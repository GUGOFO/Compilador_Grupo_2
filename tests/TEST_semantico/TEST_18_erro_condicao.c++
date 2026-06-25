int main() {
    int saldo = -50;
    
    // Erro Semântico: A condição do 'while' deve ser estritamente 'bool'
    while (saldo) { 
        saldo += 10;
    }

    return 0;
}