%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "tabela.h"

    int yylex(void);
    void yyerror(const char *s);

    extern int yylineno;
    extern char* yytext;
    
    void print_indent(int nivel)
    {
    
        for(int i = 0; i < nivel; i++) 
            printf("    ");
            
    }

    int nivel_atual = 0;
    char escopo_atual[64] = "global";
    
%}

/* SEÇÃO DE DEFINIÇÕES */

%union 
{

    int ival;
    char *sval;
    
}

%token <sval> TOK_ID TOK_STRING_LIT
%token <ival> TOK_INT_LIT

%token TOK_VOID TOK_INT TOK_FLOAT TOK_BOOL
%token TOK_COUT TOK_OUT TOK_SCOLON TOK_LPAREN TOK_RPAREN TOK_LBRACE TOK_RBRACE
%token TOK_ASSIGN TOK_PLUS TOK_MINUS TOK_MULT TOK_DIV
%token TOK_RETURN

%left TOK_PLUS TOK_MINUS
%left TOK_MULT TOK_DIV

%type <sval> exp

%%

/* SEÇÃO DE REGRAS */

programa:
    lista_declaracoes;

lista_declaracoes:
    declaracao
    | lista_declaracoes declaracao;

declaracao:
    funcao
    | declaracao_var
    | TOK_SCOLON;

funcao:
    TOK_INT TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE 
    {
    
        inserirSimbolo($2, "int", "global");
        strcpy(escopo_atual, $2);
        printf("int %s() {\n", $2);
        nivel_atual++;
        
    }
    
    lista_comandos TOK_RBRACE 
    {
    
        nivel_atual--;
        strcpy(escopo_atual, "global");
        print_indent(nivel_atual);
        printf("}\n");
        
    };

lista_comandos:
    /* vazio */
    | lista_comandos comando;

comando:
    comando_cout
    | declaracao_var
    | comando_return;

/* Traduz o cout para printf */

comando_cout:
    TOK_COUT TOK_OUT exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("printf(\"%%d\\n\", %s);\n", $3);
        
    };

/* Declaração de variável, verifica a redeclaração e insere na tabela */

declaracao_var:
    TOK_INT TOK_ID TOK_ASSIGN exp TOK_SCOLON 
    {
    
        if (buscarSimbolo($2, escopo_atual) != NULL)
            fprintf(stderr, "Erro Semântico na linha %d: '%s' já foi declarada neste escopo\n", yylineno, $2);
        else
            inserirSimbolo($2, "int", escopo_atual);
            
        print_indent(nivel_atual);  
        printf("int %s = %s;\n", $2, $4);
        
    }
    
    | TOK_INT TOK_ID TOK_SCOLON 
    {
    
        if (buscarSimbolo($2, escopo_atual) != NULL)
            fprintf(stderr, "Erro Semântico na linha %d: '%s' já foi declarada neste escopo\n", yylineno, $2);
        else
            inserirSimbolo($2, "int", escopo_atual);
            
        print_indent(nivel_atual);
        printf("int %s;\n", $2);
        
    };

comando_return:
    TOK_RETURN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("return %s;\n", $2);
        
    };

exp:
    TOK_INT_LIT 
    {
    
        char buf[50];
        sprintf(buf, "%d", $1);
        $$ = strdup(buf);
        
    }
    | 
    TOK_ID 
    {

         /* verifica aonde o identificador foi declarado */
    
        if (buscarSimbolo($1, escopo_atual) == NULL && buscarSimbolo($1, "global") == NULL)
            fprintf(stderr, "Erro Semântico na linha %d: '%s' não foi declarada\n", yylineno, $1);
        $$ = strdup($1);
        
    }
    | 
    exp TOK_PLUS exp 
    {
    
        char buf[256];
        sprintf(buf, "%s + %s", $1, $3);
        $$ = strdup(buf);
        
    }
    | 
    exp TOK_MULT exp 
    {
    
        char buf[256];
        sprintf(buf, "%s * %s", $1, $3);
        $$ = strdup(buf);
        
    }
    | 
    TOK_LPAREN exp TOK_RPAREN
    {
    
        char buf[256];
        sprintf(buf, "(%s)", $2);
        $$ = strdup(buf);
        
    }
    | 
    TOK_STRING_LIT 
    {
    
        $$ = strdup($1);
        
    };

%%

/* Exibe os erros */

void yyerror(const char *s) 
{

    fprintf(stderr, "Erro na linha %d: %s (perto de '%s')\n", yylineno, s, yytext);
    
}

/* imprime os headers do C, roda o parser e exibe a tabela de símbolos */

int main() 
{

    printf("#include <stdio.h>\n#include <stdbool.h>\n\n");
    
    int resultado = yyparse();
    imprimirTabela();
    return resultado;
    
}