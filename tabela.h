#ifndef TABELA_SIMBOLOS_H
#define TABELA_SIMBOLOS_H

typedef struct Simbolo{
    char nome[36];
    char tipo[20];
    char escopo[10];

    struct Simbolo *prox;
} Simbolo;

void inserirSimbolo(char *nome, char *tipo, char *escopo);
Simbolo *buscarSimbolo(char *nome, char *escopo);
void imprimirTabela();


#endif