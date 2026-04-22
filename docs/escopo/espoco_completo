---
title: Escopo Completo
parent: Escopo do Compilador
nav_order: 1
---

# Escopo Completo

Dentro desse documento esta todo o escopo do nosso compilador de C++ -> C, ele se restringira em funcionalidades, ou seja, oque ele consegue e não consegue compilar da primeira para segunda linguagem, entre em alguma ava de analise caso queira ver as tecnologias usadas.

## Dentro do Escopo

A seguir estão todas as funcionalidades que, ao final da vida util do projeto, o compilador conseguira realizar

### Tipos Primitivos

- int
- bool
- void
- char

### Inicialização / declaração


```c++
int x;
```

```c++
int x = 10;
```

Esses são alguns exemplos, porem esse int pode ser substituido por qualquer um dos tipos primitivos vistos anteriormente, desde que o tipo do valor esteja correto

### Escopo

Diferenciação de variaveis globais, local e bloco.

A seguir mostro exemplo dos 3 respectivamente:

```c++
int global;

int main(){
    global = 1;
    return 0;
}
```

```c++
int main(){
    int local = 0;
    local = 1;
    return 0;
}
```

```c++
int main(){
    
    if(1 = 1){
        int bloco = 0;
        bloco = 1;
    }

    return 0;
}
```

### Entradas e Saidas

- **Saidas**

No c++, utilizamos cout, ele pode ser usado em nosso compilador:

```c++
std::cout << "Oi";

int idade = 10
std::cout << idade;
```
- **Saidas**

No c++, utilizamos cin, ele pode ser usado em nosso compilador:

```c++
int idade;
std::cin >> idade;

```

### Operadores Aritimeticos

- "+"
- "-"
- "*"
- "/"
- "%"

Um exemplo de usabilidade no meio do codigo:

```c++
int x = 2;
int y = 10;
int z = x + y;
```

Esse operador no pode ser substituido por qualquer um dos vistos anteriormente

### Operadores Logicos / Relacionais

- ==
- !=
- <
- ">"
- <=
- ">="

Um exemplo de usabilidade no meio do codiho

```c++
int x = 2;
int y = 10;

if(int x == y){
    x = 3;
}
```

Esse operador no pode ser substituido por qualquer um dos vistos anteriormente

### Agrupamento

Utiliza parenteses para dar prioridade a conta

Um exemplo de usabilidade no meio do codiho

```c++
if( ( 2 - 3 ) * 4 == -4 ){
    std::cout << "Correto";
}
```

