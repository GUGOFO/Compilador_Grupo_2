int main() {
    float media = 7.5;

    if (media >= 5.0) {
        if (media >= 9.0) {
            std::cout << "Aprovado com Louvor";
        } else {
            std::cout << "Aprovado";
        }
    } else {
        std::cout << "Reprovado";
    }

    return 0;
}