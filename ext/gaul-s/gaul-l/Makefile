# =============================================================================#
#
#

MAIN_SRC_DIR = ..

include $(MAIN_SRC_DIR)/Make.mak

# =============================================================================#
#

CC_PIC = gcc -Wall -fPIC 

CC = LANG=C gcc -Wall -fPIC 

#CC = gcc -x c -Wall 
# -x c 

# очень странно, если без -x c  , то компилит ошибку 
# -x c другая ошибка в символах
# а потом уже снова нормально компилится без ошибок ..
# 
#-------------------------------------------------------------------------------

GAUL_HOME = ../gaul-c

GAUL_INCS = -I$(GAUL_HOME)
GAUL_LIBS = -L$(GAUL_HOME)/T -lgaul -lgaul_util

#-------------------------------------------------------------------------------

PROGS = T/tclgaul.so  T/tclgaul_gena.so 

all : $(PROGS)  
#	(cd ./Others; make all)

#-------------------------------------------------------------------------------

T/tclgaul.so : T/g-chro.o T/g-conv.o T/g-prox.o T/g-tclg.o
	$(CC) -shared -fpic -o $@ $^ $(GAUL_LIBS) 


T/g-chro.o : g-chro.cc g-chro.hh 
	$(CC) -x c -o $@ -c $< $(TCL_INCS) $(GAUL_INCS) 

T/g-conv.o : g-conv.cc g-conv.hh
	$(CC) -x c -o $@ -c $< $(TCL_INCS) $(GAUL_INCS) 

T/g-prox.o : g-prox.cc g-prox.hh g-tclg.hh g-conv.hh
	$(CC) -x c -o $@ -c $< $(TCL_INCS) $(GAUL_INCS) 

T/g-tclg.o : g-tclg.cc g-tclg.hh g-conv.hh g-prox.hh g-chro.hh
	$(CC) -x c -o $@ -c $< $(TCL_INCS) $(GAUL_INCS) 

#-------------------------------------------------------------------------------

GCC = LANG=C  gcc -x c -fPIC 

T/tclgaul_gena.so: T/g_0000.o
	gcc  -shared -o $@ $^ T/tclgaul.so $(GAUL_LIBS)

T/g_0000.o: g_0000.cc
	$(GCC)  -o $@ -c $^ $(TCL_INCS) $(TCL_LIBS)
#	$(CC)  -o $@ -c $^ -I$(TCL_DIR_INC) $(TCL_LIBS)

#-------------------------------------------------------------------------------

clean : 
	rm -f  T/*.o T/*.so *.o *.lo $(PROGS)

#-------------------------------------------------------------------------------

save :
	(cd ../m ; S.sh)

# =============================================================================#


