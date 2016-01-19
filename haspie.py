import argparse
import subprocess
import re
import sys
import os
import threading
import errno
import ConfigParser
sys.path.append('./lib') 
from HaspMusic import ClaspResult
from HaspMusic import ClaspChords
import HaspMusic
import Out

def clasp_timeout(p):
    if p.poll() is None:
        try:
            p.kill()
            print 'Timeout reached, terminating clasp'
        except OSError as e:
            if e.errno != errno.ESRCH:
                print 'All options explored before timeout'

def key_to_base(key):
	base = 21
	split_key = re.search("([A-G])([\+\-])?", key)
	bases = [("C",21),("D",23),("E",25),("F",26),("G",28),("A",30),("B",32)]
	if split_key == None:
		raise ValueError("Key should be in the form [A-G][+-]?")
	groups = len(split_key.groups())
	if (groups > 0) or (groups <= 2):
		fund = split_key.group(0)
		base = [p[1] for p in bases if p[0] == key][0]
		if groups == 2:
			if split_key.group(1) == "+":
				mod = 1
			elif split_key.group(1) == "-":
				mod = -1
			else:
				mod = 0
	else:
		raise ValueError("Key should be in the form [A-G][+-]?")
	return (base + mod)

		
def main():
	parser = argparse.ArgumentParser(description='haspie - Harmonizing music with ASP')
	parser.add_argument('xml_score', metavar='XML_SCORE',
	                   help='input musicXML score for armonizing')
	parser.add_argument('-n', '--num_sols', metavar='N', nargs=1, default=0, type=int,
	                   help='max number of ASP solutions, by default all of them')
	parser.add_argument('-s', '--span', metavar='S', nargs=1, default=1, type=int,
	                   help='horizontal span to consider while harmonizing, this takes in account subdivision, by default 1')
	parser.add_argument('-v', '--voices', metavar='V', nargs="+", default="",
	                   help='extra instruments, these can be input by name or by numerical note range (i.e soprano,guitar,(65,90)...) to leave one of the sides of the range unespecified use 0')
	parser.add_argument('-S', '--show', action='store_true', default=False,
						help='show result in editor instead of writing it to a file in the desired format')
	parser.add_argument('-f', '--format', metavar='xml|pdf|midi|ly', nargs=1, default="xml", type=str,
	                   help='output file format for the result')
	parser.add_argument('-o', '--output', metavar='output/dir/for/file', nargs=1, default="out", type=str,
	                   help='output file name for the result')
	parser.add_argument('-t', '--timeout', metavar='T', nargs=1, default=5, type=int,
	                   help='maximum time (in seconds) allowed to search for optimum')
	parser.add_argument('-k', '--key', metavar='A~G+-?', nargs=1, default="",
	                   help='key in which the score should be harmonized, if not specified, parser will autodetect it')
	parser.add_argument('-m', '--mode', metavar='major|minor', nargs=1, default="", choices=['major', 'minor'],
	                   help='mode of the scale, if not specified, parser will autodetect it')
	parser.add_argument('-M', '--melodious', action='store_true', default=False,
	                   help='turns on melodic preferences in ASP for a more melodic result')
	parser.add_argument('-6', '--sixthslink', action='store_true', default=False,
	                   help='turns on sixth-four chord linking in ASP for a more natural result (very heavy)')
	parser.add_argument('-O', '--max_optimums', metavar='O', nargs=1, default=10, type=int,
	                   help='max number of optimum solutions to display in score completion, by default it\'s 10')
	parser.add_argument('-c', '--config', metavar='config_file_name.lp', nargs=1, default="",
						help='reads preference order and weights for parameters from the desired *.lp file stored in /pref folder')

	args = parser.parse_args()

	infile = args.xml_score

	n = args.num_sols
	if args.num_sols != 0:
		n = args.num_sols[0]

	opt_all = ""
	if n == 0:
		opt_all = "--opt-all"
	mode = args.mode
	if args.mode != "":
		mode = args.mode[0]

	span = args.span
	if args.span != 1:
		span = args.span[0]

	fmt = args.format
	if args.format != "xml":
		fmt = args.format[0]

	if args.output != "out":
		final_out = args.output[0]

	timeout = args.timeout
	if args.timeout != 5:
		timeout = args.timeout[0]

	key = args.key
	if args.key != "":
		key = args.key[0]

	melodious = ""
	if args.melodious:
		melodious = "asp/preferences/melodious.lp"

	sixthslink = ""
	if args.sixthslink:
		sixthslink = "asp/preferences/sixths_link.lp"

	max_optimums = args.max_optimums
	if args.max_optimums != 10:
		max_optimums = args.max_optimums[0]

	config = args.config
	if args.config:
		config = args.config[0]

	asp_outfile_name = re.search('/(.*?)\.xml', infile)
	outname = asp_outfile_name.group(1)
	if args.output == "out":
		final_out = "./out/" + outname + "." + fmt
	lp_outname = outname + ".lp"
	xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname, "-s", str(span), "-k", str(key), "-m", str(mode))
	xml_parser_ret = subprocess.call(xml_parser_args)
	
	score_config = ConfigParser.ConfigParser()
	score_config.read('./tmp/score_meta.cfg')

	title = score_config.get('meta', 'title')
	composer = score_config.get('meta', 'composer')
	subdivision = score_config.get('scoredata', 'base_note')
	key = score_config.get('scoredata', 'key_name')
	key_value = score_config.get('scoredata', 'key_value')
	mode = score_config.get('scoredata', 'mode')
	last_voice = int(score_config.get('scoredata', 'last_voice'))
	freebeat = int(score_config.get('scoredata', 'freebeat'))

	base = key_to_base(key)

	extra_voices = ""
	if args.voices != "":
		f = open('./tmp/extra_voices.lp', 'w')
		extra_voices = "tmp/extra_voices.lp"
		i = 1
		for v in args.voices:
			f.write("voice(" + str(last_voice+i) +").\n")
			name = re.search("([a-zA-Z\_\-]+)", v)
			vrange = re.findall("([0-9]+)", v)
			if name != None:
				f.write("voice_type("+ str(last_voice+i) + ", " + name.group(0) +").\n")
			elif name == None:
				f.write("voice_type("+ str(last_voice+i) + ", piano).\n")
			elif len(vrange) == 2:
				vrange = sorted(vrange)
				if (vrange[0] != "0"):
					f.write("voice_limit_low("+ str(last_voice+i) + ", " + vrange[0] +").\n")
				if (vrange[1] != "0"):
					f.write("voice_limit_high("+ str(last_voice+i) + ", " + vrange[1] +").\n")
			else:
				print "Voice limit for voice "+str(last_voice+1)+" has not been properly specified, please refer to usage.\n"
			i += 1
		f.close()

	if xml_parser_ret != 0:
		sys.exit("Parsing error, stopping execution.")

	asp_chord_args = ("clingo", config, "asp/assign_chords.lp", "asp/include/" + mode + "_mode.lp", "asp/include/" + mode + "_chords.lp",
		"asp/include/chord_conversions.lp", "asp/include/measures.lp", "asp/include/voice_types.lp", extra_voices,
		"asp/generated_logic_music/" + lp_outname,"-n", str(n), 
		"--const", "span=" + str(span), "--const", "base="+ str(base), 
		"--const", "subdiv="+subdivision, opt_all)

	asp_proc = subprocess.Popen(asp_chord_args, stdout=subprocess.PIPE)
    
	asp_chord_out = asp_proc.stdout.read()

	if (re.search("UNSATISFIABLE",asp_chord_out) != None):
		sys.exit("UNSATISFIABLE, stopping execution.")

	chords = ClaspChords(asp_chord_out)
	print chords
	
	sol_num = len(chords.chord_solutions)
	selected_solution = raw_input('Select a chord solution to complete the score (1..' + str(sol_num) +') [' + str(sol_num) + ']: ')
	if selected_solution == '':
		selected_solution = sol_num
	print chords.chord_solutions[int(selected_solution)-1]

	assig_chords = open("tmp/assigned_chords.lp", "w")
	assig_chords.write(HaspMusic.asp_clean_chords(chords.chord_solutions[int(selected_solution)-1].raw_ans))
	assig_chords.close()

	asp_note_args = ("clingo", config, sixthslink, melodious, "asp/complete_score.lp", "asp/include/" + mode + "_mode.lp", "asp/include/" + mode + "_chords.lp",
		"asp/include/conversions.lp", "asp/include/measures.lp", "asp/include/voice_types.lp", "tmp/assigned_chords.lp", extra_voices,
		"asp/generated_logic_music/" + lp_outname,"-n", str(n), 
		"--const", "span=" + str(span), "--const", "base="+ str(base), 
		"--const", "subdiv="+subdivision, opt_all)

	asp_proc = subprocess.Popen(asp_note_args, stdout=subprocess.PIPE)
	if (args.voices != "" or freebeat == 1):
		t = threading.Timer( timeout, clasp_timeout, [asp_proc] )
		t.start()
		t.join()
		t.cancel()

	asp_note_out = asp_proc.stdout.read()

	if (re.search("UNSATISFIABLE",asp_note_out) != None):
		sys.exit("UNSATISFIABLE, stopping execution.")

	res = ClaspResult(asp_note_out,max_optimums)
	print res

	sol_num = len(res.solutions)
	if sol_num > 0:
		if (args.voices != "" or freebeat == 1):
			selected_solution = raw_input('Select a solution to output (1..' + str(sol_num) +') [' + str(sol_num) + ']: ')
			if selected_solution == '':
				selected_solution = sol_num
			print res.solutions[int(selected_solution)-1]
		else:
			selected_solution = sol_num

		output = Out.solution_to_music21(res.solutions[int(selected_solution)-1], int(subdivision), span, base, int(key_value), mode, title, composer)
		if args.show:
			output.show(fmt)
		else:
			print "Writing output file to", final_out
			output.write(fp=final_out, fmt=fmt)
	else:
		print "Timeout was to short or something went wrong, no solutions were found.\n"

if __name__ == "__main__":
    main()