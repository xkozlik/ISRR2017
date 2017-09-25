

FIG=$(wildcard *.fig)
EPS=$(patsubst %.fig,%.eps,$(wildcard *.fig))
PDF=$(patsubst %.fig,%.pdf,$(wildcard *.fig))
CZECHFILE="cestina.txt"
FIGURECMD=fig2dev
EPS2PDF=epstopdf
CPCXFIG=cpcxfig

all: $(EPS) $(PDF) 

%.eps: %.fig
	$(FIGURECMD) -L eps $(basename $@).fig $@
	#$(CPCXFIG) $(CZECHFILE) $@
	
%.pdf: %.eps	
	$(EPS2PDF) $<

clean:
	rm -rf $(EPS) $(PDF)
copy: all
#	cp *.eps ../../fig	
#	cp *.pdf ../../fig	
	@for i in $(PDF) $(EPS) ; do ln -s -f ../support/fig/$$i ../../fig; done

