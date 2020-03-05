# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc arr2d_make {ii jj} {  

  set size  [expr {$ii * $jj}]

  set array [list_create_num_val $size "@"]

  # "двумерный" список заменить на реально вложенный, по глобальному
  # имени !?
  # структуру заменить на DICT !! ??

  set a [MAKE_GLOBAL_NAME] ;# получили глобальное имя (ссылку)

  set ${a}(ii)    $ii
  set ${a}(jj)    $jj


  set ${a}(array) $array  
  
  return $a
}
# -------------------------------------------------------------------------------
proc arr2d_ii {a} { 


  return [set ${a}(ii)]   
}
# -------------------------------------------------------------------------------
proc arr2d_jj {a} { 


  return [set ${a}(jj)]   
}
# -------------------------------------------------------------------------------
proc arr2d_get {a i j} { 

  set ii   [arr2d_ii $a]
  set jj   [arr2d_jj $a]
  
  set ind  [expr {$i * $jj + $j}] ;# ???!!!! тоже дает задержку ???!!! немного
  
  set arr_name [set ${a}(array)]
  
  set arr [set $arr_name]  
  
  return [lindex $arr $ind]    
} 
# -------------------------------------------------------------------------------
proc arr2d_set {a i j val} { 

  set ii    [arr2d_ii $a]
  set jj    [arr2d_jj $a]
    
  set ind [expr {$i * $jj + $j}]

  set arr_name [set ${a}(array)]

  lset $arr_name $ind $val  ;# сильный тормоз !!
} 
# -------------------------------------------------------------------------------
proc arr2d_print {a} {  

  set ii    [arr2d_ii $a]
  set jj    [arr2d_jj $a]

  puts "ii    = $ii"
  puts "jj    = $jj"
  puts "array = "

  for {set i 0} {$i < $ii} {incr i} {

  puts -nonewline "      "
  for {set j 0} {$j < $jj} {incr j} {

    set val [arr2d_get $a $i $j]

    puts -nonewline "$val "
  }
    puts ""
  }

  return
}
#-------------------------------------------------------------------------------
proc ARR2_test {} {  

  set a [arr2d_make 10 20]

  set ii    [arr2d_ii $a]
  set jj    [arr2d_jj $a]

  for {set i 0} {$i < $ii} {incr i} {
  for {set j 0} {$j < $jj} {incr j} {
    
    arr2d_set  $a $i $j "$i$j"     
  }}


  puts ""
  puts "!!!!!!!!!!!!!!!!!!!!!"
  puts ""

  arr2d_print $a

  puts ""

}
#-------------------------------------------------------------------------------

# b~.tl MISC ARR2_test

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
