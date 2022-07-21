# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ../../Make.mak



JIMTCL_DIR = ../jimtcl		
OLDJOY_DIR = ../oldjoy		
RANDOM_DIR = ../random		
PLOTER_DIR = ../ploter		
LISOFT_DIR = ../lisoft		
NATURE_DIR = ../nature		

#-------------------------------------------------------------------------------


all:  OLDJOY__ JIMTCL__ RANDOM__ PLOTER__ LISOFT__ NATURE__   

#-------------------------------------------------------------------------------

OLDJOY__ :
	(cd $(OLDJOY_DIR); make)

JIMTCL__ :
	(cd $(JIMTCL_DIR); make)

RANDOM__ :
	(cd $(RANDOM_DIR); make)

PLOTER__ :
	(cd $(PLOTER_DIR); make)

LISOFT__ :
	(cd $(LISOFT_DIR); make)

NATURE__ :
#	(cd $(NATURE_DIR); make)

#-------------------------------------------------------------------------------
test:
	M

#-------------------------------------------------------------------------------

clean : 
	(cd $(OLDJOY_DIR); make clean)
	(cd $(JIMTCL_DIR); make clean)
	(cd $(RANDOM_DIR); make clean)
	(cd $(LISOFT_DIR); make clean)
	(cd $(PLOTER_DIR); make clean)
	(cd $(NATURE_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
