#include "QuadrupleManager.hpp"

#include <string.h>
#include <sstream>
#include <fstream>

#include "SymbolTable.hpp"
#include "Vendor/VariadicTable.h"
#include "common.h"
void QuadrupleManager::addQuadruple(const string &op, const string &arg1, const string &arg2, const string &result) {
    printf("Adding quadruple: %s %s %s %s\n", op.c_str(), arg1.c_str(), arg2.c_str(), result.c_str());
    quadruples.emplace_back(op, arg1, arg2, result);
}

void QuadrupleManager::addQuadruple(const Quadruple &quadruple) {
    quadruples.push_back(quadruple);
}

void QuadrupleManager::addQuadrupleInFront(const string &op, const string &arg1, const string &arg2, const string &result) {
    quadruples.insert(quadruples.begin(), Quadruple(op, arg1, arg2, result));
}

void QuadrupleManager::addQuadrupleInFront(const Quadruple &quadruple) {
    quadruples.insert(quadruples.begin(), quadruple);
}

string QuadrupleManager::newTemp() {
    return "T" + std::to_string(tempCount++);
}

string QuadrupleManager::newLabel() {
    return "L" + std::to_string(labelCount++) + ":";
}

int QuadrupleManager::generateNewExitLabel() {
    exitLabel = labelCount++;
    return exitLabel;
}

int QuadrupleManager::getExitLabel() {
    return exitLabel;
}

vector<Quadruple> QuadrupleManager::getQuadruples() {
    return this->quadruples;
}

string QuadrupleManager::allocMap(string var)
{
    if (registerMap.find(var) != registerMap.end()) {
        return registerMap[var];
    } else {
        string newReg = "R" + std::to_string(registerCount++);
        registerMap[var] = newReg;
        return newReg;
    }
}
string QuadrupleManager::getRegister(string var)
{
    return registerMap[var];
}

void QuadrupleManager::printQuadruples(const string& inputFileName) {
    VariadicTable<string, string, string, string, string> vt({"Index", "Op", "Arg1", "Arg2", "Result"});

    for (size_t i = 0; i < quadruples.size(); ++i) {
        quadruples[i].display(i, vt);
    }

    std::ostringstream oss;
    vt.print(oss);
    string output = oss.str();
    printf("%s", output.c_str());
    printf("Input file name: %s\n", inputFileName.c_str());

    if (!inputFileName.empty()) {
        string outputFileName = inputFileName;
        size_t pos = outputFileName.find("input");
        if (pos != string::npos) {
            outputFileName.replace(pos, 5, "output");
        }

        // Insert "_quadruples" before extension
        size_t dotPos = outputFileName.find_last_of('.');
        if (dotPos != string::npos) {
            outputFileName.insert(dotPos, "_quadruples");
        }

        printf("Writing quadruples to %s\n", outputFileName.c_str());

        ofstream outFile(outputFileName);
        if (!outFile) {
            cerr << "Error: Could not open " << outputFileName << " for writing" << endl;
            return;
        }
        outFile << output;
        outFile.close();
    }
}

int QuadrupleManager::tempCount = 0;
int QuadrupleManager::labelCount = 0;
int QuadrupleManager::registerCount = 0;
map<string, string> QuadrupleManager::registerMap;

static QuadrupleManager mainQuadrupleManager;

vector<QuadrupleManager *> quadrupleManagers = {&mainQuadrupleManager};
vector<string> caseExpression;

extern "C" {

void addQuadrupleToQuadManager(void *quadManager, const char *op, const char *arg1, const char *arg2, const char *result) {
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    quadManagerPtr->addQuadruple(op, arg1, arg2, result);
}

void addQuadrupleToQuadManagerInFront(void *quadManager, const char *op, const char *arg1, const char *arg2, const char *result) {
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    quadManagerPtr->addQuadrupleInFront(Quadruple(op, arg1, arg2, result));
}

void addCaseExpression(const char *expr) {
    caseExpression.push_back(expr);
}

const char *getCurrentCaseExpression() {
    return strdup(caseExpression.back().c_str());
}

void removeLastCaseExpression() {
    caseExpression.pop_back();
}

const char *generateNewExitLabelFromCurrentQuadManager() {
    int labelId = quadrupleManagers.back()->generateNewExitLabel();
    return strdup(("L" + std::to_string(labelId) + ":").c_str());
}

const char *getExitLabelFromCurrentQuadManager() {
    int labelId = quadrupleManagers.back()->getExitLabel();
    return strdup(("L" + std::to_string(labelId) + ":").c_str());
}

void enterQuadManager() {
    QuadrupleManager *quadManager = new QuadrupleManager();
    quadrupleManagers.push_back(quadManager);
}

void *exitQuadManager() {
    QuadrupleManager *quadManager = quadrupleManagers.back();
    quadrupleManagers.pop_back();
    return (void *)quadManager;
}

void addQuadrupleToCurrentQuadManager(const char *op, const char *arg1, const char *arg2, const char *result) {
    quadrupleManagers.back()->addQuadruple(op, arg1, arg2, result);
}

void mergeQuadManagerToCurrentQuadManager(void *quadManager) {
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    QuadrupleManager *prevQuadManager = quadrupleManagers.back();
    for (auto quad : quadManagerPtr->getQuadruples()) {
        prevQuadManager->addQuadruple(quad);
    }
}

void mergeQuadManagerToCurrentQuadManagerInFront(void *quadManager) {
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    QuadrupleManager *prevQuadManager = quadrupleManagers.back();
    // reverse iterate
    vector<Quadruple> quads = quadManagerPtr->getQuadruples();
    for (auto it = quads.rbegin(); it != quads.rend(); ++it) {
        prevQuadManager->addQuadrupleInFront(*it);
    }
}

void handleFunctionQuadruples(void *quadManager, void *function) {
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    Function *func = (Function *)function;
    vector<Variable *> *arguments = func->getArguments();
    for (auto arg : *arguments) {
        string argName = arg->getName();
        quadManagerPtr->addQuadrupleInFront("POP", "", "", argName);
    }
    string returnLabel = "ret_" + func->getLabel() + "_var";
    quadManagerPtr->addQuadrupleInFront("POP", "", "", returnLabel);
    string returnLabelContent = "content(" + string(returnLabel) + ")";
    quadManagerPtr->addQuadruple("JMP", returnLabelContent, "", "");
}

void handleFunctionReturnQuadruples() {
    Function *function = FunctionContextSingleton::getCurrentFunction();
    string returnLabel = "ret_" + function->getLabel() + "_var";
    string returnLabelContent = "content(" + string(returnLabel) + ")";
    addQuadrupleToCurrentQuadManager("JMP", returnLabelContent.c_str(), "", "");
}

void handleFunctionReturnWithExprQuadruples(const char *expr) {
    addQuadrupleToCurrentQuadManager("PUSH", expr, "", "");
    handleFunctionReturnQuadruples();
}

void handleFunctionCallQuadruples(void *function, void *paramList, const char *returnVar) {
    Function *func = (Function *)function;
    vector<Parameter> *params = (vector<Parameter> *)paramList;
    vector<Variable *> *arguments = func->getArguments();
    const char *returnLabel = newLabel();
    for (int i = 0; i < params->size(); i++) {
        addQuadrupleToCurrentQuadManager("PUSH", params->at(i).name.c_str(), "", "");
    }
    addQuadrupleToCurrentQuadManager("PUSH", returnLabel, "", "");
    addQuadrupleToCurrentQuadManager("JMP", func->getLabel().c_str(), "", "");

    addQuadrupleToCurrentQuadManager(returnLabel, "", "", "");
    if (func->getType() != VOID_T) {
        addQuadrupleToCurrentQuadManager("POP", "", "", returnVar);
    }
}

void handleForLoopQuadruples(const char *booleanExprVar, void *booleanExprQuadManager, void *assignmentQuadManager, void *scopeQuadManager) {
    QuadrupleManager *booleanExprQuadManagerPtr = (QuadrupleManager *)booleanExprQuadManager;
    QuadrupleManager *assignmentQuadManagerPtr = (QuadrupleManager *)assignmentQuadManager;
    QuadrupleManager *scopeQuadManagerPtr = (QuadrupleManager *)scopeQuadManager;

    string forLabel = newLabel();
    string endForLabel = newLabel();
    addQuadrupleToCurrentQuadManager(forLabel.c_str(), "", "", "");
    mergeQuadManagerToCurrentQuadManager(booleanExprQuadManagerPtr);
    addQuadrupleToCurrentQuadManager("JF", booleanExprVar, "", endForLabel.c_str());
    mergeQuadManagerToCurrentQuadManager(scopeQuadManagerPtr);
    mergeQuadManagerToCurrentQuadManager(assignmentQuadManagerPtr);
    addQuadrupleToCurrentQuadManager("JMP", forLabel.c_str(), "", "");
    addQuadrupleToCurrentQuadManager(endForLabel.c_str(), "", "", "");
}

void handleRepeatUntilQuadruples(const char *booleanExprVar, void *booleanExprQuadManager, void *scopeQuadManager) {
    QuadrupleManager *booleanExprQuadManagerPtr = (QuadrupleManager *)booleanExprQuadManager;
    QuadrupleManager *scopeQuadManagerPtr = (QuadrupleManager *)scopeQuadManager;

    string repeatLabel = newLabel();
    string endLabel = newLabel();

    addQuadrupleToCurrentQuadManager(repeatLabel.c_str(), "", "", "");
    mergeQuadManagerToCurrentQuadManager(scopeQuadManagerPtr);
    mergeQuadManagerToCurrentQuadManager(booleanExprQuadManagerPtr);
    addQuadrupleToCurrentQuadManager("JF", booleanExprVar, "", endLabel.c_str());
    addQuadrupleToCurrentQuadManager("JMP", repeatLabel.c_str(), "", "");
    addQuadrupleToCurrentQuadManager(endLabel.c_str(), "", "", "");
}

void handleWhileQuadruples(const char *booleanExprVar, void *booleanExprQuadManager, void *scopeQuadManager) {
    QuadrupleManager *booleanExprQuadManagerPtr = (QuadrupleManager *)booleanExprQuadManager;
    QuadrupleManager *scopeQuadManagerPtr = (QuadrupleManager *)scopeQuadManager;

    string whileLabel = newLabel();
    string endLabel = newLabel();

    addQuadrupleToCurrentQuadManager(whileLabel.c_str(), "", "", "");
    mergeQuadManagerToCurrentQuadManager(booleanExprQuadManagerPtr);
    addQuadrupleToCurrentQuadManager("JF", booleanExprVar, "", endLabel.c_str());
    mergeQuadManagerToCurrentQuadManager(scopeQuadManagerPtr);
    addQuadrupleToCurrentQuadManager("JMP", whileLabel.c_str(), "", "");
    addQuadrupleToCurrentQuadManager(endLabel.c_str(), "", "", "");
}

void addQuadruple(const char *op, const char *arg1, const char *arg2, const char *result) {
    mainQuadrupleManager.addQuadruple(op, arg1, arg2, result);
}

const char *newTemp() {
    return strdup(mainQuadrupleManager.newTemp().c_str());
}

const char *newLabel() {
    return strdup(mainQuadrupleManager.newLabel().c_str());
}

void printQuadruples(const char* inputFileName) {
    mainQuadrupleManager.printQuadruples(inputFileName);
}
const char* allocMap(const char *var)
{
    return strdup(mainQuadrupleManager.allocMap(var).c_str());

}
const char* getRegister(const char *var)
{
    return strdup(mainQuadrupleManager.getRegister(var).c_str());
}


static float *castExprToFloat(ExprValue *expr1, ExprValue *expr2, char operation, int line) {
    float *result = new float();

    switch (operation) {
        case '+':
            *result = *(float *)expr1->value + *(float *)expr2->value;
            break;
        case '-':
            *result = *(float *)expr1->value - *(float *)expr2->value;
            break;
        case '*':
            *result = *(float *)expr1->value * *(float *)expr2->value;
            break;
        case '/':
            if (*(float *)expr2->value == 0) {
                exitOnError("Division by zero", 0);
            }
            *result = *(float *)expr1->value / *(float *)expr2->value;
            break;
        case '^':
            *result = 1;
            for (int i = 0; i < *(int *)expr2->value; i++) {
                *result *= *(float *)expr1->value;
            }
            break;
    }

    return result;
}

static int *castExprToInt(ExprValue *expr1, ExprValue *expr2, char operation, int line) {
    int *result = new int();

    switch (operation) {
        case '+':
            *result = *(int *)expr1->value + *(int *)expr2->value;
            break;
        case '-':
            *result = *(int *)expr1->value - *(int *)expr2->value;
            break;
        case '*':
            *result = *(int *)expr1->value * *(int *)expr2->value;
            break;
        case '/':
            if (*(int *)expr2->value == 0) {
                exitOnError("Division by zero", 0);
            }
            *result = *(int *)expr1->value / *(int *)expr2->value;
            break;
        case '^':
            *result = 1;
            for (int i = 0; i < *(int *)expr2->value; i++) {
                *result *= *(int *)expr1->value;
            }
            break;
    }

    return result;
}

void *castExpressions(ExprValue *expr1, ExprValue *expr2, char operation, Type *castedType, int line) {
    if (expr1->type == FLOAT_T || expr2->type == FLOAT_T) {
        *castedType = FLOAT_T;
        return castExprToFloat(expr1, expr2, operation, line);
    }

    *castedType = INTEGER_T;
    return castExprToInt(expr1, expr2, operation, line);
}
}
