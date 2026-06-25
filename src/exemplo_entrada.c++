int calcularDobro(int numero) {
    return numero * 2;
}

int main() {
    int idade = 21;
    float nota = 9.5;
    double pi = 3.14159;
    bool aprovado = true;
    bool reprovado = false;
    char turma = 'A';
    int saldo = -150;
    int meuVetor[5];
    bool flagInutil = true;
    int meuVetorInutil[50];

    std::cout << "--- INICIANDO TESTES DO COMPILADOR ---";
    std::cout << "\n";
    
    std::cout << "Saldo na conta (negativo):";
    std::cout << saldo; 
    std::cout << "\n";

    int calculo = 0;
    calculo += 10;
    calculo -= 2;
    calculo *= 5; 

    if (aprovado and not reprovado) {
        std::cout << "Logica textual (and, not) funcionou!";
        std::cout << "\n";
    } else {
        std::cout << "Falhou...";
        std::cout << "\n";
    }

    if (calculo == 40 && saldo < 0) {
        std::cout << "Logica simbolica (&&, ==, <) funcionou!";
        std::cout << "\n";
    }

    int contador = 0;
    std::cout << "Testando While: ";
    std::cout << "\n";
    while (contador < 3) {
        std::cout << contador;
        std::cout << "\n";
        contador += 1;
    }

    std::cout << "Testando Do-While com Break: ";
    std::cout << "\n";
    do {
        std::cout << "Entrou e executou o break!";
        std::cout << "\n";
        break;
    } while (false);

    std::cout << "Testando For (reaproveitando variavel): ";
    std::cout << "\n";
    int i = 0;
    for (i = 0; i < 2; i++) {
        if (i == 1) {
            std::cout << "\n";
            i += 1;
        }
        std::cout << i;
        std::cout << "\n";
        i += 1;
    }

    if (true) {
        int idade = 99; 
        std::cout << "Shadowing (idade interna devera ser 99): ";
        std::cout << idade;
        std::cout << "\n";
    }

    std::cout << "Testando Comando Switch-Case: ";
    std::cout << "\n";
    int opcao = 2;
    switch (opcao) {
        case 1:
            std::cout << 111;
            std::cout << "\n";
            break;
        case 2:
            std::cout << 222;
            std::cout << "\n";
            break;
        default:
            std::cout << 999;
            std::cout << "\n";
            break;
    }

    meuVetor[2] = 88;
    int valorVetor = meuVetor[2];
    std::cout << valorVetor;
    std::cout << "\n";

    std::cout << "Idade global intacta (devera ser 21): ";
    std::cout << idade;
    std::cout << "\n";

    std::cout << "Testando Chamada de Funcao (Dobro de 25): ";
    std::cout << "\n";
    int resultado = calcularDobro(25);
    std::cout << resultado;
    std::cout << "\n";
    
    std::cout << "SUCESSO ABSOLUTO!";
    std::cout << "\n";

    return 0;
}