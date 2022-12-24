# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

include ./Make.mak

#-------------------------------------------------------------------------------

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
#-------------------------------------------------------------------------------

GCC  = LANG=C  gcc -g

GNUPLOTI_DIR = P
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

#------------------------------------------------------------------

PROGS_origin =  f_test T/e_tcl.so  T/e_jim.so T/e-0000.so 

#-------------------------------------------------------------------------------

all:  $(PROGS_origin) 
	(cd IGRAPH; make)

test:  
	T_graphs.sh
	(cd IGRAPH;                         make test)
	(cd CURVATURES/GraphRicciCurvature; make test)

#-------------------------------------------------------------------------------

T/e-0000.so: T/e-0000.o T/e-0000_wrap.o
	gcc -shared  -o $@ $^

T/e-0000.o: e-0000.c e-0000.h
	gcc -c -fpic -I. -o $@  e-0000.c       -I/usr/include/tcl8.6

T/e-0000_wrap.o: T/e-0000_wrap.c
	gcc -c -fpic -I.  -o $@ $<  -I/usr/include/tcl8.6

T/e-0000_wrap.c: e-0000.i
	swig -tcl8  -o $@ e-0000.i


#------------------------------------------------------------------

f_test :  f_test.c T/e-0000.o                                    
	$(GCC) -o $@ $^ $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm

#T/e-0000.o : e-0000.c e-0000.h                                  
##	$(GCC) -D_GNUPLOT -o $@ -c $< $(GNUPLOTI_INC)
#	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

#------------------------------------------------------------------

ifdef NOTEST
BUILDOPTS := --notest
endif

#JIM_DIR = ./JIM

SRC =  e-0000.c e_init.c ##  p_comm.c p_gnup.c p_plot.c
DEP =  e-0000.h

T/e_jim.so:  $(SRC) $(DEP) 
	build-jim-ext --notest $(BUILDOPTS) -D_JIM -o $@ $(SRC) $(GNUPLOTI_INC) ##-lpgnup  -L./P/T

#-------------------------------------------------------------------------------
#------------------------------------------------------------------

T/e_tcl.so: T/e_init.o T/e-0000.o ##$(GNUPLOTI_LIB)
	gcc  -shared -o $@ $^ $(TCL_STUB_LIB_SPEC_clean)

T/e_init.o: e_init.c e-0000.h
	$(GCC_)  -o $@ -DNO_CONST=1 -c -fPIC $< $(TCL_INCS) $(TCL_STUB_LIB_SPEC_clean)

#--------------------------------------------

clean:  
	rm -f T/*.o $(PROGS)
	rm -f T/*.o T/*.so T/*_wrap*
	rm -f core 
	(cd IGRAPH;   make clean)
	rm -f T/*.dot T/*.png T/*.file

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
