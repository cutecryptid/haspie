# haspie-haspist
Tool for harmonizing musical pieces based in Answer Set Programming

**DISCLAIMER: Haspie Haspist's name is a pun and a working title, should not be taken as final but who knows.**
At the moment is only working in Linux based OS, don't expect a Windows/Mac release. But maybe some time...

# What is this?

The current project is its author's Computer Science Final Degree Project and tries to achieve automatic harmonization of melodic pieces throught the use of [Answer Set Programming](http://potassco.sourceforge.net/). It consists of two stages: Parsing and Magic. Parsing transforms a melodic musical piece in MusicXML to logic facts *a la prolog* while Magic uses several harmony rules and the previously given facts to deduce the piece's harmony and be able to write scores for other voices following it or detect mistakes and irregularities in the current melody. Due to time and complexity restrictions it won't cover complex aspects of composition nor harmonization. No modulation, just plain and simple harmonization.

# Requisites
Python 2.7, gringo 3.0.5 and clingo 3.0.5, music21 >= 2.1.2 python module installed and present in the system's PATH. In addition you can install a variety of programs for music21 output such as score viewers, midi players etc. If you install them BEFORE the music21 module installation they should be automatically linked. If not, you can edit the .music21rc file in your user's home folder with the routes to each default program for music21 to use.

# Compiling from source
The only compiled part of the project is the MXML to ASP facts parser. A binary is bundled with every release, but if you wish to compile it for compatibility reasons, a Makefile is also bundled. Go to ```parser/source``` and run ```make```. The bin file is generated in the parser folder so it can be properly referenced by the python pipeline.

#TO DO:
 - Investigate about harmonization in other scales (is base constant enough or do we need more info?)
 - Melodic preferences stopped working
 - Decide which preferences should be included as a parameter in pipeline (single/bundled/mixed)
 - Tessiturae detection is very expensive, but it can be included while generating brand new voices
 - Optimums should be filtered to show only the really best competing options to user

