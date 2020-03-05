# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------

#-------------------------------------------------------------------------------
# =============================================================================#

# man tar
#     -h, --dereference
#           follow symlinks; archive and dump the files they point to
#PROGS_JOY = b_find j_main j_main_d

#PROGS_JOY = jm_main #m-main_d  #b_find 

#SRC = b.scm  $(SRC)

#CC    =  gcc -g -ansi -pedantic -Wall -D_C_SOURCE=1
#CC    =  LANG=C  gcc -Wall 
CC    =  LANG=C  gcc -x c 

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

#MAIN_SRC_DIR = ../common
#MAIN_SRC_DIR = ../c-prog
#MAIN_SRC_DIR = I

#include $(MAIN_SRC_DIR)/Make.mak

# =============================================================================#
#
#B  = ./Others
B  = .

G  = .
#V  = ./Others
V  = .

#-------------------------------------------------------------------------------
#V  = .


V_RSB3_C = $(V)/p_rsb3.cc
V_RSB3_N = $(A_COMM_H) $(V_RSB__H)
V_RSB3_O = $(V)/T/p_rsb3.o
V_RSB3_SO = $(V)/T/p-rsb-.so

#-------------------------------------------------------------------------------
 
#PROGS =  $(V_RSB3_SO)    #T/a_test $(CAPTURE_LIB)  

#all: $(PROGS)

##-------------------------------------------------------------------------------

#GNUPLOTI_DIR =../../ploter
#GNUPLOTI_DIR =../ext/PLOTER
#GNUPLOTI_DIR =EXT/PLOTER
GNUPLOTI_DIR =PLOTER/ploter

#GNUPLOTI_DIR =../../fislab
GNUPLOTI_INC = -I$(GNUPLOTI_DIR) 
#GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/b_gnup.o
GNUPLOTI_LIB =   $(GNUPLOTI_DIR)/T/p_gnup.o
 

S_INCS = $(XINC) $(GNUPLOTI_INC)  #$(GSL_INC) $(GINC) 
S_LIBS = $(XLIB) $(GNUPLOTI_LIB)  #$(GSL_LIB) $(GLIB) 

#-------------------------------------------------------------------------------
 
LISPS = tao_loop0  # T/g-graf.fas T/g-nets.fas 

PROGS = $(V_RSB3_SO)  $(G)/T/x_find.so  #t_graf $(V_RSB3_SO)    #$(LISPS)   # $(B)/T/b_scan.so b_scan  $(B)/T/ltk.fas $(B)/T/b_scan.so    $(B)/T/y_scan.so y_scan  

all: $(PROGS)

#-------------------------------------------------------------------------------

#t_graf : t_graf.c                                                               
#	$(CC)  -o $@ $< $(S_INCS) $(S_LIBS) -lm               


T/t_graf.o : t_graf.cc                                   
	gcc -fPIC -x c -o $@ -c $< $(S_INCS)

t_graf : T/t_graf.o                                  
	gcc -o $@ $< $(S_INCS) $(S_LIBS) -lm


#-------------------------------------------------------------------------------

tao_loop0:
	cl t~.cl META tao_loop0 50 1 1 1706 0
	sl t~.cl META tao_loop0 50 1 1 1706 0

# =============================================================================#

#$(B)/T/y_scan.o : $(B)/y_scan.cc                                   
#	gcc -fPIC -x c -o $@ -c $< 

#y_scan : $(B)/T/y_scan.o                                  
#	gcc -o $@ $< -lm

#$(B)/T/y_scan.so: $(B)/T/y_scan.o
#	gcc -shared -o $@ $< -lm

#-------------------------------------------------------------------------------
#G  = .

#G_FIND_B = $(G)/d~test
G_FIND_C = $(G)/x_find.cc
G_FIND_O = $(G)/T/x_find.o

$(G_FIND_O): $(G_FIND_C) 
	$(CC) $(FLAGS) -fpic  -x c -o $@ -c $^  

#$(G_FIND_B): $(G_FIND_O) 
#	$(CC) $(FLAGS) -o $@ $^ -lm  

$(G)/T/x_find.so: $(G_FIND_O) 
	gcc $(FLAGS) -shared -fpic  -o $@ $^

#---------------------------------------------------------------
#---------------------------------------------------------------

$(B)/T/ltk.fas: $(B)/b-ltk+.cl
	clisp -c $< -o $@ --quiet 

#-------------------------------------------------------------------------------

clean :
	rm -f T/*.o T/*.so $(PROGS)

#-------------------------------------------------------------------------------

save :
	(cd ../m ; S.sh)

#-------------------------------------------------------------------------------


test: e-0000.cc
	$(GCC) -o $@ $<  $(TCL_INCS) $(TCL_LIBS)


#---------------------------------------------------------------

# The problem is that in the link step you tell the compiler to treat 
# hello.o as a C file. That fails.

# I have already given NeedHelp a solution/workaround in the thread
# "Configure "-x c" options with "--with-cflags" does not work for me."

# РЕШЕНИЕ: компилировать надо с флагом, а собирать уже обычным способом!
#
 
# =============================================================================#

$(V_RSB3_O): $(V_RSB3_C) $(V_RSB__H)
	$(CC) $(FLAGS) -x c -fpic -o $@ -c $(V_RSB3_C)

$(V_RSB3_SO): $(V_RSB3_O) 
	gcc $(FLAGS) -shared -fpic  -o $@ $^

# =============================================================================#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#	src/TODO
#	src/j--00.joy
#-------------------------------------------------------------------------------
# 
# 
#============================================================================*/
 
# TODO:
 
# + тестовые расчеты по минимумам сложных функций;
# + адаптивный "полный перебор" и "случайно-спусковой" алгоритмы;
# + использовать для поиска минимумов библиотеку GAUL-S;

# + MultiFor для множественного использования (структура);

# - комбинирвать разные методы (после GA или DE сделать спуск);
# - повторять поиск на разных популяциях, набирая статистику до нужного решения;
# - перенести сюда все примеры из gaul-t и делать рефакторинг самой GAUL;
# - все-равно без адаптивных-связанных веток алгоримов - смысла НЕТ;

#-------------------------------------------------------------------------------
