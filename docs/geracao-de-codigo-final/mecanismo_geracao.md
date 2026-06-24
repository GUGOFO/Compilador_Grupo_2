---
title: Mecanismo de Emissão de Código Alvo
parent: Geração de Código Final
nav_order: 2
---

# Mecanismo de Emissão de Código Alvo

A geração de código alvo do nosso transpilador é governada de forma polimórfica: os nós que compõem a nossa AST implementam o método virtual `gerarC()`, que dita as regras de impressão sintática baseadas na semântica de C padrão.

Abaixo estão mapeados os critérios de engenharia utilizados na tradução de cada elemento da linguagem:

---

## 1. Injeção de Diretivas e Cabeçalhos
No topo do arquivo final gerado, o nó raiz do programa injeta automaticamente as inclusões de cabeçalho da biblioteca padrão do C. São incluídas as diretivas para dar suporte a funções de entrada e saída (I/O) e para habilitar o suporte nativo a tipos booleanos reais na linguagem C (verdadeiro e falso).

## 2. Tradução Avançada de Fluxos de Stream (I/O)
Como a linguagem C não possui os objetos abstratos de stream do C++, o transpilador realiza o mapeamento direto para funções clássicas de leitura e escrita:
* **Comando de Saída (`cout`):** O compilador intercepta as expressões de impressão e consulta o tipo que foi inferido na fase semântica para aquele nó da AST. Se a expressão for avaliada como um inteiro, a tradução insere uma máscara de formatação inteira no argumento. Se a expressão for avaliada como ponto flutuante, insere automaticamente a máscara decimal flutuante. O mesmo tratamento estrito é aplicado para a impressão de caracteres isolados ou strings textuais fixas.
* **Comando de Entrada (`cin`):** É mapeado diretamente para a função de leitura formatada do C. O compilador identifica o tipo de dado da variável vindo da tabela de símbolos e configura a máscara apropriada, realizando obrigatoriamente a passagem por referência do identificador para que a memória seja atualizada corretamente.

---

## 3. Isolamento de Escopos e Proteção de Shadowing
Para dar suporte completo ao sombreamento de variáveis (onde um bloco interno possui uma variável local de mesmo nome de uma variável externa), as estruturas de decisão condicional preservam a impressão obrigatória dos delimitadores de chaves textuais. 

Ao envelopar os blocos internos sob chaves em C, garantimos que o ciclo de vida e a visibilidade das variáveis locais fiquem restritos àquele escopo em tempo de execução, impedindo colisões de nomes ou redefinições inválidas perante o GCC.

---

## 4. Sincronização com a Eliminação de Código Morto
A emissão do código final trabalha em total sinergia com a etapa de otimização. No momento em que a árvore sintática processa os nós de declaração de variáveis simples ou declaração de vetores estruturados, é realizada uma varredura contra o conjunto global de monitoramento de uso. 

Caso o identificador analisado tenha sido detectado como morto (variável inútil que nunca foi lida ou operada em cálculos), o método de geração simplesmente ignora a instrução, impedindo que a variável seja impressa no arquivo C de saída. Isso garante uma redução direta no consumo de memória RAM do binário final.

---

## 5. Emissão do Laço For e Operadores Pós-Fixados
A tradução do laço `for` reconstrói a assinatura clássica da iteração estruturada em C. Com o suporte nativo adicionado para os operadores de incremento e decremento pós-fixados, o cabeçalho do laço agora emite o formato limpo contendo a atribuição inicial, a expressão de teste e a expressão de atualização. 

Essa implementação limpa elimina a necessidade de lógicas redundantes no corpo do bloco e previne a ocorrência de avisos ou advertências de compilação por parte do compilador GCC.