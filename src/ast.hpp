#pragma once
#include <string>
#include <vector>
#include <memory>
#include <cstdio>
#include <set>

extern std::set<std::string> variaveis_usadas;

class ASTNode;
using NodoPtr = std::unique_ptr<ASTNode>;

class GeradorTAC {
private:
    static inline int contador_temp = 0;
    static inline int contador_label = 0;
public:
    static std::string novo_temporario() {
        return "t" + std::to_string(contador_temp++);
    }
    static std::string nova_label() {
        return "L" + std::to_string(contador_label++);
    }
};

class ASTNode {
public:
    int         linha         = 0;
    std::string tipo_inferido = "";

    virtual ~ASTNode() = default;
    virtual void print(int nivel = 0)  const = 0;
    virtual void gerarC(int nivel = 0) const = 0;
    virtual std::string gerarTAC(int nivel = 0) const = 0;

protected:
    void indent(int nivel, FILE* stream = stdout) const {
        for (int i = 0; i < nivel; i++) fprintf(stream, "    ");
    }
    void printInfo(FILE* stream = stdout) const {
        if (linha > 0)
            fprintf(stream, " (linha %d)", linha);
        if (!tipo_inferido.empty())
            fprintf(stream, " [tipo: %s]", tipo_inferido.c_str());
    }
};

class LiteralInteiroNode : public ASTNode {
public:
    int valor;
    explicit LiteralInteiroNode(int v) : valor(v) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[LiteralInteiro: %d]", valor); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override { 
        printf("%d", valor); 
    }
    std::string gerarTAC(int nivel = 0) const override {
        return std::to_string(valor);
    }
};

class LiteralFloatNode : public ASTNode {
public:
    float valor;
    explicit LiteralFloatNode(float v) : valor(v) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[LiteralFloat: %g]", valor); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override { 
        printf("%f", valor); // <--- ALTERADO DE %g PARA %f (Garante o .0000 no C)
    }
    std::string gerarTAC(int nivel = 0) const override {
        return std::to_string(valor);
    }
};

class LiteralStringNode : public ASTNode {
public:
    std::string valor;
    explicit LiteralStringNode(const char* v) : valor(v) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[LiteralString: %s]", valor.c_str()); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override { 
        printf("%s", valor.c_str()); 
    }
    std::string gerarTAC(int nivel = 0) const override {
        return valor;
    }
};

class IdentificadorNode : public ASTNode {
public:
    std::string nome;
    explicit IdentificadorNode(const char* n) : nome(n) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Identificador: %s]", nome.c_str()); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override { 
        printf("%s", nome.c_str()); 
    }
    std::string gerarTAC(int nivel = 0) const override {
        return nome;
    }
};

class OperacaoBinariaNode : public ASTNode {
public:
    std::string operador;
    NodoPtr     esquerda;
    NodoPtr     direita;

    OperacaoBinariaNode(std::string op, NodoPtr esq, NodoPtr dir)
        : operador(op), esquerda(std::move(esq)), direita(std::move(dir)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[OperacaoBinaria: %s]", operador.c_str()); printInfo(stderr); fprintf(stderr, "\n");
        if (esquerda) esquerda->print(nivel + 1);
        if (direita) direita->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        if (!direita) {
            printf("%s", operador.c_str());
            if (esquerda) esquerda->gerarC();
        } else {
            if (esquerda) esquerda->gerarC();
            printf(" %s ", operador.c_str());
            if (direita) direita->gerarC();
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string esq = esquerda ? esquerda->gerarTAC(nivel) : "";
        
        if (!direita) {
            std::string temp = GeradorTAC::novo_temporario();
            indent(nivel, stderr);
            fprintf(stderr, "%s := %s %s\n", temp.c_str(), operador.c_str(), esq.c_str());
            return temp;
        }
        
        std::string dir = direita->gerarTAC(nivel);
        std::string temp = GeradorTAC::novo_temporario();
        indent(nivel, stderr);
        fprintf(stderr, "%s := %s %s %s\n", temp.c_str(), esq.c_str(), operador.c_str(), dir.c_str());
        return temp;
    }
};

class ExpParenNode : public ASTNode {
public:
    NodoPtr expr;
    explicit ExpParenNode(NodoPtr e) : expr(std::move(e)) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[ExpressaoParenteses]"); printInfo(stderr); fprintf(stderr, "\n");
        if (expr) expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        printf("("); if (expr) expr->gerarC(); printf(")"); 
    }
    std::string gerarTAC(int nivel = 0) const override {
        return expr ? expr->gerarTAC(nivel) : "";
    }
};

#include <set> // Garanta que está no topo do ast.hpp
extern std::set<std::string> variaveis_usadas; // <--- IMPORTA A VARIÁVEL DO PARSER

class DeclVarNode : public ASTNode {
public:
    std::string tipo;
    std::string nome;
    NodoPtr     inicializador;

    DeclVarNode(std::string t, std::string n, NodoPtr init = nullptr)
        : tipo(t), nome(n), inicializador(std::move(init)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[DeclVar: %s %s]", tipo.c_str(), nome.c_str()); printInfo(stderr); fprintf(stderr, "\n");
        if (inicializador) inicializador->print(nivel + 1);
    }
    
    void gerarC(int nivel = 0) const override { 
        // 🚀 OTIMIZAÇÃO SEGUNDO A REGRA AS-IF: Se a variável nunca foi usada, ela não vai para o código final!
        if (variaveis_usadas.find(nome) == variaveis_usadas.end()) {
            return; 
        }
        indent(nivel);
        printf("%s %s", tipo.c_str(), nome.c_str());
        if (inicializador) {
            printf(" = ");
            inicializador->gerarC();
        }
        printf(";\n");
    }
    
    std::string gerarTAC(int nivel = 0) const override {
        // 🚀 OTIMIZAÇÃO: Se a variável nunca foi usada, ela também some do TAC!
        if (variaveis_usadas.find(nome) == variaveis_usadas.end()) {
            return ""; 
        }
        if (inicializador) {
            std::string val = inicializador->gerarTAC(nivel);
            indent(nivel, stderr);
            fprintf(stderr, "%s := %s\n", nome.c_str(), val.c_str());
        }
        return "";
    }
};

class CmdReturnNode : public ASTNode {
public:
    NodoPtr expr;
    explicit CmdReturnNode(NodoPtr e) : expr(std::move(e)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Return]"); printInfo(stderr); fprintf(stderr, "\n");
        if (expr) expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("return "); if (expr) expr->gerarC(); printf(";\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string val = expr ? expr->gerarTAC(nivel) : "";
        indent(nivel, stderr);
        fprintf(stderr, "return %s\n", val.c_str());
        return "";
    }
};

class CmdCoutNode : public ASTNode {
public:
    NodoPtr expr;
    explicit CmdCoutNode(NodoPtr e) : expr(std::move(e)) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Cout]"); printInfo(stderr); fprintf(stderr, "\n");
        if (expr) expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        indent(nivel);
        if (expr && expr->tipo_inferido == "string") {
            printf("printf("); expr->gerarC(); printf(");\n");
        } else if (expr && (expr->tipo_inferido == "float" || expr->tipo_inferido == "double")) {
            printf("printf(\"%%f\", "); expr->gerarC(); printf(");\n");
        } else if (expr && expr->tipo_inferido == "char") {
            printf("printf(\"%%c\", "); expr->gerarC(); printf(");\n");
        } else {
            printf("printf(\"%%d\", "); if (expr) expr->gerarC(); printf(");\n");
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string val = expr ? expr->gerarTAC(nivel) : "";
        indent(nivel, stderr);
        fprintf(stderr, "print %s\n", val.c_str());
        return "";
    }
};

class CmdCinNode : public ASTNode {
public:
    std::string variavel;
    explicit CmdCinNode(const char* v) : variavel(v) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Cin: %s]", variavel.c_str()); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override { 
        indent(nivel);
        if (tipo_inferido == "float" || tipo_inferido == "double") {
            printf("scanf(\"%%f\", &%s);\n", variavel.c_str());
        } else if (tipo_inferido == "char") {
            printf("scanf(\"%%c\", &%s);\n", variavel.c_str());
        } else {
            printf("scanf(\"%%d\", &%s);\n", variavel.c_str());
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        indent(nivel, stderr);
        fprintf(stderr, "read %s\n", variavel.c_str());
        return "";
    }
};

class BlocoNode : public ASTNode {
public:
    std::vector<NodoPtr> comandos;
    void adicionar(NodoPtr cmd) { comandos.push_back(std::move(cmd)); }
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Bloco]"); printInfo(stderr); fprintf(stderr, "\n");
        for (auto& c : comandos) {
            if (c) c->print(nivel + 1);
        }
    }
    void gerarC(int nivel = 0) const override { 
        for (auto& c : comandos) {
            if (c) c->gerarC(nivel);
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        for (auto& c : comandos) {
            if (c) c->gerarTAC(nivel);
        }
        return "";
    }
};

class ChamadaFuncaoNode : public ASTNode {
public:
    std::string nome;
    std::vector<NodoPtr> argumentos;

    ChamadaFuncaoNode(std::string n, std::vector<NodoPtr> args)
        : nome(n), argumentos(std::move(args)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[ChamadaFuncao: %s]\n", nome.c_str());
        for (auto& arg : argumentos) {
            if (arg) arg->print(nivel + 1);
        }
    }

    void gerarC(int nivel = 0) const override {
        printf("%s(", nome.c_str());
        for (size_t i = 0; i < argumentos.size(); ++i) {
            if (argumentos[i]) argumentos[i]->gerarC();
            if (i + 1 < argumentos.size()) printf(", ");
        }
        printf(")");
    }

    std::string gerarTAC(int nivel = 0) const override {
        std::vector<std::string> temps;
        for (auto& arg : argumentos) {
            if (arg) temps.push_back(arg->gerarTAC(nivel));
        }
        
        for (const auto& t : temps) {
            indent(nivel, stderr);
            fprintf(stderr, "param %s\n", t.c_str());
        }

        std::string temp_retorno = GeradorTAC::novo_temporario();
        indent(nivel, stderr);
        fprintf(stderr, "%s := call %s, %lu\n", temp_retorno.c_str(), nome.c_str(), argumentos.size());
        return temp_retorno;
    }
};

class FuncaoNode : public ASTNode {
public:
    std::string tipo_retorno;
    std::string nome;
    std::vector<NodoPtr> parametros;
    NodoPtr     corpo;

    FuncaoNode(std::string t, std::string n, std::vector<NodoPtr> params, NodoPtr c)
        : tipo_retorno(t), nome(n), parametros(std::move(params)), corpo(std::move(c)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Funcao: %s %s]\n", tipo_retorno.c_str(), nome.c_str());
        for (auto& p : parametros) {
            if (p) p->print(nivel + 1);
        }
        if (corpo) corpo->print(nivel + 1);
    }

    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("%s %s(", tipo_retorno.c_str(), nome.c_str());
        for (size_t i = 0; i < parametros.size(); ++i) {
            if (auto* d = dynamic_cast<DeclVarNode*>(parametros[i].get())) {
                printf("%s %s", d->tipo.c_str(), d->nome.c_str());
            }
            if (i + 1 < parametros.size()) printf(", ");
        }
        printf(") {\n");
        if (corpo) corpo->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
    }

    std::string gerarTAC(int nivel = 0) const override {
        fprintf(stderr, "begin_func %s\n", nome.c_str());
        if (corpo) corpo->gerarTAC(nivel + 1);
        fprintf(stderr, "end_func\n\n");
        return "";
    }
};

class ProgramaNode : public ASTNode {
public:
    std::vector<NodoPtr> declaracoes;
    void adicionar(NodoPtr d) { declaracoes.push_back(std::move(d)); }

    void print(int nivel = 0) const override {
        fprintf(stderr, "[Programa]\n");
        for (auto& d : declaracoes) {
            if (d) d->print(nivel + 1);
        }
    }
    void gerarC(int nivel = 0) const override {
        printf("#include <stdio.h>\n#include <stdbool.h>\n\n");
        for (auto& d : declaracoes) {
            if (d) d->gerarC(nivel);
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        fprintf(stderr, "--- CÓDIGO INTERMEDIÁRIO (TAC) ---\n");
        for (auto& d : declaracoes) {
            if (d) d->gerarTAC(nivel);
        }
        fprintf(stderr, "----------------------------------\n\n");
        return "";
    }
};

class BreakNode : public ASTNode {
public:
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Break]"); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("break;\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "break\n");
        return "";
    }
};

class ContinueNode : public ASTNode {
public:
    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Continue]"); printInfo(stderr); fprintf(stderr, "\n");
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("continue;\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "continue\n");
        return "";
    }
};

class AssignNode : public ASTNode {
public:
    std::string nome;
    std::string op;
    NodoPtr     valor;

    AssignNode(std::string n, std::string o, NodoPtr v)
        : nome(n), op(o), valor(std::move(v)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[Assign: %s %s]", nome.c_str(), op.c_str()); printInfo(stderr); fprintf(stderr, "\n");
        if (valor) valor->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        indent(nivel);
        printf("%s %s ", nome.c_str(), op.c_str());
        if (valor) valor->gerarC();
        printf(";\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string val = valor ? valor->gerarTAC(nivel) : "";
        indent(nivel, stderr);
        if (op == "=") {
            fprintf(stderr, "%s := %s\n", nome.c_str(), val.c_str());
        } else {
            std::string op_simples = op.substr(0, 1); 
            std::string temp = GeradorTAC::novo_temporario();
            fprintf(stderr, "%s := %s %s %s\n", temp.c_str(), nome.c_str(), op_simples.c_str(), val.c_str());
            indent(nivel, stderr);
            fprintf(stderr, "%s := %s\n", nome.c_str(), temp.c_str());
        }
        return "";
    }
};

class IfNode : public ASTNode {
public:
    NodoPtr condicao;
    NodoPtr entao;
    NodoPtr senao;

    IfNode(NodoPtr cond, NodoPtr ent, NodoPtr sen = nullptr)
        : condicao(std::move(cond)), entao(std::move(ent)), senao(std::move(sen)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[If]"); printInfo(stderr); fprintf(stderr, "\n");
        if (condicao) condicao->print(nivel + 1);
        if (entao) entao->print(nivel + 1);
        if (senao) senao->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("if ("); if (condicao) condicao->gerarC(); printf(") {\n");
        if (entao) entao->gerarC(nivel + 1);
        indent(nivel); printf("}");
        if (senao) {
            printf(" else {\n");
            senao->gerarC(nivel + 1);
            indent(nivel); printf("}\n");
        } else {
            printf("\n");
        }
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string cond = condicao ? condicao->gerarTAC(nivel) : "true";
        std::string label_falso = GeradorTAC::nova_label();
        std::string label_fim = GeradorTAC::nova_label();

        indent(nivel, stderr);
        fprintf(stderr, "if_falso %s goto %s\n", cond.c_str(), label_falso.c_str());
        
        if (entao) entao->gerarTAC(nivel + 1);
        
        if (senao) {
            indent(nivel + 1, stderr);
            fprintf(stderr, "goto %s\n", label_fim.c_str());
            fprintf(stderr, "%s:\n", label_falso.c_str());
            senao->gerarTAC(nivel + 1);
            fprintf(stderr, "%s:\n", label_fim.c_str());
        } else {
            fprintf(stderr, "%s:\n", label_falso.c_str());
        }
        return "";
    }
};

class WhileNode : public ASTNode {
public:
    NodoPtr condicao;
    NodoPtr corpo;

    WhileNode(NodoPtr cond, NodoPtr corp)
        : condicao(std::move(cond)), corpo(std::move(corp)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[While]"); printInfo(stderr); fprintf(stderr, "\n");
        if (condicao) condicao->print(nivel + 1);
        if (corpo) corpo->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("while ("); if (condicao) condicao->gerarC(); printf(") {\n");
        if (corpo) corpo->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string label_inicio = GeradorTAC::nova_label();
        std::string label_fim = GeradorTAC::nova_label();

        fprintf(stderr, "%s:\n", label_inicio.c_str());
        std::string cond = condicao ? condicao->gerarTAC(nivel + 1) : "true";
        
        indent(nivel + 1, stderr);
        fprintf(stderr, "if_falso %s goto %s\n", cond.c_str(), label_fim.c_str());
        
        if (corpo) corpo->gerarTAC(nivel + 1);
        
        indent(nivel + 1, stderr);
        fprintf(stderr, "goto %s\n", label_inicio.c_str());
        fprintf(stderr, "%s:\n", label_fim.c_str());
        return "";
    }
};

class DoWhileNode : public ASTNode {
public:
    NodoPtr corpo;
    NodoPtr condicao;

    DoWhileNode(NodoPtr corpo, NodoPtr cond)
        : corpo(std::move(corpo)), condicao(std::move(cond)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[DoWhile]"); printInfo(stderr); fprintf(stderr, "\n");
        if (corpo) corpo->print(nivel + 1);
        if (condicao) condicao->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("do {\n");
        if (corpo) corpo->gerarC(nivel + 1);
        indent(nivel); printf("} while ("); if (condicao) condicao->gerarC(); printf(");\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string label_inicio = GeradorTAC::nova_label();
        fprintf(stderr, "%s:\n", label_inicio.c_str());
        if (corpo) corpo->gerarTAC(nivel + 1);
        std::string cond = condicao ? condicao->gerarTAC(nivel + 1) : "true";
        indent(nivel + 1, stderr);
        fprintf(stderr, "if %s goto %s\n", cond.c_str(), label_inicio.c_str());
        return "";
    }
};

class ForNode : public ASTNode {
public:
    NodoPtr init;
    NodoPtr condicao;
    NodoPtr incremento;
    NodoPtr corpo;

    ForNode(NodoPtr init, NodoPtr cond, NodoPtr inc, NodoPtr corpo)
        : init(std::move(init)), condicao(std::move(cond)),
          incremento(std::move(inc)), corpo(std::move(corpo)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[For]"); printInfo(stderr); fprintf(stderr, "\n");
        if (init) init->print(nivel + 1);
        if (condicao) condicao->print(nivel + 1);
        if (incremento) incremento->print(nivel + 1);
        if (corpo) corpo->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("for (");
        if (auto* d = dynamic_cast<DeclVarNode*>(init.get())) {
            printf("%s %s = ", d->tipo.c_str(), d->nome.c_str());
            if (d->inicializador) d->inicializador->gerarC();
        } 
        else if (auto* a = dynamic_cast<AssignNode*>(init.get())) {
            printf("%s %s ", a->nome.c_str(), a->op.c_str());
            if (a->valor) a->valor->gerarC();
        }
        printf("; "); if (condicao) condicao->gerarC();
        printf("; "); if (incremento) incremento->gerarC();
        printf(") {\n");
        if (corpo) corpo->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        if (init) init->gerarTAC(nivel);
        std::string label_inicio = GeradorTAC::nova_label();
        std::string label_fim = GeradorTAC::nova_label();
        
        fprintf(stderr, "%s:\n", label_inicio.c_str());
        std::string cond = condicao ? condicao->gerarTAC(nivel + 1) : "true";
        indent(nivel + 1, stderr);
        fprintf(stderr, "if_falso %s goto %s\n", cond.c_str(), label_fim.c_str());
        
        if (corpo) corpo->gerarTAC(nivel + 1);
        if (incremento) incremento->gerarTAC(nivel + 1);
        
        indent(nivel + 1, stderr);
        fprintf(stderr, "goto %s\n", label_inicio.c_str());
        fprintf(stderr, "%s:\n", label_fim.c_str());
        return "";
    }
};

class DeclVetorNode : public ASTNode {
public:
    std::string tipo;
    std::string nome;
    int tamanho;

    DeclVetorNode(std::string t, std::string n, int tam)
        : tipo(t), nome(n), tamanho(tam) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[DeclVetor: %s %s[%d]]\n", tipo.c_str(), nome.c_str(), tamanho);
    }
    
    void gerarC(int nivel = 0) const override { 
        if (variaveis_usadas.find(nome) == variaveis_usadas.end()) {
            return; 
        }
        indent(nivel);
        printf("%s %s[%d];\n", tipo.c_str(), nome.c_str(), tamanho);
    }
    
    std::string gerarTAC(int nivel = 0) const override {
        // 🚀 OTIMIZAÇÃO: Também some do TAC!
        if (variaveis_usadas.find(nome) == variaveis_usadas.end()) {
            return ""; 
        }
        return "";
    }
};

class ArrayAccessNode : public ASTNode {
public:
    std::string nome;
    NodoPtr indice;

    ArrayAccessNode(std::string n, NodoPtr idx)
        : nome(n), indice(std::move(idx)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[ArrayAccess: %s]\n", nome.c_str());
        if (indice) indice->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        printf("%s[", nome.c_str()); if (indice) indice->gerarC(); printf("]");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string idx = indice ? indice->gerarTAC(nivel) : "0";
        std::string t_offset = GeradorTAC::novo_temporario();
        
        indent(nivel, stderr);
        fprintf(stderr, "%s := %s * 4\n", t_offset.c_str(), idx.c_str());
        
        std::string t_val = GeradorTAC::novo_temporario();
        indent(nivel, stderr);
        fprintf(stderr, "%s := %s[%s]\n", t_val.c_str(), nome.c_str(), t_offset.c_str());
        return t_val;
    }
};

class ArrayAssignNode : public ASTNode {
public:
    std::string nome;
    NodoPtr indice;
    NodoPtr valor;

    ArrayAssignNode(std::string n, NodoPtr idx, NodoPtr val)
        : nome(n), indice(std::move(idx)), valor(std::move(val)) {}

    void print(int nivel = 0) const override {
        indent(nivel, stderr); fprintf(stderr, "[ArrayAssign: %s]\n", nome.c_str());
        if (indice) indice->print(nivel + 1);
        if (valor) valor->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override { 
        indent(nivel);
        printf("%s[", nome.c_str()); if (indice) indice->gerarC(); printf("] = ");
        if (valor) valor->gerarC(); printf(";\n");
    }
    std::string gerarTAC(int nivel = 0) const override {
        std::string idx = indice ? indice->gerarTAC(nivel) : "0";
        std::string val = valor ? valor->gerarTAC(nivel) : "0";
        std::string t_offset = GeradorTAC::novo_temporario();
        
        indent(nivel, stderr);
        fprintf(stderr, "%s := %s * 4\n", t_offset.c_str(), idx.c_str());
        indent(nivel, stderr);
        fprintf(stderr, "%s[%s] := %s\n", nome.c_str(), t_offset.c_str(), val.c_str());
        return "";
    }
};

class CaseNode : public ASTNode {
public:
    NodoPtr condicao;
    NodoPtr comandos;

    CaseNode(NodoPtr cond, NodoPtr cmds)
        : condicao(std::move(cond)), comandos(std::move(cmds)) {}
    
    void print(int nivel = 0) const override {
        indent(nivel, stderr);
        if (condicao) fprintf(stderr, "[Case]"); 
        else fprintf(stderr, "[Default]");
        printInfo(stderr);
        fprintf(stderr, "\n");
        if (condicao) condicao->print(nivel + 1);
        if (comandos) comandos->print(nivel + 1);
    }

    void gerarC(int nivel = 0) const override {
        indent(nivel);
        if (condicao) {
            printf("case ");
            condicao->gerarC();
            printf(":\n");
        } else {
            printf("default:\n");
        }
        if (comandos) comandos->gerarC(nivel + 1);
    }

    std::string gerarTAC(int nivel = 0) const override {
        if (comandos) comandos->gerarTAC(nivel);
        return "";
    }
};

class SwitchNode : public ASTNode {
public:
    NodoPtr expressao;
    std::vector<NodoPtr> cases;

    SwitchNode(NodoPtr exp = nullptr) : expressao(std::move(exp)) {}

    void adicionarCase(NodoPtr c) { cases.push_back(std::move(c));}

    void print(int nivel = 0) const override {
        indent(nivel, stderr);
        fprintf(stderr, "[Switch]"); 
        printInfo(stderr);
        fprintf(stderr, "\n");
        if(expressao) expressao->print(nivel + 1);
        for (auto& c : cases) {
            if (c) c->print(nivel + 1);
        }
    }

    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("switch (");
        if (expressao) expressao->gerarC();
        printf(") {\n");
        for (auto& c : cases) {
            if (c) c->gerarC(nivel + 1);
        }
        indent(nivel);
        printf("}\n");
    }

    std::string gerarTAC(int nivel = 0) const override {
        if (expressao) expressao->gerarTAC(nivel);
        for (auto& c : cases) {
            if (c) c->gerarTAC(nivel);
        }
        return "";
    }
};