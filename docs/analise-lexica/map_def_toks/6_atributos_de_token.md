---
title: 6 - Atributos e yylval
parent: Mapeamento de Tokens
nav_order: 6
---

# Gestão de Atributos e Valor do Token

Na análise léxica, identificar um token muitas vezes não é suficiente. Para tokens como identificadores e literais, o compilador precisa saber o valor real que eles carregam. Essa informação extra é chamada de **Atributo Semântico**.

## 6.1 - O que é o yylval?

O yylval é uma variável global utilizada para passar o valor semântico de um token do Analisador Léxico (Flex) para o Analisador Sintático (Bison). 

Por padrão, o yylval armazena apenas inteiros, mas em compiladores reais ele é definido como uma **Union** em C, permitindo que ele transporte diferentes tipos de dados simultaneamente.

## 6.2 - Estrutura da Union (Exemplo)

No analisador sintático, definimos os tipos de dados que o yylval pode carregar:

```c
%union {
    int ival;      // Para números inteiros
    float fval;    // Para números decimais
    char cval;     // Para caracteres únicos
    char *sval;    // Para nomes de variáveis e strings
}
```

## 6.3 - Mapeamento de Atribuições

Sempre que o Flex reconhece um token que possui valor, ele deve preencher o campo correspondente do yylval antes de executar o return:

| Token | Campo de yylval | Exemplo de Atribuição no Flex |
| :--- | :--- | :---: |
| TOK_INT_LIT | ival | yylval.ival = atoi(yytext); |
| TOK_FLOAT_LIT | fval | yylval.fval = atof(yytext); |
| TOK_CHAR_LIT | cval | yylval.cval = yytext[1]; |
| TOK_ID | cval | yylval.sval = strdup(yytext); |
| TOK_STRING_LIT | sval | yylval.sval = strdup(yytext); |

## 6.4 - Importância da Função strdup()
Para tokens que carregam texto (como nomes de variáveis ou frases), usamos a função strdup(yytext). Isso é necessário porque o Flex reutiliza o mesmo espaço de memória (yytext) para cada novo token encontrado. Se não duplicarmos a string, o valor do primeiro identificador será sobrescrito pelo próximo assim que ele for lido.

## 6.5 - Tokens sem Atributos
Tokens como palavras reservadas (TOK_IF, TOK_WHILE) e operadores (TOK_PLUS, TOK_SCOLON) geralmente não precisam preencher o yylval. Para o compilador, basta saber que o símbolo existe; o símbolo em si (ex: o caractere ;) não carrega um "valor" que precise ser processado matematicamente.