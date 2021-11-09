# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

#set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM
#set auto_path [linsert $auto_path 0 $COMPOT/ext/random] ;# for JIM

#-------------------------------------------------------------------------------

#source "a-comm.tl"

package require compot::common 
package require compot::random 

#-------------------------------------------------------------------------------
# установить ссылку для конкретного окружения

#set_debian_OUT_add


# -------------------------------------------------------------------------------
proc test_01_NEW {} { 
  
  #YRAND_C
  
  #set gr [graf_create 4]

  #EDGE_set $gr 0 1  1
  #EDGE_set $gr 1 2  1
  #EDGE_set $gr 2 3  1
  #EDGE_set $gr 0 3  3.1 ;#3.1 2.9
  
  #NODE_set $gr 0   2.2
  
  #set s   0
  #set tar 3

  #puts -nonewline [format "\n"]
  #graf_print $gr

  #puts ""
  #dict_print $gr
  #puts ""

  # TODO
  #
  #graf_smin  $gr $s $tar $::NIL
  
  puts ""
}
#/*-----------------------------------------------------------------------------*/ 
proc test_01 {} {

  #   GRAF *pg;
  #   int   s, t, nn;
  #   double  r, d;
  #   int     num_r, num_d;
  
  
  #   pg = GrafCreate (4);
  set pg [mg_graf_create 4]
  
  #   //GrafInit (pg, YCONST, 0.0, 0.0, YCONST, NOT, 0.0);
  #   GrafInit (pg, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  
  #   EDGE (pg, 0, 1) = 1;
  #   EDGE (pg, 1, 2) = 1;
  #   EDGE (pg, 2, 3) = 1;
  #   EDGE (pg, 0, 3) = 3.1 /* 2.9 */;
  
  #   s = 0;
  #   t = 3;
  
  #printf ("\n");
  #   GrafPrint (pg);

  puts "pg = $pg"
  puts ""
  mg_graf_print $pg
  
#   GrafSmin (pg, s, t, NULL);
#   printf ("\n");

#   GrafMetrica (pg, &r, &d, &num_r, &num_d);

#   printf ("r = %.1f  num_r = %d \n", r, num_r);
#   printf ("d = %.1f  num_d = %d \n", d, num_d);

#   printf ("\n");

#   return;
}
#-------------------------------------------------------------------------------
proc TEST {} {

  puts ""
  puts "TEST ...................... "
  puts ""


  if {$::__JIM__} {
    
    ##load "P/T/libpgnup.so" 
    load "T/e_jim.so" Metagraph
    
  } else {
    load "T/e_tcl.so" Metagraph
  } 
  
  
  mg_test_01
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  test_01_NEW 

  test_01 

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return 0
}
#-------------------------------------------------------------------------------

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#
################################################################################

