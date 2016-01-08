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
	int harm_over;
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

typedef struct{
	int part_id;
	char * instrument;
	int limit_low;
	int limit_high;
} voice_type;

stack * stag;
queue * note_q;
queue * meas_q;
queue * chord_q;
queue * voice_q;
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
int act_voice;
char* act_instrument;
int voice_high;
int voice_low;
int act_harm_over;
char * justify;
char * valign;
char * title;
char * composer;
char act_sentence[140];
voice_type * tmp_voice;
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

voice_type * new_voice(){
	voice_type* v;
	v = malloc(sizeof(voice));
	v->part_id = 0;
	v->instrument = "";
	v-> limit_low = 0;
	v-> limit_high = 0;
}

voice_type * mod_voice(voice_type * v, int pid, char * inst, int low, int high){
	v->part_id = pid;
	v->instrument = inst;
	v-> limit_low = low;
	v-> limit_high = high;
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
	  n -> grace = 0;
	  n -> harm_over = 0;
	  return n;
}

note* mod_note(note* n, int voi, int val, int cm, int sta, int len, int dot, int gra, int hao){
	n -> voice = voi;
	n -> value = val;
	n -> chordmod = cm;
	n -> staff = sta;
	n -> length = len;
	n -> dotted = dot;
	n -> grace = gra;
	n -> harm_over = hao;
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
	if(!strcmp(act_alter, "flat") || !strcmp(act_alter, "-1"))
		alterVal = -1;
	if(!strcmp(act_alter, "sharp") || !strcmp(act_alter, "1"))
		alterVal = 1;
	if(!strcmp(act_alter, "natural") || !strcmp(act_alter, "0"))
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
%token INSTRUMENT SCOREPART CREDIT JUSTIFY VALIGN
%token <valStr> TEXT
%type  <valInt> block part1 part2 body attr
%start S
%%
S : version doctype block | block | error {yyerror("ERROR: Unrecognised file format. File is not Standard Music XML.");};

version : OPTAG QUES TEXT attr QUES CLTAG {};

doctype : OPTAG EXCL DOCTYPE doctags docurl CLTAG {};

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
		| OPTAG INSTRUMENT CLTAG TEXT OPTAG SLASHTAG INSTRUMENT CLTAG {$$=0;act_instrument = $4;}
		| OPTAG INSTRUMENT CLTAG OPTAG SLASHTAG INSTRUMENT CLTAG {$$=0;act_instrument = "";}
		| OPTAG FIFTHS CLTAG TEXT OPTAG SLASHTAG FIFTHS CLTAG {$$ = 0; key_fifths= atoi($4);}
		| OPTAG MODE CLTAG TEXT OPTAG SLASHTAG MODE CLTAG {$$ = 0; key_mode=$4;}
		| OPTAG ROOTSTEP CLTAG TEXT OPTAG SLASHTAG ROOTSTEP CLTAG {$$ = 0; act_root = $4;}
		| OPTAG KIND CLTAG TEXT OPTAG SLASHTAG KIND CLTAG {$$ = 0; act_kind = $4;}
		| OPTAG CREDIT attr CLTAG sentence OPTAG SLASHTAG CREDIT CLTAG{
			$$ = 0;
			if (strcmp(justify, "center") == 0 && strcmp(valign, "top") == 0){
				title = strdup(act_sentence);
			}
			if (strcmp(justify, "right") == 0 && strcmp(valign, "bottom") == 0){
				composer = strdup(act_sentence);
			}
			memset(&act_sentence[0], 0, sizeof(act_sentence));
		}
		| OPTYPE TEXT CLTYPE {$$ = 0; act_type = $2;}
		| part1 part2 {$$ = 0;} 
		| part1 error {yyerror("ERROR: Unclosed tag found.");}
		| part1 part2 error {yyerror("ERROR: Unrecognised file format. File is not Standard Music XML.");}; 

part1 : OPTAG NOTE attr {$$ = 0; act_alter = ""; act_ch_mod=0; grace_mod=0; act_staff=1; add_stack(stag, "note");}
		| OPTAG KEY  {$$ = 0; add_stack(stag, "key");}
		| OPTAG PART_ID KVOTHE TEXT KVOTHE {$$ = 0; part= part+1; note_position = 0; add_stack(stag, "part");}
		| OPTAG TIME {$$ = 0; add_stack(stag, "time");}
		| OPTAG HARMONY attr{$$ = 0; act_kind = ""; act_harm_over = 1;}
		| OPTAG SCOREPART attr{$$= 0; act_voice = act_voice +1; act_instrument = "";}
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
			tmp_note = mod_note(tmp_note, part, act_note_val, act_ch_mod, act_staff, act_length, act_dot, grace_mod, act_harm_over);
			add_queue(note_q, tmp_note);
			act_dot = 0;
			act_harm_over = 0;
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
		| CLTAG body OPTAG SLASHTAG SCOREPART CLTAG{
			if (strcmp(act_instrument, "") != 0){
				int i;
				for(i = 0; act_instrument[i]; i++){
					  act_instrument[i] = tolower(act_instrument[i]);
				}
			} else {
				act_instrument = "default";
			}
			tmp_voice = new_voice();
			mod_voice(tmp_voice, act_voice, act_instrument, voice_low, voice_high);
			add_queue(voice_q, tmp_voice);
			if (strcmp(act_instrument, "piano") == 0){
				act_voice = act_voice+1;
				tmp_voice = new_voice();
				mod_voice(tmp_voice, act_voice, act_instrument, voice_low, voice_high);
				add_queue(voice_q, tmp_voice);
			}
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
		| JUSTIFY EQUAL KVOTHE TEXT KVOTHE attr {$$ = 0; justify = $4;}
		| VALIGN EQUAL KVOTHE TEXT KVOTHE attr {$$ = 0; valign = $4;}
		| TEXT EQUAL KVOTHE TEXT KVOTHE attr {$$ = 0;};

sentence : TEXT {strcat(act_sentence, $1); strcat(act_sentence, " ");}
		| sentence TEXT {strcat(act_sentence, $2); strcat(act_sentence, " ");}

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
    return key_root;
}

int key_fifths_number(char * key_name, char * km){
	char* roots[] = {"A", "B-", "B", "C", "D-", "D", "E-", "E", "F", "G-", "G", "A-"};
	int key_fifths[] = {3, -2, 5, 0, -5, 2, -3, 4, -1, -6, 1, -4};
	// For minor scales just add 3 to the index (modulo'ed ofc)
	int key_fifths_no = 0;
	int key_index = 0;
    while ( key_index < 12 && strcmp(roots[key_index], key_name) != 0) ++ key_index;  

    if (strcmp(km, "major") == 0){
    	key_fifths_no = key_fifths[key_index];
    } else {
    	key_fifths_no = key_fifths[(key_index+3) % 12];
    }
    return key_fifths_no;
}

char ** tonality_scale(char * key_name, char * km, char* scale[]){
	char* notes[] = {"A", "B-", "B", "C", "D-", "D", "E-", "E", "F", "G-", "G", "A-"};
	int maj_pattern[] = {0,2,4,5,7,9,11};
	int min_pattern[] = {0,2,3,5,7,8,10};
	int key_index = 0;
	while (key_index < 12 && strcmp(notes[key_index],key_name) != 0) ++ key_index;
	// Create scale following pattern based on km
	int i;
	for (i = 0; i < 7; ++i)
	{
		scale[i] = malloc(5 * sizeof(char));
		if (strcmp(km, "major") == 0){
			scale[i] = notes[(key_index + maj_pattern[i]) % 12];
		} else {
			scale[i] = notes[(key_index + min_pattern[i]) % 12];
		}
	}
}

char * chord_grade(chord* c, char ** scale){
	char* grades[] = {"i", "ii", "iii", "iv", "v", "vi", "vii"};
	// Find root of chord in that scale, use that as index for grades
	int grade_index = 0;
	while (grade_index < 7 && strcmp(scale[grade_index],(c-> root))!=0) ++ grade_index;
	char str[5];
	strcpy(str, grades[grade_index]);
	int sz = strlen(grades[grade_index]);
	if (strcmp((c -> kind), "minor") == 0){
		strcat(str, "m");
		sz = sz + 1;
	}
	if (strcmp((c -> kind), "diminished") == 0){
		strcat(str, "o");
		sz = sz + 1;
	}
	if (strcmp((c -> kind), "dominant") == 0){
		strcat(str, "7");
		sz = sz + 1;
	}
	if (strcmp((c -> kind), "minor-seventh") == 0){
		strcat(str, "m7");
		sz = sz + 2;
	}
	char *ret_str = malloc(sz);
    strcpy(ret_str,str);
	return ret_str;
}

int usage(char* prog_name){
	printf ("usage: %s file.xml [-s subdivision] [-o file.lp]\n", prog_name);
	printf ("-d subdivision: subdivision in which the notes of the piece should be divided\n");
	printf ("-k key: key in which the piece should be harmonized\n");
	printf ("-s harmonization span: base figures taken in account to assign a chord\n");
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
	int harm_span = 1;
	char * opt_key = "";
	char * opt_mode = "";

	while ((c = getopt (argc, argv, "hd:k:m:s:o:")) != -1)
    switch (c)
      {
      case 'h':
      	usage(argv[0]);
      	return 1;
      case 'd':
        opt_subdivision = atoi(optarg);
        break;
      case 'k':
        opt_key = optarg;
        break;
      case 'm':
        opt_mode = optarg;
        break;
      case 's':
      	harm_span = atoi(optarg);
      	break;
      case 'o':
      	outfile = optarg;
      	break;
      case '?':
        if (optopt == 'o' || optopt == 's' || optopt == 'd' || optopt == 'k'){
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

	act_voice = 0;
	act_note = malloc(sizeof(char));
	key_fifths = 0;
	key_mode = "major";
	title = "";
	composer = "";

	stag = new_stack();
	note_q = new_queue();
	meas_q = new_queue();
	chord_q = new_queue();
	voice_q = new_queue();
	do {
		yyparse();
	} while (!feof(yyin));

	if (opt_subdivision != 0){
		subdivision = opt_subdivision;
	}

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
	int last_voice = 1;

	char * final_key;
	int final_fifths;
	char * final_mode;

	if (strcmp(opt_mode, "") != 0){
		final_mode = opt_mode;
	} else {
		final_mode = key_mode;
	}

	char * det_key = key_name(key_fifths,final_mode);
	if (strcmp(opt_key, "") != 0){
		final_key = opt_key;
		final_fifths = key_fifths_number(opt_key, final_mode);
	} else {
		final_key = det_key;
		final_fifths = key_fifths;
	}
	
	char *scale[7];
	tonality_scale(det_key,key_mode,scale);

	while(queue_size(*note_q) > 0){
		tmp_note = pop_queue(note_q);
		if (pos % harm_span == 0 && tmp_note->harm_over == 1 && queue_size(*chord_q) > 0 ){
			tmp_chord = pop_queue(chord_q);
			fprintf(f, "chord(%d, %s).\n", ((pos/harm_span)+1), chord_grade(tmp_chord, scale));
		}
		if (act_part != tmp_note->voice){
			act_part = tmp_note->voice;
			voice_mod += staff_no;
			if(queue_size(*voice_q) > 0){
				tmp_voice = pop_queue(voice_q);
				fprintf(f, "voice_type(%d, %s).\n", (tmp_voice->part_id + (tmp_note->staff-1) + voice_mod), tmp_voice->instrument);
				if (strcmp(tmp_voice->instrument, "piano") == 0){
					fprintf(f, "voice_type(%d, %s).\n", (tmp_voice->part_id + (tmp_note->staff) + voice_mod), tmp_voice->instrument);
				}
				if (tmp_voice -> limit_low != 0){
					fprintf(f, "voice_limit_low(%d, %d).\n", (tmp_voice->part_id + (tmp_note->staff-1) + voice_mod), tmp_voice->limit_low);
				}
				if (tmp_voice -> limit_high != 0){
					fprintf(f, "voice_limit_high(%d, %d).\n", (tmp_voice->part_id + (tmp_note->staff-1) + voice_mod), tmp_voice->limit_high);
				}
				last_voice = (tmp_voice->part_id + (tmp_note->staff-1) + voice_mod);
				if (strcmp(tmp_voice->instrument, "piano") == 0){
					last_voice++;
				}
			}
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
		if (!tmp_note->grace){
			fprintf(f, "figure(%d,%d,%d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), times, pos+1);
		}
		for (i; i < (times+1); i++){
			pos++;
			switch(tmp_note->value) {
			   	case -1:
			    	fprintf(f, "rest(%d, %d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), pos);
			    	break;
			   	case -2:
			      	fprintf(f, "freebeat(%d, %d).\n", (tmp_note->voice + (tmp_note->staff-1) + voice_mod), pos);
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
	
	fclose(f);

	if (strcmp(title, "") == 0){
		title = "Music Piece";
	}

    if (strcmp(composer, "") == 0){
		composer = "HASP";
	}

	printf("%s by %s\n", title, composer);
	printf("Base note - 1/%d\n", subdivision);
	printf("Detected %s %s key from key signature\n", det_key, key_mode);
	printf("Harmonizing in %s %s\n", final_key, final_mode);
	printf("OK - Correctly generated music logic file in %s\n", outfile);
	
	f = fopen("tmp/score_meta.cfg", "w");
	fprintf(f, "[meta]\n");
	fprintf(f, "title=%s\n", title);
	fprintf(f, "composer=%s\n", composer);

	fprintf(f, "[scoredata]\n");
	fprintf(f, "base_note=%d\n", subdivision);
	fprintf(f, "key_name=%s\n", final_key);
	fprintf(f, "key_value=%d\n", final_fifths);
	fprintf(f, "mode=%s\n", final_mode);
	fprintf(f, "last_voice=%d\n", last_voice);
	fclose(f);
	printf("Extra score information can be found in tmp/score_meta.conf\n");
	return 0;
}

void yyerror (char const *message) { 
	if (strcmp(message, "syntax error"))	{
		fprintf (stderr, "%s\n", message);
		exit(-1);
	}
}