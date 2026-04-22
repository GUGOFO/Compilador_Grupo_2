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
    }
    lista_comandos TOK_RBRACE {
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
    | declaracao_var
    | comando_return
    | TOK_SCOLON
    ;

/* Converte cout << para printf */

comando_cout:
    TOK_COUT TOK_OUT exp TOK_SCOLON {
        print_indent(nivel_atual);
        printf("printf(\"%%g\\n\", %s);\n", $3);
    }
    ;

/* Traducao de declaracao de variaveis */

declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        print_indent(nivel_atual);
        printf("%s %s = %s;\n", $1, $2, $4);
    }
    | tipo TOK_ID TOK_SCOLON {
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
    | TOK_ID {
        $$ = strdup($1);
    }
    | TOK_STRING_LIT {
        $$ = strdup($1);
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

