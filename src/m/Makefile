# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ../../Make.mak


COMMON_DIR = ../common
FUN-GP_DIR = ../fun-gp

##JIMTCL_DIR = ../jimtcl		
#OLDJOY_DIR = ../oldjoy		
##RANDOM_DIR = ../random		
PLOTER_DIR = ../ploter		
LISOFT_DIR = ../lisoft	
DIALOG_DIR = ../dialog

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#OTHERS_DIR = ../others/m
TESTER_DIR = ../test-s

CAUL-S_DIR = ../gaul-s		
CGPLIB_DIR = ../cgplib		
LOGICS_DIR = ../logics		

TENSOR_DIR = ../arrays		
LISPER_DIR = ../lisper
GAMERS_DIR = ../gamers

#-------------------------------------------------------------------------------


all:  COMMON_  FUN-GP_  LISOFT_ DIALOG_ CGPLIB_ LOGICS_ TENSOR_ \
      GAMERS_ GRAPHS_ ORIGIN_ TESTER_

# RANDOM__ PLOTER__  OLDJOY_
# CAUL-S__ # LISPER__ ##OTHERS__  #repo01  ##   ## JIMTCL__ 

#-------------------------------------------------------------------------------



GRAPHS_ :
	(cd ../graphs; make)

#OLDJOY_ :
#	(cd $(OLDJOY_DIR); make)

#JIMTCL_ :
#	(cd $(JIMTCL_DIR); make)

#RANDOM_ :
#	(cd $(RANDOM_DIR); make)

#PLOTER_ :
#	(cd $(PLOTER_DIR); make)

LISOFT_ :
	(cd $(LISOFT_DIR); make)

COMMON_ :
	(cd $(COMMON_DIR); make)

FUN-GP_ :
	(cd $(FUN-GP_DIR); make)

DIALOG_ :
	(cd $(DIALOG_DIR); make)

ORIGIN_ :
	(cd ../origin; make)

SOLVER_ :
	(cd ../solver; make)


#-------------------------------------------------------------------------------

#OTHERS_ :
#	(cd $(OTHERS_DIR); make)

TESTER_ :
	(cd $(TESTER_DIR); make)

#-------------------------------------------

#CAUL-S_ :
#	(cd $(CAUL-S_DIR); make)

CGPLIB_ :
	(cd $(CGPLIB_DIR); make)

LOGICS_ :
	(cd $(LOGICS_DIR); make)

TENSOR_ :
	(cd $(TENSOR_DIR); make)


# LISPER_ :
# 	(cd $(LISPER_DIR); make)

GAMERS_ :
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
#	(cd $(OLDJOY_DIR); make clean)
#	(cd $(JIMTCL_DIR); make clean)
#	(cd $(RANDOM_DIR); make clean)
	(cd $(LISOFT_DIR); make clean)
#	(cd $(PLOTER_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(FUN-GP_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)
	(cd ../origin; make clean)
	(cd ../solver; make clean)

#	(cd ../repo01; make clean)

	(cd $(TESTER_DIR); make clean)
##	(cd $(OTHERS_DIR); make clean)

	(cd $(CAUL-S_DIR); make clean)
	(cd $(CGPLIB_DIR); make clean)
	(cd $(LOGICS_DIR); make clean)
	(cd $(TENSOR_DIR); make clean)
	(cd $(GAMERS_DIR); make clean)
	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
