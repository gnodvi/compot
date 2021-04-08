
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ../../Make.mak


CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
PLOTER_DIR = ../ploter		
##JIMTCL_DIR = ../jimtcl		
LOGICS_DIR = ../logics		
JOYJOY_DIR = ../joyjoy		
X_TOOL_DIR = ../x-tool		

#-------------------------------------------------------------------------------


all:  CAUL-S__ CGPLIB__ PLOTER__ LOGICS__ JOYJOY__ ##JIMTCL__  

#-------------------------------------------------------------------------------

CAUL-S__ :
	(cd $(CAUL-S_DIR); make)

CGPLIB__ :
	(cd $(CGPLIB_DIR); make)

PLOTER__ :
	(cd $(PLOTER_DIR); make)

LOGICS__ :
	(cd $(LOGICS_DIR); make)

JOYJOY__ :
	(cd $(JOYJOY_DIR); make)

# X_TOOL__ :
# 	(cd $(JOYJOY_DIR); make)

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
	(cd $(LOGICS_DIR); make clean)
	(cd $(JOYJOY_DIR); make clean)
	(cd $(X_TOOL_DIR); make clean)

##	(cd $(JIMTCL_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
