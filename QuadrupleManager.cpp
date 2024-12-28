#include "QuadrupleManager.hpp"

#include <string.h>

#include "Vendor/VariadicTable.h"
#include "common.h"
void QuadrupleManager::addQuadruple(const string &op, const string &arg1, const string &arg2, const string &result) {
    printf("Adding quadruple: %s %s %s %s\n", op.c_str(), arg1.c_str(), arg2.c_str(), result.c_str());
    quadruples.emplace_back(op, arg1, arg2, result);
}

void QuadrupleManager::addQuadruple(const Quadruple &quadruple) {
    quadruples.push_back(quadruple);
}

void QuadrupleManager::addQuadrupleInFront(const Quadruple &quadruple) {
    quadruples.insert(quadruples.begin(), quadruple);
}

string QuadrupleManager::newTemp() {
    return "t" + std::to_string(tempCount++);
}

string QuadrupleManager::newLabel() {
    return "L" + std::to_string(labelCount++);
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

void QuadrupleManager::printQuadruples() {
    VariadicTable<string, string, string, string, string> vt({"Index", "Op", "Arg1", "Arg2", "Result"});

    for (size_t i = 0; i < quadruples.size(); ++i) {
        quadruples[i].display(i, vt);
    }

    vt.print(cout);
}

int QuadrupleManager::tempCount = 0;
int QuadrupleManager::labelCount = 0;

static QuadrupleManager mainQuadrupleManager;

vector<QuadrupleManager *> quadrupleManagers = {&mainQuadrupleManager};
vector<string> caseExpression;

extern "C" {

void addQuadrupleToQuadManager(void *quadManager, const char *op, const char *arg1, const char *arg2, const char *result) {
    cout << "Push back" << endl;
    QuadrupleManager *quadManagerPtr = (QuadrupleManager *)quadManager;
    quadManagerPtr->addQuadruple(op, arg1, arg2, result);
}

void addQuadrupleToQuadManagerInFront(void *quadManager, const char *op, const char *arg1, const char *arg2, const char *result) {
    cout << "Push front" << endl;
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
    return strdup(("L" + std::to_string(labelId)).c_str());
}

const char *getExitLabelFromCurrentQuadManager() {
    int labelId = quadrupleManagers.back()->getExitLabel();
    return strdup(("L" + std::to_string(labelId)).c_str());
}

void enterQuadManager() {
    cout << "Entering quad manager" << endl;
    QuadrupleManager *quadManager = new QuadrupleManager();
    quadrupleManagers.push_back(quadManager);
}

void *exitQuadManager() {
    cout << "Exiting quad manager" << endl;
    QuadrupleManager *quadManager = quadrupleManagers.back();
    quadrupleManagers.pop_back();
    return (void *)quadManager;
}

void addQuadrupleToCurrentQuadManager(const char *op, const char *arg1, const char *arg2, const char *result) {
    cout << quadrupleManagers.size() << endl;
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

void addQuadruple(const char *op, const char *arg1, const char *arg2, const char *result) {
    mainQuadrupleManager.addQuadruple(op, arg1, arg2, result);
}

const char *newTemp() {
    return strdup(mainQuadrupleManager.newTemp().c_str());
}

const char *newLabel() {
    return strdup(mainQuadrupleManager.newLabel().c_str());
}

void printQuadruples() {
    mainQuadrupleManager.printQuadruples();
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
