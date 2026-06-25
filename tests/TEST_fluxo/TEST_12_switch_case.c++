int main() {
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

    return 0;
}