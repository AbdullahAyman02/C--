all: clean flex bison gcc

clean:
	del /F /Q *.yy.c *.tab.c *.tab.h *.output *.o parser.exe 2>nul || rm -f *.yy.c *.tab.c *.tab.h *.output parser *.o nul
	
flex:
	flex lexer.l

bison:
	bison --yacc -d -v parser.y

gcc:
	gcc -c -g y.tab.c
	gcc -c -g lex.yy.c
	gcc -c -g common.c
	g++ -std=c++11 -g -o parser y.tab.o lex.yy.o common.o Quadruple.cpp QuadrupleManager.cpp SymbolTable.cpp