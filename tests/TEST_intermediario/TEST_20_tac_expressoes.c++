int main() {
    int a = 10;
    int b = 20;
    int c = 3;
    int resultado = 0;

    // Deve gerar múltiplos temporários respeitando a precedência de operadores
    resultado = a + b * c - (a / 2);

    // Deve gerar a operação base em um temporário e reatribuir à variável
    resultado += 5;
    resultado *= b;

    std::cout << resultado * 1.0;
    std::cout << "\n";

    return 0;
}