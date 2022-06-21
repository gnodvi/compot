# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------
#
# FunCode - робот-программист, конкурент нейросети AlpaCode от Google.
#
#-------------------------------------------------------------------------------


set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]


package require compot::common 

# ------------------------------------------------------------------------------
# идея в том, что :

# 1) идем с концов сравнивая;
# 2) если символы совпадают, значит мы его печатали, всё просто;
# 3) если не совпадают, то единственный вариант может быть, если там была;
#    нажата BACKSPACE, что "убмвает" сразу 2 символа - его и предыдущий;
# 4) ну м ограничения по началу строк смотрим;

# ------------------------------------------------------------------------------
proc solver_task_backspace_ver1 {s t n m} {

  set f 1  
  
  set i [expr {$n - 1}]
  set j [expr {$m - 1}]
  
  
  #for {set j [expr {$m - 1}]} {$j >= 0} {incr j -1} {}
  while {1} {
    
    if {$j < 0} {break}
    puts "j = $j "
    
    #       // while (i >= 0 && s[i] != t[j])
    while {1} {
      
      set si [string index $s $i]
      set tj [string index $t $j]
      
      puts "  i = $i, si = |$si|, tj = |$tj| " 
      
      if {$i < 0} {break} ;# и затем выйдем из цикла for
      
      if { $si == $tj } {
        break
      } ;# // символы равны, выходим на сдвиг в 1 символ
      
      incr i -2 ;#  // если не равны в исходной строке сдвигаемся на 2 символа
    }
    
    if {$i < 0} {
      set f 0
      break
    }
    
    incr i -1 ;# // и дальше указатель в исходной строке на 1 символ влево
    incr j -1 ;# 
  }
    
  return $f
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc pred_i {} {

  incr ::i -1 ;# уменьшили i на единицу

}
# ------------------------------------------------------------------------------
proc pred_j {} {

  incr ::j -1 ;# уменьшили i на единицу

}
# ------------------------------------------------------------------------------
proc if_si_tj_equal {todo} {

  set si [string index $::s $::i]
  set tj [string index $::t $::j]

  if { $si == $tj } {
    break;
  }
}
# ------------------------------------------------------------------------------
proc set_f_0 {} {

  set ::f 0  

}
# ------------------------------------------------------------------------------
proc set_f_1 {} {

  set ::f 1

}
# ------------------------------------------------------------------------------
proc break_if_i_negative {} {

  if {$::i < 0} {
  
    return -code break
  } 
  
}
# ------------------------------------------------------------------------------
proc break_if_j_negative {} {

  if {$::j < 0} {
  
    return -code break
  } 
  
}
# ------------------------------------------------------------------------------
proc break_if_i_equal_j {} {

  
  set si [string index $::s $::i]
  set tj [string index $::t $::j]
  
  if { $si == $tj } {
    return -code break
  } ;# // символы равны, выходим на сдвиг в 1 символ

}
# ------------------------------------------------------------------------------
proc setf0_and_break_if_i_negative {} {

  if {$::i < 0} {
  
    set_f_0
    return -code break
  } 
  
}
# ------------------------------------------------------------------------------
proc solver_global_tcl {} {

  while {1} {
    
    break_if_j_negative 
    
    while {1} {
      
      break_if_i_negative 

      break_if_i_equal_j 
      
      # если не равны в исходной строке сдвигаемся на 2 символа
      pred_i
      pred_i
    }
    
    setf0_and_break_if_i_negative 
    
    pred_i  ;# и дальше указатель в исходной строке на 1 символ влево
    pred_j
  }
   
}
# ------------------------------------------------------------------------------
proc solver_task_backspace_ver2 {s t n m} {

  # сделаем решение через глобальные переменные и укрупненные "макросы"
  # 

  set ::s $s
  set ::t $t
  set ::n $n
  set ::m $m

  set ::i  [- $::n 1]
  set ::j  [- $::m 1]
  
  set_f_1  
  
  solver_global_tcl
    
  return $::f
}
# ------------------------------------------------------------------------------
proc solver_task_backspace_ver3 {s t n m} {

  # сделаем решение через глобальные переменные и укрупненные "макросы"
  # 

  set ::s $s
  set ::t $t
  set ::n $n
  set ::m $m

  set ::i  [- $::n 1]
  set ::j  [- $::m 1]
  
  set_f_1  
  
  solver_global_fun
    
  return $::f
}
#-------------------------------------------------------------------------------
proc fun_init_solver {} {

  source "f-0000.tl"  ;# общие части
  source "f-1111.tl"  ;# простой jOY 


  v1_init_all  

  set ::while_end 0 ;# !!!!!!!!!!!!!!1


  v0_: while_1  {

    set do_part    [pop ]

    while {1} {
    
      r c ;# очистили стек и снова выполняем весь блок

      foreach d $do_part {

        #puts "d = $d"

        r  $d

        if {$::while_end} {
          break ;# выходим из foreach
        }
      }

      if {$::while_end} {
        set ::while_end 0 ;# чтобы продолжить цикл в охватывающем while
        break ;# а теперь выходим из while
      }

    }
    
  }  tcl  


  v0_: BREAK  {

    set ::while_end 1
    
  } tcl


}
#-------------------------------------------------------------------------------
proc test_fun {} {

  puts ""
  puts "test_fun ..."
  puts ""
  
  fun_init_solver 


  set ::i 0

  v0_: if_i7  {

    if {$::i == 7} {
      puts " if_end_do_breka: ::i == $::i  -> do while end"
      set ::while_end 1
    }
    
  } tcl

  v0_: if_i5  {

    set do_body [pop]

    if {$::i == 5} {
      r $do_body
    }
    
  } tcl

  #r c  10 {0 > } {1 - } while  .s  

  r c  { 
    {puts "............. ii = $::i BEG"} tcl {incr ::i} tcl   ~BREAK if_i5 \
    {puts "............. ii = $::i END"} tcl } while_1  

  puts ""

  return
}
# ------------------------------------------------------------------------------
proc solver_global_fun {} {


  fun_init_solver 


  v0_: pred_i  ~pred_i tcl
  v0_: pred_j  ~pred_j tcl

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_: break_if_j_negative {
    if {$::j < 0} {
      set ::while_end 1
    }    
  }  tcl
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_: break_if_i_negative {
    if {$::i < 0} {
      set ::while_end 1
      #puts "break_if_i_negative: !!! ::while_end = $::while_end"
    }    
  }  tcl
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_: setf0_and_break_if_i_negative {
    if {$::i < 0} {      
      set_f_0
      set ::while_end 1
    } 
  } tcl

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_: break_if_i_equal_j {

    set si [string index $::s $::i]
    set tj [string index $::t $::j]
    
    if { $si == $tj } {
      #return -code break
      set ::while_end 1
    } ;# // символы равны, выходим на сдвиг в 1 символ
    
  } tcl

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  r c  {

    break_if_j_negative 

    {
      break_if_i_negative
      break_if_i_equal_j

      pred_i
      pred_i
    } while_1 
 
    setf0_and_break_if_i_negative 
    pred_i
    pred_j

  } while_1  


}
# ------------------------------------------------------------------------------

set ::FILENAME "f_code.in"

# ------------------------------------------------------------------------------
proc task_backspace {} {

  #   ios_base::sync_with_stdio(false);
  #   cin.tie(NULL);
  
  #   freopen ("t_code.I",  "r", stdin);
  set fin [open $::FILENAME  "r"]
  
  #   int ttt;
  #   cin >> ttt; //  первое значение - количество тестов

  #set ttt [read $f] ;# причитали все сразу целиком
  set ttt [gets $fin] ;# причитали только первую строку

  puts "ttt = $ttt \n"
  
  for {set tt 0} {$tt < $ttt} {incr tt} {
  
    # один тест
  
    #  читаем две строки ?
    set s [gets $fin]
    set t [gets $fin]
  
    set n [string length $s]
    set m [string length $t] 
  
    puts ""
    puts "-------------------------------------"
    puts ""

    puts "s = $s, n = $n"
    puts "t = $t, m = $m"
  
    #-----------------------------------------

    # tcl, наиболее близкий к варианту на си
    # 
    set f [solver_task_backspace_ver1  $s $t $n $m]

    if {$f}  {
      puts "YES"
    } else {
      puts  "NO"
    }

    puts "~~~~~~~~~~~~"
   
    # tcl, через укрупненные макросы
    # 
    set f [solver_task_backspace_ver2  $s $t $n $m]

    if {$f}  {
      puts "YES"
    } else {
      puts  "NO"
    }
    puts "~~~~~~~~~~~~"
    
    # fun через укрупненные макросы
    # 
    set f [solver_task_backspace_ver3  $s $t $n $m]

    if {$f}  {
      puts "YES"
    } else {
      puts  "NO"
    }
    #-----------------------------------------

    
    #puts "------------------------------- "
    
  }
  
  #   return 0;
}
# ------------------------------------------------------------------------------
proc main {} {


  test_fun

  puts ""

  task_backspace 

  puts ""

}
#-------------------------------------------------------------------------------

main


#
################################################################################
