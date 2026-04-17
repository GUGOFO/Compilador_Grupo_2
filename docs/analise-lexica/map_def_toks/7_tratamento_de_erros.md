---
title: 7 - Tratamento de Erros
parent: Mapeamento de Tokens
nav_order: 7
---

# Tratamento de Erros Léxicos

O analisador léxico é a "primeira linha de defesa" do compilador. Ele deve ser capaz de identificar caracteres ou sequências que não pertencem ao alfabeto da linguagem C++ ou que violam as regras de formação de tokens. 

## 7.1 - O que é um Erro Léxico?

Um erro léxico ocorre quando o fluxo de entrada contém um caractere que não pode ser associado a nenhum token válido definido no mapeamento. 
* **Exemplos comuns:** Símbolos como `@`, `$`, ou `§` fora de strings, ou números mal formados que não encaixam nas regex de inteiros ou floats.



## 7.2 - Requisitos do Analisador

Para que o erro seja útil ao desenvolvedor, o scanner deve fornecer informações precisas para a correção:
* **Mensagem Clara:** Explicar que um caractere inesperado foi encontrado.
* **Localização:** Informar exatamente a **linha** e a **coluna** onde o erro ocorreu.
* **Interrupção:** Conforme definido no planejamento inicial, o sistema deve parar a análise ao encontrar uma falha crítica.

## 7.3 - Implementação Técnica (A Regra "Pega-Tudo")

No Flex, implementamos o tratamento de erros através de uma regra especial colocada ao **final** da seção de regras. Essa regra utiliza o caractere curinga `.` (ponto), que captura qualquer caractere que não tenha sido reconhecido pelas regras anteriores.

```c
. { 
    printf("Erro Léxico na linha %d: Caractere inesperado '%s'\n", yylineno, yytext);
    exit(1); 
}
```

## 7.4 - Relação com Outras Fases
É importante notar que o analisador léxico tem uma visão limitada. Ele não consegue detectar erros de lógica ou de sentido.

- **Erros Sintáticos:** São detectados pela próxima fase (Bison) quando os tokens estão certos, mas na ordem errada.

- **Erros Semânticos:** São detectados na terceira fase, como quando tentamos somar tipos incompatíveis (ex: String z = x + y).

O tratamento de erros léxicos garante que apenas "peças" legítimas cheguem às fases subsequentes do front-end do compilador.