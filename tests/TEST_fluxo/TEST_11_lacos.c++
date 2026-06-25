int main() {
    int contador = 0;

    // Teste estruturado do laço While
    while (contador < 3) {
        std::cout << contador * 1.0;
        std::cout << "\n";
        contador += 1;
    }

    // Teste do laço For com controle de Break e Continue
    int i = 0;
    for (i = 0; i < 5; i++) {
        if (i == 1) {
            i += 1;
            continue;
        }
        if (i == 4) {
            break;
        }
        std::cout << i * 1.0;
        std::cout << "\n";
        i += 1;
    }

    // Teste estruturado do laço Do-While
    int j = 0;
    do {
        std::cout << "Executou o bloco do-while";
        std::cout << "\n";
        j += 1;
    } while (j < 1);

    return 0;
}