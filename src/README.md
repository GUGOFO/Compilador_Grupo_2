# Documentação

Arquivo reservado para o codigo do projeto

## Como rodar

1. Entre na pasta "scr"

2. Caso esteja no windows, ative o WSL

3. rode "bison -d parser.y"

3. rode "flex scanner.l"

4. rode "g++ -std=c++17 parser.tab.c lex.yy.c tabela.c -o transpilador"

5. rode "./transpilador < exemplo_entrada.c++ > saida.c && gcc saida.c -o programa_executavel"

6. rode "./programa_executavel"