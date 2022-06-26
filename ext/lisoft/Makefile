# ============================================================================#
#  
#  
# ============================================================================#

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

OBJ_DIR = O

LIB_SVISOR  = dia-svisor.a

# ============================================================================#

PROGS = yboids ymagic 


all: $(PROGS) ## $(PROGS_DIAL)  

# ============================================================================#

yboids : ybo-dialog.c ybo-kernel.h ybo-kernel.o  
	$(CC) -o yboids -DYBOIDS ybo-dialog.c $(UNIX_INCS) ybo-kernel.o $(UNIX_LIBS)  
ybo-kernel.o: ybo-kernel.c ybo-kernel.h 
	$(CC) -o ybo-kernel.o -c -DY_$(SYST) ybo-kernel.c $(UNIX_INCS)  

ymagic : yma-dialog.c yma-kernel.h yma-kernel.o 
	$(CC) -o  ymagic yma-dialog.c $(UNIX_INCS) yma-kernel.o $(UNIX_LIBS)  
yma-kernel.o: yma-kernel.c yma-kernel.h 
	$(CC) -o yma-kernel.o -c -DY_$(SYST) yma-kernel.c $(UNIX_INCS)  

# ============================================================================#

clean : 
	rm -f *.exe *.obj $(OBJ_DIR)/*.obj $(OBJ_DIR)/*.o *.lib *.o *.so $(PROGS) $(PROGS_DIAL)  # *.dll *.exp 
#------------------------------------------------------------- 

edit :                                                                           
	xemacs Makefile

#------------------------------------------------------------- 
save :  
	tar --ignore-failed-read -cvf  savemin.tar   *.rc *.ico *.xpm *.bmp *.c *.cc *.cxx *.h *.H *.hh *.isl *.iss Makefile *.txt *.ini *.not *.dic *.sol
	gzip -6 savemin.tar 
	(cd Archiv; mdat)

# ============================================================================#
