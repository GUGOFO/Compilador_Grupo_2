// Função com múltiplos parâmetros no escopo global
int somarTres(int a, int b, int c) {
    return a + b + c;
}

// Procedimento vazio auxiliar
void processar() {
    int x = somarTres(1, 2, 3);
}

int main() {
    processar();
    return 0;
}