
all: clean flex bison gcc

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.output parser

flex:
	flex lexer.l

bison:
	bison --yacc -d -v parser.y

gcc:
	gcc lex.yy.c y.tab.c -o parser
