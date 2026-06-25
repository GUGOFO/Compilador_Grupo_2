---
title: Análise Sintática
nav_order: 3
has_children: true
---

# Análise Sintática

É a segunda fase do front-end de um compilador, ocorrendo logo após a análise léxica e precedendo a análise semântica. O analisador sintático verifica a estrutura e a organização hierárquica dos tokens com base nas regras gramaticais. É o módulo responsável por validar se a "frase" escrita pelo programador faz sentido estrutural e por construir a Árvore de Sintaxe Abstrata (AST), que servirá de base para a tradução e otimização do código.

Para cada linguagem há uma gramática livre de contexto (GLC) específica. No nosso transpilador de C++ para C (desenvolvido com a ferramenta Bison), o analisador sintático possui responsabilidades fundamentais para o ecossistema do compilador, que são:
 - Verificar se a sequência de tokens obedece estritamente à ordem exigida pela sintaxe da linguagem;
 - Agrupar expressões matemáticas, lógicas e comandos em estruturas aninhadas válidas;
 - Impor restrições de escopo do projeto;
 - Capturar e reportar erros de sintaxe imediatamente através da rotina `yyerror`, abortando o pipeline de compilação em caso de falhas impeditivas;
 - Instanciar e conectar os nós da AST para que as fases posteriores consigam mapear as variáveis, fluxos de controle e realizar a geração do código C correspondente.