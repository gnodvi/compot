# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------


TENSOR_DIR = ../arrays		

HPOKER_DIR = ../hpoker

##LISPER_DIR = ../lisper

ORIGIN_DIR = ../origin

POKERS_DIR = ../pokers

DIALOG_DIR = ../dialog

#-------------------------------------------------------------------------------


all:  TENSOR__ ORIGIN__  DIALOG__ ##POKERS__ # HPOKER__ # OTHERS__ LISPER__  

#-------------------------------------------------------------------------------

TENSOR__ :
	(cd $(TENSOR_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)

# OTHERS__ :
# 	(cd $(OTHERS_DIR); make)

# LISPER__ :
# 	(cd $(LISPER_DIR); make)

#POKERS__ :
#	(cd $(JOY_GP_DIR); make)

ORIGIN__ :
	(cd $(ORIGIN_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(TENSOR_DIR); make clean)
#	(cd $(POKERS_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
	(cd $(ORIGIN_DIR); make clean)
##	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
