---
title: Tabela de Símbolos
parent: Análise Semântica
nav_order: 2
---

# Tabela de Símbolos

A Tabela de Símbolos é a estrutura de dados central da análise semântica. Ela atua como um repositório dinâmico contendo o registro de todos os identificadores (variáveis, vetores e funções) declarados ao longo do programa, permitindo consultas contextuais rápidas durante a checagem de tipos e a validação de escopos.

## Campos da Tabela Real do Projeto

Cada registro inserido na nossa tabela de símbolos armazena estritamente as seguintes informações estruturadas em C/C++:

| Campo | Tipo | Descrição |
|---|---|---|
| `nome` | char[36] | O nome textual do identificador como foi escrito pelo programador. |
| `tipo` | char[20] | O tipo de dado associado (`int`, `float`, `double`, `bool`, `char`, `void` ou a notação `[]` para indicar vetores). |
| `escopo` | int | O nível de aninhamento numérico onde o identificador foi declarado (0 = escopo global, 1 = funções/variáveis locais da main, 2+ = blocos internos). |

## Exemplo

Dado o seguinte código C++:

```cpp

int calcularDobro(int numero) {
    return numero * 2;
}

int main() {
    int idade = 21;
    int meuVetor[5];
}

```

As chamadas internas de depuração do compilador (`imprimirTabela()`) refletem as tabelas de símbolos nos fechamentos de escopo da seguinte maneira:

* **Ao fechar o escopo da função `calcularDobro` (Nível 1):**
    * Nome: `numero`, Tipo: `int`, Escopo: `1`
    * Nome: `calcularDobro`, Tipo: `int`, Escopo: `0`

* **Ao fechar o escopo da função `main` (Nível 1):**
    * Nome: `calcularDobro`, Tipo: `int`, Escopo: `0`
    * Nome: `main`, Tipo: `int`, Escopo: `0`
    * Nome: `idade`, Tipo: `int`, Escopo: `1`
    * Nome: `meuVetor`, Tipo: `int[]`, Escopo: `1`

## Gerenciamento Dinâmico de Escopos

O escopo é gerenciado por meio de um contador numérico global (`nivel_atual`) controlado incrementalmente pelo Bison. Toda vez que o parser abre um caractere `{`, o nível de escopo é incrementado. Quando o caractere `}` correspondente é fechado, a função `removerEscopo(nivel_atual)` é acionada, realizando uma varredura na lista encadeada da tabela para desalocar da memória e descartar todos os símbolos pertencentes àquele nível que acabou de expirar, mantendo as variáveis superiores protegidas contra colisões.

## Gerenciamento de escopos

O escopo é gerenciado por meio de um contador numérico global (nivel_atual) controlado incrementalmente pelo Bison.
Toda vez que o parser abre um caractere {, o nível de escopo é incrementado. Quando o caractere } correspondente é fechado, a função removerEscopo(nivel_atual) é acionada, realizando uma varredura na lista encadeada da tabela para desalocar da memória e descartar todos os símbolos pertencentes àquele nível que acabou de expirar, mantendo as variáveis superiores protegidas contra colisões.

## Integração Real no Arquivo parser.y

Diferente de um transpilador ingênuo baseado em macros textuais, nosso analisador semântico realiza as verificações de tipo e escopo diretamente nas ações gramaticais do Bison antes de acoplar os nós na Árvore Sintática Abstrata (AST):

1. Na Declaração de Variável:

```cpp
tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON
{
    // A própria função inserirSimbolo aborta o programa se houver redefinição no mesmo escopo
    inserirSimbolo($2, $1, nivel_atual);
    
    if (!verificar_atribuicao_ok($1, $4->tipo_inferido)) {
        fprintf(stderr, "Erro semantico (linha %d): tipo '%s' incompativel com '%s'\n", yylineno, $4->tipo_inferido.c_str(), $1);
        erro_semantico_detectado = true;
    }
    
    auto* n = new DeclVarNode($1, $2, adotar($4));
    n->linha = yylineno;
    $$ = n;
}
```

2. No Uso de um Identificador (Expressão):

```cpp
| TOK_ID
{
    Simbolo* s = buscarSimbolo($1, nivel_atual);
    if (!s) {
        fprintf(stderr, "Erro semantico (linha %d): variavel '%s' nao declarada.\n", yylineno, $1);
        erro_semantico_detectado = true;
    }
    
    auto* n = new IdentificadorNode($1);
    n->linha = yylineno;
    if (s) n->tipo_inferido = s->tipo; // Decora o nó da AST com o tipo real vindo da tabela
    $$ = n;
}
```

## Bibliografia:

- https://pgrandinetti-github-io.translate.goog/compilers/page/what-is-semantic-analysis-in-compilers/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc
- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
