from music21 import *
us = environment.UserSettings()

def solution_to_music21(solution, subdivision):
	parts = []
	for v in solution.voices.items():
		p = stream.Part()	
		[p.insert(n[1]-1,note.Note(n[0])) for n in v[1]]
		parts += [p]
	score = stream.Score(parts)
	return score

