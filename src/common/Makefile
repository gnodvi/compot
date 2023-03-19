# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = ../h

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

GCC  = LANG=C  gcc -g

GNUPLOTI_DIR = P
GNUPLOTI_INC = -I$(GNUPLOTI_DIR) 
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/p_gnup.o

LITTLE_DIR = O/little

#-------------------------------------------------------------------------------

PROGS =  c_test T/c_capt.so  ##  r_test T/r_tcl.so T/r_jim.so    

# h-graf 
#all:   PLOTER__ $(PROGS)   

all:   PLOTER__ RANDOM__ $(PROGS)  #LITTLE__  


#-------------------------------------------------------------------------------

PLOTER__:
	(cd PLOTER; make)

RANDOM__:
	(cd RANDOM; make)

#LITTLE__ :
#	(cd $(LITTLE_DIR); make)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

c_test: c_test.cc
	$(GCC_)  -o $@ $^  $(TCL_INCS) $(TCL_LIBS)

#------------------------------------------------------------------

T/c_capt.so: T/c_capt.o
	gcc  -shared -o $@ $^ $(TCL_STUB_LIB_SPEC_clean)

T/c_capt.o: c_capt.cc
	$(GCC_)  -o $@ -DNO_CONST=1 -c -fPIC $^ $(TCL_INCS) $(TCL_STUB_LIB_SPEC_clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#h-graf : T/h-graf.o  T/h_meta.o                                  
#	$(GCC) -o $@ $< $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm

#T/h-graf.o : h-graf.c                                   
#	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

#T/h_meta.o : h_meta.c                                   
#	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

#-------------------------------------------------------------------------------

clean : 
	(cd PLOTER; make clean)
	(cd RANDOM; make clean)
	rm -f T/*.o $(PROGS)

test:
	T.sh

#---------------------------------------------------------------

# The problem is that in the link step you tell the compiler to treat 
# hello.o as a C file. That fails.

# I have already given NeedHelp a solution/workaround in the thread
# "Configure "-x c" options with "--with-cflags" does not work for me."

# РЕШЕНИЕ: компилировать надо с флагом, а собирать уже обычным способом!
#
 
#============================================================================*/
 
# TODO:
 
# + MultiFor для множественного использования (структура);

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
