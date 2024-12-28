%{
    #include "common.h"
    #include "y.tab.h"
    #include <stdio.h>      // for functions like debugPrintf and scanf
    #include <string.h>     // for functions like strcmp
    void yyerror(char *);   // for error handling. This function is called when an error occurs
    // int count = 1;
    
%}
%option yylineno
%%

([1-9][0-9]*|0)         {
                          yylval.integer = atoi(yytext);
                          debugPrintf("Token: INTEGER, Value: %d\n", yylval.integer);
                          return INTEGER;
                        }

([1-9][0-9]*|0)\.[0-9]+ {
                          yylval.floating = atof(yytext);
                          debugPrintf("Token: FLOATING, Value: %f\n", yylval.floating);
                          return FLOATING;
                        }

\'[^\']?\'              {
                          yylval.character = yytext[1];
                          debugPrintf("Token: CHARACTER, Value: %c\n", yylval.character);
                          return CHARACTER;
                        }

\"[^\"]*\"              {
                          yylval.string = strdup(yytext);
                          debugPrintf("Token: CHARARRAY, Value: %s\n", yylval.string);
                          return CHARARRAY;
                        }

("True"|"False")        {
                          yylval.integer = (strcmp(yytext, "True") == 0 ? 1 : 0);
                          debugPrintf("Token: BOOLEAN, Value: %d\n", yylval.integer);
                          return BOOLEAN;
                        }

([-+/*(){}\^.=;><?:,]|&&|\|\|)   {
                                yylval.string = strdup(yytext);
                                debugPrintf("Token: %s\n", yytext);
                                return *yytext;
                               }

"while"                 {
                          debugPrintf("Token: WHILE\n");
                          return WHILE;
                        }

"repeat"                {
                          debugPrintf("Token: REPEAT\n");
                          return REPEAT;
                        }

"until"                 {
                          debugPrintf("Token: UNTIL\n");
                          return UNTIL;
                        }

"for"                   {
                          debugPrintf("Token: FOR\n");
                          return FOR;
                        }

"switch"                {
                          debugPrintf("Token: SWITCH\n");
                          return SWITCH;
                        }
"case"                  {
                          debugPrintf("Token: CASE\n");
                          return CASE;
                        }

"if"                    {
                          debugPrintf("Token: IF\n");
                          return IF;
                        }

"then"                  {
                          debugPrintf("Token: THEN\n");
                          return THEN;
                        }

"else"                  {
                          debugPrintf("Token: ELSE\n");
                          return ELSE;
                        }

"function"              {
                          debugPrintf("Token: FUNCTION\n");
                          return FUNCTION;
                        }

"return"                {
                          debugPrintf("Token: RETURN\n");
                          return RETURN;
                        }

"int"                   {
                          debugPrintf("Token: INT\n");
                          return INT;
                        }

"float"                 {
                          debugPrintf("Token: FLOAT\n");
                          return FLOAT;
                        }

"bool"                  {
                          debugPrintf("Token: BOOL\n");
                          return BOOL;
                        }

"char"                  {
                          debugPrintf("Token: CHAR\n");
                          return CHAR;
                        }

"string"                {
                          debugPrintf("Token: STRING\n");
                          return STRING;
                        }

"const"                 {
                          debugPrintf("Token: CONST\n");
                          return CONST;
                        }

"void"                  {
                          debugPrintf("Token: VOID\n");
                          return VOID;
                        }

">="                    {
                          debugPrintf("Token: GE\n");
                          return GE;
                        }

"<="                    {
                          debugPrintf("Token: LE\n");
                          return LE;
                        }

"=="                    {
                          debugPrintf("Token: EQ\n");
                          return EQ;
                        }

"!="                    {
                          debugPrintf("Token: NE\n");
                          return NE;
                        }

[a-zA-Z_][a-zA-Z0-9_]*  {
                        //   yylval.sIndex = count++;
                          debugPrintf("Token: VARIABLE, Value: %s\n", yytext);
                          yylval.string = strdup(yytext);
                          return VARIABLE;
                        }

[ \t\n]+                ; /* Ignore whitespace */

\/\/.*                  ; /* Ignore single-line comments */

\/\*[^*]*\*+([^/*][^*]*\*+)*\/ {
                            /* Ignore multi-line comments */
                          }

\/\*[^*]*               {
                            debugPrintf("Error: Unterminated comment starting at line %d\n", yylineno);
                            yyerror("Unterminated comment");
                          }

.                       {
                          char errorChar = yytext[0];
                          debugPrintf("Error: Invalid character '%c' at line %d\n", errorChar, yylineno);
                          yyerror("Invalid character");
                        }

%%

int yywrap(void) {
    return 1;
}