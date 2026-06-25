# Transpilador de C++ para C Otimizado

Este arquivo contém o guia operacional rápido com os pré-requisitos e os passos necessários para compilar e executar o transpilador do grupo.

## Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas e configuradas no seu ambiente (Linux, macOS ou WSL no Windows):
* **Flex** (Fast Lexical Analyzer Generator)
* **Bison** (GNU Project Parser Generator)
* **G++ / GCC** (Com suporte para C++17 e compilação C nativa)

## Como Compilar e Rodar

Siga o passo a passo abaixo executando os comandos sequencialmente no seu terminal:

1. **Entre na pasta de código-fonte:**
```bash
cd src
```
2. **Gere o analisador sintático com o Bison:**
```bash
bison -d parser.y
```
3. **Gere o analisador léxico com o Flex:**
```bash
flex scanner.l
```
4. **Compile o transpilador utilizando o padrão C++17:**
```bash
g++ -std=c++17 parser.tab.c lex.yy.c tabela.c -o transpilador
```
5. **Execute a transpilação do arquivo de teste e invoque o GCC para gerar o binário final:**
```bash
./transpilador < exemplo_entrada.c++ > saida.c && gcc saida.c -o programa_executavel
```
6. **Execute o programa nativo executável gerado:**
```bash
./programa_executavel
```

Este documento detalha as especificações formais, decisões de projeto, verificações semânticas e estratégias de otimização implementadas no transpilador modular de C++ para C.

## Como Rodar a Suíte de Testes Automatizada

O projeto conta com um script de automação (executar_testes.sh) que realiza todo o ciclo de vida do pipeline: compila o transpilador, valida os arquivos lícitos, captura e exibe os diagnósticos dos testes de erro controlados e imprime os relatórios analíticos de Código Intermediário (TAC).

1. Dê permissão de execução ao script:

```bash
chmod +x executar_testes.sh
```

2. Execute a suíte completa:

```bash
./executar_testes.sh
```

## Arquitetura do Pipeline do Compilador
O sistema implementa o fluxo de tradução clássico dividido nas seguintes camadas estruturadas:
* **Análise Léxica (`scanner.l`):** Conversão do fluxo de caracteres de entrada em tokens lógicos, tratando palavras reservadas, literais, operadores matemáticos/atribuição e lógica simbólica/textual (`and`, `not`, `or`).
* **Análise Sintática (`parser.y`):** Analisador sintático ascendente LALR gerado pelo Bison que valida o fluxo de tokens contra a Gramática Livre de Contexto (GLC) e constrói a Árvore Sintática Abstrata (AST).
* **Análise Semântica (`tabela.c`):** Verificador de tipos (*Type Checker*), controle de escopo estático por meio de lista encadeada e inferência automática de expressões na árvore.
* **Geração de Código Intermediário (TAC):** Emissão de Código de Três Endereços utilizando variáveis temporárias (`t0`, `t1`, ...) e rótulos de controle (`L0`, `L1`, ...) direcionados ao fluxo `stderr`.
* **Otimização de Código (`ast.hpp`):** Algoritmos recursivos que caminham sobre os nós da AST aplicando podas e transformações em tempo de compilação.
* **Geração de Código Final (`ast.hpp`):** Tradução estruturada da AST higienizada para código de linguagem C padrão, incluindo cabeçalhos essenciais, direcionada ao fluxo `stdout`.
