#include "tabela.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


Simbolo *tabela = NULL;

void inserirSimbolo(char *nome, char *tipo, int escopo){
    //Verifica se o símbolo já está na tabela
    Simbolo *s = tabela;
    while (s) {
        if(strcmp(s -> nome, nome) == 0 && s -> escopo == escopo){
            fprintf(stderr, "Erro Semântico: símbolo '%s' já declarado neste escopo.\n", nome);
            exit(1);
        }
        s = s->prox;
    }

    Simbolo *novo = (Simbolo *)malloc(sizeof(Simbolo));
    strcpy(novo -> nome, nome);
    strcpy(novo -> tipo, tipo);
    novo -> escopo = escopo;
    novo->prox = NULL;

    if (tabela == NULL) tabela = novo;
    else{
        Simbolo *last = tabela;
        while(last -> prox)
            last = last -> prox;
        last -> prox = novo;
    }
}

Simbolo *buscarSimbolo(char *nome, int escopo_atual){
    for (int e = escopo_atual; e >= 0; e--){
        for(Simbolo *s = tabela; s; s = s -> prox){
            if (strcmp(s -> nome, nome) == 0 && s -> escopo == e)
                return s;
        }
    }
    return NULL;
}

void removerEscopo(int escopo_alvo){
    Simbolo *atual = tabela;
    Simbolo *anterior = NULL;

    while(atual != NULL){
        if(atual -> escopo == escopo_alvo){
            if(anterior == NULL) tabela = atual -> prox;
            else anterior -> prox = atual -> prox;
            Simbolo *aux = atual;
            atual = atual -> prox;
            free(aux);
        }
        else{
            anterior = atual;
            atual = atual -> prox;
        }
    }
}

void imprimirTabela(){
    printf("\nTabela de Simbolos:\n");
    for(Simbolo *s = tabela; s; s = s -> prox)
        printf("Nome: %s, Tipo: %s, Escopo: %d\n", s -> nome, s -> tipo, s -> escopo);
}