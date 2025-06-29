/* 以下内容会添加到Bison生成的头文件中 */
%code requires {
    #include <memory>
    #include <string>
    #include "ast.h"
}

/* 以下内容会添加到Bison生成的源文件中 */
%{
#include <iostream>
#include <memory>
#include <string>
#include <cstring>
#include <vector>
#include "ast.h"

int yylex();
void yyerror(std::unique_ptr<BaseAST> &ast, const char *s);

using namespace std;
%}

// 定义 parser 函数
%parse-param { std::unique_ptr<BaseAST> &ast }

// 定义yylval, 是一个union
%union {
    std::string *str_val;
    int int_val;
    BaseAST *ast_val;
    std::vector<std::unique_ptr<BaseAST>> *vec_val;
}

%token RETURN
%token INT
%token PLUS MINUS NOT
%token TIMES DIV MOD
%token LT GT LE GE EQ NE AND OR
%token <str_val> IDENT
%token <int_val> INT_CONST

%type <ast_val> FuncDef Block Stmt Exp PrimaryExp Number
%type <ast_val> LOrExp LAndExp EqExp RelExp AddExp MulExp UnaryExp
%type <ast_val> VarDecl VarDef VarAssign
%type <vec_val> StmtList
%type <str_val> UnaryOp
%%

CompUnit
    : FuncDef {
        auto comp_unit = make_unique<CompUnitAST>();
        comp_unit->func_def = unique_ptr<BaseAST>($1);
        ast = move(comp_unit);
    }
    ;

FuncDef
    : INT IDENT '(' ')' Block {
        auto ast = new FuncDefAST();
        ast->func_type = "int";
        ast->ident = *unique_ptr<string>($2);
        ast->block = unique_ptr<BaseAST>($5);
        $$ = ast;
    }
    ;

Block
    : '{' StmtList '}' {
        auto ast = new BlockAST();
        ast->stmts = unique_ptr<vector<unique_ptr<BaseAST>>>($2);
        $$ = ast;
    }
    ;

StmtList
    : {
        auto vec = new vector<unique_ptr<BaseAST>>();
        $$ = vec;
    }
    | StmtList Stmt {
        auto vec =$1;
        vec->push_back(unique_ptr<BaseAST>($2));
        $$ = vec;
    }
    ;

Stmt
    : RETURN Exp ';' {
        auto ret_ast = new ReturnStmtAST();
        ret_ast->exp = unique_ptr<BaseAST>($2);

        auto ast = new StmtAST();
        ast->type = 1;
        ast->stmt = unique_ptr<BaseAST>(ret_ast);
        $$ = ast;
    }
    | VarDecl ';' {
        auto ast = new StmtAST();
        ast->type = 2;
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | VarAssign ';' {
        auto ast = new StmtAST();
        ast->type = 3;
        ast->stmt = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

VarDecl
    : INT VarDef {
        auto ast = new VarDeclStmtAST();
        ast->var_def = unique_ptr<BaseAST>($2);
        $$ = ast;
    }

VarDef
    : IDENT '=' Exp {
        auto ast = new VarDefAST();
        ast->ident = *unique_ptr<string>($1);
        ast->exp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

VarAssign
    : IDENT '=' Exp {
        auto lval = new LValAST();
        lval->ident = *unique_ptr<string>($1);

        auto ast = new VarAssignStmtAST();
        ast->lval = unique_ptr<BaseAST>(lval);
        ast->exp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

Exp
    : LOrExp {
        auto ast = new ExpAST();
        ast->lorExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    ;

LOrExp
    : LAndExp {
        auto ast = new LOrExpAST();
        ast->type = 1;
        ast->landExp_lorExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | LOrExp OR LAndExp {
        auto ast = new LOrExpAST();
        ast->type = 2;
        ast->landExp_lorExp = unique_ptr<BaseAST>($1);
        ast->landExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

LAndExp
    : EqExp {
        auto ast = new LAndExpAST();
        ast->type = 1;
        ast->eqExp_landExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | LAndExp AND EqExp {
        auto ast = new LAndExpAST();
        ast->type = 2;
        ast->eqExp_landExp = unique_ptr<BaseAST>($1);
        ast->eqExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

EqExp
    : RelExp {
        auto ast = new EqExpAST();
        ast->type = 1;
        ast->relExp_eqExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | EqExp EQ RelExp {
        auto ast = new EqExpAST();
        ast->type = 2;
        ast->eq_op = "==";
        ast->relExp_eqExp = unique_ptr<BaseAST>($1);
        ast->relExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | EqExp NE RelExp {
        auto ast = new EqExpAST();
        ast->type = 2;
        ast->eq_op = "!=";
        ast->relExp_eqExp = unique_ptr<BaseAST>($1);
        ast->relExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

RelExp
    : AddExp {
        auto ast = new RelExpAST();
        ast->type = 1;
        ast->addExp_relExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | RelExp LT AddExp {
        auto ast = new RelExpAST();
        ast->type = 2;
        ast->rel_op = "<";
        ast->addExp_relExp = unique_ptr<BaseAST>($1);
        ast->addExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | RelExp GT AddExp {
        auto ast = new RelExpAST();
        ast->type = 2;
        ast->rel_op = ">";
        ast->addExp_relExp = unique_ptr<BaseAST>($1);
        ast->addExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | RelExp LE AddExp {
        auto ast = new RelExpAST();
        ast->type = 2;
        ast->rel_op = "<=";
        ast->addExp_relExp = unique_ptr<BaseAST>($1);
        ast->addExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | RelExp GE AddExp {
        auto ast = new RelExpAST();
        ast->type = 2;
        ast->rel_op = ">=";
        ast->addExp_relExp = unique_ptr<BaseAST>($1);
        ast->addExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

AddExp
    : MulExp {
        auto ast = new AddExpAST();
        ast->type = 1;
        ast->mulExp_addExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | AddExp PLUS MulExp {
        auto ast = new AddExpAST();
        ast->type = 2;
        ast->add_op = "+";
        ast->mulExp_addExp = unique_ptr<BaseAST>($1);
        ast->mulExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | AddExp MINUS MulExp {
        auto ast = new AddExpAST();
        ast->type = 3;
        ast->add_op = "-";
        ast->mulExp_addExp = unique_ptr<BaseAST>($1);
        ast->mulExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

MulExp
    : UnaryExp {
        auto ast = new MulExpAST();
        ast->type = 1;
        ast->unaryExp_mulExp = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | MulExp TIMES UnaryExp {
        auto ast = new MulExpAST();
        ast->type = 2;
        ast->mul_op = "*";
        ast->unaryExp_mulExp = unique_ptr<BaseAST>($1);
        ast->unaryExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | MulExp DIV UnaryExp {
        auto ast = new MulExpAST();
        ast->type = 2;
        ast->mul_op = "/";
        ast->unaryExp_mulExp = unique_ptr<BaseAST>($1);
        ast->unaryExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    | MulExp MOD UnaryExp {
        auto ast = new MulExpAST();
        ast->type = 2;
        ast->mul_op = "%";
        ast->unaryExp_mulExp = unique_ptr<BaseAST>($1);
        ast->unaryExp = unique_ptr<BaseAST>($3);
        $$ = ast;
    }
    ;

UnaryExp
    : PrimaryExp {
        auto ast = new UnaryExpAST();
        ast->type = 1;
        ast->primaryExp_unaryExp = unique_ptr<BaseAST>($1);
    }
    | UnaryOp UnaryExp {
        auto ast = new UnaryExpAST();
        ast->type = 2;
        ast->unary_op = *unique_ptr<string>($1);
        ast->primaryExp_unaryExp = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    ;

UnaryOp
    : PLUS {
        string *op = new string("+");
        $$ = op;
     }
    | MINUS {
        string *op = new string("-");
        $$ = op;
     }
    | NOT {
        string *op = new string("!");
        $$ = op;
    }
    ;

PrimaryExp
    : '(' Exp ')' {
        auto ast = new PrimaryExpAST();
        ast->type = 1;
        ast->exp_number_lval = unique_ptr<BaseAST>($2);
        $$ = ast;
    }
    | Number {
        auto ast = new PrimaryExpAST();
        ast->type = 2;
        ast->exp_number_lval = unique_ptr<BaseAST>($1);
        $$ = ast;
    }
    | IDENT {
        auto lval = new LValAST();
        lval->ident = *unique_ptr<string>($1);

        auto ast = new PrimaryExpAST();
        ast->type = 3;
        ast->exp_number_lval = unique_ptr<BaseAST>(lval);
        $$ = ast;
    }
    ;

Number
    : INT_CONST {
        auto ast = new NumberAST();
        ast->value = $1;
        $$ = ast;
    }
    ;

%%

void yyerror(unique_ptr<BaseAST> &ast, const char *s) {
    extern int yylineno;
    extern char *yytext;
    int len = strlen(yytext);
    int i;
    char buf[512] = {0};
    for (i=0; i<len; ++i)
        sprintf(buf, "%s%d ", buf, yytext[i]);
    fprintf(stderr, "ERROR: %s at symbol '%s' on line %d\n", s, buf, yylineno);
}