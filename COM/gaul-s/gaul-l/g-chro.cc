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
 * chromosome.c
 *
 */

#include <string.h> // memcpy

// mgena ------------------------------------------

#define byte gaulbyte

// mgena ------------------------------------------

#include <tcl.h>
#include <gaul.h>

//#include "t_chro.hh"
#include "g-chro.hh"

/*
 * Function Bodies
 */

/*
 * TclObj_chromosome_constructor is used to allocate single chromosomes. 
 */
boolean TclObj_chromosome_constructor(population *pop, entity *entity) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!entity) die("Null pointer to entity structure passed.");

    if (entity->chromosome != NULL)
        die("This entity already contains chromosomes.");

// mgena
/*     if (pop->num_chromosomes != 1) */
/*         die("This entity contains multiple chromosomes."); */

    Tcl_Obj *objPtr = Tcl_NewObj();
    entity->chromosome = s_malloc(sizeof(Tcl_Obj *));
    entity->chromosome[0] = objPtr;
    Tcl_IncrRefCount(objPtr);

    return TRUE;
}

/*
 * TclObj_chromosome_destructor is used to deallocate single chromosomes. 
 */
void TclObj_chromosome_destructor(population *pop, entity *entity) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!entity) die("Null pointer to entity structure passed.");

    if (entity->chromosome == NULL)
        die("This entity already contains no chromosomes.");

// mgena
/*     if (pop->num_chromosomes != 1) */
/*         die("This entity contains multiple chromosomes."); */

    Tcl_DecrRefCount((Tcl_Obj *) entity->chromosome[0]);
    s_free(entity->chromosome);
    entity->chromosome = NULL;

    return;
}

/*
 * TclObj_chromosome_replicate is used to clone single chromosomes. 
 */
void TclObj_chromosome_replicate(const population *pop, entity *src, entity *dest, const int chromosomeid) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!src || !dest) die("Null pointer to entity structure passed.");
    if (!src->chromosome || !dest->chromosome) die("Entity has no chromosomes.");
    if (chromosomeid != 0) die("Invalid chromosome index.");

// mgena
/*     if (pop->num_chromosomes != 1) die("This entity contains multiple chromosomes."); */

    if (!src->chromosome[chromosomeid] || !dest->chromosome[chromosomeid]) die("Entity has empty chromosomes.");

    Tcl_DecrRefCount((Tcl_Obj *) dest->chromosome[0]);
    dest->chromosome[0] = Tcl_DuplicateObj((Tcl_Obj *) src->chromosome[0]);
    Tcl_IncrRefCount((Tcl_Obj *) dest->chromosome[0]);

    return;
}

/*
 * TclObj_chromosome_to_bytes is used to pack genomic data into a contiguous block of memory. 
 */
unsigned int TclObj_chromosome_to_bytes(const population *pop, entity *joe, byte **bytes, unsigned int *max_bytes) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!joe) die("Null pointer to entity structure passed.");

// mgena
/*     if (pop->num_chromosomes != 1) die("This entity contains multiple chromosomes."); */

    if (*max_bytes != 0) die("Internal error.");
    if (!joe->chromosome || !joe->chromosome[0]) die("Entity has no chromosomes.");

    dief("Function not implemented");

    int length = 0;
    *bytes = Tcl_GetByteArrayFromObj((Tcl_Obj *) joe, &length);

    return length;
}

/*
 * TclObj_chromosome_from_bytes is used to unpack genomic data from a contiguous block of memory. 
 */
void TclObj_chromosome_from_bytes(const population *pop, entity *joe, byte *bytes) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!joe) die("Null pointer to entity structure passed.");
    if (!joe->chromosome || !joe->chromosome[0]) die("Entity has no chromosomes.");

    dief("Function not implemented");

    //Tcl_SetByteArrayObj((Tcl_Obj *) joe->chromosome[0], bytes, length)

    return;
}

/*
 * TclObj_chromosome_to_string is used to generate a human readable representation of genomic data.
 */
char * TclObj_chromosome_to_string(const population *pop, const entity *joe, char *text, size_t *textlen) {
    if (!pop) die("Null pointer to population structure passed.");
    if (!joe) die("Null pointer to entity structure passed.");
    if (!joe->chromosome || !joe->chromosome[0]) die("Entity has no chromosomes.");

    dief("Function not implemented");

    int length;
    char *string;
    string = Tcl_GetStringFromObj(joe->chromosome[0], &length);

    if (*textlen < length + 1) {
        *textlen = length + 1;
        text = s_realloc(text, sizeof(char) * *textlen);
    }

    memcpy(&(text[0]), string, length);
    text[*textlen] = '\0';

    return text;
}
