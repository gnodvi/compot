# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


TENSOR_DIR = ../arrays		

COMMON_DIR = ../common
#DIALOG_DIR = ../dialog

#JOY_GP_DIR = ../joy-gp

TEST-S_DIR = ../others/m

UGRAPH_DIR = ../ugraph

#-------------------------------------------------------------------------------


all:  TENSOR__ COMMON__  TEST-S__  UGRAPH__ ##JOY_GP__  DIALOG__ 

#-------------------------------------------------------------------------------

TENSOR__ :
	(cd $(TENSOR_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

#DIALOG__ :
#	(cd $(DIALOG_DIR); make)


# JOY_GP__ :
# 	(cd $(JOY_GP_DIR); make)

TEST-S__ :
	(cd $(TEST-S_DIR); make)

UGRAPH__ :
	(cd $(UGRAPH_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(TENSOR_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
#	(cd $(DIALOG_DIR); make clean)
##	(cd $(JOY_GP_DIR); make clean)
	(cd $(TEST-S_DIR); make clean)
	(cd $(UGRAPH_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
