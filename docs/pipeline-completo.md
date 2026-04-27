---
title: Pipeline Completo do Compilador
nav_order: 5
---

# Pipeline Completo do Compilador

Esse documento explica o que foi feito no projeto até agora, passando pelas três fases do front-end do compilador: análise léxica, análise sintática e análise semântica. O compilador do grupo é na verdade um **transpilador** — ele lê código C++ e gera código C equivalente.

O fluxo completo é esse:

```
código C++ de entrada
        ↓
[Análise Léxica] — scanner.l (Flex)
        ↓ tokens
[Análise Sintática] — parser.y (Bison)
        ↓ árvore gramatical + ações
[Análise Semântica] — (a ser implementada no parser.y)
        ↓
código C gerado na saída padrão
```

---

## 1. Análise Léxica — `scanner.l`

É a primeira fase. O Flex lê o código-fonte caractere por caractere e agrupa eles em **tokens** — as unidades mínimas com significado.

### Como o Flex funciona

Cada regra do `scanner.l` tem o formato `padrão { ação }`. O Flex sempre casa o **padrão mais longo** possível, e em caso de empate usa a regra que aparece primeiro no arquivo. Por isso a ordem importa:

- palavras reservadas vêm **antes** dos identificadores — senão `int` seria lido como nome de variável
- operadores de 2 caracteres vêm **antes** dos de 1 caractere — senão `==` seria lido como dois `=`

### O que o léxico reconhece

**Espaços e comentários** — ignorados sem gerar token:
```
"/*" ... */    consome o bloco inteiro
"//".* ;       ignora o resto da linha
[ \t\r\n]      ignora espaço, tab, quebra de linha
```

**Palavras reservadas** — 28 keywords do C++, cada uma com seu token:
```
"int"    → TOK_INT       "if"     → TOK_IF
"float"  → TOK_FLOAT     "while"  → TOK_WHILE
"bool"   → TOK_BOOL      "for"    → TOK_FOR
"void"   → TOK_VOID      "return" → TOK_RETURN
"cout"   → TOK_COUT      "cin"    → TOK_CIN
"std"    → TOK_STD       ...
```

**Operadores de 2 caracteres** — declarados antes dos de 1 para não serem lidos pela metade:
```
"+="  → TOK_ADD_ASSIGN    "=="  → TOK_EQ
"<<"  → TOK_OUT           "!="  → TOK_NEQ
">>"  → TOK_IN            "<="  → TOK_LE
"::"  → TOK_SCOPE         "&&"  → TOK_LOGIC_AND
```

**Operadores de 1 caractere** — pontuação e operadores simples:
```
"+"  → TOK_PLUS    ";"  → TOK_SCOLON
"-"  → TOK_MINUS   "("  → TOK_LPAREN
"*"  → TOK_MULT    "{"  → TOK_LBRACE
"/"  → TOK_DIV     "["  → TOK_LBRACKET
"="  → TOK_ASSIGN
```

**Literais** — usam expressões regulares e salvam o valor em `yylval`:

| Padrão | O que reconhece | Token |
|---|---|---|
| `[0-9]*\.[0-9]+` | float: `3.14`, `.5` | `TOK_FLOAT_LIT` |
| `[0-9]+` | inteiro: `42`, `0` | `TOK_INT_LIT` |
| `\"([^"\\\n]\|\\.) *\"` | string: `"oi"` | `TOK_STRING_LIT` |
| `'(\\.\|[^\\'])'` | char: `'a'`, `'\n'` | `TOK_CHAR_LIT` |

**Identificadores** — nomes de variáveis e funções:
```
[a-zA-Z_][a-zA-Z0-9_]*  →  TOK_ID
```
Começa com letra ou `_`, seguido de letras, dígitos e `_`. O nome é salvo em `yylval.sval`.

**Erros léxicos** — qualquer caractere não reconhecido cai na regra `.` (a última), que imprime:
```
Erro Léxico na linha 3, coluna 5: caractere '@' inválido
```

O léxico também rastreia linha (`yylineno`, via `%option yylineno`) e coluna (`coluna`, atualizada manualmente a cada regra) pra essas mensagens de erro.

---

## 2. Análise Sintática — `parser.y`

É a segunda fase. O Bison recebe os tokens do Flex e verifica se a sequência deles segue a gramática do compilador. Se seguir, executa as **ações** de cada regra — que no caso do projeto geram o código C equivalente.

O Bison usa a estratégia **LALR(1)**: lê os tokens um por vez, olha 1 token à frente, e decide qual regra aplicar com base no que já viu.

### Precedência de operadores

Declarada no início do `parser.y`, define qual operador é calculado primeiro em expressões ambíguas:

```
%left  TOK_LOGIC_OR                         menor precedência
%left  TOK_LOGIC_AND
%left  TOK_EQ  TOK_NEQ
%left  TOK_LT  TOK_GT  TOK_LE  TOK_GE
%left  TOK_PLUS  TOK_MINUS
%left  TOK_MULT  TOK_DIV  TOK_MOD
%right TOK_LOGIC_NOT                        maior precedência
```

Sem isso, `2 + 3 * 4` poderia ser interpretado como `(2 + 3) * 4` em vez de `2 + (3 * 4)`.

### As regras gramaticais e o que elas geram

**`programa`** — ponto de entrada, uma lista de declarações no topo do arquivo

**`funcao`** — reconhece `tipo nome() { ... }` e gera o cabeçalho da função em C:
```cpp
// entrada C++          // saída C gerada
int main() {      →     int main() {
    ...                     ...
}                       }
```

**`tipo`** — os tipos aceitos: `int`, `float`, `double`, `bool`, `void`, `char`, `long`, `short`

**`declaracao_var`** — variável com ou sem inicialização:
```cpp
// entrada C++              // saída C gerada
int x = 5;          →      int x = 5;
float y;            →      float y;
```

**`comando_cout`** — traduz `std::cout <<` para `printf`:
```cpp
// entrada C++                  // saída C gerada
std::cout << "oi";      →       printf("oi");
std::cout << x;         →       printf("%g\n", x);
```

**`comando_cin`** — traduz `std::cin >>` para `scanf`:
```cpp
// entrada C++          // saída C gerada
std::cin >> x;    →     scanf("%g", &x);
```

**`comando_return`** — `return exp;` é traduzido direto pra C

**`exp`** — expressões aritméticas e de comparação, montadas como texto via `sprintf`:
```cpp
a + b        →   "a + b"
a * (b + c)  →   "a * (b + c)"
x == 0       →   "x == 0"
```

### Erros sintáticos

Se a sequência de tokens não encaixar em nenhuma regra, o Bison chama `yyerror`:
```
Erro de Sintaxe na linha 3: syntax error (perto de '=')
```

O sintático rejeita código como:
```cpp
int = 5;            sem nome de variável
int main { }        sem parênteses na função
x = 5;              atribuição simples (não está nas regras)
if (x > 0) { }      if não implementado ainda
```

### O que o `main()` do parser faz

Antes de iniciar o parsing, imprime os headers necessários pro código C gerado:
```c
#include <stdio.h>
#include <stdbool.h>
```
Depois chama `yyparse()`, que dispara todo o processo.

---

## 3. Análise Semântica

É a terceira fase — a que verifica o **sentido** do código, não só a forma. Diferente das duas anteriores, ela ainda **não foi implementada** no código do projeto. O `parser.y` atual é um transpilador puro: se o código passa no sintático, ele gera o C sem nenhuma verificação adicional.

### O que precisaria ser implementado

A análise semântica seria integrada diretamente nas ações das regras gramaticais do `parser.y`, junto com uma **tabela de símbolos** — uma estrutura que registra tudo que foi declarado no programa.

**Verificação de declaração antes do uso** — toda vez que um `TOK_ID` aparece numa expressão, consulta a tabela pra ver se ele foi declarado:
```cpp
int main() {
    return x + 1;   // ERRO: x nunca foi declarado
}
```

**Verificação de redeclaração** — ao declarar uma variável, verifica se ela já existe no mesmo escopo:
```cpp
int main() {
    int x = 1;
    int x = 2;   // ERRO: x já foi declarada aqui
}
```

**Verificação de tipos** — verifica se os tipos dos dois lados de uma atribuição são compatíveis:
```cpp
int x = 0;
int y = 1;
String z = x + y;   // ERRO: não dá pra atribuir int a String
```

**Verificação de escopo** — variáveis declaradas dentro de um bloco `{}` não existem fora dele:
```cpp
int main() {
    int x = 10;
}
int outra() {
    return x + 1;   // ERRO: x não existe aqui
}
```

**Verificação de retorno** — o tipo do `return` deve bater com o tipo declarado na função:
```cpp
int soma(int a, int b) {
    return 3.14;   // ERRO: função retorna int, não float
}
```

---

## Resumo do que foi feito

| Fase | Ferramenta | Arquivo | Status |
|---|---|---|---|
| Análise Léxica | Flex | `src/scanner.l` | ✅ implementado |
| Análise Sintática | Bison | `src/parser.y` | ✅ implementado |
| Análise Semântica | — | a ser adicionado ao `src/parser.y` | 🔲 pendente |

O transpilador já consegue ler um subconjunto de C++ com funções, variáveis, `cout`, `cin` e expressões aritméticas, e gerar o código C equivalente. A análise semântica seria o próximo passo para detectar erros de tipo e de escopo antes de gerar a saída.
