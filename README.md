# haspie
Tool for harmonizing musical pieces based in Answer Set Programming

# What is this?
This was my Computer Science Graduation Project and tries to achieve automatic harmonization of music pieces through the use of [Answer Set Programming](http://potassco.sourceforge.net/). It consists of two stages: Parsing and Magic. Parsing transforms a melodic musical piece in MusicXML to logic facts *a la prolog* while Magic uses several harmony rules and the previously given facts to deduce the piece's harmony and be able to write scores for other voices following it or detect mistakes and irregularities in the current melody. Due to time and complexity restrictions it won't cover complex aspects of composition nor harmonization. No modulation, just plain and simple harmonization.

This project was rated with a 10/10 and awarded with an Honor Mention on February 18th 2016.

# System Requirements
Python 2.7, gringo 3.0.5 and clingo 3.0.5, music21 >= 2.1.2 python module installed and present in the system's PATH. In addition you can install a variety of programs for music21 output such as score viewers, midi players etc. If you install them BEFORE the music21 module installation they should be automatically linked. If not, you can edit the .music21rc file in your user's home folder with the routes to each default program for music21 to use.

# Compiling from source
The only compiled part of the project is the MXML to ASP facts parser. A binary is bundled with every release, but if you wish to compile it for compatibility reasons, a Makefile is also bundled. Go to ```parser/source``` and run ```make```. The bin file is generated in the parser folder so it can be properly referenced by the python pipeline.

