# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd ext;   make)
	(cd src/m; make)

test:  
	(cd ext; make test)
	T.sh

#--------------------------------------------

clean:  
	(cd ext;   make clean)
	(cd src/m; make clean)

cleanall:  clean
	(cd ext;   make cleanall)

#--------------------------------------------
MIN = ../compot_min

savemin:
	mkdir  -p   $(MIN)
	cp -r ./P   $(MIN)
	cp -r ./src/common/ $(MIN)/
	cp -r ./src/fun-gp/ $(MIN)/
	cp -r ./src/tester/ $(MIN)/
	cp -r ./src/repo01/ $(MIN)/
	cp    ./Make.min    $(MIN)/Makefile
	cp    ./src/common/Make.mak    $(MIN)/

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
