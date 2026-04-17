---
title: 4 - Operadores e Pontuação
parent: Mapeamento de Tokens
nav_order: 4
---

## 4 - Operadores e Pontuação

Esta seção mapeia todos os símbolos que realizam operações matemáticas, lógicas e de fluxo, além dos delimitadores estruturais do código.

### 4.1 - Operadores Aritméticos e de Atribuição

| Símbolo | Token | Descrição |
| :--- | :--- | :---: |
| + | TOK_PLUS | Operação de adição |
| - | TOK_MINUS | Operação de subtração |
| * | TOK_MINUS | Operação de multiplicação |
| / | TOK_DIV | Operação de divisão |
| % | TOK_MOD | Operação modular |
| = | TOK_ASSIGN | Atribuição simples de valor |
| += | TOK_ADD_ASSIGN | Adição seguida de atribuição |
| -= | TOK_SUB_ASSIGN | Subtração seguida de atribuição |
| *= | TOK_MULT_ASSIGN | Multiplicação seguida de atribuição |
| /= | TOK_DIV_ASSIGN | Divisão seguida de atribuição |
| %= | TOK_MOD_ASSIGN | Módulo seguido de atribuição |

### 4.2 - Operadores Relacionais e Lógicos

| Símbolo | Token | Descrição |
| :--- | :--- | :---: |
| == | TOK_EQ | TOK_LOGIC_NOT |
| != | TOK_NEQ | Comparação de diferença |
| < | TOK_LT | Menor que |
| > | TOK_GT | Maior que |
| <= | TOK_LE | Menor ou igual a |
| >= | TOK_GE | Maior ou igual a |
| && | TOK_LOGIC_AND | Operação lógica "E" |
| \\ (Reto) | TOK_LOGIC_AND | Operação lógica "OU" |
| ! | TOK_LOGIC_NOT | Operação lógica de negação |

### 4.3 - Específicos C++ (Stream e Escopo)

| Símbolo | Token | Descrição |
| :--- | :--- | :---: |
| << | TOK_OUT | Operador de inserção em stream |
| >> | TOK_IN | Operador de extração de stream |
| :: | TOK_SCOPE | Operador de resolução de escopo |

### 4.4 - Pontuação e Delimitadores

| Símbolo | Token | Descrição |
| :--- | :--- | :---: |
| ; | TOK_SCOLON | Terminador de instrução |
| . | TOK_COMMA | Separador de elementos |
| ( | TOK_LPAREN | Início de expressão ou lista de argumentos |
| ) | TOK_RPAREN | Fim de expressão ou lista de argumentos |
| { | TOK_LBRACE | Início de bloco de código |
| } | TOK_RBRACE | Fim de bloco de código |
| [ | TOK_LBRACKET | Início de índice de array |
| ] | TOK_LBRACKET | Fim de índice de array |