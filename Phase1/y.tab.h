
/* A Bison parser, made by GNU Bison 2.4.1.  */

/* Skeleton interface for Bison's Yacc-like parsers in C
   
      Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.
   
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.
   
   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */


/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     INTEGER = 258,
     INT = 259,
     FLOATING = 260,
     FLOAT = 261,
     BOOLEAN = 262,
     BOOL = 263,
     CHARACTER = 264,
     CHAR = 265,
     CHARARRAY = 266,
     STRING = 267,
     VARIABLE = 268,
     CONST = 269,
     REPEAT = 270,
     UNTIL = 271,
     FOR = 272,
     SWITCH = 273,
     CASE = 274,
     IF = 275,
     THEN = 276,
     ELSE = 277,
     RETURN = 278,
     WHILE = 279,
     FUNCTION = 280,
     VOID = 281,
     GE = 282,
     LE = 283,
     EQ = 284,
     NE = 285
   };
#endif
/* Tokens.  */
#define INTEGER 258
#define INT 259
#define FLOATING 260
#define FLOAT 261
#define BOOLEAN 262
#define BOOL 263
#define CHARACTER 264
#define CHAR 265
#define CHARARRAY 266
#define STRING 267
#define VARIABLE 268
#define CONST 269
#define REPEAT 270
#define UNTIL 271
#define FOR 272
#define SWITCH 273
#define CASE 274
#define IF 275
#define THEN 276
#define ELSE 277
#define RETURN 278
#define WHILE 279
#define FUNCTION 280
#define VOID 281
#define GE 282
#define LE 283
#define EQ 284
#define NE 285




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
{

/* Line 1676 of yacc.c  */
#line 12 "parser.y"

    int integer;            // integer value
    float floating;         // floating value
    char character;         // character value
    char* string;           // string value
    // bool boolean;           // boolean value



/* Line 1676 of yacc.c  */
#line 122 "y.tab.h"
} YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
#endif

extern YYSTYPE yylval;


