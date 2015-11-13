FUENTE = mxml_asp

all: compile clean_source

compile:
	gcc -c lib/stack.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o ../$(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o -lfl -ly -lm

clean_source:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o

clean_all:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o $(FUENTE) output.asp

