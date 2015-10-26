import argparse
import subprocess
import re

def parse_out(asp_out):
	satis = re.search('SATISFIABLE', asp_out)
	solution = []
	if satis == None:
		print "UNSATISFIABLE"
		return solution
	solutions = re.compile("Answer:\s*[0-9]+").split(asp_out)

	for sol in solutions:
		chord = re.findall('chord\([0-9]+,[0-9]+\)', sol)
		if len(sol) > 0:
			solution += [sorted(chord)]
	return solution

def main():
	parser = argparse.ArgumentParser(description='Harmonizing music with ASP')
	parser.add_argument('xml_score', metavar='XML_SCORE',
	                   help='input musicXML score for armonizing')
	parser.add_argument('-n', metavar='N', nargs=1, default=1, type=int,
	                   help='max number of ASP solutions')
	parser.add_argument('-s', metavar='S', nargs=1, default=1, type=int,
	                   help='horizontal span to consider while harmonizing')
	parser.add_argument('-m', metavar='[major|minor]', nargs=1, default="major",
	                   help='mode')

	args = parser.parse_args()

	infile = args.xml_score

	n = args.n
	if args.n != 1:
		n = args.n[0]

	mode = args.m
	if args.m != "major":
		mode = args.m[0]

	span = args.s
	if args.s != 1:
		span = args.s[0]

	asp_outfile_name = re.search('/(.*?)\.xml', infile)
	outname = asp_outfile_name.group(1)
	lp_outname = outname + ".lp"
	xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname)
	xml_parser = subprocess.call(xml_parser_args)
	asp_args = ("clingo", "asp/assign_chords.lp", "asp/include/" + mode + "_mode.lp" ,
		"asp/generated_logic_music/" + lp_outname, "-n", str(n))
	asp_proc = subprocess.Popen(asp_args, stdout=subprocess.PIPE)
	asp_out = asp_proc.stdout.read()

	solution = parse_out(asp_out)
	if len(solution) > 0:
		print "SATISFIABLE"
		for sol in solution:
			print sol
	else:
		print "UNSATISFIABLE"


if __name__ == "__main__":
    main()