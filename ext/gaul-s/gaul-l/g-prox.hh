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
 * proxy.h
 *
 */

#include <tcl.h>
#include <gaul.h>

/*
 * Function Prototypes
 */

boolean Proxy_generation_hook(const int generation, population *pop);

boolean Proxy_evaluate(population *pop, entity *entity);

boolean Proxy_seed(population *pop, entity *adam);

entity *Proxy_adapt(population *pop, entity *child);

void Proxy_mutate(population *pop, entity *mother, entity *daughter);

void Proxy_crossover(population *pop, entity *mother, entity *father, entity *daughter, entity *son);

void Proxy_chromosome_destructor(population *pop, entity *entity);
