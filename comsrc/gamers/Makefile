# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------

#-------------------------------------------------------------------------------

#CC    =  gcc -g -ansi -pedantic -Wall -D_C_SOURCE=1
#CC    =  LANG=C  gcc -Wall 
CC    =  LANG=C  gcc -x c 

#---------------------------------------------------------------

PROGS = T/r-rsb-.so


all: $(PROGS) 
	(cd SROBOT;   make)

#---------------------------------------------------------------

clean :
	rm -f T/*.o T/*.so $(PROGS)
	(cd SROBOT;   make clean)

#---------------------------------------------------------------

# The problem is that in the link step you tell the compiler to treat 
# hello.o as a C file. That fails.

# I have already given NeedHelp a solution/workaround in the thread
# "Configure "-x c" options with "--with-cflags" does not work for me."

# РЕШЕНИЕ: компилировать надо с флагом, а собирать уже обычным способом!
#
#---------------------------------------------------------------

T/r_rsb3.o: r_rsb3.cc
	$(CC) $(FLAGS) -x c -fpic -o $@ -c $<

T/r-rsb-.so: T/r_rsb3.o 
	gcc $(FLAGS) -shared -fpic  -o $@ $^

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
