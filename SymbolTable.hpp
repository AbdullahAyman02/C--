#pragma once

#include <iostream>
#include <unordered_map>
#include <vector>

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
    virtual void print();
    string getName();
    int getLine();
    Type getType();
};

class Variable : public Symbol {
   private:
    bool isConstant;

   public:
    Variable(Type type, string name, int line, bool isConstant);
    void print() override;
    bool getIsConstant();
};

class Function : public Symbol {
   private:
    vector<Variable*>* arguments;

   public:
    Function(string name, Type returnType, vector<Variable*>* arguments, int line);
    vector<Variable*>* getArguments();
    void print() override;
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
