---
title: Mapeamento de Tokens
parent: Análise Léxica
has_children: true
nav_order: 2
---

# Mapeamento e Definição dos Tokens

Nesta seção, detalhamos a especificação técnica de todos os elementos léxicos que nosso compilador é capaz de reconhecer. O mapeamento foi estruturado para servir como um guia direto de implementação para a ferramenta Flex.

1. **[Palavras Reservadas](./1_palavras_reservadas.md)**: Lista de termos protegidos da linguagem C++ e seus tokens associados (ex: int, if, cout).
2. **[Identificadores](./2_identificador.md)**: Regras de formação e nomenclatura para nomes de variáveis e funções (TOK_ID).
3. **[Literais](./3_literais.md)**: Definição de constantes numéricas, cadeias de texto e caracteres.
4. **[Operadores e Pontuação](./4_Operadores_Pontuação.md)**: Mapeamento de símbolos matemáticos, lógicos e delimitadores estruturais.
5. **[Tabela de Símbolos](./5_tabela_de_simbulos.md)**: Estrutura dinâmica para armazenamento de metadados dos identificadores durante a execução.
6. **[Atributos e yylval](./6_atributos_de_token.md)**: Gestão dos valores semânticos passados do scanner para o parser.
7. **[Tratamento de Erros](./7_tratamento_de_erros.md)**: Protocolos de detecção e reporte de caracteres inválidos no fluxo de entrada.

Selecione uma categoria no menu ao lado para ver os detalhes técnicos e tokens associados.