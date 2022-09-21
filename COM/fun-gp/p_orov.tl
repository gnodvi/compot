# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/COM/common] ;# for JIM

#------------------------------------------

package require compot::common 

#------------------------------------------

# source "b-com0.tl"
# source "b-com1.tl"

# source "f-rand.tl"

source "p-corE.tl"

source "p-diff.tl"

# ;#-------------------------------------------------------------------------------

# ; задача определения координат (1D, 2D) точек по их расстояниям
# ; 
# ; MDS - Multidimension Scaling

# ;-------------------------------------------------------------------------------

# ; TODO:

# ; -) координаты фиксированных точек тоже надо вводить с погрешностями
# ; -) расстояния тоже могут быть не точны? как быть? варьировать по очереди?
# ; -) для представления точек и узлов использовать библиотеку графов

# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------

# ; параметры задачи:
# ; 

# ;(defvar _new          #f)
# ;(defvar _new          #t)

# ;(defvar *seed_points* NIL)
# ;(defvar *seed_points_index* 0)

# (defvar *max_val_arr* NIL)

# (defvar *dim*     NIL)
# (defvar *n_ext*   NIL)  
# (defvar *n_fix*   NIL)


# (defvar *max_len_defnode* 5) ; формат записи

# (defvar *work_fix_points* NIL) ; для удобства: начальные фиксированные точки
# (defvar *work_point*      NIL) ; для удобства: рабочая точка

# (defvar *nodes*      NIL)
# (defvar *edges*      NIL)


# ;# /*******************************************************************************
# ;# //------------------------------------------------------------------------------
proc point_from_chromosome {chromosome i} {

  #   ; здесь надо учитывать размерность точек !!
  #   ;
  #   ; cначала выпишем координаты в глобальную рабочую точку
  
  for {set d 0} {$d < $::dim} {incr d} {
  
    lset ::work_point $d [lindex $chromosome  [expr {($i * $::dim) + $d}] ]
  }
  
  return $::work_point
}
# ;# //------------------------------------------------------------------------------
proc point_print {point} {


  puts -nonewline  "\[" 
  
  for {set d 0} {$d < $::dim} {incr d} {
  
    puts -nonewline [format "%9.6f " [lindex $point $d]]
  }
  
  puts -nonewline  "\] "

}
# ;# //------------------------------------------------------------------------------
proc name_by_ind {ind} {

  set name "NAME"

  #   ;;(loop for n :across *nodes* :do
  #   ;;
  #   ;; )
  
  set name [lindex $::nodes $ind]

  return $name
}
# ;# //------------------------------------------------------------------------------
proc ext_point_print {point ext_ind} {

  set all_ind  [+ $::n_fix $ext_ind]
  set name  [name_by_ind   $all_ind]
  
  
  #   ;(format t "p~d (~s) = "  all_ind name)   
  #   ;(format t "p~s = "  name) 
  
  puts -nonewline  [format "%4s = "  $name] 
  
  point_print $point

}
# ;# //------------------------------------------------------------------------------
# ;# //  synopsis:	Generation callback
# ;# //------------------------------------------------------------------------------
# ;# static boolean 
# ;# test_generation_callback (int generation, population *pop)
# ;# //------------------------------------------------------------------------------
proc test_generation_callback {generation pop} {


  if {[expr {$generation % 10}] == 0} {

    set best [pop_get_entity_  $pop  0] 
    
    puts stderr "test_generation_callback: pop = [set $pop], best = $best"

    set best_chromo  [item_get_mainsrc  $best]
    set best_fit     [item_get_fitn     $best]
    
    
    puts -nonewline [format "%3d  : "  $generation]
    
    if $::__is_print {

      for {set i 0} {$i < $::n_ext} {incr i} {
      
        set p [point_from_chromosome  $best_chromo $i]
        ext_point_print  $p $i
      }
    }
    
    puts [format "(fitness = %9.6f) "  $best_fit]
    
  }
  
  return true
  
}
# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
# ;(defun find_len_true (edges ind_A ind_B)

# ;(let* (
# ;  )

# ;  (loop for e in edges do 
    
# ;    (when (and (= (nth 0 e) ind_A) (= (nth 1 e) ind_B))
# ;      (return-from find_len_true (nth 2 e))
# ;      )
# ;    )

# ;  (die "find_len_true")

# ;))
# ;#-------------------------------------------------------------------------------
# ;(defun calc_err_main (ind_A ind_B  points edges)

# ;(let* (
# ;  (A (elt points ind_A))
# ;  (B (elt points ind_B))

# ;  (len_true (find_len_true edges  ind_A ind_B))
# ;  )

# ;  (calc_err  A B len_true)

# ;))

# ;#-------------------------------------------------------------------------------
proc calc_len {A B} {

  # (let* (
  #   A_xyz B_xyz
  
  #   ;len 
  #   val 
  set sum 0
  #   )
  
  #   ;(setf a (first A)) ; здесь д.б. сама точка 
  
  #   (loop :for d :from 0 :below *dim* :do
  for {set d 0} {$d < $::dim} {incr d} {
  
    set A_xyz [lindex $A $d]
    set B_xyz [lindex $B $d] ;# соотв. координаты концов отрезка
    
    #     ;;(setf len (abs (- A_xyz B_xyz))) 
    
    set val [expr {$A_xyz - $B_xyz}] 
    
    incf sum [expr {$val * $val}]
  }
  
  #   ;(sqrt len) 
  
  return [expr {sqrt ($sum)}] 
  
}
# ;#-------------------------------------------------------------------------------
proc calc_err {A B len_true} {

  # (let* (
  
  set len [calc_len  $A $B]   
  #   )
  
  
  return [expr {abs ($len - $len_true)}]
  
}
# ;#-------------------------------------------------------------------------------
proc calc_err_for_one_edge {e points} {

  #   err
  #   ;(full_err 0)
  #   ;(summ_err 0)
  
  #   A B ;fitness
  #   A_ind B_ind  
  #   L_true
  
  
  set A_ind  [lindex $e 0] ;# (nth 0 e))
  set B_ind  [lindex $e 1] ;# (nth 1 e))
  set L_true [lindex $e 2] ;# (nth 2 e))
  
  set A [lindex $points $A_ind] ;# это многомерные точки !! с радиусами ??
  set B [lindex $points $B_ind]
  
  set err [calc_err  $A $B  $L_true]

  return $err
}
# ;#-------------------------------------------------------------------------------
proc calc_fitness_from_points {points edges} {

  #   err
  set summ_err 0
  #   ;(mult_err 0)
  
  #   fitness
  
  #   ;(format t "calc_fitness_from_points: points = ~s ~%" points)
  
  #  (loop :for e :in edges :do 
  foreach e $edges {
  
    set err [calc_err_for_one_edge  $e $points]
    
    incf summ_err  $err  ;# простая сумма? 

    #    ;(incf mult_err (* err err)) ; квадратичная, с послед. корнем?
  }
  
  #  -----------------------------------------------------
  # т.е. чем больше тем хуже или "чем меньше тем лучше"
  # 
  set fitness [expr {- $summ_err}]
  #
  # а теперь, "чем больше тем лучше" , стремясь к нулю !

  #   ;;
  #   ;(setf fitness (- (sqrt mult_err))) ;- какая лучше, вроде особо нет разницы
  
  
  return $fitness
  
}
# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
# ;# //  synopsis:	Fitness function.

# ;# /* static */ boolean 
# ;# _test_score (population *pop, entity *this_entity)
# ;#-------------------------------------------------------------------------------
proc _test_score {this_entity task} {

  # (declare (ignore pop))
  
  #   fitness
  
  #   ;;  # нулевая точка должна быть фиксированна !
  #   points 
  
  
  #   ;;   0        1        2       3       4
  
  #   ;;   O ------ A ------ B ----- C ----- D
  #   ;;  
  #   ;;            1        0       1       4   cl orovos.cl 50 50 
  
  #   ;;  |AB| = 1
  #   ;;  |BC| = 1
  #   ;;  |AD| = 3
  #   ;; 
  
  # ;  (edges '(
  # ;          (0 1  1.0)
  
  # ;          (1 2  1.0)
  # ;          (2 3  1.0)
  # ;          (1 4  3.0) ; cl orovos.cl  69 10
  # ;          ;(3 4  1.0)
  # ;          ))
  
  # ;  (n     4)
  # ;  (*n_fix* 1)
  
  #   ;(x0  0) ;  эта точка участвует в расчетах фитнеса, но ен участвует в геноме
  #   ; можно считать их в общей схеме полагаю фложок - фикс,
  #   ; а можно - как дополнительное условие, алгоритм расчета фитнеса.
  
  set chromosome [item_get_mainsrc  $this_entity]
  

  #   ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   ;; сформируем из хромосомы массив точек, а потом уже будем его обрабатывать
  #   ;;
  set points [list_make [expr {$::n_fix + $::n_ext}]]
  
  
  #   ;; запишем сначала фиксированные точки в этот рабочий массив
  #   ;; 
  #   (loop :for i :from 0 :below *n_fix*  :do 
  for {set i 0} {$i < $::n_fix} {incr i} {

    #     (setf (elt points i)  (elt *work_fix_points* i))
    lset points $i [lindex $::work_fix_points $i]
  }  
  
  #   ;; теперь запишем точки из генома
  #   ;; 

  for {set i 0} {$i < $::n_ext} {incr i} {
  
    lset points [expr {$i + $::n_fix}] [point_from_chromosome  $chromosome  $i]
  }
  
  #   ;; и теперь по этому 
  #   ;; 
  
  set fitness [calc_fitness_from_points  $points $::edges]
  
  return $fitness 
  
}
# ;#-------------------------------------------------------------------------------
# ;# Seed genetic data.

# ;# /* static */ boolean 
# ;# _test_seed (population *pop, entity *adam)
# ;#-------------------------------------------------------------------------------
proc point_init_by_random {&point} { 

  USE_REFS

  #   ; надо бы поточнее тут? по размерностям
  #   ; 
  
  #   (loop for d :from 0 :below *dim* :do
  for {set d 0} {$d < $::dim} {incr d} {
  
    #puts "d = $d"
    #  (setf (aref point d)  (random_double  (aref *max_val_arr* d)))
    #item_set_chromo_gen $point $d  [random_double [lindex $::max_val_arr $d]]

    lset point $d  [random_double [lindex $::max_val_arr $d]]
  }
  
}
# ;#-------------------------------------------------------------------------------
proc point_to_entity {point ent i} { 


  for {set d 0} {$d < $::dim} {incr d} {
  
    item_set_chromo_gen  $ent [expr {($::dim * $i) + $d}]  [lindex $point $d]
  }

}
# ;#-------------------------------------------------------------------------------
proc _test_seed {pop task adam} {  ;# task - описание заадчи


  #   ;; TODO: здесь нужно бы иметь индекс, т.е. связь с начальными значениями ??
  #   ;; 
  #   ;; нет, нужен механизм подключения "начальных точек"
  
  
  #   (declare (ignore pop))
  
  #   ;;  #   ((double *) adam->chromosome[0]) [0] = random_double (2.0);
  #   ;;  #   ((double *) adam->chromosome[0]) [1] = random_double (2.0);
  #   ;;  #   ((double *) adam->chromosome[0]) [2] = random_double (2.0);
  #   ;;  #   ((double *) adam->chromosome[0]) [3] = random_double (2.0);
  
  #   ;;  # пока будем делать с ОДНОЙ хромосомой 
  #   ;;  #
  #   ;;  # а надо ли несколько хромосом? т.е. например многомерная точка?
  #   ;;  # или адаптироваться должны процедуры скрещивания и т.д?
  
  
  #   (loop for i :from 0 :below *n_ext* :do
  for {set i 0} {$i < $::n_ext} {incr i} {
  
    point_init_by_random   ::work_point           ;# рабочая глобальная точка
    point_to_entity        $::work_point $adam $i 
  }
  
  
  return true

}
# ;# //------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
proc draw_entity {pop id name} {


  set entity  [pop_get_entity_      $pop $id]
  set chromo  [item_get_mainsrc  $entity]
  
  puts ""  
  puts [format "%s : fitness = %.6f "  $name [pop_get_entity_fitness_  $pop $id]]
  puts ""
  
  for {set i 0} {$i < $::n_ext} {incr i} {
  
    set p [point_from_chromosome $chromo $i]
    
    #puts "   "
    ext_point_print  $p $i
    puts "" 
  }
  
  puts ""
  
}
# ;#-------------------------------------------------------------------------------
proc draw_results {pop} {


  draw_entity   $pop 0 "FINAL 0"
  
  draw_entity   $pop 1 "FINAL 1"
  
  #   ;(draw_entity   pop 2 "FINAL 2")
  
}
# ;#-------------------------------------------------------------------------------
proc pntssolver_do {population_size max_generations             
                    {strategy      "GA_DE_STRATEGY_BEST"}       
                    {crossover     "GA_DE_CROSSOVER_BINOMIAL"}  
                    {num_perturbed 1}                           
                    } {
                  
  set crossover_factor    0.8 
  set weighting_factor    0.5 
  set weighting_factor2   0.5 
  
  #   pop 
  #   gen_hook_proc evaluate_proc initseed_proc 
  
  
  #   ;(random_seed 23091975)
  
  
  set  gen_hook_proc  "test_generation_callback"
  #set  evaluate_proc  "_test_score"
  set  initseed_proc  "_test_seed"
  
  #   (setf pop (ga_genesis_double         
  #              population_size              ; const int              population_size     
  #              1                            ; const int              num_chromo         
  #              (* *n_ext* *dim*) ; 4                ; const int              len_chromo        
  #              gen_hook_proc     ; GAgeneration_hook      generation_hook    
  #              NUL                          ; GAiteration_hook       iteration_hook 
  #              NUL                          ; GAdata_destructor      data_destructor 
  #              NUL                          ; GAdata_ref_incrementor data_ref_incrementor
  #              evaluate_proc     ; GAevaluate             evaluate  
  #              initseed_proc     ; GAseed                 seed 
  #              NUL                          ; GAadapt                adapt 
  #              NUL                          ; GAselect_one           select_one 
  #              NUL                          ; GAselect_two           select_two 
  #              NUL                          ; GAmutate               mutate           
  #              NUL                          ; GAcrossover            crossover 
  #              NUL                          ; GAreplace              replace 
  #              NUL                          ; vpointer               User data
  #              ))
  
  
  set task [task_create   -fit_func "_test_score" -fit_tobest "MAX"]

  set pop [ga_genesis_main   \
	   $task \
           $population_size    \
           1		       \
           [expr $::n_ext * $::dim] \
           $gen_hook_proc      \
           NULL		       \
           NULL		       \
           NULL		       \
           $initseed_proc      \
           NULL	               \
           NULL	               \
           NULL	               \
           NULL                \
           NULL                \
           NULL		       \
           NULL		       \
          ]

  #   ;;    # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  #   ;;    #
  ga_population_seed  $pop $task
  
  if $::__is_print { 
    pop_print $pop
  }
  
  #puts ""
  #puts "population_size = $population_size"

  #puts ""
  #puts "pntssolver_do ............ EXIT !!!!!!!!!!!"
  #puts ""

  #exit ;# !!!!!!!!!!!!!!1

  #   (ga_population_set_differentialevolution_parameters    
  #       pop 
  #       strategy crossover 
  #       num_perturbed weighting_factor weighting_factor2 
  #       crossover_factor)
  
  ga_population_set_differentialevolution_parameters $pop \
                                     $strategy $crossover   \
                                     $num_perturbed $weighting_factor $weighting_factor2 \
                                     $crossover_factor

  puts ""  
  
  #   ;;    # выполняем основной расчет (поиск минимума)
  #   ;;    #
  ga_differentialevolution  $pop $task	$max_generations 		
  
  
  if $::__is_print {
    puts "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
  }
  
  puts ""  
  pop_print $pop
  puts ""
  
  
  draw_results  $pop
  
  #   ;;  return
  
}
# ;# //------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
proc  add_to_end_of_list {l x} {

  #   (reverse (cons x (reverse l)))
  
  return [lappend $l $x]

}
# ;#-------------------------------------------------------------------------------
proc find_index_by_name  {name nodes_} {

  # ;; здесь nodes_ - простой массив индексов !?
  
  # (let (
  set ind  -1
  set len  [llength $nodes_]

  #   e
  #   )
  
  #   (loop :for i :from 0 :below len :do
  for {set i 0} {$i < $len} {incr i} {
  
    set e [lindex $nodes_ $i] ;# (elt nodes_ i))
    
   # puts "find_index_by_name: name= $name  e= $e"
    
    #  (when (eql e name) 
    if [string equal $e $name] {  
    
      set ind $i
      break ;# (return)
    }
  }
  
  if {$ind == -1} { 
    puts ""
    puts "ERROR !!  find_index_by_name:  name = $name"
    puts ""
    exit
  }
  
  return $ind
}
# ;#-------------------------------------------------------------------------------
proc find_radius_by_name {name nodes} {

  set obxvat 0.0

  #   ;(format t "find_radius_by_name: name = ~s  ind = ~s ~%" name ind)

  #   (loop :for n :across nodes :do
  foreach n $nodes {
  
    #     (when (eql (aref n 0)  name) 
    if {[string equal [lindex $n 0] $name]} {
    
      set obxvat [lindex $n 1]
      break ;#       (return)
    }
  }
  
  return [/ $obxvat 6.28]

  #   ;0.5  
  #   ;(aref (aref nodes ind) 1)
}
# ;#-------------------------------------------------------------------------------
proc edges_correct {nodes  &name_edges} {

  USE_REFS

  set size [llength  $name_edges]
  
  #   e  
  #   A_name   B_name
  #   A_radius B_radius
  #   L_true    L_true_correct
  
  
  #   (loop :for i :from 0 :below size :do
  for {set i 0} {$i < $size} {incr i} {
  
    set e [lindex $name_edges $i]
    
    set A_name  [lindex  $e 0]  
    set B_name  [lindex  $e 1] 
    
    puts "edges_correct: A_name = $A_name  B_name = $B_name"
    
    set A_radius  [find_radius_by_name  $A_name $nodes] 
    set B_radius  [find_radius_by_name  $B_name $nodes] 
    
    #     ;(exit)
    set L_TRUE  [lindex $e 2]
    
    #     ;;-------------------------------------------
    
    set L_TRUE_correct [+ $L_TRUE $A_radius $B_radius]
    
    #setf (aref e 2) L_TRUE_correct)
    lset e 2  $L_TRUE_correct
    
    #     (setf (elt name_edges i) e) ; запишем обратно
    lset name_edges $i  $e
  }
  
}
# ;#-------------------------------------------------------------------------------
proc  make_edges_from_namededges  {namededges nodes} {


  # (declare (special nodes))

  #puts "namededges = $namededges"


  set edges  {} ;# NIL)

  #   ie
  #   A_name B_name L_true A_indx B_indx


  #   (loop :for ne :across namededges :do
  foreach ne $namededges {
  
    set A_name  [lindex $ne 0]   
    set B_name  [lindex $ne 1]     
    set L_true  [lindex $ne 2] ;# здесь уже расстояние между центрами, корректное?
    
    set A_indx  [find_index_by_name  $A_name $nodes]
    set B_indx  [find_index_by_name  $B_name $nodes]
    
    set ie [list  $A_indx $B_indx $L_true] ;# ребро (индекс индекс длина)

    #     ;(setf ie  (A_indx B_indx L_true)) ; ребро (индекс индекс длина)
    
    puts "ne = $ne  ie = $ie" 
    
    #set edges [add_to_end_of_list  $edges $ie]
    lappend edges $ie
  }

  puts ""
  puts "make_edges_from_namededges ............................"
  puts ""
  puts "names = $namededges"
  puts "nodes = $nodes"
  puts "edges = $edges"
  puts "......................................................."
  puts "" 

  return $edges

}
# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
proc loop_for_fix_nodes {defnodes &nodes_} {

  USE_REFS

  set n 0
  #   is_fix_flag
  
  #   (loop :for p :across defnodes :do  
  foreach p $defnodes {
  
    #puts "p = $p"

    set is_fix_flag [lindex $p 3] ;# (aref p 3))
  
    if {$is_fix_flag} {
  
      #puts ""
      #puts "!!!! is_fix_flag !!!!"
      #puts ""

      #       (vector-push-extend  (aref p 0)            nodes_) ; только имя туда
      #       (vector-push-extend  (aref p 4) *work_fix_points*) ; сами коориднаты точки
      
      #lappend nodes             [lindex $p 0]  ????
      lappend ::nodes           [lindex $p 0]
      lappend ::work_fix_points [lindex $p 4]

      incr n
    }
  
  }
  
  #puts ""
  #puts "::nodes = $::nodes"
  #puts "  nodes = $nodes"
  #puts ""

  return $n ;# return 

}
# ;#-------------------------------------------------------------------------------
proc loop_for_ext_nodes {defnodes  &nodes_} {

  USE_REFS

  set n 0
  #   is_fix_flag


  #   (loop :for p :across defnodes :do
  foreach p $defnodes {
  
    set is_fix_flag [lindex $p 3]
    
    if {! $is_fix_flag} { ;# не фиксированные точки
    
      #       (vector-push-extend  (aref p 0) nodes_)
      #lappend nodes_ [lindex $p 0]
      lappend ::nodes [lindex $p 0]
      
      #       ;(when _new
      #       ;  (point_init_by_random  *work_point*) 
      #       ;  (vector-push-extend    (copy-seq  *work_point*)  *seed_points*)
      #       ;  )
      
      incr n
    }
  }
  
  return $n ;# return 
}
# ;#-------------------------------------------------------------------------------
proc loop_for_all_nodes_simple {defnodes  &nodes_} {

  USE_REFS

  set n_fix  0
  set n_ext  0

  #   ; тут же надо именно последовательно формировать !!!
  #   ; т.е. на выходе сначала фиксированные точки, а не смешивать!!
  
  set n_fix  [loop_for_fix_nodes  $defnodes nodes_] ;# -> *nodes*
  set n_ext  [loop_for_ext_nodes  $defnodes nodes_] ;# -> *nodes*
   
  #   (values n_fix n_ext) 

  return [list $n_fix $n_ext]
}
# ;#-------------------------------------------------------------------------------
proc pntssolver_init_task {&defnodes  namededges dim max_val_arr} {

  USE_REFS

  set ::dim  $dim ;# это уже глобальная переменная  

  #   ;(nodes_  (make-array 0 :adjustable t :fill-pointer 0))
  #   ;p
  #   ;(n 0)  

  set ::max_val_arr  $max_val_arr 
  
  #   ;; делаем массивы и заносим туда поэлементно
  
  set ::nodes {}
  set ::work_fix_points {}

  set ::work_point [list_make $::dim 0]

  #   ; создаем по заданным шаблонам уже мат. узлы:
  #   ;
  #   ; чтобы вернуть несколько значений (если переменные уже есть):
  #   ; 

  foreach {::n_fix ::n_ext} [loop_for_all_nodes_simple  $defnodes ::nodes] {break}
  
  #   ;(format t "pntssolver_init_task: fix_nodes_ = ~S ~%" *nodes*)
  #   ;(format t "~%" )
  
  #   ; создаем ребра:
  
  set ::edges [make_edges_from_namededges  $namededges $::nodes] 
  
  return
}
# ;#-------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
proc make_test_1 {dim} {


  #   ;;  эти точки участвуют в расчетах фитнеса, но не в геноме
  #   ;; 
  
  # полагаем, что это точки с "обхватом"
  # имя / охват / фикс.координаты?

  set defnodes { 
    {x0   0.0 " x0" true {0  0}} 

    {p10  0.0 "p10" false} 
    {p20  0.0 "p20" false}
    {p30  0.0 "p30" false}
    {p40  0.0 "p40" false}
  }
  
  
  set namededges { 
  
    {x0  p10  1.0} 
    {p10 p20  1.0}
    {p20 p30  1.0}
  
    {p10 p40  3.0}
  }
  
    # ;                (3 4  1.0) ;  чем больше связей, тем точне, особенно в 2D
    # ;                (0 4  4.0)
    # ;                (0 3  3.0)
  
    # ;; ----------------------------
  #   ;; ----------------------------
  
  #   ;; сначала надо скорерктировать, если нужно (!), расстояния между 
  #   ;; центрами толстых точек:
  
  # ;  (print name_edges)
  # ;  (format t "~%")
  
  # ;  (edges_correct   defnodes  namededges) 
  # ;  (print name_edges)
  # ;  (format t "~%")
  
  # ;  (exit)
  #   ;---------------------------------------------------------------------
  
  #   ;(setf max_val_arr (make-array dim :initial-element 5.0))
  #   ;(pntssolver_init_task    all_points_local name_edges  dim 5.0)
  
  #(make-array ; массив максимальных значений
  #              dim :initial-element 5.0))
  #
  set arrmax [list_make $dim 5.0] 

  pntssolver_init_task    defnodes $namededges $dim $arrmax                    

}
# ;#-------------------------------------------------------------------------------
proc make_real_orovo {} {

  # ;(setf *dim*   2) ; это уже глобальная переменная
  
  
  #   ;;  эти точки участвуют в расчетах фитнеса, но не в геноме
  #   ;; 
  
  
  # { pX   0.00    ""  true {13.50  44.78}} ;; посчитал через уравнения
  # { pZ   0.00    ""  true {30 30.7}} ;  { pZ pY 9.3}
  # { p4_  0.00    ""  true {30 21.3}} ;  { pZ  p4_  9.4}
  # { pP   0.00    ""  true {30 20.3}} ;  prirezka (20.3 by doc)


  set defnodes { 
  
    { pL   0.00    ""  true { 0  0}}
    { pR   0.00    ""  true {30  0}}
  
    { pX   0.00    ""  true {13.50  44.78}}
    { pY   0.00    ""  true {30 40}}
  
    { pZ   0.00    ""  true {30 30.7}} 
  
    { p4_  0.00    ""  true {30 21.3}}
    { pP   0.00    ""  true {30 20.3}}
  
  
    { p1   1.50    ""  true {16.4  37}}
    { p2   0.98   "B"  true {16.35 23.65}}
    { p2_  0.95   "B"  true {16.35 23.35}}
    { p3   0.98   "B"  true {22.4  22.1}}
    { p4   1.20   "B"  true {28.6  21.8}}
    { p5   0.60   "B"  true {27.3  31.1}}
    { p6   0.60   "S"  true {31    32.3}}
    { p7   0.33   "B"  true {30    35.7}}
    { p8   0.52   "B"  true {24.45 29.2}}
    { p9   0.44   "S"  true {21.3  27.15}}
    { p10  0.49   "S"  true {19.2  27.4}}
    { p11  0.47   "B"  true {13.3  29.3}}
    { p12  0.45   "B"  true {10    32.15}}
    { p13  0.52   "S"  true {14.6  34.3}}
    { p14  0.62   "B"  true {12    11.9}}
    { p15  0.85   "B"  true {13.25 11.9}}
    { p16  0.47   "S"  true {20.2  14.55}}
    { p17  1.19   "B"  true {27.1  13.3}}
    { p18  0.58   "O"  true {8.7    9.3}}
    { p19  0.33   "O"  true {8.6   15.6}}
    { p20  0.48   "S"  true {6.25  10.4}}
    
  
    { p21  0.45   "S"  false}
    { p22  0.17   "S"  true {6.1  5.6}}
    { p23  0.45   "O"  true {7    4.6}}
    { p24  0.26   "S"  true {2    0.45}}
    { p25  0.41   "S"  true {4.4  1.3}}
    
    { p26  0.73   "B"  true {6    0.2}}
    { p26_ 0.19   "O"  false}
    
    { p27  0.29   "B"  false}
    { p28  0.31   "B"  false}
    { p29  0.49   "B"  false}
    { p30  0.63   "B"  false}
    { p31  0.69   "B"  true {11.4   3 }}
    { p32  0.40   "B"  false}
    { p33  0.35   "B"  false}
    { p34  0.35   "B"  false}
    { p35  0.59   "B"  true {15.7  3.5}}
    { p36  0.17   "O"  false}
    { p37  0.76   "O"  false}
    { p38  0.40   "B"  true {19.75 3.35}}
    { p39  0.46   "B"  true {20.1  4.2 }}
    { p40  0.37   "O"  false}
    { p41  0.33   "O"  false}
    { p42  0.53   "O"  true {22    5.2 }}
    { p43  0.47   "O"  true {21.75 7   }}
    { p45  0.23   "O"  false}
    { p46  0.20   "O"  false}
    { p47  0.20   "O"  true {24.2  5.5}}
    { p48  0.25   "O"  true {25.25 2.5}}
    { p49  0.15   "O"  false}
    
    
    { pA   0.00    ""  true {14.05 13.75}} 
    { pB   0.00    ""  false} 
    { pC   0.00    ""  true {19.4  12.1}} 
    { pD   0.00    ""  true {14.35 11.3}}  
    
  }
  
  
  #  { pB_  0.00    ""  false } 
  #  { pC_  0.00    ""  false } 
  
  #  { pC_ p17  2.8} 
  #  { pP  pB_  4.5} 
  
  set namededges {
  
    { p1  p2  13.4} 
    { p1  pX   9.0} 
    { p1  pY  13.8} 
    
    { p2  p2_  0.3}               
    { p2  p10  4.3}               
    { p2  p11  6.0}
    { p2  p12 10.3}
    { p2  p13 10.4}
    
    { p3  p2   6.0}
    { p3  p4   6.1}
    { p3  p8   7.0} 
    { p3  p9   5.0} 
    { p3  p16  7.8} 
    
    { p4  p5   9.0}
    { p4  p8   8.1}
    { p4  p4_  1.3}
    
    { p5  p1  12.62}
    { p5  p6   3.1}
    { p5  p7   5.4}
    { p5  p8   3.9}
    { p5  pZ   2.1}
    
    { p6  p7   4.0}
    { p7  pY   4.3}
    { p8  p9   3.5}
    { p9  p13  9.5}
    
    { p10 p9   2.1}
    { p10 p11  5.76}
    
    { p11 p12  4.38}
    { p11 p13  5.0}
    
    { p12 p13  5.15}
    { p13 p1   3.45}
    
  
    { p14 p15  0.87} 
    { p14 p16  7.13} 
    { p14 p18  4.14} 
    
    { p16 pB   4.14} 
    
    { pA  p2_  9.15} 
    { pA  p14  2.55} 
    { pA  p15  1.7} 
    
    { pA  pB   5.0} 
    { pC  pD   5.0} 
    { pA  pD   2.5} 
    { pB  pC   2.5} 
    
    { pA  p18  6.93} 
    { pA  p19  5.86} 
    
    { pB  p2_  8.7} 
    { pB  p3   7.9} 
    { pC  p16  2.5} 
    { pC  p17  7.87} 
    { pD  p15  1.3} 
    
    { p18 pD   5.98} 
    { p18 p19  6.27} 
    { p18 p20  2.60} 
    
    { p19 p14  5.00} 
    { p19 p16 11.58} 
    { p19 pB  10.47} 
    { p19 p20  5.37} 
    
    
    { pR  p48  5.43} 
    { pR  p40  8.53} 
    { pR  p41  8.00} 
    { pR  p37 11.01} 
    { pR  p38 10.98} 
    { pR  p39 10.76} 
    { pR  p42  9.52} 
    { pR  p43 10.90} 
    { pR  p47  8.05} 
    { pR  p45  7.15} 
    { pR  p38 10.96} 
    { pR  p35 14.65} 
    { pR  p31 18.66} 
    { pR  p49 13.78} 
    
    { p40 p48  3.90} 
    { p40 p46  4.00} 
    { p40 p45  3.44} 
    { p40 p41  1.42} 
    { p40 p42  4.05} 
    { p40 p43  5.80} 
    { p40 p39  3.28} 
    { p40 p38  2.97} 
    { p40 p35  6.14} 
    { p40 p36  4.08} 
    { p40 p37  2.62} 
    { p40 p31 10.05} 
    { p40 p33  8.95} 
    { p40 p34  9.8} 
    { p40 pC  11.2} 
    { p40 pD  12.5} 
    { p40 p23 15.0} 
    
    
    { p35 p14  9.48} 
    { p35 p15  9.1} 
    { p35 pC   9.37} 
    { p35 pD   8.12} 
    { p35 p18  9.3} 
    { p35 p21 11.86} 
    { p35 p34  3.6} 
    { p35 p31  4.00} 
    { p35 p33  3.28} 
    { p35 p32  4.18} 
    { p35 p27  6.45} 
    { p35 p26  9.9} 
    { p35 p29  5.11} 
    { p35 p28  6.24} 
    { p35 p43  6.8} 
    { p35 p42  6.4} 
    { p35 p39  4.26} 
    { p35 p38  3.67} 
    { p35 p41  6.6} 
    { p35 p37  4.3} 
    { p35 p36  3.08} 
    { p35 p19 14.39} 
    
    
    { p23 p22  1.17} 
    { p23 p25  3.95} 
    { p23 p26  4.33} 
    { p23 p24  6.24} 
    { p23 p30  4.07} 
    { p23 p31  4.83} 
    { p23 p34  5.20} 
    { p23 p35  9.05} 
    { p23 pL   8.18} 
    { p23 p18  4.74} 
    { p23 p21  4.86} 
    { p23 p20  5.86} 
    { p23 p14  8.73} 
    { p23 p15  9.41} 
    { p23 pD   9.84} 
    
    
    { pL  p24  2.03} 
    { pL  p25  4.50} 
    { pL  p26  5.98} 
    { pL  p26_ 6.86} 
    
  }
    
  #    ;; ---------------------------------------------
  
  edges_correct   $defnodes namededges 
  
  pntssolver_init_task   defnodes $namededges  2  {30 40}
  
}
# ------------------------------------------------------------------------------
# proc sqrt {v} {

#   return [expr $v]
# }
# ------------------------------------------------------------------------------
proc calc_len_points {p1 p2} {
  

  set x1 [lindex $p1 0]    
  set y1 [lindex $p1 1]  
  
  set x2 [lindex $p2 0]    
  set y2 [lindex $p2 1] 
  
  set lx [- $x2 $x1] 
  set ly [- $y2 $y1] 
  
  #set ret [sqrt [+ [* $lx $lx] [* $ly $ly]]]

  set ret [expr {sqrt (($lx * $lx) + ($ly * $ly))}]
  
  return $ret
}
# ------------------------------------------------------------------------------
proc new_prirezka_test {} {
  
  set p1   {94 58}    ;# (97594 132058)
  set p2   {70 80}    ;# (97570 132080)
  set p3   {86 54}    ;# (97586 132054)
  set p4   {92 57}    ;# (97592 132057)
  
  set n1   {83 68}    ;# (97583 132068)
  set n2   {79 90}    ;# (97579 132090)
  set n3   {60 88}    ;# (97560 132088)
  set n4   {47 80}    ;# (97547 132080)
  set n5   {53 70}    ;# (97553 132070)
  
  set a  [calc_len_points  $p3 $n1]
  set b  [calc_len_points  $n1 $p2]
  set c  [calc_len_points  $p2 $p3]
  
  #   (x  (/ (+ (- (* a a) (* b b)) (* c c)) (* 2 c)))
  #   (y  (sqrt (- (* a a) (* x x))))

  set x  [expr {((($a * $a) - ($b * $b)) + ($c * $c)) /  (2 * $c)}]
  set y  [expr {sqrt (($a * $a) - ($x * $x))}]

  
  #   (declare (ignore p1 p4 n2 n3 n4))
  
  puts ""
  puts "p2 __ p3 =  [calc_len_points  $p2 $p3]"  ;# 30.528675f0 
  puts "p2 __ n5 =  [calc_len_points  $p2 $n5]"   
  puts ""

  puts "a= $a b= $b c= $c"  
  puts "x= $x"  
  puts "y= $y" 
 
  puts ""
  
}
# ;#-------------------------------------------------------------------------------
# ;proc parse_opts {&population_size &max_generations  \
# ;                def_population_size def_max_generations} {

# ;#-------------------------------------------------------------------------------
# (defun parse_opts_int_int_int (index  int1 int2 int3)

# (let* (
#   ;(index  0)

#   (argus  (get_argus))
#   (argc   (list-length argus))
#   )

#   ;(format t "argc = ~s ~%" argc)
#   (setf __is_print false)
  
#   (set int1   (parse-integer (nth index argus))) (incf index)

#   ;(unless  (= argc 0) ;; если есть параметры
#   (set int2 (parse-integer (nth index argus))) (incf index) ; пишем в "символ"
#   (set int3 (parse-integer (nth index argus))) (incf index)
#   ;)
  

#   ;(when (= argc 3)
#   ;    (set r_dim             (parse-integer (nth 2 argus))) 
#   ;  )

#   (when (= argc (+ index 1))   ; cl v_pnts.cl  01  4 1  @
#     (setf __is_print true)
#     )

# ))
# ;#-------------------------------------------------------------------------------
proc parse_opts_int_int {index  &int1 &int2} {

  USE_REFS

  global argc argv argv0

  #   (argus  (get_argus))
  #   (argc   (list-length argus))
  
  set ::__is_print false
  
  #   (set int1 (parse-integer (nth index argus))) (incf index)
  #   (set int2 (parse-integer (nth index argus))) (incf index) ; пишем в "символ"
  
  set int1 [lindex $argv $index]  ; incr index
  set int2 [lindex $argv $index]  ; incr index
  
  #   (when (= argc (+ index 1))   ; ...... @

  if {$argc == [+ $index 1]} {

    set ::__is_print true
    set ::is_print   true
  }
  
}
# ;# //------------------------------------------------------------------------------
# ;#-------------------------------------------------------------------------------
proc make_test_orovo {} {

  # ; MDS - Multidimension Scaling
  
  set defnodes   {} ;# (make-array  0 :adjustable t :fill-pointer 0))
  set namededges {} ;# (make-array  0 :adjustable t :fill-pointer 0))
  
  #   ;; ----------------------------
  #   ;; TODO: задавать функциями с формированием имен и координат узлов!
  
        
  lappend defnodes {p_00_00    0.0    ""  true {0   0}} 
  lappend defnodes {p_30_00    0.0    ""  true {30  0}} 
  lappend defnodes {p_00_40    0.0    ""  true {0  40}} 
  lappend defnodes {p_30_40    0.0    ""  true {30 40}}  
  
  lappend defnodes {p_15_00    0.0    ""  false}
  lappend defnodes {p_15_40    0.0    ""  false}
  
  #   ;; ----------------------------
  #   ;; TODO: задавать функциями с формированием имен и длин ребер!
  
  lappend namededges { p_00_00  p_15_00  15 } 
  lappend namededges { p_15_00  p_30_00  15 }
  lappend namededges { p_00_40  p_15_40  15 }
  lappend namededges { p_15_40  p_30_40  15 }
  
  #   ;; TODO: сделать отдельную функцию, по индексам координат формировать
  #   ;;       имена и расстояния;
  #   ;; 
  
  #   ;; ----------------------------
    
  pntssolver_init_task  defnodes  $namededges  2  {30 40}
  
}
# ;# //------------------------------------------------------------------------------
proc  MAIN {} {
  
  set num_test          1
  set population_size  40 
  set max_generations  50

  # --------------------------------------------------

  global argc argv

  #set argv [lrange $argv 1 end]

  set num_test        [dict_parse $argv "-test"   1]
  set population_size [dict_parse $argv "-lpop"  40]
  set max_generations [dict_parse $argv "-nums"  50]
  set ::is_print      [dict_parse $argv "-print"  0]


  puts ""

  set ::__is_print $::is_print  

  puts ""
  puts "num_test        = $num_test"
  puts "population_size = $population_size" ;# lpop
  puts "max_generations = $max_generations" ;# nums
  puts ""

  comm_random_seed 23091975 ;# сюда вынес, чтобы отдельно формировать случайные точки
  

  #   ;;--------------------------------------------------
  switch -glob $num_test  {
  
    "1"  {make_test_1  1}
    "2"  {make_test_1  2}
    
    "20" {make_test_orovo}
    
    #     ;;------------------------------------------------
    
    "22" {
    
      make_real_orovo

      set ::is_print    1
      #set  ::__is_print true

      puts ""
      puts "population_size = $population_size"
      puts ""

      pntssolver_do  $population_size $max_generations \
        "GA_DE_STRATEGY_RANDTOBEST" \
        "GA_DE_CROSSOVER_BINOMIAL"  \
        1  ;# num_perturbed

      exit
    }

    "23" {
    
      new_prirezka_test
      exit
    }
    #default: {
    #  puts "ERROR num_test !!"
    #  exit
    #}
    
  }
  #   ;;--------------------------------------------------
  
  
  pntssolver_do   $population_size $max_generations
  
}
# ;-------------------------------------------------------------------------------

MAIN

# ;-------------------------------------------------------------------------------

# g_orov.jm  1  4 1 
# g_orov.jm  1  40 40 
# g_orov.jm  2  4 1 
# g_orov.jm 20  100 30 
# g_orov.jm 23 

# g_orov.jm 22 ERROR !!!!!!!!!!!!!!!!!!!!!!!!1 

# ;-------------------------------------------------------------------------------
