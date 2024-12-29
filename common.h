#ifndef COMMON_H
#define COMMON_H

#ifdef __cplusplus
extern "C" {

#endif

// #define DEBUG

#ifdef DEBUG
#define debugPrintf(...) printf(__VA_ARGS__)
#else
#define debugPrintf(...)
#endif

typedef enum {
    INTEGER_T,
    FLOAT_T,
    CHAR_T,
    STRING_T,
    BOOLEAN_T,
    VOID_T
} Type;

typedef struct {
    Type type;
    void* value;
    const char* name;
    int line;
} ExprValue;

const char* exprToString(ExprValue* exprValue);

void enterScope();
void exitScope(int line);
void addSymbolToSymbolTable(void* symbol);
void* createVariable(Type type, const char* name, int line, int isConstant);
void* getSymbolFromSymbolTable(const char* name, int line);
void checkBothParamsAreNumbers(Type type1, Type type2, int line);
void checkBothParamsAreBoolean(Type type1, Type type2, int line);
void checkParamIsNumber(Type type, int line);
void checkBothParamsAreOfSameType(Type type1, Type type2, int line);
void printSymbolTable(const char* inputFileName);
Type getSymbolType(void* symbol);
void exitOnError(const char* message, int line);
void printLogToFile(const char* message, int line, const char* errorType);
void* createArgumentList();
void addVariableToArgumentList(void* argumentList, void* variable);
void* createFunction(Type returnType, const char* name, void* argumentList, int line);
void* createParamList();
void addParamToParamList(void* paramList, const char* name, Type type);
void checkParamListAgainstFunction(void* paramList, void* function, int line);
void checkVariableIsNotConstant(void* symbol, int line);
void* getVariableFromSymbolTable(const char* name, int line);
void setVariableAsInitialized(void* symbol);
void checkReturnStatementIsValid(Type returnType, int line);

void* createSwitchCaseList();
void addCaseToSwitchCaseList(void* switchCaseList, Type type, int line);
void checkSwitchCaseListAgainstType(void* switchCaseList, Type type);

void addQuadruple(const char* op, const char* arg1, const char* arg2, const char* result);
const char* newTemp();
const char* newLabel();
void printQuadruples(const char* inputFileName);

void enterQuadManager();
void* exitQuadManager();
void mergeQuadManagerToCurrentQuadManager(void* quadManager);
void mergeQuadManagerToCurrentQuadManagerInFront(void* quadManager);
void addQuadrupleToCurrentQuadManager(const char* op, const char* arg1, const char* arg2, const char* result);
const char* generateNewExitLabelFromCurrentQuadManager();
const char* getExitLabelFromCurrentQuadManager();
void addQuadrupleToQuadManager(void* quadManager, const char* op, const char* arg1, const char* arg2, const char* result);
void addQuadrupleToQuadManagerInFront(void* quadManager, const char* op, const char* arg1, const char* arg2, const char* result);

void addCaseExpression(const char* expr);
const char* getCurrentCaseExpression();
void removeLastCaseExpression();

const char* convertFloatNumToChar(float num);
const char* convertIntNumToChar(int num);
const char* convertNumToChar(void* num, Type type);

void setFunctionLabel(void* function, const char* label);
const char* getFunctionLabel(void* function);
void handleFunctionQuadruples(void* quadManager, void* function);
void handleFunctionReturnQuadruples();
void handleFunctionReturnWithExprQuadruples(const char* expr);
void handleFunctionCallQuadruples(void* function, void* paramList, const char* returnVar);
void handleForLoopQuadruples(const char* booleanExprVar, void* booleanExprQuadManager, void* assignmentQuadManager, void* scopeQuadManager);
void handleRepeatUntilQuadruples(const char* booleanExprVar, void* booleanExprQuadManager, void* scopeQuadManager);
void handleWhileQuadruples(const char* booleanExprVar, void* booleanExprQuadManager, void* scopeQuadManager);
void* castExpressions(ExprValue* expr1, ExprValue* expr2, char operation, Type* castedType, int line);


#ifdef __cplusplus
}
#endif

#endif