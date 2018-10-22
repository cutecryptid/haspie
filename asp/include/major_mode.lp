scale_grade(1..7).
non_scale_grade(8;9;11;12;13).

% translate semitone value to grade (major mode)
grade(V,1,T) :- sem_tones(V,3,T).
grade(V,2,T) :- sem_tones(V,5,T).
grade(V,3,T) :- sem_tones(V,7,T).
grade(V,4,T) :- sem_tones(V,8,T).
grade(V,5,T) :- sem_tones(V,10,T).
grade(V,6,T) :- sem_tones(V,0,T).
grade(V,7,T) :- sem_tones(V,2,T).

ex_grade(V,1,T) :- ex_sem_tones(V,3,T).
ex_grade(V,2,T) :- ex_sem_tones(V,5,T).
ex_grade(V,3,T) :- ex_sem_tones(V,7,T).
ex_grade(V,4,T) :- ex_sem_tones(V,8,T).
ex_grade(V,5,T) :- ex_sem_tones(V,10,T).
ex_grade(V,6,T) :- ex_sem_tones(V,0,T).
ex_grade(V,7,T) :- ex_sem_tones(V,2,T).

% fictional grades out of the scale
grade(V,8,T) :- sem_tones(V,4,T). % I sharp, II flat
grade(V,9,T) :- sem_tones(V,6,T). % II sharp, III flat
grade(V,11,T) :- sem_tones(V,9,T). % IV sharp, V flat
grade(V,12,T) :- sem_tones(V,11,T). % V sharp, VI flat
grade(V,13,T) :- sem_tones(V,1,T). % VI sharp, VII flat

ex_grade(V,8,T) :- ex_sem_tones(V,4,T). % I sharp, II flat
ex_grade(V,9,T) :- ex_sem_tones(V,6,T). % II sharp, III flat
ex_grade(V,11,T) :- ex_sem_tones(V,9,T). % IV sharp, V flat
ex_grade(V,12,T) :- ex_sem_tones(V,11,T). % V sharp, VI flat
ex_grade(V,13,T) :- ex_sem_tones(V,1,T). % VI sharp, VII flat
