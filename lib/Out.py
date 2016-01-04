from music21 import *
import re
us = environment.UserSettings()

def rom_to_int(input):
	if type(input) != type(""):
		raise TypeError, "expected string, got %s" % type(input)
	input = input.upper()
	nums = ['M', 'D', 'C', 'L', 'X', 'V', 'I']
	ints = [1000, 500, 100, 50,  10,  5,   1]
	places = []
	for c in input:
		if not c in nums:
			raise ValueError, "input is not a valid roman numeral: %s" % input
	for i in range(len(input)):
		c = input[i]
		value = ints[nums.index(c)]
		try:
			nextvalue = ints[nums.index(input[i +1])]
			if nextvalue > value:
				value *= -1
		except IndexError:
			pass
		places.append(value)
	sum = 0
	for n in places: sum += n
	return sum

def romanToChord(roman, base, mode):
	av_chords = ["A","B-","B","C","D-","D","E-","E","F","G-","G","A-"]
	major_semitone_grades = [3,5,7,8,10,0,2]
	minor_semitone_grades = [3,5,6,8,10,11,1]
	chord = re.findall('([iv]+)([o7m])?', roman)
	rootval = rom_to_int(chord[0][0])
	if mode == "maj":
		root_semitones = major_semitone_grades[rootval-1]
	else:
		root_semitones = minor_semitone_grades[rootval-1]
	out_chord = av_chords[(root_semitones + (base-21))%12]
	if chord[0][1] != None:
		out_chord += chord[0][1]
	return out_chord
	

def solution_to_music21(solution, subdivision, span, base, key_value, mode, title, composer):
	score = stream.Score()
	i = 0
	k = key.KeySignature(key_value)
	for v in solution.voices.items():
		p = stream.Part()
		p.append(k)
		for vt in solution.voicetypes:
			if v[0] == vt.voice:
				inst_name = vt.name
			else:
				inst_name = "piano"
		inst = instrument.fromString(inst_name)
		p.append(inst)
		for item in v[1]:
			c = next((c for c in solution.chords if ((c.time-1)*span) == (item.time-1)), None)
			if c != None and i == 0:
				p.append(harmony.ChordSymbol(romanToChord(c.name, base, mode)))
			if item.type == "rest":
				subdivision/4
				tmp_note = note.Rest(quarterLength=(float(item.duration)/(float(subdivision)/float(4))))
			elif item.type == "measure":
				str_meas = str(item.ncount) + "/" + str(item.ntype)
				tmp_note =  meter.TimeSignature(str_meas)
			elif item.type == "vchord":
				tmp_chord = []
				for n in item.notes:
					tmp_n = note.Note(n.value, quarterLength=(float(n.duration)/(float(subdivision)/float(4))))
					tmp_n.pitch.accidental = None
					tmp_chord += [tmp_n]
				tmp_note = chord.Chord(tmp_chord)
			else:
				tmp_note = note.Note(item.value, quarterLength=(float(item.duration)/(float(subdivision)/float(4))))
				tmp_note.pitch.accidental = None
			if any((e.time == item.time) and (e.voice-1 == i)  for e in solution.errors):
			 	tmp_note.color = "#ff0000"
			if any((p.time == item.time) and (p.voice-1 == i)  for p in solution.passing):
				tmp_note.color = "#0000ff"
			p.append(tmp_note)
		score.append(p)
		i+= 1
	score.insert(metadata.Metadata())
	score.metadata.title = title
	score.metadata.composer = composer
	return score