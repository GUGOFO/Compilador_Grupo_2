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

 /* 
   Aqui esta o mapeamento das palavras reservadas, para que ele identifique todas
 */

"and"           { return TOK_AND; }
"bool"          { return TOK_BOOL; }
"break"         { return TOK_BREAK; }
"case"          { return TOK_CASE; }
"char"          { return TOK_CHAR; }
"cin"           { return TOK_CIN; }
"continue"      { return TOK_CONTINUE; }
"cout"          { return TOK_COUT; }
"default"       { return TOK_DEFAULT; }
"do"            { return TOK_DO; }
"double"        { return TOK_DOUBLE; }
"else"          { return TOK_ELSE; }
"false"         { return TOK_FALSE; }
"float"         { return TOK_FLOAT; }
"for"           { return TOK_FOR; }
"if"            { return TOK_IF; }
"int"           { return TOK_INT; }
"long"          { return TOK_LONG; }
"not"           { return TOK_NOT; }
"nullptr"       { return TOK_NULLPTR; }
"or"            { return TOK_OR; }
"return"        { return TOK_RETURN; }
"short"         { return TOK_SHORT; }
"sizeof"        { return TOK_SIZEOF; }
"switch"        { return TOK_SWITCH; }
"true"          { return TOK_TRUE; }
"void"          { return TOK_VOID; }
"while"         { return TOK_WHILE; }

 /* 
   Aqui tem q estar os operadores com 2 caracteres, para que eles identifiquem primeiro antes
   dos que estão com 1 caracteres
 */

"+="            { return TOK_ADD_ASSIGN; }
"-="            { return TOK_SUB_ASSIGN; }
"*="            { return TOK_MULT_ASSIGN; }
"/="            { return TOK_DIV_ASSIGN; }
"%="            { return TOK_MOD_ASSIGN; }
"=="            { return TOK_EQ; }
"!="            { return TOK_NEQ; }
"<="            { return TOK_LE; }
">="            { return TOK_GE; }
"&&"            { return TOK_LOGIC_AND; }
"||"            { return TOK_LOGIC_OR; }

 /* 
   Aqui tem todas as reservadas do C++ especificamente 
 */

"<<"            { return TOK_OUT; }
">>"            { return TOK_IN; }
"::"            { return TOK_SCOPE; }

 /* 
   Operadores e pontuação
 */

"+"             { return TOK_PLUS; }
"-"             { return TOK_MINUS; }
"*"             { return TOK_MULT; }
"/"             { return TOK_DIV; }
"%"             { return TOK_MOD; }
"="             { return TOK_ASSIGN; }
"<"             { return TOK_LT; }
">"             { return TOK_GT; }
"!"             { return TOK_LOGIC_NOT; }
";"             { return TOK_SCOLON; }
","             { return TOK_COMMA; }
"("             { return TOK_LPAREN; }
")"             { return TOK_RPAREN; }
"{"             { return TOK_LBRACE; }
"}"             { return TOK_RBRACE; }
"["             { return TOK_LBRACKET; }
"]"             { return TOK_RBRACKET; }

 /* 
   identificadores para variaveis, os classiocos "Tokens_ID"
 */

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.sval = strdup(yytext); 
    return TOK_ID; 
}

%%

int main() {
    int token;
    while ((token = yylex()) != 0) {
        printf("Token: %d | Lexema: %s\n", token, yytext);
    }
    return 0;
}