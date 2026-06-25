int main() {
    int x = 0;
    bool condicao = true;

    // Teste de TAC para estrutura condicional IF-ELSE
    if (condicao) {
        x = 10;
    } else {
        x = 20;
    }

    // Teste de TAC para laço de repetição WHILE
    while (x > 0) {
        x -= 1;
    }

    // Teste de TAC para laço de repetição FOR
    int i = 0;
    for (i = 0; i < 3; i++) {
        std::cout << i * 1.0;
        std::cout << "\n";
    }

    return 0;
}