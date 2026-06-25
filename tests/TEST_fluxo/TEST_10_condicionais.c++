int main() {
    float media = 7.5;

    if (media >= 5.0) {
        if (media >= 9.0) {
            std::cout << "Aprovado com Louvor";
            std::cout << "\n";
        } else {
            std::cout << "Aprovado";
            std::cout << "\n";
        }
    } else {
        std::cout << "Reprovado";
        std::cout << "\n";
    }

    return 0;
}