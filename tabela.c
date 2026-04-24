#include "tabela.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


Simbolo *tabela = NULL;

void inserirSimbolo(char *nome, char *tipo, char *escopo){
    //Verifica se o símbolo já está na tabela
    Simbolo *s = tabela;
    while (s) {
        if(strcmp(s -> nome, nome) && strcmp(s -> escopo, escopo) == 0)
            return;
        s = s->prox;
    }

    Simbolo *novo = malloc(sizeof(Simbolo));
    strcpy(novo -> nome, nome);
    strcpy(novo -> tipo, tipo);
    strcpy(novo -> escopo, escopo);
    novo->prox = NULL;

    if (tabela == NULL) tabela = novo;
    else{
        Simbolo *last = tabela;
        while(last -> prox)
            last = last -> prox;
        last -> prox = novo;
    }
}

Simbolo *buscarSimbolo(char *nome, char *escopo){
    for(Simbolo *s = tabela; s; s = s -> prox)
        if (strcmp(s -> nome, nome) && strcmp(s -> escopo, escopo) == 0)
            return s;
    return NULL;
}

void imprimirTabela(){
    printf("\nTabela de Simbolos:\n");
    for(Simbolo *s = tabela; s; s = s -> prox)
        printf("Nome: %s, Tipo: %s, Escopo: %s\n", s -> nome, s -> tipo, s -> escopo);
}