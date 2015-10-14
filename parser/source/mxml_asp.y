%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>
#include <unistd.h>
#include "lib/stack.h"

void yyerror (char const *);

stack * stag;
int part = 0;
int note_position;
char * act_note;
char * voice;
char * act_alter;
int act_note_val;
int act_oct;
FILE *f;


int noteVal (char * note, char * act_alter){
	int alterVal;
	alterVal = 0;
	if(!strcmp(act_alter, "flat"))
		alterVal = -1;
	if(!strcmp(act_alter, "sharp"))
		alterVal = 1;
	if(!strcmp(act_alter, "natural"))
		alterVal = 0;

	if(!strcmp(note, "C"))
		return 24 + alterVal;
	if(!strcmp(note, "D"))
		return 26 + alterVal;
	if(!strcmp(note, "E"))
		return 28 + alterVal;
	if(!strcmp(note, "F"))
		return 29 + alterVal;
	if(!strcmp(note, "G"))
		return 31 + alterVal;
	if(!strcmp(note, "A"))
		return 21 + alterVal;
	if(!strcmp(note, "B"))
		return 23 + alterVal;
}
%}
%union{
	int valInt;
	float valFloat;
	char * valStr;
}
%token OPTAG CLTAG SLASHTAG EQUAL KVOTHE QUES EXCL NOTE OCTA STEP PART_ID REST CHORD ALTER DOCTYPE
%token <valStr> TEXT
%token <valInt> NUMBER
%type  <valInt> block part1 part2 body attr
%start S
%%
S : version doctype block | block | error {yyerror("Go home XML, you are drunk");};

version : OPTAG QUES TEXT attr QUES CLTAG {printf("Version OK\n");};

doctype : OPTAG EXCL DOCTYPE doctags docurl CLTAG {printf("DOCTYPE OK\n");};

doctags : /*...*/ {}
		| TEXT doctags {};

docurl : /*...*/ {}
		|  KVOTHE TEXT docwords KVOTHE docurl {};

docwords : /*...*/ {}
		|  SLASHTAG docwords {}
		|  TEXT docwords {}

block : OPTAG REST SLASHTAG CLTAG {$$ = 0; act_oct = -1;}
		| OPTAG TEXT attr SLASHTAG CLTAG {$$ = 0;}
		| OPTAG ALTER CLTAG TEXT OPTAG SLASHTAG ALTER CLTAG{$$ = 0; act_alter = $4;} 
		| OPTAG CHORD SLASHTAG CLTAG {$$ = 0; note_position = note_position-1;} 
		| OPTAG OCTA CLTAG TEXT OPTAG SLASHTAG OCTA CLTAG {$$ = 0; act_oct = atoi($4);} 
		| OPTAG STEP CLTAG TEXT OPTAG SLASHTAG STEP CLTAG {$$ = 0; act_note = $4;} 
		| part1 part2 {$$ = 0;} 
		| part1 error {yyerror("Close the tag, that enters viruji");}
		| part1 part2 error {yyerror("There are a lot of things there. Too many things.");};

part1 : OPTAG NOTE attr {$$ = 0; act_alter = ""; add_stack(stag, "note");} 
		| OPTAG PART_ID KVOTHE TEXT KVOTHE {$$ = 0; part= part+1; note_position = 0; add_stack(stag, "part");}
		| OPTAG TEXT attr {$$ = 0; add_stack(stag, (void*) $2);};

part2 : CLTAG body OPTAG SLASHTAG NOTE CLTAG {
			$$ = 0;
			if(strcmp("note", pop(stag))){
				printf("note - TAG NO CERRADO\n");
				exit(-1);
			};
			note_position = note_position+1;
			if (act_oct == -1){
				act_note_val = -1;
			} else {
				act_note_val = noteVal(act_note, act_alter) + (12 * act_oct);
			}
            fprintf(f, "note(%d, %d, %d).\n", part, act_note_val, note_position);
		} 
		| CLTAG OPTAG SLASHTAG TEXT CLTAG {
			$$ = 0; 
			if(strcmp($4, pop(stag))){
				printf("%s - TAG NO CERRADO\n", $4);
				exit(-1);
			};
		};
		| CLTAG body OPTAG SLASHTAG TEXT CLTAG {
			$$ = 0; 
			if(strcmp($5, pop(stag))){
				printf("%s - TAG NO CERRADO\n", $5);
				exit(-1);
			};
		};

attr : /*...*/ {} 
		| TEXT EQUAL KVOTHE TEXT KVOTHE attr {$$ = 0;};

body : body block {$$ = 0;}
	| body TEXT {$$ = 0;}
	| block {$$ = 0;}
	| TEXT {$$ = 0;};
%%


extern int yylex();
extern int yyparse();
extern FILE *yyin;

int usage(char* prog_name){
	printf ("usage: %s file.xml [-s subdivision] [-o file.lp]\n", prog_name);
	printf ("-s subdivision: subdivision in which the notes of the piece should be divided\n");
	printf ("-o file.lp: name for the output file, default is output.lp\n");
}

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Too few arguments\n");
		usage(argv[0]);
		exit(1);
	}

	FILE *infile = fopen(argv[1], "r");
	char* outfile = "output.lp";

	if (!infile) {
		printf("The input file specified can't be opened!\n");
		return -1;
	}

	int c;
	int subdivision = 4;

	while ((c = getopt (argc, argv, "s:o:")) != -1)
    switch (c)
      {
      case 's':
        subdivision = atoi(optarg);
        break;
      case 'o':
      	outfile = optarg;
      	break;
      case '?':
        if (optopt == 'o' || optopt == 's'){
        	fprintf (stderr, "Option -%c requires an argument.\n", optopt);
      	  	usage(argv[0]);
        }
        else if (isprint (optopt)){
        	fprintf (stderr, "Unknown option `-%c'.\n", optopt);
      	  	usage(argv[0]);
        }
        else {
        	fprintf (stderr,
                   "Unknown option character `\\x%x'.\n",
                   optopt);
      		usage(argv[0]);
        }
        return 1;
      default:
        abort ();
      }

	yyin = infile;

	f = fopen(outfile, "w");
	if (f == NULL){
	    printf("Error opening %s file!\n", outfile);
	    exit(1);
	}

	act_note = malloc(sizeof(char));

	stag = new_stack();
	do {
		yyparse();
	} while (!feof(yyin));

	fclose(f);
	printf("OK - Fichero output.asp generado\n");
	return 0;
}

void yyerror (char const *message) { 
	if (strcmp(message, "syntax error"))	{
		fprintf (stderr, "%s\n", message);
		exit(0);
	}
}