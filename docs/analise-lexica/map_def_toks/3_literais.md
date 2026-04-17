---
title: 3 - Literais
parent: Mapeamento de Tokens
nav_order: 3
---

# 3 - Literais

Os literais são valores fixos escritos diretamente no código-fonte que representam dados constantes. Eles são classificados de acordo com o tipo de dado que representam.

| Tipo de Literal | Token | Exemplos | Descrição |
| :--- | :--- | :--- | :---: |
| **Inteiro** | TOK_INT_LIT | 10, 42, 0 | Sequências de dígitos numéricos sem ponto decimal. |
| **Ponto Flutuante** | TOK_FLOAT_LIT | 2.34, 0.4, 2.0 | Números que contêm uma parte fracionária separada por ponto. |
| **String** | TOK_STRING_LIT | "Hellow world", "oi" | Sequências de caracteres delimitadas por aspas duplas. |
| **Caractere** | TOK_CHAR_LIT | 'z', '\n', '\0' | Um único caractere ou sequência de escape entre aspas simples. |

## 3.2 - Regras de Reconhecimento (Regex)

Para o funcionamento no Flex, utilizaremos os seguintes padrões:

- **Inteiros:** [0-9]+

- **Floats:** [0-9]*\.[0-9]+

- **Strings:** "([^"\n]*)" (Cadeias entre aspas, sem permitir quebras de linha diretas)

- **Caracteres:** '(\\.|[^\\'])' (Permite caracteres normais ou sequências de escape como \n ou \t)

## 3.3 - Armazenamento de Valores (yylval)
Como esses tokens possuem valor semântico, o analisador léxico deve preencher a união yylval antes de retornar o token:

- Para **TOK_INT_LIT**: yylval.ival = atoi(yytext);

- Para **TOK_FLOAT_LIT**: yylval.fval = atof(yytext);

- Para **TOK_STRING_LIT**: yylval.sval = strdup(yytext);

- Para **TOK_CHAR_LIT:** yylval.cval = yytext[1];
