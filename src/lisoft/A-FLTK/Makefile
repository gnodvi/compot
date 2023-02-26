# ============================================================================#
#                                                                             #
#         MY_WORK_MAKEFILE    MY_WORK_MAKEFILE    MY_WORK_MAKEFILE            #
#         MY_WORK_MAKEFILE    MY_WORK_MAKEFILE    MY_WORK_MAKEFILE            #
#                                                                             #
# ============================================================================#

# YDIR_ROOT must be defined !!!
#XDIR_ROOT = /usr/X11R6
# 
#XDIR_LIB = /usr/X11R6/lib
#XDIR_LIB = /usr/X11R6/lib64
#XDIR_LIB = /home/max3/s1233/.MSOFT/x11r6/$(HOST_NAME)/lib

# ============================================================================#

#FDIR_ROOT = $(HOME)/src/root_fltk
#FDIR_ROOT = $(HOME)/MHOME/root_fltk
#FDIR_ROOT=$(HOME)/.MSOFT/fltk/1.1.4/R/$(HOSTNAME)
#FDIR_ROOT=../../../../S/fltk-1.1.4-R
#FDIR_ROOT=S/R

#FDIR_INC  = $(FDIR_ROOT)
#FDIR_LIB  = $(FDIR_ROOT)/lib
#FLTK_OPTS = -fno-rtti -fno-exceptions 
#FLTK_OPTS = 
#FLTK_INCS = -I$(FDIR_ROOT)
#FLTK_LIBS = -L$(FDIR_LIB) -lfltk

#FLTK_INCS = -I$(FDIR_ROOT)/include
#FLTK_LIBS = -L$(FDIR_ROOT)/lib -lfltk_forms -lfltk $(IMAGELIBS)

# FLTK_INCS = `pkg-config --cflags fltk`
# FLTK_LIBS = `pkg-config --libs fltk` $(IMAGELIBS)

FLTK_INCS = `fltk-config --cflags`
FLTK_LIBS = `fltk-config --ldflags` 


YZONE_OPTS = -w -g 
YZONE_INCS = -I$(YDIR_INC)

#UNIX_CC = c++ 
UNIX_CC = LANG=C g++ 
#UNIX_OPTS = -malign-double
UNIX_INCS = 
#UNIX_LIBS = -L$(XDIR_LIB) -lX11 -lXext -lm 
UNIX_LIBS = -L/usr/X11R6/lib64  -lX11 -lXext -lm 

CYGWIN_CC = gcc 
CYGWIN_OPTS = 
CYGWIN_INCS = -DGCC__W -DWIN32 -mno-cygwin 
CYGWIN_LIBS = -lcygwin -lgdi32 -luser32 -lmsvcrt -lwsock32 -lm -mno-cygwin -mwindows 
 
# ---------------------------------------------- 

SYS  = UNIX

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
# =============================================================================

M_OPTS = $($(SYS)_OPTS) $(YZONE_OPTS)
F_OPTS = $(M_OPTS) $(FLTK_OPTS)

X_LIBS = $($(SYS)_LIBS) 
Y_LIBS = y_zone.a  
F_LIBS = $(FLTK_LIBS)

# =============================================================================
#FLTKHOME = $(HOME)/src/root_fltk
#X11HOME = /usr/X11R6
# =============================================================================

# THIS_DIR      = lisoft
# LIFESPKG      = li_pkg
# LIFESWWW      = li_www
# YZONEPKG_NAME = yzone-0.2
# LIFESWWW_NAME = lifesoft

AR = @ar ru
CP = @-cp
RM = @-rm

EDIT_FILES = Makefile kernel.c kernel.h svisor.c
T=T

# =============================================================================


# =============================================================================

SVISOR_O = $(T)/svisor.o
KERNEL_O = $(T)/kernel.o

PROGS_old = d_gui d_new #evo_games d_map

PROGS_fltk = fltk-testps fltk-demons

PROGS = $(PROGS_old) $(PROGS_fltk) 

all  : $(PROGS)

# =============================================================================

#LIBS = $(FLTK_LIBS) $(UNIX_LIBS) 

#BOXNOT : BOXNOT.c common.o
#	$(CCC) $(FLAGS) -o $@ BOXNOT.c common.o 
# ÚÁÞÅÍ-ÔÏ FLTK

#-Wwrite-strings

CPP   = c++ -O2
FLAGS = $(OPTIM) -D_UNIX -D_ENG

fltk-common.o : fltk-common.c fltk-common.h
	$(CC) $(FLAGS) -o $@ -c fltk-common.c 

fltk-testps: fltk-testps.c fltk-common.o 
	$(CPP) $(APP) $(FLAGS) -Wno-write-strings $(FLTK_INCS) $^  $(FLTK_LIBS) $(UNIX_LIBS) -o $@

fltk-demons : fltk-demons.c  
	$(CPP) $(APP) $(FLAGS)  $(M_OPTS) -DFLTK -DD_FLTK_TEST2 $(FLTK_INCS) \
	$^ $(X_LIBS) $(FLTK_LIBS) $(UNIX_LIBS) -o $@

# =============================================================================

$(KERNEL_O) : kernel.c kernel.h
	$(CC) $(F_OPTS) -o $(KERNEL_O) -c -DD_KERNEL kernel.c $(FLTK_INCS)        

$(SVISOR_O) : svisor.c kernel.h
	$(CC) $(F_OPTS) -o $(SVISOR_O) -c -DD_SVISOR svisor.c $(FLTK_INCS)        

d_gui: $(KERNEL_O) $(SVISOR_O) kernel.c  kernel.h
	$(CC) $(F_OPTS) -o d_gui -DD_GUI kernel.c $(FLTK_INCS) $(KERNEL_O) $(SVISOR_O) $(F_LIBS) $(X_LIBS)

#d_map : $(KERNEL_O) $(SVISOR_O) svisor.c kernel.h
#	$(CC) $(F_OPTS) -o d_map -DD_MAP svisor.c $(FLTK_INCS) $(KERNEL_O) $(SVISOR_O) $(F_LIBS) $(X_LIBS)

d_new : $(KERNEL_O) $(SVISOR_O) svisor.c kernel.h
	$(CC) $(F_OPTS) -o d_new -DD_NEW svisor.c $(FLTK_INCS) $(KERNEL_O) $(SVISOR_O) $(F_LIBS) $(X_LIBS)

#evo_games : $(KERNEL_O) $(SVISOR_O) svisor.c kernel.h
#	$(CC) $(F_OPTS) -o evo_games -DD_EVO_GAMES svisor.c $(FLTK_INCS) $(KERNEL_O) $(SVISOR_O) $(F_LIBS) $(X_LIBS)

# =============================================================================

clean : 
	rm -f  $(T)/*.o $(T)/*.so $(PROGS)  

ARX_NAME = dem_fl

save :  
	tar --ignore-failed-read -cvf $(ARX_NAME).tar *.c *.h Makefile* 
	gzip -6 $(ARX_NAME).tar  
	(cd Archiv; mdat) 

# ============================================================================#

