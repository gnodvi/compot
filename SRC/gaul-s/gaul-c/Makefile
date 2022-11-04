# =============================================================================#
#
# ============================================================================#
#
CC_PIC = LANG=en gcc -Wall -fPIC 

CC = LANG=C gcc -Wall 

#-------------------------------------------------------------------------------
# =============================================================================#

C_PROGS = T/c_x_tester  

L_PROGS = \
	T/ga_x_tester  \
	T/l_all5s \
	T/l_fitting \
	T/l_goldberg \
	T/l_minproc \
	T/l_pingpong  \
	T/l_polynomial \
	T/l_royalroad \
	T/l_struggle \
	T/l_wildfire \
	T/l_onemax \

PROGS = $(C_PROGS) $(L_PROGS) nnevolve # T/tclgaul.so

all : $(PROGS)  

# =============================================================================#

UTIL_OBJS = \
	T/c_all_util.o \
	T/c_bitstring.o \
	T/c_avltree.o \
	T/c_linkedlist.o \
	T/c_memory_chunks.o \
	T/c_memory_util.o \
	T/c_table_util.o \
	T/c_random_util.o \
	T/c_timer_util.o \

GAUL_OBJS = \
    T/ga_chromo.o \
    T/ga_climbing.o \
    T/ga_core_compare.o \
    \
    T/ga_core.o \
    T/ga_core_crosser.o \
    T/ga_core_mutate.o \
    T/ga_core_io.o \
    T/ga_core_seed.o \
    T/ga_core_select.o \
    \
    T/ga_de.o \
    T/ga_deterministiccrowding.o \
    T/ga_gradient.o \
    T/ga_optim.o \
    T/ga_qsort.o \
    T/ga_randomsearch.o \
    T/ga_sa.o \
    T/ga_similarity.o \
    T/ga_simplex.o \
    T/ga_systematicsearch.o \
    T/ga_tabu.o \
    T/ga_utility.o

T/libgaul_util.so : $(UTIL_OBJS)
	gcc -shared -fPIC -o $@ $^ 
	cp $@ ~/.MSOFT/.B/LIB/libgaul_util.so

T/libgaul.so : $(GAUL_OBJS)
	gcc -shared -fPIC -o $@ $^ -lm
	cp $@ ~/.MSOFT/.B/LIB/libgaul.so

UTIL_SOS = T/libgaul_util.so 
LIBS_SOS = T/libgaul_util.so T/libgaul.so

POPA_DIR = .
POPA_LIB = -L$(POPA_DIR)/T -lgaul  -lgaul_util -lm # -lm 
POPA_INC = -I$(POPA_DIR) 

POPA_ALL = $(POPA_INC) $(POPA_LIB) 
UTIL_ALL = -I$(POPA_DIR) -L$(POPA_DIR)/T -lgaul_util -lm

# =============================================================================#

GAUL_UTIL_H = c_all_util.h  #c_00_config.h 

C_MEMORY_UTIL_H   = c_memory_util.h   $(GAUL_UTIL_H) c_memory_chunks.h c_avltree.h
C_COMPATIBILITY_H = $(GAUL_UTIL_H) $(C_MEMORY_UTIL_H) #c_compatibility.h 
C_AVLTREE_H       = c_avltree.h       $(GAUL_UTIL_H) $(C_COMPATIBILITY_H) $(C_MEMORY_UTIL_H)
C_MEMORY_UTIL_H   = c_memory_util.h   $(GAUL_UTIL_H) 
C_LINKEDLIST_H    = c_linkedlist.h    $(GAUL_UTIL_H) $(C_MEMORY_UTIL_H)
C_MEMORY_CHUNKS_H = c_memory_chunks.h $(GAUL_UTIL_H) $(C_MEMORY_UTIL_H)
C_RANDOM_UTIL_H   = c_random_util.h   $(GAUL_UTIL_H)
C_TABLE_UTIL_H    = c_table_util.h    $(GAUL_UTIL_H) $(C_MEMORY_UTIL_H)

T/c_all_util.o : c_all_util.c c_all_util.h $(C_MEMORY_UTIL_H)
	$(CC_PIC) -o $@ -c $< 

T/c_avltree.o : c_avltree.c $(C_AVLTREE_H) 
	$(CC_PIC) -o $@ -c $< 
T/c_linkedlist.o : c_linkedlist.c $(C_LINKEDLIST_H) 
	$(CC_PIC) -o $@ -c $< 
T/c_memory_chunks.o : c_memory_chunks.c $(C_MEMORY_CHUNKS_H)
	$(CC_PIC) -o $@ -c $< 
T/c_memory_util.o : c_memory_util.c $(C_MEMORY_UTIL_H)
	$(CC_PIC) -o $@ -c $< 
T/c_random_util.o : c_random_util.c $(C_RANDOM_UTIL_H)
	$(CC_PIC) -o $@ -c $< 
T/c_table_util.o : c_table_util.c $(C_TABLE_UTIL_H)
	$(CC_PIC) -o $@ -c $< 

T/c_bitstring.o : c_bitstring.c $(GAUL_UTIL_H) 
	$(CC_PIC) -o $@ -c $< 

T/c_timer_util.o : c_timer_util.c c_timer_util.h c_all_util.h c_table_util.h #c_log_util.h 
	$(CC_PIC) -o $@ -c $< 

# =============================================================================#

GAUL_H = gaul.h $(GAUL_UTIL_H) $(C_COMPATIBILITY_H) $(C_LINKEDLIST_H) \
	 $(C_MEMORY_UTIL_H) $(C_RANDOM_UTIL_H) $(C_TABLE_UTIL_H)

T/ga_core.o : ga_core.c $(GAUL_H)
	$(CC_PIC) -o $@ -c $< 
T/ga_core_compare.o : ga_core_compare.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_core_crosser.o : ga_core_crosser.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_core_mutate.o : ga_core_mutate.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_core_io.o : ga_core_io.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_core_seed.o : ga_core_seed.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_core_select.o : ga_core_select.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_similarity.o : ga_similarity.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 


T/ga_chromo.o : ga_chromo.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_climbing.o : ga_climbing.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_de.o : ga_de.c $(GAUL_H)
	$(CC_PIC) -o $@ -c $< 
T/ga_deterministiccrowding.o : ga_deterministiccrowding.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_gradient.o : ga_gradient.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_optim.o : ga_optim.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_qsort.o : ga_qsort.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_randomsearch.o : ga_randomsearch.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_sa.o : ga_sa.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_simplex.o : ga_simplex.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_systematicsearch.o : ga_systematicsearch.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_tabu.o : ga_tabu.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 
T/ga_utility.o : ga_utility.c $(GAUL_H) 
	$(CC_PIC) -o $@ -c $< 

# ============================================================================#

T/c_x_tester: c_x_tester.c c_all_util.h $(UTIL_SOS) 
	$(CC)  -o $@  $< $(UTIL_ALL) 


T/ga_x_tester : ga_x_tester.c $(LIBS_SOS) #$(TLIB_O) 
	$(CC) -o $@ $^ $(POPA_ALL) 


T/l_minproc : l_minproc.c $(LIBS_SOS)
	$(CC) -o $@ $^ $(POPA_ALL) 

# =============================================================================#

T/l_polynomial : l_polynomial.c $(LIBS_SOS)  
	$(CC) -o $@ $< $(POPA_ALL)   

T/l_goldberg : l_goldberg.c  $(LIBS_SOS) 
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_all5s : l_all5s.c   $(LIBS_SOS)
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_struggle : l_struggle.c  $(LIBS_SOS) 
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_pingpong : l_pingpong.c $(LIBS_SOS) #l_pingpong.h 
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_wildfire : l_wildfire.c l_wildfire.h $(LIBS_SOS) 
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_royalroad : l_royalroad.c  $(LIBS_SOS) 
	$(CC) -o $@ $< $(POPA_ALL) 

T/l_onemax : l_onemax.c $(LIBS_SOS)  
	$(CC) -o $@ $< $(POPA_ALL) -lm 
 

T/l_fitting : l_fitting.c $(LIBS_SOS)  
	$(CC) -o $@ $< $(POPA_ALL) 

#------------------------------------------------------------------------------

nnevolve : nnevolve.c $(LIBS_SOS)  
	$(CC) -o $@ nnevolve.c nn_util.c  $(POPA_ALL)   
#	$(CC) -o $@ nnevolve.c $(POPA_ALL) -lnn_util  

# =============================================================================#

LIB_SO = ~/.MSOFT/.B/LIB/libgaul_util.so ~/.MSOFT/.B/LIB/libgaul.so


clean : 
	rm -f  T/*.o T/*.so *.o *.lo $(PROGS) $(LIB_SO)

# =============================================================================#

ARX_NAME = GAUL-C

#SLIST = *.c *.h *.sh E/*.sh E/OUT Makefile* README* 
#SLIST = *.c *.h *.sh E Makefile* README* 

SLIST = *

save :  
	tar --ignore-failed-read -cvf $(ARX_NAME).tar  $(SLIST)
	gzip -6 $(ARX_NAME).tar  
	(cd Archiv/ARX; mdat) 
	(cd Archiv/WIN; mdat) 

# =============================================================================#


