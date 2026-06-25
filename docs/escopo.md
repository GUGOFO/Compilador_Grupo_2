---
title: Escopo Operational Atualizado
nav_order: 99
---

# Tabela de Escopo Operacional do Compilador

A tabela abaixo resume o escopo operacional real e atualizado do compilador, dividindo as construções da linguagem C++ entre o que é nativamente suportado pelo pipeline após as últimas implementações e o que ainda gerará falhas ou erros.

| Categoria | Suportado | Não Suportado / Quebra |
| :--- | :--- | :--- |
| **Tipos de Dados** | `int`, `float`, `double`, `bool`, `char`, `long`, `short`, `void`. | Criar classes (`class`), estruturas (`struct`) ou usar tipos complexos da biblioteca padrão (ex: `std::string`). |
| **Declaração de Variáveis** | Uma variável por linha, com ou sem inicialização (ex: `int a = 0;` ou `int b;`). | **Declarações múltiplas** na mesma linha separadas por vírgula (ex: `int a, b;` gera **Erro Sintático**). |
| **Estruturas de Controle** | `if`, `else`, `while`, `do-while`, `for`, `break`, `continue`, `return`, além de suporte completo a blocos **`switch`**, **`case`** e **`default`**. | Estruturas de escolha baseadas em tipos não integris (como switch de strings). |
| **Blocos e Chaves `{}`** | Delimitar os corpos de todas as estruturas (`if`, `while`, etc.) obrigatoriamente com chaves `{ }`, mesmo contendo apenas uma instrução. | Omitir as chaves `{ }` em estruturas de linha única (Gera **Erro Sintático**). |
| **Laço `for`** |Aceita a inicialização de variáveis, expressões condicionais e atualização automática por meio de operadores pós-fixados (`i++`, `i--`). | Expressões de atualização vazias ou omissão de delimitadores internos. |
| **Funções (Declaração e Uso)** | Declaração de funções **com ou sem parâmetros** (ex: `int calcularDobro(int numero)`) e **chamadas de função estruturadas** com repasse de argumentos. | Funções com assinaturas complexas (ponteiros de funções, sobrecarga) ou checagem estrita de aridade de parâmetros devido à simplicidade da tabela de símbolos. |
| **Nomes de Identificadores** | Nomes com até **35 caracteres**. Suporta *shadowing* (sombreamento) em escopos diferentes protegendo variáveis superiores. | Nomes com **36 caracteres ou mais** (Gera **Estouro de Buffer / Segmentation Fault** na struct de tamanho fixo). Redeclarar a mesma variável no mesmo bloco. |
| **I/O (Entrada e Saída)** | Um único operando por instrução: `std::cout << "texto"` e `std::cout << numero`, `std::cin >> variavel`. Floats são impressos com formato estável de ponto flutuante. | **Encadeamento de operadores** (ex: `cout << a << b;` ou `cin >> a >> b;` geram **Erro Sintático**). Usar `std::endl` (Gera **Erro Sintático**). Use Cin so com int |
| **Operadores Matemáticos** | Expressões binárias (`+`, `-`, `*`, `/`, `%`), suporte unário (sinais negativos) e **suporte nativo a operadores pós-fixados de incremento (`++`) e decremento (`--`)**. | Operadores pré-fixados (ex: `++i`, `--j`) ou operadores bitwise complexos. |
| **Operadores Lógicos** | Símbolos clássicos (`&&`, `BARRA BARRA`, `!`) e operadores textuais equivalentes (`and`, `or`, `not`) mapeados de forma harmonizada. | Expressões com profundidade de recursão extrema (risco de estourar a pilha interna do Bison). |
| **Literais Numéricos** | Inteiros até cerca de 2.14 bilhões (10 dígitos). Ponto flutuante com suporte a precisão simples e dupla impresso via `%f`. | Inteiros gigantes (sofrem **Overflow** silencioso via `atoi`). Números flutuantes gigantes são truncados ou viram `inf`. |
| **Strings e Caracteres** | Strings com escapes (ex: `"Linha 1\n"`) e caracteres únicos (`'a'`, `'\n'`) resolvidos por sequências de escape no léxico. | Quebras de linha físicas literais dentro das aspas duplas (Gera **Erro Léxico**). Caracteres múltiplos dentro de aspas simples (ex: `'abc'`). |
| **Arrays e Vetores** | Declaração de vetores unidimensionais (ex: `int meuVetor[5];`), **atribuição indexada** (`meuVetor[2] = 88;`) e **acesso de elementos** com cálculo de offset no TAC. | Matrizes multidimensionais (ex: `int m[2][2]`) ou manipulação direta de ponteiros aritméticos de baixo nível (`*ptr`, `&var`). |
| **Operador `sizeof()`** | Reconhecimento léxico e sintático da estrutura do operador para tipos e expressões (ex: `sizeof(int)` ou `sizeof(a)`). | O operador repassa a estrutura do tipo ou identificador diretamente para o nó correspondente na árvore sintática. |
| **Comentários** | Comentários de linha única (`//`) e de múltiplas linhas (`/* ... */`). São descartados no léxico e não geram impactos no parser. | Aninhar blocos de comentários de múltiplas linhas (ex: `/* A /* B */ C */`) quebra a lógica de captura do scanner. |
| **Bibliotecas e Pré-processador** | Injeção automática das diretivas `#include <stdio.h>` e `#include <stdbool.h>` no topo do arquivo objeto gerado. | Escrever manualmente diretivas de pré-processador (como `#include <iostream>`) no código fonte C++ (Gera **Erro Léxico** devido ao caractere `#`). |

---

## 2. Especificação Individual de Limites Técnicos e Estouros

Abaixo estão descritas as restrições físicas de capacidade e os comportamentos de falha para cada componente de dados do sistema:

### 2.1 - Tipo `int` (Inteiros de 32 bits)
* **Limite Técnico:** Valores na faixa de **`-2.147.483.648` a `2.147.483.647`** (Inteiro de 32 bits com sinal em complemento de dois).
* **Justificativa no Código:** O analisador léxico (`scanner.l`) captura a sequência numérica via `[0-9]+` e delega a conversão textual para a função `atoi(yytext)`, cujo resultado é armazenado no campo `<ival>` do Bison, tipado nativamente como `int`.
* **Comportamento no Estouro:** Entradas de literais que excedam esses limites numéricos sofrerão de **Integer Overflow** durante a compilação do transpilador, provocando efeitos de *rollover* (onde números excessivamente grandes tornam-se negativos ou truncam para valores corrompidos).

### 2.2 - Tipos `float` e `double` (Pontos Flutuantes)
* **Limite Técnico:** Expoente máximo de magnitude $\approx 3.4 \times 10^{38}$ e precisão garantida de até **7 dígitos decimais**.
* **Justificativa no Código:** Embora o scanner utilize a função `atof(yytext)` (capaz de ler dupla precisão de 64 bits), a estrutura da `%union` no `parser.y` define estritamente o campo de transporte como **`float fval;`**. Como consequência, qualquer número fracionário sofre um *downcast* implícito na árvore sintática, operando na precisão simples de um `float` de 32 bits.
* **Comportamento no Estouro:** Decimais que excedam a magnitude máxima sofrem estouro de ponto flutuante em tempo de transpilação, convertendo-se silenciosamente no símbolo **`inf`** (Infinito) no arquivo C gerado ou sacrificando a precisão dos dígitos menos significativos.

### 2.3 - Tipo `char` (Caracteres Primitivos)
* **Limite Técnico:** Tamanho fixo de **1 byte** (Mapeamento numérico integral de 0 a 255 na tabela ASCII).
* **Justificativa no Código:** O scanner processa os caracteres envoltos por aspas simples, incluindo o tratamento de sequências de escape padrão (como `\n` e `\t`), e armazena o respectivo valor numérico ASCII no campo `<ival>` da união.
* **Comportamento no Estouro:** Tentar agrupar caracteres múltiplos dentro de aspas simples (ex: `'abc'`) corrompe a lógica de casamento do Flex, fazendo com que o analisador capture apenas o primeiro caractere útil e descarte o restante de maneira imprevisível.

### 2.4 - Tipo `string` (Cadeias de Texto Literais)
* **Limite Técnico:** Limitado pelo tamanho máximo do buffer interno de leitura do Flex (padrão de **16 KB por token**) e pela memória RAM disponível no sistema para alocação.
* **Justificativa no Código:** O padrão léxico `\"([^"\\\n]|\\.)*\"` captura a string e invoca a rotina **`strdup(yytext)`** para duplicar textualmente os caracteres na memória heap do transpilador, salvando o ponteiro de referência em `yylval.sval`.
* **Comportamento no Estouro:** O padrão bloqueia quebras de linha físicas diretas no meio do texto sem o uso de barra de escape. Strings que estourem o buffer fixo ou violem a regra de quebra de linha abortam o sistema imediatamente por **Erro Léxico**.

### 2.5 - Identificadores (`TOK_ID` - Nomes de Variáveis e Funções)
* **Limite Técnico:** Comprimento máximo de **35 caracteres úteis**.
* **Justificativa no Código:** A estrutura de registros da análise semântica define rigorosamente o campo em C como **`char nome[36];`** no arquivo `tabela.h`. Como strings em C exigem o caractere terminador nulo (`\0`) na última posição, restam apenas 35 bytes de espaço utilizável.
* **Comportamento no Estouro:** A função de inserção semântica em `tabela.c` opera por meio da função de cópia direta `strcpy(novo->nome, nome);`. A definição de uma variável ou função com 36 caracteres ou mais provocará um **Buffer Overflow** interno, corrompendo referências vizinhas da lista encadeada e fechando o transpilador com um erro de **Falha de Segmentação (*Segmentation Fault*)**.

### 2.6 - Vetores e Arrays (`DeclVetorNode`)
* **Limite Técnico:** Índice máximo de até `2.147.483.647` elementos na árvore sintática. Na execução do programa final, o tamanho total fica restrito ao tamanho da pilha do sistema operacional (geralmente limitado a **8 MB** por padrão em sistemas Linux e macOS).
* **Justificativa no Código:** O `parser.y` captura a constante de tamanho através do token `TOK_INT_LIT`. Ao transcompilar para o código alvo, a árvore emite uma alocação estática local padronizada em C (`tipo nome[tamanho];`).
* **Comportamento no Estouro:** A declaração de arrays excessivamente gigantescos passará com sucesso pelo transpilador e pelo GCC. No entanto, no momento da execução do binário final, a tentativa de alocar um bloco de memória superior a 8 MB estourará instantaneamente a pilha de execução, resultando em um erro de **Stack Overflow (Segmentation Fault)** em tempo de execução.

### 2.7 - Níveis de Escopo / Aninhamento de Blocos
* **Limite Técnico:** Suporta o controle escalar de até `2.147.483.647` níveis internos, limitado na prática pela pilha de recursão sintática do Bison (configurada por padrão para até **10.000** estados abertos).
* **Justificativa no Código:** O controle é monitorado de forma atômica por meio da variável global inteira **`int nivel_atual = 0;`** presente no escopo do parser, incrementada a cada token `{` e decrementada a cada token `}`.
* **Comportamento no Estouro:** Tentar aninhar blocos de chaves de forma excessiva e redundante satura a pilha de análise LALR(1), provocando o travamento do Bison por **Falha no Parsing**.