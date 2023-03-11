# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------


#GCC = LANG=C  gcc -fno-diagnostics-color -std=c99 -fstack-protector -std=gnu99
# 
#cc1: error: unrecognized command line option '-fno-diagnostics-color'

#GCC = LANG=C  gcc -fstack-protector -std=gnu99

GCC  = LANG=C  gcc -g


PROGS = l_scan T/l_scan.so  m_nist  

#-------------------------------------------------------------------------------

all: $(PROGS)

#-------------------------------------------------------------------------------

l_scan : T/l_scan.o                                  
	$(GCC) -o $@ $< -lm

T/l_scan.o : l_scan.c                                   
	$(GCC)  -fPIC -x c -o $@ -c $< 

T/l_scan.so: T/l_scan.o
	$(GCC)  -shared -o $@ $< -lm

#-------------------------------------------------------------------------------

#m_nist: m_nist.c m_file.c m_nnet.c
#	LANG=C gcc -o $@ $^ -lm 

m_nist: T/m_nist.o T/m-file.o T/m-nnet.o
	LANG=C gcc -o $@ $^ -lm 

# все равно ошибка *** stack smashing detected ***: <unknown> terminated


T/m_nist.o: m_nist.c
	LANG=C gcc -c -o $@ $^  

T/m-file.o: m-file.c
	LANG=C gcc -c -o $@ $^  

T/m-nnet.o: m-nnet.c
	LANG=C gcc -c -o $@ $^  

#-------------------------------------------------------------------------------

clean:
	rm -f *.o $(PROGS) T/*.o
	rm -fR D

#------------------------------------------------------------- 

save :  
	tar --ignore-failed-read -cvf  savemin.tar   *.rc *.ico *.xpm *.bmp *.c *.cc *.cxx *.h *.H *.hh *.isl *.iss Makefile *.txt *.ini *.not *.dic *.sol
	gzip -6 savemin.tar 
	(cd Archiv; mdat) 

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
