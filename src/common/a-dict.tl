# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::A_DICT_TL] {
  return
} else {
  set  ::A_DICT_TL ""
}

#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/10609
#-------------------------------------------------------------------------------

# As I like the new "dict" command very much, I want to use it in all my new 
# projects. But I don't want my programs to need tcl 8.5!
# Here is a pure tcl emulation of "dict" command.

# <Vince> -- this is very useful indeed. Thanks!

# The new dict update and dict with are not yet supported here. Any contributions?

# <PS> I created a dict package based on the current (Nov2005) code of Tcl 8.5, 
# which has all the features and most of the performance of the real thing. 
# See the dict page, search for 'tclDict'

# Here's an ugly 'dict update' implementation. Any improvements?

#-------------------------------------------------------------------------------
if {0} {
#-------------------------------------------------------------------------------


  #-----------------------------------------------------------------------------
  proc _dict_update {dvar args} {
    
    set name [string map {: {} ( {} ) {}} $dvar]
    
    upvar 1 $dvar dv
    upvar 1 _my_dict_array$name local
    
    array set local $dv
    foreach {k v} [lrange $args 0 end-1] {
      if {[info exists local($k)]} {
        if {![uplevel 1 [list info exists $v]]} {
        uplevel 1 [list upvar 0 _my_dict_array${name}($k) $v]
        } else {
          uplevel 1 [list set $v $local($k)]
        }
      }
    }
    set code [catch {uplevel 1 [lindex $args end]} res]
    
    foreach {k v} [lrange $args 0 end-1] {
      if {[uplevel 1 [list info exists $v]]} {
        set local($k) [uplevel 1 [list set $v]]
      } else {
        unset -nocomplain local($k)
      }
    }
    
    set dv [array get local]
    unset local
    
    return -code $code $res
  }
  #----------------------------------------------------------------------------
  #
  #----------------------------------------------------------------------------
  # Poor man's dict -- a pure tcl [dict] emulation
  # Very slow, but complete.
  #
  # Not all error checks are implemented!
  # e.g. [dict create odd arguments here] will work
  #
  # Implementation is based on lists, [array set/get]
  # and recursion
  #----------------------------------------------------------------------------

  if {![llength [info commands dict]]} {
    
    proc dict {cmd args} {
      uplevel 1 [linsert $args 0 _dict_$cmd]
    }
    
    proc _dict_get {dv args} {
      
      if {![llength $args]} {return $dv} else {
        array set dvx $dv
        set key [lindex $args 0]
        set dv $dvx($key)
        set args [lrange $args 1 end]
        return [eval [linsert $args 0 _dict_get $dv]]
      }
    }
    
    proc _dict_exists {dv key args} {
      array set dvx $dv
      set r [info exists dvx($key)]
      if {!$r} {return 0}
      if {[llength $args]} {
        return [eval [linsert $args 0 _dict_exists $dvx($key) ]]
      } else {return 1}
    }
    
    proc _dict_set {dvar key value args } {
      upvar 1 $dvar dv
      if {![info exists dv]} {set dv [list]}
      array set dvx $dv
      if {![llength $args]} {
        set dvx($key) $value
      } else {
        eval [linsert $args 0 _dict_set dvx($key) $value]
      }
      set dv [array get dvx]
    }
    
    proc _dict_unset {dvar key args} {
      upvar 1 $dvar mydvar
      if {![info exists mydvar]} {return}
      array set dv $mydvar
      if {![llength $args]} {
        if {[info exists dv($key)]} {
          unset dv($key)
        }
      } else {
        eval [linsert $args 0 _dict_unset dv($key) ]
      }
      set mydvar [array get dv]
      return {}
    }
    
    proc _dict_keys {dv {pat *}} {
      array set dvx $dv
      return [array names dvx $pat]
    }
    
    proc _dict_append {dvar key {args}} {
      upvar 1 $dvar dv
      if {![info exists dv]} {set dv [list]}
      array set dvx $dv
      eval [linsert $args 0 append dvx($key) ]
      set dv [array get dvx]
    }
    
    proc _dict_create {args} {
      return $args
    }
    
    proc _dict_filter {dv ftype args} {
      set r [list]
      foreach {globpattern} $args {break}
      foreach {varlist script} $args {break}
      
      switch $ftype {
        key {
          foreach {key value} $dv {
            if {[string match $globpattern $key]} {
              lappend r $key $value
            }
          }
        }
        value {
          foreach {key value} $dv {
            if {[string match $globpattern $value]} {
              lappend r $key $value
            }
          }
        }
        script {
          foreach {Pkey Pval} $varlist {break}
          upvar 1 $Pkey key $Pval value
          foreach {key value} $dv {
            if {[uplevel 1 $script]} {
              lappend r $key $value
            }
          }
        }
        default {
          error "Wrong filter type"
        }
      }
      return $r
    }
    
    proc _dict_for {kv dict body} {
      uplevel 1 [list foreach $kv $dict $body]
    }
    
    proc _dict_incr {dvar key {incr 1}} {
      upvar 1 $dvar dv
      if {![info exists dv]} {set dv [list]}
      array set dvx $dv
      if {![info exists dvx($key)]} {set dvx($key) 0}
      incr dvx($key) $incr
      set dv [array get dvx]
    }
    
    proc _dict_info {dv} {
      return "Dictionary is represented as plain list"
    }
    
    proc _dict_lappend {dvar key args} {
      upvar 1 $dvar dv
      if {![info exists dv]} {set dv [list]}
      array set dvx $dv
      eval [linsert $args 0 lappend dvx($key)]
      set dv [array get dvx]
    }
    
    proc _dict_merge {args} {
      foreach dv $args {
        array set dvx $dv
      }
      array get dvx
    }
    
    proc _dict_replace {dv args} {
      foreach {k v} $args {
        _dict_set dv $k $v
      }
      return $dv
    }
    proc _dict_remove {dv args} {
      foreach k $args {
        _dict_unset dv $k
      }
      return $dv
    }
    
    proc _dict_size {dv} {
      return [expr {[llength $dv]/2}]
    }
    
    proc _dict_values {dv {gp *}} {
      set r [list]
      foreach {k v} $dv {
        if {[string match $gp $v]} {
          lappend r $v
        }
      }
      return $r
    }
    
  }
  #----------------------------------------------------------------------------
  
  # Anton Kovalenko
  
  # 28jan04 jcw - The "ihash" package in critlib [1] might be a way to get good 
  # performance (from C, i.e. with a Tcl extension, not a core change). See also 
  # the Adding a hashed datatype page where this extension is described in more 
  # detail.
  
  # RHS 20Sept2004 I included this code in the .tgz file for RHS's Bytecode Package. 
  # I wasn't sure who to ask about doing this, but I assumed it was ok, since its 
  # on the Wiki and my code is released open source (standard Tclish license). 
  # I made a note in the dict.tcl file that the code in that file is not 
  # copyrighted to me, and put a link to this page. If my including this file is 
  # an issue, let me know and I'll remove it.
  
  #----------------------------------------------------------------------------
} ;#  END if {0_}



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   DICTTOOL   DICTTOOL   DICTTOOL   DICTTOOL 
#-------------------------------------------------------------------------------

###
# This package enhances the stock dict implementation with some
# creature comforts
###

#-------------------------------------------------------------------------------

if {[info commands ::ladd] eq {}} {

  proc ladd {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        set var {}
    }
    foreach item $args {
      if {$item in $var} continue
      lappend var $item
    }
    return $var
  }
}

if {[info command ::ldelete] eq {}} {

  proc ::ldelete {varname args} {
    upvar 1 $varname var
    if ![info exists var] {
        return
    }
    foreach item [lsort -unique $args] {
      while {[set i [lsearch $var $item]]>=0} {
        set var [lreplace $var $i $i]
      }
    }
    return $var
  }  
}

if {[::info commands ::tcl::dict::getnull] eq {}} {

  proc ::tcl::dict::getnull {dictionary args} {
    if {[exists $dictionary {*}$args]} {
      get $dictionary {*}$args
    }
  }

  if {$::__TCL__} {
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] getnull ::tcl::dict::getnull]
  }
}

#-------------------------------------------------------------------------------
if {[::info commands ::tcl::dict::print] eq {}} {

  ###
  # Test if element is a dict
  ###

  proc ::tcl::dict::_putb {buffervar indent field value} {

    ::upvar 1 $buffervar buffer
    ::append buffer \n [::string repeat " " $indent] [::list $field] " "

    if {[string index $field end] eq "/"} {

      ::incr indent 2
      ::append buffer "\{"

      foreach item $value {
        if [catch {
        if {![is_dict $item]} {
          ::append buffer \n [::string repeat " " $indent] [list $item]
        } else {
          ::append buffer \n "[::string repeat " " $indent]\{"
          ::incr indent 2
          foreach {sf sv} $item {
            _putb buffer $indent $sf $sv
          }
          ::incr indent -2
          ::append buffer \n "[::string repeat " " $indent]\}"          
        }
        } err] {
          puts [list FAILED $indent $field $item]
          puts $err
          puts "$::errorInfo"
        }
      }
      ::incr indent -2
      ::append buffer \n [::string repeat " " $indent] "\}"

    } elseif {[string index $field end] eq ":" || ![is_dict $value]} {
      ::append buffer [::list $value]

    } else {
      ::incr indent 2
      ::append buffer "\{"

      foreach {f v} $value {
        _putb buffer $indent $f $v
      }
      ::incr indent -2
      ::append buffer \n [::string repeat " " $indent] "\}"
    }
  }

  proc ::tcl::dict::print dict {

    ::set buffer {}

    ::foreach {field value} $dict {
      _putb buffer 0 $field $value
    }

    return $buffer
  }
  
  if {$::__TCL__} {
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] print ::tcl::dict::print]
  }

}
#-------------------------------------------------------------------------------

if {[::info commands ::tcl::dict::is_dict] eq {}} {

  ###
  # Test if element is a dict
  ###

  proc ::tcl::dict::is_dict { d } {
    # is it a dict, or can it be treated like one?
    if {[catch {dict size $d} err]} {
      #::set ::errorInfo {}
      return 0
    }
    return 1
  }

  if {$::__TCL__} {
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] is_dict ::tcl::dict::is_dict]
  }

}
#-------------------------------------------------------------------------------

if {[::info commands ::tcl::dict::rmerge] eq {}} {

  ###
  # title: A recursive form of dict merge
  # description:
  # A routine to recursively dig through dicts and merge
  # adapted from http://stevehavelka.com/tcl-dict-operation-nested-merge/
  ###

  proc ::tcl::dict::rmerge {a args} {
    ::set result $a
    # Merge b into a, and handle nested dicts appropriately
    ::foreach b $args {
      for { k v } $b {
        if {[string index $k end] eq ":"} {
          # Element names that end in ":" are assumed to be literals
          set result $k $v
        } elseif { [dict exists $result $k] } {
          # key exists in a and b?  let's see if both values are dicts
          # both are dicts, so merge the dicts
          if { [is_dict [get $result $k]] && [is_dict $v] } {
            set result $k [rmerge [get $result $k] $v]
          } else {  
            set result $k $v
          }
        } else {
          set result $k $v
        }
      }
    }
    return $result
  }

  if {$::__TCL__} {
  namespace ensemble configure dict -map [dict replace\
      [namespace ensemble configure dict -map] rmerge ::tcl::dict::rmerge]
  }

}

#package provide dicttool 1.0

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/23526

# pdict: Pretty print a dict
# Updated 2017-12-06 09:28:12 by HolgerJ╡
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
if {0} {

  #-------------------------------------------------
  
  # APN: Also see exhibit for a generalized package for pretty printing.
  
  # see also http://core.tcl.tk/tcllib/doc/trunk/embedded/www/tcllib/files/modules
  # /dicttool/dicttool.html
  # tjk's implementation  edit
  
  # I couldn't find a quick way to print a dict item when I was debugging some
  # code so I wrote this pretty printer. Enjoy...tjk
  
  #-------------------------------------------------------------------------------
  
  # -- pdict
  #
  # Pretty print a dict similar to parray.
  #
  # USAGE:
  #
  #   pdict d [i [p [s]]]
  #
  # WHERE:
  #  d - dict value or reference to be printed
  #  i - indent level
  #  p - prefix string for one level of indent
  #  s - separator string between key and value
  #
  # EXAMPLE:
  
  # % set d [dict create a {1 i 2 j 3 k} b {x y z} c {i m j {q w e r} k o}]
  # a {1 i 2 j 3 k} b {x y z} c {i m j {q w e r} k o}
  
  # % pdict $d
  
  # a ->
  #   1 -> 'i'
  #   2 -> 'j'
  #   3 -> 'k'
  # b -> 'x y z'
  # c ->
  #   i -> 'm'
  #   j ->
  #     q -> 'w'
  #     e -> 'r'
  #   k -> 'o'
  
  # % pdict d
  # dict d
  
  # a ->
  # ...
  
  #-------------------------------------------------------------------------------
  proc pdict { d {i 0} {p "  "} {s " -> "} } {
    
    set fRepExist [expr {0 < [llength\
                                [info commands tcl::unsupported::representation]]}]
    
    if { (![string is list $d] || [llength $d] == 1)
         && [uplevel 1 [list info exists $d]] } {
      set dictName $d
      unset d
      upvar 1 $dictName d
      puts "dict $dictName"
    }
    
    if { ! [string is list $d] || [llength $d] % 2 != 0 } {
      return -code error  "error: pdict - argument is not a dict"
    }
    
    set prefix [string repeat $p $i]
    set max 0
    foreach key [dict keys $d] {
      if { [string length $key] > $max } {
        set max [string length $key]
      }
    }
    
    dict for {key val} ${d} {
      
      puts -nonewline "${prefix}[format "%-${max}s" $key]$s"
      
      if {    $fRepExist && [string match "value is a dict*"\
                               [tcl::unsupported::representation $val]]
              || ! $fRepExist && [string is list $val]
              && [llength $val] % 2 == 0 } {
        puts ""
        pdict $val [expr {$i+1}] $p $s
      } else {
        puts "'${val}'"
      }
    }
    
    return
  }
  #-------------------------------------------------
  proc testing {} {
    
    
    puts ""
    set d [dict create a {1 i 2 j 3 k} b {x y z} c {i m j {q w e r} k o}]
    
    pdict $d
    puts ""
    
    pdict $d 2
    puts ""
    
  }
  #-------------------------------------------------
  
  testing
  
}
#-------------------------------------------------------------------------------
# RS's implementation  edit

# RS 2014-08-05 Here is my version, working similar to parray:
#-------------------------------------------------------------------------------
if {0} {
  
  #-------------------------------------------------
  proc pdict {dict {pattern *}} {
    
    set longest 0
    set keys [dict keys $dict $pattern] 
    
    foreach key $keys {
      set l [string length $key]
      if {$l > $longest} {set longest $l}
    }
    
    foreach key $keys {
      puts [format "%-${longest}s = %s" $key [dict get $dict $key]]
    }
  }
  #-------------------------------------------------
  proc testing {} {
    
    puts ""  
    pdict {a 1 b 2 verylongkey 3}
    puts ""
    
    #  a           = 1
    #  b           = 2
    #  verylongkey = 3
    
    pdict {a 1 b 2 verylongkey 3} ? ;# show only one-character keys  
    puts ""
    
    #  a = 1
    #  b = 2
    
    set ppp {a b   c {d e  f {g h}}}
    
    pdict $ppp  
    puts ""
    
  }  
  #-------------------------------------------------
  
  testing 
  
}
#-------------------------------------------------------------------------------
# DKF's implementation  edit

# DKF We might as well still use dict for:
#-------------------------------------------------------------------------------
if {0} {
  
  #-------------------------------------------------
  proc pdict {dict {pattern *}} {
    
    set longest 0
    
    dict for {key -} $dict {
      
      if {[string match $pattern $key]} {
        set longest [expr {max($longest, [string length $key])}]
      }
    }
    
    dict for {key value} [dict filter $dict key $pattern] {
      
      puts [format "%-${longest}s = %s" $key $value]
    }
    
  }
  #-------------------------------------------------
  proc testing {} {
    
    puts ""
    
    set ppp {a b   c {d e  f {g h}}  verylongkey 3}  
    pdict $ppp  
    
    puts ""
    
  }
  #-------------------------------------------------
  
  testing
  
}
#-------------------------------------------------------------------------------
# Or even:
#-------------------------------------------------------------------------------
if {0} {
  
  #-------------------------------------------------
  proc pdict {dict {pattern *}} {
    
    set longest [tcl::mathfunc::max 0 {*}[lmap key [dict keys $dict $pattern] {string length $key}]]
    
    dict for {key value} [dict filter $dict key $pattern] {
      
      puts [format "%-${longest}s = %s" $key $value]
    }
    
  }
  #-------------------------------------------------
  proc testing {} {
    
    puts ""
    
    set ppp {a b   c {d e  f {g h}}}  
    pdict $ppp  
    
    puts ""
  }
  #-------------------------------------------------
  
  testing
  
}
#-------------------------------------------------------------------------------

# It's probably not a good idea to sort the keys; the order semi-matters
# (usually not, but sometimes yes).

# PL, 2014-08-07: added 0 to the invocation of tcl::mathfunc::max to handle
# empty dictionaries.

# pdict's implementation  edit
# code

#-------------------------------------------------------------------------------
if {1} {
  
#-------------------------------------------------
proc pdict {args} {

  set cmd pdict
  set usage "usage: $cmd ?maxlevel? dictionaryValue ?globPattern?..."

  if {[string is integer [lindex $args 0]]} {
    # если первый параметр число, то это будет макс. уровень глубины печати
    # 
    set maxlvl [lindex $args 0]
    set args [lrange $args 1 end]
  } else {
    set maxlvl [llength $args] ;# заведомо максимальный уровень?
  }

  # разбираем остальные параметры команды: словарь и шаблон 
  # 
  foreach {dvar pat} $args break

  if {$dvar == ""} {error $usage}
  if {$pat  == ""} {set pat "*"}  ;# шаблон по умолчанию

  set args [lrange $args 2 end] ;# паттерны ? используем в рекурсивной вызывалке


  upvar __pdict__level  __pdict__level ;# "выносим" переменную наружу как статическую?
  upvar __pdict__names  __pdict__names ;# сюда будем складывать GLOBAL_NAMES ?

  incr __pdict__level +1 ;# счетчик итерационных вызовов ?

  set sp [string repeat " " [expr $__pdict__level-1]] ;# строка отступа?


  if {[catch {dict keys $dvar $pat} keys]} {

    error "$cmd error: 'dictionaryValue' is no 'dict'\n -> $usage\n  -> $keys"

  } elseif {[llength $keys]} {

    # идем циклом по списку ключей и делаем список длин их имен, затем
    # берем максимальный
    #
    set size [max {*}[lmap k $keys {string length $k}]]

    # и снова идем по ключам
    # 
    foreach key $keys {

      set dsubvar [dict get $dvar $key]

      puts -nonewline [format {%s%-*s} $sp $size $key] ;# печатаем имя

      if {$__pdict__level < $maxlvl} {

        set isVal   [catch {dict keys $dsubvar} keys]

        if {[llength $keys] == 0} { 

          # это словарь, но пустой?
          #
          puts " = \{\}"

        } elseif {$isVal} {

          # это обычное значение
          #
          puts " = $dsubvar"
          lappend __pdict__names [list $dsubvar $key]

        } else {

          # а это новый словарь 
          #
          puts " \{"
          pdict $maxlvl $dsubvar {*}$args ;# рекурсивно вызываем !!!
          puts "$sp\}"
        }

      } else {

        puts " = $dsubvar"
      }


    }
  } else {
  }

  if {$__pdict__level == 1} {
    unset -nocomplain __pdict__level

  } else {
    incr __pdict__level -1
  }

}
#-------------------------------------------------
# example
# the command

#pdict 4 $::LP::analyze * 7

# create the following output

# 166 {
#   7 {
#     IL {
#       type      = EMPTY
#       blocksize = 0
#     }
#   }
# }
# 176 {
#   7 {
#     IL {
#       type      = DS
#       blocksize = 5
#     }
#   }
# }
# 177 {
#   7 {
#     IL {
#       type      = BN
#       blocksize = 5
#     }
#   }
# }
#-------------------------------------------------
proc testing {} {

  puts ""

  set ppp {a b   c {d e  f {g h}}   verylongkey 3}
  
  pdict 2 $ppp  
  #pdict 9 $ppp  

  puts ""

}
#-------------------------------------------------

#testing

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#    TESTS   TESTS    TESTS    TESTS    TESTS 
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
proc DICT_test_01 {} {

  puts ""

  #-------------------------------------------------
  #set personal_data \
  [dict create  name [dict create FIRST "Frank" LAST "Zappa"] pid 106 ]

  set personal_data [dict create pid 106  name [dict create FIRST "Frank" LAST "Zappa"] ]

  set phone 223344

  dict set personal_data telnum $phone

  puts "dict  = [dict get $personal_data]"

  puts "name  = [dict get $personal_data  name]"

  puts "name  = [dict get $personal_data  name FIRST]" ; # => Frank

  #puts "tnum  = [dict get $personal_data  telnum]" 
  #-------------------------------------------------

  set d [dict create FIRST "Frank" LAST "Zappa"]

  puts "dict  = [dict get $d]" 
  puts "first = [dict get $d FIRST]" 
  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_dict_plus {} {

  set b {rem rem_proc  + plus_proc}
 
  puts ""

  if {! [dict exists $b "+"]} {

    puts "run_builtin_func: DON'T exist:  b = $b"    
  } else {
    puts "run_builtin_func: OK !!"
  }
 
  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_dict_err {} {

  set d  {-title {PLOTER for PLOT} -args_list {::G_DICT_0 0}}
  set key "-title"

  puts ""

  if {! [dict exists $d $key]} {

    puts "DON'T exist:  d = $d"    
  } else {
    puts "TEST_dict_err: OK !!"
  }
 
  puts ""

}
#-------------------------------------------------------------------------------
proc DICT_tests {} {


  DICT_test_01

  puts "---------------------------------"

  DICT_test_02

  puts "---------------------------------"

  TEST_dict_plus

  TEST_dict_err

  puts ""

}
#-------------------------------------------------------------------------------
proc DICT_test_02 {} {

  set ppp {a b   c {d e  f g}}

  set ppp [dict create {*}$ppp]

  #dict set ppp  a b   c {d e  f g}

  puts ""
  puts "ppp = [dict get $ppp]"   
  puts ""

  puts "ppp(a)   = [dict get $ppp a]"    ;# b
  puts "ppp(c)   = [dict get $ppp c ]"   ;# d e f g
  puts "ppp(c d) = [dict get $ppp c d]"  ;# e
  puts "ppp(c f) = [dict get $ppp c f]"  ;# g
  puts ""

  #dict getnull $ppp h    ;# (empty string)
  #dict getnull $ppp c h  ;# (empty string)

  dict set ppp  a h
  puts "ppp(a)   = [dict get $ppp a]"    ;# h

  dict set ppp  c i
  puts "ppp(x)   = [dict get $ppp c]"    ;# h

  puts ""
  puts "ppp = [dict get $ppp]"   
  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc dict_create {args} {

  #puts "1111"

  set d [MAKE_GLOBAL_NAME "DICT"] ;# [MAKE_GLOBAL_DICT] 

  set $d [dict create {*}$args]

  return $d
}
#-------------------------------------------------------------------------------
proc dict_get_D {d} {

  if [is_GLOBAL_NAME $d]  {

    set D [set $d]
  } else {
    set D $d
  }

  return $D
}
#-------------------------------------------------------------------------------
proc dict_expand {d} {

  set list_old [dict_get_D $d]

  set list_new {}


  foreach l $list_old {

    if [is_GLOBAL_NAME $l]  {

      set l_new [dict_expand $l]
    } else {
      set l_new $l
    }

    lappend list_new $l_new
  }

  return $list_new
}
#-------------------------------------------------------------------------------
#
# 1-й знак: раскрытие указателя на DICT
# 2-й знак: раскрытие указателей промежуточных индексов (кроме последнего)
# 3-й знак: раскрытие указателя последнего индекса
#
# dict get == dict_get_000
# dict_get == dict_get_100
#
#-------------------------------------------------------------------------------
proc dict_get {d_keys args} {
  
  # указатель на словарь может быть составной, весь путь
  # 
  set d    [lindex $d_keys 0]
  set keys [lrange $d_keys 1 end] ;# {}

  return [dict get [set $d] {*}$keys  {*}$args]
}
#-------------------------------------------------------------------------------
proc dict_get_111 {d_keys args} {

  # очень замедляет раскрытие! 
  # 

  set e [dict_expand $d_keys] ;# TODO: можно оптимизировать - не всё раскрывать?

  return [dict get $e {*}$args]
}
#-------------------------------------------------------------------------------
proc dict_set {d_keys args} {

  # указатель на словарь может быть составной, весь путь
  # 
  set d    [lindex $d_keys 0]
  set keys [lrange $d_keys 1 end] ;# {}

  if {[catch {set ret [dict set $d {*}$keys {*}$args]} err]} {
  
    #puts ""
    #puts "ERROR in dict_set !! err = $err"
    #puts ""

    # будем последовательно, начиная с начала (хотя можно с конца?)
    # проверять ключи на то, что они - ссылки!

    set num_keys [- [llength $args] 1]

    for {set i 0} {$i < $num_keys} {incr i} {

      set key      [lindex $args $i]
      set val [dict get [set $d] $key]

      #puts "i= $i key= $key  val= $val"

      if [is_GLOBAL_NAME $val] {

        set new_args [lrange $args  [+ $i 1] end]
        #puts "new_args = $new_args"

        #set ret [dict set $val {*}$new_args] ;# а если среди остальных ключей
                                              # тоже ссылки?
        set ret [dict_set $val {*}$new_args]

        break ;# уже остальные ключи обработаны итерационно
      }
    }

    #exit
  }

  return $ret
}
# ==============================================================================

# alias SET dict_set
# alias GET dict_get

# ------------------------------------------------------------------------------
proc print_dsubvar {dsubvar dsubvar_key  is_real sp ofile} {

  set num_keys_max 5

  upvar __pdict__level  __pdict__level ;# "выносим" переменную наружу как статическую?
  upvar __pdict__names  __pdict__names ;# сюда будем складывать GLOBAL_NAMES ?


  set isVal  [catch {dict keys $dsubvar} keys] ;# смотрим, что это
      
  if {[llength $keys] == 0} { 
    
    # это словарь, но пустой?
    #
    puts $ofile " = \{\}"
    
  } elseif {$isVal} {
    
    # это обычное значение
    #
    if {$is_real} {

      puts $ofile " $dsubvar"
    } else {
      puts $ofile " = $dsubvar"
    }
    
    if [is_GLOBAL_NAME $dsubvar] {
      lappend __pdict__names [list $dsubvar $dsubvar_key]
    }

  } else {
    
    # а это обычный словарь, не ссылка, т.е. значение словаря 
    #
    puts        $ofile " \{"    
    pdict_simp  $dsubvar $is_real $ofile $num_keys_max ;# рекурсивно вызываем !!!
    puts        $ofile "$sp\}"
  }
  
  return
}
# ------------------------------------------------------------------------------
if {$::__JIM__} {
# ------------------------------------------------------------------------------
#https://wiki.tcl-lang.org/page/max
# ------------------------------------------------------------------------------
proc max args {

  set res [lindex $args 0]

  foreach element [lrange $args 1 end] {
    if {$element > $res} {set res $element}
  }

  return $res
}
# ------------------------------------------------------------------------------
}
# ------------------------------------------------------------------------------
proc get_max_keylen {keys} {

  set lens_list [lmap k $keys   {string length $k}]

  #puts stderr ""
  #puts stderr "keys = $keys  lens_list = $lens_list"
  #puts stderr ""
  
  # вообще-то один аргумент может быть у функции "max" !!! &&
  #
  set size [max {*}$lens_list] ;# - убрал конфликт в j-1111

  #set size [::tcl::mathfunc::max {*}$lens_list]


  return $size
}
# ------------------------------------------------------------------------------
proc pdict_simp {dvar  {is_real "false"} {ofile "stdout"} {num_keys_max 5}} {
  
  #set num_keys_max 5


  #set cmd pdict
  
  #set usage "usage: $cmd ?maxlevel? dictionaryValue ?globPattern?..."
  #set usage "usage: $cmd dictionaryValue "

  #   if {[string is integer [lindex $args 0]]} {
  #     # если первый параметр число, то это будет макс. уровень глубины печати
  #     # 
  #     set maxlvl [lindex $args 0]
  #     set args [lrange $args 1 end]
  #   } else {
  #     set maxlvl [llength $args] ;# заведомо максимальный уровень?
  #   }

  # разбираем остальные параметры команды: словарь и шаблон 
  # 
  #foreach {dvar pat} $args break
  # 
  #foreach {dvar} $args break

  #if {$dvar == ""} {error $usage}
  #if {$pat  == ""} {set pat "*"}  ;# шаблон по умолчанию

  #set args [lrange $args 2 end] ;# паттерны ? используем в рекурсивной вызывалке


  upvar __pdict__level  __pdict__level ;# "выносим" переменную наружу как статическую?
  upvar __pdict__names  __pdict__names ;# сюда будем складывать GLOBAL_NAMES ?

  incr __pdict__level +1 ;# счетчик итерационных вызовов ?

  # сформируем строку отступа
  #
  set probel_size "  "
  set sp [string repeat $probel_size  $__pdict__level] 


  if {[catch {dict keys $dvar} keys]} {

    #error "$cmd error: 'dictionaryValue' is no 'dict'\n -> $usage\n  -> $keys"
    error "error: 'dictionaryValue' is no 'dict'\n -> $keys"
  } 

  set num_keys [llength $keys]

  #set num_keys_max 20
  #set num_keys_max 5

  #-------------------------------------------------------
  if $num_keys {

    # идем циклом по списку ключей и делаем список длин их имен, затем
    # берем максимальный
    #
    set size [get_max_keylen $keys]
    #set size [max {*}[lmap k $keys {string length $k}]]

    # и снова идем по ключам
    # 
    set n -1 ;# но будем их подсчитывать и не все печатать, если много?

    if {$num_keys > $num_keys_max} {
      #set n_max 5
      set n_max $num_keys_max
    } else {
      set n_max $num_keys
    }

    #-----------------------------------------------------
    foreach key $keys {

      incr n ;# порядковый номер ключа

      if {! $is_real} {

      if {$n >= $n_max } { 

        if {$n != [- $num_keys 1]} { # последний тоже напечатаем

          if {$n == $n_max}  { # на этой позиции напечатаем точки
            puts [format {%s%-*s} $sp $size "............"] 
          }
          continue
        }
      }
      }

      set dsubvar [dict get $dvar $key] ;# находим значение по ключу

      puts -nonewline $ofile [format {%s%-*s} $sp $size $key] ;# печатаем имя (ключ)

      print_dsubvar $dsubvar $key  $is_real $sp $ofile
      
    } ;# foreach key
    #-----------------------------------------------------

  } ;# if $num_keys
  #-------------------------------------------------------
  

  if {$__pdict__level == 1} {

    unset -nocomplain __pdict__level
    return $__pdict__names
    
  } else {
    incr __pdict__level -1
  }

}
#-------------------------------------------------------------------------------
proc dict_print_keys {d  {is_real "false"} {ofile "stdout"} {num_keys_max 5}} {

  #set num_keys_max 5

  set __pdict__names {} ;# сюда складываем 

  set ret [pdict_simp  $d $is_real $ofile $num_keys_max ] 

  return $ret
}
#-------------------------------------------------------------------------------
proc get_globalnames_from_list {list} {

  set ret {}

  foreach l $list {

    if {! [is_GLOBAL_NAME $l]} {continue}
    
    #puts "get_globalnames_from_list: l = $l v = [set $l]"

    lappend ret $l
  }

  return $ret 
}
#-------------------------------------------------------------------------------
proc list_print_keys {pd  {is_real "false"} {ofile "stdout"}} {

  set d [set $pd] 

  set len [llength $d]

  if {$is_real} {

    puts -nonewline $ofile "$d"

  } elseif [< $len 15] {

    puts "$d"

  } else {

    for {set i 0} {$i < 3} {incr i} {
      puts -nonewline "[lindex $d $i] "
    }

    puts -nonewline "...... "

    for {set i [- $len 3]} {$i < $len} {incr i} {
      puts -nonewline "[lindex $d $i] "
    }

    puts ""
  }

  set globalnames [get_globalnames_from_list $d]

  return $globalnames
}
#-------------------------------------------------------------------------------
proc print_ret_pointers {ret {is_real "false"} {ofile "stdout"}} {

  foreach nn $ret {

    set n   [lindex $nn 0] ;# это указатель на структуру
    set key [lindex $nn 1] ;# а это ее имя печатается в комментах

    if [is_GLOBAL_DICT $n] {

      puts $ofile ""
      puts $ofile [format "\# %8s .............................." $key]
      puts $ofile "\#"

      dict_print $n "" $is_real $ofile
    }


    if [is_GLOBAL_LIST $n] {list_print $n    $is_real $ofile}
  }

  return
}
#-------------------------------------------------------------------------------
proc dict_print {pd {mainname ""}  {is_real "false"} {ofile "stdout"} 
                 {num_keys_max 5}
                 args} {


  if [is_GLOBAL_DICT $pd]  { # это ссылка на словарь

    set name $pd
    set d [set $pd]

  } else { # или это сам словарь

    set name "DICT" ;# имя для печати этого словаря
    set d $pd
  }

  #------------------------------------------------------

  # если имя конкретно указано - возьмем его?
  # 
  if {$mainname != ""} {

    #set name $mainname
    puts $ofile ""
    puts $ofile "set $mainname $name"
  }


  puts $ofile ""

  if {$is_real} {
    puts $ofile "set $name \{"
    puts $ofile ""
  } else {
    puts "dict_print $name = "
  }

  set ret [dict_print_keys $d $is_real $ofile $num_keys_max] ;# печать основного словаря

  if {$is_real} {

    puts $ofile ""
    puts $ofile "\}"
  } 

  # печать вспомогательных ссылок
  # 

  print_ret_pointers $ret $is_real $ofile

  puts $ofile ""

  return
}
#-------------------------------------------------------------------------------
proc list_print {pd  {is_real "false"} {ofile "stdout"}} {

  #set ofile "stdout"

  puts $ofile ""

  if {$is_real} {

    puts -nonewline $ofile "set $pd \{ "
  } else {

    puts -nonewline "list_print $pd = "
  }

  set ret [list_print_keys $pd $is_real $ofile]

  if {$is_real} {

    puts -nonewline $ofile " \}"
    puts            $ofile ""
  }


  return
}
#-------------------------------------------------------------------------------
  #a~.tl DICT TEST_new
  #b~.tl PLUT p1_test1_NEW
#-------------------------------------------------------------------------------
proc TEST_new {} {

  set ppp {a b   c {d e  f g}}

  puts ""
  puts "ppp = [dict get $ppp]"   
  puts "ppp = [dict_get_111 $ppp]"   
  puts ""
  puts "------------------------------------------"
  puts ""

  
  set d [dict_create {*}$ppp]

  puts "ppp = [set $d]"   
  puts "ppp = [dict get [set $d]]"   
  puts "ppp = [dict_get $d]"   
  puts ""
  #puts "ppp print = [dict print [set $d]]"   
  #puts ""

  puts "ppp(a)   = [dict_get_111 $d  a]"    ;# b
  puts "ppp(c)   = [dict_get_111 $d  c ]"   ;# d e f g
  puts "ppp(c d) = [dict_get_111 $d  c d]"  ;# e
  puts "ppp(c f) = [dict_get_111 $d  c f]"  ;# g
  puts ""

  # переустановим a
  
  #dict set ppp  a h
  dict_set $d  a h
  puts "ppp(a)   = [dict_get_111 $d a]"    ;# h

  # переустановим c
  
  dict_set $d  c i
  puts "ppp(c)   = [dict_get_111 $d c]"    ;# h

  puts ""
  puts "ppp = [dict_get_111 $d]"   
  puts ""

  # переустановим еще c !!!!!!!!!!!!1
  
  dict_set $d  c [dict_create  j k  l m]

  puts "------------------------------------------"
  puts ""
  puts "ppp = [dict_get_111 $d]"   
  puts ""
  puts "ppp expand = [dict_expand $d]"   
  puts "ppp(c)   = [dict_get_111 $d  c]" 
  puts "ppp(c l) = [dict_get_111 $d  c l]"  ;# m !!!!!!!
  puts ""

  dict_set $d  c l "NEW"

  puts ""
  puts "ppp expand = [dict_expand $d]"   
  puts "ppp(c)   = [dict_get_111 $d  c]" 

  # еще глубже установим  структуру!!
  
  dict_set $d  c j [dict_create  o p]

  puts "ppp expand = [dict_expand $d]"   
  puts ""

  dict_set $d  c j o "NEWEST"

  puts "ppp(c j o) = [dict_get_111 $d  c j o]"

  puts ""

  puts "ppp(c j) = [dict_get_111 $d  c j]" 
  #
  # TODO:
  #
  # нужно здесь отладить все варианты доступа и раскрытия указателей по ключам
  # а также оптимизацию выполнения
  #
  #puts "ppp(c j) = [dict_get_110 $d  c j]" 

  #testing

  puts ""
  puts "------------------------------------------"
  puts ""
  puts "dict_expand = [dict_expand $d]"   
  puts ""
  

  #puts "dict print = [dict print [set $d]]"   
  #puts ""

  #dict_print $d 
  #puts ""

  puts "------------------------------------------"

  set ppp {a b   c {d e  f {g h}}   verylongkey 3}

  set d [dict_create {*}$ppp]

  puts ""
  dict_print $d 

  dict_set $d  c d [dict_create  AA BB]

  puts ""
  dict_print $d 

  puts ""
  puts ""
}
#-------------------------------------------------------------------------------
proc dict_print_real {pd} {


  dict_print $pd  "" "true" "stdout" 10000

}
#-------------------------------------------------------------------------------
proc TEST_big {} {


  set ppp {001 b \
           002 c \
           003 c \
           004 c \
           005 c \
           006 c \
           007 c \
           008 c \
           009 c \
           010 c \
           011 c \
           012 c \
           013 c \
           014 c \
           015 c \
           016 c \
           017 c \
           018 c \
           019 c \
             c {d e  f {\
                          001 h \
                          002 h \
                          003 h \
                          004 h \
                          005 h \
                          006 h \
                          007 h \
                          008 h \
                        }}   verylongkey 3}

  set d [dict_create {*}$ppp]

  puts ""
  dict_print $d "NANNNNNN" false
  puts ""

  dict_print_real $d 
  puts ""

#     if {$num_keys > 20} {
#       set n_max 5
#     } else {
#       set n_max $num_keys
#     }

}
#-------------------------------------------------------------------------------
# 

# a~.tl DICT DICT_tests
# a~.tl DICT TEST_new

# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_create {} {

  puts ""
  puts "TEST_create ....."
  puts ""

  set dic1 [dict_create]

  puts "dic1  = $dic1"
  puts "dic1  = [set $dic1]"

  set dic2 [dict_create a b]

  puts "dic2  = $dic2"
  puts "dic2  = [set $dic2]"


}
#-------------------------------------------------------------------------------

#   set dic3 [dict_create a b]

#   puts stderr "dic3  = $dic3"
#   puts stderr "dic3  = [set $dic3]"


#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#  ARR2D_    ARR2D_    
#
#-------------------------------------------------------------------------------
proc arr2d_make_NEW {ii jj} {  

  set size  [expr {$ii * $jj}]

  set a [dict_create]

  dict_set $a "ii" $ii 
  dict_set $a "jj" $jj 


  # двумерный список заменить на реально вложенный, по глобальному
  # имени !?
  # 
  #set array [list_create $size "@"]

  #dict_set $a "array" $array 


  return $a ;# указатель
}
# -------------------------------------------------------------------------------

set ::DICT_EXPAND 0

# -------------------------------------------------------------------------------
proc arr2d_ii_NEW {a} { 

#   if {[llength $a] > 1} {

#     puts ""
#     puts "arr2d_ii_NEW: a = $a"
#     puts ""

#     #set a {*}$a
#     #exit
#   }

  if {$::DICT_EXPAND} {

    return [dict_get_111 $a "ii"]  ;#   - ОЧЕНЬ замедляет в цикле (((( !!! 
  } else {
    #return [dict_get     $a "ii"]  
    return [dict_get     {*}$a "ii"]  
  }
}
# -------------------------------------------------------------------------------
proc arr2d_jj_NEW {a} { 

#   if {[llength $a] > 1} {

#     puts ""
#     puts "arr2d_jj_NEW: a = $a"
#     puts ""

#     #exit
#   }

  if {$::DICT_EXPAND} {

    return [dict_get_111 $a "jj"] 
  } else {
    return [dict_get     $a "jj"]  
  }
}
# -------------------------------------------------------------------------------
proc arr2d_set_NEW {a  i j val} { 

  # здесь а - может быть и "список-путь" !

  dict_set $a "a_${i}_${j}"  $val

} 
# -------------------------------------------------------------------------------
proc arr2d_get_NEW {a  i j} { 


  return [dict_get $a  "a_${i}_${j}"]
} 
# -------------------------------------------------------------------------------
proc arr2d_print_NEW {a} {  

  if {[llength $a] > 1} {

    # если это составной указатель, то да. а если это сам словарь? как отличить?

    puts ""
    puts "arr2d_print_NEW: a = $a"
    #puts ""

    #exit
  }

  set ii    [arr2d_ii_NEW $a]
  set jj    [arr2d_jj_NEW $a]

  puts "ii    = $ii"
  puts "jj    = $jj"
  puts "array = "

  for {set i 0} {$i < $ii} {incr i} {

  puts -nonewline "      "
  for {set j 0} {$j < $jj} {incr j} {

    set val [arr2d_get_NEW $a $i $j]

    puts -nonewline "$val "
  }
    puts ""
  }

  return
}
#-------------------------------------------------------------------------------
proc ARR2_test_NEW {} {  

  global argc argv arg0

  if {$argc > 2} { ;# например   b~.tl MISC ARR2_test_NEW @

    puts ""
    puts "::DICT_EXPAND     !!!!!!!!!"

    set ::DICT_EXPAND 1 

    # очень замедляется, поскольку в "dict_get_111"  испольщуется итерационное раскрытие
    # возможно, что оно просто ен оптимально, надо попробовать K ??

    # но как только убрал встроенный список - все OK вшсе_уч!!!
    # т.е. исключил копирование списка??
  }

  set a [arr2d_make_NEW 10 20]

  set ii    [arr2d_ii_NEW  $a]
  set jj    [arr2d_jj_NEW  $a]

  for {set i 0} {$i < $ii} {incr i} {
  for {set j 0} {$j < $jj} {incr j} {
    
    arr2d_set_NEW  $a  $i $j  "$i$j"     
  }}


  puts ""

  dict_print $a

  puts ""
  puts ""

  arr2d_print_NEW $a

  puts ""

  # ---------------------------------------------------
  # 
  # попробуем вложить словарь, но работать через склеенный указатель:

  set d [dict_create   key1 val1  key2 val2  key3 val3]

  dict_set $d  key2 $a
  dict_set $d  key3 [set $a] ;# записали туда массив (словаоь) целиком

  puts ""
  puts "--------------------------------------------------------"
  puts ""

  dict_print $d 

  puts ""
  puts "--------------------------------------------------------"
  puts ""

  if {! $::DICT_EXPAND} {

    # можно печатать по полному пути (относительно указателя)
    # 
    arr2d_print_NEW  "$d key3" 
    
    set ar [dict_get $d "key3"]

    puts ""
    puts "ar = $ar"
    puts ""

    #arr2d_print_NEW  $ar 
    
    # TODO: надо выбрать : либо "полные" ссылки, либо возможность работать
    # и со ссылкой и со словареи - да нет же!! без ссылки нельзя будет менять значения!
    #

    #
    #arr2d_print_NEW  $d key3   - не работает !! а надо?

    set val [arr2d_get_NEW "$d key3" 2 3]

    puts "val = $val"
    puts ""

    arr2d_set_NEW "$d key3" 2 3  55 ;# не заносит??

    set val [arr2d_get_NEW "$d key3" 2 3]

    puts "val = $val"
    puts ""
  }

  puts ""
  puts "--------------------------------------------------------"
  puts ""

  puts [set $a]

  puts ""
  puts "--------------------------------------------------------"
  puts ""


}
#-------------------------------------------------------------------------------

# b~.tl MISC ARR2_test_NEW 
# b~.tl MISC ARR2_test_NEW @

#-------------------------------------------------------------------------------
proc dictionary_read_from_saved_file {name work_dir filename} {

  source "$work_dir/$filename"
    
  set dict [set $name]

  return $dict
}
#-------------------------------------------------------------------------------
proc dict_read_from_saved_file {name work_dir filename} {


  set dict [dictionary_read_from_saved_file $name $work_dir $filename]

  set plot [dict_create {*}$dict] ;# лучше веренм указатель ?

  return $plot
}
# -------------------------------------------------------------------------------
# proc dict_read_from_file {work_dir fname} {

#   # а теперь попробуем прочитать:
#   # 

#   set f [open "$work_dir/$fname"  "r"]

#   gets $f line 

#   #puts "line = $line"

#   set p [dict_create {*}$line]

#   close $f

#   return $p
# }
#-------------------------------------------------------------------------------
proc dict_save_simple {dic name work_dir filename} {

  #set name "PLOT"

  set ofile [open "$work_dir/$filename"  "w"]

  if {0} {

    #puts $ofile "[set $plot]"

  } else {

    puts $ofile "set $name \{"
    puts $ofile ""
    puts $ofile "[set $dic]"
    puts $ofile ""
    puts $ofile "\}"

  }

  close $ofile
 
}
#------------------------------------------------------------------------------- 
proc dict_save {dic name fname} {

  set ofile [open $fname "w"]

  dict_print $dic $name true $ofile

  close $ofile

}
#------------------------------------------------------------------------------- 
proc DICT_save {} {

  set fname "a-dict.s0";

  set ppp {a b   c {d e  f {g h}}   verylongkey 3}

  MAKE_GLOBAL_NAME_set_timed

  set dic [dict_create {*}$ppp]

  #puts ""
  #dict_print $d 

  dict_set $dic  c d         [dict_create  AA BB]

  dict_set $dic  verylongkey [list_create_num_val  4] ;# получается с другой семантикой ?

  puts ""
  dict_print $dic  
  puts ""

  #dict_save_simple  $dic "NAME" "." $fname ;# как одиночный файл  

  #   set ofile [open $fname "w"]  
  #   dict_print $dic "NAME" true $ofile ;# $fname  
  #   close $ofile

  dict_save $dic "NAME" $fname

  puts ""
  puts "-------------------------------------------------------------"
  #puts ""
  puts [exec more $fname]
  #puts ""
  puts "-------------------------------------------------------------"
  #puts ""
  

  #set p [dict_read_from_file "." $fname] ;# читает простую строку
  # 

  # читаем цеилком файлом
  # 
  #set dic [dictionary_read_from_saved_file "NAME" "." $fname]

  #dict_print $dic "THE_NAME" ;# там не указатель, а значение

  #puts ""
  #puts "-------------------------------------------------------------"
  #puts ""

  # а можно и указатель сделать:
  #
  #set p [dict_read_from_saved_file "NAME" "." $fname]

  source "./$fname"

  
  puts ""
  puts "-------------------------------------------------------------"

  #dict_print $p "THE_NAME" true ;# а здесь через указатель и с реальным выводом переменных
  dict_print $NAME "THE_NAME" true ;# а здесь через указатель и с реальным выводом переменных

  #puts "-------------------------------------------------------------"
  #puts ""


  #puts "= [dict_get_111 $p  c d]" 
  #puts ""

  return
}
#-------------------------------------------------------------------------------
proc dict_parse {d key {defaultval NULL}} {

  #if {0} {
  #  puts stderr ""
  #  puts stderr "dict_parse :   d = $d  "
  #  puts stderr "           : key = $key. defaultval = $defaultval"
  #  puts stderr ""
  #}

  if [dict exists     $d $key] {

    return [dict get $d $key]

  } else {

    if {$defaultval == "NULL"} {
      
      # а зачем так себя ограничивать, ошибку выдавать?

      #puts stderr "d = $d"
      #puts stderr ""
      #ERROR "dict_parse, key = $key"
      
    } else {
      return $defaultval
    }
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# a~.tl DICT DICT_save

#-------------------------------------------------------------------------------
proc dict_class_create {classname {baseclasses {}} classvars constructorbody} {

  set ret [dict_create]

  SET $ret "classname"       $classname
  SET $ret "baseclasses"     $baseclasses
  SET $ret "classvars"       $classvars
  SET $ret "constructorbody" $constructorbody

  proc ${classname}_constructor {obj args} $constructorbody

  #--------------------------------------------------
  set newbody {

    set classname $classname
    set dclass \$::DCLASSES($classname)

    return [dclass_newobj \$dclass {*}\$args]
  }
  # 
  # подкоректировать тело процедуры: заменить по значению $classname
  # 
  set newbody [subst -nocommand $newbody]

  proc ${classname}_new {args} $newbody

  #--------------------------------------------------

  set cmdbody {

    set classname $classname

    tailcall "\${classname}_\$cmd" {*}\$args
  }

  set cmdbody [subst -nocommand $cmdbody]

  proc $classname {{cmd new} args} $cmdbody
  
  #--------------------------------------------------

  set ::DCLASSES($classname) $ret

  return $ret
}
#-------------------------------------------------------------------------------
proc set_variables {d classname args} {

  set dclass $::DCLASSES($classname)

  set classvars       [GET $dclass "classvars"]

  # устанавливаем переменные из этого класса
  # 
  dict for {var val} $classvars {
    
    if {$var == ";\#"} {continue} ;# пропускаем "комментарии"

    #puts stderr "var = $var, val = $val"
    SET $d $var $val
  }

  # и запускаем конструктор
  # 
  ${classname}_constructor $d {*}$args

}
#-------------------------------------------------------------------------------
proc dclass_newobj {dclass args} {

  #puts stderr "dclass_newobj: args = $args"

  set d [dict_create]

  set classname       [GET $dclass "classname" ]
  set baseclasses     [GET $dclass "baseclasses"]

  # сначала установим все переменные базовых классов
  # 
  foreach c $baseclasses {

    #puts stderr "c = $c"
    set_variables $d $c {*}$args
  }

  # и после уже переменные своего основного класса
  # 
  set_variables $d $classname {*}$args

  # и, наверное, имя класса записать в объект !!
  # 
  SET $d "classname" $classname

  return $d
}
# ------------------------------------------------------------------------------
proc RUN1 {procname obj args} {

  # вызываемая проц-ра в маленьких буквах, т.е. CALC -> calc
  # 
  #set procname  [string tolower [lindex [info level -1] 0]]
  #set procname  "${procname}_"

  #set classname [CLASSNAME $obj]
  set classname [GET $obj "classname"]

  # сделаем вызывемую процедуру-метод 
  #
  set procforclass "${procname}${classname}"

  # сдалано не правильно, должны бы идти по всем базовым классам, иерархически
  # и искать эту процедуру-метод?

  while {1} {
    
    if {! [exists_command $procforclass]} {
      
      #-------------------------------------------------
      #set classname    [BASECLASS $classname]

      set dclass $::DCLASSES($classname)
      
      set baseclasses  [GET $dclass "baseclasses"]
      
      set classname  [lindex $baseclasses 0] ;# пока предполагаем не более одного
      #-------------------------------------------------


      set procforclass "${procname}$classname" 

      #puts "new classname = $classname"
      #puts "procforclass = $procforclass"

    } else {
      break
    }
    
  }

  return [$procforclass $obj {*}$args]
}
#-------------------------------------------------------------------------------
proc TEST_class {} {

  puts ""
  puts "TEST_dict_class"
  puts ""

  #-----------------------------------------------

  set c1 [dict_class_create C1 {} {

    ;# _это_перечисление_переменных
    
    name1  "C1-name"    
  } {
    # а это конструктор класса 
    puts "C1 constructor ......."
    puts "name = [GET $obj name1]"
  }]

  puts "c1 = $c1"
  dict_print $c1 ;# "class c1"
  puts ""

  #-----------------------------------------------

  set c2 [class_create 1 C2 {C1} {

    name1  "C2-name"    
    name2  "C2-name"    
  } {

    puts "C2 constructor ......."
    puts "name = [GET $obj name2]"
    puts "args = $args"
  }]

  puts "c2 = $c2"
  dict_print $c2
  puts ""

  #-----------------------------------------------

  puts "-----------------------"
  set c1_obj1 [dclass_newobj $c1]

  dict_print $c1_obj1 
  puts "-----------------------"


  puts "-----------------------"
  set c1_obj2 [C1_new]

  dict_print $c1_obj2
  puts "-----------------------"

  #-----------------------------------------------

  puts "-----------------------"
  set c2_obj1 [dclass_newobj $c2   -param1 par1]

  dict_print $c2_obj1
  puts "-----------------------"


  puts "-----------------------"
  set c2_obj2 [C2 new   -param2 par2]

  dict_print $c2_obj2
  puts "-----------------------"

  #-----------------------------------------------


  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------



