#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

typedef struct Simbolo{
    char nome[36];
    char tipo[20];
    int escopo;
    struct Simbolo *prox;
} Simbolo;

void inserirSimbolo(char *nome, char *tipo, int escopo);
Simbolo *buscarSimbolo(char *nome, int escopo);
void removerEscopo(int escopo_alvo);
void imprimirTabela();

#endif
