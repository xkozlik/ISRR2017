

EPS=$(wildcard *.eps)
PDF=$(patsubst %.eps,%.pdf,$(wildcard *.eps))
CONVERT=epstopdf

all: $(EPS) $(PDF) 

%.pdf: %.eps
	$(CONVERT) $(basename $@).eps -o=$@
	
clean:
	rm -rf $(PDF) 

copy: all
#	cp *.eps ../../fig	
#	cp *.pdf ../../fig	
	@for i in $(PDF) $(EPS) ; do ln -s -f ../support/eps/$$i ../../fig; done
