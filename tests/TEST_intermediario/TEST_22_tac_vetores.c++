int main() {
    int meuVetor[10];
    int indice = 2;
    int armazem = 0;

    // Escrita indexada (ArrayAssignNode)
    meuVetor[indice] = 50;

    // Leitura indexada em expressão (ArrayAccessNode)
    armazem = meuVetor[indice] + 5;

    std::cout << armazem * 1.0;
    std::cout << "\n";

    return 0;
}