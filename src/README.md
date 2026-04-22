# Documentação

Arquivo reservado para o codigo do projeto

## Como rodar

1. Entre na pasta "scr"

2. Caso esteja no windows, ative o WSL

3. rode "bison -d parser.y

3. rode "flex scanner.l"

4. rode "gcc parser.tab.c lex.yy.c -o transpilador -lfl"

5. rode "./transpilador < exemplo_entrada.c++ > saida.c"