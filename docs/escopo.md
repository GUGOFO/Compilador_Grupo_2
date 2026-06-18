---
title: Escopo
nav_order: 6
---

# Tabela de Escopo

A tabela abaixo resume o escopo operacional completo do compilador, dividindo as construções da linguagem C++ entre o que é nativamente suportado pelo pipeline e o que gerará falhas críticas, erros de sintaxe ou estouros de memória.

| Categoria | Suportado | Não Suportado / Quebra |
| :--- | :--- | :--- |
| **Tipos de Dados** | `int`, `float`, `double`, `bool`, `char`, `long`, `short`, `void`. | Criar classes (`class`), estruturas (`struct`) ou usar tipos da biblioteca padrão (ex: `std::string`). |
| **Declaração de Variáveis** | Uma variável por linha, com ou sem inicialização (ex: `int a = 0;` ou `int b;`). | **Declarações múltiplas** na mesma linha separadas por vírgula (ex: `int a, b;` gera **Erro Sintático**). |
| **Estruturas de Controle** | `if`, `else`, `while`, `do-while`, `for`, `break`, `continue`, `return`. | Usar `switch`, `case` e `default` (Gera **Erro Sintático**). |
| **Blocos e Chaves `{}`** | Delimitar os corpos de todas as estruturas (`if`, `while`, etc.) obrigatoriamente com chaves `{ }`, mesmo contendo apenas uma instrução. | Omitir as chaves `{ }` em estruturas de linha única (Gera **Erro Sintático**). |
| **Laço `for`** | **Suporte Total:** Aceita tanto a declaração interna de variáveis quanto atribuições simples de variáveis preexistentes (ex: `for(int i = 0; ...)` ou `for(i = 0; ...)`). | Não há restrição quanto à inicialização após a correção gramatical e o *cast* dinâmico na AST. |
| **Funções (Declaração e Uso)** | Declaração de funções sem parâmetros e com bloco de escopo (ex: `int main() { ... }`). | **Funções com parâmetros** (ex: `void calc(int x)`) e **Chamadas de função** no meio do código (Ambos geram **Erro Sintático**). Apenas a `main` executa. |
| **Nomes de Identificadores** | Nomes com até **35 caracteres**. Suporta *shadowing* (sombreamento) em escopos diferentes. | Nomes com **36 caracteres ou mais** (Gera **Estouro de Buffer / Segmentation Fault** na struct da Tabela de Símbolos). Redeclarar a mesma variável no mesmo bloco. |
| **I/O (Entrada e Saída)** | Um único operando por instrução: `std::cout << "texto"`, `std::cout << numero`, `std::cin >> variavel`. | **Encadeamento de operadores** (ex: `cout << a << b;` ou `cin >> a >> b;` geram **Erro Sintático**). Usar `std::endl` (Gera **Erro Sintático**). Imprimir variáveis não numéricas (gera máscara `%g` inválida no C). |
| **Operadores Matemáticos** | Expressões binárias (`+`, `-`, `*`, `/`, `%`). **Suporte unário:** Sinais negativos diretos (ex: `int a = -5;`) agora funcionam perfeitamente. | Operadores de incremento ou decremento (ex: `i++` ou `--j` geram **Erro Sintático** devido à falta de tokens específicos). |
| **Operadores Lógicos** | Símbolos clássicos (`&&`, `BARRA BARRA`, `!`) e operadores textuais equivalentes (`and`, `or`, `not`). | Expressões com profundidade de recursão extrema (risco de estourar a pilha interna do Bison). |
| **Literais Numéricos** | Inteiros até cerca de 2.14 bilhões (10 dígitos). Ponto flutuante com suporte a precisão simples (7 casas decimais). | Inteiros gigantes (ex: 20 dígitos sofrem **Overflow** silencioso via `atoi`). Números flutuantes gigantes são truncados ou viram `inf`. |
| **Strings e Caracteres** | Strings com escapes (ex: `"Linha 1\nLinha 2"`) e caracteres únicos (`'a'`, `'\n'`). | Quebras de linha físicas literais dentro das aspas duplas (Gera **Erro Léxico**). Caracteres múltiplos dentro de aspas simples (ex: `'abc'`). |
| **Arrays e Ponteiros** | Reconhecimento léxico isolado dos símbolos `[`, `]`, `*`, `&`. | Declaração de vetores (`int a[10]`) ou manipulação de ponteiros (`*ptr`, `&var`) (Gera **Erro Sintático** por falta de regras no parser). |
| **Operador `sizeof()`** | Reconhecimento léxico e sintático da estrutura do operador para tipos e expressões (ex: `sizeof(int)` ou `sizeof(a)`). | **Bug de Geração de Código:** A AST omite a palavra `sizeof`, gerando apenas o tipo ou a expressão no código C final, o que invalida a compilação no GCC. |
| **Comentários** | Comentários de linha única (`//`) e de múltiplas linhas (`/* ... */`). São descartados no léxico e não geram impactos. | Aninhar blocos de comentários de múltiplas linhas (ex: `/* A /* B */ C */`) quebra a lógica de captura do scanner. |
| **Bibliotecas e Pré-processador** | Injeção automática das diretivas `#include <stdio.h>` e `#include <stdbool.h>` no topo do arquivo objeto gerado. Saída de diagnóstico redirecionada para `stderr`. | Escrever manualmente diretivas de pré-processador (como `#include <iostream>` ou `#define`) no código fonte (Gera **Erro Léxico** devido ao caractere `#`). |