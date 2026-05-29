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

ProgramaNode* raiz       = nullptr;
int           nivel_atual = 0;

static BlocoNode* blocoAtual = nullptr;
static NodoPtr adotar(ASTNode* p) { return NodoPtr(p); }
%}

%union {
    int      ival;
    float    fval;
    char*    sval;
    ASTNode* node;
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
%right TOK_LOGIC_NOT

%type <sval> tipo
%type <node> exp declaracao declaracao_var comando_cout comando_cin
%type <node> comando_return funcao bloco_funcao comando

%%

programa:
    lista_declaracoes
    {
        raiz->gerarC();
        fprintf(stderr, "\n");
        imprimirTabela();
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
    tipo TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE
    {
        inserirSimbolo($2, $1, 0);
        nivel_atual++;
        blocoAtual = new BlocoNode();
    }
    bloco_funcao TOK_RBRACE
    {
        removerEscopo(nivel_atual);
        nivel_atual--;

        auto* fn = new FuncaoNode($1, $2, adotar($7));
        fn->linha = yylineno;
        $$ = fn;
    }
    ;

bloco_funcao:
    /* vazio */
    {
        $$ = blocoAtual;
    }
    | bloco_funcao comando
    {
        BlocoNode* b = static_cast<BlocoNode*>($1);
        if ($2) b->adicionar(adotar($2));
        $$ = b;
    }
    ;

tipo:
    TOK_INT      { $$ = "int"; }
    | TOK_FLOAT  { $$ = "float"; }
    | TOK_DOUBLE { $$ = "double"; }
    | TOK_BOOL   { $$ = "bool"; }
    | TOK_VOID   { $$ = "void"; }
    | TOK_CHAR   { $$ = "char"; }
    | TOK_LONG   { $$ = "long"; }
    | TOK_SHORT  { $$ = "short"; }
    ;

comando:
    comando_cout     { $$ = $1; }
    | comando_cin    { $$ = $1; }
    | declaracao_var { $$ = $1; }
    | comando_return { $$ = $1; }
    | TOK_SCOLON     { $$ = nullptr; }
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
            fprintf(stderr, "Erro semântico (linha %d): variável '%s' não declarada.\n", yylineno, $5);

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
    | TOK_ID
    {
        Simbolo* s = buscarSimbolo($1, nivel_atual);
        if (!s)
            fprintf(stderr, "Erro semântico (linha %d): variável '%s' não declarada.\n", yylineno, $1);

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
    | TOK_LPAREN exp TOK_RPAREN
    {
        auto* n = new ExpParenNode(adotar($2));
        n->linha = yylineno;
        n->tipo_inferido = $2->tipo_inferido;
        $$ = n;
    }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro sintático (linha %d): %s (perto de '%s')\n", yylineno, s, yytext);
}

int main() {
    if (yyparse() != 0) {
        fprintf(stderr, "Falha no parsing.\n");
        return 1;
    }
    fprintf(stderr, "Transpilação concluída com sucesso!\n");
    delete raiz;
    return 0;
}
