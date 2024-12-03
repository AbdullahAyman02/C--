%{
    #include <stdio.h>      // for functions like printf and scanf
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    int yylex(void);        // for lexical analysis. This function is called to get the next token
    extern FILE *yyin;      // for file handling. This is the input file. The default is stdin
%}

// The union is used to define the types of the tokens. Since the datatypes that we will work with are  either int/float, char/string, and boolean, we will use a union to define the types of the tokens   
%union {
    int integer;            // integer value
    float floating;         // floating value
    char character;         // character value
    char* string;           // string value
    bool boolean;           // boolean value
};

// The tokens are defined here. The tokens are the smallest unit of the language. They are the keywords, identifiers, operators, etc. that are used in the language
%token <integer> INT
%token <floating> FLOAT
%token <boolean> BOOL
%token <character> CHAR
%token <string> STRING
%token <string> VARIABLE
%token <string> FUNCTION_NAME
%token CONST REPEAT UNTIL FOR SWITCH CASE IF THEN ELSE RETURN WHILE FUNCTION VOID GE LE EQ NE

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
    statement ';' program
    | /* NULL */
    | ';' program
    ;

scope:
    '{' program '}'
    ;

dataType:
    INT | FLOAT | CHAR | STRING | BOOL
    ;

declaration:
    dataType VARIABLE
    | dataType VARIABLE '=' assignmentValue
    | CONST dataType VARIABLE '=' assignmentValue
    ;

assignment:
    VARIABLE '=' assignmentValue
    ;

assignmentValue:
    expression
    | CHAR
    | STRING
    | FUNCTION_NAME '(' parameters ')'
    ;

initialization:
    declaration
    | assignment
    ;

expression:
    mathematical
    | logical
    | VARIABLE
    ;

mathematical:
    mathematical '+' mathematical
    | mathematical '-' mathematical
    | mathematical '*' mathematical
    | mathematical '/' mathematical
    | mathematical '^' mathematical
    | '-' mathematical
    | '(' mathematical ')'
    | numerical
    ;

numerical:
    INT
    | FLOAT
    ;

logical:
    mathematical '>' mathematical
    | mathematical '<' mathematical
    | mathematical GE mathematical
    | mathematical LE mathematical
    | mathematical EQ mathematical
    | mathematical NE mathematical
    | logical '|' logical
    | logical '&' logical
    | '(' logical ')'
    | BOOL
    ;


statement:
    initialization
    | WHILE '(' expression ')' scope
    | REPEAT scope UNTIL '(' expression ')'
    | FOR '(' initialization ';' expression ';' assignment ')' scope
    | SWITCH '(' expression ')' '{' case '}'
    | scope
    | IF '(' expression ')' THEN scope
    | IF '(' expression ')' THEN scope ELSE scope
    | FUNCTION dataType FUNCTION_NAME '(' arguments ')' scope
    | FUNCTION VOID FUNCTION_NAME '(' arguments ')' scope
    | FUNCTION_NAME '(' parameters ')'
    | RETURN assignmentValue
    | RETURN
    ;

argumentsList:
    dataType VARIABLE
    | dataType VARIABLE ',' argumentsList
    ;

arguments:
    argumentsList
    | /* NULL */
    ;

parametersList:
    assignmentValue ',' parametersList
    | assignmentValue
    ;

parameters:
    parametersList
    | /* NULL */
    ;

case:
    CASE caseCondition ':' scope
    | CASE caseCondition ':' scope case
    ;

caseCondition:
    CHAR
    | caseExpression
    ;

caseExpression:
    mathematical
    | logical
    ;

%%

void yyerror(char *s) {
    fprintf(stderr, "%s\n", s);
}

int main() {
    // Open the input file
    yyin = fopen("input.txt", "r");
    // Call the parser
    yyparse();
    // Close the input file
    fclose(yyin);
    return 0;
}