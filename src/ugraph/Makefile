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

PROGS =  e-graf 

all:   $(PROGS)   


#-------------------------------------------------------------------------------

e-graf : T/e-graf.o  T/e_meta.o                                  
	$(GCC) -o $@ $< $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm

T/e-graf.o : e-graf.c                                   
	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

T/e_meta.o : e_meta.c                                   
	$(GCC) -fPIC -x c -o $@ -c $< $(GNUPLOTI_INC)

#-------------------------------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)
#	(cd P; make clean)

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
