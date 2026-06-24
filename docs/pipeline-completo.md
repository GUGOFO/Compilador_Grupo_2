---
title: Pipeline Completo do Compilador
nav_order: 6
---

# Pipeline Completo do Compilador

Este documento estabelece a visão geral e a especificação técnica de todas as etapas que compõem o pipeline do nosso sistema. O projeto opera como um **transpilador robusto e otimizador**, encarregado de traduzir um subconjunto estruturado da linguagem C++ para código C nativo padronizado.

O fluxo completo é esse:

```
Código C++ de Entrada
↓
[ 1. Análise Léxica ] ———→ scanner.l (Flex) ➔ Gera fluxo de Tokens
↓
[ 2. Análise Sintática ] ——→ parser.y (Bison) ➔ Constrói a AST polimórfica
↓
[ 3. Análise Semântica ] ——→ tabela.c ➔ Valida tipos, escopos e assinaturas
↓
[ 4. Código Intermediário ] ➔ ast.hpp ➔ Emite Código de Três Endereços (TAC) via stderr
↓
[ 5. Otimização de Código ] ➔ ast.hpp ➔ Executa podas agressivas na AST (As-If)
↓
[ 6. Geração de Código Final ] ➔ ast.hpp ➔ Emite código C compilável via stdout
↓
Binário Executável Nativo (Gerado via GCC)
```

---

## 1. Análise Léxica — `scanner.l`

A análise léxica é a primeira linha de processamento do compilador. O Flex lê o código-fonte caractere por caractere e agrupa os fluxos de texto em **Tokens** com significados léxicos definidos.

### Critérios de Casamento e Reconhecimento
O Flex utiliza o algoritmo de casamento de padrão mais longo e, em caso de empate, aplica a regra de precedência física de escrita do arquivo:
* **Palavras Reservadas:** Identifica as keywords primitivas de controle, objetos de fluxo e tipos (`int`, `while`, `cout`, `std`, etc.).
* **Operadores de Dois Caracteres:** Declarados e processados antes dos operadores simples para evitar leituras truncadas (ex: `+=`, `==`, `&&` e os pós-fixados `++` e `--`).
* **Gerenciamento de Literais:** Expressões regulares extraem os valores de literais inteiros, flutuantes, strings e caracteres, populando os campos apropriados da união global `yylval`.
* **Tratamento de Localização e Erros:** O scanner ignora espaços e comentários e mantém a contagem em tempo real de linhas e colunas para emitir mensagens detalhadas caso caracteres inválidos sejam interceptados.

---

## 2. Análise Sintática — `parser.y`

A análise sintática recebe o fluxo de tokens emitido pelo Flex e confronta a ordem das palavras contra a Gramática Livre de Contexto (GLC) do compilador. O Bison opera sob o modelo ascendente **LALR(1)**.

### Resolução de Ambiguidades e AST
* **Precedência Gramatical:** Regras explícitas de associação `%left` e `%right` solucionam ambiguidades matemáticas e lógicas nativamente (como garantir a multiplicação antes da adição).
* **Construção da Árvore:** Em vez de emitir strings diretamente, as ações gramaticais constroem uma Árvore Sintática Abstrata (AST) modular e polimórfica estruturada em ponteiros inteligentes únicos (`std::unique_ptr`), garantindo o isolamento das operações.

---

## 3. Análise Semântica — `tabela.c` / `tabela.h`

A análise semântica valida a coerência lógica e o sentido das instruções presentes na árvore sintática. Esta camada é governada por uma **Tabela de Símbolos** implementada em lista encadeada dinâmica com escopos aninhados.

### Validações Estritas Executadas
* **Controle de Escopo:** Garante que todo identificador operado tenha sido previamente declarado no bloco vigente ou em blocos superiores, limpando e desalocando da tabela as variáveis locais ao término de cada bloco `{}`.
* **Bloqueio de Redeclarações:** Impede colisões de nomes de variáveis ou vetores criados em duplicidade sob um mesmo nível de bloco lógico.
* **Type Checker (Checador de Tipos):** Força a compatibilidade de tipos em atribuições, anota a árvore com tipos inferidos e barra expressões condicionais (`if`, `while`) cujos resultados não avaliem estritamente para o tipo lógico booleano.
* **Assinatura de Retorno:** Monitora o escopo de funções e garante que o valor retornado por uma instrução `return` seja idêntico ao tipo primitivo prometido na assinatura da função.

---

## 4. Geração de Código Intermediário (TAC)

A geração de código intermediário lineariza a estrutura hierárquica da AST para uma linguagem abstrata de baixo nível chamada **Código de Três Endereços (TAC)**.

### Características do TAC no Projeto
* **Atomização de Expressões:** Sentenças matemáticas complexas são quebradas em instruções sequenciais simples amparadas por variáveis temporárias exclusivas (`t0`, `t1`, ...).
* **Aplanamento de Controle:** Laços de repetição e decisões condicionais são traduzidos em estruturas planas orientadas a rótulos de ancoragem (`L0`, `L1`, ...) e desvios lógicos condicionais.
* **Fluxo de Depuração:** O Código Intermediário completo é impresso de forma limpa diretamente no fluxo de erros do sistema (`stderr`), servindo como relatório nativo de depuração em tempo de compilação.

---

## 5. Otimização de Código — `ast.hpp`

Antes de emitir o software final, o compilador realiza modificações estruturais profundas na AST seguindo a regra do *As-If*, visando reduzir o consumo de memória e acelerar a velocidade do programa.

### Técnicas Formais Aplicadas
* **Constant Folding:** Pré-calculo recursivo de operações binárias compostas puramente por literais constantes fixos directly na árvore sintática.
* **Simplificações Algébricas:** Eliminação e simplificação automática de redundâncias matemáticas baseadas em elementos neutros e nulos (ex: `x + 0` ➔ `x`, `x * 1` ➔ `x`, `x * 0` ➔ `0`).
* **Dead Code Elimination (Eliminação de Código Morto):**
  * Poda completa de ramos condicionais inalcançáveis baseados em seleções fixas (ex: `if (false)`).
  * Rastreamento global de uso através de um conjunto dinâmico (`std::set`). Variáveis ou vetores de grande porte declarados que nunca sofram ações de leitura ou operação são **completamente suprimidos** do TAC e do arquivo final, liberando espaço físico no binário.

---

## 6. Geração de Código Final

A etapa final do pipeline percorre a AST otimizada através do método polimórfico `gerarC()`, emitindo a tradução equivalente em linguagem C nativa perfeitamente válida.

* **Mapeamento de Fluxos:** O código C transpilado é direcionado para a saída padrão (`stdout`), injetando os cabeçalhos essenciais (`<stdio.h>` e `<stdbool.h>`).
* **Compilação Nativa:** O programador realiza o redirecionamento do texto para a criação física de um arquivo fonte e invoca o utilitário GCC, obtendo como resultado máximo do projeto um binário executável nativo e independente.

---

## Resumo Técnico de Implementação

| Fase do Compilador | Ferramenta / Módulo | Arquivo de Origem | Status do Pipeline |
|---|---|---|---|
| **Análise Léxica** | Flex | `src/scanner.l` | ✅ 100% Implementado |
| **Análise Sintática** | Bison | `src/parser.y` | ✅ 100% Implementado |
| **Análise Semântica** | Tabela Encadeada | `src/tabela.c` / `tabela.h` | ✅ 100% Implementado |
| **Código Intermediário** | Gerador TAC | `src/ast.hpp` | ✅ 100% Implementado |
| **Otimização de Código** | AST Optimizer | `src/ast.hpp` | ✅ 100% Implementado |
| **Geração de Código Final** | AST Transpiler | `src/ast.hpp` | ✅ 100% Implementado |