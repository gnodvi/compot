# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#-------------------------------------------------------------------------------

source "a-comm.tl"

#-------------------------------------------------------------------------------
# установить ссылку для конкретного окружения

set_debian_OUT_add


#-------------------------------------------------------------------------------
proc RAND {} {

  my_source "g-rand.tl"
  my_source "a-comr.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию


  # a~.jm RAND permutation_test
  # a~.jm RAND random_test
  # a~.jm RAND TEST_lrand

}
#-------------------------------------------------------------------------------
proc MENU {} {

  my_source "a-menu.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc COMM {} {

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc JIMO {} {

  source "a-como.tl" ;# загрузка не скомпилированного варианта
                     ;# практически не влияет на скорость (на 1 microsec может)

  #mgena@mgena-ThinkPad common $ a~.jm JIMO TEST_time (без компиляции)
  #
  #Create:   13 microseconds per iteration
  #SetGet:   24 microseconds per iteration
  #Delete:   12 microseconds per iteration  т.е. вполне норм !!


  #Create:   11 microseconds per iteration   (с компиляцией)
  #SetGet:   23 microseconds per iteration
  #Delete:   12 microseconds per iteration

  # для сравнения 

  # b~.tl TEST_cloo_time
  # b~.tl TEST TIME_all

  # Create:   4.443 microseconds per iteration
  # SetGet:   3.025 microseconds per iteration
  # Delete:   4.556 microseconds per iteration

  #TEST_com0_time: 

  #Create:   62.56 microseconds per iteration
  #SGcget:   36.14 microseconds per iteration
  #SGvget:   11.23 microseconds per iteration
  #Delete:   143.63 microseconds per iteration

  #source "a-jimo.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc DICT {} {

  #package require "dicttool"
  #source "dicttool.tcl"

  source "a-dict.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

  #   (run_cdr_argus (first argus) argus "COMM ..")

}
#-------------------------------------------------------------------------------
proc PLUT {} {

  # b~.tl PLUT p1_test1 
  # b~.tl PLUT p1_test1_NEW 

  # b~.tl PLUT plot_test3_save 

  # b~.tl PLUT plot_test3 
  # b~.tl PLUT plot_test3_dyn

  #package require co-com 1.0

  #source "b-com0.tl"
  #source "b-mfor.tl"

  my_source "a-comp.tl"

  source "a-dict.tl"

  source "a-comp.tl"
  source "a-plot.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc TEST_color {} {

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  puts_test_colors "RED"
  puts_test_colors "GREEN"
  puts_test_colors "BLUE"
  puts_test_colors "CYAN"
  puts_test_colors "PURPLE"
  puts_test_colors "YELLOW"
  puts_test_colors "BLACK"
  puts_test_colors "WHITE"


  win_sgr $::SGR_DEFAULT

  #puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts ""
}
#-------------------------------------------------------------------------------
#proc test_5 {ind} {}
proc TEST_5 {} {

  set bar 42

  puts ""
  puts "bar= $bar"

  test_refs  foo bar

  puts "bar= $bar"
  puts ""
}
#-------------------------------------------------------------------------------
proc TEST_true_calc {} {


  #set out [goto_qnx_s6338 "ls" "t"]  ;# для тестирования

  #------------------------------------------------------------
  #  не понятно что-то заглючило, может с етью чего 
  #  а вообще, надо бы отказать от внешних хостов, как бы заходить
  #  на localhost ? 
  #------------------------------------------------------------
  #DebugOn
  #------------------------------------------------------------

  #set test_dir T
  #set test_dir "E/TMP"

  #set test_dir "S"
  set test_dir "E/S"

  set TRUE_FILE "$test_dir/config.sav" 
  set CALC_FILE "$test_dir/config.out" 
  set DIFF_FILE "$test_dir/config.dif"

  #set  out [goto_qnx_s6338 "ls" "s"]  ;# для тестирования
  #puts $out

  set out "pilot    MSOFT"
  #exit

  save_out_to_file  $out $CALC_FILE

  puts ""

  set is_to_overwrite 0

  check_true_and_calc_begin  "QNX ls TEST" 

  check_true_and_calc   $TRUE_FILE $CALC_FILE $DIFF_FILE  "" "" $is_to_overwrite

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc test_6 {} {

  puts " == $tcl_platform(threaded)"

}
#-------------------------------------------------------------------------------
proc ArrayInvert {arr1Name arr2Name {pattern *}} {

  upvar  $arr1Name arr1   $arr2Name arr2 ;# inverse

  foreach {index value} [array get arr1 $pattern] {

    set arr2($value) $index
  }

}
#-------------------------------------------------------------------------------
proc array_test {} {

  set arr1(1)  10 
  set arr1(2)  20
  set arr1(3)  30

  ArrayInvert arr1 arr2

  puts ""
  puts "arr1= [array get arr1]"
  puts "arr2= [array get arr2]"
  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc puts_test_colors {NAME} {

  win_set_color $NAME
  puts   "  COLOR_$NAME"

  win_set_color_light $NAME
  puts   "  COLOR_LIGHT_$NAME"

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_color_min {} {

  win_sgr $::SGR_DEFAULT

  puts ""
  puts "COLOR TEST"
  puts ""

  win_set_color RED
  puts         "SGR_BOLD - SGR_RED"
  win_set_color DEFAULT

  win_sgr $::SGR_CYAN
  puts "SGR_BOLD - SGR_RED"
  win_sgr $::SGR_DEFAULT

  win_puts "SGR_BOLD - SGR_RED" GREEN

  puts ""
  puts "COLOR TEST"
  puts ""

}
#-------------------------------------------------------------------------------
proc test_refs {a &b} {

  USE_REFS

  puts "a=$a,  b=$b"

  set b new_value
}
#-------------------------------------------------------------------------------
proc test_6_proc {&b} {

  USE_REFS

  puts "b=  $b"

  set b { 2 3 4}
}
#-------------------------------------------------------------------------------
proc test_6 {ind} {

  set bar {42 22 47}

  puts ""
  puts "bar= $bar"

  test_6_proc bar

  puts "bar= $bar"
  puts ""
}
#-------------------------------------------------------------------------------
proc TEST_c_api {} {

  puts ""
  puts "TEST_c_api .."
  puts ""


}
#-------------------------------------------------------------------------------

# If you cannot change your code to take the name of a channel to write to (the 
# most robust solution), you can use a trick to redirect stdout to a file: 
# reopening.

proc foo {} { puts "hello world" }

proc reopenStdout {file} {

    close stdout
    open $file w        ;# The standard channels are special

}

#-------------------------------------------------------------------------------
proc TEST_reopen1 {} {


  puts "Hello world 1"

  reopenStdout T/TEST_reopen

  puts "Hello world 2"

  reopenStdout /dev/tty   ;# Default destination on Unix; Win equiv is CON:

  # не получилось обратно ... !!
  puts "Hello world 3"

  # Be aware that if you do this, you lose track of where your initial stdout was 
  # directed to (unless you use TclX's dup to save a copy).

}
#-------------------------------------------------------------------------------
# эта команда портит работу для JIM! (puts ..)
#
if {0} {

##********************************************************
 ## Name: stdout
 ##
 ## Description:
 ##
 ## Switch stdout handling by puts command from the usual
 ## behaviour to a state where stdout is redefined to be
 ## another file.
 ##
 ## Native puts command error handling is unimpaired and
 ## a dangling filehandle is never generated.
 ##
 ##
 ## Calling convention:
 ##
 ##   stdout off          - redirects stdout to nowhere
 ##
 ##   stdout off /tmp/foo - redirects stdout to /tmp/foo
 ##
 ##   stdout on           - restores normal behaviour
 ##
 ##
 ## by: Phil Ehrens for the LIGO Lab at Caltech 09/02
 ## valuable contributions by: Bruce Hartweg
 ##********************************************************

proc stdout { switch { file "" } } {

  if { ! [ llength [ info command __puts ] ] && \
         [ string equal off $switch ] } {
    rename puts __puts
    if { [ string length $file ] } {
      eval [ subst -nocommands {proc puts { args } {
        set fid [ open $file a+ ]
        if { [ llength \$args ] > 1 && \
               [ lsearch \$args stdout ] == 0 } {
          set args [ lreplace \$args 0 0 \$fid ]
        } elseif {  [ llength \$args ] == 1 } {
          set args [ list \$fid \$args ]
        }
        if { [ catch {
          eval __puts \$args
        } err ] } {
          close \$fid
          return -code error \$err
        }
        close \$fid
      }} ]
    } else {
      eval [ subst -nocommands {proc puts { args } {
        if { [ llength \$args ] > 1 && \
               [ lsearch \$args stdout ] == 0 || \
               [ llength \$args ] == 1 } {
          # no-op
        } else {
          eval __puts \$args
        }
      }} ]   
    }
  } elseif { [ llength [ info command __puts ] ] && \
               [ string equal on $switch ] } {
    rename puts {}
    rename __puts puts
  }

}
##********************************************************
}
#-------------------------------------------------------------------------------
proc TEST_reopen2 {} {


  puts "Hello world 1"

  stdout off 

  puts "Hello world 2"

  #stdout off "T/TEST_reopen2" - не вышло 
  #stdout off "/tmp/TEST_reopen2" - тоже не вышло 

  puts "Hello world 3"

  stdout on  

  puts "Hello world 4"

  # Be aware that if you do this, you lose track of where your initial stdout was 
  # directed to (unless you use TclX's dup to save a copy).

}
#-------------------------------------------------------------------------------

#package require Memchan
package require tcltest
#namespace import ::tcltest::*

#   tcltest::test example-1.0 {normal return} {
#     format %s value
#   } value

# чего-тоне идет никак, аохоже надо отдельным скриптом только??
# 
# 

#Your Software under Test
#-------------------------------------------------------------------------------
proc sum {a b} {

  expr {$a + $b}

}
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/1502

# The tcltest package provides the user with utility tools for writing and running
# tests in the Tcl test suite. It can also be used to create a customized test 
# harness for an extension.

# Tcltest is bundled into the Tcl software core distribution.
#-------------------------------------------------------------------------------
proc TEST_tcltest {} {

  puts "Hello world !!!!"

#   tcltest::test sum_addTwoZerosExpectZero {
#     Test: [sum 0 0] == 0
#   } -body {
#     sum 0 0
#   } -result 0
  
#   tcltest::test sum_addTwoPositiveNumbers {} -body {
#     sum 4 9
#   } -result 13

  tcltest::test example-1.0 {normal return} {
    format %s value
  } value

}
#-------------------------------------------------------------------------------
#
#
#
#
#
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/4478
#-------------------------------------------------------------------------------
proc TEST_split {} {


 set mystring "line1\nline2\nline3\nline4\n"

 proc splitline {string} {
        set rc [llength [split $string "\n"]] 
        incr rc -1
        return $rc
 }

 proc regline {string} {
        set rc [regexp -line -all "\n" $string]
        return $rc
 }

 proc splitchar {string} {
 foreach x [split $string ""] {if {[catch {incr counters($x)}]} {set counters($x) 1}}
        set rc $counters(\n)
        return $rc
 } 

 puts ""

 puts [time {splitline $mystring} 10000]
 puts [time {regline   $mystring} 10000]
 puts [time {splitchar $mystring} 10000]

 proc xsplitline {string} {
        set rc [llength [xsplit $string "\n"]] 
        incr rc -1
        return $rc
 }

 puts ""
 puts "XSPLIT:"
 puts [xsplit $mystring "\n"]
 puts [time {xsplitline $mystring} 10000]


}
#-------------------------------------------------------------------------------
proc TEST_my_split {} {

  set mystring "line0 line1\nline2\nline3\nline4\n"

  set ret [my_split $mystring]

  puts ""
  puts "STR = "
  puts "$mystring"
  puts "RET = $ret"

}
#-------------------------------------------------------------------------------
proc TEST_fontname {} {

# Quick and dirty:
#  printf '\033]50;?\007'

# The returned string, which will probably be taken by the shell as input
# from the keyboard, will be the above control sequence with the '?'
# replaced with a font name or alias.

# If the returned font name is an alias, look it up with xprop:
#  xprop -font 7x13

# See /usr/share/doc/xterm*/ctlseqs.txt for details.

# This site may be of interest:
# <http://home.comcast.net/~urbanjost/CLONE/UNIX_SCRIPTS/scripts_xterm/index.html>

#  puts -nonewline "\033\[ $par m"

  puts ""
  puts "TEST_fontname:"
  puts ""

  #puts -nonewline "\033\]50;?\007"
  #puts -nonewline "\033\]50\;\?\007"

  puts "--------------------------------"
  puts -nonewline "\033\[ 50;?\007"
  puts "--------------------------------"

  #set ret [exec xtermcontrol --get-font]
  catch {[exec xtermcontrol --get-font]} ret

  puts "RET = $ret"
  puts ""
  puts "IS_KOI = [is_koi8]"
  puts ""
  

}
#-------------------------------------------------------------------------------
proc TEST_ko_uf {} {

  #set text_koi8 "Привет, грёбаный мир !!" ;# ё нельзя, ???
  set text_koi8 "Привет, гребаный мир !!"

  puts ""
  puts $text_koi8
  puts ""

  puts "ENCODING NAMES = [encoding names]"
  puts ""

  #puts [encoding convertfrom koi8-u $text_koi8]
  #puts [encoding convertfrom koi8-r $text_koi8]
  puts [koi_to_utf $text_koi8]
  puts ""

}
#-------------------------------------------------------------------------------
proc MISC_NEW {} {

  #source "b-com0.tl"
  source "a-dict.tl"

  #source "b-mfor.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc DISP {} {

  source "a-disp.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set CUR_DIR "a"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
# 
# a~.tl DICT_tests
# a~.tl TEST_5
# a~.tl TEST_color
# 
#-------------------------------------------------------------------------------
#
################################################################################

