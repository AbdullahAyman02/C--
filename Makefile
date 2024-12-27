
all: clean flex bison gcc

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.output parser *.o

flex:
	flex lexer.l

bison:
	bison --yacc -d -v parser.y

gcc:
	gcc -c y.tab.c
	gcc -c lex.yy.c
	g++ -std=c++11 -o parser y.tab.o lex.yy.o Quadruples.cpp SymbolTable.cpp

