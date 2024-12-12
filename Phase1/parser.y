%{
    #include <stdio.h>      // for functions like printf and scanf
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    int yylex(void);        // for lexical analysis. This function is called to get the next token
    extern FILE *yyin;      // for file handling. This is the input file. The default is stdin
    extern int yylineno;    // for line number. This variable stores the current line number
    extern char *yytext;    // for token text. This variable stores the current token text
    #define YYDEBUG 1       // for debugging. If set to 1, the parser will print the debugging information
    extern int yydebug;     // for debugging. This variable stores the current debugging level
    #include "example.h"
%}

// The union is used to define the types of the tokens. Since the datatypes that we will work with are  either int/float, char/string, and boolean, we will use a union to define the types of the tokens   
%union {
    int integer;            // integer value
    float floating;         // floating value
    char character;         // character value
    char* string;           // string value
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
%left '|'           // left associative token. This means that the token is evaluated from left to right a | b | c -> (a | b) | c
%left '&'
%left '<' '>' GE LE EQ NE
%left '+' '-'
%left '*' '/'
%right '^'          // right associative token. This means that the token is evaluated from right to left a ^ b ^ c -> a ^ (b ^ c)

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
    | FUNCTION dataType VARIABLE '(' arguments ')' scope                { printf("function\n");}
    | FUNCTION VOID VARIABLE '(' arguments ')' scope                    { printf("function\n");}
    | VARIABLE '(' parameters ')'                                       { printf("function call\n"); }
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
    dataType VARIABLE
    | dataType VARIABLE '=' assignmentValue     { printf("dataType VARIALE = assignmentValue\n"); }
    | CONST dataType VARIABLE '=' assignmentValue
    ;

dataType:
    INT | FLOAT | CHAR | STRING | BOOL          { printf("dataType\n"); }
    ;

assignment:
    VARIABLE '=' assignmentValue
    ;

assignmentValue:
    expression                                  { printf("expression\n"); }
    | CHARACTER
    | CHARARRAY
    | VARIABLE '(' parameters ')'
    ;

expression:
    VARIABLE
    | INTEGER
    | FLOATING
    | BOOLEAN
    | expression '+' expression
    | expression '-' expression
    | expression '*' expression
    | expression '/' expression
    | expression '^' expression
    | '-' expression
    | expression '|' expression
    | expression '&' expression
    | expression '<' expression
    | expression '>' expression
    | expression GE expression
    | expression LE expression
    | expression EQ expression
    | expression NE expression
    | '(' expression ')'
    ;

arguments:
    argumentsList
    | /* NULL */
    ;

argumentsList:
    dataType VARIABLE
    | dataType VARIABLE ',' argumentsList
    ;

parameters:
    parametersList
    | /* NULL */
    ;

parametersList:
    assignmentValue ',' parametersList
    | assignmentValue
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
    
    // Close the input file
    fclose(yyin);
    my_function_c();
    return 0;
}