﻿#ifndef AST_H
#define AST_H
#include <iostream>
#include <sstream>
#include <memory>

inline void dumpIndent(int level, std::string s) {
    for (int i = 0; i < level; ++i) {
        std::cout << "  ";
    }
    std::cout << s << std::endl;
}

class BaseAST {
public:
    virtual ~BaseAST() = default;

    virtual void Dump(int) const = 0;
};

class CompUnitAST : public BaseAST {
public:
    std::unique_ptr<BaseAST> func_def;

    void Dump(int level) const override {
        dumpIndent(level, "CompUnitAST {");
        func_def -> Dump(level + 1);
        dumpIndent(level, "}");
    }
};

class FuncDefAST: public BaseAST {
public:
    std::string ident;
    std::string func_type;
    std::unique_ptr<BaseAST> block;

    void Dump(int level) const override {
        dumpIndent(level, "FuncDefAST {");
        dumpIndent(level + 1, "ident: " + ident);
        dumpIndent(level + 1, "func_type: " + func_type);
        dumpIndent(level + 1, "block: {");
        block -> Dump(level + 2);
        dumpIndent(level + 1, "}");
        dumpIndent(level, "}");
    }
};

class BlockAST: public BaseAST {
public:
    std::unique_ptr<BaseAST> stmt;

    void Dump(int level) const override {
        dumpIndent(level, "BlockAST {");
        stmt -> Dump(level + 1);
        dumpIndent(level, "}");
    }
};

class ReturnStmtAST: public BaseAST {
public:
    std::unique_ptr<BaseAST> exp;

    void Dump(int level) const override {
        dumpIndent(level, "ReturnAST {");
        exp->Dump(level + 1);
        dumpIndent(level, "}");
    }
};

// Exp ::= UnaryExp
class ExpAST: public BaseAST {
public:
    std::unique_ptr<BaseAST> unaryExp;

    void Dump(int level) const override {
        dumpIndent(level, "ExpAST {");
        unaryExp->Dump(level + 1);
        dumpIndent(level, "}");
    }
};

// UnaryExp ::= PrimaryExp | UnaryOp UnaryExp
class UnaryExpAST: public BaseAST {
public:
    int type;
    std::string unary_op;
    std::unique_ptr<BaseAST> primaryExp_unaryExp;

    void Dump(int level) const override {
        if (type == 1) {
            dumpIndent(level, "UnaryExpAST {");
            primaryExp_unaryExp->Dump(level + 1);
            dumpIndent(level, "}");
        } else if (type == 2) {
            dumpIndent(level, "UnaryExpAST {");
            dumpIndent(level + 1, "unary_op: " + unary_op);
            primaryExp_unaryExp->Dump(level + 1);
            dumpIndent(level, "}");
        }
    }
};

// PrimaryExp ::= "(" Exp ")" | Number
class PrimaryExpAST: public BaseAST {
public:
    int type;
    std::unique_ptr<BaseAST> exp_number;

    void Dump(int level) const override {
        dumpIndent(level, "PrimaryAST {");
        exp_number -> Dump(level + 1);
        dumpIndent(level, "}");
    }
};

class NumberAST: public BaseAST {
public:
    int value;

    void Dump(int level) const override {
        dumpIndent(level, "NumberAST {");
        dumpIndent(level + 1, "value: " + std::to_string(value));
        dumpIndent(level, "}");
    }
};

#endif //AST_H
