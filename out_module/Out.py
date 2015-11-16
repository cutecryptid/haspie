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
	out_chord = av_chords[root_semitones]
	if chord[0][1] != None:
		out_chord += chord[0][1]
	return out_chord
	

def solution_to_music21(solution, subdivision, span, base, mode):
	score = stream.Score()
	i = 0
	for v in solution.voices.items():
		p = stream.Part()
		p.append(clef.TrebleClef())
		for item in v[1]:
			c = next((c for c in solution.chords if ((c.time-1)*span) == (item.time-1)), None)
			if c != None and i == 0:
				p.append(harmony.ChordSymbol(romanToChord(c.name, base, mode)))
			if str(item) == "R":
				tmp_note = note.Rest()
			else:
				tmp_note = note.Note(item.value)
				tmp_note.pitch.accidental = None
				if any((e.time == item.time) and (e.voice-1 == i)  for e in solution.errors):
					tmp_note.color = "#ff0000"
			p.append(tmp_note)
		score.append(p)
		i+= 1
	return score