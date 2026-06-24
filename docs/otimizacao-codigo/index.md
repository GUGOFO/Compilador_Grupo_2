---
title: Otimização de Código
nav_order: 6
has_children: true
---

# Otimização de Código

A otimização de código é a fase do compilador responsável por transformar a representação interna do programa (a nossa Árvore Sintática Abstrata - AST) de modo que o código final gerado seja mais eficiente. Essa eficiência pode ser medida em termos de menor tempo de execução (velocidade) ou menor consumo de recursos (memória e espaço em disco).

No desenvolvimento do nosso transpilador, as otimizações são aplicadas diretamente sobre a AST através de métodos recursivos antes que a geração de Código Intermediário (TAC) e Código C Final seja disparada.

## A Regra do *As-If* (Como Se)

Todas as transformações executadas pelo nosso otimizador obedecem estritamente à **Regra do As-If**. Essa regra fundamental da engenharia de compiladores estabelece que o otimizador possui total liberdade para modificar a estrutura interna, alterar cálculos e remover elementos do código original, desde que o comportamento observável do programa final seja **exatamente o mesmo** que o programador pretendia.

Ou seja, o programa otimizado deve produzir exatamente as mesmas saídas textuais (`cout`) e lógicas para as mesmas entradas fornecidas pelo usuário (`cin`), mas executando menos instruções por baixo dos panos.

## Benefícios da Otimização Baseada na AST

Aplicar as otimizações diretamente na árvore sintática oferece vantagens estratégicas de projeto:
* **Independência de Arquitetura:** As simplificações são feitas em alto nível lógico, o que significa que o código gerado será otimizado independentemente se o destino final for um processador Intel, ARM ou um transpilador C.
* **Limpeza Multicamadas:** Ao podar a AST, economizamos a geração de variáveis temporárias e rótulos no TAC, o que por consequência emite um arquivo C nativo muito mais enxuto e limpo para o GCC compilar.

## Bibliografia

- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
- Muchnick, S. S. **Advanced Compiler Design and Implementation**. Morgan Kaufmann, 1997.