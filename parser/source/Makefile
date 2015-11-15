FUENTE = mxml_asp

all: compile clean_source

compile:
	gcc -c lib/stack.c -w
	gcc -c lib/queue.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o ../$(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o queue.o -lfl -ly -lm

clean_source:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o queue.o

clean_all:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o queue.o $(FUENTE) output.asp

