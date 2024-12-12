extension=".exe"
MACRO=""
PLATFORM ?= WINDOWS_PLATFORM

ifeq ($(PLATFORM), UNIX_PLATFORM)
	extension=""
	MACRO="-D UNIX_PLATFORM"
endif

all: clean flex bison gcc

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.output *.o parser${extension}

flex:
	flex lexer.l

bison:
	bison -d -v parser.y

gcc:
	gcc -c ${MACRO} lex.yy.c 
	gcc -c ${MACRO} parser.tab.c
	g++ -c ${MACRO} example.cpp 
	g++ ${MACRO} lex.yy.o parser.tab.o example.o -o parser${extension}
