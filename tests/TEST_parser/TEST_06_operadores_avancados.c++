int main() {
    int x = 10;
    bool b = true;
    int tamanhoTipo = sizeof(int);
    int tamanhoVar = sizeof(x);
    
    // Na sua gramática, incrementos pós-fixados devem ser usados dentro de estruturas lícitas (como o for)
    int i = 0;
    for (i = 0; i < 2; x++) {
        b = !b;
    }
    
    int negativo = -x;
    bool condicao = !b && (x > 5 || b == true);
    return 0;
}