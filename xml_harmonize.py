import argparse
import subprocess
import re
import sys
import os
sys.path.append('./out_module') 
import Out

class Note:
	"""Class that stores information about a note in the score"""
	def __init__(self, value, time):
		self.value = value
		self.time = time

	def __str__(self):
		return str(self.value)

class Rest:
	"""Class that stores information about a rest in the score"""
	def __init__(self, time):
		self.time = time
	def __str__(self):
		return "R"

class Chord:
	"""Class that stores information about a chord in the score"""
	def __init__(self, time, name):
		self.name = name
		self.time = time

	def __str__(self):
		return self.name

class Error:
	"""Class that stores information about an error in the score"""
	def __init__(self, voice, grade, time):
		self.voice = voice
		self.grade = grade
		self.time = time

	def __str__(self):
		return "Voice: " + str(self.voice) + ", Grade: " + str(self.grade) + ", " + str(self.time)

class HaspSolution:
	"""Class that stores information of a single solution of the harmony
	deducing module"""
	def __init__(self, chords, voices, errors, optimization):
		self.chords = chords
		self.errors = errors
		self.voices = voices
		self.optimization = optimization

	def __str__(self):
		ret = "Chords: ["
		first = True
		for ch in self.chords:
			if first:
				first = False
				ret += str(ch)
			else:
				ret +=", " + str(ch)
		ret += "]\n"
		if len(self.errors) > 0:
			ret += "Errors: "
			first = True
			for er in self.errors:
				if first:
					first = False
					ret += str(er)
				else:
					ret +=" // " + str(er)
			ret += "\n"
		for voice in self.voices.keys():
			notes = self.voices[voice]
			ret += "Voice " + str(voice) + ": ["
			first = True
			for note in notes:
				if first:
					first = False
					ret += str(note)
				else:
					ret += ", " + str(note)
			ret += "]\n"
		ret += "OPT: " + str(self.optimization)
		return ret

class ClaspResult:
	"""Class that parses and stores output of a clasp execution
	It's created with the textual output of clasp and then stores
	satisfability, optimization status and all of it's solutions
	with its optimization values"""
	def __init__(self, asp_out):
		self.raw_output = asp_out
		self.solutions = self.parse_solutions()

	def parse_solutions(self):
		out = self.raw_output
		answers = re.split('Answer:\s*[0-9]+', out)
		solutions = []
		for ans in answers:
			if len(ans) > 0:
				notes = re.findall('out_note\(([0-9]+),([0-9]+),([0-9]+)\)', ans)
				voices = {};
				for note in notes:
					if (int(note[0]) in voices.keys()):
						voices[int(note[0])].append(Note(int(note[1]),int(note[2])))
					else:
						voices.update({(int(note[0])) : [Note(int(note[1]),int(note[2]))]})
				rests = re.findall('rest\(([0-9]+),([0-9]+)\)', ans)
				for rest in rests:
					if (int(rest[0]) in voices.keys()):
						voices[int(rest[0])].append(Rest(int(rest[1])))
					else:
						voices.update({(int(rest[0])) : [Rest(int(rest[1]))]})

				voices = {k: sorted(v, key=lambda tup: tup.time) for k, v in voices.items()}

				chords = [Chord(int(ch[0]),ch[1]) for ch in sorted(re.findall('chord\(([0-9]+),([ivxmo7]+)\)', ans))]
				errors = [Error(int(er[0]),int(er[1]),int(er[2])) for er in re.findall('error\(([0-9]+),([0-9]+),([0-9]+)\)', ans)]
				str_opts = re.split("\s*", re.search('Optimization:((?:\s*[0-9]+)+)', ans).group(1))
				taw = str_opts.pop(0)
				optimums = map(int, str_opts)
				solutions += [HaspSolution(chords,voices,errors,optimums)]
		return solutions

	def __str__(self):
		ret = ""
		ansno = 1
		for sol in self.solutions:
			ret += "Answer " + str(ansno) + ":\n"
			ret += str(sol) + "\n\n"
			ansno += 1
		return ret

		
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
	parser.add_argument('-m', '--mode', metavar='major|minor', nargs=1, default="major", choices=['major', 'minor'],
	                   help='mode of the scale, major by default')
	parser.add_argument('-v', '--voices', metavar='V', nargs=1, default="0", type=int,
	                   help='number of extra voices that should be added to the score for harmonization')
	parser.add_argument('-sh', '--show', action='store_true', default=False,
						help='show result in editor instead of writing it to a file in the desired format')
	parser.add_argument('-f', '--format', metavar='xml|pdf|midi|ly', nargs=1, default="xml", type=str,
	                   help='output file format for the result')
	parser.add_argument('-o', '--output', metavar='output/dir/for/file', nargs=1, default="out", type=str,
	                   help='output file format for the result')
	parser.add_argument('-t', '--timeout', metavar='T', nargs=1, default=5, type=int,
	                   help='maximum time allowed to search for optimum')

	args = parser.parse_args()

	infile = args.xml_score

	n = args.num_sols
	if args.num_sols != 0:
		n = args.num_sols[0]

	opt_all = ""
	if n == 0:
		opt_all = "--opt-all"

	mode = args.mode
	if args.mode != "major":
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

	print "SHOW: ", args.show

	asp_outfile_name = re.search('/(.*?)\.xml', infile)
	outname = asp_outfile_name.group(1)
	if args.output == "out":
		final_out = outname + "." + fmt
	lp_outname = outname + ".lp"
	xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname, "-s", str(sub))
	xml_parser_ret = subprocess.call(xml_parser_args)
	
	if xml_parser_ret <= 0:
		sys.exit("Parsing error, stopping execution.")

	asp_args = ("clingo", "asp/assign_chords.lp", "asp/include/" + mode + "_mode.lp", "asp/include/" + mode + "_chords.lp",
		"asp/include/conversions.lp", "asp/generated_logic_music/" + lp_outname, "-n", str(n), "--const", "span=" + str(span), 
		"--const", "extra_voices="+ str(voices), opt_all)

	asp_proc = subprocess.Popen(asp_args, stdout=subprocess.PIPE)
	asp_out = asp_proc.stdout.read()

	res = ClaspResult(asp_out)
	print res

	sol_num = len(res.solutions)
	selected_solution = raw_input('Select a solution to output [1..' + str(sol_num) + ']: ')
	print res.solutions[int(selected_solution)-1]
	
	output = Out.solution_to_music21(res.solutions[int(selected_solution)-1], xml_parser_ret)
	if args.show:
		output.show(fmt)
	else:
		print "Writing output file to", final_out
		output.write(fp=final_out, fmt=fmt)

if __name__ == "__main__":
    main()