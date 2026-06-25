---
title: 3 - Construção da AST
parent: Análise Sintática
nav_order: 3
---

# Construção da Árvore de Sintaxe Abstrata (AST)

À medida que o Bison valida a estrutura gramatical do programa, ele executa ações semânticas associadas para construir uma representação intermediária chamada **Árvore de Sintaxe Abstrata (AST)**. Essa árvore mapeia logicamente o programa para possibilitar a tradução para C.

## 3.1 - Arquitetura de Nós (`ast.hpp`)

Cada elemento estrutural da linguagem é representado por uma classe que herda da classe base `ASTNode`. O projeto faz uso de gerenciamento de memória moderno por meio de ponteiros inteligentes (`std::unique_ptr<ASTNode>`), representados pelo alias `NodoPtr`.

Cada nó implementa métodos fundamentais para o pipeline:
* `print(int nivel)`: Exporta a estrutura hierárquica da árvore em texto para fins de depuração.
* `gerarC(int nivel)`: Realiza a tradução direta e a indentação do nó para código C equivalente.
* `gerarTAC(int nivel)`: Prepara o nó para a emissão de Código de Três Endereços (TAC).

### Componentes de Seleção Múltipla Implementados:
* **`SwitchNode`**: Gerencia a expressão de controle avaliada (`NodoPtr expressao`) e ramificações guardadas em `std::vector<NodoPtr> cases`. O método `gerarC` abre o escopo traduzido para `switch (...) {` e delega a indentação de cada caso interno.
* **`CaseNode`**: Representa uma cláusula condicional interna. Se possuir uma condição válida, renderiza `case X:`, caso contrário, é interpretado diretamente como o bloco `default:`.

## 3.2 - Passagem de Dados entre Bison e AST

No arquivo `parser.y`, a diretiva `%union` especifica quais tipos de dados os tokens e os símbolos não-terminais podem carregar:

```c
%union {
    int          ival;
    char* sval;
    ASTNode* nodo;
    std::vector<ASTNode*>* lista;
}
```