

#-------------------------------------------------------------------------------

# Installation is straightforward:

# julia> Pkg.add("LightGraphs")

#-------------------------------------------------------------------------------

# ......... 
# ......... 

# INFO: Building HDF5
# Installing dependency hdf5-tools via `sudo apt-get install hdf5-tools`:
# sudo: no tty present and no askpass program specified
# Sorry, try again.
# sudo: no tty present and no askpass program specified
# Sorry, try again.
# sudo: no tty present and no askpass program specified
# Sorry, try again.
# sudo: 3 incorrect password attempts
# ====================================[ ERROR: HDF5 ]====================================

# LoadError: failed process: Process(`sudo apt-get install hdf5-tools`, ProcessExited(1)) [1]
# while loading /home/pilot/.julia/v0.5/HDF5/deps/build.jl, in expression starting on line 27

# =======================================================================================
# INFO: Building LightXML

# ===================================[ BUILD ERRORS ]====================================

# WARNING: HDF5 had build errors.

#  - packages with build errors remain installed in /home/pilot/.julia/v0.5
#  - build the package(s) and all dependencies with `Pkg.build("HDF5")`
#  - build a single package by running its `deps/build.jl` script


#Решение: просто доустановил hdf5-tools

# =======================================================================================



#-------------------------------------------------------------------------------

using LightGraphs


# Usage Examples
# (all examples apply equally to DiGraph unless otherwise noted):

#-------------------------------------------------------------------------------
function test_light_graph_01()

  print( "\n")

  # create an empty undirected graph
  #
  g = Graph()

  # create a 10-node undirected graph with no edges
  #
  g = Graph(10)

  print( "g     = $g \n")
  @printf( "nv(g) = %s \n", nv( g))

  @assert nv( g) == 10

  print( "\n")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # create a 10-node undirected graph with 30 randomly-selected edges
  #
  g = Graph( 10, 30)

  # add an edge between vertices 4 and 5
  #
  add_edge!( g, 4, 5)

  # remove an edge between vertices 9 and 10
  #
  rem_edge!( g, 9, 10)

  # create vertex 11
  #
  add_vertex!( g)

  # remove vertex 2
  # attention: this changes the id of vertex nv(g) to 2
  #
  rem_vertex!( g, 2)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # get the neighbors of vertex 4
  #
  neighbors( g, 4)

  # iterate over the edges
  m = 0
  for e in edges( g)
    print( "e = $e \n")
    m += 1
  end

  @assert m == ne( g)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  using Graphs
  using GraphPlot

  g = graphfamous( "karate")    # это из пакета GraphPlot

  plot( g)                      # это из пакета Graph !!

end
#-------------------------------------------------------------------------------

# ERROR: LoadError: MethodError: no method matching dijkstra_shortest_paths(::LightGraphs.Graph, ::Int32, ::LightGraphs.DefaultDistance; distmx=[0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0; … ; 0.0 0.0 … 0.0 0.0; 0.0 0.0 … 0.0 0.0])
# Closest candidates are:
#   dijkstra_shortest_paths{T}(::Union{LightGraphs.DiGraph,LightGraphs.Graph}, ::Int32, ::AbstractArray{T,2}; allpaths) at /home/pilot/.julia/v0.5/LightGraphs/src/shortestpaths/dijkstra.jl:90 got unsupported keyword argument "distmx"
#   dijkstra_shortest_paths{T}(::Union{LightGraphs.DiGraph,LightGraphs.Graph}, ::Array{Int32,1}, ::AbstractArray{T,2}; allpaths) at /home/pilot/.julia/v0.5/LightGraphs/src/shortestpaths/dijkstra.jl:31 got unsupported keyword argument "distmx"
#   dijkstra_shortest_paths(::Union{LightGraphs.DiGraph,LightGraphs.Graph}, ::Int32) at /home/pilot/.julia/v0.5/LightGraphs/src/shortestpaths/dijkstra.jl:90 got unsupported keyword argument "distmx"

#-------------------------------------------------

# # show distances between vertex 4 and all other vertices
# dijkstra_shortest_paths(g, 4).dists

# as above, but with non-default edge distances
#
# distmx = zeros( 10,10)
# distmx[4,5] = 2.5
# distmx[5,4] = 2.5

# dijkstra_shortest_paths(g, 4, distmx=distmx).dists

#-------------------------------------------------------------------------------

# graph I/O
# g = loadgraph("mygraph.jgz", :lg)
# savegraph("mygraph.gml", g, :gml)

#-------------------------------------------------------------------------------

# LoadError: HDF5 not properly installed. Please run Pkg.build("HDF5")

# Решение: просто доустановил hdf5-tools
# 
#-------------------------------------------------------------------------------
  
#-------------------------------------------------------------------------------
function test_10( )

  print( "\n")
  
  
  # create a 10-node undirected graph with no edges
  #
  g = Graph( 3)
  
  print( "g     = $g \n")
  @printf( "nv(g) = %s \n", nv( g))  
  #@assert nv( g) == 10
  
  
  add_edge!(g, 1, 2)   #
  
  add_edge!(g, 3, 2)   #
  
  #add_edge!(g, 3, 1, weight=1.0) # ??
   
  #plot( g)

  print( "\n")
  
end
#-------------------------------------------------------------------------------


test_10( )

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

