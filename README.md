# haspie
Tool for harmonizing musical pieces based in Answer Set Programming

# Disclaimer
Currently, haspie is being deeply revised and refactored, repo might (and will) be unstable until next release.
I will be porting haspie to Python3 and Clingo5, and it will start using the official Clingo Python Module.
Other than that, as I'll be improving haspie as I conduct my PhD research, big changes will come for the tool, such as simplification in usage, the always mentioned Musescore2 plugin interface and performance increase.
The focus of my PhD is the Efficient Generation of heterogeneous solutions to optimization problems in ASP so I hope that my research also helps improving the quality and diversity of the solutions provided by haspie.
Haspie v2 will have different parallel versions from now on, each one of them taking advantage of different aspects of problem solving to achieve better times and solutions, so expect a few forks.
For now, I will be developing what I call haspie_core, which is a very simple and functional version of haspie. It will only feature chord selection for now.

# What is this?
This was my Computer Science Graduation Project and tries to achieve automatic harmonization of music pieces through the use of [Answer Set Programming](http://potassco.sourceforge.net/). It consists of two stages: Parsing and Magic. Parsing transforms a melodic musical piece in MusicXML to logic facts *a la prolog* while Magic uses several harmony rules and the previously given facts to deduce the piece's harmony and be able to write scores for other voices following it or detect mistakes and irregularities in the current melody. Due to time and complexity restrictions it won't cover complex aspects of composition nor harmonization. No modulation, just plain and simple harmonization.

This project was rated with a 10/10 and awarded with an Honor Mention on February 18th 2016.

# System Requirements
Python 3.6.6, clingo 5.3.0, music21 >= 5.3.0 and clingo python modules installed and present in the system's PATH. In addition you can install a variety of programs for music21 output such as score viewers, midi players etc. If you install them BEFORE the music21 module installation they should be automatically linked. If not, you can edit the .music21rc file in your user's home folder with the routes to each default program for music21 to use.

# Compiling from source
The only compiled part of the project is the MXML to ASP facts parser. A binary is bundled with every release, but if you wish to compile it for compatibility reasons, a Makefile is also bundled. Go to ```parser/source``` and run ```make```. The bin file is generated in the parser folder so it can be properly referenced by the python pipeline.
