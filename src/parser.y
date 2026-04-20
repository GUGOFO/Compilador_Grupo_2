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


/* SEÇÃO DE REGRAS */

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
    TOK_INT TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE {
        printf("int %s() {\n", $2);
        nivel_atual++; 
    }
    lista_comandos TOK_RBRACE {
        nivel_atual--;
        print_indent(nivel_atual);
        printf("}\n");
    }
    ;

/* Bloco interno de comandos */

lista_comandos:

    | lista_comandos comando
    ;

comando:
    comando_cout
    | declaracao_var
    | comando_return
    ;

/* Converte cout << para printf */

comando_cout:
    TOK_COUT TOK_OUT exp TOK_SCOLON {
        print_indent(nivel_atual);
        printf("printf(\"%%d\\n\", %s);\n", $3);
    }
    ;

/* Traducao de declaracao de variaveis */

declaracao_var:
    TOK_INT TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        print_indent(nivel_atual);
        printf("int %s = %s;\n", $2, $4);
    }
    | TOK_INT TOK_ID TOK_SCOLON {
        print_indent(nivel_atual);
        printf("int %s;\n", $2);
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
    | TOK_ID {
        $$ = strdup($1);
    }
    | exp TOK_PLUS exp {
        char buf[256];
        sprintf(buf, "%s + %s", $1, $3);
        $$ = strdup(buf);
    }
    | exp TOK_MULT exp {
        char buf[256];
        sprintf(buf, "%s * %s", $1, $3);
        $$ = strdup(buf);
    }
    | TOK_LPAREN exp TOK_RPAREN {
        char buf[256];
        sprintf(buf, "(%s)", $2);
        $$ = strdup(buf);
    }
    | TOK_STRING_LIT {
        $$ = strdup($1);
    }
    ;

%%

/* FUNCOES DE SUPORTE */

/* Exibe erros de sintaxe e a linha onde ocorreram */
void yyerror(const char *s) {
    fprintf(stderr, "Erro na linha %d: %s\n", yylineno, s);
}

/* Inicia o transpilador e imprime os headers do C */
int main() {
    printf("#include <stdio.h>\n#include <stdbool.h>\n\n");
    return yyparse();
}

