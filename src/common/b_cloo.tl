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
proc SETGET {args} {


  set setfix "__SET"
  set getfix "__GET"

  #set setfix "_S"
  #set getfix "_G"

  foreach {vn val} $args {

    uplevel 1 variable $vn $val  ;# сначала создаем переменную

    # а затем к ней методы доступа:
    #
    set setproc ${vn}$setfix 
    set getproc ${vn}$getfix

    #puts "setproc = $setproc"
    #puts "getproc = $getproc"

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

  uplevel 1 eval SETGET $args

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

oo::class create summation {

  variable MM 0 ;# так тоже можно ?? нет. похоже не создается переменная
 
  method getMM {} {
    variable MM
    return $MM
  }

  constructor {} {
    variable v 5
  }
  
  eval SETGET  {TT 111} 
  eval SETGET  {NN 555} 

  #eval SETGET     {NN 555}
  
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
proc testcall {s} {


  puts "VALUE = [$s getvalue]"

}
#-------------------------------------------------------------------------------
proc TEST_cloo {} {


  set sum [summation new]

  puts ""

  $sum TT__SET 222
  puts "TT =  [$sum TT__GET]"

  $sum NN__SET 333
  puts "NN =  [$sum NN__GET]"

  
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

  $sum destroy

}
#-------------------------------------------------------------------------------
proc TEST_cloo_time {} {

  #package require Itcl
  #namespace import itcl::*
  
  #set nums 10000
  set nums 100

  #class A {}
  
  oo::class create A {

    eval SETGET  {NN 555} 
  }

  puts ""

  set i 0
  puts "Create:   [time {A create $i;   incr i} $nums]"
  
  set i 0
  #puts "SetGet:   [time {$i set_NN $i;  $i get_NN;  incr i} $nums]"
  puts "SetGet:   [time {$i NN__SET $i;  $i NN__GET;  incr i} $nums]"

  set i 0
  #puts "Delete:   [time {delete object $i; incr i} $nums]"
  puts "Delete:   [time {$i destroy; incr i} $nums]"

  A destroy

}
#-------------------------------------------------------------------------------

oo::class create TESTT {


}

#-------------------------------------------------------------------------------
proc TEST_cloo_NEW {} {


  set tst [TESTT new]

  oo::define TESTT variable AAAA

  oo::objdefine $tst variable BBBB

  set [info object namespace $tst]::AAAA 5000

  puts ""
  puts "AAAA = [set [info object namespace $tst]::AAAA]" 
  puts ""


  puts "info class  variables  = [info class  variables TESTT]"
  puts "info object variables  = [info object variables $tst]"
  puts "info object vars       = [info object vars $tst]"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# b~.tl TEST TEST_cloo
# b~.tl TEST TEST_cloo_time
# b~.tl TEST TEST_cloo_NEW

################################################################################

