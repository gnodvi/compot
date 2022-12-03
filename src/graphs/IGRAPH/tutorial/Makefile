# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

include ./Make.mak

#-------------------------------------------------------------------------------

OPTIM = -O2 -fno-exceptions -Wall 

GCC_ = LANG=C  gcc -x c 

#----------------------------------------------

CC = LANG=C gcc -g


OPTIM = -fno-exceptions -Wall
GCC   = LANG=C gcc -O2
CPP   = c++ -O2

FLAGS = -fno-exceptions -Wall `pkg-config --libs --cflags igraph`

#Libs: -L${libdir} -ligraph
#Libs.private: -lm -lstdc++ -lgmp -lblas -llapack -lgomp -lpthread
#Requires.private: 
#Cflags: -I${includedir}/igraph

#-------------------------------------------------------------------------------

GCC  = LANG=C  gcc -g

#-------------------------------------------------------------------------------

PROGS = tutorial1 tutorial2 tutorial3

all:   $(PROGS)  


#-------------------------------------------------------------------------------

tutorial1: tutorial1.c
	gcc ${FLAGS}  -o $@ $< 

tutorial2: tutorial2.c
	gcc ${FLAGS}  -o $@ $< 

tutorial3: tutorial3.c
	gcc ${FLAGS}  -o $@ $< 


#-------------------------------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
