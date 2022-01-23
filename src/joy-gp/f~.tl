# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------


set COMPOT "./COMPOT" 

set auto_path [linsert $auto_path 0 $COMPOT]


package require compot::common 

package require tcltest


#source "g-corE.tl"

################################################################################
#
# 
#-------------------------------------------------------------------------------
# proc TEST_listexpand {} {

#   set element {BEG 1 2 END}

#   puts "element = $element"

#   set els {*}$element 

#   # так нельзя делать, можно только использовать там где уже
#   # нужны "раскрытые" списки

# }
#-------------------------------------------------------------------------------

proc tcl2json value {

  # Guess the type of the value; deep *UNSUPPORTED* magic!
  #
  regexp {^value is a (.*?) with a refcount} \
    [::tcl::unsupported::representation $value] -> type
  
  switch $type {

    string {
      # Skip to the mapping code at the bottom
    }

    dict {
      set result "{"
      set pfx ""
      dict for {k v} $value {
        append result $pfx [tcl2json $k] ": " [tcl2json $v]
        set pfx ", "
      }
      return [append result "}"]
    }

    list {
      set result "\["
      set pfx ""
      foreach v $value {
        append result $pfx [tcl2json $v]
        set pfx ", "
      }
      return [append result "\]"]
    }

    int - double {
      return [expr {$value}]
    }

    booleanString {
      return [expr {$value ? "true" : "false"}]
    }

    default {

      # Some other type; do some guessing...
      if {$value eq "null"} {
        # Tcl has *no* null value at all; empty strings are semantically
        # different and absent variables aren't values. So cheat!
        return $value
      } elseif {[string is integer -strict $value]} {
        return [expr {$value}]
      } elseif {[string is double -strict $value]} {
        return [expr {$value}]
      } elseif {[string is boolean -strict $value]} {
        return [expr {$value ? "true" : "false"}]
      }

    }
  }
  
  # For simplicity, all "bad" characters are mapped to \u... substitutions
  set mapped [subst -novariables [regsub -all {[][\u0000-\u001f\\""]} \
                                    $value {[format "\\\\u%04x" [scan {& } %c]]}]]
  return "\"$mapped\""
}
#-------------------------------------------------------------------------------
proc isalist {string} {


  return [expr {0 == [catch {llength $string}]}]

}
#-------------------------------------------------------------------------------

# RS: The (outer) curlies are not part of the list - they are added, or parsed 
# away, when needed.

# Tcl lists are not fundamentally different from strings, rather, I'd say they 
# are a "view" on strings. Just as "42" can be viewed as string, or integer, 
# it can also be viewed as a one-element list. Except if you introduce your own 
# tagging convention, 
# there is no way of telling whether a list is in reality a 
# string - in the other direction, only strings that cannot be parsed as lists 
# (unbalanced braces, quotes..) cannot be viewed as lists.

#-------------------------------------------------------------------------------
proc TEST_tcllist {} {

  # нужно научиться различать и отличать встроенные списки от простых значений!

  set prg " {1 2}  {3} 4"

  # похоже нет никаких различий между {3} и 4, - это оба списки (list)
  # 

  puts ""
  puts "PRG= $prg"
  puts ""

  foreach i $prg {

    if {[string is list $i]} {
      set inf0 "string_is_LIST"
    } else {
      set inf0 "string_is_not_LIST"
    }
    
    set inf1 [isalist  $i]

    set inf2 [tcl2json $i]

    puts [format "i= %5s : llength= [llength $i] : $inf0 : $inf1 : $inf2 " |$i| ]
  }

}
#-------------------------------------------------------------------------------
proc TEST_match {} {


  puts ""
  puts "TEST: string match ................."
  puts ""

  puts [string match "*is*"    "this test is" ]
  puts [string match "*as*"    "this test is" ]
  puts [string match "capture" "capture" ]
  puts [string match "$*"      "\$value" ]

  puts ""
  puts "TEST lsearch ................."
  puts ""

  puts [lsearch   -glob -all  "this test is"  "*is*" ]
  puts [lsearch  -inline -all "this test is"  "*is*" ]
  puts [lsearch               "this test is"  "is" ]

  #puts ""
}
#-------------------------------------------------------------------------------
proc NEXT_sorted {} {

  set res {{1 one} {3 three} {2 two}}

  # сортируем по 1-му элементу списков

  set sorted [lsort -integer -index 0 $res]

  puts ""
  puts "res origin = $res"
  puts "res sorted = $sorted"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# ~/.pilot/s/compot/genpro$ j~.tl JOY2 TEST_main b__01.joy 
#
# OPEN_FNAME not find file TEST_main in all PATHS !!
#
#-------------------------------------------------------------------------------
proc TEST_biblio {args} {

  puts ""
  puts "TEST_biblio"
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


  #biblio_print 

  #return ;# откуда там уже библиотека?

  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  #f~.tl 1111 TEST_dict_NEW
  # 
  #v1_init_all       ;# начальная инициализация
  joy_init ;# самая начальная инициация

  #biblio_print 

  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  # сначала в общую библиотеку библ.функцию
  # 

  set bibl [list \
             "kvadrat" [list "src"  {dup *}] \
             ]

  biblio_push $bibl ;# запихнуть в глобальную библиотеку  ::BIBLIO
  #
  # TODO - наверное надо этот же словарь использовать и как ::LIPS ?

  biblio_print 


  return

  set src1 {3 kvadrat ^}

  set prog [list \
             "main"    [list "src"  $src1] \
             ]


  run_v1_prog   $prog 

  return
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc 0000 {} {

  source "f-0000.tl"  ;# общие части

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc 1111 {} {

  source "f-0000.tl"  ;# общие части
  source "f-1111.tl"  ;# надо будет подключить и ко всем примерам!!

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------

# f~.tl 1111 TEST_2005 
# f~.tl 1111 TEST_dict_NEW 
# f~.tl 1111 TEST_dict_VER -seed 2023 
# f~.tl 1111 TEST_list 
# f~.tl 1111 TEST_more 
# f~.tl 1111 TEST_simp 
# f~.tl 1111 TEST_solv 
# f~.tl 1111 TEST_sort 

#-------------------------------------------------------------------------------
proc 2222 {} {

  source "f-0000.tl"  ;# общие части
  source "f-1111.tl"  
  source "f-2222.tl"  

  global argc argv

  incr ::ind0

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
# tcltest::test intro-1 {} -body {
  
#   expr 3 * 5  
# } -result 15

#return
#----------------------------------------------------

# не пойму, что за предупреждение выдает:
#
#WARNING: unknown option TEST: should be one of -asidefromdir, -constraints, -debug, -errfile, -file, -limitconstraints, -load, -loadfile, -match, -notfile, -outfile, -preservecore, -relateddir, -singleproc, -skip, -testdir, -tmpdir, or -verbose
#
# Хотя, если так вызывать, то все нормально:
# 
# tclsh TEST.tcl

#-------------------------------------------------------------------------------
proc 3333 {} {

  source "f-0000.tl"  ;# общие части 
  source "f-3333.tl"

  #V3_INIT_01 ;# и!!

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc MORE {} {

  source "f-0000.tl"  ;# общие части

  source "f-1111.tl"  
  source "f-2222.tl"  
  source "f-3333.tl"

  #V3_INIT_03  ;# куча дополнительных функций

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------

set CUR_DIR "f"
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------
#
# f~.tl 0000 TEST_biblio

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
