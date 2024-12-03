%{
    #include <stdio.h>      // for functions like printf and scanf
    void yyerror(char *);   // for error handling. This function is called when an error occurs
%}

%%

// TODO: Implement the lexer rules here (regex and actions)
// REMOVE THE PREVIOUS COMMENT BEFORE RUNNING THE LEXER

%%

int yywrap() {
    return 1;
}