---
title: Geração de Código Intermediário (TAC)
nav_order: 5
has_children: true
---

# Geração de Código Intermediário (TAC)

A Geração de Código Intermediário é a fase que faz a ponte fundamental entre o front-end (independente da máquina alvo) e o back-end do compilador. No nosso projeto, a Árvore Sintática Abstrata (AST) validada e otimizada é traduzida para uma representação linearizada conhecida como **Código de Três Endereços (TAC - Three-Address Code)**.

O TAC é uma linguagem de baixo nível abstrata onde cada instrução possui, no máximo, três operadores: dois operandos de entrada, um operador de ação e um local de destino. Essa estrutura simplificada facilita drasticamente a análise de fluxo de dados e prepara o ambiente para otimizações de baixo nível antes da emissão do código final.

## Objetivos do TAC no Nosso Compilador

No escopo do nosso transpilador modular, a geração de TAC desempenha papéis de engenharia fundamentais:
* **Linearização do Fluxo:** Transforma estruturas de controle complexas e aninhadas da árvore sintática (como laços `for`, `while`, `do-while` e blocos `switch-case`) em uma sequência plana de instruções baseadas em desvios condicionais e rótulos.
* **Abstração de Expressões Complexas:** Desmembro de expressões matemáticas longas e aninhadas em passos atômicos sequenciais, fazendo uso de variáveis temporárias.
* **Mapeamento de Memória para Arrays:** Conversão de acessos indexados de vetores em operações explícitas de cálculo de deslocamento (*offset*) em bytes.
* **Padronização de Chamadas de Função:** Organização sequencial da passagem de parâmetros e recebimento de retornos através de pilhas abstratas de ativação.

## Fluxo de Saída de Dados

Para manter a organização modular de Engenharia de Software exigida na disciplina, o nosso compilador separa a saída de dados em duas frentes:
1. O **Código C Final** Otimizado é direcionado para a saída padrão (`stdout`), permitindo o redirecionamento direto para a criação do arquivo fonte (.c).
2. O **Código Intermediário (TAC)** é impresso de forma limpa e estruturada diretamente no fluxo de erro padrão (`stderr`), servindo como um excelente relatório analítico de depuração exibido em tempo real na tela do terminal.

## Bibliografia

- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.