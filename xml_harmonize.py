import argparse
import subprocess
import re
import sys
import os
import threading
import errno
sys.path.append('./lib') 
from HaspMusic import ClaspResult
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
	parser = argparse.ArgumentParser(description='Harmonizing music with ASP')
	parser.add_argument('xml_score', metavar='XML_SCORE',
	                   help='input musicXML score for armonizing')
	parser.add_argument('-n', '--num_sols', metavar='N', nargs=1, default=0, type=int,
	                   help='max number of ASP solutions, by default all of them')
	parser.add_argument('-s', '--span', metavar='S', nargs=1, default=1, type=int,
	                   help='horizontal span to consider while harmonizing, by default 1')
	parser.add_argument('-d', '--divide', metavar='32|16|8|4|2|1', nargs=1, default=0, type=int,
	                   help='forces subdivision of the notes in the score to a specific value, by default it\'s automatically calculated')
	parser.add_argument('-v', '--voices', metavar='V', nargs=1, default="0", type=int,
	                   help='number of extra voices that should be added to the score for harmonization')
	parser.add_argument('-S', '--show', action='store_true', default=False,
						help='show result in editor instead of writing it to a file in the desired format')
	parser.add_argument('-f', '--format', metavar='xml|pdf|midi|ly', nargs=1, default="xml", type=str,
	                   help='output file format for the result')
	parser.add_argument('-o', '--output', metavar='output/dir/for/file', nargs=1, default="out", type=str,
	                   help='output file format for the result')
	parser.add_argument('-t', '--timeout', metavar='T', nargs=1, default=5, type=int,
	                   help='maximum time (in seconds) allowed to search for optimum')
	parser.add_argument('-k', '--key', metavar='[A-G][+-]?', nargs=1, default="C",
	                   help='key in which the score should be harmonized, default is C, flats and sharps can be specified by -/+ (i.e. C+,A-,...)')
	parser.add_argument('-m', '--mode', metavar='maj|min', nargs=1, default="maj", choices=['major', 'minor'],
	                   help='mode of the scale, major by default')
	parser.add_argument('-M', '--melodious', action='store_true', default=False,
	                   help='turns on melodic preferences in ASP for a more melodic result')
	parser.add_argument('-A', '--aspdebug', action='store_true', default=False,
	                   help='option for not interpreting results, just print ASP out')
	parser.add_argument('-P', '--onlyparse', action='store_true', default=False,
	                   help='option for not ASPing, just parse')

	args = parser.parse_args()

	infile = args.xml_score

	n = args.num_sols
	if args.num_sols != 0:
		n = args.num_sols[0]

	opt_all = ""
	if n == 0:
		opt_all = "--opt-all"
	mode = args.mode
	if args.mode != "maj":
		mode = args.mode[0]

	sub = args.divide
	if args.divide != 0:
		sub = args.divide[0]

	span = args.span
	if args.span != 1:
		span = args.span[0]

	voices = args.voices
	if args.voices != 0:
		voices = args.voices[0]

	fmt = args.format
	if args.format != "xml":
		fmt = args.format[0]

	if args.output != "out":
		final_out = args.output[0]

	timeout = args.timeout
	if args.timeout != 5:
		timeout = args.timeout[0]

	key = args.key
	if args.key != "C":
		key = args.key[0]

	base = key_to_base(key)

	melodious = ""
	if args.melodious:
		melodious = "asp/preferences/melodious.lp"

	asp_outfile_name = re.search('/(.*?)\.xml', infile)
	outname = asp_outfile_name.group(1)
	if args.output == "out":
		final_out = outname + "." + fmt
	lp_outname = outname + ".lp"
	xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname, "-s", str(sub))
	xml_parser_ret = subprocess.call(xml_parser_args)
	
	if xml_parser_ret <= 0:
		sys.exit("Parsing error, stopping execution.")

	if args.onlyparse:
		sys.exit("")

	verbose = ""
	if args.aspdebug:
		verbose = "-V"

	asp_args = ("clingo", "asp/assign_chords.lp", "asp/include/" + mode + "or_mode.lp", "asp/include/" + mode + "or_chords.lp",
		"asp/include/conversions.lp", "asp/include/measures.lp", "asp/include/voice_types.lp", 
		"asp/generated_logic_music/" + lp_outname,"-n", str(n), 
		"--const", "span=" + str(span), "--const","extra_voices="+ str(voices), "--const", "base="+ str(base), 
		"--const", "subdiv="+str(xml_parser_ret), opt_all, melodious, verbose)

	if args.aspdebug:
		asp_proc = subprocess.call(asp_args)
	else:
		asp_proc = subprocess.Popen(asp_args, stdout=subprocess.PIPE)

		t = threading.Timer( timeout, clasp_timeout, [asp_proc] )
		t.start()
		t.join()
		t.cancel()
	    
		asp_out = asp_proc.stdout.read()

		if (re.search("UNSATISFIABLE",asp_out) != None):
			sys.exit("UNSATISFIABLE, stopping execution.")

		res = ClaspResult(asp_out)
		print res

		sol_num = len(res.solutions)
		selected_solution = raw_input('Select a solution to output (1..' + str(sol_num) +') [' + str(sol_num) + ']: ')
		if selected_solution == '':
			selected_solution = sol_num
		print res.solutions[int(selected_solution)-1]
		
		output = Out.solution_to_music21(res.solutions[int(selected_solution)-1], xml_parser_ret, span, base, mode)
		if args.show:
			output.show(fmt)
		else:
			print "Writing output file to", final_out
			output.write(fp=final_out, fmt=fmt)

if __name__ == "__main__":
    main()