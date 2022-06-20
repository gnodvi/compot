# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


COMMON_DIR = ../common
FUN-GP_DIR = ../fun-gp
OTHERS_DIR = ../others/m
TESTER_DIR = ../tester/m

#-------------------------------------------------------------------------------


all:  COMMON__  FUN-GP__  OTHERS__  TESTER__ 

#-------------------------------------------------------------------------------

COMMON__ :
	(cd $(COMMON_DIR); make)

FUN-GP__ :
	(cd $(FUN-GP_DIR); make)

OTHERS__ :
	(cd $(OTHERS_DIR); make)

TESTER__ :
	(cd $(TESTER_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(COMMON_DIR); make clean)
	(cd $(FUN-GP_DIR); make clean)
	(cd $(OTHERS_DIR); make clean)
	(cd $(TESTER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
