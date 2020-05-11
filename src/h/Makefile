
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = .

include ./Make.mak


ALASKA_DIR = ../alaska		
COMMON_DIR = ../common
DIALOG_DIR = ../dialog

LISPER_DIR = ../lisper
OPTIMA_DIR = ../optima
TEST-S_DIR = ../test-s/n

#-------------------------------------------------------------------------------


all:  COMMON__ ALASKA__ DIALOG__   LISPER__  OPTIMA__  TEST-S__  

#-------------------------------------------------------------------------------

ALASKA__ :
	(cd $(ALASKA_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)


LISPER__ :
	(cd $(LISPER_DIR); make)

OPTIMA__ :
	(cd $(OPTIMA_DIR); make)

TEST-S__ :
	(cd $(TEST-S_DIR); make)

#-------------------------------------------------------------------------------

clean : 
	(cd $(ALASKA_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)

	(cd $(LISPER_DIR); make clean)
	(cd $(OPTIMA_DIR); make clean)
	(cd $(TEST-S_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
