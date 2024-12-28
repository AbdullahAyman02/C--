#pragma once

#include <iostream>
#include <unordered_map>
#include <vector>

#include "Vendor/VariadicTable.h"
#include "common.h"
using namespace std;

class Symbol {
   private:
    string name;
    Type type;
    int line;

   public:
    Symbol(string name, Type type, int line);
    Symbol() = default;
    virtual void print(VariadicTable<string, string, string, string>& vt);
    string getName();
    int getLine();
    Type getType();
};

class Variable : public Symbol {
   private:
    bool isConstant;
    bool isFuncArg;
    bool isInitialized = false;

   public:
    Variable(Type type, string name, int line, bool isConstant, bool isFuncArg = false, bool isInitialized = false);
    void print(VariadicTable<string, string, string, string>& vt) override;
    bool getIsConstant();
    bool getIsFuncArg();
    bool getIsInitialized();
    void setIsInitialized(bool isInitialized);
    void setIsFuncArg(bool isFuncArg);
};

class Function : public Symbol {
   private:
    vector<Variable*>* arguments;
    bool isReturnStatementPresent = false;

   public:
    Function(string name, Type returnType, vector<Variable*>* arguments, int line);
    vector<Variable*>* getArguments();
    void print(VariadicTable<string, string, string, string>& vt) override;
    bool getIsReturnStatementPresent();
    void setIsReturnStatementPresent(bool isReturnStatementPresent);
};

class SymbolTable {
   private:
    unordered_map<string, Symbol*> symbols;
    SymbolTable* parent;

   public:
    SymbolTable();
    SymbolTable(SymbolTable* parent);
    void insert(Symbol* symbol);
    Symbol* lookup(string name);
    SymbolTable* getParent();
    SymbolTable* createChild();
    void print();
};
