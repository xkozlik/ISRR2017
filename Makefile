LATEX	= latex
LATEXPDF = pdflatex
BIBTEX	= bibtex
DVI2PS	= dvips
COMPRESS = gzip

DOCARC_CMD=$(HOME)/programy/docarc/docarc-client-1.0.2/docarc
DOCARC_BPPATH=$(HOME)/programy/docarc/docarc-client-1.0.2/bp

SUPPORTDIR = support

NAME = paper
DVINAME	= paper
TARGET = all

$(NAME): pdf

ps:  dvi bib
	$(DVI2PS) $(DVINAME) -o $(NAME).ps

dvi:	pic bib
	$(LATEX) $(NAME)

pdf:	pic bib
	$(LATEXPDF) $(NAME)


$(NAME).aux:
	$(LATEX)  $(NAME)

bib:	$(NAME).aux
	$(BIBTEX) $(NAME)

all:   ps pdf

pic:fig/.done	
	touch fig/.done

fig/.done:
	$(MAKE) -C $(SUPPORTDIR)/ copy

docarc:
	$(DOCARC_CMD) -b $(DOCARC_BPPATH) fetch $(NAME)

clean:
	rm -f *~ *# *.log *.aux *.toc *.dvi *.gz core *.ps *.pdf
	rm -rf fig/.done fig/*.png fig/*.eps fig/*.pdf *.bbl *.blg 

cleanall: clean
	$(MAKE) -C $(SUPPORTDIR)/ clean
	rm -rf *.snm *.out *.nav
