
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


TENSOR_DIR = ../tensor		
COMMON_DIR = ../common
DIALOG_DIR = ../dialog

OPTIMA_DIR = ../optima
TEST-S_DIR = ../test-s/m
##LISPER_DIR = ../lisper

#-------------------------------------------------------------------------------


all:  COMMON__ TENSOR__ DIALOG__   OPTIMA__  TEST-S__  ##LISPER__   

#-------------------------------------------------------------------------------

TENSOR__ :
	(cd $(TENSOR_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)


OPTIMA__ :
	(cd $(OPTIMA_DIR); make)

TEST-S__ :
	(cd $(TEST-S_DIR); make)

# LISPER__ :
# 	(cd $(LISPER_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(TENSOR_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)

	(cd $(OPTIMA_DIR); make clean)
	(cd $(TEST-S_DIR); make clean)
##	(cd $(LISPER_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
