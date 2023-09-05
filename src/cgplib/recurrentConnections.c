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

#include "common.h"
#include "cgp.h"

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

  params = initialiseParameters(numInputs, numNodes, numOutputs, nodeArity);
  
  //---------------------------------
  //setRandomNumberSeed (1999);
  setRandomNumberSeed (2003);
  //---------------------------------

  addNodeFunction(params, "add,sub,mul,div");

  setUpdateFrequency(params, updateFrequency);

  setRecurrentConnectionProbability(params, recurrentConnectionProbability);

  printParameters(params);

  trainingData = initialiseDataSetFromFile("./dataSets/fibonacci.data");

  chromo = runCGP(params, trainingData, numGens);

  printChromosome(chromo, 0);

  freeDataSet(trainingData);
  freeChromosome(chromo);
  freeParameters(params);

  return 0;
}
//------------------------------------------------------------------------------
int main (int argc, char **argv) {

  int  ret = 0;
  char buf[80];

  strcpy (buf, "recurrentConnections");

  get_options_CGP (argc, argv,  
                   buf,   
                   NULL, NULL, NULL, NULL, NULL, NULL);

  if      (! strcmp (buf, "recurrentConnections")) ret = test_recurrentConnections (argc, argv);
  else {  
    printf ("\nERROR option -t = %s \n\n", buf);
  }
  
  return (ret);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
