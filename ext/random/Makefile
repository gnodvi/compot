# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#TCLTK_CONF_DIR=~/.MSOFT/_tcl_tk/8.6.0/R/lib
#TCLTK_CONF_DIR?=/usr/lib/x86_64-linux-gnu/tcl8.6
#TCLTK_CONF_DIR?=/usr/lib/tcl8.5
#TCLTK_CONF_DIR?=/usr/lib/tcl8.6
#TCLTK_CONF_DIR?=/usr/lib/i386-linux-gnu/tcl8.6

ARCHPATH := $(shell dpkg-architecture -qDEB_BUILD_MULTIARCH)

TCLTK_CONF_DIR?=/usr/lib/$(ARCHPATH)/tcl8.6

#-------------------------------------------------------------------------------

#AR = @ar ru
#CP = @-cp
#RM = @-rm
#MV = mv
#EDIT_PROG  = xemacs
#MAKE = make

#SOFT_DIR = $(HOME)/.MSOFT

#-------------------------------------------------------------------------------

#_OS := $(shell uname -s)

#ifeq ($(_OS), Linux)
#else
#endif

#_NODENAME := $(shell uname -n)


#------------------------------------------------

include $(TCLTK_CONF_DIR)/tclConfig.sh

#-------------------------------------------------------------------------------

TCL_INCS=$(TCL_INCLUDE_SPEC) 

TCL_LIB_SPEC_clean	= $(subst ', , $(TCL_LIB_SPEC))

TCL_LIBS=$(TCL_LIB_SPEC_clean) 

TCL_STUB_LIB_SPEC_clean = $(subst ', , $(TCL_STUB_LIB_SPEC))

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

CURDIR="$(shell pwd)"

#FLAGS=-D__DIR__='${CURDIR}' -Wall -Winline -O3 -Wno-unused-result -std=c++11

#FLAGS=-D__DIR__='${CURDIR}' -Wall -Winline -g -O0 -Wno-unused-result
#FLAGS=-Wall -Winline -O3 -funroll-loops
#FLAGS=-Wall -Winline -O3 -funroll-loops
#FLAGS=-g -Wall -pg -O0 
#FLAGS=-g

#CC=g++
#LDFLAGS=-lboost_iostreams -lm -lboost_system -lboost_filesystem

#------------------------------------------------------------------

PROGS = k_test T/g-rand.o g_test T/k_tcl.so T/k_jim.so

all: $(PROGS)

#------------------------------------------------------------------

GCC_ = LANG=C  gcc -x c 

CC_PIC = LANG=en gcc -Wall -fPIC 
CC = LANG=C gcc -Wall 

H-FILES   = g-rand.h g-comm.h


T/g-rand.o : g-rand.c $(H-FILES)
	$(CC_PIC) -o $@ -c $< 

#-------------------------------------------------

g_test: g_test.c  $(H-FILES)  T/g-rand.o 
	$(CC)  -o $@  $< $(UTIL_ALL) T/g-rand.o -lm

#------------------------------------------------------------------

k_test: k_test.c k-main.h T/k-main.o
	gcc ${FLAGS} -o $@ $< T/k-main.o

T/k-main.o: k-main.c k-main.h
	gcc ${FLAGS} -c $<  -o $@

#-------------------------------------------------------------------------------

T/k_tcl.so: T/k-init.o T/k-main.o
	gcc  -shared -o $@ $^ $(TCL_STUB_LIB_SPEC_clean)

T/k-init.o: k-init.c
	$(GCC_)  -o $@ -DNO_CONST=1 -c -fPIC $^ $(TCL_INCS) $(TCL_STUB_LIB_SPEC_clean)

#------------------------------------------------------------------

ifdef NOTEST
BUILDOPTS := --notest
endif

JIM_DIR = ./JIM

T/k_jim.so:  k-main.c k-init.c
	build-jim-ext -I$(JIM_DIR) -I$(JIM_DIR) $(BUILDOPTS) -D_JIM -o $@ $^

#------------------------------------------------------------------

clean:
	rm -f core *~ T/*.o  *.o  gmon.out *.tmp.* *.out $(PROGS) 

#------------------------------------------------------------------
#------------------------------------------------------------------
