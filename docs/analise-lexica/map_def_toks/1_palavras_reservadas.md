---
title: 1 - Palavras Reservadas
parent: Mapeamento de Tokens
nav_order: 1
---

# 1 - Palavras Reservadas
A seguir, estão todas as palavras reservadas que estarão no escopo do nosso compiladores, junto com a explicação doque cada uma faz

| Palavras Reservadas | Token | Descrição |
| :--- | :--- | :---: |
| and | TOK_AND | Sinônimo para o operador lógico de conjunção && |
| bool | TOK_BOOL | Tipo de dado que armazena valores lógicos (verdadeiro ou falso) |
| break | TOK_BREAK | Interrompe a execução do laço ou bloco switch atual |
| case | TOK_CASE | Define uma ramificação específica de execução dentro de um switch |
| char | TOK_CHAR | Tipo de dado fundamental que armazena um único caractere |
| cin | TOK_CIN | **(Token Especial)** Objeto utilizado para leitura de dados via entrada padrão |
| continue | TOK_CONTINUE | Salta o restante do corpo do laço e vai direto para a próxima iteração |
| cout | TOK_COUT | **(Token Especial)** Objeto utilizado para impressão de dados na saída padrão.iteração |
| default | TOK_DEFAULT | Define o bloco executado caso nenhum case seja correspondido.  |
| do | TOK_DO | Inicia uma estrutura de repetição que executa o bloco ao menos uma vez.  |
| double | TOK_DOUBLE | Tipo de dado para números de ponto flutuante com precisão dupla.  |
| else | TOK_ELSE | Define o bloco executado quando a condição do if é falsa. |
| false | TOK_FALSE | Literal booleano que representa o valor lógico falso.  |
| float | TOK_FLOAT | Tipo de dado para números de ponto flutuante com precisão simples.  |
| for | TOK_FOR | Estrutura de repetição que integra inicialização, condição e incremento. |
| if | TOK_IF | Estrutura de controle que executa um bloco se uma condição for verdadeira.  |
| int | TOK_INT | Tipo de dado básico para armazenamento de números inteiros.  |
| long | TOK_LONG | Modificador que aumenta a capacidade de armazenamento de inteiros ou decimais. |
| not | TOK_NOT | Sinônimo para o operador lógico de negação !. |
| nullptr | TOK_NULLPTR | Representa de forma segura um valor de ponteiro nulo. |
| or | TOK_OR | Sinônimo para o operador lógico de disjunção ` |
| return | TOK_RETURN | Finaliza a execução de uma função e retorna um valor. |
| short | TOK_SHORT | Modificador de tipo que reduz o espaço de memória ocupado por um inteiro. |
| sizeof | TOK_SIZEOF | Operador que retorna o tamanho em bytes de um tipo ou objeto. |
| switch | TOK_SWITCH | Estrutura de seleção múltipla baseada no valor de uma expressão integral. |
| true | TOK_TRUE | Literal booleano que representa o valor lógico verdadeiro. |
| void | TOK_VOID | Indica que uma função não retorna valor ou define um ponteiro genérico. |
| while | TOK_WHILE | Estrutura de repetição que executa um bloco enquanto a condição for verdadeira. |

## 1.1 - Tipos de Dados

Palavras que definem a natureza da informação armazenada em uma variável

- **bool:** Representa valores lógicos (verdadeiro ou falso).

- **char:** Armazena um único caractere.

- **double:** Ponto flutuante de precisão dupla.

- **float:** Ponto flutuante de precisão simples.

- **int:** Números inteiros.

- **long:** Modificador para aumentar a precisão de inteiros ou decimais.

- **short:** Modificador para reduzir o espaço de memória de inteiros.

- **void:** Indica ausência de tipo ou retorno de função.

## 1.2 -  Fluxo de Controle
Comandos que determinam a ordem de execução das instruções do programa.

- **if / else:** Estruturas de decisão condicional.

- **switch / case / default:** Estruturas de seleção múltipla.

- **for / while / do:** Estruturas de repetição (laços).

- **break:** Interrompe o laço ou switch atual.

- **continue:** Pula para a próxima iteração do laço.

- **return:** Finaliza uma função e retorna um valor.

## 1.3 - Específicos C++ e Tokens Especiais
Elementos existentes no C++ que não existem no C

- **cin:** Token especial para entrada de dados via stream.

- **cout:** Token especial para saída de dados via stream.

- **nullptr:** Literal que representa um ponteiro nulo de forma segura.

## 1.4 - Aliases Lógicos e Operadores em Palavra
Substitutos textuais para operadores simbólicos e operadores de sistema.

- **and:** Alias para o operador lógico &&.

- **or:** Alias para o operador lógico (Duas barras retas).

- **not:** Alias para o operador lógico !.

- **sizeof:** Operador que retorna o tamanho (em bytes) de um tipo ou objeto.

## 1.5 - Literais Booleanos
Valores constantes para o tipo bool.

- **true:** Representa o valor verdadeiro.

- **false:** Representa o valor falso.