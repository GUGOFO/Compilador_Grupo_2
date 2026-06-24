---
title: Escopo Operational Atualizado
nav_order: 6
---

# Tabela de Escopo Operacional do Compilador

A tabela abaixo resume o escopo operacional real e atualizado do compilador, dividindo as construções da linguagem C++ entre o que é nativamente suportado pelo pipeline após as últimas implementações e o que ainda gerará falhas ou erros.

| Categoria | Suportado | Não Suportado / Quebra |
| :--- | :--- | :--- |
| **Tipos de Dados** | `int`, `float`, `double`, `bool`, `char`, `long`, `short`, `void`. | Criar classes (`class`), estruturas (`struct`) ou usar tipos complexos da biblioteca padrão (ex: `std::string`). |
| **Declaração de Variáveis** | Uma variável por linha, com ou sem inicialização (ex: `int a = 0;` ou `int b;`). | **Declarações múltiplas** na mesma linha separadas por vírgula (ex: `int a, b;` gera **Erro Sintático**). |
| **Estruturas de Controle** | **Suporte Total:** `if`, `else`, `while`, `do-while`, `for`, `break`, `continue`, `return`, além de suporte completo a blocos **`switch`**, **`case`** e **`default`**. | Estruturas de escolha baseadas em tipos não integris (como switch de strings). |
| **Blocos e Chaves `{}`** | Delimitar os corpos de todas as estruturas (`if`, `while`, etc.) obrigatoriamente com chaves `{ }`, mesmo contendo apenas uma instrução. | Omitir as chaves `{ }` em estruturas de linha única (Gera **Erro Sintático**). |
| **Laço `for`** | **Suporte Total:** Aceita a inicialização de variáveis, expressões condicionais e atualização automática por meio de operadores pós-fixados (`i++`, `i--`). | Expressões de atualização vazias ou omissão de delimitadores internos. |
| **Funções (Declaração e Uso)** | **Suporte Total:** Declaração de funções **com ou sem parâmetros** (ex: `int calcularDobro(int numero)`) e **chamadas de função estruturadas** com repasse de argumentos. | Funções com assinaturas complexas (ponteiros de funções, sobrecarga) ou checagem estrita de aridade de parâmetros devido à simplicidade da tabela de símbolos. |
| **Nomes de Identificadores** | Nomes com até **35 caracteres**. Suporta *shadowing* (sombreamento) em escopos diferentes protegendo variáveis superiores. | Nomes com **36 caracteres ou mais** (Gera **Estouro de Buffer / Segmentation Fault** na struct de tamanho fixo). Redeclarar a mesma variável no mesmo bloco. |
| **I/O (Entrada e Saída)** | Um único operando por instrução: `std::cout << "texto"`, `std::cout << numero`, `std::cin >> variavel`. Floats são impressos com formato estável de ponto flutuante. | **Encadeamento de operadores** (ex: `cout << a << b;` ou `cin >> a >> b;` geram **Erro Sintático**). Usar `std::endl` (Gera **Erro Sintático**). |
| **Operadores Matemáticos** | Expressões binárias (`+`, `-`, `*`, `/`, `%`), suporte unário (sinais negativos) e **suporte nativo a operadores pós-fixados de incremento (`++`) e decremento (`--`)**. | Operadores pré-fixados (ex: `++i`, `--j`) ou operadores bitwise complexos. |
| **Operadores Lógicos** | Símbolos clássicos (`&&`, `BARRA BARRA`, `!`) e operadores textuais equivalentes (`and`, `or`, `not`) mapeados de forma harmonizada. | Expressões com profundidade de recursão extrema (risco de estourar a pilha interna do Bison). |
| **Literais Numéricos** | Inteiros até cerca de 2.14 bilhões (10 dígitos). Ponto flutuante com suporte a precisão simples e dupla impresso via `%f`. | Inteiros gigantes (sofrem **Overflow** silencioso via `atoi`). Números flutuantes gigantes são truncados ou viram `inf`. |
| **Strings e Caracteres** | Strings com escapes (ex: `"Linha 1\n"`) e caracteres únicos (`'a'`, `'\n'`) resolvidos por sequências de escape no léxico. | Quebras de linha físicas literais dentro das aspas duplas (Gera **Erro Léxico**). Caracteres múltiplos dentro de aspas simples (ex: `'abc'`). |
| **Arrays e Vetores** | **Suporte Total:** Declaração de vetores unidimensionais (ex: `int meuVetor[5];`), **atribuição indexada** (`meuVetor[2] = 88;`) e **acesso de elementos** com cálculo de offset no TAC. | Matrizes multidimensionais (ex: `int m[2][2]`) ou manipulação direta de ponteiros aritméticos de baixo nível (`*ptr`, `&var`). |
| **Operador `sizeof()`** | Reconhecimento léxico e sintático da estrutura do operador para tipos e expressões (ex: `sizeof(int)` ou `sizeof(a)`). | O operador repassa a estrutura do tipo ou identificador diretamente para o nó correspondente na árvore sintática. |
| **Comentários** | Comentários de linha única (`//`) e de múltiplas linhas (`/* ... */`). São descartados no léxico e não geram impactos no parser. | Aninhar blocos de comentários de múltiplas linhas (ex: `/* A /* B */ C */`) quebra a lógica de captura do scanner. |
| **Bibliotecas e Pré-processador** | Injeção automática das diretivas `#include <stdio.h>` e `#include <stdbool.h>` no topo do arquivo objeto gerado. | Escrever manualmente diretivas de pré-processador (como `#include <iostream>`) no código fonte C++ (Gera **Erro Léxico** devido ao caractere `#`). |