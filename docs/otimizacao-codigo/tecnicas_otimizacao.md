---
title: Técnicas de Otimização Implementadas
parent: Otimização de Código
nav_order: 2
---

# Técnicas de Otimização Implementadas

O nosso compilador executa três técnicas clássicas de otimização de forma recursiva ao caminhar pelos nós da árvore sintática (AST) antes de emitir o código intermediário e alvo. Abaixo está o detalhamento conceitual e exemplos práticos de como cada uma delas é aplicada no projeto:

---

## 1. Constant Folding (Dobramento de Constantes)

O **Constant Folding** consiste em avaliar e pré-calcular operações matemáticas envolvendo valores constantes (literais fixos) diretamente em tempo de compilação, em vez de deixar que essa conta seja feita em tempo de execução.

* **Como é aplicado:** Quando o analisador processa um nó de operação binária (como `+`, `-`, `*`), ele inspeciona se ambos os nós filhos (esquerdo e direito) são literais constantes. Caso positivo, o compilador realiza a conta matematicamente, remove os nós originais e os substitui por um único nó literal com o resultado calculado.

* **Exemplo de Aplicação:**
    * **Código Original (C++):** `int resultado = 2 * 25;`
    * **Árvore Sintática (Antes):** Um nó de atribuição apontando para um operador `*` que conecta os literais `2` e `25`.
    * **Árvore Sintática (Depois):** O operador e os filhos são eliminados. Resta apenas o nó de atribuição recebendo diretamente o literal `50`.
    * **Código C Final Gerado:** `int resultado = 50;`

---

## 2. Simplificações Algébricas

A técnica de **Simplificação Algébrica** utiliza identidades e propriedades matemáticas (como os elementos neutros e nulos da aritmética) para simplificar ou eliminar expressões redundantes na árvore sintática.

O nosso otimizador avalia e aplica automaticamente três cenários distintos:

* **A) Elemento Neutro da Adição e Subtração (`+ 0` ou `- 0`):**
    * **Código Original:** `calculo = valor + 0;`
    * **Como é aplicado:** O compilador detecta que o filho direito é o literal zero sob um operador de soma. Ele descarta o operador e o zero, mantendo apenas o identificador original.
    * **Código C Final Gerado:** `calculo = valor;`

* **B) Elemento Neutro da Multiplicação (`* 1`):**
    * **Código Original:** `total = saldo * 1;`
    * **Como é aplicado:** O compilador identifica a multiplicação pelo literal um. A subárvore é reduzida para preservar apenas o nó da variável.
    * **Código C Final Gerado:** `total = saldo;`

* **C) Elemento Nulo da Multiplicação (`* 0`):**
    * **Código Original:** `resultado = (expressao_longa_e_complexa) * 0;`
    * **Como é aplicado:** Multiplicar qualquer valor por zero resulta em zero. O otimizador realiza uma poda agressiva: ele descarta completamente toda a subárvore da expressão complexa (independentemente do tamanho) e a substitui instantaneamente por um nó contendo apenas o literal zero.
    * **Código C Final Gerado:** `resultado = 0;`

---

## 3. Dead Code Elimination (Eliminação de Código Morto)

A **Eliminação de Código Morto** identifica e remove instruções, blocos ou declarações que não possuem utilidade prática ou que nunca serão alcançados pelo fluxo de execução do sistema. Ela é aplicada em duas frentes:

### A) Poda de Ramos Condicionais Inalcançáveis
Ocorre quando o resultado lógico de uma estrutura condicional envolve um literal booleano constante avaliado em tempo de compilação.

* **Como é aplicado:** Ao analisar uma estrutura `if`, o compilador verifica o valor da condição. Se a condição for avaliada como falsa fixa, todo o bloco de comandos internos é descartado da AST.
* **Exemplo de Aplicação:**

    * **Código Original:** 
    ```cpp
      if (false) {
          int idade = 99;
          std::cout << idade;
      }
    ```
    
    * **Transformação Semântica:** O compilador apaga completamente o bloco interno. Como o bloco foi eliminado na AST, as variáveis internas não vazam e nenhuma instrução de desvio (`if_falso` ou `goto`) é gerada no TAC.
    * **Código C Final Gerado:** *(Nenhuma linha de código é emitida para este bloco)*.

### B) Eliminação de Declarações de Variáveis Não Utilizadas
Muitas vezes variáveis ou vetores são alocados no código mas nunca chegam a ser operados, desperdiçando memória física.

* **Como é aplicado:** O compilador monitora dinamicamente quais variáveis sofrem ações de leitura, escrita, operações aritméticas ou impressões via `cout`. Os nomes dessas variáveis são salvos em um conjunto global de uso. No momento de emitir o código, os nós de declaração consultam esse conjunto; se a variável não foi usada, sua declaração é omitida.
* **Exemplo de Aplicação:**
    * **Código Original:**
      ```cpp
      int idade = 21;
      bool flagInutil = true;
      int meuVetorInutil[50];
      std::cout << idade;
      ```
    * **Transformação Semântica:** O compilador registra que apenas `idade` foi ativamente requisitada no programa. As variáveis `flagInutil` e `meuVetorInutil` são identificadas como mortas.
    * **Código C Final Gerado:**
      ```c
      int idade = 21;
      printf("%d", idade);
      ```
    *(Note que as declarações da flag e do vetor de 50 posições sumiram completamente do TAC e do arquivo final, otimizando o consumo de memória do programa)*.