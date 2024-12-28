#include "SymbolTable.hpp"

#include <algorithm>
#include <cstring>

#include "Vendor/VariadicTable.h"
#include "common.h"
static string getTypeName(Type type);

Symbol::Symbol(string name, Type type, int line) {
    this->name = name;
    this->type = type;
    this->line = line;
}

void Symbol::print(VariadicTable<string, string, string, string>& vt) {
    cout << this->getName() << "   " << "Symbol" << "   " << getTypeName(this->getType()) << "   " << " - " << endl;
}

string Symbol::getName() {
    return this->name;
}

Variable::Variable(Type type, string name, int line, bool isConstant, bool isFuncArgument, bool isInitialized) : Symbol(name, type, line) {
    this->isConstant = isConstant;
    this->isFuncArg = isFuncArgument;
    this->isInitialized = isInitialized;
}

int Symbol::getLine() {
    return this->line;
}

Type Symbol::getType() {
    return this->type;
}

void Variable::print(VariadicTable<string, string, string, string>& vt) {
    string kind = this->getIsFuncArg() ? "Arg" : "Var";
    string otherColumn = (this->getIsConstant()) ? "Const" : " - ";
    vt.addRow(this->getName(), kind, getTypeName(this->getType()), otherColumn);
}

bool Variable::getIsConstant() {
    return this->isConstant;
}

bool Variable::getIsFuncArg() {
    return this->isFuncArg;
}

bool Variable::getIsInitialized() {
    return this->isInitialized;
}

void Variable::setIsInitialized(bool isInitialized) {
    this->isInitialized = isInitialized;
}

void Variable::setIsFuncArg(bool isFuncArg) {
    this->isFuncArg = isFuncArg;
}

Function::Function(string name, Type returnType, vector<Variable*>* arguments, int line) : Symbol(name, returnType, line) {
    this->arguments = arguments;
}

vector<Variable*>* Function::getArguments() {
    return this->arguments;
}

void Function::print(VariadicTable<string, string, string, string>& vt) {
    int argumentCount = this->arguments->size();
    string arguments = "args Cnt = " + to_string(argumentCount);
    vt.addRow(this->getName(), "Func", getTypeName(this->getType()), arguments);
    for (Variable* param : *this->arguments) {
        param->print(vt);
    }
}

bool Function::getIsReturnStatementPresent() {
    return this->isReturnStatementPresent;
}

void Function::setIsReturnStatementPresent(bool isReturnStatementPresent) {
    this->isReturnStatementPresent = isReturnStatementPresent;
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
    VariadicTable<string, string, string, string> vt({"Name", "Kind", "Type", "Other"});
    for (auto it = this->symbols.begin(); it != this->symbols.end(); ++it) {
        it->second->print(vt);
    }
    vt.print(cout);
}

static SymbolTable globalSymbolTable;
static SymbolTable* currentSymbolTable = &globalSymbolTable;
static string getTypeName(Type type);

struct FunctionMetadata {
    bool isFunctionConsumedInScopeCheck;
    Function* function;
};

struct SwitchCaseMetadata {
    Type type;
    int line;
};

static vector<FunctionMetadata> functionContext;

extern "C" {

static void pushFunctionArgumentListIfExistsToScopeSymbolTable() {
    if (functionContext.empty() || functionContext.back().function == nullptr || functionContext.back().isFunctionConsumedInScopeCheck) {
        functionContext.push_back({true, nullptr});
        return;
    }
    FunctionMetadata& functionMetadata = functionContext.back();
    if (functionMetadata.isFunctionConsumedInScopeCheck) {
        return;
    }
    for (auto arg : *functionMetadata.function->getArguments()) {
        try {
            Variable* var = new Variable(arg->getType(), arg->getName(), arg->getLine(), arg->getIsConstant(), false, true);
            currentSymbolTable->insert(var);
        } catch (string e) {
            exitOnError(e.c_str(), arg->getLine());
        }
    }
    functionMetadata.isFunctionConsumedInScopeCheck = true;
}

static void checkReturnStatementIsPresent(Function* function) {
    if (function == nullptr) {
        return;
    }

    if (function->getType() == VOID_T) {
        return;
    }

    if (!function->getIsReturnStatementPresent()) {
        string message = "Function " + function->getName() + " does not have a return statement";
        exitOnError(message.c_str(), function->getLine());
    }
};

static void popFunctionArgumentListIfExists() {
    if (functionContext.empty()) {
        return;
    }
    Function* function = functionContext.back().function;
    functionContext.pop_back();

    checkReturnStatementIsPresent(function);
}

static Function* getCurrentFunction() {
    if (functionContext.empty()) {
        return nullptr;
    }
    for (auto it = functionContext.rbegin(); it != functionContext.rend(); ++it) {
        if (it->function != nullptr) {
            return it->function;
        }
    }
    return nullptr;
}

void checkReturnStatementIsValid(Type returnType, int line) {
    Function* currentFunction = getCurrentFunction();
    if (currentFunction == nullptr) {
        exitOnError("Return statement outside of function", line);
    }

    if (currentFunction->getType() != returnType) {
        string message = "Return type mismatch. Expected " + getTypeName(currentFunction->getType());
        message += " but got " + getTypeName(returnType);
        exitOnError(message.c_str(), line);
    }

    currentFunction->setIsReturnStatementPresent(true);
}

void enterScope() {
    currentSymbolTable = currentSymbolTable->createChild();
    pushFunctionArgumentListIfExistsToScopeSymbolTable();
}

void exitScope(int line) {
    SymbolTable* parent = currentSymbolTable->getParent();
    if (parent == nullptr) {
        exitOnError("Cannot exit global scope", line);
    }
    popFunctionArgumentListIfExists();
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

    for (auto arg : *arguments) {
        arg->setIsFuncArg(true);
        arg->setIsInitialized(true);
    }

    Function* function = new Function(name, returnType, arguments, line);

    functionContext.push_back({false, function});

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

void setVariableAsInitialized(void* symbol) {
    Variable* var = (Variable*)symbol;
    var->setIsInitialized(true);
}

void* getVariableFromSymbolTable(const char* name, int line) {
    Symbol* symbol = (Symbol*)getSymbolFromSymbolTable(name, line);
    Variable* var = dynamic_cast<Variable*>(symbol);
    if (var == nullptr) {
        string message = "Symbol " + string(name) + " is not a variable";
        exitOnError(message.c_str(), line);
    }
    if (!var->getIsInitialized()) {
        string message = "Variable " + string(name) + " is not initialized";
        exitOnError(message.c_str(), line);
    }
    return (void*)var;
}

void checkVariableIsNotConstant(void* symbol, int line) {
    Variable* var = (Variable*)symbol;
    if (var->getIsConstant()) {
        string message = "Variable " + var->getName() + " is constant";
        exitOnError(message.c_str(), line);
    }
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

const char* convertNumToChar(void* num, Type type) {
    if (type == FLOAT_T) {
        return convertFloatNumToChar(*(float*)num);
    }
    return convertIntNumToChar(*(int*)num);
}

void* createSwitchCaseList() {
    return (void*)new vector<SwitchCaseMetadata>();
}

void addCaseToSwitchCaseList(void* switchCaseList, Type type, int line) {
    vector<SwitchCaseMetadata>* switchCases = (vector<SwitchCaseMetadata>*)switchCaseList;
    switchCases->push_back({type, line});
}

void checkSwitchCaseListAgainstType(void* switchCaseList, Type type) {
    vector<SwitchCaseMetadata>* switchCases = (vector<SwitchCaseMetadata>*)switchCaseList;
    for (SwitchCaseMetadata switchCase : *switchCases) {
        if (switchCase.type != type) {
            string message = "Switch case expects type " + getTypeName(type) + " but got " + getTypeName(switchCase.type);
            exitOnError(message.c_str(), switchCase.line);
        }
    }
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