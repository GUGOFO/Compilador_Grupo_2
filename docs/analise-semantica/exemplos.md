---
title: Exemplos de Erros Semânticos
parent: Análise Semântica
nav_order: 1
---

# Exemplos de Erros Semânticos

Abaixo estão alguns exemplos de erros que passam pelo léxico e pelo sintático sem problema, mas são pegos pelo analisador semântico.

## Incompatibilidade de tipos na atribuição

um código em C++:

```cpp
int x = 0;
int y = 1;
String z = x + y;
```

Esse código passaria tanto pelo léxico quanto pelo sintático, pois os tokens estão certos e a gramática está correta, porém, quando se vai ver a semântica, vai ser verificado que esse código está errado.

Não da para colocar em uma `String` a soma de dois inteiros (não dessa forma pelo menos). O analisador semântico verifica que o tipo do lado direito (`int`) é incompatível com o tipo declarado no lado esquerdo (`String`) e lança um erro.

## Variável não declarada

```cpp
int main() {
    return x + 1;
}
```

O token `x` é um identificador válido pro léxico e a expressão `return x + 1` é gramaticalmente correta pro sintático. Mas o semântico vai consultar a tabela de símbolos, não vai encontrar nenhuma declaração de `x` e vai lançar o erro.

## Redeclaração no mesmo escopo

```cpp
int main() {
    int x = 1;
    int x = 2;
}
```

Declarar `x` duas vezes no mesmo bloco é um erro semântico. O analisador vê que `x` já existe na tabela de símbolos com o mesmo nível de escopo e rejeita a segunda declaração.

## Uso fora do escopo

```cpp
int main() {
    int x = 10;
}

int outra() {
    return x + 1;
}
```

`x` foi declarado dentro de `main()` e só existe enquanto `main()` está em execução. Quando `outra()` tenta usar `x`, ele não está mais na tabela de símbolos — o escopo de `main()` já foi encerrado.

## Retorno incompatível com o tipo da função

```cpp
int soma(int a, int b) {
    return 3.14;
}
```

A função declara retornar `int`, mas o valor de retorno é `float`. O analisador semântico verifica se o tipo da expressão no `return` é compatível com o tipo declarado na assinatura da função.

## Variável não inicializada antes do uso

```cpp
int x;
int y = x + 1;
```

`x` foi declarada mas nunca recebeu um valor. Usar uma variável não inicializada é um comportamento indefinido em C++, então o analisador semântico lança um aviso (ou erro, dependendo da implementação).
