# -*-   mode: tcl  ; coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
set auto_path [linsert $auto_path 0 "COMPOT/src"]

package require compot::common 

#-------------------------------------------------------------------------------

set auto_path [linsert $auto_path 0 "COMPOT/src/optima"]

package require compot::optima

#-------------------------------------------------------------------------------

my_load "r-obot.tl" CUR_DIR
my_load "r-ogsl.tl" CUR_DIR



my_load "s_fun0.tl" CUR_DIR)
 
#-------------------------------------------------------------------------------
proc FUNO {} {

  source  "s_funo.tl"

  global argc argv
  eval [lindex $argv 1] ;#

  #   (run_cdr_argus (first argus) argus "FUNO ..")
}
#-------------------------------------------------------------------------------
proc SOLV {} {

  my_load "solve0.tl" CUR_DIR 

  #   (load "solver.li")
  source  "solver.tl"

  global argc argv
  eval [lindex $argv 1] ;#

  #   (run_cdr_argus (first argus) argus "SOLV ..")
}
#----------------------------------------------------------------------------

# (READ_AND_CALL_ARGUS  CUR_DIR)

# ============================================================================
# ; TODO: 

# ;+ sl s~.cl SOLV berger_main
# ;+ sl s~.cl SOLV gazdin_main     (простой нeполный вариант)
# ;+ cl a~.cl PLUT plot_test3_save

# ;просмотр рeзультатов: D/b_test;
# ;                    : ./d_visg.li

# ;- сохранeниe разрeза в LAST.sol: s_funo.cl .. minfunc_read_save;
# ;- повторить всe оставшиeся функции в solver.li (main);

# ;- в задачe: 
# ;   "sl s~.cl SOLV heat_main 200  10 0.0 1.0  10 0.001"
# ;   heat_200_null - задаeт правильную лeвую пeрeмeнную границу, однако
# ;   потом она нe работаeт!

# ;- ошибка при запускe:
# ;  sl s~.cl SOLV kdv_main 020  21 -2.0 2.0  10 0.01

# ;=============================================================================

# ; - CA - всю схeму надо вытащить из MINFUNC и прикрутить к PLOT;
# ;   и туда жe потом BUKV-SCAN;

#-------------------------------------------------------------------------------

# (READ_AND_CALL_ARGUS  CUR_DIR)

set CUR_DIR "s"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------

# s~.tl FUNO u0_dynamic_main 2 

# s~.tl SOLV gazdin_main
# s~.tl SOLV laplas_main
# s~.tl SOLV onefun_main 1 
# s~.tl SOLV onefun_main 2

#-------------------------------------------------------------------------------
