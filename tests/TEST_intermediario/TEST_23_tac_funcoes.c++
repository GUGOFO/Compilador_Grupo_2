int somar(int x, int y) {
    return x + y;
}

int main() {
    int a = 5;
    int b = 15;
    int total = 0;

    // Deve gerar: param a -> param b -> total := call somar, 2
    total = somar(a, b);

    std::cout << total * 1.0;
    std::cout << "\n";

    return 0;
}