---
title: Estrutura e Funcionamento do TAC
parent: Geração de Código Intermediário (TAC)
nav_order: 2
---

# Estrutura e Funcionamento do TAC

A geração do Código de Três Endereços (TAC) no nosso projeto é realizada de forma polimórfica: cada classe que compõe os nós da nossa AST (`ast.hpp`) herda e implementa obrigatoriamente o método virtual `gerarTAC()`. Ao caminhar recursivamente sobre a árvore, o compilador lineariza os comandos e emite as instruções correspondentes.

## A Infraestrutura do `GeradorTAC`

Para garantir a unicidade de todas as variáveis e desvios gerados, o compilador encapsula a classe estática `GeradorTAC`, encarregada de gerenciar dois contadores incrementais indexados por string:
* **Variáveis Temporárias (`t0`, `t1`, `t2`...):** Criadas automaticamente através do método `novo_temporario()` sempre que uma expressão matemática ou lógica intermediária precisa armazenar um resultado flutuante em memória.
* **Rótulos de Desvio (`L0`, `L1`, `L2`...):** Criados através do método `nova_label()` para demarcar os destinos de saltos lógicos e pontos de ancoragem para o controle de fluxo.

---

## Mapeamento de Instruções Estruturadas

O compilador traduz a semântica de C++ de alto nível para os seguintes padrões literais de instruções de três endereços impressas no `stderr`:

### 1. Expressões e Atribuições Aritméticas
Expressões complexas são desmembradas. Uma soma comum resulta na instrução padrão de três posições `temp := esquerda * direita`. No caso de operadores compostos de atribuição (como `calculo *= 5`), o gerador extrai o operador base, resolve a matemática em um temporário e faz a reatribuição logo em seguida de forma atômica.

### 2. Controle de Fluxo Condicional e Laços
As estruturas de decisão e repetição utilizam a instrução nativa de salto condicional falso `if_falso [condição] goto [rótulo]`:
* **IF-ELSE:** Avalia a condição; se falsa, salta para o rótulo do senão; caso contrário, executa o bloco interno e pula para o rótulo de encerramento.
* **WHILE e FOR:** Ancoram um rótulo no início da checagem da expressão condicional. Se a condição falhar, saltam para fora do loop. Ao final do corpo do laço (e execução do incremento, no caso do `for`), uma instrução incondicional `goto` força o retorno ao início do teste.
* **DO-WHILE:** Executa o bloco de comandos sequencialmente primeiro e, no final, realiza o teste lógico através da instrução direta `if [condição] goto [início]`, garantindo a execução obrigatória de ao menos uma iteração.

### 3. Acesso e Escrita em Vetores (Arrays)
Como o TAC opera em baixo nível, ele não possui conceito de índices abstratos de arrays. O compilador traduz acessos a vetores (tanto leitura quanto escrita) realizando explicitamente a aritmética de ponteiros com base no tamanho do tipo primitivo (considerando 4 bytes para inteiros no projeto):
1. Multiplica-se o índice desejado por 4 para computar o deslocamento: `t_offset := indice * 4`.
2. Realiza-se o acesso indexado pela memória física mapeada: `t_val := vetor[t_offset]` ou `vetor[t_offset] := valor`.

### 4. Chamadas de Função e Entrada/Saída
* **Procedimentos e Funções:** Os argumentos são empilhados individualmente através da instrução `param [valor]`. Em seguida, a ativação é disparada pela instrução `destino := call [nome_função], [quantidade_parâmetros]`.
* **Fluxos de Stream (`cout` e `cin`):** São convertidos diretamente para primitivas abstratas lineares de leitura e escrita representadas pelas palavras-chave **`print`** e **`read`**.

---

## Benefícios para a Otimização
Ao isolar as operações em instruções de no máximo três endereços, a fase subsequente de **Otimização de Código** consegue rastrear com precisão o ciclo de vida das variáveis e dos temporários, facilitando a aplicação de técnicas como a eliminação de subexpressões comuns e a propagação de constantes diretamente nas representações intermediárias.