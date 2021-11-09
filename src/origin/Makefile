# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#include ../n//Make.mak

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

GCC  = LANG=C  gcc -g

GNUPLOTI_DIR = P
GNUPLOTI_INC = -I$(GNUPLOTI_DIR) 
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/p_gnup.o

#-------------------------------------------------------------------------------

ARCHPATH := $(shell dpkg-architecture -qDEB_BUILD_MULTIARCH)

TCLTK_CONF_DIR?=/usr/lib/$(ARCHPATH)/tcl8.6

include $(TCLTK_CONF_DIR)/tclConfig.sh

#----------------------------------------------------------

TCL_INCS=$(TCL_INCLUDE_SPEC) 

TCL_LIB_SPEC_clean	= $(subst ', , $(TCL_LIB_SPEC))

TCL_LIBS=$(TCL_LIB_SPEC_clean) 

TCL_STUB_LIB_SPEC_clean = $(subst ', , $(TCL_STUB_LIB_SPEC))

#-------------------------------------------------------------------------------

PROGS =  e_test T/e_tcl.so  T/e_jim.so

all:   $(PROGS)   


#-------------------------------------------------------------------------------

T/e-0000.o : e-0000.c e-0000.h                                  
	$(GCC) -D_GNUPLOT -o $@ -c $< $(GNUPLOTI_INC)
#	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)


e_test :  e_test.c T/e-0000.o                                    
	$(GCC) -o $@ $^ $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm

#------------------------------------------------------------------


T/e-init.o: e-init.c
	$(GCC_)  -o $@ -DNO_CONST=1 -c -fPIC $^ $(TCL_INCS) $(TCL_STUB_LIB_SPEC_clean)

T/e_tcl.so: T/e-init.o T/e-0000.o $(GNUPLOTI_LIB)
	gcc  -shared -o $@ $^ $(TCL_STUB_LIB_SPEC_clean)

#------------------------------------------------------------------

ifdef NOTEST
BUILDOPTS := --notest
endif

JIM_DIR = ./JIM

SRC =  e-0000.c e-init.c ##  p_comm.c p_gnup.c p_plot.c
DEP =  e-0000.h

T/e_jim.so:  $(SRC) $(DEP) 
	build-jim-ext --notest $(BUILDOPTS) -D_JIM -o $@ $(SRC) $(GNUPLOTI_INC) ##-lpgnup  -L./P/T

#-------------------------------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)
#	(cd P; make clean)

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
