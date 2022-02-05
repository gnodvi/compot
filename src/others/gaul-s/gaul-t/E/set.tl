#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------


source "../../gaul-l/a-comm.tl"

puts ""
cd ..    ;# перейти в корневую директорию для выполнения заданий

#-------------------------------------------------------------------------------

#tst T1 E/OUT . "ga_x_tester.sh"

#tst T1 E/OUT . "ga_x_tester.tl de_test"

#tst T1 E/OUT . "ga_x_tester.tl de 9 2"


#tst T1 E/OUT . "ga_x_tester.tl  ga 20 10"

#tst T1 E/OUT . "ga_x_tester.tl sd2  5 5"

#-------------------------------------------------------------------------------

#tst T1 E/OUT . "l_all5s.tl _1  11 10 10"

#tst T1 E/OUT . "l_all5s.tl _2  11 10 10"

#tst T1 E/OUT . "l_struggle.tl _1  2 5 2"

#tst T1 E/OUT . "l_struggle.tl _2  5  1 1 1"


#tst T1 E/OUT . "l_struggle.tl _3  5 20"


#tst T1 E/OUT . "l_struggle.tl _4  10 2 @"

#tst T1 E/OUT . "l_struggle.tl _5  2 10 1"


#tst T1 E/OUT . "l_struggle.tl dc  1 5 2  @"

#-------------------------------------------------------------------------------

tst T1 E/OUT . "l_pingpong.tl _09  1 5 1  @"

#tst T1 E/OUT . "l_pingpong.tl _t1_25  1 2 4"

#-------------------------------------------------------------------------------

puts ""

#-------------------------------------------------------------------------------

