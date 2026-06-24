/*
  ======================================================================
  📦 ARQUIVO DE ENTRADA EM C++ (EXEMPLO_ENTRADA.C++)
  ======================================================================
*/

// --- [1] Seção de Funções ---
int calcularDobro(int numero) {
    return numero * 2;
}

// --- [2] Função Principal ---
int main() {
    // Declarações básicas
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
    
    // Teste de Operações Matemáticas
    std::cout << "Saldo na conta (negativo):";
    std::cout << saldo * 1.0; 
    std::cout << "\n";

    int calculo = 0;
    calculo += 10;
    calculo -= 2;
    calculo *= 5; 
    
    // Teste de Lógica Textual (and, not)
    if (aprovado and not reprovado) {
        std::cout << "Logica textual (and, not) funcionou!";
        std::cout << "\n";
    } else {
        std::cout << "Falhou...";
        std::cout << "\n";
    }

    // Teste de Lógica Simbólica
    if (calculo == 40 && saldo < 0) {
        std::cout << "Logica simbolica (&&, ==, <) funcionou!";
        std::cout << "\n";
    }

    // Teste de Laço While
    int contador = 0;
    std::cout << "Testando While: ";
    std::cout << "\n";
    while (contador < 3) {
        std::cout << contador * 1.0;
        std::cout << "\n";
        contador += 1;
    }

    // Teste de Laço Do-While com Break
    std::cout << "Testando Do-While com Break: ";
    std::cout << "\n";
    do {
        std::cout << "Entrou e executou o break!";
        std::cout << "\n";
        break;
    } while (false);

    // Teste de Laço For com Continue
    std::cout << "Testando For (reaproveitando variavel): ";
    std::cout << "\n";
    int i = 0;
    for (i = 0; i < 2; i + 1) {
        if (i == 1) {
            std::cout << "Executou o continue!";
            std::cout << "\n";
            i += 1;
            continue;
        }
        std::cout << i * 1.0;
        std::cout << "\n";
        i += 1;
    }

    // Teste de Escopo e Shadowing
    if (true) {
        int idade = 99; 
        std::cout << "Shadowing (idade interna devera ser 99): ";
        std::cout << idade * 1.0;
        std::cout << "\n";
    }

    // Teste da Estrutura Switch-Case
    std::cout << "Testando Comando Switch-Case: ";
    std::cout << "\n";
    int opcao = 2;
    switch (opcao) {
        case 1:
            std::cout << 111 * 1.0;
            std::cout << "\n";
            break;
        case 2:
            std::cout << 222 * 1.0;
            std::cout << "\n";
            break;
        default:
            std::cout << 999 * 1.0;
            std::cout << "\n";
            break;
    }

    // Teste de Atribuição e Acesso a Vetores
    meuVetor[2] = 88;
    int valorVetor = meuVetor[2];
    std::cout << valorVetor * 1.0;
    std::cout << "\n";

    // Verificação de Escopo Global Mantido
    std::cout << "Idade global intacta (devera ser 21): ";
    std::cout << idade * 1.0;
    std::cout << "\n";

    // Teste de Chamada de Função
    std::cout << "Testando Chamada de Funcao (Dobro de 25): ";
    std::cout << "\n";
    int resultado = calcularDobro(25);
    std::cout << resultado * 1.0;
    std::cout << "\n";
    
    std::cout << "SUCESSO ABSOLUTO!";
    std::cout << "\n";

    return 0;
}