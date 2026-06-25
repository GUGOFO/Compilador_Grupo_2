int main() {
    int ativo = 1;

    if (false) {
        int variavelMorta = 100;
        std::cout << "Este bloco sera completamente podado da AST";
        std::cout << "\n";
    }

    std::cout << ativo * 1.0;
    std::cout << "\n";
    return 0;
}