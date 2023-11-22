# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

PROGS =  r_code ## $(PROGS_origin)

all:  $(PROGS)
	(cd OLDJOY; make)


#------------------------------------------------------

r_code: r_code.cc 
	 c++  -D_UNIX -D_ENG  -D_UNIX -D_ENG  -o $@ $< 

#------------------------------------------------------

clean : 
	rm -f T/*.o $(PROGS)
	rm -f T/*.o T/*.so T/*_wrap*
	rm -f core 
	(cd OLDJOY; make clean)

test:
	T.sh

#-------------------------------------------------------------------------------

# The problem is that in the link step you tell the compiler to treat 
# hello.o as a C file. That fails.

# I have already given NeedHelp a solution/workaround in the thread
# "Configure "-x c" options with "--with-cflags" does not work for me."

# РЕШЕНИЕ: компилировать надо с флагом, а собирать уже обычным способом!
#
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
