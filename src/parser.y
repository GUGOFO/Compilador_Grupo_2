%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tabela.h"


int yylex(void); 
void yyerror(const char *s); 


extern int yylineno; 
extern char* yytext; 

void print_indent(int nivel) {
    for(int i = 0; i < nivel; i++) printf("    ");
}
int nivel_atual = 0;
int escopo_atual = 0;
%}

/* SEÇÃO DE DEFINIÇÕES */

%union {
    int ival;     
    float fval;
    char *sval;   
}

/* Tokens com Valor Semântico: */

%token <sval> TOK_ID TOK_STRING_LIT
%token <ival> TOK_INT_LIT TOK_CHAR_LIT
%token <fval> TOK_FLOAT_LIT

/* Tokens de Palavras Reservadas (Keywords) */

%token TOK_VOID TOK_INT TOK_FLOAT TOK_DOUBLE TOK_BOOL TOK_LONG TOK_SHORT TOK_CHAR
%token TOK_COUT TOK_CIN TOK_RETURN TOK_IF TOK_ELSE TOK_WHILE TOK_FOR TOK_DO
%token TOK_BREAK TOK_CONTINUE TOK_SWITCH TOK_CASE TOK_DEFAULT TOK_SIZEOF
%token TOK_AND TOK_OR TOK_NOT TOK_TRUE TOK_FALSE TOK_NULLPTR
%token TOK_STD TOK_ENDL

/* Tokens de Operadores e Pontuação */

%token TOK_OUT TOK_IN TOK_SCOLON TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE
%token TOK_LBRACKET TOK_RBRACKET TOK_COMMA TOK_SCOPE
%token TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_MULT TOK_DIV TOK_MOD
%token TOK_EQ TOK_NEQ TOK_LT TOK_GT TOK_LE TOK_GE
%token TOK_LOGIC_AND TOK_LOGIC_OR TOK_LOGIC_NOT
%token TOK_ADD_ASSIGN TOK_SUB_ASSIGN TOK_MULT_ASSIGN TOK_DIV_ASSIGN TOK_MOD_ASSIGN

/* DEFINIÇÃO DE PRECEDÊNCIA */
%left TOK_LOGIC_OR
%left TOK_LOGIC_AND
%left TOK_EQ TOK_NEQ
%left TOK_LT TOK_GT TOK_LE TOK_GE
%left TOK_PLUS TOK_MINUS
%left TOK_MULT TOK_DIV TOK_MOD
%right TOK_LOGIC_NOT

/* Definição de tipos para os Não-Terminais da Gramática */
%type <sval> exp tipo


/* SEÇÃO DE REGRAS GRAMATICAIS*/

%%

programa:
    lista_declaracoes
    ;

/* Permite multiplas declaracoes no mesmo arquivo */

lista_declaracoes:
    declaracao
    | lista_declaracoes declaracao
    ;

declaracao:
    funcao
    | declaracao_var
    | TOK_SCOLON 
    ;

/* Traducao de funcoes: gera o cabecalho e controla o escopo */

funcao:
    tipo TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE {
        printf("%s %s() {\n", $1, $2);
        nivel_atual++;
        escopo_atual++;
    }
    lista_comandos TOK_RBRACE {
        removerEscopo(escopo_atual);
        escopo_atual--;
        nivel_atual--;
        print_indent(nivel_atual);
        printf("}\n");
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

/* Bloco interno de comandos */

lista_comandos:

    | lista_comandos comando
    ;

comando:
    comando_cout
    | comando_cin
    | declaracao_var
    | comando_return
    | comando_atribuicao
    | comando_if
    | comando_while
    | TOK_SCOLON
    ;

/* Converte cout << para printf e cin >> para scanf*/

comando_cout:
    TOK_STD TOK_SCOPE TOK_COUT TOK_OUT exp TOK_SCOLON {
        print_indent(nivel_atual);
        if ($5[0] == '"') {
            printf("printf(%s);\n", $5);
        } else {
            printf("printf(\"%%g\\n\", %s);\n", $5);
        }
    }
    ;

comando_cin:
    TOK_STD TOK_SCOPE TOK_CIN TOK_IN TOK_ID TOK_SCOLON {
        print_indent(nivel_atual);
        printf("scanf(\"%%g\", &%s);\n", $5);
    }
    ;

/* Traducao de declaracao de variaveis */

declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        inserirSimbolo($2, $1, escopo_atual);
        print_indent(nivel_atual);
        printf("%s %s = %s;\n", $1, $2, $4);
    }
    | tipo TOK_ID TOK_SCOLON {
        inserirSimbolo($2, $1, escopo_atual);
        print_indent(nivel_atual);
        printf("%s %s;\n", $1, $2);
    }
    ;

/* Traducao do comando de retorno */

comando_return:
    TOK_RETURN exp TOK_SCOLON {
        print_indent(nivel_atual);
        printf("return %s;\n", $2);
    }
    ;

/* Permite a atribuição de valor a uma variável */

comando_atribuicao:
    TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        Simbolo *s = buscarSimbolo($1, escopo_atual);
        if(s == NULL){
            fprintf(stderr, "Erro Semântico na linha %d: Não é possível atribuir valor a '%s' pois ela não foi declarada.\n", yylineno, $1);
            exit(1);
        }
        print_indent(nivel_atual);
        printf("%s = %s;\n", $1, $3);
    }
    ;

/* Tradução de estruturas condicionais */

comando_if:
    TOK_IF TOK_LPAREN exp TOK_RPAREN TOK_LBRACE {
        print_indent(nivel_atual);
        printf("if (%s) {\n", $3);
        nivel_atual++;
        escopo_atual++;
    }
    lista_comandos TOK_RBRACE {
        removerEscopo(escopo_atual);
        escopo_atual--;
        nivel_atual--;
        print_ident(nivel_atual);
        printf("}\n");
    }
    
    /* Tratamento do ELSE */

    | comando_if TOK_ELSE TOK_LBRACE {
        print_indent(nivel_atual);
        printf("else {\n");
        nivel_atual++;
        escopo_atual++;
    }
    lista_comandos TOK_RBRACE {
        removerEscopo(escopo_atual);
        escopo_atual--;
        nivel_atual--;
        print_ident(nivel_atual);
        printf("}\n");
    }
    ;

/* Tradução do laço while */

comando_while:
    TOK_WHILE TOK_LPAREN exp TOK_RPAREN TOK_LBRACE {
        print_ident(nivel_atual);
        printf("while (%s) {\n", $3);
        nivel_atual++;
        escopo_atual++;
    }
    lista_comandos TOK_RBRACE {
        removerEscopo(escopo_atual);
        escopo_atual--;
        nivel_atual--;
        print_indent(nivel_atual);
        printf("}\n");
    }
    ;

/* Regras de expressao: montam o texto final do codigo C */

exp:
    TOK_INT_LIT {
        char buf[50];
        sprintf(buf, "%d", $1);
        $$ = strdup(buf);
    }
    | TOK_FLOAT_LIT {
        char buf[50];
        sprintf(buf, "%g", $1);
        $$ = strdup(buf);
    }
    | TOK_CHAR_LIT {
        char buf[50];
        sprintf(buf, "'%c'", $1);
        $$ = strdup(buf);
    }
    | TOK_ID {
        $$ = strdup($1);
    }
    | TOK_STRING_LIT {
        $$ = strdup($1);
    }
    | TOK_TRUE {
        $$ = strdup("1");
    }
    | TOK_FALSE {
        $$ = strdup("0");
    }
    | TOK_NULLPTR {
        $$ = strdup("NULL");
    }
    | exp TOK_PLUS exp {
        char buf[512];
        sprintf(buf, "%s + %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_MULT exp {
        char buf[512];
        sprintf(buf, "%s * %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_EQ exp {
        char buf[512];
        sprintf(buf, "%s == %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_NEQ exp {
        char buf[512];
        sprintf(buf, "%s != %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_MINUS exp {
        char buf[512];
        sprintf(buf, "%s - %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_DIV exp {
        char buf[512];
        sprintf(buf, "%s / %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_MOD exp {
        char buf[512];
        sprintf(buf, "%s %% %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_LT exp {
        char buf[512];
        sprintf(buf, "%s < %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_GT exp {
        char buf[512];
        sprintf(buf, "%s > %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_LE exp {
        char buf[512];
        sprintf(buf, "%s <= %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_GE exp {
        char buf[512];
        sprintf(buf, "%s >= %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_LOGIC_AND exp {
        char buf[512];
        sprintf(buf, "%s && %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_LOGIC_OR exp {
        char buf[512];
        sprintf(buf, "%s || %s", $1, $3);
        $$ = strdup(buf);
    }
    | TOK_LOGIC_NOT exp {
        char buf[512];
        sprintf(buf, "!%s", $2);
        $$ = strdup(buf);
    }
    | TOK_LPAREN exp TOK_RPAREN {
        char buf[512];
        sprintf(buf, "(%s)", $2);
        $$ = strdup(buf);
    }
    ;

%%

/* FUNCOES DE SUPORTE */

void yyerror(const char *s) {
    fprintf(stderr, "Erro de Sintaxe na linha %d: %s (perto de '%s')\n", yylineno, s, yytext);
}

/* Inicia o transpilador e imprime os headers do C */
int main() {

    /* Adiciona os headers necessários no topo do ficheiro C gerado */
    printf("#include <stdio.h>\n");
    printf("#include <stdbool.h>\n\n");
    
    /* Inicia o processo de parsing */
    if (yyparse() == 0) {
        fprintf(stderr, "Transpilação concluída com sucesso!\n");
    }
    return 0;
}

