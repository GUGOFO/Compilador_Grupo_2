%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

int coluna = 1;

%}

%option yylineno
%option noyywrap

%%

"/*" { 
         int c;
         while((c = input()) != 0) {
             if(c == '*') {
                 if((c = input()) == '/') break;
                 else unput(c);
             }
             else if(c == '\n') coluna = 1; 
             else coluna++;
         }
     }

"//".* { ; }

[ ]+            { coluna += yyleng; } 
\t              { coluna += 8; }
\r              { ; }
\n              { coluna = 1; }       


 /* 
   Aqui esta o mapeamento das palavras reservadas, para que ele identifique todas
 */

"and"           { coluna += yyleng; return TOK_AND; }
"bool"          { coluna += yyleng; return TOK_BOOL; }
"break"         { coluna += yyleng; return TOK_BREAK; }
"case"          { coluna += yyleng; return TOK_CASE; }
"char"          { coluna += yyleng; return TOK_CHAR; }
"cin"           { coluna += yyleng; return TOK_CIN; }
"continue"      { coluna += yyleng; return TOK_CONTINUE; }
"cout"          { coluna += yyleng; return TOK_COUT; }
"default"       { coluna += yyleng; return TOK_DEFAULT; }
"do"            { coluna += yyleng; return TOK_DO; }
"double"        { coluna += yyleng; return TOK_DOUBLE; }
"else"          { coluna += yyleng; return TOK_ELSE; }
"false"         { coluna += yyleng; return TOK_FALSE; }
"float"         { coluna += yyleng; return TOK_FLOAT; }
"for"           { coluna += yyleng; return TOK_FOR; }
"if"            { coluna += yyleng; return TOK_IF; }
"int"           { coluna += yyleng; return TOK_INT; }
"long"          { coluna += yyleng; return TOK_LONG; }
"not"           { coluna += yyleng; return TOK_NOT; }
"nullptr"       { coluna += yyleng; return TOK_NULLPTR; }
"or"            { coluna += yyleng; return TOK_OR; }
"return"        { coluna += yyleng; return TOK_RETURN; }
"short"         { coluna += yyleng; return TOK_SHORT; }
"sizeof"        { coluna += yyleng; return TOK_SIZEOF; }
"std"           { coluna += yyleng; return TOK_STD; }
"switch"        { coluna += yyleng; return TOK_SWITCH; }
"true"          { coluna += yyleng; return TOK_TRUE; }
"void"          { coluna += yyleng; return TOK_VOID; }
"while"         { coluna += yyleng; return TOK_WHILE; }

 /* 
   Aqui tem q estar os operadores com 2 caracteres, para que eles identifiquem primeiro antes dos que estão com 1 caracteres
 */

"+="            { coluna += yyleng; return TOK_ADD_ASSIGN; }
"-="            { coluna += yyleng; return TOK_SUB_ASSIGN; }
"*="            { coluna += yyleng; return TOK_MULT_ASSIGN; }
"/="            { coluna += yyleng; return TOK_DIV_ASSIGN; }
"%="            { coluna += yyleng; return TOK_MOD_ASSIGN; }
"=="            { coluna += yyleng; return TOK_EQ; }
"!="            { coluna += yyleng; return TOK_NEQ; }
"<="            { coluna += yyleng; return TOK_LE; }
">="            { coluna += yyleng; return TOK_GE; }
"&&"            { coluna += yyleng; return TOK_LOGIC_AND; }
"||"            { coluna += yyleng; return TOK_LOGIC_OR; }

 /* 
   Aqui tem todas as reservadas do C++ especificamente 
 */

"<<"            { coluna += yyleng; return TOK_OUT; }
">>"            { coluna += yyleng; return TOK_IN; }
"::"            { coluna += yyleng; return TOK_SCOPE; }

 /* 
   Operadores e pontuação
 */

"+"             { coluna += yyleng; return TOK_PLUS; }
"-"             { coluna += yyleng; return TOK_MINUS; }
"*"             { coluna += yyleng; return TOK_MULT; }
"/"             { coluna += yyleng; return TOK_DIV; }
"%"             { coluna += yyleng; return TOK_MOD; }
"="             { coluna += yyleng; return TOK_ASSIGN; }
"<"             { coluna += yyleng; return TOK_LT; }
">"             { coluna += yyleng; return TOK_GT; }
"!"             { coluna += yyleng; return TOK_LOGIC_NOT; }
";"             { coluna += yyleng; return TOK_SCOLON; }
","             { coluna += yyleng; return TOK_COMMA; }
"("             { coluna += yyleng; return TOK_LPAREN; }
")"             { coluna += yyleng; return TOK_RPAREN; }
"{"             { coluna += yyleng; return TOK_LBRACE; }
"}"             { coluna += yyleng; return TOK_RBRACE; }
"["             { coluna += yyleng; return TOK_LBRACKET; }
"]"             { coluna += yyleng; return TOK_RBRACKET; }

 /* 
   Identifica os valores de INT, FLOAT, CHAR e STRING 
 */

[0-9]*\.[0-9]+ { 
    yylval.fval = atof(yytext); 
    coluna += yyleng;
    return TOK_FLOAT_LIT; 
}

[0-9]+ { 
    yylval.ival = atoi(yytext); 
    coluna += yyleng;
    return TOK_INT_LIT; 
}

\"([^"\\\n]|\\.)*\" { 
    yylval.sval = strdup(yytext); 
    coluna += yyleng;
    return TOK_STRING_LIT; 
}

'(\\.|[^\\'])' { 
    coluna += yyleng;
    return TOK_CHAR_LIT; 
}

 /* 
   identificadores para variaveis, os classiocos "Tokens_ID"
 */

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.sval = strdup(yytext);
    coluna += yyleng;
    return TOK_ID; 
}

 /* 
   Printar os erros
 */

. { 
    printf("Erro Léxico na linha %d, coluna %d: caractere '%s' inválido\n", yylineno, coluna, yytext); 
    coluna++; 
}

%%