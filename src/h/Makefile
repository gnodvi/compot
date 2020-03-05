
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

MAIN_SRC_DIR = .

include $(MAIN_SRC_DIR)/Make.mak


ALASKA_DIR = $(MAIN_SRC_DIR)/../alaska		
COMMON_DIR = $(MAIN_SRC_DIR)/../common
DIALOG_DIR = $(MAIN_SRC_DIR)/../dialog

OPTIMA_DIR = $(MAIN_SRC_DIR)/../optima
TEST-S_DIR = $(MAIN_SRC_DIR)/../test-s/n

#-------------------------------------------------------------------------------


all:  COMMON__ ALASKA__ DIALOG__   OPTIMA__   TEST-S__  

#-------------------------------------------------------------------------------

ALASKA__ :
	(cd $(ALASKA_DIR); make)

COMMON__ :
	(cd $(COMMON_DIR); make)

DIALOG__ :
	(cd $(DIALOG_DIR); make)


OPTIMA__ :
	(cd $(OPTIMA_DIR); make)

#------------------------------------------

TEST-S__ :
	(cd $(TEST-S_DIR); make)


#-------------------------------------------------------------------------------

clean : 
	(cd $(ALASKA_DIR); make clean)
	(cd $(COMMON_DIR); make clean)
	(cd $(DIALOG_DIR); make clean)

	(cd $(OPTIMA_DIR); make clean)
	(cd $(TEST-S_DIR); make clean)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
