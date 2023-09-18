# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

include ./Make.mak

#----------------------------------------------

OPTIM = -O2 -fno-exceptions -Wall 
GCC_ = LANG=C  gcc -x c 

SOFT_DIR = $(HOME)/.MSOFT
SYS_LIBS = -lm #-lsocket

#----------------------------------------------

CC = LANG=C gcc -g


OPTIM = -fno-exceptions -Wall
GCC   = LANG=C gcc -O2
CPP   = c++ -O2
FLAGS = $(OPTIM) -D_UNIX -D_ENG

#-------------------------------------------------------------------------------

GCC  = LANG=C  gcc -g

GNUPLOTI_DIR = PLOTER
GNUPLOTI_INC = -I$(GNUPLOTI_DIR) 
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/p_gnup.o

#------------------------------------------------------------------

ARCHPATH := $(shell dpkg-architecture -qDEB_BUILD_MULTIARCH)
TCLTK_CONF_DIR?=/usr/lib/$(ARCHPATH)/tcl8.6

include $(TCLTK_CONF_DIR)/tclConfig.sh


TCL_INCS=$(TCL_INCLUDE_SPEC) 
TCL_LIB_SPEC_clean	= $(subst ', , $(TCL_LIB_SPEC))
TCL_LIBS=$(TCL_LIB_SPEC_clean) 
TCL_STUB_LIB_SPEC_clean = $(subst ', , $(TCL_STUB_LIB_SPEC))

IGRAPH_INCS = `pkg-config --cflags igraph`
IGRAPH_LIBS = `pkg-config   --libs igraph`

#------------------------------------------------------------------

PROGS =  c_igra c_test T/e_tcl.so  T/e_jim.so T/e-0000.so  \
	T/c-1111-notplot.o T/c-1111-gnuplot.o  ## d_test

all:  
#	(cd IGRAPH; make)
#	(cd CURVAT; make)
	(cd .; make origin)

origin: $(PROGS) 

test:  
	# (cd IGRAPH; make test)
	# (cd CURVAT; make test)
	T_graphs.sh

#-------------------------------------------------------------------------------

T/e-0000.so: T/c-0000.o T/e-0000_wrap.o   T/c-1111-notplot.o
	gcc -shared  -o $@ $^

T/c-0000.o: c-0000.c c-0000.h
	gcc -c -fpic -I. -o $@  c-0000.c  -I/usr/include/tcl8.6


T/e-0000_wrap.o: T/e-0000_wrap.c
	gcc -c -fpic -I.  -o $@ $<  -I/usr/include/tcl8.6

T/e-0000_wrap.c: e-0000.i
	swig -tcl8  -o $@ e-0000.i



T/c-1111-notplot.o: c-1111.c c-1111.h
	gcc -c -fpic -I. -o $@  c-1111.c   -I/usr/include/tcl8.6

T/c-1111-gnuplot.o: c-1111.c c-1111.h
	gcc -c -fpic -I. -D_GNUPLOT -o $@  c-1111.c   -I/usr/include/tcl8.6 $(GNUPLOTI_INC) $(GNUPLOTI_LIB)



c_test :  c_test.c T/c-0000.o   T/c-1111-gnuplot.o                                 
	$(GCC) -o $@ $^ $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm

#T/e-0000.o : e-0000.c e-0000.h                                  
##	$(GCC) -D_GNUPLOT -o $@ -c $< $(GNUPLOTI_INC)
#	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

#------------------------------------------------------------------

c_igra :  c_igra.c                                    
	$(GCC) -o $@ $^ ${IGRAPH_INCS} ${IGRAPH_LIBS} 

#------------------------------------------------------------------

ifdef NOTEST
BUILDOPTS := --notest
endif

#JIM_DIR = ./JIM

SRC =  c-0000.c e_init.c ##  p_comm.c p_gnup.c p_plot.c
DEP =  c-0000.h

T/e_jim.so:  $(SRC) $(DEP) 
	build-jim-ext --notest $(BUILDOPTS) -D_JIM -o $@ $(SRC) $(GNUPLOTI_INC) ##-lpgnup  -L./P/T

#-------------------------------------------------------------------------------

T/e_tcl.so: T/e_init.o T/c-0000.o T/c-1111-notplot.o ##$(GNUPLOTI_LIB)
	gcc  -shared -o $@ $^ $(TCL_STUB_LIB_SPEC_clean)

T/e_init.o: e_init.c c-0000.h
	$(GCC_)  -o $@ -DNO_CONST=1 -c -fPIC $< $(TCL_INCS) $(TCL_STUB_LIB_SPEC_clean)

# ============================================================================#

#S_INCS = $(XINC) $(GINC) $(GNUPLOTI_INC) $(GSL_INC) 
#S_LIBS = $(XLIB) $(GLIB) $(GNUPLOTI_LIB) $(GSL_LIB) 

#d_test : d_test.c                                                               
#	$(CC) -o $@ $^ $(S_INCS) $(XLIB) $(GNUPLOTI_LIB) $(GSL_LIB)  -lm            

#--------------------------------------------

clean:  
	rm -f T/*.o $(PROGS)
	rm -f T/*.o T/*.so T/*_wrap*
	rm -f core 
	rm -f T/*.dot T/*.png T/*.file
#	(cd IGRAPH;   make clean)
#	(cd CURVAT;   make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
