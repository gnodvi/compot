# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc get_srand_from_argv {num} {

  global argc argv argv0

  #set num 1 ;# 1 , 2

  if {$argc != $num} {
    puts ""
    puts "USE: $argv0 <rand_seed>"
    puts ""
    exit
    
  } else {
    # стабилизатор генератора случ. чисел
    # это значение надо вводить из ком. строки

    set srand_init [lindex $argv [expr $num - 1]]
    # set srand_init [lindex $argv 0] 
  }
  
  # если спец флажок, то брать реально случайно !
  # 
  if {$srand_init == "@"} {
    # // random_tseed (); 
    # // random_seed ((unsigned int) (time (NULL)%RANDOM_RAND_MAX));
    
    # как то тут надо аналогично сделать , но пока можно псевдо (без времени)
    set srand_init [expr {int (100 * rand())}]
  }

  return $srand_init
}
#-------------------------------------------------------------------------------
proc set_srand_local_and_gaul {srand_init} {


  # начальная установка для местного (Tcl) генератора случ. чисел
  # 
  expr {srand ($srand_init)}
  
  #  понадобиться потом для переустановки srand (после инициализации)
  # 
  load T/tclgaul_gena.so Gaulgena

  return
}
#-------------------------------------------------------------------------------
proc seedrand_from_argv {{num 1}} {


  set srand_init [get_srand_from_argv $num]

  set_srand_local_and_gaul $srand_init

  return $srand_init
}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
