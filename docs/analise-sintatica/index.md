---
title: Análise Léxica
nav_order: 2
has_children: true
---

# Análise Léxica

A análise léxica é a fase inicial do front-end de um compilador, atuando como a primeira linha de processamento do código-fonte. Sua principal responsabilidade é ler o fluxo de caracteres textuais do arquivo de entrada (como o nosso `exemplo_entrada.c++`) e agrupá-los em unidades sintáticas lógicas significativas chamadas **Tokens**.

Enquanto o analisador sintático (Bison) se preocupa com a ordem e a estrutura gramatical das frases, o analisador léxico (Flex) opera isoladamente no nível das palavras, descartando elementos irrelevantes para a tradução.

## Atividades Fundamentais do Nosso Scanner

No escopo do nosso transpilador, o analisador léxico executa as seguintes tarefas automatizadas:
* **Tokenização:** Identificação e classificação de palavras reservadas, literais (numéricos e textuais), identificadores e operadores compostos.
* **Filtragem de Ruído:** Eliminação de caracteres de espaço em branco, tabulações (`\t`), quebras de linha (`\n`) e retornos de carro (`\r`) que servem apenas para a formatação do código.
* **Descarte de Comentários:** Identificação e eliminação de comentários de linha única (`//`) e comentários em bloco (`/* ... */`), impedindo que textos explicativos poluam a análise sintática.
* **Rastreamento de Localização:** Atualização em tempo real dos contadores de linhas e colunas do código-fonte para viabilizar mensagens de erro semânticas e sintáticas precisas.

## Fluxo no Pipeline

Código Fonte (C++) ➔ [ Analisador Léxico (Flex) ] ➔ Fluxo de Tokens ➔ [ Analisador Sintático (Bison) ]

## Bibliografia

- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
- Levine, J. **Flex & Bison: Text Processing Tools**. O'Reilly Media, 2009.