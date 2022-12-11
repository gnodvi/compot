# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

all:  
	(cd freeglut; make)
	(cd   jimtcl; make)
	(cd metamath; make)

#-------------------------------------------------------------------------------

clean:  
	(cd freeglut; make clean)
	(cd   jimtcl; make clean)
	(cd metamath; make clean)

cleanall: clean cleanbin cleanarx
#	(cd freeglut; make -i cleanall)
#	(cd   jimtcl; make -i cleanall)
#	(cd metamath; make -i cleanall)

#-------------------------------------------------------------------------------

src:
	(cd   jimtcl; make src)
	(cd metamath; make src)


#-------------------------------------------------------------------------------

#cleanall: cleanarx cleanbin

cleanarx:
	(cd A;  find . ! -name '.gitignore' -type f -exec rm -f {} +)

cleanbin: cleansrc
	(cd R;  find . ! -name '.' -type d -exec rm -R -f {} +)

cleansrc: 
#	(cd T;  find . ! -name '.gitignore' -type d -exec rm -R -f {} +)
	(cd T;  find . ! -name '.' -type d -exec rm -R -f {} +)


#-------------------------------------------------------------------------------

test:  
	(cd   jimtcl; make test)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
