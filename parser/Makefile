FUENTE = mxml_asp
INPUT = input/music.xml

all: compile run clean

compile:
	gcc -c lib/stack.c -w
	flex $(FUENTE).l
	bison -o $(FUENTE).tab.c $(FUENTE).y -yd
	gcc -o $(FUENTE) lex.yy.c $(FUENTE).tab.c stack.o -lfl -ly -lm

run:
	./$(FUENTE) < $(INPUT)

clean:
	rm $(FUENTE) lex.yy.c $(FUENTE).tab.c $(FUENTE).tab.h stack.o

