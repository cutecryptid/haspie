%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>
#include <unistd.h>
#include "lib/stack.h"
#include "lib/queue.h"

void yyerror (char const *);

typedef struct{ 
	int voice;
	int value;
	int chordmod;
	int staff;
	int length;
	int dotted;
	int grace;
} note; 

typedef struct{ 
	int voice;
	int beats;
	int beattype;
	int position;
} measure;

typedef struct{
	char* root; 
	char* kind;
	int hbeat;
} chord;

stack * stag;
queue * note_q;
queue * meas_q;
queue * chord_q;
int part = 0;
int note_position;
char * act_note;
char * voice;
char * act_alter;
char * act_type;
char * act_lyric;
int act_note_val;
int act_oct;
int act_sub;
int act_beats;
int act_beattype;
int subdivision;
int opt_subdivision;
int act_length;
int act_dot;
int act_ch_mod;
int act_staff;
int grace_mod;
int key_fifths;
char* key_mode;
char* act_root;
char* act_kind;
note * tmp_note;
measure * tmp_meas;
chord * tmp_chord;
FILE *f;

chord * new_chord(){
	chord* c;
	c = malloc(sizeof(chord));
	c -> root = "";
	c -> kind = "";
	c -> hbeat = 0;
}

chord * mod_chord(chord* c, char* rt, char * kn, int hb){
	c -> root = rt;
	c -> kind = kn;
	c -> hbeat = hb;
}

note* new_note(){
	  note* n;
	  n = malloc(sizeof(note));
	  n -> voice = 0;
	  n -> value = 0;
	  n -> staff = 0;
	  n -> chordmod = 0;
	  n -> length = 0;
	  n -> dotted = 0;
	  return n;
}

note* mod_note(note* n, int voi, int val, int cm, int sta, int len, int dot, int gra){
	n -> voice = voi;
	n -> value = val;
	n -> chordmod = cm;
	n -> staff = sta;
	n -> length = len;
	n -> dotted = dot;
	n -> grace = gra;
	return n;
}

measure* new_measure(){
	  measure* m;
	  m = malloc(sizeof(measure));
	  m -> voice = 0;
	  m -> beats = 0;
	  m -> beattype = 0;
	  m -> position = 0;
	  return m;
}

measure* mod_measure(measure* m, int voi, int bea, int bet, int pos){
	m -> voice = voi;
	m -> beats = bea;
	m -> beattype = bet;
	m -> position = pos;
	return m;
}


int noteVal (char * note, int act_oct, char * act_alter){
	int alterVal;
	alterVal = 0;
	if(!strcmp(act_alter, "flat"))
		alterVal = -1;
	if(!strcmp(act_alter, "sharp"))
		alterVal = 1;
	if(!strcmp(act_alter, "natural"))
		alterVal = 0;

	int oct_val = 12 * act_oct;

	if(!strcmp(note, "C"))
		return 12 + oct_val + alterVal;
	if(!strcmp(note, "D"))
		return 14 + oct_val + alterVal;
	if(!strcmp(note, "E"))
		return 16 + oct_val + alterVal;
	if(!strcmp(note, "F"))
		return 17 + oct_val + alterVal;
	if(!strcmp(note, "G"))
		return 19 + oct_val + alterVal;
	if(!strcmp(note, "A"))
		return 9 + oct_val + 12 + alterVal;
	if(!strcmp(note, "B"))
		return 11 + oct_val + 12 + alterVal;
}

int type_to_int(char* notetype){
	int notelength;
	if (!strcmp(notetype, "32nd"))
		notelength = 32;
	if (!strcmp(notetype, "16th"))
		notelength = 16;
	if (!strcmp(notetype, "eighth"))
		notelength = 8;
	if (!strcmp(notetype, "quarter"))
		notelength = 4;
	if (!strcmp(notetype, "half"))
		notelength = 2;
	if (!strcmp(notetype, "whole"))
		notelength = 1;
	return notelength;
}


int subdivide(int notelength, int subdivision){
	if ((subdivision >= notelength) && (notelength != 0)){
		return subdivision/notelength;
	} else {
		printf("Cannot divide a 1/%d with a subdivision of 1/%d. Use automated mode or a smaller subdivision.\n", notelength, subdivision);
		return 1;
	}
	
}

int ispower2(int x){
	return (((x & (x - 1)) == 0) && (x >= 0) && (x <= 32));
}


%}
%union{
	int valInt;
	float valFloat;
	char * valStr;
}

%token OPTAG CLTAG SLASHTAG EQUAL KVOTHE QUES EXCL NOTE OCTA STEP PART_ID REST CHORD ALTER DOCTYPE OPTYPE CLTYPE
%token NOTVISIBLE BEATS BEATTYPE TIME DOT OPSTAFF CLSTAFF GRACETAG MODE HARMONY ROOT ROOTSTEP KIND FIFTHS KEY
%token <valStr> TEXT
%type  <valInt> block part1 part2 body attr
%start S
%%
S : version doctype block | block | error {yyerror("ERROR: Unrecognised file format. File is not Standard Music XML.");};

version : OPTAG QUES TEXT attr QUES CLTAG {printf("Version OK\n");};

doctype : OPTAG EXCL DOCTYPE doctags docurl CLTAG {printf("DOCTYPE OK\n");};

doctags : /*...*/ {}
		| TEXT doctags {};

docurl : /*...*/ {}
		|  KVOTHE TEXT docwords KVOTHE docurl {};

docwords : /*...*/ {}
		|  SLASHTAG docwords {}
		|  TEXT docwords {}

block : OPTAG REST SLASHTAG CLTAG {
		$$ = 0; 
		if (act_oct != -2){
			act_oct = -1;
		}
		}
		| OPTAG DOT SLASHTAG CLTAG {
			$$ = 0;
			act_dot = 1;
		}
		| GRACETAG{
			$$ = 0;
			grace_mod = 1;
		}
		| OPTAG TEXT attr SLASHTAG CLTAG {$$ = 0;}
		| OPTAG ALTER CLTAG TEXT OPTAG SLASHTAG ALTER CLTAG{$$ = 0; act_alter = $4;} 
		| OPTAG CHORD SLASHTAG CLTAG {$$ = 0; act_ch_mod = -1;} 
		| OPSTAFF TEXT CLSTAFF {$$ = 0; act_staff = atoi($2);} 
		| OPTAG OCTA CLTAG TEXT OPTAG SLASHTAG OCTA CLTAG {$$ = 0; act_oct = atoi($4);}
		| OPTAG BEATS CLTAG TEXT OPTAG SLASHTAG BEATS CLTAG {$$ = 0; act_beats = atoi($4);}
		| OPTAG BEATTYPE CLTAG TEXT OPTAG SLASHTAG BEATTYPE CLTAG {$$ = 0; act_beattype = atoi($4);} 
		| OPTAG STEP CLTAG TEXT OPTAG SLASHTAG STEP CLTAG {$$ = 0; act_note = $4;} 
		| OPTAG FIFTHS CLTAG TEXT OPTAG SLASHTAG FIFTHS CLTAG {$$ = 0; key_fifths= atoi($4);}
		| OPTAG MODE CLTAG TEXT OPTAG SLASHTAG MODE CLTAG {$$ = 0; key_mode=$4;}
		| OPTAG ROOTSTEP CLTAG TEXT OPTAG SLASHTAG ROOTSTEP CLTAG {$$ = 0; act_root = $4;}
		| OPTAG KIND CLTAG TEXT OPTAG SLASHTAG KIND CLTAG {$$ = 0; act_kind = $4;}
		| OPTYPE TEXT CLTYPE {$$ = 0; act_type = $2;}
		| part1 part2 {$$ = 0;} 
		| part1 error {yyerror("ERROR: Unclosed tag found.");}
		| part1 part2 error {yyerror("ERROR: Unrecognised file format. File is not Standard Music XML.");}; 

part1 : OPTAG NOTE attr {$$ = 0; act_alter = ""; act_ch_mod=0; grace_mod=0; act_staff=1; add_stack(stag, "note");}
		| OPTAG KEY  {$$ = 0; add_stack(stag, "key");}
		| OPTAG PART_ID KVOTHE TEXT KVOTHE {$$ = 0; part= part+1; note_position = 0; add_stack(stag, "part");}
		| OPTAG TIME {$$ = 0; add_stack(stag, "time");}
		| OPTAG HARMONY {$$ = 0; act_kind = "";}
		| OPTAG TEXT attr {$$ = 0; add_stack(stag, (void*) $2);};

part2 : CLTAG body OPTAG SLASHTAG NOTE CLTAG {
			$$ = 0;
			if(strcmp("note", pop(stag))){
				printf("note - UNCLOSED TAG\n");
				exit(-1);
			};
			switch(act_oct) {
			   	case -1:
			    	act_note_val = -1;
			      	break;
			   	case -2:
			      	act_note_val = -2;
			      	break;
			   	default :
			   	act_note_val = noteVal(act_note, act_oct, act_alter);
			}
			act_length = type_to_int(act_type);
			if (act_length > subdivision){
				subdivision = act_length;
			}
			note_position = note_position+1;
			if (act_dot && (act_length*2 > subdivision)){
				subdivision = act_length * 2;
			}
			tmp_note = new_note();
			tmp_note = mod_note(tmp_note, part, act_note_val, act_ch_mod, act_staff, act_length, act_dot, grace_mod);
			add_queue(note_q, tmp_note);
			act_dot = 0;
		}
		| CLTAG body OPTAG SLASHTAG TIME CLTAG {
			$$ = 0;
			if(strcmp("time", pop(stag))){
				printf("time - UNCLOSED TAG\n");
				exit(-1);
			};
			tmp_meas = new_measure();
			tmp_meas = mod_measure(tmp_meas, part, act_beats, act_beattype, note_position);
			add_queue(meas_q, tmp_meas);
		}
		| CLTAG body OPTAG SLASHTAG HARMONY CLTAG{
			$$ = 0;
			tmp_chord = new_chord();
			tmp_chord = mod_chord(tmp_chord, act_root, act_kind, note_position);
			add_queue(chord_q, tmp_chord);
		}
		| CLTAG OPTAG SLASHTAG TEXT CLTAG {
			$$ = 0; 
			if(strcmp($4, pop(stag))){
				printf("%s - UNCLOSED TAG\n", $4);
				exit(-1);
			};
		}
		| CLTAG body OPTAG SLASHTAG TEXT CLTAG {
			$$ = 0; 
			if(strcmp($5, pop(stag))){
				printf("%s - UNCLOSED TAG\n", $5);
				exit(-1);
			};
		};

attr : /*...*/ {}
		| NOTVISIBLE attr {$$ = 0; act_oct = -2;}
		| TEXT EQUAL KVOTHE TEXT KVOTHE attr {$$ = 0;};

body : body block {$$ = 0;}
	| body TEXT {$$ = 0;}
	| block {$$ = 0;}
	| TEXT {$$ = 0;};
%%


extern int yylex();
extern int yyparse();
extern FILE *yyin;

char * key_name(int kf, char * km){
	char* roots[] = {"A", "B-", "B", "C", "D-", "D", "E-", "E", "F", "G-", "G", "A-"};
	int key_fifths[] = {3, -2, 5, 0, -5, 2, -3, 4, -1, -6, 1, -4};
	// For minor scales just add 3 to the index (modulo'ed ofc)
	char* key_root = "";
	int key_index = 0;

    while ( key_index < 12 && key_fifths[key_index] != kf) ++ key_index;  

    if (strcmp(km, "major") == 0){
    	key_root = roots[key_index];
    } else {
    	key_root = roots[(key_index+3) % 12];
    }
}

int usage(char* prog_name){
	printf ("usage: %s file.xml [-s subdivision] [-o file.lp]\n", prog_name);
	printf ("-s subdivision: subdivision in which the notes of the piece should be divided\n");
	printf ("-o file.lp: name for the output file, default is output.lp\n");
}

int main(int argc, char *argv[]) {
	if (argc < 2) {
		printf("Too few arguments\n");
		usage(argv[0]);
		exit(-1);
	}

	FILE *infile = fopen(argv[1], "r");
	char* outfile = "output.lp";
	int c;
	act_staff = 1;
	subdivision = 0;
	opt_subdivision = 0;

	while ((c = getopt (argc, argv, "hs:o:")) != -1)
    switch (c)
      {
      case 'h':
      	usage(argv[0]);
      	return 1;
      case 's':
        opt_subdivision = atoi(optarg);
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

    if (!infile) {
		printf("The input file specified can't be opened! Make sure the file exists and that is not locked.\n");
		return 1;
	}

	if (!ispower2(opt_subdivision)){
		printf("The specified subdivision is not valid, choose a power of 2 between 1 and 32 (both included).\n");
		return 1;
	}

	yyin = infile;

	act_note = malloc(sizeof(char));
	key_fifths = 0;
	key_mode = "major";

	stag = new_stack();
	note_q = new_queue();
	meas_q = new_queue();
	chord_q = new_queue();
	do {
		yyparse();
	} while (!feof(yyin));

	if (opt_subdivision != 0){
		subdivision = opt_subdivision;
	}

	printf("Base note - 1/%d\n", subdivision);

	f = fopen(outfile, "w");
	if (f == NULL){
	    printf("Error writing to %s file! Make sure the route is valid and that it's not writing-protected.\n", outfile);
	    exit(-1);
	}

	int times;
	int act_part = 0;
	int pos = 0;
	int last_staff = 0;
	int fst_staff_pos = 0;
	int snd_staff_pos = 0;
	int voice_mod = 0;
	int staff_no = 0;
	int grace_overhead = 0;
	while(queue_size(*note_q) > 0){
		tmp_note = pop_queue(note_q);
		if (act_part != tmp_note->voice){
			act_part = tmp_note->voice;
			voice_mod += staff_no;
			staff_no = 0;
			pos = 0;
			last_staff = 0;
			fst_staff_pos = 0;
			snd_staff_pos = 0;
		}
		if (tmp_note -> staff != last_staff){
			if (tmp_note -> staff == 1){
				snd_staff_pos = pos;
				pos = fst_staff_pos;
			} else {
				fst_staff_pos = pos;
				pos = snd_staff_pos;
			}
			if (tmp_note -> staff > staff_no){
				staff_no = tmp_note-> staff;
			}
		}
		times = subdivide(tmp_note->length, subdivision);
		if (tmp_note->dotted){
			times+= times/2;
		}
		pos += times*tmp_note->chordmod;
		if (grace_overhead != 0){
			pos -= grace_overhead;
			grace_overhead = 0;
		}
		int i = 1;
		fprintf(f, "figure(%d,%d,%d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), times, pos+1);
		for (i; i < (times+1); i++){
			pos++;
			switch(tmp_note->value) {
			   	case -1:
			    	fprintf(f, "rest(%d, %d).\n", tmp_note->voice, pos);
			    	break;
			   	case -2:
			      	fprintf(f, "freebeat(%d, %d).\n", tmp_note->voice, pos);
			      	break;
			    default:
			    	if (tmp_note->grace){
			    		fprintf(f, "grace_note(%d, %d, %d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), tmp_note->value, pos);
			    		grace_overhead++;
			    	} else {
			    		fprintf(f, "note(%d, %d, %d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), tmp_note->value, pos);
			    	}
			}
		}
		last_staff = tmp_note -> staff;
	}

	while(queue_size(*meas_q) > 0){
		int s_factor;
		tmp_meas = pop_queue(meas_q);
		s_factor = (subdivision/tmp_meas->beattype);
		fprintf(f, "measure(%d, %d).\n", (tmp_meas->beats)*s_factor, tmp_meas->position);
		fprintf(f, "real_measure(%d, %d, %d).\n", tmp_meas->beats, tmp_meas->beattype, tmp_meas->position);
	}

	while(queue_size(*chord_q) > 0){
		tmp_chord = pop_queue(chord_q);
		printf("CHORD %s, %s, %d\n", tmp_chord->root, tmp_chord->kind, tmp_chord->hbeat);
		fprintf(f, "chord(%d, %s).\n", tmp_chord->hbeat, tmp_chord->root);
	}
	
	fclose(f);
	
	printf("OK - Correctly generated music logic file in %s\n", outfile);
	return subdivision;
}

void yyerror (char const *message) { 
	if (strcmp(message, "syntax error"))	{
		fprintf (stderr, "%s\n", message);
		exit(-1);
	}
}