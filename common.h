#ifndef COMMON_H
#define COMMON_H

#ifdef __cplusplus
extern "C" {
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
} ExprValue;

const char* exprToString(ExprValue* exprValue);

void enterScope();
void exitScope();
void addSymbolToSymbolTable(void* symbol);
void* createVariable(Type type, const char* name, int line, int isConstant);
void* getSymbolFromSymbolTable(const char* name, int line);
void checkBothParamsAreNumbers(Type type1, Type type2, int line);
void checkBothParamsAreBoolean(Type type1, Type type2, int line);
void checkParamIsNumber(Type type, int line);
void checkBothParamsAreOfSameType(Type type1, Type type2, int line);
void printSymbolTable();
Type getSymbolType(void* symbol);
void exitOnError(const char* message, int line);
void* createArgumentList();
void addVariableToArgumentList(void* paramList, void* variable);
void* createFunction(Type returnType, const char* name, void* paramList, int line);
void* createParamList();
void addTypeToParamList(void* paramList, Type type);
void checkParamListAgainstFunction(void* paramList, void* function, int line);

#ifdef __cplusplus
}
#endif

#endif