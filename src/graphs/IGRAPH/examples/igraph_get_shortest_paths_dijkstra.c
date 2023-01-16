// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/* -*- mode: C -*-  */
/*
  IGraph library.
  Copyright (C) 2006-2012  Gabor Csardi <csardi.gabor@gmail.com>
  334 Harvard st, Cambridge MA, 02139 USA

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
#include <stdlib.h>

//------------------------------------------------------------------------------
void test_shortest_paths_dijkstra () 
{

  igraph_t g;

  igraph_vector_int_list_t vecs, evecs;
  igraph_vector_int_t parents, inbound;
  igraph_integer_t i;

  igraph_real_t weights[] = 
    { 0, 2, 1, 0, 5, 2, 1, 1, 0, 2, 2, 8, 1, 1, 3, 1, 1, 4, 2, 1 };

  igraph_vector_t weights_vec;
  igraph_vs_t vs;

  printf ("\n");

  igraph_vector_int_list_init (&vecs, 0);
  igraph_vector_int_list_init (&evecs, 0);
  igraph_vector_int_init (&parents, 0);
  igraph_vector_int_init (&inbound, 0);

  // куда будем считать кратчайшие пути
  // 
  igraph_vs_vector_small (&vs, 
                          0, 1, 3, 5, 2, 1, 
                          -1);

  igraph_small (&g, 10, IGRAPH_DIRECTED,
               0, 1, 0, 2, 0, 3,   1, 2, 1, 4, 1, 5,
               2, 3, 2, 6,         3, 2, 3, 6,
               4, 5, 4, 7,         5, 6, 5, 8, 5, 9,
               7, 5, 7, 8,         8, 9,
               5, 2,
               2, 1,
               -1);

  igraph_write_graph_dot (&g, stdout); 
  printf ("\n");

  // Handle a regular C array as a igraph_vector_t.
  // 
  igraph_vector_view (&weights_vec, weights, 
                      sizeof(weights) / sizeof(weights[0]));


  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Weighted shortest paths from a vertex.

  igraph_get_shortest_paths_dijkstra (
            &g, 
            /*vertices=*/ &vecs, // The result, the IDs of the vertices 
                                 // along the paths. This is a list of integer vectors 
            /*edges=*/   &evecs, // The result, the IDs of the edges along the paths.
            /*from=*/ 0, // The id of the vertex from/to which the geodesics 
                         // are calculated.  
             /*to=*/ vs, // Vertex sequence with the IDs of the vertices to/from 
                         // which the shortest paths will be calculated.
 
            &weights_vec,// The edge weights.  
            IGRAPH_OUT,  // the outgoing paths are calculated
            &parents,    // vector containing the parent of each vertex in the 
                         // single source shortest path tree
            /*inbound_edges=*/ &inbound
            );


  printf ("Vertices:\n");

  // идем по списку векторов из целых чисел - вершин по кратчайшему пути
  // 
  for (i = 0; i < igraph_vector_int_list_size (&vecs); i++) {
    igraph_vector_int_print (igraph_vector_int_list_get_ptr (&vecs, i));
  }

  printf ("\nEdges:\n");

  for (i = 0; i < igraph_vector_int_list_size(&evecs); i++) {
    igraph_vector_int_print (igraph_vector_int_list_get_ptr(&evecs, i));
  }


  printf ("\nParents:\n");

  igraph_vector_int_print (&parents);

  printf ("\nInbound:\n");

  igraph_vector_int_print (&inbound);

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Weighted shortest path from one vertex to another one.
 
  //igraph_vector_int_t *vertices,
  //igraph_vector_int_t *edges,
  //igraph_integer_t from,
  //igraph_integer_t to,
  // const igraph_vector_t *weights,;
  //igraph_neimode_t mode);

  // Calculates a single (positively) weighted shortest path from a single vertex 
  // to another one, using Dijkstra's algorithm.

  // This function is a special case (and a wrapper) to 
  // igraph_get_shortest_paths_dijkstra(). 

  igraph_vector_int_t v_ret, e_ret;

  igraph_vector_int_init (&v_ret, 0);
  igraph_vector_int_init (&e_ret, 0);


  //#ifdef _0
  igraph_get_shortest_path_dijkstra (&g,
                                      &v_ret,
                                      &e_ret,
                                      0,
                                      5,
                                      &weights_vec,
                                      IGRAPH_OUT);
  //#endif

  
  printf ("\n");
  printf ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n");
  printf ("\n");

  printf ("v_ret :  ");
  igraph_vector_int_print (&v_ret);

  printf ("e_ret :  ");
  igraph_vector_int_print (&e_ret);

  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  igraph_vector_int_list_destroy (&vecs);
  igraph_vector_int_list_destroy (&evecs);
  igraph_vector_int_destroy (&parents);
  igraph_vector_int_destroy (&inbound);

  igraph_vs_destroy (&vs);
  igraph_destroy (&g);

  printf ("\n");

  return;
}
/*-----------------------------------------------------------------------------*/ 
void
test_01 ()
{

  //printf ("\n");
  printf ("..... test_01 ..... \n");
  printf ("\n");

  // GRAF *pg;
  // int   s, t, nn;
  // double  r, d;
  // int     num_r, num_d;


  // pg = GrafCreate (4);
  
  // //GrafInit (pg, YCONST, 0.0, 0.0, YCONST, NOT, 0.0);
  // GrafInit (pg, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  
  // EDGE (pg, 0, 1) = 1;
  // EDGE (pg, 1, 2) = 1;
  // EDGE (pg, 2, 3) = 1;
  // //EDGE (pg, 0, 3) = 3.1 /* 2.9 */;
  // EDGE (pg, 0, 3) = 4 /* 2.9 */;
  
  // s = 0;
  // t = 3;
  
  // printf ("\n");
  // GrafPrint (pg);

  // GrafSmin (pg, s, t, NULL);
  // printf ("\n");


  igraph_t g;

  igraph_small (&g, 4, IGRAPH_DIRECTED,
               0, 1,  1, 2,  2, 3, 
               0, 3,
               -1);

  igraph_real_t weights[] = 
    {  1, 1, 1,   2  };
  igraph_vector_t weights_vec;

  // Handle a regular C array as a igraph_vector_t.
  // 
  igraph_vector_view (&weights_vec, weights, 
                      sizeof(weights) / sizeof(weights[0]));



  igraph_vector_int_t v_ret, e_ret;

  igraph_vector_int_init (&v_ret, 0);
  igraph_vector_int_init (&e_ret, 0);


  //#ifdef _0
  igraph_get_shortest_path_dijkstra (&g,
                                     &v_ret,
                                     &e_ret,
                                     0,
                                     3,
                                     &weights_vec,
                                     IGRAPH_OUT);


  printf ("v_ret :  ");
  igraph_vector_int_print (&v_ret);

  printf ("e_ret :  ");
  igraph_vector_int_print (&e_ret);


  // GrafMetrica (pg, &r, &d, &num_r, &num_d);

  // printf ("r = %.1f  num_r = %d \n", r, num_r);
  // printf ("d = %.1f  num_d = %d \n", d, num_d);

  printf ("\n");

  return;
}
//------------------------------------------------------------------------------
int main (void) {

  test_shortest_paths_dijkstra (); 

  printf ("\n");
  printf ("============================================================= \n");
  printf ("\n");

  test_01 ();

  return 0;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
