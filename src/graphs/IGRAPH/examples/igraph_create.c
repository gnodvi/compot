// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*
  IGraph library.
  Copyright (C) 2006-2012  Gabor Csardi <csardi.gabor@gmail.com>
  334 Harvard street, Cambridge, MA 02139 USA

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc.,  51 Franklin Street, Fifth Floor, Boston, MA
  02110-1301 USA

  */
//------------------------------------------------------------------------------

#include <igraph.h>

//------------------------------------------------------------------------------
int main (void) 
{

  igraph_t g;
  igraph_vector_int_t v1, v2;

  /* simple use */
  igraph_vector_int_init (&v1, 8);

  VECTOR (v1)[0] = 0;
  VECTOR (v1)[1] = 1;

  VECTOR (v1)[2] = 1;
  VECTOR (v1)[3] = 2;

  VECTOR (v1)[4] = 2;
  VECTOR (v1)[5] = 3;

  VECTOR (v1)[6] = 2;
  VECTOR (v1)[7] = 2;

  igraph_create (
                 &g,   // An uninitialized graph object. 
       &v1, // The edges to add, the first two elements are the first edge, etc. 
       0,   // The number of vertices in the graph, if smaller or equal to the 
            // highest vertex ID in the edges vector it will be increased 
            // automatically. So it is safe to give 0 here.
       0    // Boolean, whether to create a directed graph or not. If yes, then 
            // the first edge points from the first vertex ID in edges to the second, etc. 
       );  

  if (igraph_vcount (&g) != 4) {
    return 1;
  }

  igraph_vector_int_init (&v2, 0);
  igraph_get_edgelist (&g, &v2, 0); // взяли списко ребер из графа?

  igraph_vector_int_sort (&v1);
  igraph_vector_int_sort (&v2);  

  igraph_write_graph_edgelist (&g, stdout); // напечатаем ребра графа
  igraph_write_graph_dot      (&g, stdout); 

  printf ("\n");
  igraph_write_graph_graphml (&g, stdout,
                              0  //Logical value, whether to put a prefix 
                                 // in front of the attribute names to ensure 
                                 // uniqueness if the graph has vertex and 
                                 // edge (or graph) attributes with the same name. 
                              ); 
  printf ("\n");
  igraph_write_graph_lgl (&g, stdout,
                          NULL /* const char *names */, 
                          NULL /* const char *weights */,
                          true /* igraph_bool_t isolates */
                          );
  printf ("\n");
  igraph_write_graph_leda (&g, stdout,
                           NULL /* const char *vertex_attr_name */,
                           NULL /* const char *edge_attr_name */);
  printf ("\n");


  if (! igraph_vector_int_all_e (&v1, &v2) /// Are all elements equal? 
      ) {
    return 2;
  }

  igraph_destroy (&g);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  printf ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n");

  /* higher number of vertices */

  igraph_create (&g, &v1, 10, 0);

  if (igraph_vcount (&g) != 10) {
    return 1;
  }

  igraph_get_edgelist (&g, &v2, 0);

  igraph_vector_int_sort (&v1);
  igraph_vector_int_sort (&v2);

  igraph_write_graph_edgelist (&g, stdout); // напечатаем ребра графа
  igraph_write_graph_dot (&g, stdout); 

  if (! igraph_vector_int_all_e (&v1, &v2)) {
    return 3;
  }

  igraph_destroy (&g);
  igraph_vector_int_destroy (&v1);
  igraph_vector_int_destroy (&v2);

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
