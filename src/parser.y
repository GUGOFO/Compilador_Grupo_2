%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory>

#include "ast.hpp"
#include "tabela.h"

int  yylex(void);
void yyerror(const char *s);

extern int   yylineno;
extern char* yytext;

ProgramaNode* raiz        = nullptr;
int           nivel_atual = 0;

static NodoPtr adotar(ASTNode* p) { return NodoPtr(p); }
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
%token TOK_LBRACKET TOK_RBRACKET TOK_COMMA TOK_SCOPE
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
%type <node> comando_while comando_do_while comando_for parametro
%type <list> lista_parametros lista_argumentos

%%

programa:
    lista_declaracoes
    {
        // 1. Imprime a Árvore Sintática Estruturada
        fprintf(stderr, "\n======================================================================\n");
        fprintf(stderr, "                  🌳 ÁRVORE SINTÁTICA ABSTRATA (AST)\n");
        fprintf(stderr, "======================================================================\n");
        if (raiz) raiz->print();

        // 2. Imprime o Código Intermediário
        fprintf(stderr, "\n======================================================================\n");
        fprintf(stderr, "                  ⚙️ GERAÇÃO DE CÓDIGO INTERMEDIÁRIO (TAC)\n");
        fprintf(stderr, "======================================================================\n");
        if (raiz) raiz->gerarTAC();
        fprintf(stderr, "======================================================================\n");

        // 3. Executa a transpilação final silenciosa para o arquivo .c (stdout)
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
        // Converte o std::vector<ASTNode*>* para um std::vector<NodoPtr>
        std::vector<NodoPtr> params;
        if ($4) {
            for (auto* n : *$4) params.push_back(adotar(n));
            delete $4; // Limpa o vetor temporário do Bison
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
        // Insere o parâmetro no escopo da função (nivel_atual + 1)
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
    ;

comando_atribuicao:
    TOK_ID TOK_ASSIGN exp TOK_SCOLON
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $1);
        auto* n = new AssignNode($1, "=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_ADD_ASSIGN exp TOK_SCOLON
    {
        auto* n = new AssignNode($1, "+=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_SUB_ASSIGN exp TOK_SCOLON
    {
        auto* n = new AssignNode($1, "-=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_MULT_ASSIGN exp TOK_SCOLON
    {
        auto* n = new AssignNode($1, "*=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_DIV_ASSIGN exp TOK_SCOLON
    {
        auto* n = new AssignNode($1, "/=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_ID TOK_MOD_ASSIGN exp TOK_SCOLON
    {
        auto* n = new AssignNode($1, "%=", adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_if:
    TOK_IF TOK_LPAREN exp TOK_RPAREN bloco_escopo
    {
        auto* n = new IfNode(adotar($3), adotar($5));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_IF TOK_LPAREN exp TOK_RPAREN bloco_escopo TOK_ELSE bloco_escopo
    {
        auto* n = new IfNode(adotar($3), adotar($5), adotar($7));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_while:
    TOK_WHILE TOK_LPAREN exp TOK_RPAREN bloco_escopo
    {
        auto* n = new WhileNode(adotar($3), adotar($5));
        n->linha = yylineno;
        $$ = n;
    }
    ;

comando_do_while:
    TOK_DO bloco_escopo TOK_WHILE TOK_LPAREN exp TOK_RPAREN TOK_SCOLON
    {
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
    |
    TOK_FOR TOK_LPAREN TOK_ID TOK_ASSIGN exp TOK_SCOLON exp TOK_SCOLON exp TOK_RPAREN
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
        auto* n = new OperacaoBinariaNode("+", adotar($1), adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | exp TOK_MINUS exp
    {
        auto* n = new OperacaoBinariaNode("-", adotar($1), adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | TOK_MINUS exp %prec UMINUS
    {
        // Reutilizamos o nó binário, mas passando nullptr para o lado direito!
        auto* n = new OperacaoBinariaNode("-", adotar($2), nullptr);
        n->linha = yylineno;
        n->tipo_inferido = $2->tipo_inferido;
        $$ = n;
    }
    | exp TOK_MULT exp
    {
        auto* n = new OperacaoBinariaNode("*", adotar($1), adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | exp TOK_DIV exp
    {
        auto* n = new OperacaoBinariaNode("/", adotar($1), adotar($3));
        n->linha = yylineno;
        $$ = n;
    }
    | exp TOK_MOD exp
    {
        auto* n = new OperacaoBinariaNode("%", adotar($1), adotar($3));
        n->linha = yylineno;
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
    | TOK_ID TOK_LPAREN lista_argumentos TOK_RPAREN
    {
        std::vector<NodoPtr> args;
        if ($3) {
            for (auto* n : *$3) args.push_back(adotar(n));
            delete $3;
        }
        auto* n = new ChamadaFuncaoNode($1, std::move(args));
        n->linha = yylineno;
        
        // Validação semântica opcional: checa se a função foi declarada
        Simbolo* s = buscarSimbolo($1, 0);
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