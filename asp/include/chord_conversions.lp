octave(V,((N - base) / 12),T) :- note(V,N,T), N >= 0.
sem_tones(V,((N - base) \ 12),T) :- note(V,N,T), N >= 0.

newvoicenote(V,N,B) :- newvoicefigure(V,N,D,FB), beat(B), B >= FB, B < FB+D.
ex_octave(V,((N - base) / 12),T) :- newvoicenote(V,N,T), N >= 0.
ex_sem_tones(V,((N - base) \ 12),T) :- newvoicenote(V,N,T), N >= 0.

out_grade(V,G,O,T) :- ex_grade(V,G,T), ex_octave(V,O,T).
out_grade(V,G,O,T) :- grade(V,G,T), octave(V,O,T).

ex_note(V,((O*12)+base+S),T) :- ex_sem_tones(V,S,T), ex_octave(V,O,T).
out_note(V,N,T) :- note(V,N,T).
out_note(V,N,T) :- ex_note(V,N,T).