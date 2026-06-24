---
title: Geração de Código Final
nav_order: 7
has_children: true
---

# Geração de Código Final

A Geração de Código Final é a etapa de encerramento do pipeline do nosso compilador. Sua função primordial é percorrer a Árvore Sintática Abstrata (AST) — que já passou pelas validações semânticas e pelas podas de otimização — e traduzi-la de forma estruturada para a linguagem alvo.

No contexto do nosso projeto, o compilador opera como um **Transpilador (Source-to-Source Compiler)**, mapeando as construções estruturadas da linguagem de entrada (C++) diretamente para o código-fonte em linguagem C nativa padronizada.

## O Papel da Linguagem C como Código Alvo

A escolha da linguagem C padrão como código alvo oferece vantagens estratégicas para o projeto do compilador:
* **Portabilidade Binária:** Em vez de gerar código de máquina para um processador específico, delegamos essa complexidade ao GCC (GNU Compiler Collection), garantindo que o código gerado possa virar um executável nativo em qualquer sistema operacional.
* **Legibilidade de Depuração:** O arquivo de saída gerado é um texto em código C perfeitamente legível por humanos. Isso facilita a auditoria da tradução e a comprovação de que as otimizações e escopos foram mantidos de forma correta.

## Mecanismo de Redirecionamento de Fluxo

Para consolidar os critérios de modularidade de software, a emissão do código alvo utiliza os fluxos padrões do terminal:
1. O método de geração caminha recursivamente sobre a árvore sintática e emite as instruções em C diretamente através da saída padrão (`stdout`).
2. Durante a execução, o usuário realiza o redirecionamento desse fluxo criando o arquivo físico final (geralmente nomeado como `saida.c`).
3. Na sequência, o utilitário GCC é invocado sobre esse arquivo, realizando a compilação física que gera o binário executável independente.

## Bibliografia

- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.