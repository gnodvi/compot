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
 * tclgaul.h
 *
 */

// mgena ------------------------------------------

#define byte gaulbyte

// mgena ------------------------------------------

#include <tcl.h>

/*
 * Function Prototypes
 */

struct pop_data {
    Tcl_Command cmdtoken;
    Tcl_Obj *name;
    Tcl_Interp *interp;
    Tcl_Obj *generation_hook;
    Tcl_Obj *evaluate;
    Tcl_Obj *seed;
    Tcl_Obj *adapt;
    Tcl_Obj *mutate;
    Tcl_Obj *crossover;
    Tcl_Obj *select_one;
    Tcl_Obj *select_two;
    Tcl_Obj *destroy;
};
