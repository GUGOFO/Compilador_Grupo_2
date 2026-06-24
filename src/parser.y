%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory>
#include <set>

#include "ast.hpp"
#include "tabela.h"

int  yylex(void);
void yyerror(const char *s);

extern int   yylineno;
extern char* yytext;

ProgramaNode* raiz        = nullptr;
int           nivel_atual = 0;
bool          erro_semantico_detectado = false;

std::set<std::string> variaveis_usadas;

static NodoPtr adotar(ASTNode* p) { return NodoPtr(p); }

bool es_tipo_numerico(const std::string& t) {
    return t == "int" || t == "float" || t == "double" || t == "long" || t == "short" || t == "char";
}

std::string obter_tipo_resultado(const std::string& t1, const std::string& t2) {
    if (t1 == "double" || t2 == "double") return "double";
    if (t1 == "float" || t2 == "float") return "float";
    if (t1 == "long" || t2 == "long") return "long";
    return "int";
}

bool verificar_atribuicao_ok(const std::string& destino, const std::string& origem) {
    if (destino == origem) return true;
    if (es_tipo_numerico(destino) && es_tipo_numerico(origem)) return true;
    return false;
}
%}

%union {
    int      ival;
    float    fval;
    char* sval;
    ASTNode* node;
    std::vector<ASTNode*>* list;
}

%token <sval> TOK_ID TOK_STRING_LIT
%token <ival> TOK_INT_LIT TOK_CHAR_LIT
%token <fval> TOK_FLOAT_LIT

%token TOK_VOID TOK_INT TOK_FLOAT TOK_DOUBLE TOK_BOOL TOK_LONG TOK_SHORT TOK_CHAR
%token TOK_COUT TOK_CIN TOK_RETURN TOK_IF TOK_ELSE TOK_WHILE TOK_FOR TOK_DO
%token TOK_BREAK TOK_CONTINUE TOK_SWITCH TOK_CASE TOK_DEFAULT TOK_SIZEOF
%token TOK_AND TOK_OR TOK_NOT TOK_TRUE TOK_FALSE TOK_NULLPTR
%token TOK_STD TOK_ENDL

%token TOK_OUT TOK_IN TOK_SCOLON TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE
%token TOK_LBRACKET TOK_RBRACKET TOK_COMMA TOK_SCOPE TOK_COLON
%token TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_MULT TOK_DIV TOK_MOD
%token TOK_EQ TOK_NEQ TOK_LT TOK_GT TOK_LE TOK_GE
%token TOK_LOGIC_AND TOK_LOGIC_OR TOK_LOGIC_NOT
%token TOK_ADD_ASSIGN TOK_SUB_ASSIGN TOK_MULT_ASSIGN TOK_DIV_ASSIGN TOK_MOD_ASSIGN

%left TOK_LOGIC_OR
%left TOK_LOGIC_AND
%left TOK_EQ TOK_NEQ
%left TOK_LT TOK_GT TOK_LE TOK_GE
%left TOK_PLUS TOK_MINUS
%left TOK_MULT TOK_DIV TOK_MOD
%right TOK_LOGIC_NOT UMINUS

%type <sval> tipo
%type <node> exp declaracao declaracao_var comando_cout comando_cin
%type <node> comando_return funcao bloco_escopo lista_comandos comando
%type <node> comando_atribuicao comando_if 
%type <node> comando_while comando_do_while comando_for parametro comando_switch lista_cases case_item default_item
%type <list> lista_parametros lista_argumentos

%%

programa:
    lista_declaracoes
    {
        // 1. Imprime a Árvore Sintática Estruturada
        fprintf(stderr, "\n======================================================================\n");
        fprintf(stderr, "                  ÁRVORE SINTÁTICA ABSTRATA (AST)\n");
        fprintf(stderr, "======================================================================\n");
        if (raiz) raiz->print();

        // 2. Imprime o Código Intermediário
        fprintf(stderr, "\n======================================================================\n");
        fprintf(stderr, "                  GERAÇÃO DE CÓDIGO INTERMEDIÁRIO (TAC)\n");
        fprintf(stderr, "======================================================================\n");
        if (raiz) raiz->gerarTAC();
        fprintf(stderr, "======================================================================\n");

        if (erro_semantico_detectado) {
            fprintf(stderr, "\n❌ Falha na compilacao: Erros semanticos detectados. Pipeline abortado.\n\n");
            exit(1); 
        }

        // 3. Executa a transpilação final para o arquivo .c (stdout)
        if (raiz) raiz->gerarC();
    }
    ;

lista_declaracoes:
    declaracao
    {
        raiz = new ProgramaNode();
        if ($1) raiz->adicionar(adotar($1));
    }
    | lista_declaracoes declaracao
    {
        if ($2) raiz->adicionar(adotar($2));
    }
    ;

declaracao:
    funcao           { $$ = $1; }
    | declaracao_var { $$ = $1; }
    | TOK_SCOLON     { $$ = nullptr; }
    ;

funcao:
    tipo TOK_ID TOK_LPAREN lista_parametros TOK_RPAREN
    {
        inserirSimbolo($2, $1, 0); // Registra a função no escopo global
    }
    bloco_escopo
    {
        std::vector<NodoPtr> params;
        if ($4) {
            for (auto* n : *$4) params.push_back(adotar(n));
            delete $4; 
        }
        auto* fn = new FuncaoNode($1, $2, std::move(params), adotar($7));
        fn->linha = yylineno;
        $$ = fn;
    }
    ;

lista_parametros:
    %empty
    {
        $$ = new std::vector<ASTNode*>();
    }
    | parametro
    {
        $$ = new std::vector<ASTNode*>();
        $$->push_back($1);
    }
    | lista_parametros TOK_COMMA parametro
    {
        $1->push_back($3);
        $$ = $1;
    }
    ;

parametro:
    tipo TOK_ID
    {
        inserirSimbolo($2, $1, nivel_atual + 1);
        auto* n = new DeclVarNode($1, $2);
        n->linha = yylineno;
        $$ = n;
    }
    ;

bloco_escopo:
    TOK_LBRACE
    {
        nivel_atual++;
    }
    lista_comandos TOK_RBRACE
    {
        fprintf(stderr, "\n--- SVAL/ESCOPO FECHANDO (Nível %d) ---", nivel_atual);
        imprimirTabela(); 
        fprintf(stderr, "---------------------------------------\n");

        removerEscopo(nivel_atual);
        nivel_atual--;
        $$ = $3;
    }
    ;

lista_comandos:
    %empty
    {
        $$ = new BlocoNode();
    }
    | lista_comandos comando
    {
        BlocoNode* b = static_cast<BlocoNode*>($1);
        if ($2) b->adicionar(adotar($2));
        $$ = b;
    }
    ;

tipo:
    TOK_INT      { $$ = strdup("int"); }
    | TOK_FLOAT  { $$ = strdup("float"); }
    | TOK_DOUBLE { $$ = strdup("double"); }
    | TOK_BOOL   { $$ = strdup("bool"); }
    | TOK_VOID   { $$ = strdup("void"); }
    | TOK_CHAR   { $$ = strdup("char"); }
    | TOK_LONG   { $$ = strdup("long"); }
    | TOK_SHORT  { $$ = strdup("short"); }
    ;

comando:
    comando_cout         { $$ = $1; }
    | comando_cin        { $$ = $1; }
    | declaracao_var     { $$ = $1; }
    | comando_return     { $$ = $1; }
    | comando_atribuicao { $$ = $1; }
    | comando_if         { $$ = $1; }
    | comando_while      { $$ = $1; }
    | comando_do_while   { $$ = $1; }
    | comando_for        { $$ = $1; }
    | comando_switch     { $$ = $1; }
    | TOK_BREAK TOK_SCOLON
    {
        $$ = new BreakNode();
        $$->linha = yylineno;
    }
    | TOK_CONTINUE TOK_SCOLON
    {
        $$ = new ContinueNode();
        $$->linha = yylineno;
    }
    | TOK_SCOLON { $$ = nullptr; }
    ;

comando_cout:
    TOK_STD TOK_SCOPE TOK_COUT TOK_OUT exp TOK_SCOLON
    {
        auto* n = new CmdCoutNode(adotar($5));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_cin:
    TOK_STD TOK_SCOPE TOK_CIN TOK_IN TOK_ID TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($5, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $5);
        variaveis_usadas.insert($5); 
        auto* n = new CmdCinNode($5);
        n->linha = yylineno;
        if (s) n->tipo_inferido = s->tipo;
        $$ = n;
    }
    ;

declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON
    {
        inserirSimbolo($2, $1, nivel_atual);
        
        if (!verificar_atribuicao_ok($1, $4->tipo_inferido)) {
            fprintf(stderr, "Erro semantico (linha %d): tipo '%s' incompativel com '%s' na declaracao de '%s'\n", 
                    yylineno, $4->tipo_inferido.c_str(), $1, $2);
            erro_semantico_detectado = true;
        }
        
        auto* n = new DeclVarNode($1, $2, adotar($4));
        n->linha = yylineno;
        $$ = n;
    }
    | tipo TOK_ID TOK_SCOLON
    {
        inserirSimbolo($2, $1, nivel_atual);
        auto* n = new DeclVarNode($1, $2);
        n->linha = yylineno;
        $$ = n;
    }
    | tipo TOK_ID TOK_LBRACKET TOK_INT_LIT TOK_RBRACKET TOK_SCOLON
    {
        std::string tipo_vetor = std::string($1) + "[]";
        inserirSimbolo($2, strdup(tipo_vetor.c_str()), nivel_atual);
        auto* n = new DeclVetorNode($1, $2, $4);
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_atribuicao:
    TOK_ID TOK_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s) {
            fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $1);
            erro_semantico_detectado = true; 
        } else {
            if (!verificar_atribuicao_ok(s->tipo, $3->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): tipo '%s' incompativel com '%s' na atribuicao de '%s'\n", 
                        yylineno, $3->tipo_inferido.c_str(), s->tipo, $1);
                erro_semantico_detectado = true;
            }
        }
        
        // 🚀 OTIMIZAÇÃO: Registra que a variável foi usada em uma atribuição simples
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_ADD_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (s && (!es_tipo_numerico(s->tipo) || !es_tipo_numerico($3->tipo_inferido))) {
            fprintf(stderr, "Erro semantico (linha %d): operador '+=' nao suportado entre '%s' e '%s'\n", 
                    yylineno, s->tipo, $3->tipo_inferido.c_str());
        }

        // 🚀 OTIMIZAÇÃO: Registra o uso
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "+=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_SUB_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (s && (!es_tipo_numerico(s->tipo) || !es_tipo_numerico($3->tipo_inferido))) {
            fprintf(stderr, "Erro semantico (linha %d): operador '-=' nao suportado entre '%s' e '%s'\n", 
                    yylineno, s->tipo, $3->tipo_inferido.c_str());
        }

        // 🚀 OTIMIZAÇÃO: Registra o uso
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "-=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_MULT_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (s && (!es_tipo_numerico(s->tipo) || !es_tipo_numerico($3->tipo_inferido))) {
            fprintf(stderr, "Erro semantico (linha %d): operador '*=' nao suportado entre '%s' e '%s'\n", 
                    yylineno, s->tipo, $3->tipo_inferido.c_str());
        }

        // 🚀 OTIMIZAÇÃO: Registra o uso
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "*=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_DIV_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (s && (!es_tipo_numerico(s->tipo) || !es_tipo_numerico($3->tipo_inferido))) {
            fprintf(stderr, "Erro semantico (linha %d): operador '/=' nao suportado entre '%s' e '%s'\n", 
                    yylineno, s->tipo, $3->tipo_inferido.c_str());
        }

        // 🚀 OTIMIZAÇÃO: Registra o uso
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "/=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_MOD_ASSIGN exp TOK_SCOLON
    {
        // 🚀 OTIMIZAÇÃO: Registra o uso
        variaveis_usadas.insert($1);

        auto* n = new AssignNode($1, "%=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_LBRACKET exp TOK_RBRACKET TOK_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s) {
            fprintf(stderr, "Erro semantico (linha %d): vetor '%s' nao declarado.\n", yylineno, $1);
            erro_semantico_detectado = true;
        } else {
            if ($3->tipo_inferido != "int") {
                fprintf(stderr, "Erro semantico (linha %d): o indice do vetor deve ser 'int' (recebeu '%s')\n", yylineno, $3->tipo_inferido.c_str());
                erro_semantico_detectado = true;
            }
            std::string t_base = s->tipo;
            if (t_base.size() > 2 && t_base.substr(t_base.size() - 2) == "[]") {
                t_base = t_base.substr(0, t_base.size() - 2);
            }
            if (!verificar_atribuicao_ok(t_base, $6->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): tipo '%s' incompativel com o tipo base do vetor '%s' ('%s')\n", 
                        yylineno, $6->tipo_inferido.c_str(), $1, t_base.c_str());
                erro_semantico_detectado = true;
            }
        }

        // 🚀 OTIMIZAÇÃO: Registra que o vetor foi usado (recebeu um valor numa posição)
        variaveis_usadas.insert($1);

        auto* n = new ArrayAssignNode($1, adotar($3), adotar($6));
        n->linha = yylineno;
        $$ = n;
    }
    ;
    
comando_if:
    TOK_IF TOK_LPAREN exp TOK_RPAREN bloco_escopo
    {
        if ($3->tipo_inferido != "bool") {
            fprintf(stderr, "Erro semantico (linha %d): a condicao do 'if' deve ser 'bool' (recebeu '%s')\n", yylineno, $3->tipo_inferido.c_str());
        }
        auto* lit = dynamic_cast<LiteralInteiroNode*>($3);
        if (lit) {
            if (lit->valor == 0) {
                $$ = new BlocoNode(); 
            } else {
                auto* n = new BlocoNode();
                n->adicionar(adotar($5));
                // Para forçar a impressão de chaves no C sem quebrar o TAC, podemos manter a semântica de bloco isolado.
                // Uma alternativa simples é usar o próprio IfNode com condição fixa ou criar um escopo em C.
                // Vamos manter o IfNode tradicional para condições verdadeiras se houver shadowing, ou simplesmente:
                auto* n_if = new IfNode(adotar($3), adotar($5));
                n_if->linha = yylineno;
                $$ = n_if;
            }
        } else {
            auto* n = new IfNode(adotar($3), adotar($5));
            n->linha = yylineno;
            $$ = n;
        }
    }
    | TOK_IF TOK_LPAREN exp TOK_RPAREN bloco_escopo TOK_ELSE bloco_escopo
    {
        if ($3->tipo_inferido != "bool") {
            fprintf(stderr, "Erro semantico (linha %d): a condicao do 'if' deve ser 'bool' (recebeu '%s')\n", yylineno, $3->tipo_inferido.c_str());
        }
        auto* lit = dynamic_cast<LiteralInteiroNode*>($3);
        if (lit) {
            if (lit->valor == 0) {
                // Se o IF for falso, o ELSE é executado. Mantemos a estrutura para não perder o escopo.
                auto* n = new IfNode(adotar($3), adotar($5), adotar($7));
                n->linha = yylineno;
                $$ = n;
            } else {
                auto* n = new IfNode(adotar($3), adotar($5), adotar($7));
                n->linha = yylineno;
                $$ = n;
            }
        } else {
            auto* n = new IfNode(adotar($3), adotar($5), adotar($7));
            n->linha = yylineno;
            $$ = n;
        }
    }
    ;

comando_while:
    TOK_WHILE TOK_LPAREN exp TOK_RPAREN bloco_escopo
    {
        if ($3->tipo_inferido != "bool") {
            fprintf(stderr, "Erro semantico (linha %d): a condicao do 'while' deve ser 'bool' (recebeu '%s')\n", yylineno, $3->tipo_inferido.c_str());
        }
        auto* n = new WhileNode(adotar($3), adotar($5));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_do_while:
    TOK_DO bloco_escopo TOK_WHILE TOK_LPAREN exp TOK_RPAREN TOK_SCOLON
    {
        if ($5->tipo_inferido != "bool") {
            fprintf(stderr, "Erro semantico (linha %d): a condicao do 'do-while' deve ser 'bool' (recebeu '%s')\n", yylineno, $5->tipo_inferido.c_str());
        }
        auto* n = new DoWhileNode(adotar($2), adotar($5));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_for:
    TOK_FOR TOK_LPAREN tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON exp TOK_SCOLON exp TOK_RPAREN
    {
        inserirSimbolo($4, $3, nivel_atual + 1);
    }
    bloco_escopo
    {
        auto* init = new DeclVarNode($3, $4, adotar($6));
        auto* n = new ForNode(adotar(init), adotar($8), adotar($10), adotar($13));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_FOR TOK_LPAREN TOK_ID TOK_ASSIGN exp TOK_SCOLON exp TOK_SCOLON exp TOK_RPAREN
    bloco_escopo
    {
        Simbolo* s = buscarSimbolo($3, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $3);
        auto* init = new AssignNode($3, "=", adotar($5));
        auto* n = new ForNode(adotar(init), adotar($7), adotar($9), adotar($11));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_switch:
    TOK_SWITCH TOK_LPAREN exp TOK_RPAREN TOK_LBRACE lista_cases TOK_RBRACE
    {
       auto* sw = static_cast<SwitchNode*>($6);
       sw->expressao = adotar($3);
       sw->linha = yylineno;
       $$ = sw;
    }
    ;

lista_cases:
    %empty
    {
        $$ = new SwitchNode(nullptr);
    }
    | lista_cases case_item
    {
        auto* sw = static_cast<SwitchNode*>($1);
        if ($2) sw->adicionarCase(adotar($2));
        $$ = sw;
    }
    | lista_cases default_item
    {
        auto* sw = static_cast<SwitchNode*>($1);
        if ($2) sw->adicionarCase(adotar($2));
        $$ = sw;
    }
    ;

case_item:
    TOK_CASE exp TOK_COLON lista_comandos
    {
       $$ = new CaseNode(adotar($2), adotar($4));
       $$->linha = yylineno;
    }
    ;

default_item:
    TOK_DEFAULT TOK_COLON lista_comandos
    {
        $$ = new CaseNode(nullptr, adotar($3));
        $$->linha = yylineno;
    }
    ;

comando_return:
    TOK_RETURN exp TOK_SCOLON
    {
        auto* n = new CmdReturnNode(adotar($2));
        n->linha = yylineno;
        $$ = n;
    }
    ;

exp:
    TOK_INT_LIT
    {
        auto* n = new LiteralInteiroNode($1);
        n->linha = yylineno;
        n->tipo_inferido = "int";
        $$ = n;
    }
    | TOK_FLOAT_LIT
    {
        auto* n = new LiteralFloatNode($1);
        n->linha = yylineno;
        n->tipo_inferido = "float";
        $$ = n;
    }
    | TOK_CHAR_LIT
    {
        auto* n = new LiteralInteiroNode($1);
        n->linha = yylineno;
        n->tipo_inferido = "char";
        $$ = n;
    }
    | TOK_TRUE
    {
        auto* n = new LiteralInteiroNode(1);
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | TOK_FALSE
    {
        auto* n = new LiteralInteiroNode(0);
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | TOK_NULLPTR
    {
        auto* n = new IdentificadorNode("NULL");
        n->linha = yylineno;
        n->tipo_inferido = "void*";
        $$ = n;
    }
    | TOK_ID
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $1);
        variaveis_usadas.insert($1); 
        auto* n = new IdentificadorNode($1);
        n->linha = yylineno;
        if (s) n->tipo_inferido = s->tipo;
        $$ = n;
    }
    | TOK_STRING_LIT
    {
        auto* n = new LiteralStringNode($1);
        n->linha = yylineno;
        n->tipo_inferido = "string";
        $$ = n;
    }
    | exp TOK_PLUS exp
    {
        // 🚀 OTIMIZAÇÃO: Tenta fazer o Constant Folding de Inteiros
        auto* esq_lit = dynamic_cast<LiteralInteiroNode*>($1);
        auto* dir_lit = dynamic_cast<LiteralInteiroNode*>($3);
        
        if (esq_lit && dir_lit) {
            auto* n = new LiteralInteiroNode(esq_lit->valor + dir_lit->valor);
            n->linha = yylineno;
            n->tipo_inferido = "int";
            $$ = n; // Substitui os três nós por um único nó com o valor somado!
        } else {
            // Se não forem constantes, mantém o comportamento normal de gerar o nó binário
            auto* n = new OperacaoBinariaNode("+", adotar($1), adotar($3));
            n->linha = yylineno;
            if (!es_tipo_numerico($1->tipo_inferido) || !es_tipo_numerico($3->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): operador '+' nao suportado entre '%s' e '%s'\n", 
                        yylineno, $1->tipo_inferido.c_str(), $3->tipo_inferido.c_str());
                erro_semantico_detectado = true;
                n->tipo_inferido = "desconhecido";
            } else {
                n->tipo_inferido = obter_tipo_resultado($1->tipo_inferido, $3->tipo_inferido);
            }
            $$ = n;
        }
    }
    | exp TOK_MINUS exp
    {
        // 🚀 OTIMIZAÇÃO: Tenta fazer o Constant Folding de Inteiros
        auto* esq_lit = dynamic_cast<LiteralInteiroNode*>($1);
        auto* dir_lit = dynamic_cast<LiteralInteiroNode*>($3);
        
        if (esq_lit && dir_lit) {
            auto* n = new LiteralInteiroNode(esq_lit->valor - dir_lit->valor);
            n->linha = yylineno;
            n->tipo_inferido = "int";
            $$ = n;
        } else {
            auto* n = new OperacaoBinariaNode("-", adotar($1), adotar($3));
            n->linha = yylineno;
            if (!es_tipo_numerico($1->tipo_inferido) || !es_tipo_numerico($3->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): operador '-' nao suportado entre '%s' e '%s'\n", 
                        yylineno, $1->tipo_inferido.c_str(), $3->tipo_inferido.c_str());
                n->tipo_inferido = "desconhecido";
            } else {
                n->tipo_inferido = obter_tipo_resultado($1->tipo_inferido, $3->tipo_inferido);
            }
            $$ = n;
        }
    }
    | TOK_MINUS exp %prec UMINUS
    {
        auto* lit = dynamic_cast<LiteralInteiroNode*>($2);
        if (lit) {
            auto* n = new LiteralInteiroNode(-lit->valor);
            n->linha = yylineno;
            n->tipo_inferido = "int";
            $$ = n;
        } else {
            auto* n = new OperacaoBinariaNode("-", adotar($2), nullptr);
            n->linha = yylineno;
            if (!es_tipo_numerico($2->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): operador unario '-' nao suportado para o tipo '%s'\n", 
                        yylineno, $2->tipo_inferido.c_str());
            }
            n->tipo_inferido = $2->tipo_inferido;
            $$ = n;
        }
    }
    | exp TOK_MULT exp
    {
        // 🚀 OTIMIZAÇÃO: Tenta fazer o Constant Folding de Inteiros
        auto* esq_lit = dynamic_cast<LiteralInteiroNode*>($1);
        auto* dir_lit = dynamic_cast<LiteralInteiroNode*>($3);
        
        if (esq_lit && dir_lit) {
            auto* n = new LiteralInteiroNode(esq_lit->valor * dir_lit->valor);
            n->linha = yylineno;
            n->tipo_inferido = "int";
            $$ = n;
        } else {
            auto* n = new OperacaoBinariaNode("*", adotar($1), adotar($3));
            n->linha = yylineno;
            if (!es_tipo_numerico($1->tipo_inferido) || !es_tipo_numerico($3->tipo_inferido)) {
                fprintf(stderr, "Erro semantico (linha %d): operador '*' nao suportado entre '%s' e '%s'\n", 
                        yylineno, $1->tipo_inferido.c_str(), $3->tipo_inferido.c_str());
                n->tipo_inferido = "desconhecido";
            } else {
                n->tipo_inferido = obter_tipo_resultado($1->tipo_inferido, $3->tipo_inferido);
            }
            $$ = n;
        }
    }
    | exp TOK_DIV exp
    {
        auto* n = new OperacaoBinariaNode("/", adotar($1), adotar($3));
        n->linha = yylineno;
        if (!es_tipo_numerico($1->tipo_inferido) || !es_tipo_numerico($3->tipo_inferido)) {
            fprintf(stderr, "Erro semantico (linha %d): operador '/' nao suportado entre '%s' e '%s'\n", 
                    yylineno, $1->tipo_inferido.c_str(), $3->tipo_inferido.c_str());
            n->tipo_inferido = "desconhecido";
        } else {
            n->tipo_inferido = obter_tipo_resultado($1->tipo_inferido, $3->tipo_inferido);
        }
        $$ = n;
    }
    | exp TOK_MOD exp
    {
        auto* n = new OperacaoBinariaNode("%", adotar($1), adotar($3));
        n->linha = yylineno;
        if ($1->tipo_inferido != "int" || $3->tipo_inferido != "int") {
            fprintf(stderr, "Erro semantico (linha %d): operador '%%' exige operandos do tipo 'int' (recebeu '%s' e '%s')\n", 
                    yylineno, $1->tipo_inferido.c_str(), $3->tipo_inferido.c_str());
        }
        n->tipo_inferido = "int";
        $$ = n;
    }
    | exp TOK_EQ exp
    {
        auto* n = new OperacaoBinariaNode("==", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_NEQ exp
    {
        auto* n = new OperacaoBinariaNode("!=", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_LT exp
    {
        auto* n = new OperacaoBinariaNode("<", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_GT exp
    {
        auto* n = new OperacaoBinariaNode(">", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_LE exp
    {
        auto* n = new OperacaoBinariaNode("<=", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_GE exp
    {
        auto* n = new OperacaoBinariaNode(">=", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_LOGIC_AND exp
    {
        auto* n = new OperacaoBinariaNode("&&", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | exp TOK_LOGIC_OR exp
    {
        auto* n = new OperacaoBinariaNode("||", adotar($1), adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | TOK_LOGIC_NOT exp
    {
        auto* n = new OperacaoBinariaNode("!", adotar($2), nullptr);
        n->linha = yylineno;
        n->tipo_inferido = "bool";
        $$ = n;
    }
    | TOK_LPAREN exp TOK_RPAREN
    {
        auto* n = new ExpParenNode(adotar($2));
        n->linha = yylineno;
        n->tipo_inferido = $2->tipo_inferido;
        $$ = n;
    }
    | TOK_SIZEOF TOK_LPAREN tipo TOK_RPAREN
    {
        auto* n = new IdentificadorNode($3);
        n->linha = yylineno;
        n->tipo_inferido = "int";
        $$ = n;
    }
    | TOK_SIZEOF TOK_LPAREN exp TOK_RPAREN
    {
        auto* n = new ExpParenNode(adotar($3));
        n->linha = yylineno;
        n->tipo_inferido = "int";
        $$ = n;
    }
    | TOK_ID TOK_LBRACKET exp TOK_RBRACKET
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semantico (linha %d): vetor '%s' nao declarado.\n", yylineno, $1);
        
        // 🚀 OTIMIZAÇÃO: Registra que o vetor foi acessado/lido para uma expressão
        variaveis_usadas.insert($1);

        auto* n = new ArrayAccessNode($1, adotar($3));
        n->linha = yylineno;
        if (s) {
            std::string t = s->tipo;
            if (t.size() > 2 && t.substr(t.size()-2) == "[]") n->tipo_inferido = t.substr(0, t.size()-2);
            else n->tipo_inferido = t;
        }
        $$ = n;
    }
    | TOK_ID TOK_LPAREN lista_argumentos TOK_RPAREN
    {
        Simbolo* s = buscarSimbolo($1, 0);
        if (!s) {
            fprintf(stderr, "Erro semantico (linha %d): funcao '%s' nao declarada.\n", yylineno, $1);
            erro_semantico_detectado = true;
        }
        
        // Como a struct Simbolo não tem campos de parâmetros, 
        // saltamos a validação de aridade (número de argumentos) 
        // para não quebrar a compilação, mas mantemos a chamada.
        
        std::vector<NodoPtr> args;
        if ($3) {
            for (auto* n : *$3) args.push_back(adotar(n));
            delete $3;
        }
        
        auto* n = new ChamadaFuncaoNode($1, std::move(args));
        n->linha = yylineno;
        if (s) n->tipo_inferido = s->tipo;
        $$ = n;
    }
    ;

lista_argumentos:
    %empty
    {
        $$ = new std::vector<ASTNode*>();
    }
    | exp
    {
        $$ = new std::vector<ASTNode*>();
        $$->push_back($1);
    }
    | lista_argumentos TOK_COMMA exp
    {
        $1->push_back($3);
        $$ = $1;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintatico (linha %d): %s (perto de '%s')\n", yylineno, s, yytext);
}

int main() {
    if (yyparse() != 0) {
        fprintf(stderr, "Falha no parsing.\n");
        return 1;
    }
    fprintf(stderr, "Transpilacao concluida com sucesso!\n");
    delete raiz;
    return 0;
}