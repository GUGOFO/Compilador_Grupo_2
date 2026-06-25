---
title: 2 - Estrutura da Gramática
parent: Análise Sintática
nav_order: 2
---

# Estrutura da Gramática e Regras Sintáticas

Esta seção documenta como a gramática da linguagem (o subconjunto do C++ definido para a disciplina) foi estruturada no gerador de analisadores **GNU Bison**. O analisador sintático recebe o fluxo de tokens do Flex e valida se a ordem e a construção das instruções estão corretas.

## 2.1 - Abordagem de Análise (Parsing)

O Bison utiliza uma análise **LALR(1)**, que lê o código da esquerda para a direita e constrói a árvore de derivação de baixo para cima (*Bottom-Up*). Ele analisa um token adiante (*lookahead*) para decidir entre empilhar um token na pilha (*shift*) ou reduzir um conjunto de tokens para um símbolo não-terminal (*reduce*).

## 2.2 - Escopo Operacional da Sintaxe

A gramática foi mapeada e expandida para suportar as principais estruturas condicionais, de repetição e de seleção múltipla. A tabela abaixo detalha o comportamento do parser para as construções estruturais:

| Categoria | Construção Suportada | Restrição / Provoca Erro Sintático |
| :--- | :--- | :--- |
| **Declaração de Variáveis** | Uma variável por linha, com ou sem inicialização (ex: `int a = 0;` ou `int b;`). | **Declarações múltiplas** na mesma linha separadas por vírgula (ex: `int a, b;`) geram erro. |
| **Estruturas de Controle** | `if`, `else`, `while`, `do-while`, `for` e a seleção múltipla **`switch`**, **`case`** e **`default`**. | Uso de blocos ou comandos desalinhados com as regras de derivação. |
| **Blocos e Chaves `{}`** | O corpo de qualquer estrutura condicional, escolha ou laço deve ser **obrigatoriamente** delimitado por chaves `{ }`. | Omitir chaves em estruturas de instrução única (ex: `if (x) return 0;` sem `{}`) gera erro. |

## 2.3 - Símbolos Não-Terminais da Gramática

A linguagem é processada a partir de regras hierárquicas compostas por símbolos não-terminais dentro de `parser.y`:

* **`programa`**: O ponto de entrada da gramática, que representa a totalidade do arquivo de código.
* **`lista_declaracoes`**: Uma sequência de funções ou declarações de variáveis globais.
* **`declaracao_funcao`**: Define a assinatura (tipo de retorno, nome, parâmetros) e o corpo de uma função.
* **`bloco_comandos`**: Conjunto de instruções encapsuladas por `{}`.
* **`comando`**: Instruções isoladas de atribuição, retorno, laços, condicionais ou blocos de seleção (`switch`).
* **`exp`**: Expressões matemáticas, lógicas ou literais.

## 2.4 - Precedência de Operadores

Para evitar ambiguidades nas expressões sem a necessidade de parênteses excessivos, as regras de precedência foram explicitamente declaradas de forma ascendente (da menor para a maior precedência):

1. **Atribuições** (`=`, `+=`, `-=`, etc.)
2. **Operadores Lógicos** (`||` / `&&`)
3. **Comparações Relacionais** (`==`, `!=`, `<`, `>`, `<=`, `>=`)
4. **Operadores Aditivos** (`+`, `-`)
5. **Operadores Multiplicativos** (`*`, `/`, `%`)
6. **Operador Unário** (Negação lógica `!`)