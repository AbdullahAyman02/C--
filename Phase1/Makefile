extension=".exe"
MACRO=""
PLATFORM ?= WINDOWS_PLATFORM

ifeq ($(PLATFORM), UNIX_PLATFORM)
	extension=""
	MACRO="-D UNIX_PLATFORM"
endif

all: clean flex bison gcc

clean:
	rm -f *.yy.c *.tab.c *.tab.h *.output parser${extension}

flex:
	flex lexer.l

bison:
	bison -d -v parser.y

gcc:
	gcc ${MACRO} lex.yy.c parser.tab.c -o parser${extension}
