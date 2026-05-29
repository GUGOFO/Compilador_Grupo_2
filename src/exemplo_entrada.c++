int main() {
    int base = 10;
    float altura = 5.5;
    float area = 0.0;

    std::cout << "Iniciando o calculo da area...";

    area = (base * altura) / 2;

    if (area > 20.0) {
        std::cout << "A area e maior que 20";
    } else {
        std::cout << "A area e menor ou igual a 20";
    }

    int contador = 0;
    
    while (contador < 3) {
        std::cout << contador;
        contador += 1;
    }

    return 0;
}