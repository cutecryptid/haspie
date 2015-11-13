from music21 import *
us = environment.UserSettings()

def solution_to_music21(solution, subdivision):
	parts = []
	for v in solution.voices.items():
		p = stream.Part()	
		for item in v[1]:
			if str(item) == "R":
				p.insert(item.time-1,note.Rest())
			else:
				p.insert(item.time-1,note.Note(item.value))
		parts += [p]
	score = stream.Score(parts)
	for e in solution.errors:
		score.parts[e.voice-1].notes[e.time-1].color = "#ff0000"
	return score