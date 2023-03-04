# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;=============================================================================


set ::is_meta_saving 0 ;# по умолчанию ничего не сохраняем ?

#set ::NEW 0

# ;=============================================================================


# ;typedef struct {
# ;  int      numw;   // номер фрейма для вывода графика
# ;  char    *legend; // имя графика
# ;  BOOL     val;    // флажок расчета
# ;  double  *f;      // для формирования данных
# ;} ZT_OUT;

#-------------------------------------------------------------------------------
proc tao_prepare_and_draw_plot_to_console {tao} {

  puts ""
  puts "tao_prepare_and_draw_plot_to_console .."
  puts ""

  set plot [GET $tao "P_LOT"]

  # здесь надо бы установить соответсвие  xnum = xnum_real (L_XNUM)
  # 
  # set x_line [get_step_xlist_NEW $plot  $ti $fi] 
  # set xnum_real [llength $x_line] ;# ... ... .... . ..........

  # dict_set $tao "P_LOT" "L_XNUM" $step


  puts "" 
  plot_print_one_NEW $plot 0 ;# OK !!!!!
  
  return $plot
}
#-------------------------------------------------------------------------------
proc draw_plot_to_gui {plot} {


  flush stdout
  flush stderr
  
  # сохраняем в файл и потом из него печатаем
  # 
  puts ""
  puts ""
  
  plot_save_NEW  $plot "./t_save.pl"    
  
  # чмиаем локально сохраненный файл  t_save.pl
  #   
  # run_command "COMPOT/src/dialog/d_plot.tk 6 > /dev/null" ;# отдельной программой!
  # run_command "COMPOT/src//common/d_plot.tk 6 > /dev/null" ;# отдельной программой!
  run_command "COMPOT/COM/dialog/d_plot.tk 6 > /dev/null" ;# отдельной программой!
  
  #plot_print_gui_NEW $plot ;# можно и так, но тогда это уже будет графическая
  # программа ! а не хотелось бы ?                     

}
#-------------------------------------------------------------------------------
proc tao_calc_FINAL {tao} {

  set step [GET $tao "STEP"]

  # XNUM
  dict_set $tao "P_LOT" "L_XNUM" $step

  set plot [tao_prepare_and_draw_plot_to_console $tao]

  puts ""
  puts ""
  puts ""


  return
}
#--------------------x-----------------------------------------------------------
proc plot_find_func_by_name {plot fname} {

  
  # вложенный словарь крайнего уровня
  # 
  set d [dict_get $plot "FUNCS"]

  dict for {key val} $d {

    set name [dict get $val "L_NAME"]

    if {$name == $fname} {return $key}
  }

  return -1
}
#--------------------x-----------------------------------------------------------
proc plot_set_x_y {plot fname x y} {


  set f [plot_find_func_by_name $plot $fname]

  dict_set $plot "T_0" "F_$f" $x $y 

}
#--------------------x-----------------------------------------------------------
proc get_flag {plot fname} {


  set f [plot_find_func_by_name $plot $fname]

  if {$f == -1} {
    return 0
  } else {
    return 1
  }

}
#--------------------x-----------------------------------------------------------
proc tao_calc_OUTS {tao l_step} {


  set gr     [GET $tao "GR"]
  set xnum   [GET $tao "NUMS"]

  set p_lot  [GET $tao "P_LOT"] ;# новый вариант сбора в словаре !!!


  # /*------- количесиво узлов в графе ----*/

  set nodesflag [get_flag $p_lot "Nodes"]

  if {$nodesflag} {

    set num_nodes [graf_get_num_nodes $gr]

    plot_set_x_y  $p_lot "Nodes"  $l_step $num_nodes 
  }


  # /*------ количесиво ребер в графе -----*/

  set oneedgesflag [get_flag $p_lot "OneEdges"]
  set twoedgesflag [get_flag $p_lot "TwoEdges"]
  set alledgesflag [get_flag $p_lot "AllEdges"]


  if {$oneedgesflag || $twoedgesflag} {
     
    foreach  {num_one_edges  num_two_edges  num_all_edges} \
      [graf_get_num_edges  $gr] {break}
    

    if {$oneedgesflag} {
      plot_set_x_y  $p_lot "OneEdges"  $l_step  $num_one_edges 
    }

    if {$twoedgesflag} {
      plot_set_x_y  $p_lot "TwoEdges"  $l_step  $num_two_edges 
    }

    if {$alledgesflag} {
      plot_set_x_y  $p_lot "AllEdges"  $l_step $num_all_edges 
    }
  }
  

  #------------------------------------------
  # более развернутый тест:
  #

  set flagrmin [get_flag $p_lot "Rmin"]

  #------------------------------------------
  if {$flagrmin} {
  #------------------------------------------

    set flagrmax   [get_flag $p_lot "Rmax"]


    set flagnminus [get_flag $p_lot "Nminus"]
    set flagnplus  [get_flag $p_lot "Nplus"]
    set flagnnull  [get_flag $p_lot "Nnull"]

    set flagsum    [get_flag $p_lot "Sum"]
    set flagmetr   [get_flag $p_lot "Metr"]

    set flagr      [get_flag $p_lot "R"]
    set flagd      [get_flag $p_lot "D"]
    set flagnumr   [get_flag $p_lot "NumR"]
    set flagnumd   [get_flag $p_lot "NumD"]

    #--------------------------------------------

    set nminus 0
    set nplus  0
    set nnull  0
    
    set rmin   1000000
    set rmax  -1000000
    set sum    0
    

    dotimes u [GET $gr "NN"] {
    dotimes v [GET $gr "NN"] {
        
      if {[EDGE_get $gr $u $v] == "NOS"} {continue}
      
      set value [EDGE_get $gr $u $v]
      
      # небольшой трюк:
      # 
      if {$value == "YES"} {set value 0.0} 
    
      
      set rmin [MIN $rmin $value]  ;#expected floating-point number but got "YES"
      set rmax [MAX $rmax $value]
      
      
      if {$value <  0}  {incr nminus}
      if {$value >  0}  {incr nplus}
      if {$value == 0}  {incr nnull}
      
      incf sum $value
      #incr sum [expr 1.0 * $value] ;# expected integer but got "0.0"
    }}    
    
    if {$flagrmin}   {
      plot_set_x_y  $p_lot "Rmin"  $l_step $rmin 
    }

    if {$flagrmax}   {
      plot_set_x_y  $p_lot "Rmax"  $l_step $rmax 
    }

  }
  #----------------------------------------------------------

  #----------------------------------------------------------
  if {0} {

    if {$flagnminus} {
      #OUTINT   out_nminus $nminus $l_step
      #Out_set  $p_out     "Nminus" $out_nminus 
    }

    if {$flagnplus}  {
      #OUTINT   out_nplus  $nplus  $l_step
      #Out_set  $p_out     "Nplus"  $out_nplus 
    }


    if {$flagnnull}  {
      #OUTINT   out_nnull  $nnull  $l_step
      #Out_set  $p_out     "Nnull"  $out_nnull 
    } 
 

    if {$flagsum}   {
      #OUTDBL $out_sum  $sum  $l_step
      # ???
    }

    # должно быть: 
    #
    # 0   0 100   OK
    # 1   0  99
    # 1   1  98


    if {$flagmetr}  {
      set metr 0
      #OUTINT $out_metr $metr $l_step
    }
  

    foreach {r d num_r num_d}  [graf_metrica  $gr]   {}
  
    if {$flagr}      {
      #OUTDBL out_r $r $l_step
      #Out_set  $p_out "R"  $out_r
    }

    if {$flagd}      {
      #OUTDBL out_d $d $l_step
      #Out_set  $p_out "D"  $out_d
    }  

    if {$flagnumr}   {
      #OUTINT out_numr $num_r $l_step
      #Out_set  $p_out "NumR"  $out_numr
    }
    if {$flagnumd}   {
      #OUTINT out_numd $num_d $l_step
      #Out_set  $p_out "NumD"  $out_numd
    }

  

    #if  {[OUTFLAG $out_metr]}  {set metr 0}

    #       ;(format t "2..... ~%")
    # ;  // Ошибка при маленьких размерностях ???
    
    # ;    for (i=0;   i <= gr->nn-3; i++)	/*??? */
    # ;    for (j=i+1; j <= gr->nn-2; j++)
    # ;    for (k=j+1; k <= gr->nn-1; k++) {
    # ;      i_j = EDGE (gr, i, j);
    # ;      j_k = EDGE (gr, j, k);
    # ;      k_i = EDGE (gr, k, i);
    
    # ;      if ((i_j <= k_i + j_k) && (j_k <= i_j + k_i) && (k_i <= j_k + i_j))
    # ;        metr++;
    # ;    }
    #       )
    
    #   )
    # ;  /*--------------------------------------*/
    

  #------------------------------------------
  } ;# flag
  #------------------------------------------
  #----------------------------------------------------------


  return
}
#-------------------------------------------------------------------------------
proc tao_calc_MAIN_OUTS {tao {to_term 1}} {


  # счетчик шагов все же не надо внутррь расчета параметров графа !?
  # 
  set  l_step [GET $tao "STEP"]


  if {$to_term} {puts -nonewline [format "%3d)  " $l_step]}

  tao_calc_OUTS $tao $l_step

  if {$to_term} {puts -nonewline [format "\n"]}


  incr l_step

  SET $tao "STEP" $l_step 

}
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;int
# ;tao_find_new_node (GRAF *gr, int cur_node)
# ;{
# ;  int u;

# ;  for (u = 0; u < gr->nn; u++) {
# ;    if (EDGE (gr, cur_node, u) == NOT) continue;
# ;    if (RandYes(80.0)) continue;

# ;    //new_node = u;
# ;    break;
# ;  }
# ;  //new_node = YRAND (0, gr->nn-1);

# ;  return (u);
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;tao_edges_mutaciq (GRAF *gr, int u, double mutaciq)
# ;-------------------------------------------------------------------------------
# (defun tao_edges_mutaciq (gr u mutaciq)

# (let (
# ;  int v;
#   edge ;  double edge;
#   )

#   (dotimes (v (NN gr))
#     (setf edge (EDGE gr u v))

#     (when (and (RandYes mutaciq) (eql edge YES))
#       ;(format t "Mutaciq: ~2d ~2d ~%" u v)
#       (setf edge NOS)
#       )

#     (setf (EDGE gr u v) edge)
#     )

# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;tao_addnode_copys (GRAF *gr, GRAF *gr_new, int cur_node)
# ;-------------------------------------------------------------------------------
# (defun tao_addnode_copys (gr gr_new cur_node)

# (let (
#   (new_node (graf_add_node  gr_new YES))
#   )

#   (graf_edges_copy  gr cur_node  gr_new new_node)

#   (tao_edges_mutaciq  gr_new new_node 10.0)
				
#   (when (RandYes 30) 
#     ;(format t "RandYes: ~2d ~2d ~%" cur_node new_node)
#     (setf (EDGE gr_new cur_node new_node) YES))

#   (when (RandYes 30)  
#     ;(format t "RandYeS: ~2d ~2d ~%" new_node cur_node)
#     (setf (EDGE gr_new new_node cur_node) YES))

# ))
#-------------------------------------------------------------------------------
proc tao_addnode_clone_NEW {gr node} {

  set s [list_make 100] 
  
  
  # инициализация списка
  #
  set index 0

  # puts "index = $index"
  
  #  клонируем входы-выходы и составляем их список

  for {set u 0} {$u < [GET $gr "NN"]} {incr u} {

    # это число вычисляeтся один раз пeрeд циклом ??
    # а в Си это нe так !!
    
    if { [EDGE_get $gr $u $node] == "NOS"} { continue }
    if { [EDGE_get $gr $node $u] == "NOS"} { continue }
    
    # клонирование и копирование

    set new_node [graf_add_node $gr "YES"]

    # здeсь получаeтся нe слишком опрeдeлeнн, поскольку размeр графа 
    # можeт увeличиваться!
    # 
    # раскоммeнтировать пeчать в "graf_re_max"
    

    EDGE_set $gr $new_node $u   [EDGE_get $gr $node $u]
    EDGE_set $gr $u $new_node   [EDGE_get $gr $u $node]
    
    # заносим в список номер нового узла
    #
    setf_nth  $index s  $new_node

    incr index
  }

  #set indexr 55555555555

  setf_nth  $index  s  -1 ;# /завершить "виртуальный" список
  
  #puts "s = $s"
  #exit

  # распeчатать список 
  # соединить каждую точку с каждой (простейший вариант)

  for {set i 0} {1} {incr i} {

    set si [lindex $s $i]
    if {$si == -1} {break}

    for {set j 0} {1} {incr j} {
      
      set sj [lindex $s $j]
      
      #puts ""
      #puts "si = $si   sj = $sj"
      #puts ""
      
      if {$sj == -1} {break}
      
      EDGE_set $gr $si $sj  "YES"
      EDGE_set $gr $sj $si  "YES"
      
    }
  }
  
  # удаляем начальную точку ; а зачeм тогда клонировали?
  #
  graf_del_node  $gr $node
  
  #   ;(format t "tao_addnode_clone ........END ~%")

}
#-------------------------------------------------------------------------------
proc tao_addnode_NEW {addnode_type gr_old gr_new node} {
  

  # простое копирование с мутацией
  #
  if {$addnode_type == 1}  {tao_addnode_copys_NEW  $gr_old $gr_new $node}
  
  # раздувание-клонирование
  #
  if {$addnode_type == 2}  {tao_addnode_clone_NEW          $gr_new $node}
  
  # для начального тeста
  #
  if {$addnode_type == 3}  {graf_add_node_NEW              $gr_new  "YES"}
  
}
#-------------------------------------------------------------------------------
proc tao_delnode_NEW {delnode_type gr node} {

  #puts stderr ""
  #puts stderr "tao_delnode:  ............................... "
  #puts stderr "tao_delnode:  delnode_type = $delnode_type"
  #puts stderr "tao_delnode:  node         = $node"
  #puts stderr ""

  # простое удаление (вместе со связями)
  #
  if {$delnode_type == 1} { 
 
    graf_del_node $gr $node
  }
  
  # перевод стрелочек и простое удаление 
  #
  if {$delnode_type == 2} {
  
    graf_sub_node  $gr $node
    graf_del_node  $gr $node
  }
  
  # удаление со стягиванием в этот узел (не много ли удаляется?)
  #
  if {$delnode_type == 3} {
  
    graf_all_to_node $gr $node
  }
  
  return
}
#-------------------------------------------------------------------------------
proc tao_what_do {gr_new cur_node} {

  
  set do_add  50
  set do_del  40
  set do_not  [expr {(100 - ($do_add + $do_del))}]
  
  set ret [Rand123 $do_add $do_not $do_del]
  
  return $ret
}
# -------------------------------------------------------------------------------
proc tao_bestday_NEW {gr} {


  set node [graf_add_node $gr "YES"]
  
  EDGE_set $gr $node $node "YES"
  
}
#-------------------------------------------------------------------------------
proc incf_EDGE {gr p1 p2} {

  set e [EDGE_get $gr $p1 $p2]

  set e [expr {$e + 1}]

  EDGE_set $gr $p1 $p2  $e

}
#-------------------------------------------------------------------------------
proc decf_EDGE {gr p1 p2} {

  set e [EDGE_get $gr $p1 $p2]

  set e [expr {$e - 1}]

  EDGE_set $gr $p1 $p2  $e

}
#-------------------------------------------------------------------------------
proc get_p_out_by_mode {out_mode} { 

  
  set p_out_min [list  \
               {1 "Nodes"  1  NIL} \
               \
               {2 "Rmax"   1  NIL} \
               {2 "Rmin"   1  NIL} \
              ]

  #   (p_out_add (list 
  
  #     '(3 "NumD"    TRUE  NIL)
  #     '(3 "NumR"    TRUE  NIL)
  
  #     '(4 "Nminus"  TRUE  NIL)
  #     '(4 "Nplus"   TRUE  NIL)
  #     '(4 "Nnull"   TRUE  NIL)
  
  #     ;//----------------------------
  #     ;'(2 "Sum"    NIL  NIL) ; !!! нe работаeт флажок !! да зачeм он вообщe нужeн..
  #     ;'(2 "Sum"    FALSE  NIL) ; !!! нe работаeт флажок !!
  
  #     '(2 "Sum"    TRUE  NIL)
  #     ;'(1 "Metr"   TRUE  NIL)
  #   ))
  
  
  set p_out_add [list  \
               {3 "NumD"   1  NIL} \
               {3 "NumR"   1  NIL} \
               \
               {4 "Nminus" 1  NIL} \
               {4 "Nplus"  1  NIL} \
               {4 "Nnull"  1  NIL} \
              ]

  

  # TODO^ сейчас нельзя сдлать имена One_Edges Two_Edges, т.к. глючит
  # при чтении и путает с "_files" !!

  switch -- $out_mode {

    "1" {

      set p_out [list  \
                   {1 "Nodes"     1  NIL} \
                   \
                   {2 "OneEdges"  1  NIL} \
                   {2 "TwoEdges"  1  NIL} \
                  ]      
    }
      
    "4" {
      
      set p_out {}
      set p_out [lappend  p_out {*}$p_out_min]
      set p_out [lappend  p_out {*}$p_out_add]
    }   

    default {
      
      set p_out $p_out_min 
    }
  }
    
  # ---------------------------------------------------------
  #   set p_out [list  \
    #                {1 "Rmax"   1  NIL} \
    #                {1 "Rmin"   1  NIL} \
    #                \
    #                {2 "D"      1  NIL} \
    #                {2 "R"      1  NIL} \
    #                \
    #                {3 "NumD"   1  NIL} \
    #                {3 "NumR"   1  NIL} \
    #                \
    #                {4 "Nminus" 1  NIL} \
    #                {4 "Nplus"  1  NIL} \
    #                {4 "Nnull"  1  NIL} \
    #               ]
  
  return $p_out ;# вернем список описания выводов
}
#-------------------------------------------------------------------------------
proc plot_from_outlist {p_out_list nums} {

  set fnum [llength $p_out_list]
  set xnum $nums
  set tnum 1

  set p_lot  [plot_create_NEW  $fnum $xnum $tnum]

  for {set i 0} {$i < $fnum} {incr i} {

    set name [lindex $p_out_list  $i 1]

    PP_NAME_set_NEW  $p_lot $i $name ;# "Sinus"
  }


  SET $p_lot "T_0" TITLE "Test for GRAF"

  return $p_lot
}
#-------------------------------------------------------------------------------
proc tao_set_out {tao p_out_list} {

  set nums [GET $tao  "NUMS"]

  set p_lot  [plot_from_outlist  $p_out_list $nums]
  
  SET $tao "P_LOT" $p_lot ;#

}
#-------------------------------------------------------------------------------
proc tao_create {gr nums} {


  set tao [dict_create]

  SET $tao    "GR"  $gr
  SET $tao  "NUMS"  $nums

  # в словарь  нужна ссылка на список, а не сам список?
  # 

  #set fnum [llength $p_out_list]
  #set xnum $nums
  #set tnum 1

  SET $tao "STEP"   0


  return $tao
}
#-------------------------------------------------------------------------------
proc tao_save {tao} {

  set step [GET $tao "STEP"] ;# например 21


  if {[mod $step 20] == 0} {

    puts "tao_save ... step = $step"

    # надо бы это число (21) и записать в L_XNUM !! (сейчас оно 300)
    # xnum_real
    # 
    dict_set $tao "P_LOT" "L_XNUM" $step

    set numer [format "%06d" $step]
    dict_save $tao "TAO" "m__$numer" ;# например t__000021
  }

  return
}
#-------------------------------------------------------------------------------
proc graf_reform_by_ADD_DEL  {gr_old gr_new   reform_args} {

  set addnode_type [lindex $reform_args 0]
  set delnode_type [lindex $reform_args 1]


  # если ничего нет, то нужно зародить
  # 
  if {[graf_get_num_nodes $gr_old] == 0} {
    
    tao_bestday_NEW  $gr_new ;# ?????
    #tao_bestday  $gr_old
  }
  
  # главный цикл по всем узлам графа ~BEG~~~~~~~~~~~~~~~~~
  # 
  dotimes  u [GET $gr_old "NN"] {
    
    set node [NODE_get $gr_old $u]

    if {$node == "NOS"} {continue}
    
    set cur_node $u ;# ?? почему не просто $u ??

    set what_do [tao_what_do  $gr_new $cur_node]
    
    #puts stderr "cur_node= $cur_node  what_do= $what_do"
    
    
    if       {$what_do == 1} {
      tao_addnode_NEW  $addnode_type  $gr_old $gr_new $cur_node
    } elseif {$what_do == 3} {
      tao_delnode_NEW  $delnode_type  $gr_new $cur_node
    }

  }
  # главный цикл по всем узлам графа ~END~~~~~~~~~~~~~~~~~
  
  
  #  проверка корректности узлов и связей 
  #  ;(when (= addnode_type 2) ; только для тeстового случая
  #
  graf_check $gr_new
  
  # возвращаем gr_new
  # 
  
  #return $gr_new
}
#-------------------------------------------------------------------------------
proc graf_edgerecalc {gr  point new_point  test &p_isplus} {

  USE_REFS


  if {1 == $test} { ;# ---------------------------- /*Simple */
    
    set isplus $p_isplus

    if {$isplus} { 
      incf_EDGE $gr $point $new_point
    } else { 
      decf_EDGE $gr $point $new_point 
    }
    
    set isplus [expr {! $isplus}]
    set p_isplus $isplus
    
  } elseif {2 == $test} { ;# ---------------------- /*Triang */
    
    #       (setf rab_point (YRAND 0 (- (NN gr) 1)))
    #       (unless (or (= rab_point point) (= rab_point new_point))
    
    #       (when (>= (EDGE gr point new_point) 
    #           (+ (EDGE gr point rab_point) (EDGE gr rab_point new_point)))
    
    #         (decf (EDGE gr point new_point))
    #         (incf (EDGE gr point rab_point))
    #       )
    
  } elseif {3 == $test} { ;# --------------------- /*All-Plus */
    
    #       (incf (EDGE gr point new_point))			
    
  } elseif {4 == $test} { ;# ----------------------- /*Median */
    
    #       (setf sum 0)
    
    #       ;// надо попробовать бы попрощe...
    
    #       (dotimes (u (NN gr))
    #       (dotimes (v (NN gr))
    
    #         (setf edge (EDGE gr u v))
    #         (incf sum edge) 
    #         ))
    
    #       (setf sum (/ sum (- (* (NN gr) (NN gr)) (NN gr)) 2))
    
    #       (if (> (EDGE gr point new_point) sum)
    #         (decf (EDGE gr point new_point))
    #         (incf (EDGE gr point new_point))
    #         )
  } else {
    
    # ;      Error ("Calc_test not found !");
  }
  
  return
}
# ;-------------------------------------------------------------------------------
proc graf_print_meta {gr} {  

  set nn    [dict_get $gr "NN"] 
  set nodes [dict_get $gr "NODES"]
  set edges [dict_get $gr "EDGES"]


  #puts ""
  puts ""

  puts $::razd_____________________________line ;# это из файла "a-menu.tl"

  puts "NN    = $nn"

  #puts "NODES = $nodes"
  puts "NODES = [set $nodes]"


  #arr2d_print_NEW $edges

  puts -nonewline [format "------------------------------- \n"]

  puts "EDGES = "

  # подготовим форматы для выравнивая табилцы
  # 
  set node_form  "  %2d  "
  set edge_form  " % 3.1f "

  # печатаем строку шапки для узлов
  # 
  puts -nonewline [format "   | "]
  dotimes u $nn { 
    puts -nonewline [format $node_form $u]
  }

  puts -nonewline [format "\n"]
  puts -nonewline [format "------------------------------- \n"]
  

  dotimes u $nn { 

    # печатаем строку таблицы для ребер
    # 
    puts -nonewline [format "%2d | " $u]
    dotimes v $nn { 

      set val [EDGE_get $gr $u $v]

      if     {$val == "NOS"}         {puts -nonewline [format "  o  "]} \
      elseif {$val == "YES"}         {puts -nonewline [format "  *  "]} \
      elseif {[llength $val] > 1}    {puts -nonewline [format "  .  "]} \
      else                           {puts -nonewline [format $edge_form $val]}
      
    }
    
    puts -nonewline [format "\n"]
  }
  
  puts $::razd_____________________________line
  
  puts ""
  #puts ""

  return
}
#-------------------------------------------------------------------------------

set ::skip_simple_menu 0

#-------------------------------------------------------------------------------
proc tao_simple_menu {tao} {


  flush stdout  ;# все данные должны быть выведены
  flush stderr  ;# 

  set menu_list {}
  lappend menu_list   [list " d"  "Draw PLOT" [list tao_draw_GUI $tao]]
  lappend menu_list   [list " m"  "Go to End" {
    set ::skip_simple_menu 1 ;
    set ::meun_break_flag  1 ;# но в след. раз меню тоже вылетит !!
  }]

  call_menu "main" $menu_list 0 ;# упрощенный вариант

  return
}
#-------------------------------------------------------------------------------
proc  plot_print_one_line {plot} {

  puts ""
  puts "plot_print_one_line ..."
  puts ""
  
}
#-------------------------------------------------------------------------------
proc  tao_loop0_main {tao} {
  

  set gr     [GET $tao     "GR"] 
  set nums   [GET $tao   "NUMS"] 
 
  #set p_out  [GET $tao  "P_OUT"] 
  #set p_out_list  [set $p_out] ;# там указатель, а нам нужен список
  #                              # но это уже другой список ! копия !!
    
  # -----------------------------------------
  # подготавливаем алгоритм преобразования ?

  set test   [GET $tao   "TEST"]  
  set point  [GET $tao   "POINT"]  

  set isplus 0
  
  puts stderr "tao_loop0_main ..."

  # начинаем эволюцию преобразований ----------
  
  dotimes i $nums {
    
    # ничего не понятно, надо бы распечатывать!
    #set to_term 1

    tao_calc_MAIN_OUTS  $tao ;# $to_term ;# TODO: вообще убрать здесь печать !!

    # -----------------------------------------
    # выполняем алгоритм преобразования

    set new_point [YRAND 0 [expr {[GET $gr "NN"] - 1}]] ;# перемещаемся в новый узел?
                                                   # предпологая, что туда есть ребро?
    
    #if {$::NEW} {

    #puts ""
    #puts "i         = $i"
    #puts "point     = $point -> $new_point"
    puts "new_point = $new_point"
    #puts "isplus    = $isplus"
    #puts ""
    
    # здесь надо бы распечатать текущий расчет из PLOT:
    # 
    #set plot [GET $tao "P_LOT"]
    #plot_print_one_line $plot
    
    #if {! $::skip_simple_menu} { # на каждом шаге даем меню
    #  tao_simple_menu $tao  
    #}
    #}
    
    graf_edgerecalc  $gr \
                     $point $new_point $test isplus  ;# считаем это ребро

    set point $new_point
    # -----------------------------------------

    if {$::is_meta_saving} {

      tao_save $tao ;# $i
    }
  }  

  # закончиил эволюцию преобразований ---------

  tao_calc_FINAL $tao

  #   puts ""
  #   puts ""
  
  #   #if {$::NEW} {
  #   set p_lot [GET $tao "P_LOT"]
  
  #   #plot_print_NEW $p_lot   
  #   dict_print $p_lot   
  #   #}

  return
}
#-------------------------------------------------------------------------------
proc tao_loop1_main {tao} {


  set reform_proc [GET $tao "reform_proc"]
  set reform_args [GET $tao "reform_args"] 

  #---------------------------------------------------
  
  set gr_old [GET $tao     "GR"] 
  set nums   [GET $tao   "NUMS"]  


  # начинаем эволюцию преобразований ----------
  
  dotimes i $nums {
    
    tao_calc_MAIN_OUTS $tao  ;# печатаем нумерацию шагов, например 199)
    
    #  подготовить новый граф из текущего
    # 
    set gr_new [graf_create [GET $gr_old "NN"]]
    graf_copy  $gr_old $gr_new
  
  
    # "параллельные" преобразования
    # 
    $reform_proc  $gr_old  $gr_new  $reform_args		
  

    # сделать новый граф текущим 
    # 
    set gr_old $gr_new

    SET $tao "GR" $gr_old


    if {$::is_meta_saving} {

      tao_save $tao ;# $i
    }
  }
  
  # закончиил эволюцию преобразований ---------
  
  puts ""
  puts "------------------------------- "
  
  tao_calc_FINAL $tao

  return
}
#-------------------------------------------------------------------------------
proc tao_loop_MAIN {tao} {


  set loop_main_proc [GET $tao "LOOP_MAIN"]
  
  puts ""
  puts "tao_loop_MAIN: $loop_main_proc"
  puts ""

  $loop_main_proc $tao ;# выполняем основную процедуру разреза

  # а можно сделать вызов "мультиметода" или просто "метода" по типу разреза
  # 

}
#-------------------------------------------------------------------------------
#proc  tao_loop0_create {args} {} 
#-------------------------------------------------------------------------------
proc  loop0 {args} { 

  puts ""
  puts ".... tao_loop0_create  args = $args ....."
  puts ""

  set size  [dict_parse $args "-size"    30] 
  set nums  [dict_parse $args "-nums"   100] 
  set seed  [dict_parse $args "-seed"    -1]
  #set prog  [dict_parse $args "-prog"   "" ]  

  #if {1} {
  puts "size = $size"
  puts "nums = $nums"
  puts "seed = $seed"
  #puts "prog = $prog"

  #exit
  #}

  comm_random_seed_null $seed

  set gr [graf_create $size]
  
  # здесь будет целиком "разрез" задачи
  # 
  set tao [tao_create  $gr $nums] 

  SET $tao  LOOP_MAIN  "tao_loop0_main"

  # -------------------------------------------------

  graf_init  $gr "GR_RAND" 0.0 0.0  "GR_RAND" 0.0 0.0


  # TODO: заменить эту конструкцию на DICT !!
  # 

  set p_out [list  \
               {1 "Nodes"  1  NIL} \
               \
               {2 "Rmax"   1  NIL} \
               {2 "Rmin"   1  NIL} \
              ]

  tao_set_out  $tao $p_out 

  # -------------------------------------------------

  # сюда надо указывать подтестовую процедуру (test) ??
  # 
  # граф постоянный, не меняется; просто идем по ребрам к случайно
  # выбранным узлам и делаем вычисления на этих ребрах.

  set test 1
                    
  SET $tao       TEST  $test
  SET $tao      POINT  0


  return $tao
}
#-------------------------------------------------------------------------------
# proc tao_loop1_create {args} {}
#-------------------------------------------------------------------------------
proc loop1 {args} {

  # size  количество ребер в графе
  # nums  количество шагов

  set size  [dict_parse $args "-size"    30] 
  set nums  [dict_parse $args "-nums"   100] 
  set seed  [dict_parse $args "-seed"    -1]
  set prog  [dict_parse $args "-prog"   "" ]  

  if {1} {

  puts ""
  puts "......... $prog ..............."
  puts ""
  puts "args = $args"
  puts "size = $size"
  puts "nums = $nums"
  puts "seed = $seed"

  #exit
  }
  
  set gr_old [graf_create $size]

  comm_random_seed_null $seed
  
  # здесь будет целиком "разрез" задачи
  # 
  set tao [tao_create  $gr_old $nums] 

  SET $tao  LOOP_MAIN  "tao_loop1_main"

  # -------------------------------------------------

  set p_out [list  \
               {1 "Nodes"     1  NIL} \
               \
               {2 "OneEdges"  1  NIL} \
               {2 "TwoEdges"  1  NIL} \
              ]      

  tao_set_out  $tao $p_out 


  # одновременное изменение структуры по неким правилам для каждого
  # ребра по его окружению.

  # а здесь уже более специфичное задание
  #
  set addnode_type 2 ;# 1, (2), 3
  set delnode_type 3 ;# 1, (2), 3

  SET $tao  reform_proc  "graf_reform_by_ADD_DEL"
  SET $tao  reform_args  [list $addnode_type $delnode_type]


  return $tao
}
#-------------------------------------------------------------------------------
# proc  loop0 {args} { 

#   set tao [tao_loop0_create {*}$args] 

#   #tao_loop_MAIN $tao

#   return $tao
# }
#-------------------------------------------------------------------------------
# proc loop1 {args} {


#   set tao [tao_loop1_create {*}$args]

#   #tao_loop_MAIN $tao ;# эту прогу будем потом повторять по тербованию
 

#   return $tao
# }
#-------------------------------------------------------------------------------

# t_test.tl test loop0


# TODO (август 2015):

# - основные "живые" элементы (скорее ребра чем узлы) обмениваются простейшими 
#   "протокольными" сообщениями (парсинг возможно с использований 
#   "конечных автоматов");
# - живцы выживают борясь за ресурс (метрика треугольников?) и создавая коалиции, т.е.
#   структуры;
# - алгоритмы определения и визуализации структур на графах ();

# TODO (сентябрь 2018):

# - point это "мерцающий драйвер" эмуляции параллельности при возможности
#   выполнения законов сохранения
# - сами алгоритмы в точке драйвера могут быть как чисто локальные, так и более 
#   сложно-протяженные, в том числе с использовнием модели "алгоритмических струн",
#   т.е. когда один конец струны задает процедуру, а на другом конце выполняются
#   преобразования. 

# - более сложная модель:  граф "простых" узлов, которые, в свою очередь
#   помещаются в стеки на узлах мета-графа; кроме того узлы могут формировать
#   последовательности узлов или их групп? короче, нужны выч. модель на графах.
#   простейшая команда - выполнить мксимально подобную структуру на "данных"
#   аналогично окружению в команде!

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
