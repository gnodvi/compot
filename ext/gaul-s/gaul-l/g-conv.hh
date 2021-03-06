/*
    gaul - Genetic and other optimization algorighms for Tcl.
    A Tcl interface to the GAUL library.

    Copyright (C) 2008  Alexandros Stergiakis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
 * convert.h
 *
 */

#include <tcl.h>
#include <gaul.h>

#define INT_LEN 100
#define DOUBLE_LEN 200

/*
 * Function Prototypes
 */

void itoa(int n, char *s);

void dtoa(double d, char *s);

int convert_scheme(Tcl_Interp *interp, Tcl_Obj *string);

Tcl_Obj * convert_from_scheme(int scheme);

int convert_elitism(Tcl_Interp *interp, Tcl_Obj *string);

Tcl_Obj * convert_from_elitism(int elitism);
