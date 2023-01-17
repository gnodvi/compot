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

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#OTHERS_DIR = ../others/m
#TESTER_DIR = ../tester/m

CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
LOGICS_DIR = ../logics		

TENSOR_DIR = ../arrays		
LISPER_DIR = ../lisper
GAMERS_DIR = ../gamers

#-------------------------------------------------------------------------------


all:  OLDJOY__  RANDOM__ PLOTER__ COMMON__  LISOFT__  FUN-GP__  DIALOG__ CGPLIB__ LOGICS__  TENSOR__  GAMERS__ GRAPHS__  

# CAUL-S__ # LISPER__ ##OTHERS__  #repo01  ## TESTER__  ## JIMTCL__ 

#-------------------------------------------------------------------------------



GRAPHS__ :
	(cd ../graphs; make)

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

#OTHERS__ :
#	(cd $(OTHERS_DIR); make)

#TESTER__ :
#	(cd $(TESTER_DIR); make)

#-------------------------------------------

#CAUL-S__ :
#	(cd $(CAUL-S_DIR); make)

CGPLIB__ :
	(cd $(CGPLIB_DIR); make)

LOGICS__ :
	(cd $(LOGICS_DIR); make)

TENSOR__ :
	(cd $(TENSOR_DIR); make)


# LISPER__ :
# 	(cd $(LISPER_DIR); make)

GAMERS__ :
	(cd $(GAMERS_DIR); make)

#---------------------------------------------

repo01:
	(cd ../repo01; make)


#-------------------------------------------------------------------------------
test:
	M

#-------------------------------------------------------------------------------

clean : 
	(cd     ../graphs; make clean)
	(cd $(OLDJOY_DIR); make clean)
#	(cd $(JIMTCL_DIR); make clean)
	(cd $(RANDOM_DIR); make clean)
	(cd $(LISOFT_DIR); make clean)
	(cd $(PLOTER_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(FUN-GP_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
#	(cd ../origin; make clean)
	(cd ../repo01; make clean)
#	(cd $(TESTER_DIR); make clean)
#	(cd $(OTHERS_DIR); make clean)
	(cd $(CAUL-S_DIR); make clean)
	(cd $(CGPLIB_DIR); make clean)
	(cd $(LOGICS_DIR); make clean)
	(cd $(TENSOR_DIR); make clean)
	(cd $(GAMERS_DIR); make clean)
	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
