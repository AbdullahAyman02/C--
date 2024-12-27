all: clean flex bison gcc

clean:
	del /F /Q *.yy.c *.tab.c *.tab.h *.output *.o parser.exe 2>nul || rm -f *.yy.c *.tab.c *.tab.h *.output parser *.o

flex:
	flex lexer.l

bison:
	bison --yacc -d -v parser.y

gcc:
	gcc -c y.tab.c
	gcc -c lex.yy.c
	gcc -c common.c
	g++ -std=c++11 -o parser y.tab.o lex.yy.o common.o Quadruples.cpp SymbolTable.cpp