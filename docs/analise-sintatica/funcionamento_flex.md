---
title: Estrutura e Funcionamento do Flex
parent: Análise Léxica
nav_order: 2
---

# Estrutura e Funcionamento do Flex

Para a implementação do nosso analisador léxico, utilizamos a ferramenta clássica **Flex** (Fast Lexical Analyzer Generator). O Flex recebe como entrada um arquivo de especificação estruturado (`scanner.l`) contendo regras baseadas em Expressões Regulares (Regex) e gera como saída um arquivo de código-fonte em C padrão (`lex.yy.c`) contendo a máquina de estados responsável pelo escaneamento.

## Estrutura do Arquivo `scanner.l`

O arquivo de configuração do Flex é dividido formalmente em três seções delimitadas pelo caractere especial `%%`:

### 1. Seção de Definições e Cabeçalho
Localizada no topo do arquivo, delimitada por `%` e `%}`, serve para incluir bibliotecas da linguagem C/C++ (como `<stdio.h>` e `<string.h>`), importar o arquivo de tokens gerado pelo Bison (`parser.tab.h`) e declarar variáveis globais de controle. É aqui também que ativamos diretivas do Flex, tais como:
* `%option yylineno`: Gerencia automaticamente o incremento do contador de linhas a cada caractere `\n` encontrado.
* `%option noyywrap`: Dispensa a necessidade de linkar a biblioteca padrão do Flex (`-lfl`), simplificando o processo de build multiplataforma.

### 2. Seção de Regras Léxicas
É o núcleo do analisador léxico. Consiste em uma tabela onde o lado esquerdo define o padrão textual por meio de uma Expressão Regular e o lado direito define a ação em C/C++ associada. 

Quando uma cadeia de caracteres casa com a Regex, a ação correspondente é executada imediatamente. Por exemplo:
```c
"while"         { coluna += yyleng; return TOK_WHILE; }
```

### 3. Código do Usuário
Localizado após o último %%, permite escrever funções auxiliares em C. No nosso projeto, esta seção é mantida limpa, deixando que a função principal main() seja gerenciada centralizadamente pelo módulo sintático.

## Engenharia de Contagem de Linhas e Colunas

Para que o compilador consiga apontar a localização exata de falhas, o scanner realiza um controle rigoroso de posicionamento geométrico através das variáveis yylineno (nativa do Flex) e coluna (gerenciada manualmente por nós):

1. **Inicialização:** O programa inicia com coluna = 1.

2. **Consumo de Caracteres:** Sempre que um token comum é casado, incrementamos a coluna utilizando a macro yyleng, que armazena o tamanho exato da cadeia de texto consumida:
```c
coluna += yyleng;
```

3. **Quebra de Linha:** Ao encontrar o caractere \n, a variável yylineno incrementa-se automaticamente e nós resetamos o cursor de colunas de volta para o início:
```c
\n    { coluna = 1; }
```

## Tratamento Avançado de Comentários em Bloco

Comentários de linha única são descartados de forma simples ignorando o fluxo. No entanto, comentários em bloco (/* ... */) exigem uma máquina de estados simplificada usando a função nativa yyinput() para consumir caracteres continuamente até encontrar o fechamento legítimo, garantindo o ajuste correto das colunas e linhas durante o salto:

```c
"/*" { 
    int c;
    while((c = yyinput()) != 0 && c != EOF) {
        if(c == '*') {
            if((c = yyinput()) == '/') break;
            else unput(c);
        }
        else if(c == '\n') coluna = 1;
        else coluna++;
    }
}
```