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
//
double symbolicEq2 (double x) {

  //return pow(x,6) - 2*pow(x,4) + pow(x,2);
  //return pow (x, 2);
  //return (x * x);

  return (x * x * x  +  x * x  +  x);

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

  get_options_CGP (argc, argv,  
                   /* buf */NULL, 
                   &seed,
                   &d,  
                   &updateFrequency,  
                   &targetFitness,  
                   &numGens,  
                   &verbose 
                   );

  params = initialiseParameters (numInputs, numNodes, numOutputs, nodeArity);
  
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
    file = "./dataSets/symbolic.data";
    break;

  case 2:
    addNodeFunction    (params, "add,sub,mul,div,sin");
    data = make_data_function (symbolicEq2);

    file = "out_data.fun";

    saveDataSet(data, file);
    freeDataSet(data);

    break;

  case 3:
    addNodeFunction    (params, "add,sub,mul,div,sin");
    data = make_data_function (symbolicEq3);

    file = "out_data.fun";

    saveDataSet(data, file);
    freeDataSet(data);
    break;

  case 9:
    //addNodeFunction    (params, "add, sub, mul, div, sin");
    addNodeFunction    (params, "add, mul");

    data = make_data_function (symbolicEq2);

    file = "out_data.fun";

    saveDataSet(data, file);
    freeDataSet(data);

    break;

  default:
    Error ("");
  }

  //---------------------------------

  printParameters (params);
  
  trainingData = initialiseDataSetFromFile (file);
  
  chromo = runCGP (params, trainingData, numGens); // запускаем 
  
  //---------------------------------

  printChromosome (chromo, 0);
  // printChromosome (chromo, 1); // weights not used in this tests! only networks? 
  
  //---------------------------------

  saveChromosomeDot  (chromo, 0, "out_graf.dot");
  saveChromosomeLatex(chromo, 0, "out_math.tex");

  freeDataSet    (trainingData);
  freeChromosome (chromo);
  freeParameters (params);
  
  return 0;
}
//------------------------------------------------------------------------------
int main (int argc, char **argv) {

  int  ret = 0;
  char buf[80];

  strcpy (buf, "gettingStarted");

  get_options_CGP (argc, argv,  
                   buf,   
                   NULL, NULL, NULL, NULL, NULL, NULL);

  if      (! strcmp (buf, "gettingStarted")) ret = test_gettingStarted (argc, argv);
  else {  
    printf ("\nERROR option -t = %s \n\n", buf);
  }
  
  return (ret);
}
//------------------------------------------------------------------------------
// gettingStarted -t gettingStarted -s0 -d2 -u10
// gettingStarted -t gettingStarted -s0 -d2 -u1 -n10 -v

// gettingStarted -d9 -v -u1

//------------------------------------------------------------------------------
