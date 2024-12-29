#include "QuadrupleManager.hpp"

#include <string.h>

#include <fstream>
#include <sstream>

#include "SymbolTable.hpp"
#include "Vendor/VariadicTable.h"
#include "common.h"

void QuadrupleManager::addQuadruple(const string &op, const string &arg1, const string &arg2, const string &result) {
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

void QuadrupleManager::print(ofstream &outFile) {
    VariadicTable<string, string, string, string, string> vt({"Index", "Op", "Arg1", "Arg2", "Result"});

    for (size_t i = 0; i < quadruples.size(); ++i) {
        quadruples[i].display(i, vt);
    }

    std::ostringstream oss;
    vt.print(oss);

    printf("%s", oss.str().c_str());
    outFile << oss.str();
}

int QuadrupleManager::tempCount = 0;
int QuadrupleManager::labelCount = 0;

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

    string returnLabel = "ret_" + func->getLabel();
    quadManagerPtr->addQuadrupleInFront("POP", "", "", returnLabel);
    string returnLabelContent = "content(" + string(returnLabel) + ")";
    quadManagerPtr->addQuadruple("JMP", returnLabelContent, "", "");
}

void handleFunctionReturnQuadruples() {
    Function *function = FunctionContextSingleton::getCurrentFunction();
    string returnLabel = "ret_" + function->getLabel();
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

void printQuadruples(const char *inputFileName) {
    const char *outputFileName = getOutputFileName(inputFileName, "_quadruples.txt");
    ofstream outFile = ofstream(outputFileName, ios::out);
    mainQuadrupleManager.print(outFile);
    outFile.close();
}
}
