import argparse
import subprocess
import re

parser = argparse.ArgumentParser(description='Harmonizing music with ASP')
parser.add_argument('xml_score', metavar='XML_SCORE',
                   help='input musicXML score for armonizing')
parser.add_argument('-n', metavar='N', nargs=1, default=1, type=int,
                   help='max number of ASP solutions')

args = parser.parse_args()

infile = args.xml_score
n = args.n[0]
asp_outfile_name = re.search('/(.*?)\.xml', infile)
outname = asp_outfile_name.group(1)
lp_outname = outname + ".lp"
xml_parser_args = ("parser/mxml_asp", infile, "-o", "asp/generated_logic_music/" + lp_outname)
xml_parser = subprocess.call(xml_parser_args)

# TODO install clingo wrapper, by now we'll be using calls
asp_args = ("clingo", "asp/assign_chords_black.lp", "asp/generated_logic_music/" + lp_outname, "-n", str(n))
asp = subprocess.call(asp_args)