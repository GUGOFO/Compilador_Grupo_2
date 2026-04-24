---
title: Tabela de Símbolos
parent: Análise Semântica
nav_order: 2
---

# Tabela de Símbolos

A tabela de símbolos é a estrutura de dados central da análise semântica. Ela funciona como um cadastro de tudo que foi declarado no programa: variáveis, funções e parâmetros. O analisador consulta essa tabela toda vez que encontra um identificador no código, pra verificar se ele existe, qual é o tipo e se está sendo usado corretamente.

## Campos da tabela

Cada entrada na tabela guarda as seguintes informações:

| Campo | Tipo | Descrição |
|---|---|---|
| `nome` | string | nome do identificador como foi escrito no código |
| `categoria` | enum | se é uma `variavel`, `funcao` ou `parametro` |
| `tipo` | string | tipo de dado declarado: `int`, `float`, `double`, `bool`, `char`, `void` etc. |
| `nivel_escopo` | inteiro | nível de aninhamento onde foi declarado (0 = global, 1 = dentro de uma função, 2 = dentro de um bloco `if`/`while`...) |
| `linha_declaracao` | inteiro | linha do código fonte onde o símbolo foi declarado |
| `inicializada` | booleano | se a variável já recebeu algum valor antes de ser usada |
| `valor_inicial` | string | valor com que foi inicializada, se houver |
| `tamanho` | inteiro | pra arrays: quantos elementos tem; pra variáveis simples é sempre 1 |

## Exemplo

Dado o seguinte código C++:

```cpp
int contador = 0;

int soma(int a, int b) {
    int resultado = a + b;
    return resultado;
}

int main() {
    float media = 7.5;
    bool aprovado = true;
}
```

A tabela de símbolos gerada seria:

| nome | categoria | tipo | nivel_escopo | linha_declaracao | inicializada | valor_inicial | tamanho |
|---|---|---|---|---|---|---|---|
| `contador` | variavel | `int` | 0 | 1 | sim | `0` | 1 |
| `soma` | funcao | `int` | 0 | 3 | sim | — | 1 |
| `a` | parametro | `int` | 1 | 3 | sim | — | 1 |
| `b` | parametro | `int` | 1 | 3 | sim | — | 1 |
| `resultado` | variavel | `int` | 1 | 4 | sim | `a + b` | 1 |
| `main` | funcao | `int` | 0 | 8 | sim | — | 1 |
| `media` | variavel | `float` | 1 | 9 | sim | `7.5` | 1 |
| `aprovado` | variavel | `bool` | 1 | 10 | sim | `true` | 1 |

`resultado`, `a` e `b` pertencem ao nível de escopo `1` (dentro da função `soma`), enquanto `contador`, `soma` e `main` pertencem ao nível `0` (escopo global).

## Gerenciamento de escopos

O escopo define em que parte do programa um identificador existe. O analisador gerencia os escopos usando uma pilha: toda vez que entra em um novo bloco `{`, um novo nível é empilhado; quando o bloco `}` é fechado, esse nível é desempilhado e todos os símbolos declarados nele são descartados.

```
Início do programa
└── Escopo 0 (global)
    ├── int contador = 0
    ├── int soma(...)
    │   └── Escopo 1 (função soma)
    │       ├── int a
    │       ├── int b
    │       └── int resultado
    │   ← ao fechar }, nível 1 é descartado
    └── int main()
        └── Escopo 1 (função main)
            ├── float media
            └── bool aprovado
        ← ao fechar }, nível 1 é descartado
```

## Sombreamento de variável

C++ permite que uma variável interna tenha o mesmo nome de uma variável externa. O analisador sempre usa a declaração mais recente (a mais próxima na pilha):

```cpp
int x = 100;

int main() {
    int x = 5;
    return x; // usa o x do nível 1, que vale 5
}
```

## Como ficaria no parser.y do projeto

O `parser.y` atual é um transpilador puro — traduz C++ pra C sem verificar nenhuma semântica. Pra adicionar a tabela de símbolos, as verificações seriam colocadas diretamente nas ações das regras gramaticais que já existem:

**Na declaração de variável:**
```c
declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        if (buscar_simbolo_no_escopo_atual($2) != NULL)
            yyerror("variável já declarada neste escopo");

        inserir_simbolo($2, $1, nivel_atual, yylineno, 1, $4);

        print_indent(nivel_atual);
        printf("%s %s = %s;\n", $1, $2, $4);
    }
```

**No uso de um identificador em expressão:**
```c
exp:
    TOK_ID {
        Simbolo *s = buscar_simbolo($1);
        if (s == NULL)
            yyerror("identificador não declarado");

        $$ = strdup($1);
    }
```

**Na declaração de função:**
```c
funcao:
    tipo TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE {
        inserir_simbolo($2, $1, 0, yylineno, 1, NULL);
        entrar_escopo();
        printf("%s %s() {\n", $1, $2);
        nivel_atual++;
    }
    lista_comandos TOK_RBRACE {
        sair_escopo();
        nivel_atual--;
        print_indent(nivel_atual);
        printf("}\n");
    }
```
