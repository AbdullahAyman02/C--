%{
    #include "common.h"
    #include <stdio.h>      // for functions like printf and scanf
    #include <string.h>     // for string functions like strdup
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    int yylex(void);        // for lexical analysis. This function is called to get the next token
    extern FILE *yyin;      // for file handling. This is the input file. The default is stdin
    extern int yylineno;    // for line number. This variable stores the current line number
    extern char *yytext;    // for token text. This variable stores the current token text
    #define YYDEBUG 1       // for debugging. If set to 1, the parser will print the debugging information
    extern int yydebug;     // for debugging. This variable stores the current debugging level
    #define DEBUG
%}

// The union is used to define the types of the tokens. Since the datatypes that we will work with are  either int/float, char/string, and boolean, we will use a union to define the types of the tokens   
%union {
    int integer;            // integer value
    float floating;         // floating value
    char character;         // character value
    char* string;           // string value
    Type type;              // data type
    void* list;             // list of parameters
    // bool boolean;        // boolean value
    ExprValue *exprValue;   // expression value
};

// The tokens are defined here. The tokens are the smallest unit of the language. They are the keywords, identifiers, operators, etc. that are used in the language
%token <integer> INTEGER
// %token <floating> INTEGER
%token INT
%token <floating> FLOATING
%token FLOAT
%token <integer> BOOLEAN
// %token <floating> BOOLEAN
%token BOOL
%token <character> CHARACTER
%token CHAR
%token <string> CHARARRAY
%token STRING
%token <string> VARIABLE
%token CONST REPEAT UNTIL FOR SWITCH CASE IF THEN ELSE RETURN WHILE FUNCTION VOID GE LE EQ NE
// %type <floating> expression caseExpression

%nonassoc '='       // non-associative token. This means that the token cannot be used in a chain of tokens like a=b=c, but can be used in a=b
%left '||'           // left associative token. This means that the token is evaluated from left to right a | b | c -> (a | b) | c
%left '&&'
%left '<' '>' GE LE EQ NE
%left '+' '-'
%left '*' '/'
%right '^'          // right associative token. This means that the token is evaluated from right to left a ^ b ^ c -> a ^ (b ^ c)

%type <type> dataType 
%type <exprValue> expression functionCall  caseCondition CASE_EXPRESSION
%type <list> arguments argumentsList parameters parametersList case SCOPE_CLOSE scope FUNCTION_SIGNATURE

%%
// The grammar rules are defined here. The grammar rules define the structure of the language. They define how the tokens are combined to form statements, expressions, etc.

program:
    statement ';' program                       { debugPrintf("statement\n"); }
    | /* NULL */
    | ';' program
    ;

statement:
    initialization                                                      { debugPrintf("initialization\n");}
    | WHILE '(' expression ')' scope                                    { debugPrintf("while\n");}
    | REPEAT scope UNTIL '(' expression ')'                             { debugPrintf("repeat\n");}
    | FOR '(' forLoopInitialization ';' expression ';' assignment ')' scope    { debugPrintf("for\n");}
    | SWITCH '(' CASE_EXPRESSION ')' '{' case '}'                            { 
                                                                            void* switchCaseList = $6;
                                                                            ExprValue* switchExpression = $3;
                                                                            Type expressionType = switchExpression->type;
                                                                            checkSwitchCaseListAgainstType(switchCaseList,expressionType);

                                                                            const char* exitLabel = getExitLabelFromCurrentQuadManager();
                                                                            addQuadrupleToCurrentQuadManager(exitLabel, "", "", "");
                                                                            removeLastCaseExpression();

                                                                            void* quadManager = exitQuadManager();
                                                                            mergeQuadManagerToCurrentQuadManager(quadManager);
                                                                        }
    | scope                                                             { debugPrintf("scope\n");}
    | IF '(' expression ')' THEN scope                                  { 
                                                                            debugPrintf("if\n");

                                                                            const char* label = newLabel();
                                                                            ExprValue* expr = $3;
                                                                            const char* exprName = expr->name;
                                                                            addQuadrupleToCurrentQuadManager("JF", exprName, "", label);

                                                                            void* quadManager = $6;
                                                                            mergeQuadManagerToCurrentQuadManager(quadManager);
                                                                            
                                                                            addQuadrupleToCurrentQuadManager(label, "", "", "");
                                                                         }
    | IF '(' expression ')'  THEN scope ELSE scope      {
                                                                            debugPrintf("if else\n");

                                                                            const char* elseLabel = newLabel();
                                                                            ExprValue* expr = $3;
                                                                            const char* exprName = expr->name;
                                                                            addQuadrupleToCurrentQuadManager("JF", exprName, "", elseLabel);

                                                                            void* scopeMgr1 = $6;
                                                                            mergeQuadManagerToCurrentQuadManager(scopeMgr1);
                                                                            
                                                                            const char* endLabel = newLabel();
                                                                            addQuadrupleToCurrentQuadManager("jmp", "", "", endLabel);

                                                                            addQuadrupleToCurrentQuadManager(elseLabel, "", "", "");

                                                                            void* scopeMgr2 = $8;
                                                                            mergeQuadManagerToCurrentQuadManager(scopeMgr2);

                                                                            addQuadrupleToCurrentQuadManager(endLabel, "", "", "");

                                                                        }
    | FUNCTION_SIGNATURE scope                                          {  
                                                                            void* function = $1;
                                                                            void* quadManager = $2;
                                                                            const char* skipFunctionLabel = newLabel();
                                                                            addQuadrupleToCurrentQuadManager("JMP", "", "", skipFunctionLabel);
                                                                            
                                                                            const char* functionLabel = getFunctionLabel(function);

                                                                            addQuadrupleToCurrentQuadManager(functionLabel, "", "", "");
                                                                            
                                                                            handleFunctionQuadruples(quadManager,function);
                                                                            mergeQuadManagerToCurrentQuadManager(quadManager);
                                                                            
                                                                            addQuadrupleToCurrentQuadManager(skipFunctionLabel, "", "", "");
                                                                        }
                                                                        
    | functionCall                                                      { debugPrintf("function call\n"); }
    | RETURN expression                                                 { 
                                                                            ExprValue* returnValue = $2;
                                                                            Type returnType = returnValue->type;
                                                                            const char* returnName = returnValue->name;
                                                                            checkReturnStatementIsValid(returnType,yylineno);
                                                                            handleFunctionReturnWithExprQuadruples(returnName);
                                                                        }
                                                                        //check return type
    | RETURN                                                            { 
                                                                            checkReturnStatementIsValid(VOID_T,yylineno);
                                                                            handleFunctionReturnQuadruples();
                                                                        }                                                               
    ;

CASE_EXPRESSION:
    expression                                          { 
                                                            $$ = $1;
                                                            const char* caseExpressionVariable = $1->name;
                                                            enterQuadManager();
                                                            addCaseExpression(caseExpressionVariable);
                                                         }

FUNCTION_SIGNATURE:
    FUNCTION dataType VARIABLE '(' arguments ')'       { 
                                                            void* parametersList = $5;
                                                            void* function = createFunction($2,$3,parametersList,yylineno);
                                                            addSymbolToSymbolTable(function);

                                                            const char* functionLabel = newLabel();
                                                            setFunctionLabel(function,functionLabel);
                                                            
                                                            $$ = function;
                                                        }
    | FUNCTION VOID VARIABLE '(' arguments ')'         { 
                                                            void* parametersList = $5;
                                                            void* function = createFunction(VOID_T,$3,parametersList,yylineno);
                                                            addSymbolToSymbolTable(function);

                                                            $$ = function;
                                                        }
    ;

forLoopInitialization:
    assignment |
    //NULL
    ;

initialization:
    declaration                                 { debugPrintf("declaration\n"); }
    | assignment                                { debugPrintf("assignment\n"); }
    ;

scope:
    SCOPE_OPEN program SCOPE_CLOSE                             { $$ = $3; }
    ;

SCOPE_OPEN:
    '{'                                         { 
                                                    debugPrintf("Scope Open\n"); 
                                                    enterScope();
                                                    enterQuadManager();
                                                }
    ;

SCOPE_CLOSE:
    '}'                                         { 
                                                    debugPrintf("Scope Close\n");
                                                    exitScope(yylineno);
                                                    void* quadManager = exitQuadManager();
                                                    $$ = quadManager;
                                                }
    ;

declaration:
    dataType VARIABLE                           {      
                                                        void* variable = createVariable($1,$2, yylineno,0);
                                                        addSymbolToSymbolTable(variable);
                                                }
    | dataType VARIABLE '=' expression          { 
                                                        const char* varName = $2;
                                                        const char* assignmentName = $4->name;
                                                        Type varType = $1;
                                                        Type assignmentType = $4->type;
                                                        void* variable = createVariable(varType,varName, yylineno,0);
                                                        setVariableAsInitialized(variable);

                                                        checkBothParamsAreOfSameType(varType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
                                                        
                                                        #ifdef DEBUG
                                                            debugPrintf("Variable: %s = %s\n", varName, assignmentName);
                                                        #endif

                                                        addQuadrupleToCurrentQuadManager("=", assignmentName, "", varName);
                                                }
    | CONST dataType VARIABLE '=' expression {     
                                                        Type varType = $2;
                                                        const char* varName = $3;
                                                        const char* assignmentName = $5->name;
                                                        void* variable = createVariable(varType,varName, yylineno,1);
                                                        Type assignmentType = $5->type;
                                                        Type variableType = $2;
                                                        checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
                                                        
                                                        setVariableAsInitialized(variable);
                                                        
                                                        #ifdef DEBUG
                                                            debugPrintf("Variable: %s = %s\n", varName, assignmentName);
                                                        #endif
                                                       
                                                        
                                                        addQuadrupleToCurrentQuadManager("=", assignmentName, "", varName);
                                                  }
    ;

dataType:
    INT               {$$ = INTEGER_T;} 
    | FLOAT           {$$ = FLOAT_T;}
    | CHAR            {$$ = CHAR_T;}
    | STRING          {$$ = STRING_T;}
    | BOOL            {$$ = BOOLEAN_T;}
    ;

assignment:
    VARIABLE '=' expression        {
                                            const char* varName = $1;
                                            const char* valName = $3->name;
                                            void* variable = getSymbolFromSymbolTable(varName,yylineno);
                                            Type assignmentType = $3->type;
                                            Type variableType = getSymbolType(variable);
                                            
                                            setVariableAsInitialized(variable);

                                            checkVariableIsNotConstant(variable, yylineno);
                                            checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                            

                                            #ifdef DEBUG
                                                debugPrintf("Assignment\n");
                                                debugPrintf("Variable: %s = %s\n", varName, valName);
                                            #endif
                                            
                                            addQuadrupleToCurrentQuadManager("=", valName, "", varName);
                                            
                                        }
                                       
    ;

expression:
    VARIABLE                    { 
                                    const char* val = strdup($1);
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    void* variable = getVariableFromSymbolTable(val,yylineno);
                                    returnValue->type = getSymbolType(variable);
                                    returnValue->value = (void*)val;
                                    returnValue->name = val;
                                    $$ = returnValue;
                                }
    | INTEGER                   { 
                                    const char* val = strdup(convertIntNumToChar($1));
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    returnValue->type = INTEGER_T;
                                    int* valInt = (int*)malloc(sizeof(int));
                                    *valInt = $1;
                                    returnValue->value = (void*)valInt;
                                    returnValue->name = val;
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Setting integer with value: %s\n", convertIntNumToChar(*(int*)($$->value)));
                                    #endif

                                }
    | FLOATING                  {             
                                    const char* val = strdup(convertFloatNumToChar($1));
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    returnValue->type = FLOAT_T;
                                    returnValue->value = (void*)val;
                                    returnValue->name = val;
                                    $$ = returnValue;

                                }
    | BOOLEAN                   { 
                                    const char* val = strdup(convertIntNumToChar($1));
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    returnValue->type = BOOLEAN_T;
                                    returnValue->value = (void*)val;
                                    returnValue->name = val;
                                    $$ = returnValue;
                                }
    | CHARACTER                 { 
                                    char* val = malloc(sizeof(char)*2);
                                    val[0] = $1;
                                    val[1] = '\0';
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    
                                    returnValue->type = CHAR_T;
                                    returnValue->value = val;
                                    returnValue->name = val;
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Setting character with value: %c\n", *(char*)($$->value));
                                    #endif
                                }
    | CHARARRAY                 {
                                    const char* val = strdup($1);
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    
                                    returnValue->type = STRING_T;
                                    returnValue->value = (void*)val;
                                    returnValue->name = val;
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Setting string with value: %s\n", (char*)$$->value);
                                    #endif
                                }
    | functionCall              { $$ = $1; }
    | expression '+' expression {
                                    ExprValue* expr1 = $1;
                                    ExprValue* expr2 = $3;
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("+", expr1Name, expr2Name, tempVar);

                                    returnValue->type = expr1Type;
                                    returnValue->value = castExpressions(expr1,expr2,'+',&returnValue->type,yylineno);
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif 
                                }
    | expression '-' expression {
                                    ExprValue* expr1 = $1;
                                    ExprValue* expr2 = $3;
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("-", expr1Name, expr2Name, tempVar);

                                    returnValue->type = expr1Type;
                                    returnValue->value = castExpressions(expr1,expr2,'-',&returnValue->type,yylineno);
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif 
                                }
    | expression '*' expression {
                                    ExprValue* expr1 = $1;
                                    ExprValue* expr2 = $3;
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("*", expr1Name, expr2Name, tempVar);

                                    returnValue->type = expr1Type;
                                    returnValue->value = castExpressions(expr1,expr2,'*',&returnValue->type,yylineno);
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif 
                                }
    | expression '/' expression {
                                    ExprValue* expr1 = $1;
                                    ExprValue* expr2 = $3;
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("/", expr1Name, expr2Name, tempVar);

                                    returnValue->type = expr1Type;
                                    returnValue->value = castExpressions(expr1,expr2,'/',&returnValue->type,yylineno);
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif 
                                }
    | expression '^' expression {
                                     ExprValue* expr1 = $1;
                                    ExprValue* expr2 = $3;
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("^", expr1Name, expr2Name, tempVar);

                                    returnValue->type = expr1Type;
                                    returnValue->value = castExpressions(expr1,expr2,'^',&returnValue->type,yylineno);
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif 
                                }
    | '-' expression             {
                                    const char* tempVar = newTemp();
                                    const char* exprName = $2->name;
                                    Type exprType = $2->type;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    
                                    checkParamIsNumber(exprType,yylineno);

                                    returnValue->type = exprType;
                                    
                                    if (exprType == INTEGER_T) {
                                        int *val = (int*)malloc(sizeof(int)); 
                                        *val = -1 * *(int*)$2->value;
                                        returnValue->value = (void*)val;
                                    } else {
                                        float *val = (float*)malloc(sizeof(float));
                                        *val = -1 * *(float*)$2->value;
                                        returnValue->value = (void*)val;
                                    }

                                    returnValue->name = tempVar;
                                    addQuadrupleToCurrentQuadManager("Minus", "", exprName, tempVar);
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Name of expression: %s\n", exprName);
                                        debugPrintf("Name of result: %s\n", tempVar);
                                        debugPrintf("Value of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif
                                 }
    | expression '||' expression {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    checkBothParamsAreBoolean(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("||", expr1Name, expr2Name, tempVar);
                                    returnValue->type = BOOLEAN_T;
                                    
                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(int*)$1->value || *(int*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->name = tempVar;
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,$$->type));
                                    #endif
                                 }
    | expression '&&' expression {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                    checkBothParamsAreBoolean(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("&&", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(int*)$1->value && *(int*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression '<' expression  {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("<", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value < *(float*)$3->value;
                                    returnValue->value = (void*)val;
                                    
                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression '>' expression {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager(">", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value > *(float*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression GE expression  {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager(">=", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value >= *(float*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression LE expression    {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreNumbers(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("<=", expr1Name, expr2Name, tempVar);
                                    
                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value <= *(float*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression EQ expression  {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreOfSameType(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("==", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value == *(float*)$3->value;
                                    returnValue->value = (void*)val;
                                    
                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | expression NE expression  {
                                    Type expr1Type = $1->type;
                                    Type expr2Type = $3->type;
                                    const char* tempVar = newTemp();
                                    const char* expr1Name = $1->name;
                                    const char* expr2Name = $3->name;
                                    ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));

                                    checkBothParamsAreOfSameType(expr1Type,expr2Type,yylineno);
                                    addQuadrupleToCurrentQuadManager("!=", expr1Name, expr2Name, tempVar);

                                    int *val = (int*)malloc(sizeof(int));
                                    *val = *(float*)$1->value != *(float*)$3->value;
                                    returnValue->value = (void*)val;

                                    returnValue->type = BOOLEAN_T;
                                    returnValue->name = tempVar;
                                    $$ = returnValue;  

                                    #ifdef DEBUG
                                        debugPrintf("Name of first expression: %s\n", expr1Name);
                                        debugPrintf("Name of second expression: %s\n", expr2Name);
                                        debugPrintf("Name of result: %s\n", convertNumToChar($$->value,INTEGER_T));
                                    #endif
                                 }
    | '(' expression ')'        { $$ = $2; }
    
    ;

functionCall:
    VARIABLE '(' parameters ')'     {
                                        const char* functionName = strdup($1);
                                        void* function = getSymbolFromSymbolTable(functionName,yylineno);
                                        void* parametersList = $3;
                                        checkParamListAgainstFunction(parametersList,function,yylineno);
                                        ExprValue *returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                        
                                        returnValue->type = getSymbolType(function);
                                        returnValue->value = (void*)functionName;
                                        returnValue->name = newTemp();

                                        handleFunctionCallQuadruples(function,parametersList,returnValue->name);
                                        
                                        $$ = returnValue;
                                    }
    ;

arguments:
    argumentsList   {     
                          debugPrintf("Arguments\n");
                          $$ = $1;
                    }
    | /* NULL */   { $$ = createArgumentList(); }
    ;

argumentsList:
    dataType VARIABLE                           {
                                                    void* argumentList = createArgumentList();
                                                    void* variable = createVariable($1,$2, yylineno,0);
                                                    addVariableToArgumentList(argumentList,variable);
                                                    $$ = argumentList;
                                                }
    | dataType VARIABLE ',' argumentsList       {
                                                    void* variable = createVariable($1,$2, yylineno,0);
                                                    addVariableToArgumentList($4,variable);
                                                    $$ = $4;
                                                }
    ;

parameters:
    parametersList     { $$ = $1; }
    | /* NULL */        { $$ = createParamList(); }
    ;

parametersList:
    expression ',' parametersList           {   void* paramList = $3; 
                                                Type paramType = $1->type;
                                                const char* paramName = $1->name;
                                                addParamToParamList(paramList,paramName,paramType);
                                                $$ = paramList;
                                            }

    | expression                        {   
                                            void* paramList = createParamList(); 
                                            Type paramType = $1->type;
                                            const char* paramName = $1->name;
                                            addParamToParamList(paramList,paramName,paramType);
                                            $$ = paramList; 
                                        }
                                            
    ;

case:
    CASE caseCondition ':' scope            {
                                                ExprValue* caseValue = $2;
                                                void* caseList = createSwitchCaseList();
                                                Type caseType = caseValue->type;
                                                int caseLine = caseValue->line;
                                                addCaseToSwitchCaseList(caseList,caseType,caseLine);
                                                $$ = caseList;

                                                void* quadManager = $4;
                                                const char* exitLabel = generateNewExitLabelFromCurrentQuadManager();
                                                const char* label = newLabel();
                                                const char* caseExpression = getCurrentCaseExpression();
                                                
                                                const char* tempVar = newTemp();
                                                addQuadrupleToQuadManagerInFront(quadManager,"JF", tempVar, "", label);
                                                addQuadrupleToQuadManagerInFront(quadManager,"==", caseExpression, caseValue->name, tempVar);

                                                addQuadrupleToQuadManager(quadManager,"jmp", "", "", exitLabel);
                                                addQuadrupleToQuadManager(quadManager,label, "", "", "");

                                                mergeQuadManagerToCurrentQuadManagerInFront(quadManager);
                                            }
    | CASE caseCondition ':' scope case     {
                                                ExprValue* caseValue = $2;
                                                void* caseList = $5;
                                                Type caseType = caseValue->type;
                                                int caseLine = caseValue->line;
                                                addCaseToSwitchCaseList(caseList,caseType,caseLine);
                                                $$ = caseList;

                                                void* quadManager = $4;
                                                const char* exitLabel = getExitLabelFromCurrentQuadManager();
                                                const char* label = newLabel();
                                                const char* caseExpression = getCurrentCaseExpression();
                                                
                                                const char* tempVar = newTemp();
                                                addQuadrupleToQuadManagerInFront(quadManager,"JF", tempVar, "", label);
                                                addQuadrupleToQuadManagerInFront(quadManager,"==", caseExpression, caseValue->name, tempVar);

                                                addQuadrupleToQuadManager(quadManager,"jmp", "", "", exitLabel);
                                                addQuadrupleToQuadManager(quadManager,label, "", "", "");
                                                
                                                mergeQuadManagerToCurrentQuadManagerInFront(quadManager);
                                            }
    ;

caseCondition:
    CHARACTER                       {   
                                        char* val = malloc(sizeof(char)*2);
                                        val[0] = $1;
                                        val[1] = '\0';
                                        ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                        returnValue->line = yylineno;
                                        returnValue->type = CHAR_T;
                                        returnValue->value = val;
                                        returnValue->name = val;
                                        $$ = returnValue;
                                    }
    | INTEGER                       {
                                        const char* val = strdup(convertIntNumToChar($1));
                                        ExprValue* returnValue = (ExprValue*)malloc(sizeof(ExprValue));
                                        returnValue->line = yylineno;
                                        returnValue->type = INTEGER_T;
                                        int* valInt = (int*)malloc(sizeof(int));
                                        *valInt = $1;
                                        returnValue->value = (void*)valInt;
                                        returnValue->name = val;
                                        $$ = returnValue;
                                    }
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "Error: %s at line %d, near '%s'\n", s, yylineno, yytext);
}

// pass argument in command line
// example: ./parser.exe input.txt
int main(int argc, char **argv) {
    yydebug = 0;
    // yydebug = 1;

    if(argc != 2) {
        debugPrintf("Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    // Open the input file
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        debugPrintf("Error: Unable to open file %s\n", argv[1]);
        return 1;
    }
    
    // Call the parser
    yyparse();
    // printSymbolTable();
    printSymbolTable();
    printQuadruples();
    // Close the input file
    fclose(yyin);
    return 0;
}