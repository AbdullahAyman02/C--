#include "QuadrupleManager.hpp"

#include <string.h>

#include "common.h"
void QuadrupleManager::addQuadruple(const string &op, const string &arg1, const string &arg2, const string &result) {
    printf("Adding quadruple: %s %s %s %s\n", op.c_str(), arg1.c_str(), arg2.c_str(), result.c_str());
    quadruples.emplace_back(op, arg1, arg2, result);
}

string QuadrupleManager::newTemp() {
    return "t" + std::to_string(tempCount++);
}

string QuadrupleManager::newLabel() {
    return "L" + std::to_string(labelCount++);
}

void QuadrupleManager::printQuadruples() {
    printf("\nGenerated Quadruples:\n");
    printf("%5s%10s%10s%10s%10s\n", "Index", "Op", "Arg1", "Arg2", "Result");

    for (size_t i = 0; i < quadruples.size(); ++i) {
        quadruples[i].display(i);
    }
}

static QuadrupleManager quadrupleManager;

extern "C" {
void addQuadruple(const char *op, const char *arg1, const char *arg2, const char *result) {
    quadrupleManager.addQuadruple(op, arg1, arg2, result);
}

const char *newTemp() {
    return strdup(quadrupleManager.newTemp().c_str());
}

const char *newLabel() {
    return strdup(quadrupleManager.newLabel().c_str());
}

void printQuadruples() {
    quadrupleManager.printQuadruples();
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
