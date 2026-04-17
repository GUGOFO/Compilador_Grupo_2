---
title: Tabela de Símbolos
parent: Mapeamento de Tokens
nav_order: 5
---

# Tabela de Símbolos

A Tabela de Símbolos é uma estrutura de dados dinâmica utilizada pelo compilador para armazenar informações sobre os identificadores ( TOK_ID ) encontrados no código-fonte. Ela funciona como um banco de dados temporário que auxilia as fases de análise semântica e geração de código.

## 5.1 - Funções Principais

A tabela desempenha papéis cruciais para garantir que o código faça sentido:
* **Verificação de Existência:** Conferir se uma variável foi declarada antes de ser usada.
* **Gerenciamento de Escopo:** Diferenciar variáveis com o mesmo nome em blocos diferentes (ex: variáveis locais vs. globais).
* **Armazenamento de Metadados:** Guardar o tipo da variável, endereço de memória e escopo.



## 5.2 - Estrutura da Tabela (Exemplo de Dados)

Sempre que o Analisador Léxico identifica um TOK_ID, a tabela é consultada ou atualizada com os seguintes campos:

| Nome (ID) | Tipo | Escopo | Linha | Endereço (Offset) |
| :--- | :--- | :--- | :--- | :--- |
| x | int | global | 10 | 0x001 |
| minha_func | void | global | 15 | 0x005 |
| contador | float | local | 18 | 0x009 |

## 5.3 - Interação com o Analisador Léxico

Diferente de tokens fixos como o TOK_IF, o processamento de um identificador exige lógica extra no arquivo .l:

1. **Encontro:** O Flex identifica uma cadeia que casa com a regex [a-zA-Z_][a-zA-Z0-9_]*.
2. **Busca:** O programa pesquisa na Tabela de Símbolos pelo texto contido em yytext.
3. **Decisão:**
   - **Se já existe:** Retorna o ponteiro/índice da entrada existente.
   - **Se não existe:** Cria uma nova entrada, armazena o nome e retorna o novo índice.
4. **Repasse Semântico:** O valor textual (nome da variável) é passado para a próxima fase através de yylval.sval = strdup(yytext).

---

## 5.4 - Importância para o Transpiler C++ -> C

Como nosso objetivo é a tradução de linguagens, a Tabela de Símbolos será nossa maior aliada para resolver conflitos:
* **Namespaces:** Se o código usa std::cout, a tabela ajuda a entender que cout pertence ao escopo std.
* **Renomeação:** Se houver conflitos de nomes que o C não suporta, podemos usar a tabela para renomear variáveis internamente durante a geração do código C final.