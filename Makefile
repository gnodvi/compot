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

compot_min:
	mkdir  -p   $(MIN)
	cp -r ./P   $(MIN)
	cp -r ./src/common/          $(MIN)/
	cp -r ./src/fun-gp/          $(MIN)/
	cp -r ./src/origin/          $(MIN)/
	cp -r ./src/dialog/          $(MIN)/
	cp -r ./src/tcl-tk/          $(MIN)/

	cp    ./Make.min             $(MIN)/Makefile
	cp    ./src/common/Make.mak  $(MIN)/

compot_min_clean:
	rm -R -f $(MIN)

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
