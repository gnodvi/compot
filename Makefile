# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd ext/m; make)
	(cd src/m; make)

test:  
	(cd .; T.sh)

#--------------------------------------------

clean:  
	(cd ext/m; make clean)
	(cd src/m; make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
