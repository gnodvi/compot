# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ../../Make.mak


COMMON_DIR = ../common
FUN-GP_DIR = ../fun-gp

##JIMTCL_DIR = ../jimtcl		
OLDJOY_DIR = ../oldjoy		
RANDOM_DIR = ../random		
PLOTER_DIR = ../ploter		
LISOFT_DIR = ../lisoft	
DIALOG_DIR = ../dialog

S_DIR = ../S	

#-------------------------------------------------------------------------------


all:  S__ OLDJOY__  RANDOM__ PLOTER__ LISOFT__  COMMON__  FUN-GP__  DIALOG__ ## JIMTCL__ 

#-------------------------------------------------------------------------------

S__ :
	(cd $(S_DIR); make)


OLDJOY__ :
	(cd $(OLDJOY_DIR); make)

#JIMTCL__ :
#	(cd $(JIMTCL_DIR); make)

RANDOM__ :
	(cd $(RANDOM_DIR); make)

PLOTER__ :
	(cd $(PLOTER_DIR); make)

LISOFT__ :
	(cd $(LISOFT_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

FUN-GP__ :
	(cd $(FUN-GP_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)

#ORIGIN__ :
#	(cd ../origin; make)

#-------------------------------------------------------------------------------
test:
	M

#-------------------------------------------------------------------------------

Aclean : 
	(cd $(S_DIR);      make Aclean)
Rclean : 
	(cd $(S_DIR);      make Rclean)

clean : 
	(cd $(S_DIR);      make clean)
	(cd $(OLDJOY_DIR); make clean)
#	(cd $(JIMTCL_DIR); make clean)
	(cd $(RANDOM_DIR); make clean)
	(cd $(LISOFT_DIR); make clean)
	(cd $(PLOTER_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(FUN-GP_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
#	(cd ../origin; make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
