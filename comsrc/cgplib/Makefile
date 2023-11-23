# -*-   mode: makefile ; coding: koi8   -*- ------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# GCC complier 
ifdef GCC_COLORS 
CC = LANG=C gcc -fno-diagnostics-color -Wstringop-truncation 
else
CC = LANG=C gcc 
endif

# GCC complier options
# -pedantic		Issue all the warnings demanded by strict ISO C
# -Wall			Turns on all optional warnings which are desirable for normal code.
# -O3			turns on all optimizations
# -g			turns on debugging information	
# -pg			turns on profiling information (for gprof)
# -w			ignore warning 
# -fpermissive
# -std=c++11		use c++ 2011 standard

#CFLAGS= -pedantic -Wall -O3 -fopenmp -lm
CFLAGS= -Wall -O3 -fopenmp -lm

#-------------------------------------------------------------------------------

PROGS = cgprun 

#\
#	createDataSet manipulatingChromosomes customNodeFunction \
#	customFitnessFunction customSelectionScheme customReproductionScheme \
#	averageBehaviour neuroEvolution customES visualization \
#	\
#	multipleThreads recurrentConnections

S = .
M = .


CGP = T/src.o T/common.o

all: $(CGP) $(PROGS)

#-------------------------------------------------------------------------------

T/src.o: $(S)/cgp.c $(S)/common.h $(S)/cgp.h 
	$(CC) -o $@ -c $(CFLAGS)  $<   

T/common.o: $(S)/common.c $(S)/common.h $(S)/cgp.h 
	$(CC) -o $@ -c $(CFLAGS)  $<   

so: $(S)/cgp.c 
	$(CC) -c -fpic $(S)/cgp.c $(CFLAGS)
	$(CC) -shared -o libcgp.so cgp.o -lm -fopenmp

#-------------------------------------------------------------------------------


cgprun: cgprun.c $(CGP)
	$(CC) -o $@ $^ $(CFLAGS)  

#-------------------------------------------------------------------------------

#createDataSet: $(M)/createDataSet.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#manipulatingChromosomes: $(M)/manipulatingChromosomes.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#customNodeFunction: $(M)/customNodeFunction.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS) 

#customFitnessFunction: $(M)/customFitnessFunction.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#customSelectionScheme: $(M)/customSelectionScheme.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#customReproductionScheme:  $(M)/customReproductionScheme.c  $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#averageBehaviour: $(M)/averageBehaviour.c $(CGP) 
#	$(CC) -o $@ $^ $(CFLAGS)

#neuroEvolution: $(M)/neuroEvolution.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#recurrentConnections: $(M)/recurrentConnections.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#customES: $(M)/customES.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#visualization: $(M)/visualization.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#printChromoEqu: $(M)/printChromoEqu.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)

#multipleThreads: $(M)/multipleThreads.c $(CGP)
#	$(CC) -o $@ $^ $(CFLAGS)


#-------------------------------------------------------------------------------

docs: ./$(S)/cgp.h ./naturaldocs/customFiles/*
	@naturaldocs -i ./src -i ./naturaldocs/customFiles -o HTML ./docs -p ./naturaldocs

profile: $(M)/averageBehaviour.c $(S)/cgp.c $(S)/cgp.h
	$(CC) -o averageBehaviour $(M)/averageBehaviour.c $(S)/cgp.c $(CFLAGS) -pg 
	./averageBehaviour
	gprof averageBehaviour | ./gprof2dot.py | dot -Tsvg -o profile.svg

#-------------------------------------------------------------------------------

#	rm -f cgp.o libcgp.so cgp.dll test gettingStarted createDataSet manipulatingChromosomes customNodeFunction customFitnessFunction customSelectionScheme customReproductionScheme manipluatingChromosomes averageBehaviour neuroEvolution printChromoEqu customES visualization recurrentConnections testEigen reservoirCGPANN multipleThreads *.data *.chromo *.depend *.layout *.exe *.layout *.out *.dot *.svg *.csv tmp.aux tmp.log *.pdf *.out 
#	rm -rf obj/

clean:
	rm -f *.data *.chromo *.depend *.layout *.exe *.layout *.out *.dot *.svg *.csv tmp.aux tmp.log *.pdf *.out 
	rm -f T/*.o *.o $(PROGS) *.tex *.aux *.dvi *.log *.fun


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
