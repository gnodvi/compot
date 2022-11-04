# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


# ;(load "t-graf.cl")

# ==============================================================================
#
#  СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ   СEТИ  
#
# ==============================================================================

# (defclass NET (GRAF) (
# ;  GRAF *gr;

#   (i  :accessor I)
#   (o  :accessor O)

# ;  int   i, o;
# ;  int  *activ, *activ_new, *a[2], num;
#   (activ     :accessor ACTIVE)
#   (activ_new :accessor ACTIVE_NEW)

#   (a0   :accessor A0)
#   (a1   :accessor A1)
#   (num  :accessor NUM)
# ))


# ------------------------------------------------------------------------------
# ;NET *
# ;net_create (int nn)
# ------------------------------------------------------------------------------
# (defun net_create (nn)

# (let (
#   (net (make-instance 'NET))
#   )

#   (graf_init_main net nn)  
#   (graf_init net GR_RAND 0.0 0.0 GR_RAND NOS NOS)

#   (setf (A0 net) (make-list nn))
#   (setf (A1 net) (make-list nn))

#   (dotimes (i nn)
#     (setf (nth i (A0 net)) 0)
#     (setf (nth i (A1 net)) 0)
#     )

# ;  net->activ     = net->a[0];
# ;  net->activ_new = net->a[1];
#   (setf (ACTIVE net)     (A0 net))
#   (setf (ACTIVE_NEW net) (A1 net))

#   (setf (NUM net) 0)

#   net
# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;net_set_activ (NET *net, int index)
# ;-------------------------------------------------------------------------------
# (defun net_set_activ (net index)
  
#   (setf (nth index (ACTIVE net)) 1)

# )
# ;-------------------------------------------------------------------------------
# (defun net_print (net)

# (let (
#   act
#   )

#   (graf_print net)

#   (dotimes (i (NN net))
#     (setf act (nth i (ACTIVE net)))
    
#     (cond 
#      ((= act 0) (format t "  -  "))
#      ((= act 1) (format t "  +  "))
#      (t          (format t "  ~s  " act))
#      )
#     )

#   (format t "~%")

# ))
# ;-------------------------------------------------------------------------------
# (defun net_activate (net)

# (let* (
# ;  int i, j;
#   edge
  
#   (gr net)
#   (nn (NN gr))
#   )

#   (dotimes (i nn)
# ;     if (! net->activ[i]) continue;
#   ;(unless (not (= (nth i (ACTIVE net)) 1))
#   (unless (= (nth i (ACTIVE net)) 0)

#     (format t "activ= ~s  -> " i)

#     (dotimes (j nn)
# ;       if (i == j) continue;  // пока без циклов на себя
#     (unless (= i j)
#        (setf edge (EDGE gr i j))
# ;       if  (edge == NOT) continue;
#        (unless (= edge NOS)

#        (format t " ~s" j)
#        ;; активируем новые узлы
#        (setf (nth j (ACTIVE_NEW net)) 1)
#     )))

#      (format t "~%")
#      ;; старый гасить нет смысла
#   ))

#   ;; поменяем указатели

#   (if (= (NUM net) 0) (progn 
#     (setf (ACTIVE net)     (A1 net))
#     (setf (ACTIVE_NEW net) (A0 net))
#     (setf (NUM net)  1)
#   ) (progn 
#     (setf (ACTIVE net)     (A0 net))
#     (setf (ACTIVE_NEW net) (A1 net))
#     (setf (NUM net)  0)
#   ))

#   ;; и очистим новую рабочую область
#   (dotimes (i nn)
#     (setf (nth i (ACTIVE_NEW net)) 0)
#   )

# ))
# ;-------------------------------------------------------------------------------
# (defun net_test0 (argus)

# (declare (ignore argus))

# (let (
#   (net  (net_create 3))
#   )

#   (setf (EDGE net 0 1) 1)
#   (setf (EDGE net 1 2) 1)

#   (net_set_activ net 0)
#   (net_print net)

#   (net_activate net)
#   (net_print net)

#   (net_activate net)
#   (net_print net)

# ))
# ;-------------------------------------------------------------------------------




# ;===============================================================================
# ;
# ;  АВТОМАТЫ   ААВТОМАТЫ   АВТОМАТЫ   АВТОМАТЫ   АВТОМАТЫ   АВТОМАТЫ   АВТОМАТЫ 
# ;
# ;===============================================================================


# record define AMAT { 

#   GR
#   ACTIVE
# }

# ;/*----------------------------------------------------------------------------*/
# ;
# ;-------------------------------------------------------------------------------
proc amat_set_active {am index} {  

  dict_set $am "ACTIVE"  $index

}
# -------------------------------------------------------------------------------
proc amat_create {nn} {  

  
  #set am   [make-instance "AMAT"]
  set am   [dict_create]

  dict_set $am "GR"  [graf_create $nn]  

  amat_set_active $am 0  
  
  return $am
}
# -------------------------------------------------------------------------------
proc amat_print {am} {  

  graf_print [dict_get $am "GR"]

  puts -nonewline [format "ACTIVE= %s \n" [dict_get $am "ACTIVE"]]
  puts ""

}
# -------------------------------------------------------------------------------
proc amat_do_step {am} { 
 
  set gr [dict_get $am "GR"]
  
  set active_node [dict_get $am "ACTIVE"]

  # провeряeм циклом всe рeбра, выходящиe из этого активного узла 

  dotimes u [dict_get $gr "NN"] { 
    
    set edge [EDGE_get $gr $active_node $u] 
    
    if {[llength $edge] != 2} {continue}

    # если там есть условный переход

    set cond [lindex $edge 0] 
    set prog [lindex $edge 1]

    # проверяем его и при выполнении условия

    if {! [expr $cond]} {continue}

    eval $prog ;# выполняем !!

    dict_set $am "ACTIVE"  $u ;# передвигаем метку активного узла

    break ;# остальные узла не проверяем, подразумевая, что у нас пока одна метка
  }
  
  return
}
# ------------------------------------------------------------------------------
proc amat_03 {} {  

  set am [amat_create 4] 
  
  set gr [dict_get $am "GR"]

  EDGE_set  $gr 0 1  [list  {10 == 10} {puts "DO STEP ... 0 --> 1"}]
  
  EDGE_set  $gr 1 2  $::NIL
  EDGE_set  $gr 1 3  $::T
  EDGE_set  $gr 2 3  $::T
  EDGE_set  $gr 3 0  $::T
  
  puts ""
  amat_print   $am
  

  amat_do_step $am  
  puts ""
  amat_print   $am
  

  amat_do_step $am  
  puts ""
  amat_print   $am

  
  amat_do_step $am  
  puts ""
  amat_print   $am
  
  puts ""

  return
}
# =============================================================================
# 
# g~.tl NETS amat_03
# 
# =============================================================================
