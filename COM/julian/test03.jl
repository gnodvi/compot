
#-------------------------------------------------------------------------------

using EvolvingGraphs

#-------------------------------------------------------------------------------
function evolving_graph_01()

  g = evolving_graph( )

  # There is nothing in the graph g at the moment. To make it a little more
  # interesting, we can add some edges to g. We need to note that edges have a time
  # dimension in an evolving graph:

  add_edge!( g, 1, 2, 1)

  # This will add an edge from node 1 to node 2 at time 1. Let’s add more
  # edges to g:

  add_edge!( g, 2, 3, 1)

  add_edge!( g, 2, 3, 2)

  add_edge!( g, 2, 4, 2)

  #Now g has 4 nodes, 4 edges and 2 timestamps. Here are the edges we have:


  es = edges( g)

  print( "\n")
  #print( "es = $es \n")
  #print( "\n")

  m1 = matrix( g, 1)
  @printf( "g1 = %s \n", m1)

  m2 = matrix( g, 2)
  @printf( "g2 = %s \n", m2)


  print( "\n")
  
end
#-------------------------------------------------------------------------------

evolving_graph_01( )

#-------------------------------------------------------------------------------



