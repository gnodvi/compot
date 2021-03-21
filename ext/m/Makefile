
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ../../Make.mak


CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
PLOTER_DIR = ../ploter		
##JIMTCL_DIR = ../jimtcl		
M-MATH_DIR = ../m-math		
JOYJOY_DIR = ../joyjoy		

#-------------------------------------------------------------------------------


all:  CAUL-S__ CGPLIB__ PLOTER__ M-MATH__ JOYJOY__ ##JIMTCL__  

#-------------------------------------------------------------------------------

CAUL-S__ :
	(cd $(CAUL-S_DIR); make)

CGPLIB__ :
	(cd $(CGPLIB_DIR); make)

PLOTER__ :
	(cd $(PLOTER_DIR); make)

M-MATH__ :
	(cd $(M-MATH_DIR); make)

JOYJOY__ :
	(cd $(JOYJOY_DIR); make)

##JIMTCL__ :
##	(cd $(JIMTCL_DIR); make)

#-------------------------------------------------------------------------------
test:
	M

#-------------------------------------------------------------------------------

clean : 
	(cd $(CAUL-S_DIR); make clean)
	(cd $(CGPLIB_DIR); make clean)
	(cd $(PLOTER_DIR); make clean)
	(cd $(M-MATH_DIR); make clean)
	(cd $(JOYJOY_DIR); make clean)
##	(cd $(JIMTCL_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
