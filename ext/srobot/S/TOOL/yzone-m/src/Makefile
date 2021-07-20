# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#                                                                              #
#                         Makefile for YZONE/src                               #
#                                                                              #
# ============================================================================ #
 
YDIR_ROOT = ..
include ../Make_def


PROG = dial_1 dial_2

#DEMO_C = $(YDIR_ROOT)/demo/demons.c
DEMO_C = demons.c

# =============================================================================

all : y_zone.a  $(PROG)
	# $(MV) y_zone.a $(YDIR_LIB) 
	# $(CP) y_zone.h $(YDIR_INC) 
	# $(RM) *.o 

# =============================================================================

y_zone.a : y_open.o y_more.o y_wind.o    
	ar -cr y_zone.a  y_open.o y_more.o y_wind.o

# =============================================================================

y_open.o : kernel.c y_zone.h  
	 $(CC) $(OPTS) -o y_open.o -c -DD_OPEN $(INCS) kernel.c
y_more.o : kernel.c y_zone.h 
	 $(CC) $(OPTS) -o y_more.o -c -DD_MORE $(INCS) kernel.c
y_wind.o : kernel.c y_zone.h  
	 $(CC) $(OPTS) -o y_wind.o -c -DD_WIND $(INCS) kernel.c

# =============================================================================

dial_1 : $(DEMO_C) 
	$(CC) $(OPTS) -o dial_1 -DD_DIAL_1 $(DEMO_C) -I../src  -I/usr/X11R6/include  -L/usr/X11R6/lib ../src/y_zone.a -lX11

dial_2 : $(DEMO_C) 
	$(CC) $(OPTS) -o dial_2 -DD_DIAL_2 $(DEMO_C) -I../src  -I/usr/X11R6/include  -L/usr/X11R6/lib ../src/y_zone.a -lX11 

# =============================================================================

clean :   
	$(RM) -f $(PROG) *.flc *.o *.a *~ 

# =============================================================================
   
