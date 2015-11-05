% translate semitone value to grade (major mode)
grade(V,1,T) :- sem_tones(V,3,T).
grade(V,2,T) :- sem_tones(V,5,T).
grade(V,3,T) :- sem_tones(V,7,T).
grade(V,4,T) :- sem_tones(V,8,T).
grade(V,5,T) :- sem_tones(V,10,T).
grade(V,6,T) :- sem_tones(V,0,T).
grade(V,0,T) :- sem_tones(V,2,T).

ex_sem_tones(V,3,T) :-  ex_grade(V,1,T).
ex_sem_tones(V,5,T) :- ex_grade(V,2,T).
ex_sem_tones(V,7,T) :- ex_grade(V,3,T).
ex_sem_tones(V,8,T) :- ex_grade(V,4,T).
ex_sem_tones(V,10,T) :- ex_grade(V,5,T).
ex_sem_tones(V,0,T) :- ex_grade(V,6,T).
ex_sem_tones(V,2,T) :- ex_grade(V,0,T).