FUENTE = mxml_asp

all: compile compile_parser clean_source

debug: compile compile_debug clean_source

compile:
	gcc -c lib/stack.c -w
	gcc -c lib/queue.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd

compile_parser:
	gcc -o ../$(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o queue.o -lfl -ly -lm

compile_debug:
	gcc -o ../$(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o queue.o -lfl -ly -lm -g

clean_source:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o queue.o

clean_all:
	rm lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o queue.o $(FUENTE) output.asp


