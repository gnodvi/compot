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

FLAGS = -fno-exceptions -Wall
IGRAPH_INCS = `pkg-config --cflags igraph`
IGRAPH_LIBS = `pkg-config   --libs igraph`

#Libs: -L${libdir} -ligraph
#Libs.private: -lm -lstdc++ -lgmp -lblas -llapack -lgomp -lpthread
#Requires.private: 
#Cflags: -I${includedir}/igraph

#-------------------------------------------------------------------------------

#GCC  = LANG=C  gcc -g 
GCC  = LANG=C  gcc -std=c99 

#-------------------------------------------------------------------------------

PROGS = tutorial1 tutorial2 tutorial3

all:   $(PROGS)  


#-------------------------------------------------------------------------------

tutorial1: tutorial1.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS} 

tutorial2: tutorial2.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS}

tutorial3: tutorial3.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS}


#-------------------------------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
