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
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with CGP-Library.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <math.h>

#include "common.h"
#include "cgp.h"

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
/*
  Returns   x^6 - 2x^4 + x^2
*/
double symbolicEq1 (double x){

	return pow(x,6) - 2*pow(x,4) + pow(x,2);
}
//------------------------------------------------------------------------------
int main (void){

  //YT_MAKEFUNC makefunc = symbolicEq1;

  struct dataSet *data = make_data_function (symbolicEq1);

  saveDataSet(data, "symbolic.data");

  freeDataSet(data);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------