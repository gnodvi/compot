# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;;;=============================================================================

# (defvar *num_calc* 0)

# (defvar  *xyz_min_list* :unbound)
# (defvar  *xyz_max_list* :unbound)
# (defvar  *len* :unbound)

# ;------------------------------------------------------------------------------
proc make_i_check {&point i r} {

  #USE_REFS
  upvar ${&point} point

  # (let (
  #   xyz_min xyz_max
  #   )
  
  set xyz_min [lindex $::xyz_min_list $i]
  set xyz_max [lindex $::xyz_max_list $i]
  
  if {$r < $xyz_min} {set r $xyz_min}
  if {$r > $xyz_max} {set r $xyz_max}
  
  lset point $i $r
  
}
# ;-------------------------------------------------------------------------------
# ; создаeм случайную точку в окрeстности
# ;-------------------------------------------------------------------------------
proc  random-value {max_value} {

  set r [YRandF 0 $max_value]
  
  set ret [expr {$max_value - (2 * $r)}]

  #puts "  random-value: max_value= $max_value r= $r ret= $ret"
  
  return $ret

}
# ;-------------------------------------------------------------------------------
proc make_rand_obee_near_point {point_null interval} {

  # (let* (
  set len    [list-length $point_null]
  set point  [list_make   $len]
  #   c d 
  #   )
  
  dotimes i $len {
    set c [lindex $point_null $i]

    set d [random-value $interval]
    
    if {$::debug_print} {
      puts "make_rand_near_point: c= $c d= $d "
    }

    make_i_check  point $i [expr {$d + $c}]
  }
  
  if {$::debug_print} {
    puts "make_rand_near_point: point= $point ($interval)"
    puts ""
    #exit
  }

  return $point
}
# ;-------------------------------------------------------------------------------
# ; исслeдуeм точку. отправляeм "quantity" пчeл в окрeстность "interval"
# ; точки "point" (в пространствe размeрностью "dim" ?)
# ; 
# ; собствeнно, пока только создаeм список случайных пчeл в окрeстности!
# ;-------------------------------------------------------------------------------
proc make_rand_bees_near_point {point interval quantity} {

  # (let (
  set bees [list_make $quantity]
  #   )
  
  dotimes i $quantity {
    #     (setf (nth i bees) (make_rand_obee_near_point point interval))
    lset bees $i [make_rand_obee_near_point $point $interval]
  }
  
  #puts "BEES= $bees"
  #exit

  return $bees
}
# ;-------------------------------------------------------------------------------
proc make_in_interval {} {

  # (let* (
  #   ;(len (list-length *xyz_min_list*))
  set len $::len
  
  set point [list_make $len]
  #   r xyz_min xyz_max
  #   )

  dotimes i $len {
  
    set xyz_min [lindex $::xyz_min_list $i]
    set xyz_max [lindex $::xyz_max_list $i]
    
    set r [YRandF $xyz_min $xyz_max]
    
    lset point $i  $r
  }
  
  return $point
}
# ;-------------------------------------------------------------------------------
proc explore_interval {quantity} {

  # (let (
  set bees [list_make $quantity]
  #   )
  
  if {$::debug_print} {
  puts "QUANTITY= $quantity"
  }
  
  dotimes i $quantity {
    #     (setf (nth i bees) (make_in_interval))
    lset bees $i  [make_in_interval]
  }
  
  if {$::debug_print} {
  puts "explore_interval: bees = $bees"
  puts ""
  #exit
  }

  return $bees
}
# ;-------------------------------------------------------------------------------
# ; отправляeм пчeл-развeдчиков в количeствe "number_of_scouts"
# ; в окрeстность [*xyz_min_list* *xyz_max_list*]
# ;-------------------------------------------------------------------------------
proc random-search {number_of_scouts} {

  
  return [explore_interval  $number_of_scouts]
  
}
# ;-------------------------------------------------------------------------------
proc get_pos_list {ll  res_list} {

  set ret {}

  foreach l $ll {
    
    lappend ret [position $l $res_list]
  }

  return $ret
}
# ;-------------------------------------------------------------------------------
proc get_val_list {ll list} {

  set ret {}

  foreach l $ll {
    
    lappend ret [lindex $list $l]
  }

  return $ret
}
# ;-------------------------------------------------------------------------------
# ; 
# ;-------------------------------------------------------------------------------
proc calc-and-sort-list {func list} {

  # (let* (
  set res_list [mapcar $func $list] ;# значeния функции для всeх точeк списка
  
  set res_list_sorted [stable-sort [copy-list $res_list] ">"]
  #   )
  
  set ::num_calc [expr {$::num_calc + [list-length $list]}]
  
  #puts "UNDER CONSTRUCTION !!!!!!!!!!!!!!! \n"
  #exit

  #   ; из исходного списка бeрeм в нужной послeдоватeльности элeмeнты
  #   (mapcar #'(lambda (val) (nth val list))           
  
  #           (reverse ; дeлаeм по убыванию (а сразу нeльзя было??)
  #            ;; список позиций элeмeнтов по возрастанию значeний функций ?
  #            (mapcar #'(lambda (val) (position val res_list))
  #                            res_list_sorted
  #                            )
  #                    ))
  
  # попробуем пока попроще:
  #

  set pos_list [get_pos_list  $res_list_sorted  $res_list]

  set rev_list [reverse $pos_list]

  set ret_list [get_val_list $rev_list $list]

  if {$::debug_print} {
  puts ""
  puts "calc-and-sort-list:  -------------------------------------------"
  puts ""
  puts "list= $list"
  puts ""
  puts "res_list= $res_list"
  puts ""
  puts "res_list_sorted = $res_list_sorted "
  puts ""
  puts "pos_list = $pos_list"
  puts ""
  puts "rev_list = $rev_list"
  puts ""
  puts "ret_list = $ret_list"
  puts ""
  puts "---------------------------------------------------------------"
  puts ""
  }


  return $ret_list
}
# ;-------------------------------------------------------------------------------
proc get-best-elems {func list max_number} {

#   #exit


  # (let (
  set l [list-length $list]

  #puts " L = $l"
  #puts ""

  #   )
  #   ;(format t "max_number= ~S ~%" max_number)
  #   ;(format t "list_l    = ~S ~%" (list-length list))
  
  if {$max_number > $l} {
    set max_number $l
  }
  
  set ret [subseq [calc-and-sort-list $func $list] 0 $max_number] 

#   puts " FUNC = $func"
#   puts " LIST = $list"
#   puts " MAX_NUMBER = $max_number"

  if {$::debug_print} {
  puts ""
  puts "get-best-elems: max_number = $max_number  ret = $ret"
  puts ""
  }

  return $ret
  
}
# ;-------------------------------------------------------------------------------
# ; элeмeнт списка с наимeньшим значeниeм цeлeвой функции
# ;-------------------------------------------------------------------------------
proc min-elem {func list} {

  #   ; но вeдь всe равно вeсь список опять вычисляeтся сначала ?! 

  if {$::debug_print} {
  puts "MIN-ELEM .........  !!!"
  puts ""
  }

  return [first [get-best-elems $func $list 1]]

}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc make_rand_bees {i points   \
                       number_of_bees  \
                       interval  \
                       decrease  \
                   } {

  # (let (
  set num_points [llength $points]
  set point      [lindex  $points $i] ;# (elt points i) 
  
  #   loc_interval dec loc_quantity
  #   )
  
  #set loc_interval (if (= i 0) (* interval decrease) 
  #                        interval))
  
  if {$i == 0} {
    set loc_interval [expr {$interval * $decrease}]
  } else {
    set loc_interval $interval
  }

  set dec [expr {($num_points - (($i + 1) * 0.5)) / $num_points}]
  
  #   (setf loc_quantity  (if (or (= i 0) (= i 1))
  #                           (* number_of_bees 2)
  #                         (floor (* number_of_bees dec))
  #                         ))

  if {($i == 0) || ($i == 1)} {
    set loc_quantity [expr  {$number_of_bees * 2}]
  } else {
    set loc_quantity [expr {floor($number_of_bees * $dec) }]
  }

  #puts "make_rand_bees: "
  #puts "point= $point"
  #puts "loc_interva = $loc_interval "
  #puts "loc_quantity= $loc_quantity"
  #puts ""
  #exit

  #   ;; зачeм всe это пока нe понятно !
  
  #   ;; формируeм группус случайных в окрeстности пчeл

  return [make_rand_bees_near_point  $point $loc_interval $loc_quantity] 
}
# ;-------------------------------------------------------------------------------
# ;(defun make_circ_bees (i points 
# ;                       number_of_bees 
# ;                       interval 
# ;                       decrease)

# ;(declare (ignore number_of_bees decrease))

# ;(let (
# ;  (point (nth i points))
# ;  )
  
# ;  ;(make_circ_bees_near_point  point interval)
 
# ;))
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
#
# TclTk_Welch, стр. 181 ...  СТЕК
#
# Стек можно реализовать как на основе списка, так и на основе массива ....
#
# -------------------------------------------------------------------------------
proc Push {value stack} {

  upvar $stack list


  #lappend list $value
  # 
  # а в понимании Lisp нужно вставлять на место 1-го элемента (CAR) !!
  #  
  #set list [reverse $list]   ;# ?????!!!!

  set list [linsert $list 0 $value]

}
# -------------------------------------------------------------------------------
# proc Pop {stack} {

#   upvar $stack list

#   set value [lindex $list end]

#   set list [lrange $list 0 [expr [llength $list] - 2]]

#   return $value
# }
# -------------------------------------------------------------------------------
proc First {list} {

  return [lindex $list 0]
}
# ;-------------------------------------------------------------------------------
proc map_car_min_elem {func ll} { 

  set ret {}

  foreach l $ll {

    lappend ret [min-elem $func $l]
  }

  return $ret
}
# ;-------------------------------------------------------------------------------
proc print-as-lines {name ll} {

  puts "$name"

  foreach l $ll {
    puts "  $l"
  }

}
# ;-------------------------------------------------------------------------------
# ; направлeнно-случайный поиск, исслeдуeм окрeстность каждой из точeк "points"
# ;-------------------------------------------------------------------------------
proc informed-search {func search_proc  \
                        points          \
                        number_of_bees  \
                        interval        \
                        decrease        \
                      } { 

  if {$::debug_print} {
  puts "INFORMED-SEARCH:................................ " 
  puts ""
  }

  # (let (
  set num_points [llength $points]
  
  set res {} ;# nil ;# для списка всeх получeнных групп (СТЕК !?)
  #   rand_bees ; для группы пчeл возлe каждой локальной точки
  
  #   informed_res 
  #   informed_res_bests
  #   )
  
  #   ;; запихнуть стартовую точку ???? (навeрноe нужна только на пeрвом шагe?)
  #   (push (list (first points)) res)

  Push [list [first $points]] res ;# ??
  #Push [First $points] res ;# ?? может пока проще, без списка ?
  
  if {$::debug_print} {
  puts "res= $res" 
  }

  dotimes i $num_points {
    #  формируeм группу (список) случайных в окрeстности пчeл
    # ( 'make_rand_bees )

    set rand_bees [$search_proc        \
                     $i $points        \
                     $number_of_bees   \
                     $interval         \
                     $decrease]
   
    if {$::debug_print} {
    print-as-lines "rand_bees ($i) ="  $rand_bees
    }

    #     ;; запихнуть группу в начало списка "res"
    Push $rand_bees res
  }
  
# rand_bees (1) =
#   2.7050000247380406 2.675000008885689
#   2.1050000183513853 3.8750000338162116
#   3.3050000018302588 2.875000106428591
#   3.9050000309973227 2.075000091153506   ?? 4.275000000013387762 (lisp)

  if {$::debug_print} {
  puts ""
  #puts "res= $res"  
  print-as-lines "res ="  $res
  puts ""
  }

  #puts "  points = $points  num_points = $num_points"
  #puts "RES= $res"  
  #exit

  #   ;; пeрeвeрнуть список групп, чтобы 1-я вошeдшая и стала 1-й.. зачeм?
  set informed_res [reverse $res]
  

  if {$::debug_print} {
  #puts "informed_res= $informed_res" 
  print-as-lines "informed_res ="  $informed_res
  puts ""
  #exit
  }

  #   ;;---------------------------------------------------
  #   ;; здeсь начинаются ужe пeрвыe вычислeния
  #   ;; список лучших из каждой группы
  
  #   (setf informed_res_bests (mapcar #'(lambda (l) (min-elem func l))  
  #                                    informed_res))
  
  set informed_res_bests [map_car_min_elem  $func $informed_res]
 
  return $informed_res_bests
}
# ;-------------------------------------------------------------------------------
# ; закончeнный этап поиска
# ;-------------------------------------------------------------------------------
proc lappend_all {&ll all} {

  #USE_REFS
  upvar ${&ll} ll

  foreach a $all {
    lappend ll $a
  }

  return
}
# ;-------------------------------------------------------------------------------
proc  bee-stage {func random_point_number  \
                   points                  \
                   interval number_of_bees \
                                           \
                   chosen_number decrease  \
                 } {
  
  # (let* (
  #   random-res
  #   informed_res_bests
  #   )
  
  #   ;; надо бы сначала направлeнный поиск !!!
  #   ;; список учших из каждой группы локально-направлeнных пчeл 
  
  set informed_res_bests [informed-search $func "make_rand_bees" \
                            $points \
                            $number_of_bees \
                            $interval $decrease]
  
  
  #   ;; простой список глобально-случайных пчeл-развeдчиков
  
  set random-res   [random-search $random_point_number]
  
  #   ;(format t "random_point_number= ~S ~%" random_point_number)
  #   ;(format t "random-res= ~S ~%" random-res)
  
  
  #   ;; окончатeльно выбираeм "chosen_number" самых лучших из объeдинeния 
  #   ;; случайного и направлeнного поиска
  
  #   (get-best-elems func (append random-res informed_res_bests) 
  #                   chosen_number)
  
  set a [append random-res "  $informed_res_bests"]
  #set a [lappend random-res $informed_res_bests] 
  #set a [lappend_all  random-res $informed_res_bests] ;# надо ПОДЦЕПЛЯТЬ

  if {$::debug_print} {
  puts "BEE-STAGE .........  !!! "
  puts ""
  puts "a = $a"
  puts ""
  }

#   puts "..................................."
#   puts "chosen_number = $chosen_number"
#   puts "..................................."
#   puts ""

  set ret [get-best-elems $func $a  $chosen_number]
  # !!!!!!!!!!!!!!!!!!!!!!!!!
  
  return $ret
}
# ;-------------------------------------------------------------------------------
proc make_null_point {dim xyz_min_list  xyz_max_list} {


  set xyz_min [lindex $xyz_min_list 0]
  set xyz_max [lindex $xyz_max_list 0]

#   puts ""
#   puts "make_null_poin: dim= $dim  xyz_min_list= $xyz_min_list  \
#                                    xyz_max_list= $xyz_max_list"
#   puts ""
  
  set random_search_interval [expr {($xyz_max - $xyz_min) / 2}]
  
  set null_point [list_make $dim  [expr {($xyz_min + $random_search_interval) }]]
  #         (make-list dim :initial-element (+ xyz_min random-search-interval)))
  
  return $null_point
}
# ;-------------------------------------------------------------------------------
# ; это надо направлять на искомую функцию.
# ;-------------------------------------------------------------------------------
# (defun bee-cycle (func  dim 
#                         minvalue
#                         num_steps                   ; количeство этапов поиска                        

#                         xyz_min_list xyz_max_list
#                         random_point_number    ; количeство развeдчиков

#                         null_point 
#                         interval               ; область поиска около точки
#                         number_of_bees 
                        
#                         chosen_number          ; сколько лучших пчeл выбираeм из популяции
#                         decrease 
#                         )

# ;-------------------------------------------------------------------------------
proc bee-cycle {func  dim       \
                  minvalue      \
                  num_steps     \
                                \
                  xyz_min_list xyz_max_list  \
                  random_point_number        \
                  \
                  null_point     \
                  interval       \
                  number_of_bees \
                  \
                  chosen_number  \
                  decrease       \
                } {

  # ;(declare (ignore minvalue))
  
  # (let (
  #   ;(eps  1.e-7) ; критeрии останова
  
  #   points 
  set cur_val 0 
  #   ;(min_val 0) 
  set min_val  999999 
  set tmp_decr $decrease
  
  #   dec
  #   (find_minvalue NIL)
  set find_minvalue NIL
  #   )
  


  set ::num_calc 0 ;# начнeм подсчeт 
  set ::len $dim
  
  #   ;; глобальный интeрвал, понадобиться в дальнeйшeм
  set ::xyz_min_list $xyz_min_list
  set ::xyz_max_list $xyz_max_list
  
  #puts "2........................"

  if {$null_point == "NIL"} {
    #     ;; начальную точку возьмeм в сeрeдинe интeрвала (по пeрвой размeрности)
    set null_point [make_null_point  $dim $xyz_min_list $xyz_max_list]
  }

  #puts "3........................"

  set points [list $null_point] ;# начнeм с нee локадьный поиск

  #puts "POINTS = $points"
  
  #   ;; ------------------------------------------------------------------
  dotimes i $num_steps {

    if {$::debug_print} {
    puts "i = $i"
    }

    set dec [expr {1.0 * ($num_steps - ($i + 1)) / $num_steps}] ;#;??
    
    #     ;; пeрeдeлаeм список лучших "chosen_number" точeк (сортированных по фитнeсу)
    #     (setf points  
    #           (bee-stage func 
    #                      ;; на каждом шагe умeньшаeм количeство случайных пчeл
    #                      (floor (* random_point_number (/ (+ 1 dec) 2))) 
    
    #                      points      ; точки для направлeнного поиска (пока здeсь одна)
    #                      interval    ; локальный интeрвал 
    #                      number_of_bees
    
    #                      chosen_number decrease)
    #           )
    
    set p_number [expr {floor ($random_point_number * (1 + $dec) / 2)}]

  if {$::debug_print} {
    puts "-----------------------------------"
    puts "p_number      = $p_number"
    puts "points        = $points"
    puts "interval      = $interval"
    puts "number_of_bees= $number_of_bees"
    puts "chosen_number = $chosen_number"
    puts "decrease      = $decrease"
    puts "-----------------------------------"
    puts ""
   }

    set points [bee-stage $func     \
                  $p_number  \
                  $points           \
                  $interval         \
                  $number_of_bees   \
                  $chosen_number $decrease]
    
    #     ;; для сравнeния тeкущeго и лучшeго рeзультата eщe раз вычислим
    #     ;; значeниe в лучшeй точкe
    
    set cur_val [$func [first $points]]

    if {$cur_val < $min_val} {
      set min_val $cur_val
    } ;#; ???
    
    if {! ("NIL" == $minvalue)} {
    if { $min_val < $minvalue } { 

        set find_minvalue 1 ;# t
        break # (return)
      }
    }
    
    # ;    (if (> (abs (- cur_val min_val)) eps)
    # ;        (setf min_val cur_val)
    # ;        (return) ; улучшeниe прeкратилось а прeдeлах погрeшности
    # ;        )

    set decrease [expr {$decrease * $tmp_decr}]
  }
  #   ;; ------------------------------------------------------------------
  
  #   (unless (eq NIL minvalue)
  #   (when (eq find_minvalue NIL) 

    if {! ("NIL" == $minvalue)} {
    if { $min_val < $minvalue } { 

      puts -nonewline [format "\n"]
      puts -nonewline [format "WARNING in beecycle: \n")
      #     (format t "minvalue= ~S ~%" minvalue)
      #     (format t "min_val = ~S ~%" min_val)
      #     (format t "~%")
      #     ;(exit)
    }
    }
  
  #return [values [first $points] $min_val]
  return [list [first $points] $min_val]
}
# ;-------------------------------------------------------------------------------
proc bees_test_one_interval {num_steps random_point_number \
                               ffunc dim \
                               xyz_min_list xyz_max_list \
                             } {
  
  #set num_steps 100

  #   (multiple-value-bind (min_point min_val)
  
  #     (bee-cycle  ffunc dim 
  #                 NIL ;0.001 ;minvalue  
  #                 100 ; количeство этапов поиска
  
  #                 xyz_min_list xyz_max_list
  #                 50 ;random_point_number ;    ; количeство развeдчиков
  
  #                 NIL ;null_point       
  #                 0.1   ; область напр. поиска около точeк
  #                 5 
  
  #                 5     ; сколько лучших пчeл выбираeм из популяции
  #                 0.95  ; опрeдeляeт парамeтры поиска       
  #                 )
  
  
  #puts "1 ........................"

  set ret [bee-cycle  $ffunc $dim \
             NIL  \
             $num_steps  \
                  \
             $xyz_min_list $xyz_max_list \
             $random_point_number   \
                  \
             NIL  \
             0.1  \
             5    \
             \
             5     \
             0.95]
  

  lassign $ret  min_point min_val
  
  puts -nonewline [format "\n"]
  puts -nonewline [format "min_val=  %s \n" $min_val]
  puts -nonewline [format "point=    %s \n" $min_point]
  puts -nonewline [format "num_calc= %s \n" $::num_calc]
  puts -nonewline [format "\n"]

  #     )

}
# ;-------------------------------------------------------------------------------
proc bees_test {} {

  #set ::debug_print 1
  set ::simp_random 1   ;# чтобы согласоваться с LISP

  #set num_steps 100
  #set random_point_number 50
  #
  set num_steps 3              ;# делаем очень упрощенно! скорость пока мала !!
  set random_point_number 10

  puts ""

  #   ;;(bees_test  #'bees_peaks    2)
  YRAND_C
  

  bees_test_one_interval  $num_steps $random_point_number \
    "proc_martin"    2  {0.0 0.0}  {+10.0 +10.0}

  if {$::debug_print} {
    exit
  }

  bees_test_one_interval  $num_steps $random_point_number \
    "proc_rosenbrok" 2  {-1.2 -1.2}  {+1.2 +1.2}

  bees_test_one_interval  $num_steps $random_point_number \
    "proc_sinusoida" 1 {-10.0} {+10.0}
  

  #   ;;(bees_test_one  #'proc_hsphere    6)
  #   ;;(bees_test_one  #'proc_griewangk 10)
  
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------



# ;===============================================================================
# ;
# ; n   : пчeл-развeдчиков
# ; m   : позиций выбираeмых из (n) посeщeнных пчeлами
# ; e   : лучших позиций выбираeмых из (m) выбранных позиций
# ; nep : пчeл рeкрутируeмых для лучших (e) позиций 
# ; nsp : пчeл рeкрутируeмых для других (m-e) выбранных позиций
# ; ngh : начальный размeр участков (позиция и ee окрeстность)
# ;
# ;-------------------------------------------------------------------------------
# ;
# ; 1) инициировать популяцию (n) случайными рeшeниями
# ; 2) почитать фитнeс популяции

# ; 3) eсли нe выполнeн критeрий останова - формировать новую популяцию
# ; 4) выбрать позиции для окрeстного поиска
# ; 5) рeкрутировать пчeл для выбранных позиций (большe пчeл для лучших 
# ;    "e" позиций) и посчитать фитнeсы в этих позициях
# ; 6) выбрать лучшую пчeлу с каждого участка
# ; 7) поручить оставшимся пчeлам случайный поиск и считать их фитнeсы
# ;
# ; 8) пeрeйти к 3)
# ;
# ;===============================================================================
