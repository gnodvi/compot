#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


INP = A/jimtcl-0.79

ADD = ./0.79_qnxpaches
OUT = ./0.79_qnxresult

#-------------------------------------------------------------------------------

all: update qnx
	@echo ""
	@echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	@echo ""
	(cd $(OUT); make)
	(cd examples; make)

qnx: 

	mkdir -p $(OUT)
	mkdir -p $(OUT)/doc
	mkdir -p $(OUT)/qnx
	mkdir -p $(OUT)/src

	cp  -Rv  $(INP)/README.oo $(OUT)/doc
	cp  -Rv  $(INP)/AUTHORS   $(OUT)
	cp  -Rv  $(INP)/LICENSE   $(OUT)
	cp  -Rv  $(INP)/README    $(OUT)

	mkdir -p $(OUT)/src/examples
	cp   -v  $(INP)/examples/client-server.tcl  $(OUT)/src/examples
	cp   -v  $(INP)/examples/ootest.tcl  $(OUT)/src/examples
	cp   -v  $(INP)/examples/parray.tcl  $(OUT)/src/examples
	cp   -v  $(INP)/examples/pipe.tcl    $(OUT)/src/examples
	cp   -v  $(INP)/examples/popen.tcl   $(OUT)/src/examples

	mkdir -p $(OUT)/src/noise
	mkdir -p $(OUT)/src/tests

	cp  -Rv  $(INP)/examples.api  $(OUT)/src

	cp  -v   $(INP)/*.c    $(OUT)/src
	cp  -v   $(INP)/*.h    $(OUT)/src
	cp  -v   $(INP)/*.tcl  $(OUT)/src

	mv  -v   $(OUT)/src/linenoise-win32.c $(OUT)/src/noise
	mv  -v   $(OUT)/src/linenoise.c       $(OUT)/src/noise
	mv  -v   $(OUT)/src/linenoise.h       $(OUT)/src/noise

	cp  -v   $(INP)/tests/*  $(OUT)/src/tests

# надо в конце все заполировать за раз

	cp  -Rv  $(ADD)/*        $(OUT)

	mkdir -p $(OUT)/src/T
	mkdir -p $(OUT)/src/Q
	mkdir -p $(OUT)/src/noise/T
	mkdir -p $(OUT)/src/noise/Q

# cp  -Rv  $(ADD)/E        $(OUT)
	# cp  -Rv  $(ADD)/doc      $(OUT)
	# cp  -Rv  $(ADD)/qnx      $(OUT)
	# cp   -v  $(ADD)/*        $(OUT)


#-------------------------------------------------------------------------------


test:
	(cd $(OUT); make test)
	(cd examples; make test)

#-------------------------------------------------------------------------------

clean: qnx_clean
	(cd examples; make clean)
#	(cd $(OUT); make clean)

qnx_clean:

	rm -R -f $(OUT)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

REL=0.79
DIRNAME=jimtcl-${REL}
RELNAME=${REL}

update: download untar

download:
	(cd A; \
	wget -c https://github.com/msteveb/jimtcl/archive/refs/tags/0.79.tar.gz ; \
	cd ..; \
	)

untar:
	(cd A; \
	gzip -kfd $(RELNAME).tar.gz; \
	tar   xvf $(RELNAME).tar; \
	rm     -f $(RELNAME).tar; \
	cd ..; \
	)

cleanall: 
	(cd A; rm -R -f $(DIRNAME); rm -f $(RELNAME).tar.gz ;)

#-------------------------------------------------------------------------------

#	cp  -Rv  $(INP)/tests $(OUT)/src
#	cp  -Rv  $(INP)/* $(OUT)
#	cp  -Rv  $(ADD)/* $(OUT)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

