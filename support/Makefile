SUBDIRS+=fig
SUBDIRS+=pic
SUBDIRS+=eps
SUBDIRS+=pdf

generate:
	echo "generate"
	@for i in $(SUBDIRS) ;\
	do \
	echo "making all in $(CURRENT_DIR)/$$i..."; \
	$(MAKE) -C $$i all; \
	done

copy:
	echo "copy"
	@for i in $(SUBDIRS) ;\
	do \
	echo "coping all from $(CURRENT_DIR)/$$i..."; \
	$(MAKE) -C $$i copy; \
	done
	touch ../fig/.done

clean:	
	echo "clean"
	@for i in $(SUBDIRS) ;\
	do \
	echo "cleaning all in $(CURRENT_DIR)/$$i..."; \
	$(MAKE) -C $$i clean; \
	done

all: generate copy
