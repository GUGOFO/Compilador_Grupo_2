int main() {
    int x = 10;

    if (x == 10) {
        int x = 20; 
        std::cout << x * 1.0;
        std::cout << "\n";
    }

    // Escopo superior protegido: Deverá imprimir 10
    std::cout << x * 1.0;
    std::cout << "\n";

    return 0;
}