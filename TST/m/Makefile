# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


#OTHERS_DIR = ../others/m
#TESTER_DIR = ../tester/m

CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
SROBOT_DIR = ../srobot		
LOGICS_DIR = ../logics		

TENSOR_DIR = ../arrays		
HPOKER_DIR = ../hpoker
LISPER_DIR = ../lisper
POKERS_DIR = ../pokers

#-------------------------------------------------------------------------------


all:  CGPLIB__ LOGICS__  TENSOR__  POKERS__ # CAUL-S__ # LISPER__ ##OTHERS__  #repo01  ## TESTER__ 

#-------------------------------------------------------------------------------

#OTHERS__ :
#	(cd $(OTHERS_DIR); make)

#TESTER__ :
#	(cd $(TESTER_DIR); make)

#-------------------------------------------------------------------------------

#CAUL-S__ :
#	(cd $(CAUL-S_DIR); make)

CGPLIB__ :
	(cd $(CGPLIB_DIR); make)

LOGICS__ :
	(cd $(LOGICS_DIR); make)

SROBOTL__ :
	(cd $(SROBOT_DIR); make)


TENSOR__ :
	(cd $(TENSOR_DIR); make)


# LISPER__ :
# 	(cd $(LISPER_DIR); make)

POKERS__ :
	(cd $(POKERS_DIR); make)

#-------------------------------------------------------------------------------

repo01:
	(cd ../repo01; make)

#-------------------------------------------------------------------------------

clean : 
	(cd ../repo01; make clean)
#	(cd $(TESTER_DIR); make clean)
#	(cd $(OTHERS_DIR); make clean)
	(cd $(CAUL-S_DIR); make clean)
	(cd $(CGPLIB_DIR); make clean)
	(cd $(LOGICS_DIR); make clean)
	(cd $(SROBOT_DIR); make clean)
	(cd $(TENSOR_DIR); make clean)
	(cd $(POKERS_DIR); make clean)
	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
