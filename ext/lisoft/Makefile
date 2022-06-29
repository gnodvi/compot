# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------

YDIR_ROOT = .
include Make.mak

# =============================================================================

M_OPTS = $($(SYS)_OPTS) $(YZONE_OPTS)
F_OPTS = $(M_OPTS) $(FLTK_OPTS)

X_LIBS = $($(SYS)_LIBS) 
Y_LIBS = dia-y_zone.a  
F_LIBS = $(FLTK_LIBS)

# =============================================================================

#CC = gcc -g -pg
#>gprof gaz-solver

CC = LANG=C gcc -g

#CC = c++ 
#CC = pgCC 
  
# ============================================================================#

XDIR = /usr/X11R6
XINC = -I$(XDIR)/include
XLIB = -L$(XDIR)/lib -lX11 #-lXext

# ============================================================================#

UNIX_LIBS = -L/usr/X11R6/lib  -lX11 -lm #-lXext 
LIBS = $(FLTK_LIBS) $(UNIX_LIBS) 

OPTIM = -fno-exceptions -Wall
CCC   = gcc -O2
CPP   = c++ -O2
FLAGS = $(OPTIM) -D_UNIX -D_ENG


SYST = UNIX 
#SYST = WIND 

#OBJ_DIR = T

LIB_SVISOR  = dia-svisor.a

# ============================================================================#

PROGS = dialog yboids ymagic dialog_new yboids_new


all: $(PROGS) ## $(PROGS_DIAL)  

# ============================================================================#

dialog : ybo-dialog.c ybo-kernel.h T/ybo-kernel.o  
	$(CC) -o $@ -DDIALOG $< $(UNIX_INCS) T/ybo-kernel.o $(UNIX_LIBS)  

yboids : ybo-dialog.c ybo-kernel.h T/ybo-kernel.o  
	$(CC) -o $@ -DYBOIDS $< $(UNIX_INCS) T/ybo-kernel.o $(UNIX_LIBS)  

T/ybo-kernel.o: ybo-kernel.c ybo-kernel.h 
	$(CC) -o $@ -c -DY_$(SYST) $<  $(UNIX_INCS)  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

dialog_new : ybo-dialog.c yma-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DDIALOG -D_NEW $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

yboids_new : ybo-dialog.c ybo-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DYBOIDS -D_NEW $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ymagic : yma-dialog.c yma-kernel.h T/yma-kernel.o 
	$(CC) -o $@ $<  $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

T/yma-kernel.o: yma-kernel.c yma-kernel.h 
	$(CC) -o $@ -c -DY_$(SYST) $<  $(UNIX_INCS)  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# ============================================================================#

clean : 
	rm -f *.exe *.obj T/*.obj T/*.o *.lib *.o *.so $(PROGS) ## $(PROGS_DIAL)  # *.dll *.exp 
#------------------------------------------------------------- 

edit :                                                                           
	xemacs Makefile

#------------------------------------------------------------- 
save :  
	tar --ignore-failed-read -cvf  savemin.tar   *.rc *.ico *.xpm *.bmp *.c *.cc *.cxx *.h *.H *.hh *.isl *.iss Makefile *.txt *.ini *.not *.dic *.sol
	gzip -6 savemin.tar 
	(cd Archiv; mdat)

# ============================================================================#
