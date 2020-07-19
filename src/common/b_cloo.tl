# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#   TclOO   TclOO   TclOO   TclOO   TclOO   TclOO   TclOO   TclOO   
#-------------------------------------------------------------------------------

package require TclOO;     #if loading for the first time


#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/17667
# Automatic get/set methods for an itcl class

#-------------------------------------------------------------------------------
# for TclOO 
#-------------------------------------------------------------------------------
proc VAR {args} {

  set setfix "SET_"
  set getfix "GET_"


  foreach {vn val} $args {

    uplevel 1 variable $vn $val  ;# сначала создаем переменную

    # а затем к ней методы доступа:
    #

    set setproc ${setfix}${vn} 
    set getproc ${getfix}${vn}

    uplevel 1 method $setproc \{v\} \{[subst -nocommand {set $vn \$v}] \}
    uplevel 1 method $getproc \{\}  \{[subst -nocommand {return $$vn}] \}

    #The  method  will  be
    #          exported  if  name  starts  with  a  lower-case letter, and non-
    #          exported otherwise; this behavior can be overridden  via  export
    #          and unexport.

    uplevel 1 export $setproc $getproc ;# теперь можно слюбых букв начинать!
  }

}
#-------------------------------------------------------------------------------
proc SET_GET {args} {

  uplevel 1 eval VAR $args

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# Команда SUBST применяется при наличии разнообразных Tcl-команд, ссылок на 
# переменные и обычных данных. Эта команда ищет квадратные скобки, знаки $ и 
# символы обратной косой черты и выполняет подстановку. Остальные данные остаются 
# неизменными.
# .. подстановка выполняется независимо от фигурных скобок. Чтобы запретить 
# подстановку команд и переменных, можно использовать обратную косую черту.
#
# При вызове команды могут указываться опции -nobackslashes, -nocommands и 
# -novariables, которые ограничивают ее возможности по выполнению подстановки.
# 
#
#-------------------------------------------------------------------------------
proc Set {obj var val} {

  set [info object namespace $obj]::${var} $val

}
#-------------------------------------------------------------------------------
proc Get {obj var} {
  
  return  [set [info object namespace $obj]::${var}]

}
#-------------------------------------------------------------------------------
proc TEST_cloo_time {} {

  #package require Itcl
  #namespace import itcl::*
  
  #set nums 10000
  set nums 100

  #class A {}
  
  oo::class create A {

    eval VAR  {NN 555} 
  }

  puts ""

  set i 0
  puts "Create:   [time {A create $i;   incr i} $nums]"
  
  set i 0
  puts "SetGet:   [time {$i SET_NN $i;  $i GET_NN;  incr i} $nums]"

  set i 0
  #puts "Delete:   [time {delete object $i; incr i} $nums]"
  puts "Delete:   [time {$i destroy; incr i} $nums]"

  A destroy

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc testcall {s} {


  puts "VALUE = [$s getvalue]"

}
#-------------------------------------------------------------------------------

oo::class create summation {

  variable MM 0 ;# так тоже можно ?? нет. похоже не создается переменная
 
  VAR XX 

  constructor {} {
    variable v  5
    variable MM 111

    set XX 999
  }
  
  method getMM {} {
    variable MM
    return  $MM
  }

  VAR  RR 

  eval VAR  {TT 111}  ;# eval when {name value}
  eval VAR  {NN 555} 


  method setvalue {val} {
    variable v
    set v $val 
  }
  method getvalue {} {
    variable v
    return $v
  }
  
  method add x {
    variable v
    incr v $x
  }
  
  destructor {
    variable v
    puts "Ended with value $v"
  }
}

#-------------------------------------------------------------------------------
proc TEST_cloo {} {


  set sum [summation new]

  puts ""

  #puts "NN =  [$sum GET_NN]"
  #puts "NN =  [$sum GET_NN]"
 
  puts "XX =  [$sum GET_XX]"
  $sum SET_XX 888
  puts "XX =  [$sum GET_XX]"

  puts ""
  puts "---------------------------------------------------"
  puts ""


  $sum SET_TT 222
  puts "TT =  [$sum GET_TT]"

  $sum SET_NN 333
  puts "NN =  [$sum GET_NN]"

  
  puts ""
  puts "Start with [$sum getvalue]"
  
  $sum setvalue 10

  puts "Start with [$sum getvalue]"
  puts ""


  for {set i 1} {$i <= 10} {incr i} {

    $sum add $i
    puts "Add $i to get [$sum getvalue]"
  }

  puts ""

  testcall $sum

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  puts "MM = [$sum getMM]"

  Set $sum MM 5000
  
  puts "MM = [Get $sum MM]"


  Set $sum XX 6000
  
  puts "XX = [Get $sum XX]"

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  $sum destroy

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

oo::class create TESTT {


}

#-------------------------------------------------------------------------------
proc TEST_cloo_NEW {} {


  set tst [TESTT new]

  Set $tst AAAA 5000 ;# норм, но тогда ее не будет в списке переменных класса!

  oo::define    TESTT variable AAAA 1234

  puts ""
  puts "AAAA = [Get $tst AAAA]" 
  puts ""


  oo::objdefine  $tst variable BBBB

  puts "info class  variables  = [info class  variables TESTT]"
  puts "info object variables  = [info object variables $tst]"
  puts "info object vars       = [info object vars      $tst]"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# b~.tl TEST TEST_cloo
# b~.tl TEST TEST_cloo_time
# b~.tl TEST TEST_cloo_NEW

################################################################################

