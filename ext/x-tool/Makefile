#-------------------------------------------------------------------------------
#GCC = LANG=C  gcc -fno-diagnostics-color -std=c99 -fstack-protector -std=gnu99
# 
#cc1: error: unrecognized command line option '-fno-diagnostics-color'

#GCC = LANG=C  gcc -fstack-protector -std=gnu99

GCC  = LANG=C  gcc -g


PROGS = l_scan T/l_scan.so  #m_nist  

#-------------------------------------------------------------------------------

all:  $(PROGS) 
	(cd CIPS;              make)
	(cd TOOL/3.20160805.1; make)
	(cd GOCR/gocr-0.52;    make)

# test:  
# 	(cd ext/m; M)
# 	(cd src/m; M)

#-------------------------------------------------------------------------------

l_scan : T/l_scan.o                                  
	$(GCC) -o $@ $< -lm

T/l_scan.o : l_scan.c                                   
	$(GCC)  -fPIC -x c -o $@ -c $< 

T/l_scan.so: T/l_scan.o
	$(GCC)  -shared -o $@ $< -lm

#-------------------------------------------------------------------------------

clean:  
	rm -f *.o $(PROGS) T/*.o
	(cd CIPS;              make clean)
	(cd TOOL/3.20160805.1; make clean)
	(cd GOCR/gocr-0.52;    make clean)
	(rm -f GOCR/gocr-0.52/src/gocr)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
