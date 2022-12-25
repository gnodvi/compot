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

#-------------------------------------------------------------------------------

#GCC  = LANG=C  gcc -g 
GCC  = LANG=C  gcc -std=c99 

#-------------------------------------------------------------------------------

PROGS = igraph_small igraph_create igraph_get_shortest_paths \
        igraph_get_shortest_paths_dijkstra 

all:   $(PROGS)  


#-------------------------------------------------------------------------------

igraph_small: igraph_small.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS} 

igraph_create: igraph_create.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS} 

igraph_get_shortest_paths: igraph_get_shortest_paths.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS} 

igraph_get_shortest_paths_dijkstra: igraph_get_shortest_paths_dijkstra.c
	$(GCC) ${FLAGS}  -o $@ ${IGRAPH_INCS} $< ${IGRAPH_LIBS} 

#-------------------------------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
