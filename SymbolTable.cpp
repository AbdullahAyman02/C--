#include "SymbolTable.hpp"

#include <algorithm>
#include <cstring>

#include "common.h"
static string getTypeName(Type type);

Symbol::Symbol(string name, Type type, int line) {
    this->name = name;
    this->type = type;
    this->line = line;
}

void Symbol::print() {
    cout << "General Symbol" << " " << this->name << endl;
}

string Symbol::getName() {
    return this->name;
}

Variable::Variable(Type type, string name, int line, bool isConstant) : Symbol(name, type, line) {
    this->isConstant = isConstant;
}

int Symbol::getLine() {
    return this->line;
}

Type Symbol::getType() {
    return this->type;
}

void Variable::print() {
    cout << "Variable" << " " << this->getName() << " Type " << getTypeName(this->getType()) << endl;
}

bool Variable::getIsConstant() {
    return false;
}

Function::Function(string name, Type returnType, vector<Variable*>* arguments, int line) : Symbol(name, returnType, line) {
    this->arguments = arguments;
}

vector<Variable*>* Function::getArguments() {
    return this->arguments;
}

void Function::print() {
    cout << "Function" << " " << this->getName() << endl;
    cout << "Return type: " << getTypeName(this->getType()) << endl;
    cout << "Parameters: " << endl;
    if (this->arguments == nullptr) {
        cout << "None" << endl;
        return;
    }
    for (Variable* param : *this->arguments) {
        param->print();
    }
}

SymbolTable::SymbolTable() {
}

SymbolTable::SymbolTable(SymbolTable* parent) {
    this->parent = parent;
}

void SymbolTable::insert(Symbol* symbol) {
    string name = symbol->getName();
    Symbol* existing = lookup(name);
    if (existing != nullptr) {
        throw "Symbol " + name + " already exists in line " + to_string(existing->getLine());
    }
    this->symbols[name] = symbol;
}

Symbol* SymbolTable::lookup(string name) {
    SymbolTable* current = this;
    while (current != nullptr) {
        auto it = current->symbols.find(name);
        if (it != current->symbols.end()) {
            return it->second;
        }
        current = current->getParent();
    }
    return nullptr;
}

SymbolTable* SymbolTable::getParent() {
    return this->parent;
}

SymbolTable* SymbolTable::createChild() {
    return new SymbolTable(this);
}

void SymbolTable::print() {
    for (auto it = this->symbols.begin(); it != this->symbols.end(); ++it) {
        it->second->print();
    }
}

static SymbolTable globalSymbolTable;
static SymbolTable* currentSymbolTable = &globalSymbolTable;
static string getTypeName(Type type);
extern "C" {

void enterScope() {
    currentSymbolTable = currentSymbolTable->createChild();
}

void exitScope() {
    SymbolTable* parent = currentSymbolTable->getParent();
    exitOnError("Cannot exit global scope", 0);
    currentSymbolTable = parent;
}

void addSymbolToSymbolTable(void* symbol) {
    Symbol* var = (Symbol*)symbol;
    try {
        currentSymbolTable->insert(var);
    } catch (string e) {
        exitOnError(e.c_str(), var->getLine());
    }
}

void* createVariable(Type type, const char* name, int line, int isConstant) {
    Variable* variable = new Variable(type, name, line, isConstant);
    return (void*)variable;
}

void* createFunction(Type returnType, const char* name, void* paramList, int line) {
    vector<Variable*>* arguments = (vector<Variable*>*)paramList;
    reverse(arguments->begin(), arguments->end());
    Function* function = new Function(name, returnType, arguments, line);
    return (void*)function;
}

void* getSymbolFromSymbolTable(const char* name, int line) {
    Symbol* symbol = currentSymbolTable->lookup(name);
    if (symbol == nullptr) {
        string message = "Symbol " + string(name) + " not found";
        exitOnError(message.c_str(), line);
    }
    return (void*)symbol;
}

void checkBothParamsAreNumbers(Type type1, Type type2, int line) {
    if (type1 != INTEGER_T && type1 != FLOAT_T) {
        string message = "First parameter is not a number";
        exitOnError(message.c_str(), line);
    }
    if (type2 != INTEGER_T && type2 != FLOAT_T) {
        string message = "Second parameter is not a number";
        exitOnError(message.c_str(), line);
    }
    checkBothParamsAreOfSameType(type1, type2, line);
}

void checkBothParamsAreBoolean(Type type1, Type type2, int line) {
    if (type1 != BOOLEAN_T) {
        string message = "First parameter is not a boolean";
        exitOnError(message.c_str(), line);
    }
    if (type2 != BOOLEAN_T) {
        string message = "Second parameter is not a boolean";
        exitOnError(message.c_str(), line);
    }
    checkBothParamsAreOfSameType(type1, type2, line);
}

void useVariableFromSymbolTable(const char* name) {
    Symbol* symbol = currentSymbolTable->lookup(name);
    if (symbol == nullptr) {
        throw "Symbol " + string(name) + " not found";
    }
}

void checkBothParamsAreOfSameType(Type type1, Type type2, int line) {
    if (type1 != type2) {
        string message = "Parameters are not of the same type ";
        message += "First parameter is of type " + getTypeName(type1) + " ,";
        message += "Second parameter is of type " + getTypeName(type2);
        exitOnError(message.c_str(), line);
    }
}

void checkParamIsNumber(Type type, int line) {
    if (type != INTEGER_T && type != FLOAT_T) {
        string message = "Parameter is not a number";
        exitOnError(message.c_str(), line);
    }
}

void printSymbolTable() {
    currentSymbolTable->print();
}

Type getSymbolType(void* symbol) {
    Symbol* sym = (Symbol*)symbol;
    return sym->getType();
}

void* createArgumentList() {
    return (void*)new vector<Variable*>();
}

void addVariableToArgumentList(void* paramList, void* variable) {
    vector<Variable*>* arguments = (vector<Variable*>*)paramList;
    Variable* var = (Variable*)variable;
    arguments->push_back(var);
}

void* createParamList() {
    return (void*)new vector<Type>();
}

void addTypeToParamList(void* paramList, Type type) {
    vector<Type>* arguments = (vector<Type>*)paramList;
    arguments->push_back(type);
}

void checkParamListAgainstFunction(void* paramList, void* function, int line) {
    vector<Type>* params = (vector<Type>*)paramList;
    Function* func = (Function*)function;
    vector<Variable*>* arguments = func->getArguments();
    reverse(params->begin(), params->end());
    if (params->size() != arguments->size()) {
        string message = "Function " + func->getName() + " expects " + to_string(arguments->size()) + " arguments";
        message += " but " + to_string(params->size()) + " were provided";
        exitOnError(message.c_str(), line);
    }
    for (int i = 0; i < params->size(); i++) {
        Type paramType = params->at(i);
        Type argType = arguments->at(i)->getType();
        if (paramType != argType) {
            string message = "Function " + func->getName() + " expects argument " + to_string(i + 1) + " to be of type ";
            message += getTypeName(argType) + " but " + getTypeName(paramType) + " was provided";
            exitOnError(message.c_str(), line);
        }
    }
}

const char* convertFloatNumToChar(float num) {
    string str = to_string(num);
    return str.c_str();
}

const char* convertIntNumToChar(int num) {
    string str = to_string(num);
    return strdup(str.c_str());
}
}

static string getTypeName(Type type) {
    switch (type) {
        case INTEGER_T:
            return "integer";
        case FLOAT_T:
            return "float";
        case CHAR_T:
            return "char";
        case STRING_T:
            return "string";
        case BOOLEAN_T:
            return "boolean";
        case VOID_T:
            return "void";
    }
    return "unknown";
}