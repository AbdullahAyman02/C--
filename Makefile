
all: clean flex bison gcc

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.output parser

flex:
	win_flex lexer.l

bison:
	win_bison --yacc -d -v parser.y

gcc:
	gcc lex.yy.c y.tab.c -o parser
