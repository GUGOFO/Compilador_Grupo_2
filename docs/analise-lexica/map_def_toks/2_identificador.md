---
title: 2 - Identificadores
parent: Mapeamento de Tokens
nav_order: 2
---

# 2 - Identificadores

Os identificadores representam os nomes definidos pelo programador para dar identidade a elementos do código, como variáveis, funções e namespaces. No nosso projeto, utilizaremos um rótulo genérico para todos eles.

## 2.1 - Tabela de Nomeclatura

| Categoria | Token | Descrição |
| :--- | :--- | :---: |
| Identificadores | TOK_ID | Nomes de variáveis, funções, namespaces e tipos definidos pelo usuário. |

## 2.2 - Regras de Formatação

Para que um conjunto de caracteres seja considerado um TOK_ID, ele deve seguir o padrão léxico do C++, que exige que o nome comece obrigatoriamente com uma letra (maiúscula ou minúscula) ou um caractere de sublinhado (_).

- **Exemplos Validos:** MinhaVariabel, soma_valores, std, main, _contador...

- **Padrão Regex:** [a-zA-Z_][a-zA-Z0-9_]*

**Nota:** Identificadores que coincidam com palavras reservadas (como int ou while) serão capturados primeiro pelas regras de palavras reservadas e não como TOK_ID.

## 2.3 - Integração com a Tabela de Símbolos

Diferente dos outros tokens, sempre que o analisador léxico encontrar um TOK_ID, ele deverá realizar uma ação adicional:

1. **Verificação:** Consultar a Tabela de Símbolos para ver se o nome já existe.

2. **Armazenamento:** Se for um nome novo, ele deve ser inserido na tabela junto com seu valor semântico (yytext).

3. **Atributo:** O valor do nome será passado para o analisador sintático através da variável
