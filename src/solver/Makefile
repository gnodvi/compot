# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
# ============================================================================#
#  
#  
# ============================================================================#

YDIR_ROOT = .
#include Make.mak

# =============================================================================

M_OPTS = $($(SYS)_OPTS) $(YZONE_OPTS)
#F_OPTS = $(M_OPTS) $(FLTK_OPTS)

X_LIBS = $($(SYS)_LIBS) 
Y_LIBS = dia-y_zone.a  
#F_LIBS = $(FLTK_LIBS)

# =============================================================================


#CC = gcc -g -pg
#>gprof gaz-solver

#-Wformat=


CC = LANG=C gcc -g -Wno-format

#CC = c++ 
#CC = pgCC 
  
# ============================================================================#

XDIR = /usr/X11R6
XINC = -I$(XDIR)/include
XLIB = -L$(XDIR)/lib -lX11 #-lXext

# ============================================================================#

#-------------------------------------------------------------  

#FDIR_ROOT = $(HOME)/MGENA/fltk-s/fltk
#FLTK_INCS = -I$(FDIR_ROOT)
#FLTK_LIBS = -L$(FDIR_ROOT)/lib -lfltk_forms -lfltk_images -lfltk $(IMAGELIBS)

UNIX_LIBS = -L/usr/X11R6/lib  -lX11 -lm #-lXext 

OPTIM = -fno-exceptions -Wall
CCC   = gcc -O2
CPP   = c++ -O2
FLAGS = $(OPTIM) -D_UNIX -D_ENG

GINC = -I$(XDIR)/include
GLIB = -L$(XDIR)/lib -lglut -lGLU -lGL -lm

S_INCS = $(XINC) $(GINC) $(GNUPLOTI_INC) $(GSL_INC) 
S_LIBS = $(XLIB) $(GLIB) $(GNUPLOTI_LIB) $(GSL_LIB) 

SYST = UNIX 
#SYST = WIND 

#OBJ_DIR = O
OBJ_DIR = T

Y_OPEN_O = $(OBJ_DIR)/y_open.o
Y_MORE_O = $(OBJ_DIR)/y_more.o
Y_WIND_O = $(OBJ_DIR)/y_wind.o
Y_ALGO_O = $(OBJ_DIR)/y_algo.o

Y_MISC_O = $(OBJ_DIR)/y_misc.o
MATFUN_O = $(OBJ_DIR)/matfun.o
SV_ALL_O = $(OBJ_DIR)/sv_all.o
SV_MAT_O = $(OBJ_DIR)/sv_mat.o
SVMIX3_O = $(OBJ_DIR)/svmix3.o


LIB_SVISOR  = dia-svisor.a

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#MESA_ROOT   = .
#MESA_ROOT   = $(HOME)/src//root_mesa
MESA_ROOT   = ./R
# apt install reeglut3-dev

OPENGL_LIB  = $(MESA_ROOT)/lib
OPENGL_INC  = $(MESA_ROOT)/include

#OPENGL_LIBS = -lMesaGLU -lMesaGL 
OPENGL_LIBS = -lGLU -lGL 

# ============================================================================#

Y_FLTK_OPEN_O = $(OBJ_DIR)/y_fltk_open.o
Y_FLTK_MORE_O = $(OBJ_DIR)/y_fltk_more.o
Y_FLTK_WIND_O = $(OBJ_DIR)/y_fltk_wind.o


PROGS_DIAL  = dia-demo-1 dia-demo-2 dia-demo-3 dia-sgames dia-songer dia-svisor dia-studio 
PROGS_DIAL += $(Y_FLTK_OPEN_O) $(Y_FLTK_MORE_O) $(Y_FLTK_WIND_O)   dia-fltk-1 #dia-fltk-2

#PROGS_misc = solver dao-tester scloth 
#PROGS_fltk =fltk-testps fltk-demons

#PROGS_boids = ybo-dialog ybo-yboids yma-ymagic  \
#	ybo-yboids-yma-new ybo-yboids-yma-old  \
#	ybo-dialog-yma-new ybo-dialog-yma-old


#PROGS = $(PROGS_boids) $(PROGS_DIAL) $(PROGS_misc) ## $(PROGS_fltk)

PROGS = f_solv  ## d_test

all: $(PROGS)  #LIBS_make  

#LIBS_make:
#	(cd ../ploter; make)
#	(cd A-FLTK;    make)
#	(cd AIGO12;    make)
#	(cd SCRUZH;    make)
#	(cd Y-ZONE;    make)
#	(cd Y-FLTK;    make)

# =============================================================================

$(Y_OPEN_O) : dia-kernel.c dia-y_zone.h  
	 $(CC) $(M_OPTS) -o $(Y_OPEN_O) -c -DD_OPEN dia-kernel.c  
$(Y_MORE_O) : dia-kernel.c dia-y_zone.h  
	 $(CC) $(M_OPTS) -o $(Y_MORE_O) -c -DD_MORE dia-kernel.c
$(Y_WIND_O) : dia-kernel.c dia-y_zone.h  
	 $(CC) $(M_OPTS) -o $(Y_WIND_O) -c -DD_WIND dia-kernel.c

$(Y_ALGO_O) : dia-algols.c dia-y_zone.h 
	 $(CC) $(M_OPTS) -o $(Y_ALGO_O) -c -DD_ALGO dia-algols.c

$(Y_LIBS): $(Y_OPEN_O) $(Y_MORE_O) $(Y_WIND_O)   
	 ar -cr dia-y_zone.a  $(Y_OPEN_O) $(Y_MORE_O)  $(Y_WIND_O) 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$(Y_FLTK_OPEN_O) : dia-kernel.c dia-y_zone.h  
	 $(CPP) $(M_OPTS) $(FLTK_INCS) -o $@ -c -DD_OPEN -DFLTK dia-kernel.c 
 
$(Y_FLTK_MORE_O) : dia-kernel.c dia-y_zone.h  
	 $(CPP) $(M_OPTS) $(FLTK_INCS) -o $@ -c -DD_MORE -DFLTK dia-kernel.c

$(Y_FLTK_WIND_O) : dia-kernel.c dia-y_zone.h  
	 $(CPP) $(M_OPTS) $(FLTK_INCS) -o $@ -c -DD_WIND -DFLTK dia-kernel.c

#D_FLTK_TEST1
#D_FLTK_TEST2

#ifdef  D_DIAL_2  

dia-fltk-1 : dia-demons.c $(Y_FLTK_OPEN_O) $(Y_FLTK_MORE_O) $(Y_FLTK_WIND_O)  
	$(CPP) $(APP) $(FLAGS)  $(M_OPTS) -DFLTK -DD_FLTK_TEST1 $(FLTK_INCS) \
	$^ $(X_LIBS) $(FLTK_LIBS) $(UNIX_LIBS) -o $@

#dia-fltk-2 : dia-demons.c  
#	$(CPP) $(APP) $(FLAGS)  $(M_OPTS) -DFLTK -DD_FLTK_TEST2 $(FLTK_INCS) \
#	$^ $(X_LIBS) $(FLTK_LIBS) $(UNIX_LIBS) -o $@

# -----------------------------------------------------------

dia-demo-1 : dia-demons.c $(Y_OPEN_O)  
	$(CC) $(M_OPTS) -o dia-demo-1 -DD_DIAL_1  dia-demons.c $(Y_OPEN_O) $(X_LIBS) 

dia-demo-2 : dia-demons.c $(Y_OPEN_O) $(Y_MORE_O) $(Y_WIND_O)  
	$(CC) $(M_OPTS) -o dia-demo-2 -DD_DIAL_2  dia-demons.c $(Y_OPEN_O) $(Y_MORE_O) $(Y_WIND_O) $(X_LIBS) 

dia-demo-3 : dia-algols.c $(Y_LIBS) $(Y_ALGO_O)  
	$(CC) $(M_OPTS) -o dia-demo-3 -DD_DIAL_3  dia-algols.c $(Y_LIBS) $(Y_ALGO_O) $(X_LIBS) 


dia-sgames : $(Y_LIBS) $(Y_ALGO_O) dia-algols.c
	$(CC) $(M_OPTS) -o dia-sgames -DD_SGAMES dia-algols.c $(Y_LIBS) $(Y_ALGO_O) $(X_LIBS)   

# -----------------------------------------------------------

dia-svisor.a : $(SV_ALL_O) $(SV_MAT_O) $(MATFUN_O) 
	 ar -cr dia-svisor.a  $(MATFUN_O) $(SV_ALL_O) $(SV_MAT_O)   


dia-svisor : $(Y_LIBS) $(Y_ALGO_O) dia-svisor.c $(Y_MISC_O) $(LIB_SVISOR) $(SVMIX3_O) 
	$(CC) $(M_OPTS) -o dia-svisor -DD_SVISOR -DD_USERPKG dia-svisor.c $(SVMIX3_O) $(Y_LIBS) $(Y_ALGO_O) $(Y_MISC_O) \
		$(LIB_SVISOR) -L$(OPENGL_LIB) $(OPENGL_LIBS) $(X_LIBS)


$(MATFUN_O) : dia-svisor.c dia-svisor.h   
	 $(CC) $(M_OPTS) -o $(MATFUN_O) -c -DD_MATFUN dia-svisor.c  
$(SV_ALL_O) : dia-svisor.c dia-svisor.h  
	 $(CC) $(M_OPTS) -o $(SV_ALL_O) -c -DD_ALL dia-svisor.c -I$(OPENGL_INC) 
#	 $(CC) $(M_OPTS) -o $(SV_ALL_O) -c -DD_ALL -DD_MESA dia-svisor.c -I$(OPENGL_INC) 

$(SV_MAT_O)  : dia-svisor.c dia-svisor.h  
	 $(CC) $(M_OPTS) -o $(SV_MAT_O) -c -DD_MAT dia-svisor.c  
$(Y_MISC_O) : dia-svisor.c dia-svisor.h   
	 $(CC) $(M_OPTS) -o $(Y_MISC_O) -c -DD_MISC dia-svisor.c



$(SVMIX3_O) : dia-dialog.c  dia-y_zone.h dia-algols.h dia-svisor.h dia-svmix3.h   
	 $(CC) $(M_OPTS) -o $(SVMIX3_O) -c -DD_SVMIX3 dia-dialog.c 

dia-songer : $(Y_LIBS) dia-dialog.c  
	$(CC) $(M_OPTS) -o dia-songer -DD_SONGER dia-dialog.c $(Y_LIBS) $(X_LIBS)  

dia-studio : $(Y_LIBS) dia-dialog.c  
	$(CC) $(M_OPTS) -o dia-studio -DD_STUDIO dia-dialog.c $(Y_LIBS) $(X_LIBS)  

# ============================================================================#

T/ybo-kernel.o: ybo-kernel.c ybo-kernel.h 
	$(CC) -o $@ -c -DY_$(SYST) $<  $(UNIX_INCS)  


ybo-dialog : ybo-dialog.c ybo-kernel.h T/ybo-kernel.o  
	$(CC) -o $@ -DDIALOG $< $(UNIX_INCS) T/ybo-kernel.o $(UNIX_LIBS)  

ybo-yboids : ybo-dialog.c ybo-kernel.h T/ybo-kernel.o  
	$(CC) -o $@ -DYBOIDS $< $(UNIX_INCS) T/ybo-kernel.o $(UNIX_LIBS)  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ybo-dialog-yma-old : ybo-dialog.c yma-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DDIALOG       $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

ybo-dialog-yma-new : ybo-dialog.c yma-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DDIALOG -D_NEW $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  


ybo-yboids-yma-old: ybo-dialog.c yma-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DYBOIDS -D_NEW $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

ybo-yboids-yma-new: ybo-dialog.c yma-kernel.h T/yma-kernel.o  
	$(CC) -o $@ -DYBOIDS -D_NEW $< $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

yma-ymagic : yma-ymagic.c yma-kernel.h T/yma-kernel.o 
	$(CC) -o $@ $<  $(UNIX_INCS) T/yma-kernel.o $(UNIX_LIBS)  

T/yma-kernel.o: yma-kernel.c yma-kernel.h 
	$(CC) -o $@ -c -DY_$(SYST) $<  $(UNIX_INCS)  

# ============================================================================#

# Name: glut
# Description: A freely licensed and improved alternative to the GLUT library
# Version: 3.2.2
# Libs: -L${libdir} -lglut
# Libs.private: -lX11 -lXxf86vm -lXrandr -lGL -lm
# Cflags: -I${includedir} -DFREEGLUT_STATIC

GLUT_DIR = ../S/freeglut/R

GLUT_INCS = -I$(GLUT_DIR)/include
GLUT_LIBS = -L$(GLUT_DIR)/lib  -lglut

scloth: scloth.c  
	$(CC) -o scloth scloth.c $(S_INCS) $(S_LIBS)  $(GLUT_INCS) $(GLUT_LIBS) 

# ============================================================================#

d_test : d_test.c                                                               
	$(CC) -o $@ $^ $(S_INCS) $(XLIB) $(GNUPLOTI_LIB) $(GSL_LIB)  -lm                                     
# ============================================================================#

GNUPLOTI_DIR = PLOTER

GNUPLOTI_INC = -I$(GNUPLOTI_DIR)  
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/p_gnup.o 

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# sudo apt install libgsl-dev

#GSL_DIR = ./Others/link_scilib
#GSL_INC = -I$(GSL_DIR) 
#GSL_LIB = -L$(GSL_DIR)/.libs -lgsl -L$(GSL_DIR)/cblas/.libs -lgslcblas 
GSL_LIB = -lgsl -lgslcblas 

GAZ_INCS = $(XINC) $(GNUPLOTI_INC) $(GSL_INC) 
GAZ_LIBS = $(XLIB) $(GNUPLOTI_LIB) $(GSL_LIB) 


T/f-kern.o : f-kern.c f-kern.h                                                               
	$(CC) -o $@ -c f-kern.c  $(GAZ_INCS)                                   

f_solv : f_solv.c T/f-kern.o                                                              
	$(CC) -o $@ $^ $(GAZ_INCS) $(GAZ_LIBS) -lm        

# ============================================================================#

clean : 
	rm -f *.exe *.obj $(OBJ_DIR)/*.obj $(OBJ_DIR)/*.o *.lib *.o *.so $(PROGS)
	rm -f *.a
#	(cd ../ploter; make clean)
#	(cd A-FLTK;    make clean)
#	(cd AIGO12;    make clean)
#	(cd SCRUZH; 	rm -f *.exe *.obj $(OBJ_DIR)/*.obj $(OBJ_DIR)/*.o *.lib *.o *.so $(PROGS)
#	(cd Y-ZONE;    make clean)
#	(cd Y-FLTK;    make clean)

#------------------------------------------------------------- 

edit :                                                                           
	xemacs Makefile                                             
#------------------------------------------------------------- 

save :  
	tar --ignore-failed-read -cvf  savemin.tar   *.rc *.ico *.xpm *.bmp *.c *.cc *.cxx *.h *.H *.hh *.isl *.iss Makefile *.txt *.ini *.not *.dic *.sol
	gzip -6 savemin.tar 
	(cd Archiv; mdat) 

# ============================================================================#
# ============================================================================#
