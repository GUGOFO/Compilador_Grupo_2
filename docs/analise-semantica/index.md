---
title: Análise Semântica
nav_order: 4
has_children: true
---

# Análise Semântica

A análise semântica é a terceira fase do front-end do compilador, executada imediatamente após a construção da Árvore Sintática Abstrata (AST) pelo parser.

Enquanto o analisador sintático valida apenas a estrutura gramatical do código (a ordem e a disposição dos tokens), o analisador semântico debruça-se sobre o **sentido e a consistência lógica** do programa, servindo como a última barreira de validação estrita antes do início das fases de otimização e geração de código.

No escopo do nosso transpilador de C++ para C, o analisador semântico executa de forma integrada as seguintes rotinas obrigatórias:
* **Verificação de Escopo:** Garante que todos os identificadores utilizados em expressões matemáticas ou lógicas tenham sido declarados previamente no bloco atual ou em blocos superiores.
* **Detecção de Redeclarações:** Impede que um mesmo nome de variável ou vetor seja declarado mais de uma vez dentro do mesmo nível de escopo.
* **Verificador de Tipos (*Type Checker*):** Avalia e valida a consistência de tipos em atribuições simples e compostas, checa a validade aritmética de operações binárias e assegura que os índices de vetores sejam estritamente expressões inteiras.
* **Validação de Condições de Controle:** Assegura que as expressões que regem as estruturas condicionais e de repetição (`if`, `while`, `do-while`) avaliem para o tipo lógico `bool`.
* **Consistência de Retorno:** Garante que as instruções `return` dentro do bloco de uma função devolvam um valor perfeitamente compatível com o tipo de dado estipulado na assinatura da função.

## Bibliografia

- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
- Grandinetti, P. *What is Semantic Analysis in Compilers?* Disponível em: <https://pgrandinetti.github.io/compilers/page/what-is-semantic-analysis-in-compilers/>.