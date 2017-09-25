

PNG=$(wildcard *.png)
EPS=$(patsubst %.png,%.eps,$(wildcard *.png))
CONVERT=convert

all: $(EPS) $(PDF) 

%.eps: %.png
	$(CONVERT) $(basename $@).png $@
	
clean:
	rm -rf $(EPS) 

copy: all
	cp *.eps ../../fig	
	cp *.png ../../fig	
#	@for i in $(PNG) $(EPS) ; do ln -s -f ../support/pic/$$i ../../fig; done
