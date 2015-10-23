FUENTE = mxml_asp
INPUT = input/music.xml

all: compile clean_source

compile:
	gcc -c lib/stack.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o ../$(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o -lfl -ly -lm

compile_windows:
	gcc -c lib/stack.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	/opt/mingw32/bin/i686-w64-mingw32-gcc lex.yy.c $(FUENTE).tab.c stack.o -lfl -ly -lm -o ../$(FUENTE).exe

clean_source:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o

clean_all:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o $(FUENTE) output.asp

