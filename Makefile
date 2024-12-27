all: clean flex bison gcc

clean:
ifeq ($(OS),Windows_NT)
	del /F /Q *.yy.c *.tab.c *.tab.h *.output *.o parser.exe 2>nul || true
else
	rm -f *.yy.c *.tab.c *.tab.h *.output parser *.o
endif

flex:
	flex lexer.l

bison:
	bison --yacc -d -v parser.y

gcc:
	gcc -c y.tab.c
	gcc -c lex.yy.c
	g++ -std=c++11 -o parser y.tab.o lex.yy.o Quadruples.cpp SymbolTable.cpp