%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int yylex(void); 
void yyerror(const char *s); 


extern int yylineno; 
extern char* yytext; 


void print_indent(int nivel) {
    for(int i = 0; i < nivel; i++) printf("    ");
}
int nivel_atual = 0;
%}

/* SEÇÃO DE DEFINIÇÕES */

%union {
    int ival;     
    char *sval;   
}

/* Tokens com Valor Semântico: */

%token <sval> TOK_ID TOK_STRING_LIT
%token <ival> TOK_INT_LIT

/* Tokens de Estrutura: */

%token TOK_VOID TOK_INT TOK_FLOAT TOK_BOOL
%token TOK_COUT TOK_OUT TOK_SCOLON TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE
%token TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_MULT TOK_DIV
%token TOK_RETURN 

/* Precedência e Associatividade: */

%left TOK_PLUS TOK_MINUS
%left TOK_MULT TOK_DIV

/* Definição de Tipos para Não-Terminais: */

%type <sval> exp


/* SEÇÃO DE Regras */

%%

/* FUNCOES DE SUPORTE */
void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d: %s\n", yylineno, s);
}

int main() {
    printf("#include <stdio.h>\n#include <stdbool.h>\n\n");
    return yyparse();
}