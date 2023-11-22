# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#-------------------------------------------------------------------------------

#set auto_path [linsert $auto_path 0 "COMPOT/src/common"]
set auto_path [linsert $auto_path 0 "COMMON"]

#set auto_path [linsert $auto_path 0 "../common"] ;# for JIM
#set auto_path [linsert $auto_path 0 ".."] ;# for JIM

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
proc test_03 {} {

  #   GRAF *pg;
  #   int   s, t, nn;
  #   double  r, d;
  #   int     num_r, num_d;

  #puts ""
  #puts "test_03 ............. 01"
  
  #   pg = GrafCreate (4);
  set pg [mg_graf_create 4]
  
  #puts "test_03 ............. 02"

  #   //GrafInit (pg, YCONST, 0.0, 0.0, YCONST, NOT, 0.0);
  #   GrafInit (pg, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  mg_graf_init $pg
  
  #puts "test_03 ............. 03"

  mg_EDGE_set $pg 0 1   1
  mg_EDGE_set $pg 1 2   1
  mg_EDGE_set $pg 2 3   1
  mg_EDGE_set $pg 0 3   3.1
  
  set s 0
  set t 3
  
  puts ""
  mg_graf_print $pg
  
  puts "EDGE = [mg_EDGE_get $pg 0 1]"
  puts ""

  mg_GrafSmin $pg $s $t NULL
  puts ""

#   GrafMetrica (pg, &r, &d, &num_r, &num_d);

#   printf ("r = %.1f  num_r = %d \n", r, num_r);
#   printf ("d = %.1f  num_d = %d \n", d, num_d);

#   printf ("\n");

#   return;
}
# -------------------------------------------------------------------------------
proc test_11_NEW {} {  

  #comm_random_seed_null 2010 ;# пусть пока так !!
  
  set nn 6
  set gr [mg_graf_create $nn]
  
  mg_graf_init $gr "GR_RAND" 0.0 5.0 "GR_RAND" 0.0 5.0
  
  puts ""
  mg_graf_print $gr
  puts ""
  
  #foreach {r d num_r num_d}  [graf_metrica $gr] {}

  #puts -nonewline [format "r = %5f  num_r = %s \n"  $r $num_r]
  #puts -nonewline [format "d = %5f  num_d = %s \n"  $d $num_d]

  #puts ""
  
  return
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
  
  
  puts "....................... 01"
  mg_test_01
  

  #puts "....................... 02"
  #test_01_NEW 

  
  puts "....................... 03"
  test_03 


  #puts "....................... 04"
  #test_11_NEW 

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return 0
}
#-------------------------------------------------------------------------------

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#
################################################################################

