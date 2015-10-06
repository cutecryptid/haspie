suspect(harry;sally).

innocent(Suspect) :- motive(Suspect), not guilty(Suspect).

motive(sally).
motive(harry).
guilty(harry).