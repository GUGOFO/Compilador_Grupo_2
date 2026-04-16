---
title: Planejamento
parent: Análise Léxica
nav_order: 2
---

# Planejamento do Analizador Lexico

Este documento estabelece o roteiro técnico para a implementação do analisador léxico. O objetivo é transformar o fluxo de caracteres do código-fonte C++ em uma sequência de unidades lógicas denominadas Tokens.

## 1 - Mapeamento e Definição dos Tokens

O primeiro paço é listar tudo o que a linguagem C++ possui que precisa ser identificado (Claro, que esteja no nosso escopo da disciplina)

### 1.1 - Palavras Reservadas: 

São termos protegidos pela linguagem que possuem significado gramatical específico:

- **Tipos de Dados:** TOK_INT (int), TOK_FLOAT (float), TOK_DOUBLE (double), TOK_BOOL (bool), TOK_VOID (void).

- **Controle de Fluxo:** TOK_IF (if), TOK_ELSE (else), TOK_WHILE (while), TOK_FOR (for), TOK_RETURN (return).

- **C++ Específicos (Subconjunto):** TOK_COUT (cout), TOK_CIN (cin), TOK_TRUE (true), TOK_FALSE (false)

### 1.2 - Identificadores:

Nomes definidos pelo programador para variáveis, funções e namespaces.

- **Exemplos:** MinhaVariabel, soma_valores, std, main...
- **Nomeclatura:** TOK_ID

### 1.3 - Literais:

Valores fixos escritos diretamente no código.

- **Integer Literals:** 10, 42, 0. (TOK_INT_LIT)

- **Float Literals:** 3.14, 0.5, 2.0. (TOK_FLOAT_LIT)

- **String Literals:** "Olá Mundo", "Resultado: ". (TOK_STRING_LIT)

- **Char Literals:** 'a', '\n'. (TOK_CHAR_LIT)

### 1.4 - Operadores e Pontuação:

Símbolos que realizam operações matemáticas ou lógicas.

- **Aritméticos:** +, -, *, /, %.

- **Atribuição:** =, +=, -=.

- **Relacionais:** ==, !=, <, >, <=, >=.

- **Lógicos:** &&, ||, !.

- **C++ Stream:** << (Inserção), >> (Extração).

### 1.5 - Punctuators (Pontuadores/Símbolos Especiais)

Símbolos de pontuação e delimitação de blocos.

- **Delimitadores:** (, ), {, }, [, ].

- **Terminadores/Separadores:** ;, ,, ..

- **Escopo:** :: (Scope Resolution).

## 2 - Especificação de Padrões

Para o reconhecimento via Flex, utilizaremos padrões de Regex. Abaixo os principais:

| Token           | Expressão Regular        | Descrição                                                     |
|-----------------|--------------------------|---------------------------------------------------------------|
| Identifier      | `[a-zA-Z_][a-zA-Z0-9_]*` | Começa com letra/underscore, seguido de alfanuméricos.        |
| Int Literal     | `[0-9]+`                 | Sequência de um ou mais dígitos.                              |
| Float Literal   | `[0-9]*\.[0-9]+`         | Dígitos opcionais, ponto, seguidos de dígitos obrigatórios.   |
| String          | `"([^"\n]*)"`            | Cadeia entre aspas, sem quebra de linha.                      |
| Comment (Line)  | `\/\/.*`                 | Ignora tudo após `//` até o fim da linha.                     |

## 3 - Implementação com Flex (.l)

Iremos usar um arquivo .l para isso (como o professor pediu)

**Estrutura basica do arquivo Flex:**

- **Definições:** Inclusão de <stdio.h>, definição de contadores de linha e colunas.
- **Regras:** Tabela de Regex vinculada a ações (ex: return TOK_IF;).
- **Codigo do Usuário:** Implementação de funções como main (para teste unitário do léxico) ou auxiliares de erro.

## 4 - Gerenciamento de Espaços e Comentários

O analizador precisa saber ignorar:

- Espaços em brancos: Serão descartados
- Comentarios: Serão descartados

## 5 - Tabela de Simbolos

Integrada ao scanner, a Tabela de Símbolos armazenará metadados dos identificadores.

- **Função:** Evitar duplicidade e preparar a fase semântica.

- **Ação:** Ao encontrar um TOK_ID, o scanner verifica se ele já existe na tabela. Se não, insere os dados iniciais (nome, escopo presumido).

## 6 - Gestão de Atributos e Valor do Token

Utilizaremos a variável global yylval (comumente uma union) para passar informações ao parser:

- **Para TOK_INT_LIT:** yylval.ival = atoi(yytext);

- **Para TOK_ID:** yylval.sval = strdup(yytext);

## 7 - Tratamento de Erros Léxicos

Um analisador precisa lidar com entradas inválidas. Se o usuário digitar um símbolo que não pertence ao C++ (como um caractere Unicode inválido ou um @ fora de uma string), o scanner deve.

- Emitir uma mensagem de erro clara
- Informar a linha e a coluna do erro
- Parar a analise

