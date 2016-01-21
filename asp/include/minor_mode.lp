scale_grade(1..7).
non_scale_grade(8;10;11;13;14).

% translate semitone value to chord (minor mode)
grade(V,1,T) :- sem_tones(V,3,T).
grade(V,2,T) :- sem_tones(V,5,T).
grade(V,3,T) :- sem_tones(V,6,T).
grade(V,4,T) :- sem_tones(V,8,T).
grade(V,5,T) :- sem_tones(V,10,T).
grade(V,6,T) :- sem_tones(V,11,T).
grade(V,7,T) :- sem_tones(V,1,T).

% fictional grades out of the scale
grade(V,8,T) :- sem_tones(V,4,T). % I sharp, II flat
grade(V,10,T) :- sem_tones(V,7,T). % III sharp, IV flat
grade(V,11,T) :- sem_tones(V,9,T). % IV sharp, V flat
grade(V,13,T) :- sem_tones(V,0,T). % VI sharp, VII flat
grade(V,14,T) :- sem_tones(V,2,T). % VII sharp, I flat

% translate semitone value to chord (minor mode)
ex_grade(V,1,T) :- ex_sem_tones(V,3,T).
ex_grade(V,2,T) :- ex_sem_tones(V,5,T).
ex_grade(V,3,T) :- ex_sem_tones(V,6,T).
ex_grade(V,4,T) :- ex_sem_tones(V,8,T).
ex_grade(V,5,T) :- ex_sem_tones(V,10,T).
ex_grade(V,6,T) :- ex_sem_tones(V,11,T).
ex_grade(V,7,T) :- ex_sem_tones(V,1,T).

% fictional grades out of the scale
ex_grade(V,8,T) :- ex_sem_tones(V,4,T). % I sharp, II flat
ex_grade(V,10,T) :- ex_sem_tones(V,7,T). % III sharp, IV flat
ex_grade(V,11,T) :- ex_sem_tones(V,9,T). % IV sharp, V flat
ex_grade(V,13,T) :- ex_sem_tones(V,0,T). % VI sharp, VII flat
ex_grade(V,14,T) :- ex_sem_tones(V,2,T). % VII sharp, I flat
