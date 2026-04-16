---
title: 1 - Mapeamento e Definição dos Tokens
parent: Análise Léxica
nav_order: 2
---

# Mapeamento e Definição dos Tokens

A seguir, estão todas as palavras reservadas que estarão no escopo do nosso compiladores, junto com a explicação doque cada uma faz

| Palavras Reservadas | Descrição |
| :--- | :---: |
| and | Sinônimo para o operador lógico de conjunção && |
| bool | Tipo de dado que armazena valores lógicos (verdadeiro ou falso) |
| break | Interrompe a execução do laço ou bloco switch atual |
| case | Define uma ramificação específica de execução dentro de um switch |
| char | Tipo de dado fundamental que armazena um único caractere |
| cin | **(Token Especial)** Objeto utilizado para leitura de dados via entrada padrão |
| const | Modificador que impede a alteração do valor de uma variável após inicializada |
| continue | Salta o restante do corpo do laço e vai direto para a próxima iteração |
| cout | **(Token Especial)** Objeto utilizado para impressão de dados na saída padrão.iteração |
| default | Define o bloco executado caso nenhum case seja correspondido.  |
| do | Inicia uma estrutura de repetição que executa o bloco ao menos uma vez.  |
| double | Tipo de dado para números de ponto flutuante com precisão dupla.  |
| else | Define o bloco executado quando a condição do if é falsa. |
| export | Utilizado para tornar declarações de módulos visíveis em outros arquivos. |
| extern | Indica que uma variável ou função está declarada em outro arquivo. |
| false | Literal booleano que representa o valor lógico falso.  |
| float | Tipo de dado para números de ponto flutuante com precisão simples.  |
| for | Estrutura de repetição que integra inicialização, condição e incremento. |
| if | Estrutura de controle que executa um bloco se uma condição for verdadeira.  |
| int | Tipo de dado básico para armazenamento de números inteiros.  |
| long | Modificador que aumenta a capacidade de armazenamento de inteiros ou decimais. |
| namespace | Agrupa identificadores (variáveis, funções) em um escopo nomeado específico. |
| not | Sinônimo para o operador lógico de negação !. |
| nullptr | Representa de forma segura um valor de ponteiro nulo. |
| or | Sinônimo para o operador lógico de disjunção ` |
| return | Finaliza a execução de uma função e retorna um valor. |
| short | Modificador de tipo que reduz o espaço de memória ocupado por um inteiro. |
| sizeof | Operador que retorna o tamanho em bytes de um tipo ou objeto. |
| static | Define permanência de valor entre chamadas ou limita o escopo ao arquivo. |
| switch | Estrutura de seleção múltipla baseada no valor de uma expressão integral. |
| true | Literal booleano que representa o valor lógico verdadeiro. |
| unsigned | Modificador para tipos inteiros que permite apenas valores não negativos. |
| using | Importa membros de um namespace ou define apelidos para tipos |
| void | Indica que uma função não retorna valor ou define um ponteiro genérico. |
| while | Estrutura de repetição que executa um bloco enquanto a condição for verdadeira. |

## 1 - Tipos de Dados

Palavras que definem a natureza da informação armazenada em uma variável

- **bool:** Representa valores lógicos (verdadeiro ou falso).

- **char:** Armazena um único caractere.

- **double:** Ponto flutuante de precisão dupla.

- **float:** Ponto flutuante de precisão simples.

- **int:** Números inteiros.

- **long:** Modificador para aumentar a precisão de inteiros ou decimais.

- **short:** Modificador para reduzir o espaço de memória de inteiros.

- **void:** Indica ausência de tipo ou retorno de função.

## 2 -  Fluxo de Controle
Comandos que determinam a ordem de execução das instruções do programa.

- **if / else:** Estruturas de decisão condicional.

- **switch / case / default:** Estruturas de seleção múltipla.

- **for / while / do:** Estruturas de repetição (laços).

- **break:** Interrompe o laço ou switch atual.

- **continue:** Pula para a próxima iteração do laço.

- **return:** Finaliza uma função e retorna um valor.

## 3 - Específicos C++ e Tokens Especiais
Elementos existentes no C++ que não existem no C

- **cin:** Token especial para entrada de dados via stream.

- **cout:** Token especial para saída de dados via stream.

- **namespace:** Define um escopo nomeado para identificadores.

- **using:** Utilizado para importar namespaces (como using namespace std).

- **nullptr:** Literal que representa um ponteiro nulo de forma segura.

## 4 - Modificadores e Qualificadores
Palavras que alteram o comportamento ou a visibilidade de variáveis e funções.

- **const:** Define que o valor da variável é imutável.

- **static:** Define permanência de valor ou limita o escopo ao arquivo.

- **unsigned:** Define que um tipo inteiro aceitará apenas valores positivos.

- **extern:** Indica que a definição está em outro arquivo/módulo.

- **export:** Usado para exportar declarações em sistemas de módulos.

## 5 - Aliases Lógicos e Operadores em Palavra
Substitutos textuais para operadores simbólicos e operadores de sistema.

- **and:** Alias para o operador lógico &&.

- **or:** Alias para o operador lógico ||.

- **not:** Alias para o operador lógico !.

- **sizeof:** Operador que retorna o tamanho (em bytes) de um tipo ou objeto.

## 6 - Literais Booleanos
Valores constantes para o tipo bool.

- **true:** Representa o valor verdadeiro.

- **false:** Representa o valor falso.