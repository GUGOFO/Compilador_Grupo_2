%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tokens.h"

typedef union {
    int ival;
    float fval;
    char cval;
    char *sval;
} YYSTYPE;

YYSTYPE yylval; 
%}

%option yylineno
%option noyywrap

%%
[ \t\r\n]+        
"//".* 
%%

int main() {
    int token;
    while ((token = yylex()) != 0) {
        printf("Token: %d | Lexema: %s\n", token, yytext);
    }
    return 0;
}