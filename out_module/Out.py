from music21 import *
us = environment.UserSettings()

def solution_to_music21(solution, subdivision, span):
	score = stream.Score()
	for v in solution.voices.items():
		p = stream.Part()
		p.clef = clef.TrebleClef()
		for item in v[1]:
			if str(item) == "R":
				tmp_note = note.Rest()
			else:
				tmp_note = note.Note(item.value)
				tmp_note.pitch.accidental = None
			tmp_note.duration = duration.Duration(4/float(subdivision))
			p.append(tmp_note)
		score.append(p)
	for e in solution.errors:
		score.parts[e.voice-1].notes[e.time-1].color = "#ff0000"
	# for c in solution.chords:
	# 	print (c.time-1)*span
	# 	score.parts[0].insert((c.time-1)*span, harmony.ChordSymbol('C'))
	return score