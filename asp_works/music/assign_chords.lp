a_chord(c;d;e;f;g;a;b).
a_note(c;d;e;f;g;a;b).
measure(1..n).

n{chord(M,AC):measure(M):a_chord(AC)}n.

%use the first note of the measure as a chord
chord(M,AC) :- note(M,1,AC).

#hide.
#show chord/2.