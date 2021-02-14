# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM

#-----------------------------------------------------------------

# сюда уже входит f-sort.tl !!
# 
package require compot::common 

#-------------------------------------------------------------------------------
proc sort_test {} {

  set my_list "2 1 5 4 6"
  
  #   (print (sort my-list #'<))  ;(1 2 4 5 6)
  #   (print (sort my-list #'>))  ;(6 5 4 2 1)
  #   (print (k-sort my-list ))   ; 
  
  puts ""

  puts [lsort -increasing $my_list]  ;# (1 2 4 5 6) by default
  puts [lsort -decreasing $my_list]  ;# (6 5 4 2 1)
  
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc sort_main {} {

  set Orign {44 55 12 42 94 18  6 67}
  set Sorts { 6 12 18 42 44 55 67 94}
  
  puts ""

  ai_print $Orign  "Orign"    
  ai_print $Sorts  "Sorts"
   
  puts ""
  puts "------------------------------------------------"
  puts ""

  #----------------------------------------------------------------------
  # обратные функции драйвра сортировки
  
  set sortcmd "lsort_MIN_to_LEFT"

  set ret [lsort -command $sortcmd $Orign] 
  ai_print $ret $sortcmd
    

  set sortcmd "lsort_MAX_to_LEFT"

  set ret [lsort -command $sortcmd $Orign] 
  ai_print $ret $sortcmd
    
  #----------------------------------------------------------------------
  puts ""
  #----------------------------------------------------------------------

  # функция признак-сортировки возвращает TRUE, если положение двух элементов
  # нас устраивает (сдева меньше или слева больше)

  #set sortcmd "LT"
  set sortcmd "qsort_MIN_to_LEFT"

  set ret [qsort_AF $Orign $sortcmd] ;# меньшие налево
  ai_print $ret $sortcmd
    
  #set sortcmd "GT"
  set sortcmd "qsort_MAX_to_LEFT"

  set ret [qsort_AF $Orign $sortcmd] ;# большие налево
  ai_print $ret $sortcmd 
    
  #----------------------------------------------------------------------

  puts ""
  
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# proc  SORT-TABS {} {

#   #source "f_sort.tl"

#   global argc argv
#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

#   #   (run_cdr_argus (first argus) argus "TEST ..")

# }
#-------------------------------------------------------------------------------
# f~.tl,TOUR,tour_main
#-------------------------------------------------------------------------------
proc TOUR {} {

  #source "f-tabs.tl" 
  #source "f-tour.tl"
  # эти файлы включаются через package require
  
  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------

set CUR_DIR "f"
  
READ_AND_CALL_ARGUS  $CUR_DIR

# ;-------------------------------------------------------------------------------
# (defun SORT-TABS (argus)

#   (my_load "f-sort.cl" CUR_DIR) (use-package :a_sort)
#   (my_load "f-tabs.cl" CUR_DIR) (use-package :a-ctab)

#   (load "f_test.li")

#   (run_cdr_argus (first argus) argus "TEST ..")

# )
# ;-------------------------------------------------------------------------------
# ;(defun SORT-TEST (argus)

# ;  (my_load "f-sort.cl" CUR_DIR) (use-package :a_sort)

# ;  (run_cdr_argus (first argus) argus "SORT ..")
# ;)
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# (defun TOUR (argus)

#   (my_load "f-tabs.cl" CUR_DIR) (use-package :a-ctab)

#   (load "f-tour.cl")
#   (run_cdr_argus (first argus) argus "TEST ..")

# )
#-------------------------------------------------------------------------------

# l~.tl SORT-TEST sort_main

#-------------------------------------------------------------------------------

# TODO: 

# - объeктная сорeвноватeльная систeма (стeнка на стeнку);
# - список популяции тожe сдeлать частью систeмы ТАБ-ТУР;
# - 
# - сорeвнованиe сортировок (болee тонкая настройка парамeтров и типов данных);
# - рождение сортировок, поиск оптимальных параметров уже заданных алгоритмов;

#-------------------------------------------------------------------------------


# l~.tl SORT-TEST sort_main
# l~.tl SORT-TEST sort_test

# l~.tl TOUR tour_main
# l~.tl SORT-TABS sort_main_03

#-------------------------------------------------------------------------------
