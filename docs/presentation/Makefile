MAIN_FILE=root
COVER_FILE=cover.tex
FILES=introduction.tex contextualization.tex design.tex implementation.tex conclusions.tex
AUX_FILES=abstract.tex dedication.tex director-agreement.tex gratefulnesses.tex keywords.tex 
BIB_FILE=bibliography.bib
GLOSSARY_FILES=acronym-glossary.tex appendix.tex term-glossary.tex
OUTPUT_FILE=fcp_memo

all: pdf clean

pdf: $(MAIN_FILE).tex $(COVER_FILE) $(FILES) $(AUX_FILES) $(BIB_FILE) $(GLOSSARY_FILES)
	pdflatex $(MAIN_FILE).tex
	bibtex $(MAIN_FILE)
	pdflatex $(MAIN_FILE).tex
	pdflatex $(MAIN_FILE).tex
	mv $(MAIN_FILE).pdf $(OUTPUT_FILE).pdf

orto:
	ispell -T latin1 -d spanish *.tex

clean:
	rm -f *.aux *.lof *.log *.lot *.mtc* *.toc *.log *~ \
		*.bbl *.blg *.bmt *.bak *.maf

mrproper: clean
	rm -f $(OUTPUT_FILE).pdf
