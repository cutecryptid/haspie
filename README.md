# haspie-haspist
Tool for harmonizing musical pieces based in Answer Set Programming

**DISCLAIMER: Haspie Haspist's name is a pun and a working title, should not be taken as final but who knows.**
At the moment is only working in Linux based OS, but due to the flexibility of Python and if I can get some things to work in windows, there will be a Windows release as well.

# What is this?

The current project is its author's Computer Science Final Degree Project and tries to achieve automatic harmonization of melodic pieces throught the use of [Answer Set Programming](http://potassco.sourceforge.net/). It consists of two stages: Parsing and Magic. Parsing transforms a melodic musical piece in MusicXML to logic facts *a la prolog* while Magic uses several harmony rules and the previously given facts to deduce the piece's harmony and be able to write scores for other voices following it or detect mistakes and irregularities in the current melody. Due to time and complexity restrictions it won't cover complex aspects of composition nor harmonization. No modulation, just plain and simple harmonization.

# Requisites
Python 2.7, gringo 3.0.5 and clingo 3.0.5, music21 >= 2.1.2 python module installed and present in the system's PATH. 

# Compiling from source
The only compiled part of the project is the MXML to ASP facts parser. A binary is bundled with every release, but if you wish to compile it for compatibility reasons, a Makefile is also bundled. Go to ```parser/source``` and run ```make```. The bin file is generated in the parser folder so it can be properly referenced by the python pipeline.

#TO DO:
Currently working on Prototype mkIV.
- Functional output module (not styling yet, just output solution to MusicXML, LilyPond or MIDI)
- Adjust and refine new notes generation (fifth jumps)
- Include 7th chords (4 notes)
- Identify and restrict weak/strong times and bridge notes (LOW PRIO, maybe mkV)
