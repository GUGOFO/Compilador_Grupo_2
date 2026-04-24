---
title: Análise Semântica
nav_order: 4
has_children: true
---

# Análise Semântica

O que é:

 - É a terceira fase do front-end de um compilador, ocorre logo seguinte a análise sintática;
 - Diferente do analizador sintático, que análisa a gramática dó código, o analisador semântico verifica o sentido, ou seja, verifica se o código vai conseguir ser compilado e funcionar de forma correta;
- Por ele ser a última linha de "segurança", ele é responsável por detectar todos os erros que foram passados despercibidos pela análise léxica e pela análise sintática;

Para cada linguagem há uma análise semântica diferente, um compilador de C é diferente de um compilador de C++, porém, existem algumas coisas que são usadas em todos os compiladores na parte semântica, mesmo que sejam linguagens diferentes, que são:
- verificar se os identificadores foram declarados antes de serem usados nos cálculos;
- verificar se as palavras-chaves reservadas não estão sendo usadas indevidamente;
- verificar se os tipos estão declarados corretamente, caso a linguagem seja explicitamente tipada;
- verificar se os cálculos são consistentes em termos de tipo, sempre que possível;

## Bibliografia:

https://pgrandinetti-github-io.translate.goog/compilers/page/what-is-semantic-analysis-in-compilers/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc
