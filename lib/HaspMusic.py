import re

class Note:
	"""Class that stores information about a note in the score"""
	def __init__(self, value, time):
		self.value = value
		self.time = time
		self.type = "note"
	def __str__(self):
		return str(self.value)

class PassingNote:
	"""Class that stores information about a passing note in the score"""
	def __init__(self, voice, value, time):
		self.voice = voice
		self.value = value
		self.time = time
	def __str__(self):
		return "Voice: " + str(self.voice) + ", " + str(self.time)

class Measure:
	"""Class that stores information about a measure in the score"""
	def __init__(self, ncount, ntype, time):
		self.ncount = ncount
		self.ntype = ntype
		self.time = time
		self.type = "measure"
	def __str__(self):
		return "(" + str(self.ncount) + "/" + str(self.ntype) + ")"

class Rest:
	"""Class that stores information about a rest in the score"""
	def __init__(self, time):
		self.time = time
		self.type = "rest"
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
	def __init__(self, chords, errors, passing, voices, optimization):
		self.chords = chords
		self.errors = errors
		self.passing = passing
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
		if len(self.passing) > 0:
			ret += "Passing Notes: "
			first = True
			for pn in self.passing:
				if first:
					first = False
					ret += str(pn)
				else:
					ret +=" // " + str(pn)
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
				try:
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
					measures = re.findall('real_measure\(([0-9]+),([0-9]+),([0-9]+)\)', ans)
					for measure in measures:
						for key in voices.keys():
							voices[key].append(Measure(int(measure[0]), int(measure[1]), int(measure[2])))

					voices = {k: sorted(v, key=lambda tup: tup.time) for k, v in voices.items()}

					chords = [Chord(int(ch[0]),ch[1]) for ch in sorted(re.findall('chord\(([0-9]+),([ivxmo7]+)\)', ans))]
					errors = [Error(int(er[0]),int(er[1]),int(er[2])) for er in re.findall('error_in_strong\(([0-9]+),([0-9]+),([0-9]+)\)', ans)]
					passing = [PassingNote(int(pn[0]),int(pn[1]),int(pn[2])) for pn in re.findall('passing_note\(([0-9]+),([0-9]+),([0-9]+)\)', ans)]
					str_opts = re.split("\s*", re.search('Optimization:((?:\s*[0-9]+)+)', ans).group(1))
					taw = str_opts.pop(0)
					optimums = map(int, str_opts)
					solutions += [HaspSolution(chords,errors,passing,voices,optimums)]
				except AttributeError:
					print "Discarding incomplete answer due to early temrination."
		return solutions

	def __str__(self):
		ret = ""
		ansno = 1
		for sol in self.solutions:
			ret += "Answer " + str(ansno) + ":\n"
			ret += str(sol) + "\n"
			ansno += 1
		return ret