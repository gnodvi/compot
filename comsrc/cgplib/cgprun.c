// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------
/*
	This file is part of CGP-Library
	Copyright (c) Andrew James Turner 2014 (andrew.turner@york.ac.uk)

    CGP-Library is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    CGP-Library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with CGP-Library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>
#include <time.h>

#include <unistd.h>
#include <stdio.h>

#include "common.h"
#include "cgp.h"

//------------------------------------------------------------------------------
// 
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//int main (void) {
//------------------------------------------------------------------------------
int test_averageBehaviour (int argc, char **argv) {


  struct parameters *params = NULL;
  struct dataSet *trainingData = NULL;
  struct results *rels = NULL;
  struct chromosome *chromo = NULL;
  
  int numInputs = 1;
  int numNodes = 15;
  int numOutputs = 1;
  int nodeArity = 2;
  
  int numGens = 10000;
  int numRuns = 10;
  
  double targetFitness = 0.1;
  int updateFrequency = 500;
  
  double averageFitness;
  
  params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,div,sin");

  setTargetFitness(params, targetFitness);

  setUpdateFrequency(params, updateFrequency);

  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/symbolic.data");

  rels = repeatCGP(params, trainingData, numGens, numRuns);

  averageFitness = getAverageFitness(rels);

  printf("The average chromosome fitness is: %f\n", averageFitness);

  chromo = getChromosome(rels, 4);

  printf("The best chromosome found on run 4:\n");

  printChromosome(chromo, 0);

  saveResults (rels, "c_out.csv" /* "results.csv" */ );

  freeDataSet(trainingData);
  freeChromosome(chromo);
  freeResults(rels);
  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/*
  Returns   x^6 - 2x^4 + x^2
*/
double symbolicEq1 (double x){

	return pow(x,6) - 2*pow(x,4) + pow(x,2);
}
//------------------------------------------------------------------------------
int test_createDataSet (int argc, char **argv) {

  //YT_MAKEFUNC makefunc = symbolicEq1;

  struct dataSet *data = make_data_function (symbolicEq1, 101, -5.0, +5.0);

  saveDataSet (data, "c_out.fun" /* "symbolic.data"  */);

  freeDataSet(data);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
double meanSquareError(struct parameters *params, struct chromosome *chromo, struct dataSet *data){

  int i,j;
  double squareError = 0;

  if (getNumChromosomeInputs(chromo) !=getNumDataSetInputs(data)){
    printf ("Error: the number of chromosome inputs must match the number of inputs specified in the dataSet.\n");
    printf ("Terminating.\n");
    exit (0);
  }

  if (getNumChromosomeOutputs(chromo) != getNumDataSetOutputs(data)) {

    printf ("Error: the number of chromosome outputs must match the number of outputs specified in the dataSet.\n");
    printf ("Terminating.\n");
    exit (0);
  }

  for (i=0; i<getNumDataSetSamples(data); i++) {

    executeChromosome (chromo, getDataSetSampleInputs(data, i));

    for (j=0; j<getNumChromosomeOutputs(chromo); j++){

      squareError += pow (getDataSetSampleOutput(data,i,j) - getChromosomeOutput (chromo,j), 2);
    }
  }


  return squareError / (getNumDataSetSamples(data) * getNumDataSetOutputs(data));
}
//------------------------------------------------------------------------------
int test_customFitnessFunction (int argc, char **argv) {

  struct parameters *params = NULL;

  int numInputs = 1;
  int numNodes = 20;
  int numOutputs = 1;
  int arity = 2;

  params = initialiseParameters (numInputs, numNodes, numOutputs, arity);

  setCustomFitnessFunction(params, meanSquareError, "MSE");

  printParameters(params);

  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
double hypotenuse (const int numInputs, const double *inputs, const double *connectionWeights){

  int i;
  double sumOfSqrs = 0;
  double hypt;

  for(i=0; i<numInputs; i++){
    sumOfSqrs += pow(inputs[i], 2);
  }

  hypt = sqrt(sumOfSqrs);

  return hypt;
}
//------------------------------------------------------------------------------
int test_customNodeFunction (int argc, char **argv) {

  struct parameters *params = NULL;

  int numInputs = 2;
  int numNodes = 10;
  int numOutputs = 1;
  int arity = 3;

  params = initialiseParameters (numInputs, numNodes, numOutputs, arity);

  addNodeFunction(params, "add,sub");

  addCustomNodeFunction(params, hypotenuse, "hypt", -1);

  printParameters(params);

  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void mutateEveryParent (struct parameters *params, struct chromosome **parents, 
                        struct chromosome **children, int numParents, int numChildren){
	
  int i;
  int selectedParent;

  /* for each child */
  for(i=0; i< numChildren; i++){

    selectedParent = i % numParents;

    /* set child as clone of selected parent */
    copyChromosome(children[i], parents[selectedParent]);

    /* mutate newly cloned child */
    mutateChromosome(params, children[i]);
  }

  return;
}
//------------------------------------------------------------------------------
int test_customReproductionScheme (int argc, char **argv) {

	
	
  struct parameters *params = NULL;
  struct dataSet *trainingData = NULL;
  struct chromosome *chromo = NULL;
	
  int numInputs = 1;

  int numNodes = 50;
  int numOutputs = 1;
  int arity = 2;
	
  int mu = 4;
  int lambda = 8;
	
  double targetFitness = 0.1;
  int updateFrequency = 1000;
  int numGens = 10000;
	
  params = initialiseParameters (numInputs, numNodes, numOutputs, arity);
  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------
	
  addNodeFunction(params, "add,sub,mul,div,sin");
	
  setTargetFitness(params, targetFitness);

  setUpdateFrequency(params, updateFrequency); 
	
  setCustomReproductionScheme(params, mutateEveryParent, "mutateEveryParent");
	
  setMu(params, mu);
  setLambda(params, lambda);
	
  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/symbolic.data");
	
  chromo = runCGP(params, trainingData, numGens);
	
  freeChromosome(chromo);
  freeDataSet(trainingData);
  freeParameters(params);
	
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void tournament (struct parameters *params, struct chromosome **parents, 
                struct chromosome **candidateChromos, int numParents, int numCandidateChromos){

  int i;
  
  struct chromosome *candidateA;
  struct chromosome *candidateB;
  
  srand (2020);  //gnodvi

  for(i=0; i<numParents; i++){
    
    candidateA = candidateChromos[rand() % numCandidateChromos];
    candidateB = candidateChromos[rand() % numCandidateChromos];
    
    if(getChromosomeFitness(candidateA) <= getChromosomeFitness(candidateB)){
      copyChromosome(parents[i], candidateA);
    }
    else{
      copyChromosome(parents[i], candidateB);
    }		
  }

}
//------------------------------------------------------------------------------
int test_customSelectionScheme (int argc, char **argv){
	
  struct parameters *params = NULL;
  struct dataSet *trainingData = NULL;
  struct chromosome *chromo = NULL;
	
  int numInputs = 1;
  int numNodes = 50;
  int numOutputs = 1;
  int arity = 2;
	
  double targetFitness = 0.1;
  int updateFrequency = 1000;
  int numGens = 10000;
	
  params = initialiseParameters (numInputs, numNodes, numOutputs, arity);
	  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,div,sin");
  
  setTargetFitness(params, targetFitness);
  
  setUpdateFrequency(params, updateFrequency); 
  
  setCustomSelectionScheme(params, tournament, "tournament");
  
  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/symbolic.data");
  
  chromo = runCGP (params, trainingData, numGens);
  
  freeChromosome(chromo);
  freeDataSet(trainingData);
  freeParameters(params);
  
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#define POPULATIONSIZE 5
#define NUMINPUTS 1
#define NUMNODES 8
#define NUMOUTPUTS 1
#define ARITY 2
  
//------------------------------------------------------------------------------
int test_manipulatingChromosomes (int argc, char **argv) {

  struct parameters *params = NULL;
  struct chromosome *chromoA = NULL;
  struct chromosome *chromoB = NULL;
  struct chromosome *chromoC = NULL;
  struct dataSet *trainingData = NULL;
  
  double testInputs[NUMINPUTS];
  
  params = initialiseParameters (NUMINPUTS, NUMNODES, NUMOUTPUTS, ARITY);
  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,sq,cube,sin");

  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/symbolic.data");

  chromoA = initialiseChromosome(params);
  chromoB = initialiseChromosome(params);

  setChromosomeFitness(params, chromoA, trainingData);

  mutateChromosome (params, chromoA);

  copyChromosome   (chromoB, chromoA);

  removeInactiveNodes (chromoB);

  printf ("chromoA with inactive nodes.\n");
  printChromosome (chromoA, 0);

  printf ("chromoB without inactive nodes.\n");
  printChromosome (chromoB, 0);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //saveChromosome (chromoB, "chromoB.chromo");   
  //chromoC = initialiseChromosomeFromFile ("chromoB.chromo");

  saveChromosome (chromoB, "c_out.chr");
  chromoC = initialiseChromosomeFromFile ("c_out.chr");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  testInputs[0] = 3;

  executeChromosome(chromoC, testInputs);

  printf("Applied input: %f\n", testInputs[0]);
  printf("Generated output: %f\n", getChromosomeOutput(chromoC, 0));

  freeChromosome(chromoA);
  freeChromosome(chromoB);
  freeChromosome(chromoC);
  freeDataSet(trainingData);
  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/*
   Custom fitness function which just does some work and returns 10.
*/
//------------------------------------------------------------------------------
double fitnessFunction 
  (struct parameters *params, struct chromosome *chromo, struct dataSet *data) {

  int i;
  double inputs[1] = {0.5};
  int numExec = 10000;

  for (i = 0; i < numExec; i++) {
    executeChromosome (chromo, inputs);
  }

  return 10;
}
//------------------------------------------------------------------------------
int test_multipleThreads (int argc, char **argv) {

  time_t timeStart, timeEnd;
  double singleThreadTime, multipleThreadTime;
  double seedUp;

  struct parameters *params = NULL;

  int numInputs = 1;
  int numNodes = 100;
  int numOutputs = 1;
  int arity = 2;

  // mgena 
  //int gens = 100;
  //int runs = 10;

  int gens = 30;
  int runs = 4;

  params = initialiseParameters (numInputs, numNodes, numOutputs, arity);

  //---------------------------------
  setRandomNumberSeed (2020);
  //---------------------------------

  setRandomNumberSeed(123456789);
  addNodeFunction(params, "add,sub,mul,div,sin");
  setMutationRate(params, 1.0);
  setCustomFitnessFunction(params, fitnessFunction, "FF");

  setNumThreads(params, 1);
  timeStart = time(NULL);
  repeatCGP(params, NULL, gens, runs);
  timeEnd = time(NULL);
  singleThreadTime = difftime(timeEnd, timeStart);

  setNumThreads(params, 4);
  timeStart = time(NULL);
  repeatCGP(params, NULL, gens, runs);
  timeEnd = time(NULL);
  multipleThreadTime = difftime(timeEnd, timeStart);

  seedUp = 100 * (singleThreadTime - multipleThreadTime) / multipleThreadTime;

  fprintf (stderr, "Single thread time: %.f seconds\n", singleThreadTime);
  fprintf (stderr, "Multiple thread time: %.f seconds\n", multipleThreadTime);
  fprintf (stderr, "Speed up = %.f%%\n", seedUp);

  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
double sinWave(struct parameters *params, struct chromosome *chromo, struct dataSet *data) {

  double i;

  double error = 0;
  double range = 6;
  double stepSize = 0.5;

  double inputs[1];

  for (i = 0; i < range; i += stepSize) {

    inputs[0] = i;

    executeChromosome(chromo, inputs);

    error += fabs(getChromosomeOutput(chromo, 0) - sin(i));
  }

  return error;
}
//------------------------------------------------------------------------------
int test_neuroEvolution (int argc, char **argv) {

  struct parameters *params = NULL;
  struct chromosome *chromo = NULL;
  
  int numInputs = 1;
  int numNodes = 20;
  int numOutputs = 1;
  int nodeArity = 5;
  
  int numGens = 25000;
  double targetFitness = 0.5;
  int updateFrequency = 500;
  
  double weightRange = 5;
  
  params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
  setRandomNumberSeed(123456789);
  
  setTargetFitness(params, targetFitness);
  
  setUpdateFrequency(params, updateFrequency);
  
  setConnectionWeightRange(params, weightRange);
  
  setCustomFitnessFunction(params, sinWave, "sinWave");
  
  addNodeFunction(params, "tanh,softsign");
  
  chromo = runCGP(params, NULL, numGens);
  
  printChromosome(chromo, 1);
  
  freeChromosome(chromo);
  freeParameters(params);
  
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
int test_recurrentConnections (int argc, char **argv) {

  struct parameters *params = NULL;
  struct dataSet *trainingData = NULL;
  struct chromosome *chromo = NULL;

  int numInputs = 1;
  int numNodes = 15;
  int numOutputs = 1;
  int nodeArity = 2;

  int numGens = 100000;
  int updateFrequency = 500;

  double recurrentConnectionProbability = 0.10;

  params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
  //---------------------------------
  //setRandomNumberSeed (1999);
  setRandomNumberSeed (2003);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,div");

  setUpdateFrequency(params, updateFrequency);

  setRecurrentConnectionProbability(params, recurrentConnectionProbability);

  printParameters(params);

  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/fibonacci.data");

  chromo = runCGP(params, trainingData, numGens);

  printChromosome(chromo, 0);

  freeDataSet(trainingData);
  freeChromosome(chromo);
  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
int test_visualization (int argc, char **argv) {

  struct parameters *params = NULL;
  struct chromosome *chromo = NULL;
  
  int numInputs  = 1;
  int numNodes   = 8;
  int numOutputs = 1;
  int nodeArity  = 2;
  
  params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,div,sin");
  
  chromo = initialiseChromosome(params);
  
  printChromosome(chromo, 0);
  saveChromosomeDot  (chromo, 0, "c_out.dot" /* "chromo.dot"  */);
  saveChromosomeLatex(chromo, 0, "c_out.tex" /* "chromo.tex"  */);
  
  freeChromosome(chromo);
  freeParameters(params);
  
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
#define POPULATIONSIZE 5
//#define NUMINPUTS 3

//#define NUMNODES 30
#define NUMOUTPUTS 1
#define ARITY 2

//------------------------------------------------------------------------------
int test_customES (int argc, char **argv) {

	
  int i, gen;
	
  struct parameters *params = NULL;
  struct chromosome *population[POPULATIONSIZE]; 
  struct chromosome *fittestChromosome = NULL;
  struct dataSet *trainingData = NULL;
		
  double targetFitness = 0;
  int maxGens = 10000;
				
  params = initialiseParameters (/* NUMINPUTS */ 3, /* NUMNODES */ 30, NUMOUTPUTS, ARITY);
  
  //---------------------------------
  setRandomNumberSeed (2021);
  //---------------------------------
	
  addNodeFunction(params, "or,nor,and,nand");
  /*setTargetFitness(params, targetFitness);*/
  setMutationType(params, "probabilistic");
  setMutationRate(params, 0.08);
	
  trainingData = initialiseDataSetFromFile("./CGPLIB/dataSets/parity3bit.data");
	
  for(i=0; i<POPULATIONSIZE; i++){
    population[i] = initialiseChromosome(params);
  }
	
  fittestChromosome = initialiseChromosome(params);
	
  /* for the number of allowed generations*/
  for(gen=0; gen<maxGens; gen++){
		
    /* set the fitnesses of the population of chromosomes*/
    for(i=0; i<POPULATIONSIZE; i++){
      setChromosomeFitness(params, population[i], trainingData);
    }
		
    /* copy over the last chromosome to fittestChromosome*/
    copyChromosome(fittestChromosome, population[POPULATIONSIZE - 1]);
		
    /* for all chromosomes except the last*/
    for(i=0; i<POPULATIONSIZE-1; i++){
			
      /* copy ith chromosome to fittestChromosome if fitter*/
      if(getChromosomeFitness(population[i]) < getChromosomeFitness(fittestChromosome)){
        copyChromosome(fittestChromosome, population[i]);
      }
    }
				
    /* termination condition*/
    if(getChromosomeFitness(fittestChromosome) <= targetFitness){
      break;
    }
				
    /* set the first member of the population to be the fittest chromosome*/
    copyChromosome (population[0], fittestChromosome);
		
    /* set remaining member of the population to be mutations of the
      fittest chromosome*/
    for(i=1; i<POPULATIONSIZE; i++){
			
      copyChromosome (population[i], fittestChromosome);
      mutateChromosome (params, population[i]);
    }
  }
	
  printf("gen\tfitness\n");
  printf("%d\t%f\n", gen, getChromosomeFitness (fittestChromosome));
	
	
	
  for(i=0; i<POPULATIONSIZE; i++){
    freeChromosome (population[i]);
  }
	
  freeChromosome (fittestChromosome);
  freeDataSet (trainingData);
  freeParameters (params);
	
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Test functions for Monahov articles
//

double MonahovTest1 (double x){

  return (pow (x,4) + pow (x,3) + pow (x,2) + x); // x^4 + x^3 + x^2 + x
}

double MonahovTest2 (double x) {

  return (sin (pow (x,4) + pow (x,2)));  // sin (x^2 + x^4)
}

double MonahovTest3 (double x) {

  //return (sin (exp (sin (exp (sin (x))))) );  
  return ( exp (sin (x)) );  
}

double MonahovTest4 (double x) {

  return ( sin(pow (x,3)) + exp(x));  
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

double SimpleFunc2 (double x){

  return pow (x, 2);

}

double SimpleFunc3 (double x){

  return pow (x, 3);

}
//------------------------------------------------------------------------------
//
double symbolicEq2 (double x) {

  //return pow(x,6) - 2*pow(x,4) + pow(x,2);
  //return pow (x, 2);
  //return (x * x);

  //return (x * x * x  +  x * x  +  x);

  return (x * x * x * x  +  x * x * x  +  x * x  +  x);

  //
  // (0):	input
  // (1):	mul	 0  0 *
  // (2):	add	 0  1 *
  // (3):	mul	 1  2 *
  // (4):	add	 3  0 
  // (5):	mul	 1  2 
  // (6):	mul	 3  3 
  // (7):	add	 3  0 
  // (8):	sub	 6  5 
  // (9):	add	 3  2 *

  //return pow (x, 2) + x;

}
//------------------------------------------------------------------------------
//
double symbolicEq3 (double x){

  return pow(x,3) + pow(x,2) + x;

}
//------------------------------------------------------------------------------
int test_gettingStarted (int argc, char **argv) {

  struct parameters *params = NULL;
  struct dataSet    *trainingData = NULL;
  struct chromosome *chromo = NULL;
  
  int numInputs  = 1;
  int numNodes   = 15;
  int numOutputs = 1;
  int nodeArity  = 2;
  
  int numGens          = 10000;
  double targetFitness = 0.1 /* 0.5 */; // ??
  int updateFrequency  = 500 /* 50 */ ;
  
  int seed = 2021;
  int d = 1; // номер теста

  //---------------------------------

  int Mu     = 1; // родители
  int Lambda = 4; // дети

  get_options_CGP (argc, argv,  
                   /* buf */NULL,    // -t 
                   &seed,            // -s 
                   &d,               // -d
                   &updateFrequency, // -u 
                   &targetFitness,   // -f 
                   &numGens,         // -g  
                   &numNodes,        // -n  
                   &verbose,         // -v
                   
                   &Mu, &Lambda
                   );

  //params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
  params = initialiseParametersMore (numInputs, numNodes, 
                                     numOutputs, nodeArity, Mu, Lambda);

  //printf ("seed = %d \n", seed);

  if (seed != 0) {
    //printf ("seed = %d !!!!!!!!!!!!!!!!!!!!! \n", seed);
    setRandomNumberSeed (seed);
  }

  //---------------------------------

  //addNodeFunction    (params, "add,sub,mul,div,sin");
  setTargetFitness   (params, targetFitness);  
  setUpdateFrequency (params, updateFrequency); // через сколько печатать?
  
  //printParameters (params);
  
  //---------------------------------
  struct dataSet *data;
  char *file = NULL;

  switch (d) {

  case 1:
    addNodeFunction    (params, "add,sub,mul,div,sin");
    // Note: you may need to check this path such that it is relative to your executable 
    // 
    file = "./CGPLIB/dataSets/symbolic.data";
    break;

  case 2:
    addNodeFunction    (params, "add,sub,mul,div,sin");
    data = make_data_function (symbolicEq2, 101, -5.0, +5.0);

    file = /* "out_data.fun" */ "c_out.fun" ;

    saveDataSet(data, file);
    freeDataSet(data);

    break;

  case 3:
    addNodeFunction    (params, "add,sub,mul,div,sin");
    data = make_data_function (symbolicEq3, 101, -5.0, +5.0);

    file = "c_out.fun";

    saveDataSet(data, file);
    freeDataSet(data);
    break;

  case 9:
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //addNodeFunction    (params, "add, sub, mul, div, sin");
    addNodeFunction    (params, "add, mul");

    double x_min = -5.0 /* 0.0 */;
    double x_max = +5.0 /* 2.0 */;
    int nums = 21 /*101*/;

    //data = make_data_function (SimpleFunc2, nums, x_min, x_max);   // x^2
    data = make_data_function (SimpleFunc3, nums, x_min, x_max);     // x^3

    //data = make_data_function (MonahovTest1, nums, x_min, x_max);   // x^4 + x^3 + x^2 + x
    //data = make_data_function (MonahovTest2, nums, x_min, x_max);   // sin (x^2 + x^4)
    //data = make_data_function (MonahovTest3, nums, x_min, x_max);   // sin exp sin exp sin
    //data = make_data_function (MonahovTest4, nums, x_min, x_max);   // sin (x3) + exp(x) 

    file = "c_out.fun";

    saveDataSet(data, file);
    freeDataSet(data);

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    break;

  default:
    Error ("");
  }

  //---------------------------------

  printParameters (params);
  
  trainingData = initialiseDataSetFromFile (file);
  
  chromo = runCGP (params, trainingData, numGens); // запускаем  !!!
  
  //---------------------------------

  printChromosome (chromo, 0);
  // printChromosome (chromo, 1); // weights not used in this tests! only networks? 
  
  //---------------------------------

  saveChromosomeDot  (chromo, 0, "c_out.dot"); // сохраним в формате графа
  saveChromosomeLatex(chromo, 0, "c_out.tex"); // сохраним формулу

  //SaveToLatex (stdout, chromo); // напечатаем в консоль 
  EqToLatex (stdout, chromo, 0); 

  printf ("\n\n"); // сбиваем работу консоли?
  // а можно распечатать файл? system ("cat out_math.tex");

  freeDataSet    (trainingData);
  freeChromosome (chromo);
  freeParameters (params);
  
  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
int main (int argc, char **argv) {

  int  ret = 0;
  char buf[80];

  strcpy (buf, "gettingStarted");

  get_options_CGP (argc, argv,  
                   buf,   
                   NULL, NULL, NULL, NULL, NULL, NULL, NULL,    NULL, NULL);

  if      (! strcmp (buf, "gettingStarted"))           ret = test_gettingStarted          (argc, argv);
  else if (! strcmp (buf, "averageBehaviour"))         ret = test_averageBehaviour        (argc, argv);
  else if (! strcmp (buf, "createDataSet"))            ret = test_createDataSet           (argc, argv);
  else if (! strcmp (buf, "customFitnessFunction"))    ret = test_customFitnessFunction   (argc, argv);
  else if (! strcmp (buf, "customNodeFunction"))       ret = test_customNodeFunction      (argc, argv);
  else if (! strcmp (buf, "customReproductionScheme")) ret = test_customReproductionScheme(argc, argv);
  else if (! strcmp (buf, "customSelectionScheme"))    ret = test_customSelectionScheme   (argc, argv);
  else if (! strcmp (buf, "manipulatingChromosomes"))  ret = test_manipulatingChromosomes (argc, argv);
  else if (! strcmp (buf, "manipulatingChromosomes"))  ret = test_multipleThreads         (argc, argv);
  else if (! strcmp (buf, "neuroEvolution"))           ret = test_neuroEvolution          (argc, argv);
  else if (! strcmp (buf, "recurrentConnections"))     ret = test_recurrentConnections    (argc, argv);
  else if (! strcmp (buf, "visualization"))            ret = test_visualization           (argc, argv);
  else if (! strcmp (buf, "customES"))                 ret = test_customES                (argc, argv);
  else {  
    printf ("\nERROR option -t = %s \n\n", buf);
  }
  
  return (ret);
}
//------------------------------------------------------------------------------

// cgprun -t gettingStarted -d9 -v -u1   // печатать много на каждом шаге 

// -t : тестовая функция
// -d : номер выполняемого теста внутри функции
// -v : немного больше печатать
// -u : через сколько печатать
// -g : numGenes - сколько максимум итераций 
// -n : numNodes - узлов в хромосоме
// -s : начальный рандом (seed)

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
