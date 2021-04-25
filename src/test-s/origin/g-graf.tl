# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ==============================================================================

# (defconstant GR_CONST 0)
# (defconstant GR_RAND  1)

# ;=============================================================================

# (defclass METKA () (  
# ;  BOOL    fix;
# ;  double  l;
# ;  int     prev;
#   (fix  :accessor FIX)
#   (l    :accessor L)
#   (prev :accessor PREV)
# ))

# record define METKA { 

#   FIX
#   L
#   PREV
# }

# (defclass WORKS () (  
# ;  int     s, t;
#   (s    :accessor S)
#   (tar  :accessor TAR)
# ;  METKA  *met;
# ;  int    *puti;
# ;  double  smin;
#   (met  :accessor  MET)
#   (puti :accessor  PUTI)
#   (smin :accessor  SMIN)
# ))

# record define WORKS { 

#   S
#   TAR
#   MET
#   PUTI
#   SMIN 
# }

# ;//--------------------------

# (defclass GRAF () (  
#   (nn    :accessor NN)
#   (nodes :accessor NODES) ; список значений в узлах
#   (edges :accessor EDGES) ; матрица смежности (веса соответствующих дуг)

# ;  WORKS  *wk;    // надо бы выделять эту память отдельно перед расчетом..
#   (wk    :accessor WK)
# ))

# record define GRAF { 
 
#   NN
#   NODES
#   EDGES
  
#   WK
# }

# ;//--------------------------
# ;(defvar YES  -1001.0)
# (defvar YES  0.0) ; странно, но и с этим значeниeм спокойно отработало

# ;(defvar YES  'YES) ; такая запись как раз прeимущeство Лиспа
#                     ; и сразу выявило ошибку в логикe тeстовых задач..!

# (defvar NOS  'NOT)
#set ::NOS "NOT"

# ;(defvar NOS  -1000.0)

# ;;;=============================================================================
# ;
# ;-------------------------------------------------------------------------------
# (defmacro EDGE (gr u v)  

#   ;(aref (EDGES gr) u v)
#   ;(list 'aref (list 'EDGES gr) u v)

#   `(aref (EDGES ,gr) ,u ,v)
# )
# ;-------------------------------------------------------------------------------
# (defmacro NODE (gr u)  

#   ;(aref (NODES gr) u)
#   (list 'aref (list 'NODES gr) u)

# )
# ;;;=============================================================================
# ;
# ;
# ;
# ;;

# -------------------------------------------------------------------------------
proc graf_init {gr type_nodes nod1 nod2 
                   type_edges edg1 edg2} {

  set nn [dict_get $gr "NN"]
  
  dotimes u $nn {

    NODE_set  $gr $u [YRandF $nod1 $nod2]
    
    dotimes v $nn {
      EDGE_set  $gr $u $v [YRandF $edg1 $edg2]
    }
  }
 
  return
}
# -------------------------------------------------------------------------------
proc graf_init1 {gr r_edge_all r_edge_two} {

  set nn [dict_get $gr "NN"] ;# [$gr.NN]

  dotimes u $nn {
    NODE_set  $gr $u    "YES" ;# все узлы
    EDGE_set  $gr $u $u "YES" ;# ребро само на себя в этом узле
  }
  
  # перебираем все ребра (с учетом симметрии)
  # 
  # for (u = 0; u < gr->nn; u++)
  # for (v=u+1; v < gr->nn; v++) 

  dotimes u $nn {

    if {[NODE_get $gr $u] == "NOS"} {continue} ;# нерабочий узел пропускаем
    
    # смотрим все узлы, больше по номеру текущего

    for {set v [+ $u 1]} {$v <= [- $nn 1]} {incr v} {

      if {[RandYes $r_edge_all]} {

        if {[RandYes $r_edge_two]} {          
          #ребро будет двухнаправленным
          EDGE_set $gr $u $v "YES"
          EDGE_set $gr $v $u "YES"

        } else {
          
          if {[RandYes 50.0]} { 
            # ребро будет в одну сторону
            EDGE_set $gr $u $v "NOS"
            EDGE_set $gr $v $u "YES"
            
          } else { 
            # ребро будет в другую сторону
            EDGE_set $gr $u $v "YES"
            EDGE_set $gr $v $u "NOS"
          }
        }        
        
      } else {
        
        EDGE_set $gr $u $v "NOS"
        EDGE_set $gr $v $u "NOS"
      }
      
  }}

  return
}
# ------------------------------------------------------------------------------- 
# 
# -------------------------------------------------------------------------------
proc NODE_set {gr u val} { 

  set ptr_nodes [dict_get $gr "NODES"]

  lset $ptr_nodes $u $val

}
# -------------------------------------------------------------------------------
proc NODE_get {gr u} { 

  set ptr_nodes [dict_get $gr "NODES"]

  set nodes [set $ptr_nodes]

  return [lindex $nodes $u]
}
# -------------------------------------------------------------------------------
proc EDGE_set {gr u v val} { 

  set edges [dict_get $gr "EDGES"]

  arr2d_set_NEW $edges $u $v "$val"     

}
# -------------------------------------------------------------------------------
proc EDGE_get {gr u v} { 

  set edges [dict_get $gr "EDGES"]

  return [arr2d_get_NEW $edges $u $v]
}
# -------------------------------------------------------------------------------
proc graf_init_main {gr nn} {  

  dict_set $gr "NN" $nn
  
  dict_set $gr "EDGES"  [arr2d_make_NEW  $nn $nn]

  #dict_set $gr "NODES"  [list_make  $nn "NOS"]
  dict_set $gr "NODES"  [list_create_num_val  $nn "NOS"]
  
  dict_set $gr "WK"  [graf_work_create $gr]
  
  dotimes u $nn {
 
    NODE_set $gr $u "NOS"
  }
  
  dotimes u $nn {
  dotimes v $nn {
    #  здесь надо вставить создание списка ребер
      
    EDGE_set $gr $u $v "NOS"
  }}

  return
}
# -------------------------------------------------------------------------------
proc graf_create {nn} { 

  
  #set gr [make-instance "GRAF"]

  set gr [dict_create]
  
  graf_init_main $gr $nn  
  
  return $gr
}
# ;-------------------------------------------------------------------------------
proc graf_print {gr} {  

  set nn    [dict_get $gr "NN"] 
  set nodes [dict_get $gr "NODES"]
  set edges [dict_get $gr "EDGES"]


  puts -nonewline [format "------------------------------- \n"]

  puts "NN    = $nn"

  puts "NODES = $nodes"
  puts "NODES = [set $nodes]"


  arr2d_print_NEW $edges

  puts -nonewline [format "------------------------------- \n"]


  puts "EDGES = "

  puts -nonewline [format "   | "]

  dotimes u $nn { 

    puts -nonewline [format "  %2d " $u]
  }

  puts -nonewline [format "\n"]
  puts -nonewline [format "------------------------------- \n"]
  

  dotimes u $nn { 

    puts -nonewline [format "%2d | " $u]

    dotimes v $nn { 

      set val [EDGE_get $gr $u $v]

      if     {$val == "NOS"}         {puts -nonewline [format "  o  "]} \
      elseif {$val == "YES"}         {puts -nonewline [format "  *  "]} \
      elseif {[llength $val] > 1}    {puts -nonewline [format "  .  "]} \
      else                           {puts -nonewline [format " %3.1f " $val]}
      
    }
    
    puts -nonewline [format "\n"]
  }
  
  puts -nonewline [format "------------------------------- \n"]
  
}
# ;-------------------------------------------------------------------------------
proc graf_work_create {pg} {


  set wk [dict_create] ;# [make-instance "WORKS"]
  set nn [dict_get $pg "NN"]

  #dict_set $wk "PUTI"  [list_make [expr {$nn * $nn}] "@"]
  dict_set $wk "PUTI"  [list_create_num_val [expr {$nn * $nn}] "@"]
  
  #set met [list_make $nn "@"]
  set met [list_create_num_val $nn "@"] ;# лучше ссылку ? 

  dict_set $wk "MET" $met  

  dotimes i $nn {

    #lset [$wk vget -MET] $i [make-instance "METKA"]
    lset $met  $i [dict_create] ;# [make-instance "METKA"]
  }
  
  return $wk
}
# ;-------------------------------------------------------------------------------

set ::FALSE 0
set ::TRUE  1

# ;BOOL
# ;graf_smin (GRAF *gr, int s, int t, double *smin)
# -------------------------------------------------------------------------------
proc graf_smin {gr s tar smin} {

  
  set pg  $gr
  set nn  [dict_get $pg "NN"]
  set wk  [dict_get $pg "WK"]
  
  set met_ptr [dict_get $wk "MET"] ;# указатель на список меток ?
  set met [set $met_ptr]           ;# раскроем указатель
  
  dict_set $wk "S"    $s
  dict_set $wk "TAR"  $tar
  
  #set puti_ptr [$wk vget -PUTI]
  set puti_ptr [dict_get $wk "PUTI"]

  #puts "puti_ptr = $puti_ptr"
  #exit

  if  {$s == $tar} { 

    dict_set $wk "SMIN"  0
    lset $puti_ptr 0  -1

    return
  }
  
  dotimes v $nn {

    set met_v [lindex $met $v]

    dict_set $met_v "FIX"   $::FALSE
    dict_set $met_v "L"     $::YMAXSPACE
    dict_set $met_v "PREV"  -1
  }

  set met_s [lindex $met $s]

  dict_set $met_s "FIX"  $::TRUE
  dict_set $met_s "L"    0
  
  set p $s ;# ??????
  
  #puts ""
  #puts "met   = $met"
  #puts "v = $v  s = $s"
  #puts "met_v = $met_v"
  #puts "met_s = $met_s"
  #puts ""

  #dict_print $met_v
  #puts ""

  #dict_print $met_s
  #puts ""

  #exit

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  while {1} {
 
    dotimes v $nn {
    
      set edge [EDGE_get  $pg $p $v]

      set met_v [lindex $met $v]
      set met_p [lindex $met $p]

      #puts "v = $v  met_v = $met_v"
      #dict_print $met_v
      #puts ""

      #puts "p = $p  met_p = $met_p"
      #dict_print $met_p
      #puts ""

      if {$edge == "NOS"} {continue}     
      if { [dict_get $met_v "FIX"] } {continue}

      set sum [expr {[dict_get $met_p "L"] + $edge}]
      
      if  {[dict_get $met_v "L"] > $sum} {

        dict_set $met_v "L"      $sum
        dict_set $met_v "PREV"   $p
      }
    }
        
    set l_min $::YMAXSPACE
      
    set v_min 0 ;#  !! наверное надо установить что-то ??

    dotimes v $nn {

      set m [lindex $met $v]

      if {[dict_get $m "FIX"]} {continue}
      
      if {[dict_get $m "L"] < $l_min} {
        set l_min [dict_get $m "L"]
        set v_min $v
      }
    }

    set met_v_min [lindex $met $v_min]

    dict_set $met_v_min "FIX"  $::TRUE
    
    set p $v_min

    if  {$p == $tar} {
      break
    }

  }  ;# while
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set p $tar
  set j 0
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  while {1} {

    lset $puti_ptr  $j $p
    incr j

    if {$p == $s} {break}

    set met_p [lindex $met $p]

    set p [dict_get $met_p "PREV"]

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #lset [$wk vget -PUTI] $j  -1
  lset [dict_get $wk "PUTI"] $j  -1
  
  set met_tar [lindex $met $tar]

  dict_set $wk "SMIN"  [dict_get $met_tar "L"]
  
  if {$smin == $::NUL}  {graf_work_print $wk}

  
}
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;graf_all_smin (GRAF *gr, int s, double *all)
# ;-------------------------------------------------------------------------------
proc graf_all_smin {gr s &ret} {

  #USE_REFS
  upvar ${&ret} ret

  set nn  [dict_get $gr "NN"]
  set num  $nn     ;# счетчик необработанных еще узлов 

  set u 0 ;# ?? этого нe было 
  

  set lis [list_make $nn "@"] ;# вспомогательный список для флажков в узлах
  
  dotimes v $nn { 
    lset lis $v  $::TRUE
  }
  
  # устанавливаем пока в рез.список значения расстояний по прямой как начальные
  # или ::MAXVAL, если нет ребра
  # 
  dotimes v $nn {

    set edge [EDGE_get  $gr $s $v]
    lset ret $v $edge 

    if {$edge == "NOS"} {
      lset ret $v $::MAXVAL
   } 
  }
  
  lset ret $s  0        ;# для самого стартового узла smin = 0      
  lset lis $s  $::FALSE ;# и флажок FALSE
  incr num -1           ;# т.е. еще один узел обработали           
  
  
  #   (loop while (/= num 0) do  ; !!!!! вот гдe была ошибка !!!!
  while {1} {
  
    if {$num == 0} {break} ;# все узлы обработанны

    set mini $::MAXVAL

    dotimes v $nn {
      if {[lindex $lis $v] == $::FALSE} {continue}
      
      # идем циклом по всем еще необработанным узлам
      # и ищем узел с минимальным расстоянием ?

      set ret_v [lindex $ret $v]

      if {$ret_v < $mini} { 
        set u    $v      ;# найденный ближайший узел
        set mini $ret_v  ;# и расстояние до него 
      }
    }
    
    lset lis $u  $::FALSE ;# флажок FALSE в этот обработанный узел
    incr num -1  ;# т.е. еще один узел обработали
    
    dotimes v $nn {
      if {[lindex $lis $v] == $::FALSE} {continue}
      
      # идем циклом по всем еще необработанным узлам
      # и смотри все ребра из найденного узла

      set val_uv [EDGE_get  $gr $u $v]
      
      if {$val_uv == "NOS"}  {set val_uv $::MAXVAL}

      set ret_u [lindex $ret $u]
      set ret_v [lindex $ret $v]

      lset ret $v   [expr {min ($ret_v,  $ret_u + $val_uv)}]
    }    

  } ;# while {1}

  return
}
# -------------------------------------------------------------------------------
proc graf_new_node {gr} {

  set u_find "NIL"
  
  dotimes  u [dict_get $gr "NN"] { ;# ищeм нeзанятый узeл в структурe графа

    if  {[NODE_get  $gr $u] == "NOS"} { 

      set u_find $u
      break
    }
  }
  
  
  return $u_find ;# eсли нe найдeн, то вeрнтся NIL

  # ;  if (u == gr->nn) {
  # ;    return (FALSE);
  # ;  }
  
  # ;  if (pu) *pu = u;
  # ;  return (TRUE);
  
}
# -------------------------------------------------------------------------------
proc graf_work_print {wk} {

  
  puts -nonewline [format "--------------------------\n"]

  puts -nonewline [format "S = %d \n"     [dict_get $wk "S"   ]]
  puts -nonewline [format "T = %d \n"     [dict_get $wk "TAR" ]]
  puts -nonewline [format "L_min = %s \n" [dict_get $wk "SMIN"]]
  
  set puti_ptr [dict_get $wk "PUTI"] ;# указатель на список
  set puti     [set $puti_ptr]

  for {set v 0} {[lindex $puti $v] != -1} {incr v} {
  }
  set num $v ;# посчитали размер списка ? до ограничителя -1

  for {set v [- $num 1]} {$v >= 0} {incr v -1} {

    puts -nonewline [format "%d" [lindex $puti $v]]

    if {$v != 0} {
      puts -nonewline "_"
    }
  }

  puts -nonewline [format "\n------------------------\n"]
  
}
# -------------------------------------------------------------------------------
proc graf_re_max {old} {


  set old_nn [dict_get $old "NN"] 

  set new_nn [int [* $old_nn 1.25]] ;# увеличиваем размер !

  puts stderr "graf_re_max:  old_nn = $old_nn  new_nn = $new_nn"
  puts ""

  set new_gr [graf_create  $new_nn] ;# создаем новый граф такого размера
  
  # перекопируем все узлы
  
  dotimes u $old_nn {

    set node [NODE_get  $old $u]

    #puts "u = $u   node = $node"

    NODE_set  $new_gr $u $node
  }
  
  # перекопируем все ребра
  
  dotimes u $old_nn {
  dotimes v $old_nn {

    EDGE_set  $new_gr $u $v [EDGE_get  $old $u $v]
  }}
  
  dict_set $old "NODES"  [dict_get $new_gr "NODES"]
  dict_set $old "EDGES"  [dict_get $new_gr "EDGES"]
  dict_set $old "NN"     [dict_get $new_gr "NN"]

}
# -------------------------------------------------------------------------------
proc graf_del_node {gr u} {

  # ;  if (u < 0 || u >= gr->nn)  return (FALSE);
  # ;  if (NODE (gr, u) == NOS)   return (FALSE);
  
  NODE_set  $gr $u  "NOS"
  
  # убираем все ребра из этого удаляемого узла

  set nn [dict_get $gr "NN"]

  dotimes v $nn {

    EDGE_set  $gr $u $v "NOS"
  }
  
  # ;  return (TRUE);
}
# ;-------------------------------------------------------------------------------
proc graf_edges_copy {gr_from u_from  gr_to u_to} {

  # ;  int v;
  # ;  //double edge;
  
  # ;  //for (v=0; v < gr_from->nn; v++) { // только односторонние?
  # ;  //  EDGE (gr_to, u_to, v) = EDGE (gr_from, u_from, v);
  # ;  //}
  
  # ;  for (v=0; v < gr_from->nn; v++) { 
  # ;    if (u_from == v) continue;
  
  # ;    if (EDGE(gr_from,u_from,v)==YES) EDGE(gr_to,u_to,v) = EDGE(gr_from,u_from,v);
  # ;    if (EDGE(gr_from,v,u_from)==YES) EDGE(gr_to,v,u_to) = EDGE(gr_from,v,u_from);
  # ;  }
  

  dotimes  v [dict_get $gr_from "NN"] {

    if  {$u_from == $v} {continue} 
    
    if  {[EDGE_get $gr_from $u_from $v] == "YES"} { 

      EDGE_set $gr_to $u_to $v   [EDGE_get $gr_from $u_from $v]
    }
    
    if {[EDGE_get $gr_from $v $u_from] == "YES"} { 

      EDGE_set $gr_to $v $u_to  [EDGE_get $gr_from $v $u_from]
    }
  }
  
}
# ;-------------------------------------------------------------------------------
proc graf_all_to_node {gr node} {

  set new_node [graf_add_node $gr "YES"]
  
  #puts stderr "graf_all_to_node:  ............................... "
  #puts stderr "graf_all_to_node:  node = $node"
  
  dotimes u [dict_get $gr "NN"] {

    #   (unless (eql node u)
    if {$node == $u} {continue}
    
    # ;    if ((EDGE(gr, node,u)==NOT) && (EDGE(gr, u,node)==NOT)) continue;
    # ;    // нашли непустой узел - соседа "u"
    
    #     (unless (and (eql (EDGE gr node u) NOS) (eql (EDGE gr u node) NOS))

    set e1 [EDGE_get $gr $node $u]
    set e2 [EDGE_get $gr $u $node]

    if {($e1 == "NOS") && ($e2 == "NOS")} {continue}
    
    graf_edges_copy  $gr $u $gr $new_node ;# // скопировать-добавить
 
    #puts stderr "graf_all_to_node:  u = $u"
    graf_del_node    $gr $u              ;# // удалили за ненадобностью

  }
  
  graf_del_node $gr $node ;# теперь удалили и сам исходный узел 

}
# ;-------------------------------------------------------------------------------
proc graf_copy {gr gr_new} {

  set nn [dict_get $gr "NN"]

  dotimes  u $nn {

    NODE_set  $gr_new $u  [NODE_get  $gr $u]
    
    dotimes  v $nn {
      EDGE_set   $gr_new  $u $v  [EDGE_get  $gr $u $v]
    }
  }
  
  return
}
# ;-------------------------------------------------------------------------------
proc graf_get_num_nodes {gr} {

  set num_nodes 0
  
  dotimes  u [dict_get $gr "NN"] {

    if {[NODE_get $gr $u] == "NOS"} {continue}

    incr num_nodes
  }
  
  return $num_nodes
}
# -------------------------------------------------------------------------------
proc graf_edges_fill {gr u edge} {

  dotimes v [dict_get $gr "NN"] {

    EDGE_set $gr $u $v  $edge
  }

}
# -------------------------------------------------------------------------------
proc graf_add_node {gr node} {

  set u [graf_new_node $gr]
  
  if  {$u == "NIL"} {

    set  u [dict_get $gr "NN"]
    graf_re_max $gr ;# увеличили размер
  }
  
  NODE_set $gr $u  $node
  
  return $u
}
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;graf_get_edges (GRAF *pgr, double *pedge, int *pu, int *pv)
# ;{
# ;  static int    u, v, nn;
# ;  static GRAF   *pg;
# ;  static double *pedge_mem;
# ;  static int    *pu_mem, *pv_mem;

# ;  double edge;

# ;  if (pgr != NULL) {
# ;    pg = pgr;
# ;    pedge_mem = pedge;
# ;    pu_mem = pu;
# ;    pv_mem = pv;

# ;    u = 0;
# ;    v = 1;
# ;    nn = pg->nn;

# ;    return (TRUE);
# ;  }
# ;	//-----------------

# ;  while (TRUE) {
# ;    if (v >= nn) {
# ;      u++;
# ;      v = u + 1;
# ;    }
# ;    if (u >= nn - 1)
# ;      return (FALSE);

# ;    edge = EDGE (pg, u, v);
# ;    v++;
# ;    if (edge != NOT)
# ;      break;
# ;  }

# ;	//printf ("edge = %f \n", edge);

# ;  if (pedge == NULL)  pedge = pedge_mem;
# ;  if (pu == NULL)     pu = pu_mem;
# ;  if (pv == NULL)     pv = pv_mem;

# ;  if (pedge != NULL)  *pedge = edge;
# ;  if (pu != NULL)     *pu = u;
# ;  if (pv != NULL)     *pv = v - 1;

# ;  return (TRUE);
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;graf_get_num_edges (GRAF *gr, int *one_edges, int *two_edges, int *all_edges)
# ;-------------------------------------------------------------------------------
proc graf_get_num_edges {gr} {

  set num_one_edges 0
  set num_two_edges 0
  
  # ;  for (u = 0; u < gr->nn; u++)
  # ;  for (v=u+1; v < gr->nn; v++) 
  
  set nn [dict_get $gr "NN"]

  dotimes u $nn {

    for {set v [expr {$u + 1}]} {$v <= [expr {$nn - 1}]} {incr v} {
    
      set e1 [EDGE_get $gr $u $v]
      set e2 [EDGE_get $gr $v $u]

      if {($e1 == "NOS") && ($e2 == "NOS")} {continue}
    
      if {($e1 != "NOS") && ($e2 != "NOS")} {       
        #           ;(format t "two_edges: ~2d ~2d [~s ~s] ~%" u v (EDGE gr u v) (EDGE gr v u))
        incr num_two_edges    
      } else {
        #           ;(format t "one_edges: ~2d ~2d [~s ~s] ~%" u v (EDGE gr u v) (EDGE gr v u))
        incr num_one_edges
      }
       
    }   
  }
  
  set num_all_edges [expr {$num_one_edges + $num_two_edges}]
  
  #return [list 7 2 9]

  return [list $num_one_edges $num_two_edges $num_all_edges]
}
# -------------------------------------------------------------------------------
proc print_all_smin {pg i all} {


  puts -nonewline [format "ALL(%d) =  " $i]
  
  dotimes j [dict_get $pg "NN"] {

    set all_j [lindex  $all $j]

    if {$all_j == $::MAXVAL} {  
      puts -nonewline [format "MAXVAL "]

    } else {
      puts -nonewline [format "%.5f " $all_j]      
    }
  }
  
  puts -nonewline [format "\n"]
 
  return
}
# -------------------------------------------------------------------------------
proc graf_metrica {pg} {

  set all [list_make 10000 "@"]
  
  set r     $::MAXVAL ;# радиус
  set d     $::MINVAL ;# окраина
  set num_r 0      ;# количество узлов в центре
  set num_d 0      ;# количество узлов на окраине
  
  set nn [dict_get $pg "NN"]

  dotimes  i $nn {

    # кратчайшие расстояния от этой вершины до остальных
    # 
    graf_all_smin  $pg $i all
    
    # ищем эксцентриситет этой вершины
    # 
    set e $::MINVAL
    
    # напeчатаeм список кратчайших расстояний
    # (print_all_smin pg i all)
    
    dotimes j $nn {      
      if {$i == $j} {continue}

      set all_j [lindex $all $j]

      if {$all_j == $::MAXVAL} {continue}

      set e [max  $e $all_j]
    }
     
    #----------------------------------------------------
    if       {$e <  $r} { # ищем радиус
      set     r  $e
      set  num_r  1

    } elseif {$e == $r} { # и считаем кол-во таких центральных точек
      incr num_r
    }
    #----------------------------------------------------

    #----------------------------------------------------
    if       {$e >  $d} { # ищем диаметр 
      set     d  $e
      set  num_d  1

    } elseif {$e == $d} { # и считаем кол-во таких окраиных точек
      incr num_d
    }
    #----------------------------------------------------

  }
  
  return [list $r $d $num_r $num_d]
}
# -------------------------------------------------------------------------------
proc graf_check {gr {is_print 0}} {


  if {$is_print} {

    puts "graf_check .............. BEG"
    puts ""
    graf_print $gr
  }
  
  set nn [dict_get $gr "NN"]

  # идeм циклом по всeм рeбрам --------------------------------------
  #
  dotimes u $nn {
  dotimes v $nn {

    set edge [EDGE_get  $gr $u $v]

    if {$edge== "NOS"} {continue}   

    if {$is_print} {

      # печатаем реальные ребра
      # 
      puts [format "%2d -> %2d  (%s) " $u $v  $edge]
    }
    
    set nu [NODE_get  $gr $u] ;# один   конец ребра
    set nv [NODE_get  $gr $v] ;# другой конец

    if {($nu == "NOS") || ($nv == "NOS")} { 

      if {$is_print} {

        # нет конца(ов) у существующего ребра, значит "удалить" ребро:
        #
        puts [format "not nodes for this edge: %2d - %2d  (%s %s) " $u $v \
                [NODE_get  $gr $u] [NODE_get $gr $v]]
      }
      
      EDGE_set  $gr $u $v  "NOS"
    }

  }}
    
  
  # идeм циклом по всeм дeйствующим узлам --------------------------
  #
  dotimes  u $nn {

    if  {[NODE_get  $gr $u] == "NOS"} {continue}    

    set exist_edges $::FALSE
    
    # провeряeм всe рeбра для этого узла

    dotimes v [dict_get $gr "NN"] {

      if  {[EDGE_get  $gr $u $v] != "NOS"} {
        set exist_edges $::TRUE
      }
    }
    
    # для существующего узла нет ни одного ребра, значит "удалить" узел:
    #
    if  {! $exist_edges} { 
      NODE_set  $gr $u "NOS"
    }
  }
  #
  # конец цикла ----------------------------------------------------

  if {$is_print} {
    puts ""
    puts "graf_check.............. END  "
    puts ""
  }

  return
}
# ===============================================================================
# 
# 
# -------------------------------------------------------------------------------
proc test_11_NEW {} {  

  srandom_set 2010 ;# пусть пока так !!
  
  set nn 6
  set gr [graf_create $nn]
  
  graf_init $gr "GR_RAND" 0.0 5.0 "GR_RAND" 0.0 5.0
  
  puts ""
  graf_print $gr
  puts ""
  
  foreach {r d num_r num_d}  [graf_metrica $gr] {}

  puts -nonewline [format "r = %5f  num_r = %s \n"  $r $num_r]
  puts -nonewline [format "d = %5f  num_d = %s \n"  $d $num_d]

  puts ""
  
  return
}
# -------------------------------------------------------------------------------
proc test_99_NEW {} {

  set ret [list_make 10000 "@"] ;# рабочий массив ? зачем такой большой ?
  
  YRAND_C
  
  set gr [graf_create 4]
  
  EDGE_set  $gr 0 1  1
  EDGE_set  $gr 1 0  1
  
  EDGE_set  $gr 1 2  1
  EDGE_set  $gr 2 1  1
  
  EDGE_set  $gr 2 3  1 
  EDGE_set  $gr 3 2  1 
  
  EDGE_set  $gr 0 3  1  
  EDGE_set  $gr 3 0  1  

  #    0 -- 1
  #    |    |
  #    3 -- 2
  
  puts ""
  graf_print $gr
  puts ""
  
  
  dotimes i [dict_get $gr "NN"] {

    graf_all_smin  $gr $i  ret ;# кратчайшие расстояния от этой вершины до остальных

    print_all_smin $gr $i $ret 
  }
  
  puts ""
}
# -------------------------------------------------------------------------------
proc test_01_NEW {} { 
  
  YRAND_C
  
  set gr [graf_create 4]

  EDGE_set $gr 0 1  1
  EDGE_set $gr 1 2  1
  EDGE_set $gr 2 3  1
  EDGE_set $gr 0 3  3.1 ;#3.1 2.9
  
  NODE_set $gr 0   2.2
  
  set s   0
  set tar 3

  puts -nonewline [format "\n"]
  graf_print $gr

  puts ""
  dict_print $gr
  puts ""

  # TODO
  #
  graf_smin  $gr $s $tar $::NIL
  
  puts ""
}
# -------------------------------------------------------------------------------
proc test_05_NEW {} {

  # (let (
  #   gr ;u
  #   )
  
  set ::simp_random 1   ;# для точного сравнения с LISP

  set gr [graf_create 4]
  
  graf_init1  $gr 50.0 50.0
  
  puts ""

  graf_print $gr
  
  puts ""
}
# ===============================================================================
# 
# 
# -------------------------------------------------------------------------------
proc test_00_NEW {} {

  set nn 4
  
  set ::simp_random 1   ;# для точного сравнения с LISP

  set gr [graf_create $nn]
  
  graf_init1  $gr 50.0 50.0

  # -----------------------------------------------------------------
  puts ""
  graf_print $gr 
  puts ""

  puts "------------------------------------------------------------"
  puts "GRAF_RE_MAX"
  puts "------------------------------------------------------------"
  puts ""
 
  graf_re_max $gr ;# попробуем просто увеличить размер

  graf_print $gr
  puts ""
  
  #exit

  puts "------------------------------------------------------------"
  puts "GRAF_ADD_NODE (2 nodes, u5 = 555 and u6 = 555)"
  puts "------------------------------------------------------------"
  puts ""

  set u5 [graf_add_node $gr "YES"]
  graf_edges_fill $gr $u5 555 ;# для всех ребер из этого узла

  set u6 [graf_add_node $gr "YES"]
  graf_edges_fill $gr $u6 666 ;# для всех ребер из этого узла
 
  graf_print $gr
  puts ""
  
  puts "------------------------------------------------------------"
  puts "GRAF_DEL_NODE (u5 with edges)"
  puts "------------------------------------------------------------"
  puts ""

  graf_del_node $gr $u5

  graf_print    $gr
  puts ""
  
  puts "------------------------------------------------------------"
  puts "GRAF_DEL_NODE (u5 without edges)"
  puts "------------------------------------------------------------"
  puts ""

  #graf_del_node $gr $u6
  NODE_set $gr $u6  "NOS"

  graf_print    $gr
  puts ""
  
  puts "------------------------------------------------------------"
  puts "GRAF_CHECK"
  puts "------------------------------------------------------------"
  puts ""

  graf_check $gr 1 ;# проверяем корректность соединений узлов и ребер!

  #graf_print $gr
  puts ""
  
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# g~.tl GRAF test_00 
# g~.tl GRAF test_01 
# g~.tl GRAF test_05 
# g~.tl GRAF test_99 
# g~.tl GRAF test_11 

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

