# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------


#TASK='-list "* +" -func "x ** 4 + x ** 3 + x ** 2 + x"'

# echo "TASK = $TASK"

# exit


#exec t~.tl TEST TEST_xx 

#eval exec r~.tl TEST TEST_xx  -seed @ -lpop 20 -size 20 -nums -1 -vers gp -news 1 -print 2 -list "* +" -func "x ** 4 + x ** 3 + x ** 2 + x"

#      -list "* + sin" -func 'sin ( x ** 2 + x )'

#      -func 'x ** 3 + x ** 2 + x'
#      -func 'x ** 3'


#-------------------------------------------------------------------------------


set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

#lappend auto_path \
  [file join [file dirname [info script]] "."] ;# "COM" "../common"


package require compot::common 

package require tcltest

# source "b-com0.tl"
# source "b-com1.tl"

#-------------------------------------------------------------------------------
#proc TEST {} {

source "f-0000.tl"  ;# общие части
source "f-1111.tl"  ;# простой jOY 

source "g-corE.tl"
source "t-proJ.tl"  ; # тесты на JOY
source "t_test.tl"  ; # т

#global argc argv

#incr ::ind0

#eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

#}
#-------------------------------------------------------------------------------

#TEST

#-------------------------------------------------------------------------------

#TASK='-list "* +" -func "x ** 4 + x ** 3 + x ** 2 + x"'

# echo "TASK = $TASK"

# exit


proc test_xx {} {

# t~.tl TEST TEST_xx  -seed @ -lpop 20 -size 20 -nums -1 \
#       -vers gp \
#       -print 2 \
#       -news 0 -list "* + dup"  -func "x ** 2"

TEST_xx  -seed @ -lpop 20 -size 20 -nums -1 \
      -vers gp \
      -print 2 \
      -news 0 -list "* + dup"  -func "x ** 2"
}

#      -news 1 -list "* + dup"  -func "x ** 3"
#      -list "* + 1" -func "4"

#      -list "* + 1" -func "x ** 2 + 2"
#      -list "* +" -func "x ** 4 + x ** 3 + x ** 2 + x"

#      -list "* + sin" -func 'sin ( x ** 2 + x )'

#      -func 'x ** 3 + x ** 2 + x'
#      -func 'x ** 3'


#-------------------------------------------------------------------------------

proc next_01 {} {

#t~.tl TEST NEXT_01 -seed 123 -lpop 10 -size 1 -nums -1 -list { p1 p3 p5 } 

set ::GP_iscrossover 0

NEXT_01 -seed @ -lpop 1 -size 1 -nums 20 -list "p1 p3 p5" -seed 2021 -print 2

}

#t~.tl TEST NEXT_01 -seed @ -lpop 10 -size 2 -nums 2 -list "p1 p3 p5" =print 3

#-------------------------------------------------------------------------------

#test_xx

next_01

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
################################################################################

