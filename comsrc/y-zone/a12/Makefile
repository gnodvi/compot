# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------

# =============================================================================#

#CYGWIN_CYGWIN  = 1 
UNIX_LINUX  = 1 
#CYGWIN_WINDOWS = 1 

# =============================================================================#

ifdef UNIX_LINUX

  #OPTIM = -O2 -w -Wunused -fno-exceptions # -Wall 
  #OPTIM = -fno-exceptions -Wreturn-type -Wimplicit -Wuninitialized
  OPTIM = -fno-exceptions -fpermissive  ##-Wwrite-strings -Wall 
  #APP = -mwindows 

  #FDIR_ROOT = ../../../../fltk-s
  #FDIR_ROOT = ../../FLTK-S
  #FDIR_ROOT = ../FLTK-S
  FDIR_ROOT = ../../F

  #FLTK_INCS = -I$(FDIR_ROOT)/include
  #FLTK_LIBS = -L$(FDIR_ROOT)/lib -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)
  FLTK_INCS = `fltk-config --cflags`
  FLTK_LIBS = `fltk-config --ldflags` -lfltk_forms -lfltk_images 

ifdef GCC_COLORS
  CC    = gcc -fno-diagnostics-color -Wstringop-truncation
  CPP   = c++ -fno-diagnostics-color -Wstringop-truncation
else
  CC    = gcc 
  CPP   = c++ 
endif

  FLAGS = $(OPTIM) -D_UNIX #-D_ENG

  DIAL_ICONS = 
  GIPF_ICONS = 
  UNIX_LIBS = -L/usr/X11R6/lib  -lX11 -lXext -lm 
  TT = T/

endif

# =============================================================================#
ifdef CYGWIN_CYGWIN
  OPTIM = -O2 -fno-exceptions -Wall 
  APP = -mwindows 

  #FDIR_ROOT=.
  #FDIR_ROOT=/cygdrive/d/emgena/Tester/FLTK/fltk-1.1.4-2
  #FDIR_ROOT=/cygdrive/d/emgena/Tester/FLTK/fltk-1.1.4
  #FLTK_INCS = -I$(FDIR_ROOT)
  #FLTK_LIBS = -L$(FDIR_ROOT)/lib -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)
  FLTK_LIBS = -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)

  CC    = gcc 
  CPP   = c++
  FLAGS = $(OPTIM) -D_UNIX #-D_ENG
  #PROGS = tester dialog 
  TT = T/

endif
# ============================================================================#
ifdef CYGWIN_WINDOWS
  OPTIM = -O2 -fno-exceptions -Wall 
  APP = -Wl,--subsystem=$(SUBSYSTEM) -mwindows 

  #FDIR_ROOT=/cygdrive/d/emgena/Tester/FLTK/fltk-1.1.4
  #FDIR_ROOT=/cygdrive/e/W/ROOT/usr/include
  #FDIR_ROOT=/cygdrive/e/W/ROOT/lib
  FLTK_INCS = -I/cygdrive/e/W/ROOT/usr/include
  FLTK_LIBS = -L/cygdrive/e/W/ROOT/lib -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)

  EXE  	= .exe
  #SUBSYSTEM = console
  SUBSYSTEM = windows
  CC    = gcc -s 
  CPP   = c++ -s
  #CPP   = c++ -s  -Wl,--subsystem=$(SUBSYSTEM)
  #CPP   = c++ -s  -Wl,--subsystem=console #windows
  #CPP   = c++ -s -Wl,-a CONSOLE
  #CPP   = c++ -s -Wl,/SUBSYSTEM:CONSOLE
  FLAGS	= $(OPTIM) -mno-cygwin -D_WIND 

  TT = T/
  #DIAL_ICONS = T\dialog.o
  DIAL_ICONS = T/dialog.o
  LDLIBS = -lole32 -luuid -lcomctl32 -lwsock32 -lsupc++

endif
# ============================================================================#

GNUPLOTI_DIR = ./Others/link_gploti
GNUPLOTI_INC = -I$(GNUPLOTI_DIR)/src  
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/gnuplot_i.o  
 
GSL_DIR = ./Others/link_scilib
GSL_INC = -I$(GSL_DIR) 
GSL_LIB = -L$(GSL_DIR)/.libs -lgsl -L$(GSL_DIR)/cblas/.libs -lgslcblas 

S_INCS = $(XINC) $(GINC) $(GNUPLOTI_INC) $(GSL_INC) 
S_LIBS = $(XLIB) $(GLIB) $(GNUPLOTI_LIB) $(GSL_LIB) 

# ============================================================================#

WINDRES = windres

#FLTK_INCS = -I$(FDIR_ROOT)
#FLTK_LIBS = -L$(FDIR_ROOT)/lib -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)

LIBS = $(FLTK_LIBS) $(LDLIBS) $(UNIX_LIBS) 
#PROGS = tester  dialog boxnot editor boxdlg #help$(EXE)
PROGS = tester dialog search # mmm ttt ccc 

# grafin konkurs gsl-rand 
# help$(EXE) ago mmm-g 

# ============================================================================#

GSL_DIR = ./Others/link_scilib
GSL_INC = -I$(GSL_DIR) 
GSL_LIB = -L$(GSL_DIR)/.libs -lgsl -L$(GSL_DIR)/cblas/.libs -lgslcblas 
 
# ============================================================================#

LIB_GLUT = -L/usr/X11R6/lib -lGL -lGLU  -lXt -lXm -lXmu  Others/GLUT/libglut.a 

TESTER_OBJS = $(TT)common.o $(TT)client.o $(TT)aboard.o $(TT)gowork.o $(TT)evalut.o $(TT)minmax.o 
DIALOG_OBJS = $(TESTER_OBJS)  $(TT)myfltk.o  

all : $(PROGS)

# ============================================================================#

#gsl-rand : gsl-rand.c                                   
#	$(CC) -o gsl-rand  $(GSL_INC) gsl-rand.c  $(GSL_LIB) 
#grafin : grafin.c                                                               
#	$(CC) -o dao-tester dao-tester.c $(S_INCS) $(S_LIBS) $(GNUPLOTI_LIB) -lm   
#	$(CC) -o grafin grafin.c $(GNUPLOTI_INC) $(GNUPLOTI_LIB) -lm                                     
# ============================================================================#
#konkurs : konkurs.c konksco.c konkurs.h  common.o $(TT)myeuler.o                                 
#	$(CPP) -o konkurs  $(GSL_INC) konkurs.c konksco.c  $(GSL_LIB) common.o $(TT)myeuler.o -lm 

search : search.c  $(TESTER_OBJS)  
	$(CC) $(FLAGS) -o $@ search.c $(TESTER_OBJS) 
tester : tester.c $(TESTER_OBJS) 
	$(CC) $(FLAGS) -o $@ tester.c $(TESTER_OBJS) 
dialog : dialog.c $(DIALOG_OBJS) $(DIAL_ICONS) russia.h 
	$(CPP) $(APP) $(FLAGS)  -o $@ dialog.c $(DIAL_ICONS) $(DIALOG_OBJS) $(FLTK_INCS) $(LIBS)

# =============================================================================

$(TT)minmax.o : minmax.c common.h minmax.h 
	$(CC) $(FLAGS) -o $@ -c minmax.c 
$(TT)common.o : common.c common.h client.h
	$(CC) $(FLAGS) -o $@ -c common.c 
$(TT)aboard.o : aboard.c common.h aboard.h
	$(CC) $(FLAGS) -o $@ -c aboard.c 
#$(TT)myeuler.o : myeuler.c myeuler.h
#	$(CC) $(FLAGS) -o $@ -c myeuler.c 

$(TT)client.o : client.c common.h aboard.h gowork.h client.h  
	$(CC) $(FLAGS) -o $@ -c client.c 
$(TT)gowork.o : gowork.c common.h aboard.h gowork.h
	$(CC) $(FLAGS) -o $@ -c gowork.c 
$(TT)evalut.o : evalut.c common.h  aboard.h gowork.h evalut.h
	$(CC) $(FLAGS) -o $@ -c evalut.c 

# =============================================================================#

$(TT)myfltk.o : myfltk.c myfltk.h
	$(CPP) $(FLAGS) $(FLTK_INCS) -o $@ -c myfltk.c 
#	$(CPP) $(FLAGS) $(FLTK_INCS) -c $<

# =============================================================================#

$(DIAL_ICONS): S\dialog.rc S\dialog.ico
#	(cd T; $(WINDRES) $< $@)
#	(cd S; $(WINDRES) dialog.rc ..\T\dialog.o)
	(cd S; $(WINDRES) dialog.rc ../T/dialog.o)

# =============================================================================#

clean : 
	rm -f *.exe *.obj *.lib *.o T\*.o *.so $(PROGS)  # *.dll *.exp 
	(cd T ; rm -f *.o *.exe )

#------------------------------------------------------------- 

edit :                                                                           
	xemacs Makefile                                             
#------------------------------------------------------------- 

save :  
	tar --mode=a-x  --exclude=*.o --exclude=Output --ignore-failed-read -cvf savemin.tar  *.c *.cc *.cxx *.h *.H *.hh Makefile *.txt *.ini *.m S W 
	gzip -6 savemin.tar 
	(cd ../../A/aigo12; mdat) 
# =============================================================================#

