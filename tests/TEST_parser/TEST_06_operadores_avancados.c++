int main() {
    int x = 10;
    bool b = true;
    
    // Teste do operador sizeof com tipo e com expressão
    int tamanhoTipo = sizeof(int);
    int tamanhoVar = sizeof(x);
    
    // Teste de operadores pós-fixados
    x++;
    x--;
    
    // Menos unário e expressões lógicas complexas com parênteses
    int negativo = -x;
    bool condicao = !b && (x > 5 || b == true);
    
    return 0;
}