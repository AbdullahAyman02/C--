%{
    #include "common.h"
    #include "QuadrupleManager.hpp"
    #include <stdio.h>      // for functions like printf and scanf
    #include <string.h>     // for string functions like strdup
    #include <cmath>        // for math functions like pow
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    int yylex(void);        // for lexical analysis. This function is called to get the next token
    extern FILE *yyin;      // for file handling. This is the input file. The default is stdin
    extern int yylineno;    // for line number. This variable stores the current line number
    extern char *yytext;    // for token text. This variable stores the current token text
    #define YYDEBUG 1       // for debugging. If set to 1, the parser will print the debugging information
    extern int yydebug;     // for debugging. This variable stores the current debugging level

    QuadrupleManager quadManager;
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
%type <exprValue> expression assignmentValue functionCall
%type <list> arguments argumentsList parameters parametersList

%%
// The grammar rules are defined here. The grammar rules define the structure of the language. They define how the tokens are combined to form statements, expressions, etc.

program:
    statement ';' program                       { printf("statement\n"); }
    | /* NULL */
    | ';' program
    ;

statement:
    initialization                                                      { printf("initialization\n");}
    | WHILE '(' expression ')' scope                                    { printf("while\n");}
    | REPEAT scope UNTIL '(' expression ')'                             { printf("repeat\n");}
    | FOR '(' initialization ';' expression ';' assignment ')' scope    { printf("for\n");}
    | SWITCH '(' expression ')' '{' case '}'                            { printf("switch\n");}
    | scope                                                             { printf("scope\n");}
    | IF '(' expression ')' THEN scope                                  { printf("if\n");}
    | IF '(' expression ')' THEN scope ELSE scope                       { printf("if else\n");}
    | FUNCTION dataType VARIABLE '(' arguments ')' scope                { 
                                                                            void* parametersList = $5;
                                                                            void* function = createFunction($2,$3,parametersList,yylineno);
                                                                            addSymbolToSymbolTable(function);
                                                                        }
    | FUNCTION VOID VARIABLE '(' arguments ')' scope                    { 
                                                                            void* parametersList = $5;
                                                                            void* function = createFunction(VOID_T,$3,parametersList,yylineno);
                                                                            addSymbolToSymbolTable(function);
                                                                        }
    | functionCall                                                      { printf("function call\n"); }
    | RETURN assignmentValue                                            { printf("return\n");}
    | RETURN                                                            { printf("return\n");}
    ;

initialization:
    declaration                                 { printf("declaration\n"); }
    | assignment                                { printf("assignment\n"); }
    ;

scope:
    '{' program '}'
    ;

declaration:
    dataType VARIABLE                           {      
                                                        void* variable = createVariable($1,$2, yylineno,0);
                                                        addSymbolToSymbolTable(variable);
                                                }
    | dataType VARIABLE '=' assignmentValue     { 
                                                        void* variable = createVariable($1,$2, yylineno,0);
                                                        Type assignmentType = $4->type;
                                                        Type variableType = $1;
                                                        checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
                                                        printf("Variable: %s = %s\n", $2, $4->name);
                                                        quadManager.addQuadruple("=", std::string($4->name), "", std::string($2));
                                                }
    | CONST dataType VARIABLE '=' assignmentValue { 
                                                        void* variable = createVariable($2,$3, yylineno,1);
                                                        Type assignmentType = $5->type;
                                                        Type variableType = $2;
                                                        checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
                                                        printf("Variable: %s = %s\n", $3, $5->name);
                                                        quadManager.addQuadruple("=", std::string($5->name), "", std::string($3));
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
    VARIABLE '=' assignmentValue        {
                                            printf("Assignment\n");
                                            void* variable = getSymbolFromSymbolTable($1,yylineno);
                                            Type assignmentType = $3->type;
                                            Type variableType = getSymbolType(variable);
                                            checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                            // Print variable with its value
                                            printf("Variable: %s = %s\n", $1, $3->name);
                                            quadManager.addQuadruple("=", std::string($3->name), "", std::string($1));
                                        }
    ;

assignmentValue:
    expression                                  { $$ = $1; }
    | CHARACTER                                 { 
                                                    $$ = new ExprValue;
                                                    $$->type = CHAR_T;
                                                    char* val = new char($1);  // Allocate new char with value
                                                    $$->value = (void*)val;
                                                    $$->name = strdup(std::string(1, $1).c_str());  // Convert char to string
                                                    printf("Setting character with value: %c\n", *(char*)($$->value));
                                                }
    | CHARARRAY                                 {
                                                    $$ = new ExprValue;
                                                    $$->type = STRING_T;
                                                    char* val = strdup($1);  // Make a copy of the string
                                                    $$->value = (void*)val;  // Store pointer to the copy
                                                    $$->name = strdup($1);   // Store name as string
                                                    printf("Setting string with value: %s\n", (char*)$$->value);
                                                }
    | functionCall                              { $$ = $1; }
    ;

functionCall:
    VARIABLE '(' parameters ')'     {
                                        void* function = getSymbolFromSymbolTable($1,yylineno);
                                        void* parametersList = $3;
                                        checkParamListAgainstFunction(parametersList,function,yylineno);
                                        $$ = new ExprValue;  // Allocate new ExprValue
                                        $$->type = getSymbolType(function);
                                        char* val = strdup($1);  // Allocate copy of function name
                                        $$->value = (void*)val;
                                        $$->name = strdup($1);   // Allocate another copy for name
                                    }
    ;

expression:
    VARIABLE                    { 
                                    void* variable = getSymbolFromSymbolTable($1,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = getSymbolType(variable);
                                    char* val = strdup($1);  // Allocate copy of variable name
                                    $$->value = (void*)val;
                                    $$->name = strdup($1);
                                }
    | INTEGER                   { 
        $$ = new ExprValue; 
        $$->type = INTEGER_T; 
        printf("Setting integer with type: %d\n", $$->type);
        printf("Setting integer with value: %d\n", $1);
        int* val = new int($1);  // Allocate new int with value
        $$->value = (void*)val; 
        printf("Set integer with value: %d\n", *(int*)($$->value));
        $$->name = strdup(std::to_string($1).c_str()); 
        printf("Setting integer with name: %s\n", $$->name);
        }
    | FLOATING                  { 
                                    $$ = new ExprValue; 
                                    $$->type = FLOAT_T; 
                                    float* val = new float($1); 
                                    $$->value = (void*)val; 
                                    $$->name = strdup(std::to_string($1).c_str());
                                }
    | BOOLEAN                   { 
                                    $$ = new ExprValue; 
                                    $$->type = BOOLEAN_T; 
                                    int* val = new int($1); 
                                    $$->value = (void*)val; 
                                    $$->name = strdup(std::to_string($1).c_str());
                                }
    | expression '+' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("+", std::string($1->name), std::string($3->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float addition properly
                                    if ($1->type == INTEGER_T && $3->type == INTEGER_T) {
                                        int* result = new int(*(int*)($1->value) + *(int*)($3->value));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float();
                                        if ($1->type == INTEGER_T)
                                            *result = (float)(*(int*)($1->value)) + *(float*)($3->value);
                                        else if ($3->type == INTEGER_T)
                                            *result = *(float*)($1->value) + (float)(*(int*)($3->value));
                                        else
                                            *result = *(float*)($1->value) + *(float*)($3->value);
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                }
    | expression '-' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("-", std::string($1->name), std::string($3->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float subtraction properly
                                    if ($1->type == INTEGER_T && $3->type == INTEGER_T) {
                                        int* result = new int(*(int*)($1->value) - *(int*)($3->value));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float();
                                        if ($1->type == INTEGER_T)
                                            *result = (float)(*(int*)($1->value)) - *(float*)($3->value);
                                        else if ($3->type == INTEGER_T)
                                            *result = *(float*)($1->value) - (float)(*(int*)($3->value));
                                        else
                                            *result = *(float*)($1->value) - *(float*)($3->value);
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                }
    | expression '*' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("*", std::string($1->name), std::string($3->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float multiplication properly
                                    if ($1->type == INTEGER_T && $3->type == INTEGER_T) {
                                        int* result = new int(*(int*)($1->value) * *(int*)($3->value));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float();
                                        if ($1->type == INTEGER_T)
                                            *result = (float)(*(int*)($1->value)) * *(float*)($3->value);
                                        else if ($3->type == INTEGER_T)
                                            *result = *(float*)($1->value) * (float)(*(int*)($3->value));
                                        else
                                            *result = *(float*)($1->value) * *(float*)($3->value);
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                }
    | expression '/' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("/", std::string($1->name), std::string($3->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float division properly
                                    if ($1->type == INTEGER_T && $3->type == INTEGER_T) {
                                        int* result = new int(*(int*)($1->value) / *(int*)($3->value));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float();
                                        if ($1->type == INTEGER_T)
                                            *result = (float)(*(int*)($1->value)) / *(float*)($3->value);
                                        else if ($3->type == INTEGER_T)
                                            *result = *(float*)($1->value) / (float)(*(int*)($3->value));
                                        else
                                            *result = *(float*)($1->value) / *(float*)($3->value);
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                }
    | expression '^' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("^", std::string($1->name), std::string($3->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float exponentiation properly
                                    if ($1->type == INTEGER_T && $3->type == INTEGER_T) {
                                        int* result = new int(pow(*(int*)($1->value), *(int*)($3->value)));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float();
                                        if ($1->type == INTEGER_T)
                                            *result = pow((float)(*(int*)($1->value)), *(float*)($3->value));
                                        else if ($3->type == INTEGER_T)
                                            *result = pow(*(float*)($1->value), (float)(*(int*)($3->value)));
                                        else
                                            *result = pow(*(float*)($1->value), *(float*)($3->value));
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                }
    | '-' expression             {
                                    checkParamIsNumber($2->type,yylineno);
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $2->name);
                                    quadManager.addQuadruple("Minus", "", std::string($2->name), temp);
                                    $$ = new ExprValue;
                                    // Handle integer and float negation properly
                                    if ($2->type == INTEGER_T) {
                                        int* result = new int(-*(int*)($2->value));
                                        $$->value = (void*)result;
                                        $$->type = INTEGER_T;
                                    } else {
                                        float* result = new float(-*(float*)($2->value));
                                        $$->value = (void*)result;
                                        $$->type = FLOAT_T;
                                    }
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression '||' expression {
                                    checkBothParamsAreBoolean($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) || *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("||", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression '&&' expression {
                                    checkBothParamsAreBoolean($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) && *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("&&", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression '<' expression  {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) < *(int*)($3->value));
                                    $$->value = (void*)result;  
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("<", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression '>' expression {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) > *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple(">", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression GE expression  {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) >= *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple(">=", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression LE expression    {
                                    checkBothParamsAreNumbers($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) <= *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("<=", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression EQ expression  {
                                    checkBothParamsAreOfSameType($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) == *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("==", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | expression NE expression  {
                                    checkBothParamsAreOfSameType($1->type,$3->type,yylineno);
                                    $$ = new ExprValue;
                                    $$->type = BOOLEAN_T;
                                    int* result = new int(*(int*)($1->value) != *(int*)($3->value));
                                    $$->value = (void*)result;
                                    std::string temp = quadManager.newTemp();
                                    printf("Name of result: %s\n", temp.c_str());
                                    printf("Name of first: %s\n", $1->name);
                                    printf("Name of second: %s\n", $3->name);
                                    quadManager.addQuadruple("!=", std::string($1->name), std::string($3->name), temp);
                                    $$->name = strdup(temp.c_str());
                                 }
    | '(' expression ')'        { $$ = $2; }
    ;

arguments:
    argumentsList  { $$ = $1; }
    | /* NULL */   { $$ = createArgumentList(); }
    ;

argumentsList:
    dataType VARIABLE                           {
                                                    void* paramList = createArgumentList();
                                                    void* variable = createVariable($1,$2, yylineno,0);
                                                    addVariableToArgumentList(paramList,variable);
                                                    $$ = paramList;
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
    assignmentValue ',' parametersList      { void* paramList = $3; 
                                                addTypeToParamList(paramList,$1->type);
                                                $$ = paramList;
                                            }

    | assignmentValue                   { void* paramList = createParamList(); 
                                            addTypeToParamList(paramList,$1->type);
                                             $$ = paramList; 
                                        }
                                            
    ;

case:
    CASE caseCondition ':' scope
    | CASE caseCondition ':' scope case
    ;

caseCondition:
    CHAR
    | INTEGER
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
        printf("Usage: %s <input file>\n", argv[0]);
        return 1;
    }

    // Open the input file
    yyin = fopen(argv[1], "r");
    if(yyin == NULL) {
        printf("Error: Unable to open file %s\n", argv[1]);
        return 1;
    }
    
    // Call the parser
    yyparse();
    // printSymbolTable();
    quadManager.printQuadruples();
    // Close the input file
    fclose(yyin);
    return 0;
}