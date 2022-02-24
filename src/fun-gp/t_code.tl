# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
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
proc if_i_negative {} {

  uplevel 1  [list break]

#  if {$::i < 0} {
#
#    uplevel 2 break
#  } 

}
# ------------------------------------------------------------------------------
proc while_1 {body} {

  while {1} {

    uplevel  $body
  }

}
# ------------------------------------------------------------------------------
proc solver_global_tcl {} {

  set f  1  
  
  set ::i  [- $::n 1]
  set ::j  [- $::m 1]
  
  while {1} {
    
    if {$::j < 0} {break}
    
    while {1} {
      
      if {$::i < 0} {break} ;# и затем выйдем из цикла for
      #if_i_negative 


      set si [string index $::s $::i]
      set tj [string index $::t $::j]
      
      if { $si == $tj } {
        break
      } ;# // символы равны, выходим на сдвиг в 1 символ

      
      # если не равны в исходной строке сдвигаемся на 2 символа
      pred_i
      pred_i
    }
    
    if {$::i < 0} {
      set f 0
      break
    }
    

    pred_i  ;# и дальше указатель в исходной строке на 1 символ влево
    pred_j
  }
    
  return $f
}
# ------------------------------------------------------------------------------
proc solver_task_backspace_ver2 {s t n m} {

  # сделаем решение через глобальные переменные и укрупненные "макросы"
  # 

  set ::s $s
  set ::t $t
  set ::n $n
  set ::m $m

  set f [solver_global_tcl]
    
  return $f
}
# ------------------------------------------------------------------------------
proc test {} {

  set i 0

  while_1 {

    if {$i == 10} {
      break;
    }

    puts "i = $i"
    incr i
  }

}

# ------------------------------------------------------------------------------
proc main {} {

  #   ios_base::sync_with_stdio(false);
  #   cin.tie(NULL);
  
  #   freopen ("t_code.I",  "r", stdin);
  set fin [open "t_code.I"  "r"]
  
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
    set f [solver_task_backspace_ver1  $s $t $n $m]

    if {$f}  {
      puts "YES"
    } else {
      puts  "NO"
    }

    puts "~~~~~~~~~~~~"
    
    set f [solver_task_backspace_ver2  $s $t $n $m]

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
#-------------------------------------------------------------------------------
proc test_fun {} {

  source "f-0000.tl"  ;# общие части
  source "f-1111.tl"  ;# простой jOY 

  puts ""
  puts "test_fun ..."
  puts ""
  
  v1_init_all  

  #r c  1 2   ~+ i    .s 
  #r c  1 2 9 ~+ dip  .s 
  set ::i 0

  set ::while_end 0 ;# !!!!!!!!!!!!!!1

  v0_: while_1  {

    set do_part    [pop ]
    #set while_part [pop ]

    #puts "stack = $::joy_ST"

    while {1} {
    
      eval r  $do_part
      #eval r  $i $do_part
      #eval r  $i 

      if {$::i == 10} {break}
      if {$::while_end} {break}

      #incr ::i
      #puts "stack = $::joy_ST"
      #puts "i = $i"

     
      #eval r  dup  ;# продублировали верхний элемент, чтобы использовать его в сравнении

      #eval r  $while_part
      #puts "stack = $::joy_ST"
 
      #set ret [pop]  ;# забрали результат сравнения
      #puts "ret = $ret, stack = $::joy_ST"

      #if {$ret == 0} {
      #  break
      #} 
    }
    
  }  tcl  

  v0_: if_end_do_break  {

    if {$::i == 5} {
      puts "::i == 5 ..... "
      set ::while_end 1
    }
    
  } tcl

  #r c  10 {0 > } {1 - } while  .s  

  r c  { {puts "ii = $::i"} tcl {incr ::i} tcl  if_end_do_break } while_1  

}
#-------------------------------------------------------------------------------

main

puts ""

test

puts ""

test_fun

#
################################################################################
