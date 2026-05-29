#pragma once
#include <string>
#include <vector>
#include <memory>
#include <cstdio>

class ASTNode;
using NodoPtr = std::unique_ptr<ASTNode>;

class ASTNode {
public:
    int         linha         = 0;
    std::string tipo_inferido = "";

    virtual ~ASTNode() = default;
    virtual void print(int nivel = 0)  const = 0;
    virtual void gerarC(int nivel = 0) const = 0;

protected:
    void indent(int nivel) const {
        for (int i = 0; i < nivel; i++) printf("    ");
    }
    void printInfo() const {
        if (linha > 0)
            printf(" (linha %d)", linha);
        if (!tipo_inferido.empty())
            printf(" [tipo: %s]", tipo_inferido.c_str());
    }
};

class LiteralInteiroNode : public ASTNode {
public:
    int valor;
    explicit LiteralInteiroNode(int v) : valor(v) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[LiteralInteiro] %d", valor);
        printInfo();
        printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        printf("%d", valor);
    }
};

class LiteralFloatNode : public ASTNode {
public:
    float valor;
    explicit LiteralFloatNode(float v) : valor(v) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[LiteralFloat] %g", valor);
        printInfo();
        printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        printf("%g", valor);
    }
};

class LiteralStringNode : public ASTNode {
public:
    std::string valor;
    explicit LiteralStringNode(const char* v) : valor(v) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[LiteralString] %s", valor.c_str());
        printInfo();
        printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        printf("%s", valor.c_str());
    }
};

class IdentificadorNode : public ASTNode {
public:
    std::string nome;
    explicit IdentificadorNode(const char* n) : nome(n) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Identificador] %s", nome.c_str());
        printInfo();
        printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        printf("%s", nome.c_str());
    }
};

class OperacaoBinariaNode : public ASTNode {
public:
    std::string operador;
    NodoPtr     esquerda;
    NodoPtr     direita;

    OperacaoBinariaNode(const char* op, NodoPtr esq, NodoPtr dir)
        : operador(op), esquerda(std::move(esq)), direita(std::move(dir)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[OperacaoBinaria] %s", operador.c_str());
        printInfo();
        printf("\n");
        esquerda->print(nivel + 1);
        direita->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        if (!direita) {
            printf("%s", operador.c_str());
            esquerda->gerarC();
        } else {
            esquerda->gerarC();
            printf(" %s ", operador.c_str());
            direita->gerarC();
        }
    }
};

class ExpParenNode : public ASTNode {
public:
    NodoPtr expr;
    explicit ExpParenNode(NodoPtr e) : expr(std::move(e)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Parenteses]");
        printInfo();
        printf("\n");
        expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        printf("("); expr->gerarC(); printf(")");
    }
};

class DeclVarNode : public ASTNode {
public:
    std::string tipo;
    std::string nome;
    NodoPtr     inicializador;

    DeclVarNode(const char* tipo, const char* nome, NodoPtr init = nullptr)
        : tipo(tipo), nome(nome), inicializador(std::move(init)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[DeclVar] %s %s%s",
               tipo.c_str(), nome.c_str(),
               inicializador ? " = ..." : "");
        printInfo();
        printf("\n");
        if (inicializador) inicializador->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("%s %s", tipo.c_str(), nome.c_str());
        if (inicializador) { printf(" = "); inicializador->gerarC(); }
        printf(";\n");
    }
};

class CmdReturnNode : public ASTNode {
public:
    NodoPtr expr;
    explicit CmdReturnNode(NodoPtr e) : expr(std::move(e)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Return]");
        printInfo();
        printf("\n");
        expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("return "); expr->gerarC(); printf(";\n");
    }
};

class CmdCoutNode : public ASTNode {
public:
    NodoPtr expr;
    explicit CmdCoutNode(NodoPtr e) : expr(std::move(e)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Cout]");
        printInfo();
        printf("\n");
        expr->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        if (auto* s = dynamic_cast<LiteralStringNode*>(expr.get())) {
            printf("printf(%s);\n", s->valor.c_str());
        } else {
            printf("printf(\"%%g\\n\", ");
            expr->gerarC();
            printf(");\n");
        }
    }
};

class CmdCinNode : public ASTNode {
public:
    std::string variavel;
    explicit CmdCinNode(const char* var) : variavel(var) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Cin] >> %s", variavel.c_str());
        printInfo();
        printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("scanf(\"%%g\", &%s);\n", variavel.c_str());
    }
};

class BlocoNode : public ASTNode {
public:
    std::vector<NodoPtr> comandos;

    void adicionar(NodoPtr cmd) { comandos.push_back(std::move(cmd)); }

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Bloco] (%zu comandos)", comandos.size());
        printInfo();
        printf("\n");
        for (auto& c : comandos) c->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        for (auto& c : comandos) c->gerarC(nivel);
    }
};

class FuncaoNode : public ASTNode {
public:
    std::string tipo_retorno;
    std::string nome;
    NodoPtr     corpo;

    FuncaoNode(const char* tipo, const char* nome, NodoPtr corpo)
        : tipo_retorno(tipo), nome(nome), corpo(std::move(corpo)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Funcao] %s %s()", tipo_retorno.c_str(), nome.c_str());
        printInfo();
        printf("\n");
        corpo->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("%s %s() {\n", tipo_retorno.c_str(), nome.c_str());
        corpo->gerarC(nivel + 1);
        indent(nivel);
        printf("}\n");
    }
};

class ProgramaNode : public ASTNode {
public:
    std::vector<NodoPtr> declaracoes;

    void adicionar(NodoPtr decl) { declaracoes.push_back(std::move(decl)); }

    void print(int nivel = 0) const override {
        printf("[Programa] (%zu declaracoes)\n", declaracoes.size());
        for (auto& d : declaracoes) d->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        printf("#include <stdio.h>\n");
        printf("#include <stdbool.h>\n\n");
        for (auto& d : declaracoes) d->gerarC(nivel);
    }
};

class BreakNode : public ASTNode {
public:
    void print(int nivel = 0) const override {
        indent(nivel); printf("[Break]"); printInfo(); printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("break;\n");
    }
};

class ContinueNode : public ASTNode {
public:
    void print(int nivel = 0) const override {
        indent(nivel); printf("[Continue]"); printInfo(); printf("\n");
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("continue;\n");
    }
};

class AssignNode : public ASTNode {
public:
    std::string nome;
    std::string op;
    NodoPtr     valor;

    AssignNode(const char* nome, const char* op, NodoPtr valor)
        : nome(nome), op(op), valor(std::move(valor)) {}

    void print(int nivel = 0) const override {
        indent(nivel);
        printf("[Assign] %s %s", nome.c_str(), op.c_str());
        printInfo(); printf("\n");
        valor->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel);
        printf("%s %s ", nome.c_str(), op.c_str());
        valor->gerarC();
        printf(";\n");
    }
};

class IfNode : public ASTNode {
public:
    NodoPtr condicao;
    NodoPtr entao;
    NodoPtr senao;

    IfNode(NodoPtr cond, NodoPtr entao, NodoPtr senao = nullptr)
        : condicao(std::move(cond)), entao(std::move(entao)), senao(std::move(senao)) {}

    void print(int nivel = 0) const override {
        indent(nivel); printf("[If]"); printInfo(); printf("\n");
        condicao->print(nivel + 1);
        entao->print(nivel + 1);
        if (senao) senao->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("if ("); condicao->gerarC(); printf(") {\n");
        entao->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
        if (senao) {
            indent(nivel); printf("else {\n");
            senao->gerarC(nivel + 1);
            indent(nivel); printf("}\n");
        }
    }
};

class WhileNode : public ASTNode {
public:
    NodoPtr condicao;
    NodoPtr corpo;

    WhileNode(NodoPtr cond, NodoPtr corpo)
        : condicao(std::move(cond)), corpo(std::move(corpo)) {}

    void print(int nivel = 0) const override {
        indent(nivel); printf("[While]"); printInfo(); printf("\n");
        condicao->print(nivel + 1);
        corpo->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("while ("); condicao->gerarC(); printf(") {\n");
        corpo->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
    }
};

class DoWhileNode : public ASTNode {
public:
    NodoPtr corpo;
    NodoPtr condicao;

    DoWhileNode(NodoPtr corpo, NodoPtr cond)
        : corpo(std::move(corpo)), condicao(std::move(cond)) {}

    void print(int nivel = 0) const override {
        indent(nivel); printf("[DoWhile]"); printInfo(); printf("\n");
        corpo->print(nivel + 1);
        condicao->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("do {\n");
        corpo->gerarC(nivel + 1);
        indent(nivel); printf("} while ("); condicao->gerarC(); printf(");\n");
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
        indent(nivel); printf("[For]"); printInfo(); printf("\n");
        init->print(nivel + 1);
        condicao->print(nivel + 1);
        incremento->print(nivel + 1);
        corpo->print(nivel + 1);
    }
    void gerarC(int nivel = 0) const override {
        indent(nivel); printf("for (");
        if (auto* d = dynamic_cast<DeclVarNode*>(init.get())) {
            printf("%s %s = ", d->tipo.c_str(), d->nome.c_str());
            if (d->inicializador) d->inicializador->gerarC();
        }
        printf("; "); condicao->gerarC();
        printf("; "); incremento->gerarC();
        printf(") {\n");
        corpo->gerarC(nivel + 1);
        indent(nivel); printf("}\n");
    }
};
