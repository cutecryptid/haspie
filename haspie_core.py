import clingo
import sys
import re
import argparse
import subprocess
import configparser
sys.path.append('./lib')
from HaspMusic import ClaspResult
from HaspMusic import ClaspChords
import HaspMusic
import Out

def key_to_base(key):
	base = 21
	split_key = re.search("([A-G])([\+\-])?", key)
	bases = [("C",21),("D",23),("E",25),("F",26),("G",28),("A",30),("B",32)]
	if split_key == None:
		raise ValueError("Key should be in the form [A-G][+-]?")
	groups = len(split_key.groups())
	if (groups > 0) or (groups <= 2):
		fund = split_key.group(0)
		base = [p[1] for p in bases if p[0] == key][0]
		if groups == 2:
			if split_key.group(1) == "+":
				mod = 1
			elif split_key.group(1) == "-":
				mod = -1
			else:
				mod = 0
	else:
		raise ValueError("Key should be in the form [A-G][+-]?")
	return (base + mod)

def onmodel(m):
    print(m)

def main():
    # OUTLINE:
    parser = argparse.ArgumentParser(description='haspie - Harmonizing music with ASP')
    parser.add_argument('xml_score', metavar='XML_SCORE',
                       help='input musicXML score for armonizing')
    parser.add_argument('-s', '--span', metavar='S', nargs=1, default=1, type=int,
                       help='horizontal span to consider while harmonizing, this takes in account subdivision, by default 1')
    parser.add_argument('-o', '--output', metavar='output/dir/for/file', nargs=1, default="out", type=str,
                       help='output file name for the result')

    args = parser.parse_args()

    infile = args.xml_score

    span = args.span
    if args.span != 1:
    	span = args.span[0]

    if args.output != "out":
    	final_out = args.output[0]

    score_config = configparser.ConfigParser()
    score_config.read('./tmp/score_meta.cfg')

    title = score_config.get('meta', 'title')
    composer = score_config.get('meta', 'composer')
    subdivision = score_config.get('scoredata', 'base_note')
    key = score_config.get('scoredata', 'key_name')
    key_value = score_config.get('scoredata', 'key_value')
    mode = score_config.get('scoredata', 'mode')
    last_voice = int(score_config.get('scoredata', 'last_voice'))

    base = key_to_base(key)

    asp_outfile_name = re.search('/(.*?)\.xml', infile)
    outname = asp_outfile_name.group(1)

    if args.output == "out":
    	final_out = "./out/" + outname + ".xml"
    lp_outname = outname + ".lp"

    # 1) Call Parser
    xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname, "-s", str(span), "-k", str(key), "-m", str(mode))
    xml_parser_ret = subprocess.call(xml_parser_args)

    # 2) Call Clingo for chord selection
    clingo_args = [
        "-c", "span=" + str(span),
        "-c", "base=" + str(base),
        "-c", "subdiv=" + str(subdivision),
        ]
    chords_clingo = clingo.Control(clingo_args)

    chords_clingo.load( "asp/assign_chords.lp" )
    chords_clingo.load( "asp/include/" + mode + "_mode.lp" )
    chords_clingo.load( "asp/include/" + mode + "_chords.lp" )
    chords_clingo.load( "asp/include/chord_conversions.lp" )
    chords_clingo.load( "asp/include/measures.lp" )
    chords_clingo.load( "asp/include/voice_types.lp" )
    chords_clingo.load( "asp/generated_logic_music/" + lp_outname )

    chords_clingo.ground([("base", [])])

    # 3) Print results / Annotate chords
    chords_clingo.solve(on_model=onmodel)

if __name__ == "__main__":
    main()
