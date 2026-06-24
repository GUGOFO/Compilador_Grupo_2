%{

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "tabela.h"

    int yylex(void);
    void yyerror(const char *s);

    extern int yylineno;
    extern char* yytext;

    typedef struct{

        char *codigo;
        char *tipo;
        
    }Exp;

    Exp *novaExp(const char *codigo, const char *tipo)
    {
    
        Exp *e = malloc(sizeof(Exp));
        e -> codigo = strdup(codigo);
        e -> tipo   = strdup(tipo);
        return e;
        
    }
    
    void print_indent(int nivel)
    {
    
        for(int i = 0; i < nivel; i++) 
            printf("    ");
            
    }

    int tipo_numerico(const char *t)
    {
    
        return strcmp(t, "int")    == 0 || 
               strcmp(t, "float")  == 0 ||
               strcmp(t, "double") == 0 || 
               strcmp(t, "long")   == 0 ||
               strcmp(t, "short")  == 0 || 
               strcmp(t, "char")   == 0;
               
    }

    const char *tipo_resultado_op(const char *t1, const char *t2)
    {
    
        if(strcmp(t1, "double") == 0 || strcmp(t2, "double") == 0) 
            return "double";
        if(strcmp(t1, "float")  == 0 || strcmp(t2, "float")  == 0) 
            return "float";
        if(strcmp(t1, "long")   == 0 || strcmp(t2, "long")   == 0) 
            return "long";
            
        return "int";
        
    }

    int tipo_atribuicao_ok(const char *destino, const char *origem)
    {
    
        if(strcmp(destino, origem) == 0) 
            return 1;
        if(tipo_numerico(destino) && tipo_numerico(origem)) 
            return 1;
            
        return 0;
        
    }

    int nivel_atual = 0;
    int escopo_atual = 0;
    char escopo_atual[64] = "global";
    
%}

/* SEÇÃO DE DEFINIÇÕES */

%union 
{

    int ival;
    float fval;
    char *sval;
    Exp *einfo;
    
}

/* Tokens com Valor Semântico */

%token <sval> TOK_ID TOK_STRING_LIT
%token <ival> TOK_INT_LIT TOK_CHAR_LIT
%token <fval> TOK_FLOAT_LIT

/* Tokens de Palavras Reservadas */

%token TOK_VOID TOK_INT TOK_FLOAT TOK_DOUBLE TOK_BOOL TOK_LONG TOK_SHORT TOK_CHAR
%token TOK_COUT TOK_CIN TOK_RETURN TOK_IF TOK_ELSE TOK_WHILE TOK_FOR TOK_DO
%token TOK_BREAK TOK_CONTINUE TOK_SWITCH TOK_CASE TOK_DEFAULT TOK_SIZEOF
%token TOK_TRUE TOK_FALSE TOK_NULLPTR
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
%type <sval>  tipo
%type <einfo> exp

%%

/* SEÇÃO DE REGRAS GRAMATICAIS */

programa:
    lista_declaracoes;
    
lista_declaracoes:
    declaracao
    | lista_declaracoes declaracao;
    
declaracao:
    funcao
    | declaracao_var
    | TOK_SCOLON;
    
/* Registra a função na tabela, rastreia o tipo de retorno e controla o escopo */

funcao:

    tipo TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE 
    {
    
        inserirSimbolo($2, $1, escopo_atual);
        
        strcpy(tipo_retorno_atual, $1);
        
        printf("%s %s() {\n", $1, $2);
        
        nivel_atual++;
        escopo_atual++;
        
    }
    
    lista_comandos TOK_RBRACE 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        tipo_retorno_atual[0] = '\0';
        
        print_indent(nivel_atual);
        printf("}\n");
        
    };
    
tipo:

    TOK_INT      { $$ = "int"; }
    | TOK_FLOAT  { $$ = "float"; }
    | TOK_DOUBLE { $$ = "double"; }
    | TOK_BOOL   { $$ = "bool"; }
    | TOK_VOID   { $$ = "void"; }
    | TOK_CHAR   { $$ = "char"; }
    | TOK_LONG   { $$ = "long"; }
    | TOK_SHORT  { $$ = "short"; };
    
lista_comandos:

    | lista_comandos comando;
    
comando:
    comando_cout
    | comando_cin
    | declaracao_var
    | declaracao_var_for
    | comando_return
    | comando_atribuicao
    | comando_if
    | comando_while
    | comando_do_while
    | comando_for
    | TOK_BREAK TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("break;\n");
        
    }
    | TOK_CONTINUE TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("continue;\n");
        
    }
    | TOK_SCOLON ;
    
/* Converte cout << para printf */

comando_cout:
    TOK_STD TOK_SCOPE TOK_COUT TOK_OUT exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        if($5->codigo[0] == '"')
            printf("printf(%s);\n", $5 -> codigo);
        else
            printf("printf(\"%%g\\n\", %s);\n", $5 -> codigo);
            
    };
    
/* Converte cin >> para scanf */

comando_cin:
    TOK_STD TOK_SCOPE TOK_CIN TOK_IN TOK_ID TOK_SCOLON 
    {
    
        if(buscarSimbolo($5, escopo_atual) == NULL)
            fprintf(stderr, "Erro Semântico na linha %d: '%s' não foi declarada\n", yylineno, $5);
            
        print_indent(nivel_atual);
        printf("scanf(\"%%g\", &%s);\n", $5);
        
    };
    
/* Verifica redeclaração, compatibilidade de tipos e insere na tabela */

declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON 
    {
    
        if(!tipo_atribuicao_ok($1, $4 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: tipo '%s' incompatível com '%s' na declaração de '%s'\n", yylineno, $4 -> tipo, $1, $2);
                
        inserirSimbolo($2, $1, escopo_atual);
        
        print_indent(nivel_atual);
        printf("%s %s = %s;\n", $1, $2, $4->codigo);
        
    }
    | tipo TOK_ID TOK_SCOLON 
    {
    
        inserirSimbolo($2, $1, escopo_atual);
        
        print_indent(nivel_atual);
        printf("%s %s;\n", $1, $2);
        
    };
    
/* Regra auxiliar para variáveis criadas dentro do cabeçalho do for */

declaracao_var_for:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON 
    {
    
        inserirSimbolo($2, $1, escopo_atual + 1);
        
        print_indent(nivel_atual);
        printf("for (%s %s = %s;", $1, $2, $4 -> codigo);
        
    };
    
/* Verifica se o tipo do retorno bate com o da função */

comando_return:
    TOK_RETURN exp TOK_SCOLON 
    {
    
        if(strlen(tipo_retorno_atual) > 0 && !tipo_atribuicao_ok(tipo_retorno_atual, $2 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: retorno do tipo '%s' incompatível com '%s'\n", yylineno, $2 -> tipo, tipo_retorno_atual);
                
        print_indent(nivel_atual);
        printf("return %s;\n", $2 -> codigo);
        
    };
    
/* Verifica se a variável foi declarada e se os tipos são compatíveis */

comando_atribuicao:
    TOK_ID TOK_ASSIGN exp TOK_SCOLON 
    {
    
        Simbolo *s = buscarSimbolo($1, escopo_atual);
        
        if(s == NULL) 
            fprintf(stderr, "Erro Semântico na linha %d: '%s' não foi declarada\n", yylineno, $1);
        
        else if(!tipo_atribuicao_ok(s -> tipo, $3 -> tipo)) 
            fprintf(stderr, "Erro Semântico na linha %d: tipo '%s' incompatível com '%s' na atribuição de '%s'\n", yylineno, $3 -> tipo, s -> tipo, $1);
        
        print_indent(nivel_atual);
        printf("%s = %s;\n", $1, $3 -> codigo);
        
    }
    | TOK_ID TOK_ADD_ASSIGN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("%s += %s;\n", $1, $3 -> codigo);
        
    }
    | TOK_ID TOK_SUB_ASSIGN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("%s -= %s;\n", $1, $3 -> codigo);
        
    }
    | TOK_ID TOK_MULT_ASSIGN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("%s *= %s;\n", $1, $3 -> codigo);
        
    }
    | TOK_ID TOK_DIV_ASSIGN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("%s /= %s;\n", $1, $3 -> codigo);
        
    }
    | TOK_ID TOK_MOD_ASSIGN exp TOK_SCOLON 
    {
    
        print_indent(nivel_atual);
        printf("%s %%= %s;\n", $1, $3 -> codigo);
        
    };
    
/* Tradução de estruturas condicionais */

comando_if:
    TOK_IF TOK_LPAREN exp TOK_RPAREN TOK_LBRACE 
    {
    
        print_indent(nivel_atual);
        printf("if (%s) {\n", $3 -> codigo);
        
        nivel_atual++;
        escopo_atual++;
        
    }
    lista_comandos TOK_RBRACE 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        print_indent(nivel_atual);
        printf("}\n");
        
    }
    | comando_if TOK_ELSE TOK_LBRACE 
    {
    
        print_indent(nivel_atual);
        printf("else {\n");
        
        nivel_atual++;
        escopo_atual++;
        
    }
    lista_comandos TOK_RBRACE 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        print_indent(nivel_atual);
        printf("}\n");
        
    };
    
/* Tradução do laço while */

comando_while:
    TOK_WHILE TOK_LPAREN exp TOK_RPAREN TOK_LBRACE 
    {
    
        print_indent(nivel_atual);
        printf("while (%s) {\n", $3 -> codigo);
        
        nivel_atual++;
        escopo_atual++;
        
    }
    lista_comandos TOK_RBRACE 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        print_indent(nivel_atual);
        printf("}\n");
        
    };
    
/* Tradução do laço do while */

comando_do_while:
    TOK_DO TOK_LBRACE 
    {
    
        print_indent(nivel_atual);
        printf("do {\n");
        nivel_atual++;
        escopo_atual++;
        
    }
    lista_comandos TOK_RBRACE TOK_WHILE TOK_LPAREN exp TOK_RPAREN TOK_SCOLON 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        print_indent(nivel_atual);
        printf("} while (%s);\n", $8 -> codigo);
        
    };
    
/* Tradução do laço for */

comando_for:
    TOK_FOR TOK_LPAREN declaracao_var_for exp TOK_SCOLON exp TOK_RPAREN TOK_LBRACE 
    {
    
        printf(" %s; %s) {\n", $4 -> codigo, $6 -> codigo);
        
        nivel_atual++;
        escopo_atual++;
        
    }
    lista_comandos TOK_RBRACE 
    {
    
        removerEscopo(escopo_atual);
        
        escopo_atual--;
        nivel_atual--;
        
        print_indent(nivel_atual);
        printf("}\n");
        
    };
    
/* Expressões — montam o código C e inferem o tipo */

exp:
    TOK_INT_LIT 
    {
    
        char buf[50];
        
        sprintf(buf, "%d", $1);
        
        $$ = novaExp(buf, "int");
        
    }
    | TOK_FLOAT_LIT 
    {

        char buf[50];
        
        sprintf(buf, "%g", $1);
        
        $$ = novaExp(buf, "float");
        
    }
    | TOK_CHAR_LIT 
    {
    
        char buf[50];
        
        sprintf(buf, "'%c'", $1);
        
        $$ = novaExp(buf, "char");
        
    }
    | TOK_TRUE 
    {
    
        $$ = novaExp("1", "bool");
        
    }
    | TOK_FALSE 
    {
    
        $$ = novaExp("0", "bool");
        
    }
    | TOK_NULLPTR 
    {
    
        $$ = novaExp("NULL", "void*");
        
    }
    | TOK_ID 
    {
    
        Simbolo *s = buscarSimbolo($1, escopo_atual);
        if (s == NULL)
            fprintf(stderr, "Erro Semântico na linha %d: '%s' não foi declarada\n", yylineno, $1);
            
        $$ = novaExp($1, s ? s->tipo : "desconhecido");
        
    }
    | TOK_STRING_LIT 
    {
    
        $$ = novaExp($1, "string");
        
    }
    | exp TOK_PLUS exp 
    {
    
        if (!tipo_numerico($1 -> tipo) || !tipo_numerico($3 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: operador '+' não suportado entre '%s' e '%s'\n", yylineno, $1 -> tipo, $3 -> tipo);
                
        char buf[512];
        
        sprintf(buf, "%s + %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, tipo_resultado_op($1 -> tipo, $3 -> tipo));
        
    }
    | exp TOK_MINUS exp 
    {
    
        if (!tipo_numerico($1 -> tipo) || !tipo_numerico($3 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: operador '-' não suportado entre '%s' e '%s'\n", yylineno, $1 -> tipo, $3 -> tipo);
                
        char buf[512];
        
        sprintf(buf, "%s - %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, tipo_resultado_op($1 -> tipo, $3 -> tipo));
        
    }
    | exp TOK_MULT exp 
    {
    
        if (!tipo_numerico($1 -> tipo) || !tipo_numerico($3 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: operador '*' não suportado entre '%s' e '%s'\n", yylineno, $1 -> tipo, $3 -> tipo);
                
        char buf[512];
        
        sprintf(buf, "%s * %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, tipo_resultado_op($1 -> tipo, $3 -> tipo));
        
    }
    | exp TOK_DIV exp 
    {
    
        if (!tipo_numerico($1 -> tipo) || !tipo_numerico($3 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: operador '/' não suportado entre '%s' e '%s'\n", yylineno, $1 -> tipo, $3 -> tipo);
                
        char buf[512];
        
        sprintf(buf, "%s / %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, tipo_resultado_op($1 -> tipo, $3 -> tipo));
        
    }
    | exp TOK_MOD exp 
    {
    
        if (!tipo_numerico($1 -> tipo) || !tipo_numerico($3 -> tipo))
            fprintf(stderr, "Erro Semântico na linha %d: operador '%%' não suportado entre '%s' e '%s'\n", yylineno, $1 -> tipo, $3 -> tipo);
                
        char buf[512];
        
        sprintf(buf, "%s %% %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "int");
        
    }
    | exp TOK_EQ exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s == %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_NEQ exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s != %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_LT exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s < %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_GT exp 
    {

        char buf[512];
        
        sprintf(buf, "%s > %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_LE exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s <= %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_GE exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s >= %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_LOGIC_AND exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s && %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | exp TOK_LOGIC_OR exp 
    {
    
        char buf[512];
        
        sprintf(buf, "%s || %s", $1 -> codigo, $3 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | TOK_LOGIC_NOT exp 
    {
    
        char buf[512];
        
        sprintf(buf, "!%s", $2 -> codigo);
        
        $$ = novaExp(buf, "bool");
        
    }
    | TOK_LPAREN exp TOK_RPAREN 
    {

        char buf[512];
        
        sprintf(buf, "(%s)", $2 -> codigo);
        
        $$ = novaExp(buf, $2 -> tipo);
        
    }
    | TOK_SIZEOF TOK_LPAREN tipo TOK_RPAREN 
    {
    
        char buf[256];
        
        sprintf(buf, "sizeof(%s)", $3);
        
        $$ = novaExp(buf, "int");
        
    }
    | TOK_SIZEOF TOK_LPAREN exp TOK_RPAREN 
    {
    
        char buf[256];
        
        sprintf(buf, "sizeof(%s)", $3 -> codigo);
        
        $$ = novaExp(buf, "int");
        
    };
    
%%

/* FUNCOES DE SUPORTE */

void yyerror(const char *s) 
{

    fprintf(stderr, "Erro de Sintaxe na linha %d: %s (perto de '%s')\n", yylineno, s, yytext);
    
}

int main() 
{

    printf("#include <stdio.h>\n");
    printf("#include <stdbool.h>\n\n");
    
    if (yyparse() == 0)
        fprintf(stderr, "Transpilação concluída com sucesso!\n");
    
    imprimirTabela();
    return 0;
    
}