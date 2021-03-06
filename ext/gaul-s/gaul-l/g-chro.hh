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
 * chromosome.h
 *
 */

#include <gaul.h>

/*
 * Function Prototypes
 */

boolean TclObj_chromosome_constructor(population *pop, entity *entity);

void TclObj_chromosome_destructor(population *pop, entity *entity);

void TclObj_chromosome_replicate(const population *pop, entity *src, entity *dest, const int chromosomeid);

unsigned int TclObj_chromosome_to_bytes(const population *pop, entity *joe, byte **bytes, unsigned int *max_bytes);

void TclObj_chromosome_from_bytes(const population *pop, entity *joe, byte *bytes);

char * TclObj_chromosome_to_string(const population *pop, const entity *joe, char *text, size_t *textlen);
