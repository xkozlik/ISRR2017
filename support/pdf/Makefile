

PDF=$(wildcard *.pdf)
#CONVERT=epstopdf

all:  
	echo Done

#%.pdf: 
#	$(CONVERT) $(basename $@).eps -o=$@
	
clean:
	echo done

copy: all
#	cp *.eps ../../fig	
#	cp *.pdf ../../fig	
	@for i in $(PDF) ; do ln -s -f ../support/pdf/$$i ../../fig; done
