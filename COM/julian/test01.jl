
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------

using Graphs # это старая, простая версия!

#------------------------------------------------------------------------------


# Graphs.jl is a Julia package that provides graph types and algorithms.
# The design of this package is inspired by the [Boost Graph Library]
# (http://www.boost.org/doc/libs/1_53_0/libs/graph/doc/index.html)

# (*e.g.* using standardized generic interfaces), while taking advantage of
# Julia's language features (*e.g.* multiple dispatch).

#------------------------------------------------------------------------------
function test_00( ) 

  g = simple_graph( 3)
  #
  #Directed Graph (3 vertices, 0 edges)
  
  
  add_edge!(g, 1, 2)   #edge [1]: 1 -- 2
  
  add_edge!(g, 3, 2)   #edge [2]: 3 -- 2
  
  add_edge!(g, 3, 1)   #edge [3]: 3 -- 1
  
  
  plot( g)

end
#-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# 
# 
# 
# ;-------------------------------------------------------------------------------
# proc NODE_set {gr u val} { 

#   set nodes_name [$gr vget -NODES]

#   lset $nodes_name $u $val

# }
# ;-------------------------------------------------------------------------------
# proc NODE_get {gr u} { 

#   return [lindex [$gr.NODES] $u]
# }
# ;-------------------------------------------------------------------------------
function EDGE_set( gr, u, v, val) 

  #   #set edges_name [$gr vget -EDGES]
  #   set edges [$gr.EDGES]

  #   #lset $edges_name $u $val
  #   arr2d_set $edges $u $v "$val"     

  add_edge!( gr, u+1, v+1) 

  
end
# ;-------------------------------------------------------------------------------
# proc EDGE_get {gr u v} { 

#   set edges [$gr.EDGES]

#   return [arr2d_get $edges $u $v]
# }
# ;-------------------------------------------------------------------------------
# proc graf_init_main {gr nn} {  

#   $gr.NN = $nn
  
#   #$gr.EDGES = [make-array [list $nn $nn]]
#   $gr.EDGES = [arr2d_make  $nn $nn]

#   #   (setf (NODES gr) (make-array nn))
#   $gr.NODES = [make_array  $nn "NOS"]
  
#   $gr.WK = [graf_work_create $gr]
  
#   dotimes u $nn { 
#     #     (setf (aref (NODES gr) u) NOS)
#     NODE_set $gr $u "NOS"
#   }
  
#   dotimes u $nn {
#   dotimes v $nn {
#     #     ; ÚÄÅÓØ ÎÁÄÏ ×ÓÔÁ×ÉÔØ ÓÏÚÄÁÎÉÅ ÓÐÉÓËÁ ÒÅÂÅÒ
      
#     #     (setf (EDGE gr u v) NOS)
#     EDGE_set $gr $u $v "NOS"
#   }}
  
# }
# ;-------------------------------------------------------------------------------
function graf_create( nn)

  # # (let (
  # #    gr 
  # #   )
  
  # set gr [make-instance "GRAF"]
  gr = simple_graph( nn)
 
  # graf_init_main $gr $nn  
  
  # return $gr
  return gr
  
end
# ;-------------------------------------------------------------------------------
# proc graf_print {gr} {  

#   set nn [$gr.NN] 
  
#   puts -nonewline [format "------------------------------- \n"]

#   puts "NN    = [$gr.NN]"
#   puts "NODES = [$gr.NODES]"
#   puts "EDGES = [arr2d_print [$gr.EDGES]]"

#   puts -nonewline [format "   | "]

#   dotimes u $nn { 
#     puts -nonewline [format "  %2d " $u]
#   }

#   puts -nonewline [format "\n"]
#   puts -nonewline [format "------------------------------- \n"]
  

#   dotimes u $nn { 

#     puts -nonewline [format "%2d | " $u]

#     dotimes v $nn { 

#       set val [EDGE_get $gr $u $v]

#       if     {$val == "NOS"}         {puts -nonewline [format "  o  "]} \
#       elseif {$val == "YES"}         {puts -nonewline [format "  *  "]} \
#       elseif {[llength $val] > 1}    {puts -nonewline [format "  .  "]} \
#       else                           {puts -nonewline [format " %3.1f " $val]}
      
#     }
    
#     puts -nonewline [format "\n"]
#   }
  
#   puts -nonewline [format "------------------------------- \n"]
  
# }
#-------------------------------------------------------------------------------
function test_01( ) 

  
  #   YRAND_C
  
  #   set gr [graf_create 4]
  gr = graf_create( 4)
  
  EDGE_set( gr, 0, 1,  1)
  EDGE_set( gr, 1, 2,  1)
  EDGE_set( gr, 2, 3,  1)
  EDGE_set( gr, 0, 3,  3.1)  # 3.1 2.9
  
  plot( gr)

  #   NODE_set $gr 0   2.2
  
  #   set s   0
  #   set tar 3
  
  #   puts -nonewline [format "\n"]
  #   graf_print $gr
  
  #   puts ""
  
  #   graf_smin  $gr $s $tar $::NIL
  
  print( "\n")

end
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
