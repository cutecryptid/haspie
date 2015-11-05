% translate semitone value to chord (minor mode)
grade(V,1,T) :- sem_tones(V,3,T).
grade(V,2,T) :- sem_tones(V,5,T).
grade(V,3,T) :- sem_tones(V,6,T).
grade(V,4,T) :- sem_tones(V,8,T).
grade(V,5,T) :- sem_tones(V,10,T).
grade(V,6,T) :- sem_tones(V,11,T).
grade(V,0,T) :- sem_tones(V,1,T).

ex_sem_tones(V,3,T) :- grade(V,1,T).
ex_sem_tones(V,5,T) :- grade(V,2,T).
ex_sem_tones(V,6,T) :- grade(V,3,T).
ex_sem_tones(V,8,T) :- grade(V,4,T).
ex_sem_tones(V,10,T) :- grade(V,5,T).
ex_sem_tones(V,11,T) :- grade(V,6,T).
ex_sem_tones(V,1,T) :- grade(V,0,T).