# -*-   mode: makefile ; coding: koi8   -*- -----------------------------------
#
#------------------------------------------------------------------------------
# ============================================================================#
#                                                                             #
#    MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF     #
#    MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF  MAKE_DEF     #
#                                                                             #
# ============================================================================#


# ============================================================================#
# YDIR_ROOT must be defined !!!
# 
XDIR_ROOT = /usr/X11R6
 
# ============================================================================#

#FDIR_ROOT = $(HOME)/src/root_fltk
FDIR_ROOT = /home/pilot/.MSOFT/fltk/1.1.10/R

#FDIR_INC  = $(FDIR_ROOT)
FDIR_INC  = $(FDIR_ROOT)/include
FDIR_LIB  = $(FDIR_ROOT)/lib

FLTK_OPTS = -fno-rtti -fno-exceptions 
#FLTK_INCS = -DFLTK -I$(FDIR_ROOT)
#FLTK_LIBS = -L$(FDIR_LIB) -lfltk

FLTK_INCS = -I$(FDIR_INC)
FLTK_LIBS = -L$(FDIR_LIB) -lfltk


YDIR_INC = $(YDIR_ROOT)/include
YDIR_LIB = $(YDIR_ROOT)/lib
YZONE_OPTS = -w -g 
YZONE_INCS = -I$(YDIR_INC)
YZONE_LIBS = $(YDIR_LIB)/y_zone.a

XDIR_LIB = $(XDIR_ROOT)/lib
UNIX_CC = c++ 
UNIX_OPTS = -malign-double
UNIX_INCS = 
UNIX_LIBS = -L$(XDIR_LIB) -lX11 -lXext -lm 

CYGWIN_CC = gcc 
CYGWIN_OPTS = 
CYGWIN_INCS = -DGCC__W -DWIN32 -mno-cygwin 
CYGWIN_LIBS = -lcygwin -lgdi32 -luser32 -lmsvcrt -lwsock32 -lm -mno-cygwin -mwindows 
 
#-------------------------------------
# Sorry, it's don't work yet :(
#
#BORLAND_CC = bcc32 -DBORL_W -v -W 
#VSTUDIO_CC = ??? -DMICR_W 
#           = -DLCC__W ??
#-------------------------------------

# ============================================================================#
# SECTION for CHANGES:   MAIN = (UNIX or CYGWIN)
#                         ADD = (FLTK or nothing)
# ---------------------------------------------- 

SYS  = UNIX
#ADD = FLTK

# ============================================================================#

CC = $($(SYS)_CC)
OPTS = $($(SYS)_OPTS) $(YZONE_OPTS) $($(ADD)_OPTS) 
INCS = $($(SYS)_INCS) $(YZONE_INCS) $($(ADD)_INCS) 
LIBS = $($(SYS)_LIBS) $(YZONE_LIBS) $($(ADD)_LIBS) 

AR = @ar ru
CP = @-cp
RM = @-rm
MV = mv
EDIT_PROG  = xemacs
MAKE = make

#.SILENT:
# ============================================================================#
