int somarTres(int a, int b, int c) {
    return a + b + c;
}

int processar() {
    int x = somarTres(1, 2, 3);
    return x;
}

int main() {
    // Chamadas de função na sua linguagem devem ser capturadas por uma atribuição exp
    int resultadoDummy = processar();
    return 0;
}