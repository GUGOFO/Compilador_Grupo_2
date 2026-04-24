---
title: Análise Semântica
nav_order: 4
---

# Análise Semântica

O que é:

 - É a terceira fase do front-end de um compilador, ocorre logo seguinte a análise sintática;
 - Diferente do analizador sintático, que análisa a gramática dó código, o analisador semântico verifica o sentido, ou seja, verifica se o código vai conseguir ser compilado e funcionar de forma correta;
- Por ele ser a última linha de "segurança", ele é responsável por detectar todos os erros que foram passados despercibidos pela análise léxica e pela análise sintática;

## Exemplo

um código em C++:

    int x = 0;
    int y = 1;
    String z = x + y;

Esse código passaria tanto pelo léxico quanto pelo sintático, pois os tokens estão certos, a gramática está correta, porém, quando se vai ver a semântica, vai ser verificado que esse código está errado.

Não da para em uma string, você por a soma de dois inteiros(não dessa forma pelo menos);

Para cada linguagem há uma análise semântica diferente, um compilador de C é diferente de um compilador de C++, porém, existem algumas coisas que são usadas em todos os compiladores na parte semântica, mesmo que sejam linguagens diferentes, que são:
- verificar se os identificadores foram declarados antes de serem usados nos cálculos;
- verificar se as palavras-chaves reservadas não estão sendo usadas indevidamente;
- verificar se os tipos estão declarados corretamente, caso a linguagem seja explicitamente tipada;
- verificar se os cálculos são consistentes em termos de tipo, sempre que possível;

---

## Tabela de Símbolos

A **tabela de símbolos** é a estrutura de dados central de toda análise semântica. Ela funciona como um "cadastro" de tudo que foi declarado no programa: variáveis, funções e parâmetros. O analisador semântico consulta essa tabela a cada vez que encontra um identificador no código para verificar se ele existe, qual é o seu tipo e se está sendo usado corretamente.

### Campos da tabela

Cada entrada na tabela guarda as seguintes informações:

| Campo | Tipo | Descrição |
|---|---|---|
| `nome` | string | O nome do identificador exatamente como escrito no código (ex: `x`, `soma`, `resultado`) |
| `categoria` | enum | Se é uma `variavel`, `funcao` ou `parametro` |
| `tipo` | string | O tipo de dado declarado: `int`, `float`, `double`, `bool`, `char`, `void` etc. |
| `nivel_escopo` | inteiro | O nível de aninhamento onde foi declarado (0 = global, 1 = dentro de uma função, 2 = dentro de um bloco `if`/`while`, e assim por diante) |
| `linha_declaracao` | inteiro | A linha do código fonte onde o símbolo foi declarado (útil para mensagens de erro precisas) |
| `inicializada` | booleano | Indica se a variável já recebeu algum valor antes de ser usada |
| `valor_inicial` | string | O valor com que foi inicializada, se houver (pode ser vazio) |
| `tamanho` | inteiro | Relevante para arrays: quantos elementos tem; para variáveis simples é sempre 1 |

### Exemplo prático

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

Observe que `resultado`, `a` e `b` pertencem ao nível de escopo `1` (dentro da função `soma`), enquanto `contador`, `soma` e `main` pertencem ao nível `0` (escopo global).

---

## Gerenciamento de Escopos

O escopo define em que parte do programa um identificador existe e pode ser acessado. O analisador semântico gerencia os escopos usando uma **pilha**: cada vez que entra em um novo bloco `{`, um novo nível é empilhado; quando o bloco `}` é fechado, esse nível é desempilhado e todos os símbolos declarados nele são descartados.

### Como a pilha de escopos funciona

```
Início do programa
└── Escopo 0 (global)
    ├── int contador = 0        → inserido no nível 0
    ├── int soma(...)           → inserido no nível 0
    │   └── Escopo 1 (função soma)
    │       ├── int a           → inserido no nível 1
    │       ├── int b           → inserido no nível 1
    │       └── int resultado   → inserido no nível 1
    │   ← ao fechar }, nível 1 é descartado
    └── int main()              → inserido no nível 0
        └── Escopo 1 (função main)
            ├── float media     → inserido no nível 1
            └── bool aprovado   → inserido no nível 1
        ← ao fechar }, nível 1 é descartado
```

### Erro de escopo — uso fora do bloco

```cpp
int main() {
    int x = 10;
}

int outra() {
    return x + 1;  // ERRO SEMÂNTICO: 'x' não existe aqui
}
```

Quando o analisador encontra `x` dentro de `outra()`, ele consulta a tabela de símbolos. Como `x` foi declarado no nível 1 de `main()` e esse escopo já foi descartado, `x` não existe mais na tabela — erro detectado.

### Sombreamento de variável (variable shadowing)

C++ permite que uma variável interna tenha o mesmo nome de uma variável externa. O analisador sempre usa a declaração mais recente (mais próxima na pilha):

```cpp
int x = 100;   // nível 0

int main() {
    int x = 5; // nível 1 — "cobre" o x global aqui dentro
    return x;  // usa o x do nível 1, que vale 5
}
```

---

## Verificação de Tipos

A verificação de tipos (ou *type checking*) é uma das responsabilidades mais importantes do analisador semântico. Ela garante que as operações feitas no código façam sentido com os tipos de dados envolvidos.

### Tipos de verificação realizadas

**1. Compatibilidade na atribuição**

O tipo do lado direito deve ser compatível com o tipo do lado esquerdo:

```cpp
int x = 3.14;      // ERRO: não dá para atribuir float a int sem conversão
bool b = "texto";  // ERRO: tipos completamente incompatíveis
float f = 10;      // OK: int pode ser promovido para float automaticamente
```

**2. Compatibilidade em operações aritméticas**

Os operandos de uma operação devem ser tipos numéricos compatíveis:

```cpp
int a = 5;
float b = 2.5;
int resultado = a + b;  // AVISO: resultado float sendo truncado para int
```

**3. Retorno de função**

O tipo retornado deve corresponder ao tipo declarado na assinatura:

```cpp
int soma(int a, int b) {
    return 3.14;  // ERRO: função declara retornar int, mas retorna float
}

int calcula() {
    // ERRO: função declara retornar int mas não tem return
}
```

**4. Uso de variável não inicializada**

```cpp
int x;
int y = x + 1;  // AVISO: 'x' foi declarada mas nunca recebeu valor
```

**5. Redeclaração no mesmo escopo**

```cpp
int main() {
    int x = 1;
    int x = 2;  // ERRO: 'x' já foi declarada neste escopo
}
```

### Tabela de compatibilidade de tipos no projeto (C++ → C)

Para o transpilador do grupo, as regras de compatibilidade entre os tipos suportados são:

| Operação | `int` | `float` | `double` | `bool` | `char` |
|---|---|---|---|---|---|
| `int` | ✅ int | ✅ float | ✅ double | ⚠️ aviso | ⚠️ aviso |
| `float` | ✅ float | ✅ float | ✅ double | ❌ erro | ❌ erro |
| `double` | ✅ double | ✅ double | ✅ double | ❌ erro | ❌ erro |
| `bool` | ⚠️ aviso | ❌ erro | ❌ erro | ✅ bool | ❌ erro |
| `char` | ⚠️ aviso | ❌ erro | ❌ erro | ❌ erro | ✅ char |

Legenda: ✅ compatível, ⚠️ conversão implícita com possível perda de dado, ❌ erro semântico

---

## Como ficaria no `parser.y` do projeto

O `parser.y` atual do grupo funciona como um transpilador puro — ele traduz C++ para C sem verificar nenhuma semântica. Para adicionar a análise semântica, a tabela de símbolos seria integrada diretamente nas ações das regras gramaticais já existentes. Veja onde cada verificação se encaixaria:

### 1. Na declaração de variável — `declaracao_var`

Atualmente o código apenas imprime a declaração em C. Com semântica, ele primeiro verificaria se o símbolo já existe no escopo e depois o inseriria na tabela:

```c
declaracao_var:
    tipo TOK_ID TOK_ASSIGN exp TOK_SCOLON {
        // VERIFICAÇÃO: já existe no escopo atual?
        if (buscar_simbolo_no_escopo_atual($2) != NULL)
            yyerror("variável já declarada neste escopo");

        // VERIFICAÇÃO: o tipo da expressão é compatível com o tipo declarado?
        if (!tipos_compativeis($1, tipo_da_exp))
            yyerror("tipos incompatíveis na atribuição");

        // INSERÇÃO: registrar na tabela de símbolos
        inserir_simbolo($2, $1, nivel_atual, yylineno, 1, $4);

        // TRADUÇÃO (já existe hoje):
        print_indent(nivel_atual);
        printf("%s %s = %s;\n", $1, $2, $4);
    }
```

### 2. No uso de identificador em expressão — `exp → TOK_ID`

Atualmente só copia o nome. Com semântica, consulta a tabela antes:

```c
exp:
    TOK_ID {
        // VERIFICAÇÃO: o identificador foi declarado?
        Simbolo *s = buscar_simbolo($1);
        if (s == NULL)
            yyerror("identificador não declarado");

        // VERIFICAÇÃO: foi inicializado antes do uso?
        if (!s->inicializada)
            yyerror("variável usada antes de ser inicializada");

        $$ = strdup($1);
    }
```

### 3. Na declaração de função — `funcao`

Registrar a função na tabela e empilhar um novo escopo:

```c
funcao:
    tipo TOK_ID TOK_LPAREN TOK_RPAREN TOK_LBRACE {
        // INSERÇÃO: registrar função na tabela global
        inserir_simbolo($2, $1, 0, yylineno, 1, NULL);

        // ESCOPO: entrar no escopo da função
        entrar_escopo();

        printf("%s %s() {\n", $1, $2);
        nivel_atual++;
    }
    lista_comandos TOK_RBRACE {
        // ESCOPO: sair do escopo, descartar variáveis locais
        sair_escopo();

        nivel_atual--;
        print_indent(nivel_atual);
        printf("}\n");
    }
```

### 4. No comando `return` — `comando_return`

Verificar se o tipo retornado bate com o tipo da função:

```c
comando_return:
    TOK_RETURN exp TOK_SCOLON {
        // VERIFICAÇÃO: o tipo da expressão retornada é compatível?
        if (!tipos_compativeis(tipo_funcao_atual, tipo_da_exp))
            yyerror("tipo do return incompatível com o tipo da função");

        print_indent(nivel_atual);
        printf("return %s;\n", $2);
    }
```

---

## Resumo do fluxo completo

```
Código C++ de entrada
        ↓
[Léxico]  → quebra em tokens
        ↓
[Sintático] → verifica gramática
        ↓
[Semântico] → consulta e atualiza tabela de símbolos
           → verifica declarações
           → verifica tipos
           → verifica escopos
           → verifica retornos
        ↓
Código C gerado (se sem erros)
```

---

## Bibliografia

- [What is Semantic Analysis in Compilers?](https://pgrandinetti-github-io.translate.goog/compilers/page/what-is-semantic-analysis-in-compilers/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc)
- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
