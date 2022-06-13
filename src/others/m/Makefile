# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------


CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
PLOTER_DIR = ../ploter		
SROBOT_DIR = ../srobot		
LOGICS_DIR = ../logics		

TENSOR_DIR = ../arrays		
HPOKER_DIR = ../hpoker
LISPER_DIR = ../lisper
POKERS_DIR = ../pokers
DIALOG_DIR = ../dialog

#-------------------------------------------------------------------------------


all:  CGPLIB__ PLOTER__ LOGICS__  TENSOR__  DIALOG__ POKERS__ # CAUL-S__ # LISPER__  

#-------------------------------------------------------------------------------

#CAUL-S__ :
#	(cd $(CAUL-S_DIR); make)

CGPLIB__ :
	(cd $(CGPLIB_DIR); make)

PLOTER__ :
	(cd $(PLOTER_DIR); make)

LOGICS__ :
	(cd $(LOGICS_DIR); make)

SROBOTL__ :
	(cd $(SROBOT_DIR); make)


TENSOR__ :
	(cd $(TENSOR_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)


# LISPER__ :
# 	(cd $(LISPER_DIR); make)

POKERS__ :
	(cd $(POKERS_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(CAUL-S_DIR); make clean)
	(cd $(CGPLIB_DIR); make clean)
	(cd $(PLOTER_DIR); make clean)
	(cd $(LOGICS_DIR); make clean)
	(cd $(SROBOT_DIR); make clean)
	(cd $(TENSOR_DIR); make clean)
	(cd $(POKERS_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
