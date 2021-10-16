# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


TENSOR_DIR = ../arrays		

COMMON_DIR = ../common
DIALOG_DIR = ../dialog

TEST-S_DIR = ../others/m

ORIGIN_DIR = ../origin

TESTER_DIR = ../tester

#-------------------------------------------------------------------------------


all:  TENSOR__ COMMON__  TEST-S__  ORIGIN__ DIALOG__ ##TESTER__   

#-------------------------------------------------------------------------------

TENSOR__ :
	(cd $(TENSOR_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)


#TESTER__ :
#	(cd $(JOY_GP_DIR); make)

TEST-S__ :
	(cd $(TEST-S_DIR); make)

ORIGIN__ :
	(cd $(ORIGIN_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(TENSOR_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
#	(cd $(TESTER_DIR); make clean)
	(cd $(TEST-S_DIR); make clean)
	(cd $(ORIGIN_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
