%{
    #include "y.tab.h"
    #include <stdio.h>      // for functions like printf and scanf
    #include <string.h>     // for functions like strcmp
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    // int count = 1;
%}
%option yylineno
%%

([1-9][0-9]*|0)         {
                          yylval.integer = atoi(yytext);
                          printf("Token: INTEGER, Value: %d\n", yylval.integer);
                          return INTEGER;
                        }

([1-9][0-9]*|0)\.[0-9]+ {
                          yylval.floating = atof(yytext);
                          printf("Token: FLOATING, Value: %f\n", yylval.floating);
                          return FLOATING;
                        }

\'[^\']?\'              {
                          yylval.character = yytext[1];
                          printf("Token: CHARACTER, Value: %c\n", yylval.character);
                          return CHARACTER;
                        }

\"[^\"]*\"              {
                          yylval.string = strdup(yytext);
                          printf("Token: CHARARRAY, Value: %s\n", yylval.string);
                          return CHARARRAY;
                        }

("True"|"False")        {
                          yylval.integer = (strcmp(yytext, "True") == 0 ? 1 : 0);
                          printf("Token: BOOLEAN, Value: %d\n", yylval.integer);
                          return BOOLEAN;
                        }

[-+/*(){}.=;&|><?:,]    {
                          yylval.string = strdup(yytext);
                          printf("Token: %s\n", yytext);
                          return *yytext;
                        }

"while"                 {
                          printf("Token: WHILE\n");
                          return WHILE;
                        }

"repeat"                {
                          printf("Token: REPEAT\n");
                          return REPEAT;
                        }

"until"                 {
                          printf("Token: UNTIL\n");
                          return UNTIL;
                        }

"for"                   {
                          printf("Token: FOR\n");
                          return FOR;
                        }

"switch"                {
                          printf("Token: SWITCH\n");
                          return SWITCH;
                        }
"case"                  {
                          printf("Token: CASE\n");
                          return CASE;
                        }

"if"                    {
                          printf("Token: IF\n");
                          return IF;
                        }

"then"                  {
                          printf("Token: THEN\n");
                          return THEN;
                        }

"else"                  {
                          printf("Token: ELSE\n");
                          return ELSE;
                        }

"function"              {
                          printf("Token: FUNCTION\n");
                          return FUNCTION;
                        }

"return"                {
                          printf("Token: RETURN\n");
                          return RETURN;
                        }

"int"                   {
                          printf("Token: INT\n");
                          return INT;
                        }

"float"                 {
                          printf("Token: FLOAT\n");
                          return FLOAT;
                        }

"bool"                  {
                          printf("Token: BOOL\n");
                          return BOOL;
                        }

"char"                  {
                          printf("Token: CHAR\n");
                          return CHAR;
                        }

"string"                {
                          printf("Token: STRING\n");
                          return STRING;
                        }

"const"                 {
                          printf("Token: CONST\n");
                          return CONST;
                        }

"void"                  {
                          printf("Token: VOID\n");
                          return VOID;
                        }

">="                    {
                          printf("Token: GE\n");
                          return GE;
                        }

"<="                    {
                          printf("Token: LE\n");
                          return LE;
                        }

"=="                    {
                          printf("Token: EQ\n");
                          return EQ;
                        }

"!="                    {
                          printf("Token: NE\n");
                          return NE;
                        }

[a-zA-Z_][a-zA-Z0-9_]*  {
                        //   yylval.sIndex = count++;
                          printf("Token: VARIABLE, Value: %s\n", yytext);
                          yylval.string = yytext;
                          return VARIABLE;
                        }

[ \t\n]+                ; /* Ignore whitespace */

\/\/.*                  ; /* Ignore comments */

.                       ; yyerror("Invalid character for some reason");

%%

int yywrap(void) {
    return 1;
}