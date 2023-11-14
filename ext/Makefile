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

#-------------------------------------------------------------------------------

src:
	(cd   jimtcl; make src)
	(cd metamath; make src)

#-------------------------------------------------------------------------------

cleanarx:
	(cd A;  find . ! -name '.gitignore' -type f -exec rm -f {} +)

cleanbin: cleansrc
	(cd R;  find . ! -name '.' -type d -exec rm -R -f {} +)

cleansrc: 
	(cd T;  find . ! -name '.' -type d -exec rm -R -f {} +)

#-------------------------------------------------------------------------------

test:  
	(cd   jimtcl; make test)
	(cd   CURVAT; make test)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
