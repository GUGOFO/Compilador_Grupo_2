// Função que promete retornar int
int calcular() {
    // Erro Semântico: Retorno bool incompatível com a assinatura da função
    return true; 
}

int main() {
    int resultado = calcular();
    return 0;
}