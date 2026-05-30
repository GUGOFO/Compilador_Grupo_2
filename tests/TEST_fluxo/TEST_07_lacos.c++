int main() {
    int contador = 0;

    while (contador < 5) {
        std::cout << contador;
        contador += 1;
    }

    for (int i = 0; i < 10; i += 1) {
        if (i == 5) {
            break;
        }
        std::cout << i;
    }

    return 0;
}