---
title: Exemplos de Erros Semânticos
parent: Análise Semântica
nav_order: 1
---

# Exemplos de Erros Semânticos

Abaixo estão listados os cenários reais de erros semânticos tratados de forma estrita pelo nosso compilador, capturados durante o processo de inferência e validação da árvore sintática anotada.

## Incompatibilidade de Tipos na Atribuição

Ocorre quando tentamos associar valores entre variáveis cujos tipos primitivos não são mapeados como compatíveis pela rotina de checagem.

```cpp
int x = 0;
bool aprovado = true;
x = aprovado; // Erro Semântico
```

* **Comportamento do Compilador:** A função verificar_atribuicao_ok("int", "bool") retornará falso, disparando uma mensagem de incompatibilidade de tipos via stderr e ativando a flag erro_semantico_detectado = true, abortando a geração final de binários.

## Uso de Variável Não Declarada

```cpp
int main() {
    return x + 1;
}
```

**Comportamento do Compilador:** Durante a redução da regra de expressões aritméticas, o Bison invoca buscarSimbolo("valor", nivel_atual). Como a função retorna um ponteiro nulo (NULL), o erro é impresso imediatamente indicando a linha do desvio.

## Redeclaração de Variável no Mesmo Escopo

A linguagem aceita redefinições de identificadores em escopos diferentes (shadowing), mas barra categoricamente a criação de duas variáveis de mesmo nome sob o mesmo bloco lógico.

```cpp
int main() {
    int x = 1;
    float x = 5.5; // Erro Semântico!
}
```

**Comportamento do Compilador:** Ao tentar processar a segunda linha, a função inserirSimbolo encontra um registro correspondente a x onde s->escopo == escopo. O compilador interrompe a execução sumariamente imprimindo: "Erro Semântico: símbolo 'x' já declarado neste escopo.".

## Retorno Incompatível com a Assinatura da Função

Ocorre quando uma função declara que vai retornar um determinado tipo em sua assinatura, mas a expressão contida na instrução return avalia para um tipo conflitante.

```cpp
int calcular() {
    return true; // Erro Semântico!
}
```

**Comportamento do Compilador:** Ao iniciar o parsing da função, o tipo "int" é salvo na variável global tipo_retorno_atual. Quando o comando_return é avaliado, o Type Checker confronta tipo_retorno_atual com o tipo_inferido da expressão ("bool"), travando a compilação por inconsistência.

## Condição de Controle Não Booleana

As estruturas de controle condicional e de repetição exigem um predicado lógico para guiar as decisões de desvio em baixo nível no TAC.

```cpp
int main() {
    int saldo = -50;
    while (saldo) { // Erro Semântico!
        saldo += 10;
    }
}
```

**Comportamento do Compilador:** Nas regras comando_if, comando_while e comando_do_while, o compilador insere uma barreira explícita verificando se $3->tipo_inferido != "bool". No caso acima, como o saldo é "int", o transpilador emite um erro alertando que a condição deve ser estritamente booleana.

## Variável não inicializada antes do uso

```cpp
int x;
int y = x + 1;
```

`x` foi declarada mas nunca recebeu um valor. Usar uma variável não inicializada é um comportamento indefinido em C++, então o analisador semântico lança um aviso (ou erro, dependendo da implementação).

## Bibliografia:

- https://pgrandinetti-github-io.translate.goog/compilers/page/what-is-semantic-analysis-in-compilers/?_x_tr_sl=en&_x_tr_tl=pt&_x_tr_hl=pt&_x_tr_pto=tc
- Aho, A. V.; Lam, M. S.; Sethi, R.; Ullman, J. D. **Compiladores: Princípios, Técnicas e Ferramentas** (Livro do Dragão). 2ª ed. Pearson, 2008.
