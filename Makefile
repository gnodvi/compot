# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd comext;   make)
	(cd comsrc/m; make)

test:  
	(cd comext; make test)
	T.sh

#--------------------------------------------

clean:  
	(cd comext;   make clean)
	(cd comsrc/m; make clean)

cleanall:  clean
	(cd comext;   make cleanall)

#--------------------------------------------

MIN = ../compot_min

compot_min:
	mkdir  -p   $(MIN)
	cp -r ./P   $(MIN)
	cp -r ./comsrc/common/          $(MIN)/
	cp -r ./comsrc/fun-gp/          $(MIN)/
	cp -r ./comsrc/origin/          $(MIN)/
	cp -r ./comsrc/dialog/          $(MIN)/
	cp -r ./comsrc/tcl-tk/          $(MIN)/

	cp    ./Make.min             $(MIN)/Makefile
	cp    ./comsrc/common/Make.mak  $(MIN)/

compot_min_clean:
	rm -R -f $(MIN)

#--------------------------------------------

MAX = ../comsrc

comsrc:
	mkdir  -p         $(MAX)
	cp -r ./P         $(MAX)
	cp -r ./comsrc/   $(MAX)/
	cp    ./Make.max  $(MAX)/Makefile
	cp    ./comsrc/common/Make.mak  $(MAX)/
#	cp    ./lib.sh   $(MAX)/

comsrc_clean:
	rm -R -f $(MAX)

#--------------------------------------------
#3       Compress the current subdirectory (tar.gz)
#tgz:
#        Pwd=`basename %d /`
#        echo -n "Name of the compressed file (without extension) [$Pwd]: "
#        read tar
#        [ "$tar"x = x ] && tar="$Pwd"
#        cd .. && \
#        tar cf - "$Pwd" | gzip -f9 > "$tar.tar.gz" && \
#        echo "../$tar.tar.gz created."


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
