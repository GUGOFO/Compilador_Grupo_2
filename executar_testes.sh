#!/bin/bash

# Definição estável de cores via ANSI-C Quoting (Obrigatório para macOS)
VERDE=$'\033[0;32m'
VERMELHO=$'\033[0;33m'
FALHA_CRITICA=$'\033[0;31m'
AZUL=$'\033[0;34m'
ROXO=$'\033[0;35m'
NEUTRO=$'\033[0m'

printf "%s\n" "${AZUL}======================================================="
printf "        SUÍTE DE TESTES AUTOMATIZADOS - COMPILADOR       \n"
printf "%s\n" "=======================================================${NEUTRO}"

# -----------------------------------------------------------------
# PASSO 1: COMPILAÇÃO AUTOMÁTICA DO TRANSPILADOR
# -----------------------------------------------------------------
printf "\n%s\n" "${ROXO}[PASSO 1] Compilando o Transpilador via Flex/Bison...${NEUTRO}"

if [ ! -d "src" ]; then
    printf "%s\n" "${FALHA_CRITICA}❌ Erro: Pasta 'src' não encontrada na raiz do projeto.${NEUTRO}"
    exit 1
fi

cd src || exit 1
bison -d parser.y
flex scanner.l
g++ -std=c++17 parser.tab.c lex.yy.c tabela.c -o transpilador 2> /dev/null

if [ $? -eq 0 ]; then
    printf "%s\n" "${VERDE}✅ Transpilador compilado com sucesso com C++17!${NEUTRO}"
else
    printf "%s\n" "${FALHA_CRITICA}❌ Falha crítica: Erro de compilação no código do transpilador.${NEUTRO}"
    exit 1
fi
cd ..

# -----------------------------------------------------------------
# PASSO 2: CATEGORIZAÇÃO DOS TESTES
# -----------------------------------------------------------------

TESTES_LEXICO_PURO=(
    "tests/TEST_scaner/TEST_01_literais.c++"
    "tests/TEST_scaner/TEST_02_keywords.c++"
    "tests/TEST_scaner/TEST_03_operadores.c++"
)

TESTES_PROGRAMA_COMPLETO=(
    "tests/TEST_parser/TEST_06_operadores_avancados.c++"
    "tests/TEST_parser/TEST_07_vetores_sintaxe.c++"
    "tests/TEST_parser/TEST_08_funcoes_assinaturas.c++"
    "tests/TEST_fluxo/TEST_10_condicionais.c++"
    "tests/TEST_fluxo/TEST_11_lacos.c++"
    "tests/TEST_fluxo/TEST_12_switch_case.c++"
    "tests/TEST_fluxo/TEST_13_otimizacao_ramos.c++"
    "tests/TEST_semantico/TEST_14_escopo.c++"
)

TESTES_DECLARACOES_PURAS=(
    "tests/TEST_scaner/TEST_04_comentarios.c++"
)

TESTES_ERRO_LEXICO=("tests/TEST_scaner/TEST_05_erro_lexico.c++")
TESTES_ERRO_SINTATICO=("tests/TEST_parser/TEST_09_erro_sintatico.c++")
TESTES_ERRO_SEMANTICO=(
    "tests/TEST_semantico/TEST_15_erro_nao_declarada.c++"
    "tests/TEST_semantico/TEST_16_erro_redeclaracao.c++"
    "tests/TEST_semantico/TEST_17_erro_atribuicao.c++"
    "tests/TEST_semantico/TEST_18_erro_condicao.c++"
    "tests/TEST_semantico/TEST_19_erro_retorno.c++"
)

TESTES_TAC=(
    "tests/TEST_intermediario/TEST_20_tac_expressoes.c++"
    "tests/TEST_intermediario/TEST_21_tac_fluxo.c++"
    "tests/TEST_intermediario/TEST_22_tac_vetores.c++"
    "tests/TEST_intermediario/TEST_23_tac_funcoes.c++"
)

# -----------------------------------------------------------------
#  PASSO 3: EXECUÇÃO DOS TESTES DE CONFORMIDADE
# -----------------------------------------------------------------
printf "\n%s\n" "${ROXO}[PASSO 2] Executando Testes de Sucesso...${NEUTRO}"

for teste in "${TESTES_LEXICO_PURO[@]}"; do
    if [ -f "$notes" ] || [ -f "$teste" ]; then
        printf "• Analisando Léxico de %s... " "$teste"
        ./src/transpilador < "$teste" > /dev/null 2> d_erro.txt
        if grep -q "Erro Léxico" d_erro.txt; then
            printf "%s\n" "${FALHA_CRITICA}❌ REJEITADO (Erro léxico inválido)${NEUTRO}"
        else
            printf "%s\n" "${VERDE}✅ PASSOU${NEUTRO}"
        fi
        rm -f d_erro.txt
    fi
done

for teste in "${TESTES_DECLARACOES_PURAS[@]}"; do
    if [ -f "$teste" ]; then
        printf "• Analisando Estrutura de %s... " "$teste"
        ./src/transpilador < "$teste" > d_saida.c 2> /dev/null
        if [ $? -eq 0 ]; then
            gcc -c d_saida.c -o d_teste_bin.o 2> /dev/null
            if [ $? -eq 0 ]; then
                printf "%s\n" "${VERDE}✅ PASSOU (Código C Válido!)${NEUTRO}"
                rm -f d_saida.c d_teste_bin.o
            else
                printf "%s\n" "${FALHA_CRITICA}❌ REJEITADO PELO GCC${NEUTRO}"
                rm -f d_saida.c
            fi
        else
            printf "%s\n" "${FALHA_CRITICA}❌ REJEITADO PELO TRANSPILADOR${NEUTRO}"
        fi
    fi
done

for teste in "${TESTES_PROGRAMA_COMPLETO[@]}"; do
    if [ -f "$teste" ]; then
        printf "• Processando %s... " "$teste"
        ./src/transpilador < "$teste" > d_saida.c 2> /dev/null
        if [ $? -eq 0 ]; then
            gcc d_saida.c -o d_teste_bin 2> /dev/null
            if [ $? -eq 0 ]; then
                printf "%s\n" "${VERDE}✅ PASSOU (Código C Válido!)${NEUTRO}"
                rm -f d_saida.c d_teste_bin
            else
                printf "%s\n" "${FALHA_CRITICA}❌ REJEITADO PELO GCC${NEUTRO}"
                rm -f d_saida.c
            fi
        else
            printf "%s\n" "${FALHA_CRITICA}❌ REJEITADO PELO TRANSPILADOR${NEUTRO}"
        fi
    fi
done

# -----------------------------------------------------------------
# PASSO 4: EXECUÇÃO DOS TESTES DE ERRO CONTROLADO
# -----------------------------------------------------------------
printf "\n%s\n" "${ROXO} [PASSO 3] Executando Testes de Erros Controlados (Devem Bloquear)...${NEUTRO}"

for teste in "${TESTES_ERRO_LEXICO[@]}"; do
    if [ -f "$teste" ]; then
        printf "• Verificando Erro Léxico em %s... " "$teste"
        ./src/transpilador < "$teste" > /dev/null 2> msg_erro.txt
        if [ $? -ne 0 ] || grep -q "Erro" msg_erro.txt; then
            printf "%s\n" "${VERDE}✅ BLOQUEADO COM SUCESSO!${NEUTRO}"
            printf "    %s\n" "${VERMELHO}↳ Diagnóstico: $(cat msg_erro.txt | grep -E "Erro" | head -n 1)${NEUTRO}"
        else
            printf "%s\n" "${FALHA_CRITICA}❌ ERRO: Aceitou erro léxico!${NEUTRO}"
        fi
        rm -f msg_erro.txt
    fi
done

for teste in "${TESTES_ERRO_SINTATICO[@]}"; do
    if [ -f "$teste" ]; then
        printf "• Verificando Erro Sintático em %s... " "$teste"
        ./src/transpilador < "$teste" > /dev/null 2> msg_erro.txt
        if [ $? -ne 0 ] || grep -q "Erro sintatico" msg_erro.txt; then
            printf "%s\n" "${VERDE}✅ BLOQUEADO COM SUCESSO!${NEUTRO}"
            printf "    %s\n" "${VERMELHO}↳ Diagnóstico: $(cat msg_erro.txt | grep "Erro sintatico" | head -n 1)${NEUTRO}"
        else
            printf "%s\n" "${FALHA_CRITICA}❌ ERRO: Aceitou erro sintático!${NEUTRO}"
        fi
        rm -f msg_erro.txt
    fi
done

for teste in "${TESTES_ERRO_SEMANTICO[@]}"; do
    if [ -f "$teste" ]; then
        printf "• Verificando Erro Semântico em %s... " "$teste"
        ./src/transpilador < "$teste" > /dev/null 2> msg_erro.txt
        if [ $? -ne 0 ] || grep -q "Erro" msg_erro.txt; then
            printf "%s\n" "${VERDE}✅ BLOQUEADO COM SUCESSO!${NEUTRO}"
            printf "    %s\n" "${VERMELHO}↳ Diagnóstico: $(cat msg_erro.txt | grep -i "Erro" | head -n 1)${NEUTRO}"
        else
            printf "%s\n" "${FALHA_CRITICA}❌ ERRO: Aceitou erro semântico!${NEUTRO}"
        fi
        rm -f msg_erro.txt
    fi
done

# -----------------------------------------------------------------
#  PASSO 5: RELATÓRIO ANALÍTICO DO CÓDIGO INTERMEDIÁRIO (TAC)
# -----------------------------------------------------------------
printf "\n%s\n" "${ROXO} [PASSO 4] Extraindo Relatório de Código Intermediário (TAC)...${NEUTRO}"

for teste in "${TESTES_TAC[@]}"; do
    if [ -f "$teste" ]; then
        printf "\n%s\n" "${AZUL}-------------------------------------------------------${NEUTRO}"
        printf " Arquivo de Origem: %s\n" "$teste"
        printf "%s\n" "${AZUL}-------------------------------------------------------${NEUTRO}"
        ./src/transpilador < "$teste" > /dev/null
        printf "%s\n" "${AZUL}-------------------------------------------------------${NEUTRO}"
    fi
done

printf "\n%s\n" "${AZUL}======================================================="
printf "   VARREDURA COMPLETA CONCLUÍDA CONCLUÍDA COM SUCESSO!       \n"
printf "%s\n" "=======================================================${NEUTRO}"