%{
    #include "common.h"
    #include <stdio.h>      // for functions like printf and scanf
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    int yylex(void);        // for lexical analysis. This function is called to get the next token
    extern FILE *yyin;      // for file handling. This is the input file. The default is stdin
    extern int yylineno;    // for line number. This variable stores the current line number
    extern char *yytext;    // for token text. This variable stores the current token text
    #define YYDEBUG 1       // for debugging. If set to 1, the parser will print the debugging information
    extern int yydebug;     // for debugging. This variable stores the current debugging level

%}

// The union is used to define the types of the tokens. Since the datatypes that we will work with are  either int/float, char/string, and boolean, we will use a union to define the types of the tokens   
%union {
    int integer;            // integer value
    float floating;         // floating value
    char character;         // character value
    char* string;           // string value
    Type type;      // data type
    void* list;        // list of parameters
    // bool boolean;           // boolean value
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

%type <type> dataType expression assignmentValue functionCall
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
    | assignment
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
                                                        Type assignmentType = $4;
                                                        Type variableType = $1;
                                                        checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
                                                }
    | CONST dataType VARIABLE '=' assignmentValue { 
                                                        void* variable = createVariable($2,$3, yylineno,1);
                                                        Type assignmentType = $5;
                                                        Type variableType = $2;
                                                        checkBothParamsAreOfSameType(variableType,assignmentType,yylineno);
                                                        addSymbolToSymbolTable(variable);
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
    VARIABLE '=' assignmentValue
    ;

assignmentValue:
    expression                                  { $$ = $1; }
    | CHARACTER                                 { $$ = CHAR_T; }
    | CHARARRAY                                 { $$ = STRING_T; }
    | functionCall                              { $$ = $1; }
    ;

functionCall:
    VARIABLE '(' parameters ')'     {
                                        void* function = getSymbolFromSymbolTable($1,yylineno);
                                        void* parametersList = $3;
                                        checkParamListAgainstFunction(parametersList,function,yylineno);
                                        $$ = getSymbolType(function);
                                    }
    ;

expression:
    VARIABLE                    { 
                                    void* variable = getSymbolFromSymbolTable($1,yylineno);
                                    $$ = getSymbolType(variable);
                                }
    | INTEGER                   { $$ = INTEGER_T; }
    | FLOATING                  { $$ = FLOAT_T; }
    | BOOLEAN                   { $$ = BOOLEAN_T; }
    | expression '+' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = $1;
                                }
    | expression '-' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = $1;
                                }
    | expression '*' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = $1;
                                }
    | expression '/' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = $1;
                                }
    | expression '^' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = $1;
                                }
    | '-' expression             {
                                    checkParamIsNumber($2,yylineno);
                                     $$ = $2;
                                 }
    | expression '||' expression {
                                    checkBothParamsAreBoolean($1,$3,yylineno);
                                    $$ = $1;
                                 }
    | expression '&&' expression {
                                    checkBothParamsAreBoolean($1,$3,yylineno);
                                    $$ = $1;
                                 }
    | expression '<' expression  {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
                                 }
    | expression '>' expression {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
                                 }
    | expression GE expression  {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
                                 }
    | expression LE expression    {
                                    checkBothParamsAreNumbers($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
                                 }
    | expression EQ expression  {
                                    checkBothParamsAreOfSameType($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
                                 }
    | expression NE expression  {
                                    checkBothParamsAreOfSameType($1,$3,yylineno);
                                    $$ = BOOLEAN_T;
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
                                                addTypeToParamList(paramList,$1);
                                                $$ = paramList;
                                            }

    | assignmentValue                   { void* paramList = createParamList(); 
                                            addTypeToParamList(paramList,$1);
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
    printSymbolTable();
    // Close the input file
    fclose(yyin);
    return 0;
}