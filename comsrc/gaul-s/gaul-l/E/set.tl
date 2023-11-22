#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------


#source "../a-comm.tl"
source "../../common/src/a-comm.tl"

puts ""
cd ..    ;# перейти в корневую директорию для выполнения заданий

#-------------------------------------------------------------------------------

#tst  1 E/OUT . "g_list.tl"

#tst  1 E/OUT . "g_memt.tl"

tst  1 E/OUT . "g_nams.tl"


#-------------------------------------------------------------------------------

#tst  3 E/OUT . "x~.tl TEST_xx  2013  10 6 10"

#tst  3 E/OUT . "x~.tl TEST_more"

#tst  3 E/OUT . "x~.tl TEST_simp"

#tst  3 E/OUT . "t~.tl TEST_errs"

#tst  3 E/OUT . "t~.tl ANTS test_antsFitness"

#tst  3 E/OUT . "t~.tl ANTS_test_shalito_joy 50"

#tst  1 E/OUT . "js~.tl TEST_main j__02.joy"

#tst  1 E/OUT . "js~.tl TEST_main j__03.joy"

#-------------------------------------------------------------------------------

#tst  1 E/OUT . "progen.tcl @ main_test"
#tst  1 E/OUT . "progen.tcl main_test @ 4 3 2"

#tst  1 E/OUT . "a_test.tcl main_test @ 4 3 2"


# tst  1 E/OUT . "apathy.tcl simp_test"
# tst  1 E/OUT . "apathy.tcl main_test a0.joy"
# tst  1 E/OUT . "apathy.tcl main_test a1.joy"

#tst  1 E/OUT . "apathy.tcl more_test"
#tst  1 E/OUT . "apathy.tcl main_test a2.joy"

#tst  1 E/OUT . "t_speed.sh"
#tst  1 E/OUT . "diff -s t_speed4.png t_speed4.png.png  2> $1"
#tst   2 E/OUT . "diff -s t_speed4.png t_speed4.png.png"
#tst   2 E/OUT . "diff -s t_minmax.png t_minmax.png.png"


#tst   2 E/OUT . "y~.tl TEST_01"
#tst   2 E/OUT . "z~.tl TEST_trans_01"
#tst   2 E/OUT . "z~.tl ANTS_t2"
#tst   2 E/OUT . "z~.tl ANTS_test_shalito"

#tst   2 E/OUT . "z~.tl ANTS_test_new"
#tst   2 E/OUT . "z~.tl ANTS_test_joy"

#===============================================================================
# перейти в корневую директорию для выполнения заданий
#cd ..

#tst A E/OUT . "joy.cl" 
#tst A E/OUT . "l_ga.tcl"
#tst A E/OUT . "l_gp.tcl"

# tst A E/OUT . "j_find" 

# tst A E/OUT . "j_main j_00.joy" 
# tst A E/OUT . "j_main j_01.joy" 
# tst A E/OUT . "j_main j_02.joy" 


#===============================================================================
# перейти в НУЖНУЮ директорию для выполнения заданий
# cd ../L

# tst B E/OUT . "j_main grmtst.joy" 
# tst B E/OUT . "j_main jp-joytst.joy" 
# tst B E/OUT . "j_main laztst.joy" 
# tst B E/OUT . "j_main modtst.joy" 
# tst B E/OUT . "j_main mtrtst.joy" 
# tst B E/OUT . "j_main plgtst.joy" 
# tst B E/OUT . "j_main symtst.joy" 

#---------------------------------------
# тесты с ошибками
#---------------------------------------
#tst B E/OUT . "j_main lsptst.joy"
#tst B E/OUT . "j_main joytut.inp"
#---------------------------------------

#tst C E/OUT . "j_main jp-church.joy" 
#tst C E/OUT . "j_main jp-nestrec.joy" 


#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------

puts ""

#-------------------------------------------------------------------------------

