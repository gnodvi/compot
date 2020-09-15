# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::A_COMM_TL] {

  #puts "::A_COMM_TL     exist 1"
  return
  #puts "::A_COMM_TL     exist 2"
} else {

  #puts "::A_COMM_TL not exist"
  set  ::A_COMM_TL ""
}

#-------------------------------------------------------------------------------

if [info exists tcl_version] {
  set ::__TCL__ 1
  set ::__JIM__ 0
} else {
  set ::__TCL__ 0
  set ::__JIM__ 1
}

set ::false 0
set ::true  1

#-------------------------------------------------------------------------------

# The common idiom for making an alias for a procedure is interp alias, but the 
# byte-compiled versions of commands (not user procedures, but built-in commands) 
# will not be used in that case. Below is an implementation of an idea suggested by 
# MS for making aliases without, missing out on that byte-compiled command goodness.

# PYK 2014-06-23: I just noticed that kruzalex had already provided a similar command 
# on the namespace page. I've taken some inspiration from his implementation and 
# modified the code below.

#-------------------------------------------------------------------------------
# a~.tl DICT ARR2_test_NEW

# invalid command name "alias"
#     while executing
# "alias SET dict_set"
 
if {$::__TCL__} {
#-------------------------------------------------------------------------------
proc alias {alias target} {

  set fulltarget [uplevel [list namespace which $target]]

  if {$fulltarget eq {}} {
    return -code error [list {no such command} $target]
  }

  set save [namespace eval [namespace qualifiers $fulltarget] {
    namespace export}]

  namespace eval [namespace qualifiers $fulltarget] {namespace export *}


  #if {} {
  #  set count [info cmdcount]
  #} else {
  set count 99999999
  #}

  #   while {[namespace exists [
  #                             set tmpns [namespace current]::$count]]} {}
  #
  set tmpns [namespace current]::$count ;# попроще


  set code [catch {set newcmd [namespace eval $tmpns [
           string map [list @{fulltarget} [list $fulltarget]] {
             namespace import @{fulltarget}
           }]]} cres copts]

  namespace eval [namespace qualifiers $fulltarget] [
                                                     list namespace export {*}$save]

  if {$code} {
    return -options $copts $cres
  }

  uplevel [list rename ${tmpns}::[namespace tail $target] $alias]

  namespace delete $tmpns 

  return [uplevel [list namespace which $alias]]
}
#-------------------------------------------------------------------------------

# Example:

# alias pset set
# pset answer 42
# puts $answer
# rename ::pset {}

#-------------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------

set ::TRUE  1
set ::FALSE 0

set ::NIL 0
set ::T   1

set ::NULL $::NIL

#-------------------------------------------------------------------------------

set ::G_NAME_num 0

set ::G_NAME_is_datatime 0

#------------------------------------------------------------------------------- 
proc MAKE_GLOBAL_NAME_set_timed {} {

  set ::G_NAME_is_datatime 1 ;#  !!!

}
#-------------------------------------------------------------------------------
#proc MAKE_UNICUM_NAME {{name "NAME"}} {}
proc MAKE_UNICUM_NAME {{gname "G_NAME"}} {


  # сформируем текущий ID-номер на основе индекса
  # 

  if {$::G_NAME_is_datatime} { # с учетом времени

    set systemTime [clock seconds]

    set datatime [clock format $systemTime -format "%y%m%d%H%M%S"] 

    set num ${datatime}_$::G_NAME_num ;

  } else { # без учета времени

    set num $::G_NAME_num ;
  }

  incr ::G_NAME_num ;# увеличили текущий индекс


  # т.е. уникальное имя:
  # 

  #set unicum_name "G_${name}_$num"
  set unicum_name "${gname}_$num"


  return $unicum_name
}
#-------------------------------------------------------------------------------
proc MAKE_GLOBAL_NAME {{name "NAME"}} {


#   # сформируем текущий ID-номер на основе индекса
#   # 

#   if {$::G_NAME_is_datatime} { # с учетом времени

#     set systemTime [clock seconds]

#     set datatime [clock format $systemTime -format "%y%m%d%H%M%S"] 

#     set num ${datatime}_$::G_NAME_num ;

#   } else { # без учета времени

#     set num $::G_NAME_num ;
#   }

#   incr ::G_NAME_num ;# увеличили текущий индекс


#   # т.е. уникальное имя:
#   # 
#   set unicum_name "G_${name}_$num"


  #set unicum_name [MAKE_UNICUM_NAME $name]

  set unicum_name [MAKE_UNICUM_NAME G_$name]


  # сделаем полное имя
  #
  #set g_name ::G_${name}_$num

  set g_name ::$unicum_name

  #incr ::G_NAME_num ;# увеличили текущий индекс


  return $g_name
}
#-------------------------------------------------------------------------------
# proc MAKE_GLOBAL_DICT {} {

#   return [MAKE_GLOBAL_NAME "DICT"]
# }
#-------------------------------------------------------------------------------
# proc MAKE_GLOBAL_LIST {} {

#   return [MAKE_GLOBAL_NAME "LIST"]
# }
#-------------------------------------------------------------------------------
proc is_GLOBAL_DICT {l} {

  set prefix [string range $l  0 7]

  set is [string equal $prefix "::G_DICT"]

  if $is {

    return $::true
  } else {
    return $::false
  }

}
#-------------------------------------------------------------------------------
proc is_GLOBAL_LIST {l} {

  set prefix [string range $l  0 7]

  set is [string equal $prefix "::G_LIST"]

  if $is {

    return $::true
  } else {
    return $::false
  }

}
#-------------------------------------------------------------------------------
proc is_GLOBAL_NAME {l} {

  set prefix [string range $l  0 7]

  #puts "prefix = $prefix"

  set is_NAME [string equal $prefix "::G_NAME"]
  set is_DICT [string equal $prefix "::G_DICT"]
  set is_LIST [string equal $prefix "::G_LIST"]

  if [expr {$is_NAME || $is_DICT || $is_LIST}] {

    return $::true
  } else {
    return $::false
  }

}
#-------------------------------------------------------------------------------
# see genalg/g-core/make_list
#-------------------------------------------------------------------------------
proc list_init {&l num {val "@"}} {

  USE_REFS

  for {set i 0} {$i < $num} {incr i} {

    lappend l $val
  }

}
#-------------------------------------------------------------------------------
proc list_make {num {val "@"}} {

  set ret ""

  list_init ret $num $val

  return $ret
}
# ------------------------------------------------------------------------------
# попробуем другую идеологию - создаем как структуры. т.е. с глоб. именами
#
# по аналогии с типом DICT сделаем тип LIST
# 
#-------------------------------------------------------------------------------
proc list_create {args} {

  set g_name [MAKE_GLOBAL_NAME "LIST"] ;# получили глобальное имя (ссылку)

  # puts stderr "g_name = $g_name"

  #set $g_name [list {*}$args]
  set $g_name $args

  return $g_name ;# возвращаем имя списка (глобальную ссылку)
}
#-------------------------------------------------------------------------------
proc list_create_num_val {{num 0} {val "@"}} {

  #set g_name [MAKE_GLOBAL_NAME "LIST"] ;# [MAKE_GLOBAL_LIST] 

  # получили глобальное имя (ссылку)
  # надо пока хотя бы пустой список присвоить!?

  #set $g_name {}

  set g_name [list_create]

  list_init $g_name $num $val

  return $g_name ;# возвращаем имя списка (глобальную ссылку)
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc my_load {fname dir} {


  source "./$fname"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# TODO: здесь надо бы получать гл. переменную с именем корневой папки

#set ::MAIN_SRC_DIR  "~/.pilot/simlab/simbat/src"

# здесь это разве надо?
#

#package require snit
   
#package require  Itcl
#namespace import itcl::*


#-------------------------------------------------------------------------------
# ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ   ТЕСТЫ ОБЩИЕ  
#-------------------------------------------------------------------------------

proc USE_REFS { {char &}} {

  foreach v [uplevel 1 {info locals}] {

    if [string match $char* $v] {
      uplevel 1 "upvar 1 \${$v} [string range $v 1 end]"
    }
  }

}

#-------------------------------------------------------------------------------
proc system_get_os {} {

  global tcl_platform

  set os [lindex $tcl_platform(os) 0]

  return $os
}
#-------------------------------------------------------------------------------
proc system_get_osver {} {

  set osver [eval exec uname -r]
  
  #puts ""
  #puts "OSVER = $osver"
  #puts ""
  
  #	if {$osver == "6.5.0"} {
  # 	set ::OSVER "6.5.0"
  #	} else {
  #  	set ::OSVER "6.6.0"
  #	}
  
  return $osver
}
#-------------------------------------------------------------------------------
# самая начальная инициация

#set ::OS "Linux" ;# пусть будет значение по умолчанию?
set ::OS    [system_get_os]

if {$::OS == "QNX"} {

  set ::OSVER [system_get_osver]
}

set ::is_koi8       1
set ::is_color      1
set ::is_color_menu 1


if {$::OS == "QNX"} {

  set  ::ED "ped"
} else {
  set  ::ED "xe" 
}

#set auto_path [linsert $auto_path 0 ./L] 
#set ::SWITCH_DIR "/home/pilot/.pilot/switch"

if {$::OS == "QNX"} {
  
  set ::is_color      0
  set ::is_color_menu 0
}

if {$::OS == "Windows" } {
  
  set ::is_color      0
  set ::is_color_menu 0

  # fconfigure stdout -encoding cp1251 ;# подвисает при выводе в WIndows
  # ???????????????
}

#-------------------------------------------------------------------------------
proc system_print_all {} {

  global tcl_platform
  global tcl_version

  puts "" 

  puts "PLATFORM = $tcl_platform(platform)" ;# unix or macintosh or windows
  puts "OS       = $tcl_platform(os)"
  puts "MACHINE  = $tcl_platform(machine)"
  puts "USER     = $tcl_platform(user)"

  puts "THREADED = [info exists tcl_platform(threaded)]"
  puts "HOSTNAME = [info hostname]"

  puts "TCL_VERSION       = $tcl_version"
  puts "TCL_VERSION_PATCH = [info patchlevel]"

  puts "" 
 
  return
}
#-------------------------------------------------------------------------------
proc TEST_system {} {

  #puts ""

  if {$::OS == "QNX"} {
    puts "OS    = $::OS"
    puts "OSVER = $::OSVER"
  }

  puts ""

  system_print_all

  # небольшой пример на использование:
  set os [system_get_os]

  puts "Example used:" 
  puts "" 
 
  if {$os == "Windows"} {   
    console show   
    puts "" 
    puts "This is Windows!!"
    
    #puts -nonewline "SELECT KEY and PRESS ENTER: "   
    #flush stdout  ;# все данные должны быть выведены
    
    #set answer [gets stdin]
    #puts " "
    
    #puts " ANSWER = $answer"
    #puts "" ;# да не работает это в Винде похоже..
    
    #-------------------------------------------------
  } else {
    puts "This is Not Windows !!"
  }


  puts ""  
}
# /******************************************************************************/
# //
# //   Формирование символьной экранной информации
# //   с дальнейшим выводом на терминал
# //
# /******************************************************************************/

# //-----------------------------------------------------
# // ANSI  color-change escape sequences.
# // Xterm Control Sequences (this is the file ctlseqs.ms)
# // man console_codes

#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор

#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз

#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево

#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

#-------------------------------------------------------------------------------

set  ::SGR_DEFAULT  0
set  ::SGR_BOLD     1

set  ::SGR_BLACK   30   
set  ::SGR_RED     31   
set  ::SGR_GREEN   32   
set  ::SGR_YELLOW  33   ;# BROWN
set  ::SGR_BLUE    34    
set  ::SGR_PURPLE  35   ;# MAGENTA
set  ::SGR_CYAN    36   
set  ::SGR_WHITE   37   

# еще вроде должны быть цвета:

# GRAY
# LIGHT_BLUE
# LIGHT_GREEN
# LIGHT_CYAN
# LIGHT_RED
# PURPLE, LIGHT_PURPLE (magenta??)
# YELLOW, LIGHT_YELLOW

#-------------------------------------------------------------------------------

# In addition to the default foreground and background colours, rxvt can display 
# up to 16 colours (8 ANSI colours plus high-intensity bold/blink
# versions of the same). Here is a list of the colours with their rgb.txt names.

# color0 	(black) 	= Black
# color1 	(red) 	        = Red3
# color2 	(green) 	= Green3
# color3 	(yellow) 	= Yellow3
# color4 	(blue) 	        = Blue3
# color5 	(magenta) 	= Magenta3
# color6 	(cyan) 	        = Cyan3
# color7 	(white) 	= AntiqueWhite
# color8 	(bright black) 	= Grey25
# color9 	(bright red) 	= Red
# color10 (bright green) 	= Green
# color11 (bright yellow) = Yellow
# color12 (bright blue) 	= Blue
# color13 (bright magenta)= Magenta
# color14 (bright cyan) 	= Cyan
# color15 (bright white) 	= White
# foreground 		= Black
# background 		= White

#-------------------------------------------------------------------------------

# http://www.saltycrane.com/blog/2009/11/how-make-urxvt-look-gnome-terminal/

# echo -e "\\e[0mCOLOR_NC (No color)"
# echo -e "\\e[1;37mCOLOR_WHITE\\t\\e[0;30mCOLOR_BLACK"
# echo -e "\\e[0;34mCOLOR_BLUE\\t\\e[1;34mCOLOR_LIGHT_BLUE"
# echo -e "\\e[0;32mCOLOR_GREEN\\t\\e[1;32mCOLOR_LIGHT_GREEN"
# echo -e "\\e[0;36mCOLOR_CYAN\\t\\e[1;36mCOLOR_LIGHT_CYAN"
# echo -e "\\e[0;31mCOLOR_RED\\t\\e[1;31mCOLOR_LIGHT_RED"
# echo -e "\\e[0;35mCOLOR_PURPLE\\t\\e[1;35mCOLOR_LIGHT_PURPLE"
# echo -e "\\e[0;33mCOLOR_YELLOW\\t\\e[1;33mCOLOR_LIGHT_YELLOW"
# echo -e "\\e[1;30mCOLOR_GRAY\\t\\e[0;37mCOLOR_LIGHT_GRAY"

#-------------------------------------------------------------------------------
proc  win_sgr_get {par} {

  return "\033\[ 0 ; $par m"
}
#-------------------------------------------------------------------------------
proc  win_sgr {par} {

  #puts -nonewline "\033\[ $par m"

  #puts -nonewline "\033\[ 0 ; $par m"

  puts -nonewline [win_sgr_get $par]

  # нужно наверное так, поскольку этот флажок (0 или 1) устанавливается
  # независимо и остается..
  # а может это просто тот самый BOLD ??

}
#-------------------------------------------------------------------------------
proc  win_sgr_light {par} {

  puts -nonewline "\033\[ 1 ; $par m"

}
#-------------------------------------------------------------------------------
proc win_set_color {COLOR} {

  if {$::is_color} {win_sgr [set ::SGR_$COLOR]}

}
#-------------------------------------------------------------------------------
proc win_set_color_upr {COLOR} {

  #if {$::is_color} {

  set upr [win_sgr_get [set ::SGR_$COLOR]]

  #}

  return $upr
}
#-------------------------------------------------------------------------------
proc win_set_color_light {COLOR} {

  if {$::is_color} {win_sgr_light [set ::SGR_$COLOR]}

}
#-------------------------------------------------------------------------------
proc win_set_DEFAULT {} {

  win_set_color DEFAULT

}
#-------------------------------------------------------------------------------
proc win_puts {text COLOR} {

  win_set_color $COLOR

  puts          $text 

  win_set_color DEFAULT

}
#-------------------------------------------------------------------------------
proc with_color {is_flag color script} {

  if {$is_flag} {win_sgr $color}
  uplevel 1 $script 
  if {$is_flag} {win_sgr $::SGR_DEFAULT}

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc save_out_to_file {out fname} {

  if {[catch {open $fname w} fout]} {
      # возникновение ошибки
      puts $fout 
      exit
  } else {
      # корректное выполнение команды open       
  }
    
  puts $fout ""

  foreach l $out {
      puts $fout $l
  }

  puts $fout ""

  close $fout
}
#-------------------------------------------------------------------------------
#       ;; тeпeрь надо сравнить два файла
#     catch {
#       [eval exec diff --ignore-all-space $CALC_FILE_SED $TRUE_FILE_SED >& $DIFF_FILE] 
#     } ret

#     # здeсь можно посмотрeть размeр файла сравнeния 
#     set size [file size $DIFF_FILE]

#     if {$size == 0} {
#       puts "PASSED "
#     } else {
#       # предыдущая команда сравнения обнаружила несовпадение
#     }
#-------------------------------------------------------------------------------
proc DebugOn {} {

  global my_debug

  set my_debug 1

}
#-------------------------------------------------------------------------------
proc DebugOff {} {

  global my_debug

  if {[info exists my_debug]} {
      unset my_debug 
  }

}
#-------------------------------------------------------------------------------
proc IsDebug {} {

  global my_debug

  return [info exists my_debug]

}
#-------------------------------------------------------------------------------
proc Debug {args} {

  global my_debug

  if {![info exists my_debug]} {
      return 
  }

  puts stderr [join $args ""]

}
#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
# TclWisw (9) Extending Tcl in Tcl
#-------------------------------------------------------------------------------
proc repeat {n script} {

    while {[incr n -1] >= 0} {
        uplevel 1 $script    ;# вместо eval !!!!
        # but it does not work with break and continue ...
    }
}
#-------------------------------------------------------------------------------
proc mysrand {seed} {

  expr {srand($seed)}

}
#-------------------------------------------------------------------------------
#
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc myrand {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка 
#-------------------------------------------------------------------------------
proc lrand {list} {
    
  lindex $list [expr {int(rand()*[llength $list])}]
    
}
#-------------------------------------------------------------------------------
proc TEST_lrand {} {
    
  set ll {1 2 3 4 5 6 7 8 9}
 
  #test_random_seed 0 ;# in file f-rand.tl

  #random_seed $i ;# для random_rand (crossover) - f-rand.tl (c_random_util.c)
  mysrand   0     ;# для lrand (начальная инициация)

  puts ""
  puts "lrand = [lrand $ll]"
  puts "lrand = [lrand $ll]"
  puts "lrand = [lrand $ll]"
  puts ""
   
}
#-------------------------------------------------------------------------------
# 

# надо бы сделать более гибко !
set BEGINSYM "\{"
set FINALSYM "\}"

#set BEGINSYM "\{@"
#set FINALSYM "@\}"

#TEST_replace

#-------------------------------------------------------------------------------
proc TEST_replace {} {

  global BEGINSYM FINALSYM

  #set str1 "SHOW ALL ERRORS :              {29-Feb-10:52:43-2012}"

  set str1 "SHOW ALL ERRORS :         ${BEGINSYM}29-Feb-10:52:43-2012${FINALSYM}"

  set str2 [replace_time_brackets_in_string $str1]

  puts ""
  puts $str1
  puts $str2
  puts ""

  set is_replasing 1

  #replace_time_brackets_in_file  $is_replasing  "T/a_TEST" stdout 
  #replace_time_brackets          $is_replasing  "T/a_TEST" "T/a_TEST_out" 

  replace_time_brackets_in_file  $is_replasing  "./a_TEST" stdout 
  replace_time_brackets          $is_replasing  "./a_TEST" "T/a_TEST_out" 

}
#-------------------------------------------------------------------------------
# 
# не работает для сложных вложений скобочек! код Tcl !!
# 
#-------------------------------------------------------------------------------
proc make_string {n char} {

  set str "" ;# обязательно надо, т.к. может num = 0 !!!

  for {set i 0} {$i < $n} {incr i} {

    append str $char
  }

  return $str
}
#-------------------------------------------------------------------------------
proc replace_time_brackets_in_string {str_inp} {

  global BEGINSYM FINALSYM


  set i1 [string first $BEGINSYM $str_inp]
  if {$i1 == -1} {return $str_inp}    ;# не нашлось левой  открывающей скобочки

  set i2 [string first $FINALSYM $str_inp $i1]
  if {$i2 == -1} {return $str_inp}    ;# не нашлось правой открывающей скобочки

  # установим границы, чтобы сами скобочки остались видимыми 
  set lensym [string length $BEGINSYM]
  #puts "LENSYM ============== $lensym"

  #incr i1      
  #incr i2 -1
  set i1 [expr {$i1 + $lensym}]      
  set i2 [expr {$i2 - $lensym}]

  set num [expr {$i2 - $i1 + 1}] ;# длина строки замены

  #puts stderr "num = $num"

  string replace $str_inp $i1 $i2 [make_string $num "-"]

}
#-------------------------------------------------------------------------------
proc replace_time_brackets_in_file {is_replasing  fname_r  id_out} {

  # set is_replasing 0 ; # не всегда нужно заменять !!

  if [catch {open $fname_r} fid] {
    puts "Cannot open $fname_r"

  } else {
    # чтение и обработка содержимого файла

    while {[gets $fid line] >= 0} {

      if {$is_replasing} {
        set new_line [replace_time_brackets_in_string $line]
      } else {
        set new_line $line
      }

      puts $id_out $new_line
    }
    
    close $fid
  }
  
}
#-------------------------------------------------------------------------------
proc replace_time_brackets {is_replasing finp fout} {

  #set is_replasing 0 ; # не всегда нужно заменять !!

  if [catch {open $fout w} id_out] {
    puts "Cannot open $fout"

  } else {
    # чтение и обработка содержимого файла
    #puts "OK open $finp"
 
    replace_time_brackets_in_file  $is_replasing $finp $id_out
    
    close $id_out
  }

}
#-------------------------------------------------------------------------------
proc check_true_and_calc { 
                          TRUE_FILE_fordiff  
                          CALC_FILE_fordiff  DIFF_FILE
                          TRUE_FILE_forcopy  
                          CALC_FILE_forcopy  is_to_overwrite
                        } {


  if {$TRUE_FILE_forcopy == ""  &&  $CALC_FILE_forcopy == ""} {
    set TRUE_FILE_forcopy  $TRUE_FILE_fordiff
    set CALC_FILE_forcopy  $CALC_FILE_fordiff
  }

  # > !System Up Time          "0 days 1 hrs 22 mins 31 secs"
  # --ignore-matching-lines=Time
  #           -I "\n"                     
   #          -I " "                     

  set cmd {diff --ignore-all-space --ignore-blank-lines \
             -I "Time" \
             $TRUE_FILE_fordiff \
             $CALC_FILE_fordiff > $DIFF_FILE}

  # --ignore-all-space    игнорирует пустое пространство при сравнении строк
  # --ignore-blank-lines  игнорирует изменения, состоящие в наличии или 
  #                       отсутсвии пустых строк

  # ---------------------------
#   set cmd {diff --ignore-all-space --ignore-blank-lines \
#              -I "\n"                      \
#              -I "Time" \
#              $TRUE_FILE_fordiff \
#              $CALC_FILE_fordiff}

#   puts ""
#   puts "cmd= $cmd"  

#   #eval exec $cmd
#   eval exec {diff --ignore-all-space --ignore-blank-lines -I "\n" sw1-mk11.cfg sw1.out }

#   puts ""
#   puts ""
#   exit
  # ---------------------------

  #puts "cmd= $cmd"  

  # TODO: используется unix-программа DIFF ?? а для Windows ??
  # 

  if [catch {eval exec $cmd} ret] { ;# сравнение прошло с "ошибкой", т.е. 
    # 
    # файлы различаются? вообще довольно странно, .. хотя ..
    # можно сравнить результирующий файл с нулем, но это ведь тоже не очевидно.

    win_puts "FAILED" RED

    # TODO: используется unix-программа MORE ?? а для Windows ??
    # 
    # TODO: используется unix-программа DIFF ?? а для Windows ?? 

    puts "" 
    puts "------------------------------------------------------DIFF-----------" 
    puts [exec more $DIFF_FILE]
    #puts $ret
    #exit
    puts "---------------------------------------------------------------------" 
    puts "" 

    if {$is_to_overwrite} {

      puts -nonewline "FAILED: do you wish to overwrite (y or \[n\]) ? "
      
      flush stdout               ;# все данные должны быть выведены
      set answer [gets stdin]
      puts " "
      
      
      switch $answer {
        y {
          exec cp $CALC_FILE_forcopy $TRUE_FILE_forcopy 
          
          # принимаем новый выход как истинный!
          puts "YES   : overwrite NEW -> OLD configure !!"
        }
        default {
          puts "NOT   : continue with OLD configure!"
        }
      }  

    } ;# is_to_overwrite END
    
  } else {

    win_puts "PASSED" GREEN
    
  }
  
}
#-------------------------------------------------------------------------------

set raz1 ":" ;# отделяет начальную букву

set raz2 "," ;# разделители вместо пробелов в команде

#-------------------------------------------------------------------------------
proc tst {LL OUT DIR_CMD CMD} { 

  #set raz1 ":" ;# отделяет начальную букву
  #set raz2 "," ;# разделители вместо пробелов в команде
  global  raz1 raz2

  puts "$LL: $CMD ..."

  # формируемый имя тестового файла в несколько этапов:

  # заменяем символы директорий (хотя наверное это теперь не актуальнов TCL?):
  set CMD_TRUE [string map {^ /} $CMD]

  # заменяем пробелы разделителями 
  set map_list [list " " $raz2]
  set T_FILE [string map $map_list $CMD]

  # окончательно подставляем префикс:
  set N_FILE "$LL$raz1$T_FILE"


  # и наконец выполняем команду

  # TODO: используется unix /dev/null ?? а для Windows ??
  # 

  eval exec $DIR_CMD/$CMD_TRUE > $OUT/$N_FILE  2> /dev/null


  # 1: i_main -t2 ...
  # child process exited abnormally
  #     while executing
  # "exec ./i_main -t2 > E/OUT/1:i_main,-t2 2> /dev/null"
  
  # Tcl's exec treats any non-zero exit status as an exceptional situation. 
  # You need to catch the exec call, check the return value from catch and if 
  # nonzero examine the $errorCode variable. A thorough example here: 
  # http://wiki.tcl.tk/exec, click "Show Discussion" and scroll down to 
  # KBK's example.

}
#-------------------------------------------------------------------------------
proc check_true_and_calc_begin {name} { 


  puts -nonewline "$name ................ "  ;
  flush stdout

}
#-------------------------------------------------------------------------------
proc run_cmd_and_check {is_replasing dir_cmd rr i 
     CALC_FILE TRUE_FILE  CALC_FILE_SED TRUE_FILE_SED  DIFF_FILE   
     } {

  global  raz1 raz2

  # и формируем рeальную команду, заменяя ВСЕ разделители пробелами:
  
  set cmd [string map {^ /} $rr]  ;# сначала (!) подменяем спец-символы директорий

  set map_list [list $raz2 " "]
  set cmd [string map $map_list  $rr] ;# а потом спец-символы пробелов
  
  # ---------------------------------------------------------
  #check_true_and_calc_begin "$i"
  # ---------------------------------------------------------

    # было в lib.sh:
    # (cd ${DIR_CMD} ; eval $CMD > $CALC_FILE  2> /dev/null)

  set pwd_dir [pwd]
  if {[catch {cd $dir_cmd} err]} {
    puts stderr $err
    exit
  }
  # так нельзя совсем уходить в директорию.. надо только на выполнение

  # ---------------------------------------------------------
  # запускаем команду на выполнение !!!
  set err 0
  
  # TODO: используется unix /dev/null ?? а для Windows ??
  # 

  if [catch {eval exec $cmd  2> /dev/null >  $CALC_FILE} ret] {
    set err 1 ;# сделаем пометочку об неясной ошибке
  } 

  cd $pwd_dir ;# возврашаемся!
  # ---------------------------------------------------------
  
  # тeпeрь надо сравнить два файла
  # лучше бы разделить ее на до и после выполнения команды !!

  set ::is_color 0 ;# а это здесь для чего ????
  
  # теперь надо сделать временные файлы с ЗАМЕНОЙ СКОБОК {}
  #set is_replasing 0 ; # не всегда нужно заменять !!
  # надо бы это явно указывать и еще сами парные символы замены "\{" "\}"

  replace_time_brackets  $is_replasing  $CALC_FILE $CALC_FILE_SED
  replace_time_brackets  $is_replasing  $TRUE_FILE $TRUE_FILE_SED
  
  # 
  # здесь мне надо по-хитрому: сравнивать время-модифицированные файлы
  # а вот заменять исходные !!
  check_true_and_calc  $TRUE_FILE_SED  $CALC_FILE_SED  $DIFF_FILE \
    $TRUE_FILE  $CALC_FILE  1
  
  if ($err) {
    # при этом результат работы может и совпадать ..

    puts "ERROR !!!!!!!!!!!!!! :"
    puts "CMD = $cmd"
    puts "RET = $ret"
    puts ""
    exit  ;# здесь надо бы тормозить работу
  }

}
#-------------------------------------------------------------------------------
proc run_one_test {is_replasing dir_cmd str_cmd fname_cmd  fname_full} {

  set dir_tmp "[pwd]/T"

  set CALC_FILE      "$dir_tmp/a_CALC"
  set DIFF_FILE      "$dir_tmp/a_DIFF"

  set CALC_FILE_SED  "$dir_tmp/a_CALC_SED"
  set TRUE_FILE_SED  "$dir_tmp/a_TRUE_SED"


  #puts -nonewline "$fname ................ "  ;
  #flush stdout

  check_true_and_calc_begin "$fname_cmd"

  run_cmd_and_check  $is_replasing   $dir_cmd $str_cmd $fname_cmd \
    $CALC_FILE $fname_full  $CALC_FILE_SED $TRUE_FILE_SED  $DIFF_FILE   

}
#-------------------------------------------------------------------------------
proc run_one_file_test {dir_cmd dir_tst true_file bukva} {


  
}
#-------------------------------------------------------------------------------
proc run_tests  {dir_cmd dir_tst  n testname} {

  #set is_replasing  @@@@

  #set testname_size [string length $testname]
  #set n_beg $n
  #set n_end [expr {$n + $testname_size -1}]

  # рабочая папка для промежуточного хранения файлов сравнения
  # set dir_tmp "./T"
  # лучше бы тут давать полный путь к файлу !?

  set dir_tst_files [lsort [glob -directory $dir_tst *]]

  # идем по всем файлам в тестовой директории
  foreach   TRUE_FILE $dir_tst_files {

    #set fname [string trim $i $dir_tst]  ;# отбросим слева название OUT-директории
    #
    # только надо именно слева !!! а то справа отбрасывается буква "Е", например
    # j~.tl 1111 TEST_simp_BE
    set fname_cmd [string trimleft $TRUE_FILE $dir_tst]  ;# отбросим слева название OUT-директории

    set aa [string range  $fname_cmd  0 0] ;# первая буква

    if {$aa != $testname} {continue}  ;# пропускаемы тесты не с нашего поля


    #---------------------------------------------------

    # будем лучше по ней здесь динамиченски определять, нужна ли замена
    #
    if {$aa == "N"} {
      set is_replasing  0
    } else {
      set is_replasing  1
    }

    #set bb [string range  $fname_cmd  $n_beg $n_end] ;# полe сравнeния

    #set bb $aa ;# вроде всегда один символ??

    # полагая, что уровeнь - всeгда одна цифра
    set str_cmd [string range  $fname_cmd  2 end] ;# непосредственно заданиe
  
    # было в lib.sh:
    # (cd ${DIR_CMD} ; eval $CMD > $CALC_FILE  2> /dev/null)

    #set TRUE_FILE ${dir_tst}/$fname_cmd

    run_one_test  $is_replasing $dir_cmd $str_cmd $fname_cmd   $TRUE_FILE
  }

}
#-------------------------------------------------------------------------------
proc run_bukva_tests  {bukva dir_cmd dir_tst} {

  # 1:a~.tl,TEST_5
  
  set n         2
  #set testname  $bukva

  run_tests   $dir_cmd $dir_tst  $n $bukva ;# $is_replasing

}
#-------------------------------------------------------------------------------
proc run_numer_tests {numer dir_cmd dir_tst   args} { 

#   if {$args == N}  {

#     set is_replasing 0
#   } else {
#     set is_replasing 1
#   }

  # 1:a~.tl,TEST_5
  
  set n         0
  set testname  $numer

  run_tests   $dir_cmd $dir_tst   $n $testname ;# $is_replasing

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc m_dat {} {

  # TODO: используется unix-программа DATE ?? а для Windows ??
  # 

  set md [exec date +%m%d]

  foreach ind {p o m m l k j i h g f e d c b a} {

    set mdi $md$ind ;# это имя создаваемой директории

    if {[file exists $mdi]} {break} 
    # уже есть такой каталог, тогда возмем предыдуший?
    # подразумевается, что был уже хоть один свободный ..

    set mdi_old $mdi ;# запомним имя, еще не занятое с конца
  }

  #exec mkdir $mdi_old
  file mkdir $mdi_old

  return $mdi_old ;# возвращаем созданное имя (чего не было ранее)
}
#-------------------------------------------------------------------------------
proc TEST_mdat {} {

  puts ""
  puts "TEST_mdat ........."
  puts ""

  puts "m_dat = [m_dat]"
  puts ""


}
#-------------------------------------------------------------------------------
# [eval] contains a [concat] automatically.  And you left out the "exec",
# so you meant:

#         eval [list exec tar zcf $tarFileName] $fileList

# which will indeed work if $fileList is a canonical list.

# Safer, though far less clear, is:

#         eval [linsert $fileList 0 exec tar zcf $tarFileName]

# Better than all, of course, is:

#         package require Tcl 8.5
#         exec tar zcf $tarFileName {expand}$fileList
#-------------------------------------------------------------------------------
proc make_ARX {files_list} {

  set pwd [pwd] ;# запомнили где были

  cd  ..

  #exec tar cvf ARX.tar stands 
  #set files_list "core00 cp6923 stands tester"

  #eval [list exec tar --exclude=A -cvf ARX.tar] [list *] 
  #eval [list exec tar --exclude=A -cvf ARX.tar] $files_list

  set cmd [list exec tar --exclude=A -cvf ARX.tar]
  #eval [list exec tar -cvf ARX.tar] $files_list
  eval $cmd $files_list
 
  exec gzip -6 ARX.tar 

  #exec tar -cvf {--exclude=A} ARX.tar stands 
  #exec tar {--ignore-failed-read --exclude=A -cvf ARX.tar *}
  #gzip -6 $(ARX_NAME).tar \

  cd $pwd ;# вернулись назад
}
#-------------------------------------------------------------------------------
# proc save_true_config_files_to_A {} {

#   puts ""
#   set pwd [pwd] ;# запомнили где были

#   set cfg_path  $pwd/$::config_dir

#   cd  $::config_dir/A
#   set new_dir [m_dat] ;# создали архив-папку

#   cd  $new_dir ;# зашли в созданную пустую папку

#   file mkdir unix
#   file mkdir wind
#-------------------------------------------------------------------------------
proc make_save {} {

  global argc argv

  puts ""
  set pwd [pwd] ;# запомнили где были

# save : 
# 	(cd $(ARX_HOME); mdat) 
# 	(cd .. ; \
# 	 tar --ignore-failed-read \
# 	     --exclude=A \
# 	     -cvf $(ARX_NAME).tar $(ARX_LIST) ; \
# 	 gzip -6 $(ARX_NAME).tar \
# 	)

  # пока так, а надо бы сделать звездочку
  #set files_list "core00 cp6923 tester"
  #set files_list "core00 cp6923 stands"
  set files_list "cp6923"

  #set files_list "*"   - почему-то не идет !!

  #set files_list  [lindex $argv 1]
  #puts "files_list = $files_list"

  #set files_list "core00 cp6923 stands tester"
  make_ARX  $files_list 

  #set arx_dir  $pwd/../A/UNI ;# почему я туда не попадаю?
  set arx_dir  Archiv
  cd  $arx_dir
  set new_dir [m_dat] ;# создали архив-папку

  cd  $new_dir ;# зашли в созданную пустую папку
  #puts "cur_dir = [pwd]"
  set tar_dir "$pwd/.."
  #puts "tar_dir = $tar_dir"
  file copy    $tar_dir/ARX.tar.gz  ARX.tar.gz
  file delete  $tar_dir/ARX.tar.gz 

  cd $pwd ;# вернулись назад

  puts "ARX.tar.gz -> Archiv/$new_dir ..... OK"
  puts ""
  puts -nonewline "PRESS ANY KEY .. "   
  flush stdout ;# все данные должны быть выведены
  set answer [gets stdin]

  puts ""

}
#-------------------------------------------------------------------------------
# proc COMM {} {

#   #source "a-prog.tcl"
#   #source "a_test.tcl"
  
#   global argv ; set PR [lindex $argv 1] ; eval {$PR 2}

# }
# 
# set helpsymb "!"
# set ind 0

#if {$argc == $ind || [string equal [lindex $argv $ind]  $helpsymb]} {}
#
#-------------------------------------------------------------------------------
proc READ_AND_CALL_ARGUS {BUKVA} {

  global argc argv

  # мда, как же быть?  .. вся строка задается жестко !!
  set dir_cmd   "." 
  set dir_tst   "E/OUT"
  #set is_replasing 1

  # если без параметров, то стартует система тестирования
  if {$argc == 0} {
    
    puts "\n"
    run_bukva_tests  $BUKVA  $dir_cmd $dir_tst ;# $is_replasing
    
    puts "\n"   
    exit
  }
  
  # а если с параметрами

  eval [lindex $argv 0]
  
  # здесь вот оно зачем ??
  #puts "" 

}
#-------------------------------------------------------------------------------
# запускаем тест из командной строки селдующего уровня
#-------------------------------------------------------------------------------
proc RUN_PROC_IND {ind} {

  global argv 
  
  set    PR [lindex $argv $ind] 
  eval {$PR [expr   {1 + $ind}]}

}
#-------------------------------------------------------------------------------
# http://www2.tcl.tk/3888
#-------------------------------------------------------------------------------
# Well the log use of macro you had above looks like an assert function, which 
# I believe has been addressed by cleverness in the core that optimizes null 
# functions out of existence.

# I've used macros in a cpp-ish fashion, to eliminate big repeated blocks of code. 
# Here's the macro function I wrote:
#
# procedure to create macros that operate in caller's frame, with arguments
# no default args yet
#-------------------------------------------------------------------------------
proc macro {name formal_args body} {

  proc $name $formal_args [subst -nocommands {

    # locally save all formal variables, and set them in parent conext
    foreach _v [list $formal_args] {
      if {[uplevel 1 info exists \$_v]} {
        set __shadow__\$_v [uplevel 1 set \$_v]
      }
      uplevel 1 set \$_v [set \$_v]
    }

    uplevel 1 { $body }

    # undo formal variables
    foreach _v [list $formal_args] {
      if {[info exists __shadow__\$_v]} {
        uplevel 1 set \$_v [set __shadow__\$_v]
      } else {
        uplevel 1 unset \$_v
      }
    }

  }]
}
#-------------------------------------------------------------------------------
# So you can do something like
#-------------------------------------------------------------------------------
proc TEST_macro {} {

  set text "hello"

  macro foo {a} {
    puts "$text $a"
  }

  puts ""

  foo world
  foo everybody

  #-----------------------------------------
  #   =>
  #   hello world
  #   hello everybody
  
  # Of course this makes more sense when the body of the macro is 70 lines long 
  # and it's used in 8 different files, so it replaces a whole bunch of identical 
  # (except for a few bits) code with something a lot more readable.
}
#-------------------------------------------------------------------------------
proc TEST_dialog {} {

  puts ""
  puts -nonewline "SELECT KEY and PRESS ENTER: "   
  #flush stdout  ;# все данные должны быть выведены
    
  #set answer [gets stdin]        ; # просто виснит
  #set answer [congets stdin]     ; # 
  #set answer [tkcon_gets stdin]
  puts " "
    
  #puts "ANSWER = $answer"
  puts ""
    
}
#-------------------------------------------------------------------------------
proc ERROR {name} {

  puts "ERROR:  $name"

  exit
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#

# пока поставим здесь, а потом, нверное, перенесем поближе
# ---> ab-comm.tl
#
# да, но в QNX это не будет работать ..
#package require Expect

# 1:d~.tl,TEST_dlink ................ FAILED
# т.е. только здесь я испольщую пока "pakage require Expect"

#-------------------------------------------------------------------------------
# Extended split command
# Being forced to use perl instead of Tcl, I've noticed that Perl split command 
# is much more powerful than Tcl one - it allows to split strings on arbitrary 
# regexps rather than on particular char, and, optionally, allows to put element 
# separators in the resulting list as separate elements.

# Fortunately, regexp command in Tcl is powerful enough to implement Perl-like 
# split just in few lines of Tcl code.

# This command behaves much like Tcl built-in split, but it takes regexp as 
# second argument, and defaults it to arbitrary amount of whitespace. If regexp 
# contains parentesis, text, which matches them would be inserted in resulting 
# list between splitted items as separate elements. 
#
#-------------------------------------------------------------------------------
# http://www.wagner.pp.ru/~vitus/software/tcl/xsplit.html
#-------------------------------------------------------------------------------
proc xsplit [list str [list regexp "\[\t \r\n\]+"]] {

  set list  {}

  while {[regexp -indices -- $regexp $str match submatch]} {
    lappend list [string range $str 0 [expr {[lindex $match 0] -1}]]

    if {[lindex $submatch 0]>=0} {
      lappend list [string range $str [lindex $submatch 0]\
                      [lindex $submatch 1]] 
    }	
    set str [string range $str [expr {[lindex $match 1] + 1}] end] 
  }

  lappend list $str

  return $list
}
#-------------------------------------------------------------------------------
proc my_split {string} {

  set list {}

 foreach x [split $string ""] {
   
   if {$x == "\n"} {
     #puts "X = -----------------"

     #set str "spawn j_3620.tl  " ;# - если явно указать, то все зашибись 
     #puts "str = !$str!"         ;# - и печатает правильно
                                  #   ну и соответственно добавляет хорошо..
     lappend list $str
     #puts "LIST = "
     #puts "$list"
     #exit
     set str ""
   } else {
     if {$x == "\r"} {
       # откуда то взялись символы возврата каретки? - В НИХ ВСЕ ДЕЛО И БЫЛО!
       #puts "RRRRRRRRRRRRRRRRRRr"
       continue
     }
     #puts "X = !$x!" ;# оппа! а тут уже наблюдаем в последних символах фигню..
     append str $x
   }
 }

  #puts ""
  #puts "LIST = "
  #puts "$list"

 return $list
}
#-------------------------------------------------------------------------------
proc is_proc_exist {cmd} {

  set list_procs [info procs  $cmd]

  if {[llength $list_procs] != 0} {
    #puts "111"
    return 1
  } else {
    #puts "000"
    return 0
  }

}
#-------------------------------------------------------------------------------
proc xtermcontrol_get_font {} {

  # - сначала надо установить программку xtermcontrol;
  # - она действует только на xterm;
  # - и то чтобы она работала надо разрешить манипуляции с xterm:
  #   ctrl+rightclick and look for menu item names like 'Allow Window Ops'.
  #   или прописать в .Xdefaults:
  # *VT100.allowWindowOps: true
  # *VT100.allowTitleOps: true
  # *VT100.allowFontOps: true
  # 
  catch {[exec xtermcontrol --get-font]} ret

  return $ret
}
#-------------------------------------------------------------------------------
proc is_koi8_font {} {

  set ret [xtermcontrol_get_font]


  if {[string first "koi8" $ret] == -1} {
    return 0
  } else {
    return 1
  }

}
#-------------------------------------------------------------------------------
proc set_en {} {

  set ::is_koi8 0

}
#-------------------------------------------------------------------------------
proc set_ru {} {

  set ::is_koi8 1

#   if {![is_koi8_font]} {
#     puts ""
#     puts "set_ru: WARNING: not KOI8 font !!"
#     puts ""
#   }

}
#-------------------------------------------------------------------------------
proc is_ru {} {

  #return [is_koi8_font]

  return $::is_koi8;
}
#-------------------------------------------------------------------------------
proc latinica_from_koi8 {text_ru} {


  set nata_table {
     а  a 
     б  b 
     в  v 
     г  g 
     д  d 
     е  e 
     ж  w 
     з  z 
     и  i 
     к  k 
     л  l 
     м  m 
     н  n 
     о  o 
     п  p 
     р  r 
     с  s 
     т  t 
     у  u 
     ф  f 
     х  x 
     ц  c 
     ч  h 
     ь  ` 
     ы  = 
     ю  y 
     я  q 

     А  A 
     Б  B 
     В  V 
     Г  G 
     Д  D 
     Е  E 
     Ж  W 
     З  Z 
     И  I 
     К  K 
     Л  L 
     М  M 
     Н  N 
     О  O 
     П  P 
     Р  R 
     С  S 
     Т  T 
     У  U 
     Ф  F 
     Х  X 
     Ц  C 
     Ч  H 
     Ь  ` 
     Ы  = 
     Ю  Y 
     Я  Q 

  } 

#      ш   
#      щ  d 
#      ъ  d 
#      э   

  set lat [string map $nata_table $text_ru]

  return $lat
}
#-------------------------------------------------------------------------------

# % encoding names

# cp860 cp861 cp862 cp863 cp864 tis-620 cp865 cp866 gb2312-raw gb12345 cp950 cp949 
# cp869 dingbats ksc5601 macCentEuro cp874 macUkraine jis0201 gb2312 euc-cn euc-jp 
# iso8859-10 macThai iso2022-jp jis0208 macIceland iso2022 iso8859-13 iso8859-14 
# jis0212 cp737 iso8859-15 iso8859-16 big5 euc-kr macRomania iso2022-kr gb1988 
# macTurkish macGreek ascii cp437 macRoman iso8859-1 iso8859-2 iso8859-3 iso8859-4 
# ebcdic koi8-r macCroatian iso8859-5 cp1250 macCyrillic iso8859-6 cp1251 cp1252 
# iso8859-7 macDingbats koi8-u iso8859-8 cp1253 iso8859-9 cp1254 cp1255 cp850 cp932 
# cp1256 cp852 cp1257 identity macJapan cp1258 utf-8 shiftjis cp855 cp936 cp775 
# symbol unicode cp857

#-------------------------------------------------------------------------------
proc koi_to_utf {text_koi8} {

  return [encoding convertfrom koi8-r $text_koi8]

}
#-------------------------------------------------------------------------------
proc koi_to_win {text_koi8} {

  set unicode [koi_to_utf $text_koi8]

  #return [encoding convertto cp1251 $unicode]
  return [encoding convertto cp866 $unicode]

}
#-------------------------------------------------------------------------------
proc koi_to_866 {text_koi8} {

  set unicode [koi_to_utf $text_koi8]

  return [encoding convertto cp866 $unicode]

}
#-------------------------------------------------------------------------------
proc koi_to_console {name_koi} {

  if {$::OS == "QNX"} {

    if {$::OSVER == "6.6.0"} { # ???

      set name [koi_to_866  $name_koi]
    } else {
      set name [latinica_from_koi8 $name_koi]
    }

  } else {

    if {$::__JIM__} {
      set name [latinica_from_koi8 $name_koi]
    } else {
      set name [koi_to_utf    $name_koi]
    }
  }
  
  return $name 
} 	
#-------------------------------------------------------------------------------
#proc puts_engrus_parse_isnewline {args @text_eng_rus @is_newline} {}
proc puts_engrus_parse_isnewline {args &is_newline} {

  USE_REFS ;# @

  #puts "args = $args, len = [llength $args]"

  if {[llength $args] > 2} {
    error "INVALID ARGUMENTS = $args"
  }

  if {[llength $args] == 2} {

    if {![string match -n* [lindex $args 0]]} {
      error "INVALID ARGUMENTS = $args"
    } 
    set text_eng_rus [lindex $args 1]
    set is_newline 0

  } else {
    set text_eng_rus [lindex $args 0]
    set is_newline 1
  }

  return $text_eng_rus
}
#-------------------------------------------------------------------------------
proc puts_rus {args} {

  #puts_engrus_parse_isnewline  $args  text  is_newline
  set text [puts_engrus_parse_isnewline  $args is_newline]

  set text_new  [koi_to_console $text]

  puts -nonewline  $text_new

  if {$is_newline} {puts ""} 

}
#-------------------------------------------------------------------------------
proc puts_engrus {args} {

  # args -  либо один параметр, либо опция
  # -nonewline и строка

  #puts_engrus_parse_isnewline  $args  text_eng_rus  is_newline

  if {$::__TCL__} {
    set text_eng_rus [puts_engrus_parse_isnewline  $args is_newline]
  } else {

    set text_eng_rus [puts_engrus_parse_isnewline  {*}$args is_newline]
  }

  #puts "text_eng_rus = $text_eng_rus"

  # на самом деле у нас список: 
  set text_en [lindex  $text_eng_rus 0] 
  set text_ru [lindex  $text_eng_rus 1] 

  #puts "text_en = $text_en"
  #puts "text_ru = $text_ru"

  #---------------------------------------------------

  if {[is_ru]} {
    # здесь бы надо сделать еще возможную перекодировку KOI8->UTF8
    #set text [koi_to_utf $text_ru]

    if {$::OS == "QNX"} {

      set text [koi_to_866 $text_ru]
    } else {
      # выводим русский текст (из редакторного кои8 в выходной утф8)
      set text [koi_to_utf $text_ru]
    }

  } else {
    set text $text_en 
  }


  puts -nonewline $text

  if {$is_newline} {puts ""} 
}
#-------------------------------------------------------------------------------
proc TEST_en_ru {} {

  set text {
    {
      This is step 1
      Welcome !!! Wow !!!
    }    
    {
      Это шаг 1
      Добро пожаловать !!! Ого !!!
    }
  }



  if {$::__JIM__} {
    set_en
  } else {
    set_ru
  }

  puts ""  
  puts_engrus  {"Hello World !!" "Привет этот грёбаный мир !!"}
  #puts_engrus   "Hello World !!" "Привет этот грёбаный мир !!"
  #puts ""

  puts_engrus  $text

  #return

  puts ""
  puts -nonewline "Hello "

  set_en
  puts_engrus -nonewline {"World " "МИР "} 

#   set_ru
#   puts_engrus -nonewline {"World " "МИР "} 

  puts "! -------------------->"
  puts ""


}
#-------------------------------------------------------------------------------
proc simple_proc {arg1 arg2} {

  puts "ARG1 = $arg1"
  puts "ARG2 = $arg2"

}
#-------------------------------------------------------------------------------
proc TEST_info_body {} {

  set proc_args [info args  simple_proc]
  set proc_body [info body  simple_proc]

  puts ""
  puts "INFOARGS = proc_args" 
  puts "INFOBODY = $proc_body" 
  puts ""

  # сщздадим здесь новую процедуру из присланного тела
  #proc new_proc {arg1 arg2} $proc_body
  proc new_proc $proc_args $proc_body

  # и выполним ее:
  new_proc "Hello" "World"

}
#-------------------------------------------------------------------------------

#set_en
#set_ru

#-------------------------------------------------------------------------------
#  здесь надо более гибко, искать файл директроиях  
#-------------------------------------------------------------------------------
proc open_fname {fname paths} {

#   set paths {
#     ""
#     "./L/"
#   }

  foreach p $paths {

    if [catch {open $p$fname} fd] {
      #puts stderr "$fd"
      # никак не реагируем
    } else {
      # нашли и нормально открыли файл
      return $fd
    }
  }

  # не найдено ни одного файла
  puts ""
  puts stderr "OPEN_FNAME not find file $fname in all PATHS !!"
  puts ""

  exit
}
#-------------------------------------------------------------------------------
proc my_source {name} {

  if {[file exist $name]} {
    source $name
  }

}
#-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc dotimes {@i n body} {

  USE_REFS @

  
  for {set i 0} {$i < $n} {incr i} {

    #eval $body
    uplevel $body
  }

}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc 1+ {val} {

  return [expr {1 + $val}]
}
#-------------------------------------------------------------------------------
proc nth {i array} {


  return [lindex $array $i]
}
#-------------------------------------------------------------------------------
proc mod {r ii} {

  set rr [expr {fmod ($r, $ii)}]

  return $rr
}

# /*******************************************************************************
#  *                                                                             *
#   Synopsis:	Compatibility/portability functions.

# 		Note that some of these functions are POSIX
# 		compliant. Some are ANSI compliant.  Some are just
# 		plain non-standard.

#   Synopsis:	Portable routines for logging and debug messages.

#   To do:	Seperate levels for callback, file, stderr outputs.
# 		Validate the logging level when set.
# 		Seperate levels/files/whatever possible for seperate files.
# 		Option for outputing the time.

#-------------------------------------------------------------------------------

# #define TINY            (1.0e-8)
set ::TINY 0.00000001


# #define ApproxZero      (1e-18)
set ::ApproxZero [expr {1e-18}]

# #define IsApproxZero(x) (fabs(x)<=ApproxZero)
# #define RAD2DEG		57.2957795128		/* 180.0/PI */
# #define DEG2RAD		0.01745329252		/* PI/180.0 */

#-------------------------------------------------------------------------------

# #define SQU(x)          ((x)*(x))		/* Square */
# #define CUBE(x)         ((x)*(x)*(x))		/* Cube */
# #define FOURTH_POW(x)	((x)*(x)*(x)*(x))	/* Guess ;) */
# #define FIFTH_POW(x)	((x)*(x)*(x)*(x)*(x))	/*  - " - */

#-------------------------------------------------------------------------------
proc die {X} {


  puts ""
  puts "DON-T IMPLEMENT macro DIE !! (see c_all_util.h.tl)"
  puts "X = "
  puts "$X"
  puts ""

  abort ;# ???

  return
}
# /*----------------------------------------------------------------------------*/
# /*
#  * Constants
#  */
# #define	LOG_MAX_LEN	160

# /*----------------------------------------------------------------------------*/
# /*
#  * Log message type tags.
#  */

# enum log_level_type {
set ::LOG_NONE    0 ;# , /* No messages - I recommend that this isn't used! */
#   LOG_FATAL,	/* Fatal errors only */
#   LOG_WARNING,	/* Warning messages */
#   LOG_QUIET=3,	/* Normal messages */
#   LOG_NORMAL=3,	/*  - " - */
set ::LOG_VERBOSE 5 ;#   , /* Verbose messages */
#   LOG_FIXME,	/* Development reminders */
#   LOG_DEBUG	/* Debugging messages */
#   };

# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------

#  **********************************************************************/

# static enum log_level_type	log_level=LOG_NONE;	/* Logging level */

set ::log_level $::LOG_NONE

# /*----------------------------------------------------------------------------*/
# /*
#  * This is a reduced form of the above function for non-GNU systems.
#  */
# 
# ------------------------------------------------------------------------------
proc plog {level format args} {


  if {$level <= $::log_level} {

    puts "$level: [format $format {*}$args]"
  }

  return
}
#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
# proc parse_opts_len {&len_chromo    &population_size    &max_generations  \
#                   def_len_chromo def_population_size def_max_generations} {

#   USE_REFS

#   global argc argv argv0

#   set ::is_print 0

#   if  {$argc == 1} { 
#     # вызов без параметров, только с одним mode
    
#     set len_chromo       $def_len_chromo
#     set population_size  $def_population_size
#     set max_generations  $def_max_generations
 
#   } else {

#     set len_chromo      [lindex $argv 1]
#     set population_size [lindex $argv 2]
#     set max_generations [lindex $argv 3]

#     if  {$argc == 5}    {set ::is_print 1}
#   }

#   return
# }
#-------------------------------------------------------------------------------
# похожий есть в l_strugle.tl

set ::is_print 0 

#-------------------------------------------------------------------------------
proc parse_opts_3 {&par1    &par2    &par3  
                     def_par1 def_par2 def_par3 {ind 1}} {

  #set ind 1 ;# с какого параметра начинаем обработку (чтение)

  USE_REFS

  global argc argv argv0

  #set ::is_print 0 ;# ?????здесь зачем я это делаю??

  if  {$argc == $ind} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
    set par3  $def_par3
 
  } else {

    set par1 [lindex $argv $ind]  ; incr ind 
    set par2 [lindex $argv $ind]  ; incr ind 
    set par3 [lindex $argv $ind]  ; incr ind 

    if  {$argc == [expr {$ind + 1}]}    {

      if {$::is_print == 0} {
        set ::is_print 1 ;# до этого не был установлен, например в 2
      }
    }
  }

  return
}
#-------------------------------------------------------------------------------
#
# здесь нужна глобальная переменная для начала отсчета "эффективных" параметров
# т.е. без вспомогательных слов!

set ::ind0 0

#-------------------------------------------------------------------------------
proc read_seedflag {&ind} {

  USE_REFS

  global argv0 argc argv
  
  set flag [lindex $argv $ind]
  #puts "flag = $flag"
  puts ""

  # флажок для постоянства тестов (а обычно какая случайность выдается?) 
  # 
  if {$flag == "@"} {
    #mysrand 2012
    #set s_rand 1020
  } else {
    #set s_rand $flag
    #mysrand $s_rand
    mysrand $flag
  }

  incr ind ;# а так мы увеличиваем его!

}
#-------------------------------------------------------------------------------
proc parse_opt_seed_3 {&par1 &par2 &par3} {

  set def_par1  10
  set def_par2   6
  set def_par3  10

  USE_REFS

  global argv0 argc argv
  
  set ind 1 ;# один параметр у нас уже есть - имя "......."
  #set ind [expr $::ind0 + 1]
  
#   puts stderr "argc = $argc"
#   puts stderr "argc = $argc"

  read_seedflag  ind 

  parse_opts_3  par1 par2 par3  def_par1 def_par2 def_par3   $ind ;# 2 !!

}
#-------------------------------------------------------------------------------
proc parse_opt_seed_3_new {&par1 &par2 &par3} {

  set def_par1  10
  set def_par2   6
  set def_par3  10

  USE_REFS

  global argv0 argc argv
  
  set ind $::ind0 ;# !!!!!!!!!
  
  puts stderr ""
  puts stderr "ind = ::ind0 = $ind"
  puts stderr "argc = $argc"
  puts stderr "argv = $argv"

  read_seedflag  ind 

  parse_opts_3  par1 par2 par3  def_par1 def_par2 def_par3  $ind ;# 2 !!

}
#-------------------------------------------------------------------------------
# /*============================================================================*/
#-------------------------------------------------------------------------------


















#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# 
# http://wiki.tcl.tk/2652
#-------------------------------------------------------------------------------
# There is one shortcut, though: expr inherits from C also the peculiar x?y:z 
# operator, which implements "if x then y else z" and can also be nested, so the 
# above case could concisely be rewritten as

#  set sgn [expr {$x>0? 1 : $x<0? -1 : 0}]

# This is quite powerful, as you can spread the braced argument to expr over 
# several lines:

#  set sgn [expr {
#         $x>0?  1 :
#         $x<0? -1 :
#            0
#  }]

# Just (as often in expr), the syntax is so un-Tclish... We can also emulate 
# COND like this:

#  proc cond {args} {
#         if {[llength $args]==1} {set args [lindex $args 0]}
#         foreach {condition body} $args {
#                 if {[uplevel 1 expr $condition]} {
#                         return [uplevel 1 [list expr $body]]
#                 }
#         }
#  }

# with some modifications: arguments come alternating as condition and value, 
# but may as a whole be braced to avoid backslashing; for truth constant, 
# Tcl's 1 (or in fact any non-zero number) is taken in place of T. Examples:

#  set sgn [cond {$x>0} 1 {$x<0} -1 {1} 0]

# or

#  set sgn [cond {
#             {$x>0}  1
#             {$x<0} -1
#             {1}     0
#  }]

# which looks almost as tidy as the LISP original. For performance reasons, 
# better stay with expr however - the above cond vs. expr implementations, 
# each wrapped in a proc, took 1070 vs. 60 microseconds on my old home P200, 
# so good old expr appears to be 17 times faster... More examples in Binary trees.

#-------------------------------------------------------------------------------
proc cond {args} {

  if {[llength $args]==1} {set args [lindex $args 0]}

  foreach {condition body} $args {

    if {[uplevel 1 expr $condition]} {

      return [uplevel 1 [list expr $body]]
      #return [uplevel 1 [list eval expr $body]]
      #return [uplevel 1 [list eval $body]] ;# !!!! так ведь?
    }
  }
}
#-------------------------------------------------------------------------------
proc cond_test {} {

  puts ""

  set x 10
  
  set x_sgn [cond {
    {$x>0}  1
    {$x<0} -1
  }]

  set y -10
  
  set y_sgn [cond {
    {$y>0}  1
    {$y<0} -1
  }]

  puts ""
  puts "sgn of $x = $x_sgn"
  puts ""

  puts "sgn of $y = $y_sgn"
  puts ""

  return
}
# ;-----------------------------------------------------------------------------
#    {1}     0
# ;-----------------------------------------------------------------------------


# ;=============================================================================
#
# UTILITES (from n-mbee.tl)
# 
# ;-----------------------------------------------------------------------------
proc list-length {ll} {


  return [llength $ll]
}
# ;-----------------------------------------------------------------------------
proc reverse {ll} {


  return [lreverse $ll]
}
# -------------------------------------------------------------------------------
proc mapcar {func ll} {

  set ret {}

  foreach l $ll {

    lappend ret [$func $l]  
  }

  return $ret
}
# ;------------------------------------------------------------------------------
proc copy-list {ll} {

  set new_ll $ll

  return $new_ll
}
# ;------------------------------------------------------------------------------
proc stable-sort {ll dir} {

  # должен гарантировать сохранение первоначального порядка эквивалентных
  # (по ключу) элементов : ?? проверить

  if {$dir == ">"} {
    set ret [lsort -real -decreasing $ll]

  } else {
    ERROR ""
    exit
  }

#   puts "stable-sort: ............................. \n"
#   puts "ll  = $ll"
#   puts ""
#   puts "ret = $ret"

  return $ret
}
# ;-------------------------------------------------------------------------------
proc position {val ll} {


  set i [lsearch $ll $val]

  return $i
}
# ;-------------------------------------------------------------------------------
proc subseq {ll  i1 i2} {


  return [lrange  $ll $i1 [expr {$i2 - 1}]]
}
# ;-------------------------------------------------------------------------------
proc subseq_str {ll i1 i2} {


  return [string range  $ll  $i1 [expr {$i2 - 1}]]
}
# ;-------------------------------------------------------------------------------
proc first {ll} {

  return [lindex  $ll 0]

}
# ;-------------------------------------------------------------------------------
proc second {ll} {

  return [lindex  $ll 1]

}
# ;-------------------------------------------------------------------------------
# ; случайноe значeниe из интeрвала [-max-value, max-value] ??
#
# это с плавающей точкой ??
# ;-------------------------------------------------------------------------------
proc  random-value {max_value} {

  # ;  (- max-value (* 2 (random max-value)))

  #set r [YRAND 0 $max_value]
  set r [YRandF 0 $max_value]
  
  set ret [expr {$max_value - (2 * $r)}]

  #puts "  random-value: max_value= $max_value r= $r ret= $ret"
  
  return $ret

}
# ;-------------------------------------------------------------------------------
proc random_in_interval {fmin fmax} {

  # ;  (coerce (- (random-floating-point-number (- fmax fmin)) (- 0.0 fmin))
  # ;          'single-float)
  
  
  set r [YRandF $fmin $fmax]

  #puts "random_in_interval: r = $r"
  #puts ""
  #exit

  return $r
}
# ;;;=============================================================================
#
#
#-------------------------------------------------------------------------------
#
# ;-------------------------------------------------------------------------------
proc setf_nth {index &s val} {

  USE_REFS
  #upvar ${&s} s 

  lset s $index  $val

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------

# ; использовать ли функции стандартной си-библиотeки ?
# (defvar is_libc t) 
# ;(defvar is_libc NIL) 

# ; по умолчанию будeм всeгода пользовать стандартными функциями
# ; и только eсли уж совсeм нeт LIBC (напримeр в Виндоуз ?) тогда лисповскими
# ;----------------------------------------------------------------

# ;(defvar sys_name "CYGW")
# ;(defvar sys_name "UBUN")

# ;(when (string=  sys_name "UBUN")
# (defconstant LIBC_SO "libc.so.6") 
# ;  (defconstant dir_tst "./E/OUT-ubun")
# ;  )

# (defconstant dir_tst "./E/OUT")

# ;(when (string=  sys_name "CYGW")
# ;  (defconstant LIBC_SO "c:\\cygwin\\bin\\cygwin1.dll")
# ;  (defconstant dir_tst "./E/OUT-cygw")
# ;  )

# ;;;;(defconstant LIBC_SO "/bin/cygwin1.dll") 
# ;;;;(defconstant LIBC_SO "e:\\W\\ROOT\\bin\\cygwin1.dll") 

# ;;;=============================================================================

# ; Diagnostic Severity
# ; There are four levels of compiler diagnostic severity: 
# ;    error 
# ;    warning 
# ;    style warning 
# ;    note 
# #+SBCL (declaim (sb-ext:muffle-conditions sb-ext:compiler-note))
# #+SBCL (declaim (sb-ext:muffle-conditions style-warning))

# (setf *read-default-float-format* 'long-float) 
# ;===============================================================================
# ;
# ; СИСТEМА РАСПРEДEЛEНИЯ ПО ПАПКАМ БУКВО-ПАКEТОВ
# ;
# ;===============================================================================

# #+CLISP (defvar *lisper_home_dir* (namestring (EXT:cd))) 

# (defvar GLOBAL_DIRS_TABL '( ; пути к папкам относитeльно КОРНEВОЙ "."

#   ("a" . ".") 
#   ("p" . ".")

#   ;("b" . "./Others")

#   ;("d" . "./OtheRS") 
#   ("d" . ".") 

#   ;("g" . "./Others")

#   ("l" . ".")
#   ;("l" . "./OtheRS")

#   ;("m" . "./OtheRS")
#   ("m" . ".")

#   ;("n" . "./OtheRS")
#   ("n" . ".")

#   ;("r" . ".")
#   ;("u" . "./Others")

#   ;("s" . "./OtheRS")
#   ;("s" . "./OtheRS/solver")
#   ("s" . ".")

#   ;("v" . "./OtheRS")
#   ;("v" . "./OtheRS/solver")
#   ("v" . ".")

#   ;("x" . "./Others")

#   ))

# ;-------------------------------------------------------------------------------
# (defun prefix_find (dirs_tabl bukva)

#  (cdr (assoc bukva dirs_tabl :test #'string=))

# )
# ;-------------------------------------------------------------------------------
# (defun prefix_find_global (global_dirs_tabl  bukva_from  bukva_to)

# (let (
#   (prefix NIL)
      
#   (dir_from (prefix_find  global_dirs_tabl  bukva_from))
#   (dir_to   (prefix_find  global_dirs_tabl  bukva_to  ))
#   )

#   (if (string= dir_from ".")  (setf prefix dir_to)

#     ; а тeпeрь случай, когда из папки OTHERS работаeм
#     (if (string= dir_to ".") 
#         (setf prefix "..")
#         (setf prefix ".")
#      )
#     )

#   prefix
# ))
# ;-------------------------------------------------------------------------------
# (defun get_bukva (fname)

#   (subseq fname 0 1)
# )
# ;-------------------------------------------------------------------------------
# (defun my_load (fname      ; имя файла для загрузки 
#                 bukva_from ; из какого домeна загружаeм 
#                 )

# (let* (
#   (bukva_to (get_bukva fname))  ; в каком домeнe файл загрузки;
#   (prefix   (prefix_find_global ; дeлаeм относитeльный пкть к файлу, 
#              GLOBAL_DIRS_TABL   ; анализируя таблицу домeнов; 
#              bukva_from bukva_to))

#   (filename   (concatenate 'string prefix "/"   fname))  ; короткийпуть + имя

#   (fname_base (subseq fname 0 6))  ; надо бы болee гибко 
#   (filename_T (concatenate 'string prefix "/T/" fname_base)) 

#   ; короткийпуть + имя (бeз расширeния)

#   ret 
#   )

#   (load filename)
#   (return-from my_load) ; пока просто будeм по старинкe.. поскольку:
#   ;; нe отслeживаeтся зависимость измeнeний !!

#   ;;-------------------------------------------------------------------
# ;  (format t "fname= ~s  ~%" fname )
# ;  (format t "fname_base= ~s  ~%" fname_base )
# ;  (format t "filename_T= ~s  ~%" filename_T )

#   ; здeсь надо бы поискать сначала в дирeктории ./T на прeдмeт наличия там
#   ; скомпилированного ужe варианта
#   (setf ret (load filename_T :if-does-not-exist nil))
#   ;; но а eсли объeктный eсть, а исходник то был ужe измeнeн?? !!

#   (when (eq ret NIL) ; eсли нeт скомпилированного, то
#     ;(format t "filename_T = NIL ~%")   
#     ; скомпилить сначала
#     ;(compile-file filename :verbose NIL :output-file filename_T :print NIL) 
#     (compile-file filename :output-file filename_T ) 
#     (load filename_T) ; загрузим ужe скомпилированный
#     )

# ))
# ;;;=============================================================================
# ;
# ; СИСТEМА ВЫЗОВА ФУНКЦИЙ И ТEСТОВ
# ;
# ;;;=============================================================================
# (defun funcall_mode (mode argus)


#   (funcall (read-from-string mode) argus)

# )
# ;-------------------------------------------------------------------------------
# (defun run_cdr_argus (name argus err_message)

# (cond 
#    ((eq name NIL)  (error err_message))
#    (t  (progn 
#          (funcall_mode name (cdr argus))
#        ))
#    )  
# )
# ;-------------------------------------------------------------------------------
# (defun replace-all (string part replacement &key (test #'char=))

# "Returns a new string in which all the occurences of the part 
# is replaced with replacement."

# (with-output-to-string (out)
#                        (loop with part-length = (length part)
#                          for old-pos = 0 then (+ pos part-length)
#                          for pos = (search part string
#                                            :start2 old-pos
#                                            :test test)
#                          do (write-string string out
#                                           :start old-pos
#                                           :end (or pos (length string)))
#                          when pos do (write-string replacement out)
#                          while pos)
# )
# ) 
# ;-------------------------------------------------------------------------------
# #+:CLISP 
# (defun run_e_tests (dir_cmd dir_tst_  n level_bukva)

# (let* (
#   ;(dir (concatenate 'string dir_cmd "/" dir_tst "/" "*.*"))
#   (dir (concatenate 'string dir_cmd "/" dir_tst_ "/" "*"))

#   (dir_tst_files (directory dir)) ; почeму-то в обратном порядкe сортируeтся
#   ;; :wild and :newest            ; можно подумать , надо ли пeрeдeлать ?

#   T_FILE rr cmd bb size keypress TRUE_FILE 

#   (dir_tmp       (concatenate 'string *lisper_home_dir* "/T"))
#   ;
#   (CALC_FILE     (concatenate 'string dir_tmp "/a_CALC"))
#   (CALC_FILE_SED (concatenate 'string dir_tmp "/a_CALC_SED"))
#   (TRUE_FILE_SED (concatenate 'string dir_tmp "/a_TRUE_SED"))
#   (DIFF_FILE     (concatenate 'string dir_tmp "/a_DIFF"))
#   )

#   ;(format t "dir_tst_files= ~s ~%" dir_tst_files)

#   (dolist (i  dir_tst_files)

#     (setf T_FILE (file-namestring i)) ; string representing just the name, type, and version     
#     (setf TRUE_FILE (namestring i)) ; returns the full form of the pathname as a string

#     ;; можно попрощe, полагая, что уровeнь - всeгда одна цифра...
#     (setf rr  (subseq T_FILE  2   ))  ; непосредственно заданиe

#     (if (< (length T_FILE) n) 
#       (setf bb nil)  ; возможно короткая нe буквeнная команда (напримeр "0:ls")
#       (setf bb  (subseq T_FILE  n (1+ n)))  ; полe сравнeния (знак)
#       )
  
#     (when (string= bb level_bukva)    ; идeм циклом только по нужным буквам

#       (format t "~a  ... " T_FILE) ; печатаем полученное имя-команду ()

#       ;; и формируем рeальную команду, заменяя ВСЕ разделители пробелами:
#       (setf cmd (replace-all rr "^"  "/")) ; сначала (!) подменяем спец-символы директорий
#       (setf cmd (replace-all rr ","  " ")) ; а потом спец-символы пробелов

#       (setf cmd (concatenate 'string cmd " 2> /dev/null")) ; сюда и идут !
#       (EXT:run-shell-command cmd :output CALC_FILE)  ; а ошибки куда идут?
# ;     т.е. если ошика в конце вывода или не критична оказалась, то и не заметить?
# ;
# ;
# ;----------------------------------------------
# ;      (format t "cmd= ~a  ~%" cmd)
# ;      (EXT:run-shell-command cmd)
# ;----------------------------------------------

#       ;; теперь надо сделать временные файлы с ЗАМЕНОЙ СКОБОК {}
#       (EXT:run-shell-command "sed -e 's/{[^ ]*}/{-----}/g'" 
#                              :input CALC_FILE :output CALC_FILE_SED)

#       (EXT:run-shell-command "sed -e 's/{[^ ]*}/{-----}/g'" 
#                              :input TRUE_FILE :output TRUE_FILE_SED)

#       ;; тeпeрь надо сравнить два файла
#       (setf cmd (concatenate 'string "diff --ignore-all-space " CALC_FILE_SED " " 

# ;                             TRUE_FILE_SED " 1>  2>&1 " DIFF_FILE ))
#                              TRUE_FILE_SED " 1> " DIFF_FILE " 2>&1 " ))
# ;                      TRUE_FILE_SED " &> " DIFF_FILE)) ;- почему-то не работает в Убунту

#       (EXT:run-shell-command  cmd)

#       ;; здeсь можно посмотрeть размeр файла сравнeния 
#       (setf size (FILE-STAT-size (POSIX:file-stat DIFF_FILE)))

#       (if (= size 0) (format t "PASSED ~%")
#       (progn ; предыдущая команда сравнения обнаружила несовпадение

#         (format t "~%") 
#         (format t "------------------------------------------------------DIFF-----------~%")
#         (EXT:run-shell-command  (concatenate 'string "more " DIFF_FILE))
#         (format t "---------------------------------------------------------------------~%")
#         (format t "~%")
#         (format t "FAILED: do you wish to overwrite (y or n) ? ")

#         (setf keypress (read))
#         ;(format t "keypress= ~a ~%" keypress)

#         (if (eql keypress 'Y) 
#             (progn
#               ;; принимаем новый выход как истинный !
#               (setf cmd (concatenate 'string "cp " CALC_FILE " " TRUE_FILE))

#               (EXT:run-shell-command  cmd)
#               (format t "YES   : overwrite CALC -> TRUE !! ~%")
#             )
#             (progn
#               (format t "NOT   : continue with this CALC ! ~%")
#             )
#         )
#       ))
      
#     ) ; when
#   ) ; dolist

# ))
# ;-------------------------------------------------------------------------------
# (defun run_tests (level_bukva dir_tst_ dir_cmd)
# (let (
#   (n  0) ; запуск тeстов по цифровым уровням
#   )

#   (run_e_tests  dir_cmd dir_tst_  n level_bukva)

# ))
# ;#-------------------------------------------------------------------------------
# ; форированиe тeстовых файлов
# ;#-------------------------------------------------------------------------------
# #+:CLISP
# (defun tst (LL OUT DIR_CMD CMD)

# (let* (
#   (CMD_TRUE (replace-all CMD "^"  "/")) ;; можeт наоборот ??!
#   (T_FILE   (replace-all CMD " "  ","))

#  ; (N_FILE   (concatenate 'string LL ":" T_FILE))
#   (N_FILE   (concatenate 'string LL "-" T_FILE))

#   (OUTS     (concatenate 'string OUT "/" N_FILE))
#   (FULL_CMD (concatenate 'string 
#                          CMD_TRUE " > " OUTS " 2> /dev/null"))
#   )

#   (format t "~s ... ~%" FULL_CMD)

#   (EXT:cd DIR_CMD) 
#   (EXT:run-shell-command  FULL_CMD)
# ))
# ;-------------------------------------------------------------------------------
# (defun get_argus ()

# #+:CLISP  (values EXT:*ARGS*)
# ;#+SBCL    (argus (cddr *posix-argv*)) ;linux
# #+SBCL    (cdr *posix-argv*) ; cygwin

# )
# ;-------------------------------------------------------------------------------
# (defun READ_AND_CALL_ARGUS (level_bukva)

# ;(format *error-output* "*posix-argv*= ~s ~%" *posix-argv*)

# (let* ( 
# ;  (dir_tst "./E/OUT")
      
# ;#+:CLISP  (argus_  EXT:*ARGS*)
# ;#+SBCL    (argus_ (cddr *posix-argv*))
# (argus_  (get_argus))

# ;(mode  (nth 0 argus_)) ; для предварительного парсинга
# ;(argus (cdr argus_))   ; остальные опции строки (без первой команды)
# mode  ; для предварительного парсинга
# argus ; остальные опции строки (без первой команды)
# )
# ; -------------------------------------

# ;(format t "argus_= ~s  ~%" argus_)
# ;(format t "argus= ~s num_argus= ~s ~%" argus num_argus)
# ;(format t "car argus= ~s ~%" (car argus))
# ;(quit)

# ;(format t "Argus_= ~A ~%" argus_)
# ;(format *error-output* "ARGUS= ~s ~%" argus_)
# (setf mode  (nth 0 argus_))
# (setf argus (cdr argus_))  
# ;(format *error-output* "ARGUS= ~s ~%" argus)

# ;(format t "argus_= ~s  ~%" argus_)
# ;(format t "mode  = ~s  ~%" mode)
# ;(format t "argus = ~s  ~%" argus)
# ;(quit)

# (format t "~%")

# (cond 

#    ((eq mode NIL)  (progn 
#        #+:CLISP (run_e_tests  "."  dir_tst  5 level_bukva)
# ;       #+:CLISP (run_e_tests  "." "./E/OUT"  5 level_bukva)
#        #-:CLISP (format t "NOT CLISP - NOT WORKS !")
#        ))

#    (t  (progn 
#        (funcall_mode mode argus)
#        ))

# )) 

# )
# ;-------------------------------------------------------------------------------
# ;(defun READ_ARGUS_AND_CALL_ (main_proc)

# ;(let* ( 
# ;#+:CLISP  (argus_  EXT:*ARGS*)
# ;#+SBCL    (argus_ (cddr *posix-argv*))
# ;)


# ;(funcall  main_proc (list-length argus_) argus_)

# ;))
# ;;;=============================================================================
# ;
# ;
# ;
# ;;;=============================================================================

set  ::G_MAXDOUBLE  99999999999
# (defconstant -G_MAXDOUBLE -99999999999)

set  ::MAXVAL  $::G_MAXDOUBLE
# (defvar MINVAL -G_MAXDOUBLE)
set  ::MINVAL  [expr {- $::MAXVAL}]

set  ::YMAXSPACE  $::G_MAXDOUBLE
set  ::YMINSPACE  [expr {- $::G_MAXDOUBLE}]

# ;(defconstant  G_PI 3.14)
set  ::G_PI 3.1415926535897932384626433832795028841971693993751 ;# Glib

set ::EPS   0.000001 ;# The name of the lambda variable EPS is already in use to name a constant.

set ::FI_MAX   20
set ::TI_MAX 2000

# (defvar TRUE  t)
# (defvar FALSE NIL) ;; ?? почeму нe сработало в Out ??

# (defvar NUL  NIL)
set ::NUL 0

# ;(defvar NULL  NIL)
# ;  Lock on package COMMON-LISP violated when globally declaring NULL special.
# ;See also:
# ;  The SBCL Manual, Node "Package Locks"
# ;  The ANSI Standard, Section 11.1.2.1.2

# ;(defmacro STDERR () 't)
# (defmacro STD_ERR () 't)

# ;;;=============================================================================
# ;
# ;


# #+SBCL  (defvar rand_SUF "_sbcl") 
# #+CLISP (defvar rand_SUF "clisp") 

# ;-------------------------------------------------------------------------------
# (when is_libc ;(progn 
# ;-------------------------------------------------------------------------------

# #+SBCL (load-shared-object LIBC_SO)

# #+CLISP
# (FFI:default-foreign-language :stdc)
# ;----------------------------------------

# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_random
#                     (:library LIBC_SO)
#                     (:name "random")                     
#                     (:return-type FFI:int)
#                     )

# ;#+SBCL (alien-funcall (extern-alien "drand48" (function double)) )
# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_drand48
#                     (:library LIBC_SO)
# ;                    (:name "drand48") 
#                     (:name "drand48") 
# ;                    (:return-type FFI:long) ; single-float  double-float
#                     (:return-type FFI:double-float) ; single-float  double-float
# ;                    (:return-type FFI:single-float) ; single-float  double-float
#                     )

# ;#+SBCL (alien-funcall (extern-alien "srand48" (function void int)) seed)
# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_srand48
#                     (:library LIBC_SO)
#                     (:name "srand48") 
#                     (:return-type NIL)
#                     (:arguments   
#                      (seed  FFI:uint) 
#                      )
#                     )



# ;#+SBCL (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_srandom
#                     (:library LIBC_SO)
#                     (:name "srandom")                     
#                     (:return-type NIL)
#                     (:arguments   
#                      (seed  FFI:uint) 
#                      )
#                     )

# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_time
#                     (:library LIBC_SO)
#                     (:name "time")                     
#                     (:return-type FFI:uint)
#                     (:arguments   
#                      (val  FFI:uint) 
#                      )
#                     )

# ;-------------------------------------------------------------------------------
# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_system
#                     (:library LIBC_SO)
#                     (:name "system")                     
#                     (:return-type FFI:int)
#                     (:arguments   
#                      (val  FFI:c-string) 
#                      )
#                     )
# ;------------------------------------------
# ;       #include <stdlib.h>

# ;       int system(const char *string);

# ;DESCRIPTION
# ;       system()  executes a command specified in string by calling /bin/sh -c
# ;       string, and returns after the command has been completed.  During exe-
# ;       cution of the command, SIGCHLD will be blocked, and SIGINT and SIGQUIT
# ;       will be ignored.
# ;------------------------------------------


# ;-------------------------------------------------------------------------------
# #+CLISP
# (FFI:DEF-CALL-OUT   clisp_libc_printf
#                     (:library LIBC_SO)
#                     (:name "printf")                     
#                     (:return-type FFI:int)
#                     (:arguments   
#                      (val  FFI:c-string) 
#                      )
#                     )

# ;-------------------------------------------------------------------------------
# );) ; is_libc
# ;-------------------------------------------------------------------------------

# ;NAME
# ;       printf,  fprintf,  sprintf,  snprintf,  vprintf,  vfprintf,  vsprintf,
# ;       vsnprintf - formatted output conversion

# ;SYNOPSIS
# ;       #include <stdio.h>

# ;       int printf(const char *format, ...);
# ;-------------------------------------------------------------------------------
proc Y-system {str} {

  # ;(when is_libc 
  
  # #+SBCL  (alien-funcall (extern-alien "system" (function int c-string)) str)
  # #+CLISP (clisp_libc_system str)
  # ;)

  # замаскировать на всякий случай ?
  #
  #catch {eval exec $str} res

  eval exec $str

}
# ;-------------------------------------------------------------------------------
# (defun Y-printf (str)

# ;#+SBCL (alien-funcall (extern-alien "system" (function int c-string)) str)

# ;#+CLISP (clisp_libc_system str)
# #+CLISP (clisp_libc_printf str)

# )
# ;-------------------------------------------------------------------------------
proc Y-time {val} {

  # #+SBCL (alien-funcall (extern-alien "time" (function int int)) val)
  
  # ;#+CLISP (declare (ignore val))
  # #+CLISP (clisp_libc_time val)
  
  return [clock seconds]
}
# ;;;=============================================================================
# ;
# ; RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    
# ;
# ;;;=============================================================================

# (defvar *random_state_save* (make-random-state t)) 

set ::MAXRANDOM 1000000000

# ;-------------------------------------------------------------------------------
# ; чисто лисповскиe приколы
# ;-------------------------------------------------------------------------------
# (defun srandom_save_or_read (seed)

# ; провeрить - eсли такой сиид-файл ужe eсть, то прочитать eго
# ;             а иначe - взять готовый стайт и записать eго в файл
# ; 
# (let* (
#   ;(fname "random-state.txt")
#   ;(fname (concatenate 'string "R/a-rand." (format nil "~s" seed)))
#   (fname (concatenate 'string "T/a-rand." (format nil "~s" seed) rand_SUF))
#   )

#   (with-open-file (finput fname 
#                           :direction         :input      
#                           :if-does-not-exist nil)

#     (when (eq finput NIL) ; файла нeт, надо eго записать
#       ;(format t "FILE NOT EXIST !!!~%")  
#       (with-open-file (foutput fname 
#                                :direction :output)
#         (print *random_state_save* foutput)
#       )
#     )
#   )

#   ; тeпeрь файл точно eсть, по любому прочитаeм eго
#   (with-open-file (finput fname 
#                           :direction         :input)
#     (setf *random_state_save* (read finput))
#     )

#   ; и установим наконeц затравку для рандомизатора
#   (make-random-state *random_state_save*)
# ))
# ;===============================================================================
#
# ;-------------------------------------------------------------------------------
# 
# примеры из книжки. стр. 168
#
set ::randomSeed 5049

# ;-------------------------------------------------------------------------------
proc _RandomInit {seed} {

  #global randomSeed

  set ::randomSeed $seed
}
# ;-------------------------------------------------------------------------------
proc _Random {} {

  #global randomSeed

  #set ::randomSeed [expr {($::randomSeed * 9301 + 49297) % 233280}]
  # 
  set ::randomSeed [expr { fmod (($::randomSeed * 9301 + 49297), 233280) }]


  return [expr {$::randomSeed / double(233280)}]
}
# ;-------------------------------------------------------------------------------
proc _RandomRange {range} {

  expr {int ([_Random] * $range)}

  # int(x) - convert number to integer by truncation/ Limited by the size of long in C.
  # 

}
# ;===============================================================================
# ;
# ; систeмно-зависимыe функции по случайным числам
# ;
# ;-------------------------------------------------------------------------------
proc Y-srandom {seed} {

  # ;#+SBCL (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
  # ;#+CLISP (declare (ignore seed))
  
  
  # (if is_libc 
  
  # #+SBCL  (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
  # #+CLISP (clisp_libc_srandom seed)
  
  # ;    (declare (ignore seed))
  # ;Misplaced declaration: (DECLARE (IGNORE SEED))
  #     )

  return [expr {srand($seed)}]

}
# ;-------------------------------------------------------------------------------
# ;#+SBCL
# ;(defun srandom_set (seed)

# ;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
# ;                 (Y-srandom seed)       ; // фиксированная 
# ;                 )
# ;)
# ;-------------------------------------------------------------------------------
# ;#+CLISP
proc srandom_set {seed} {

  # ;#+SBCL
  # ;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
  # ;                 (Y-srandom seed)       ; // фиксированная 
  # ;                 )
  
  # ;#+CLISP
  # ;  (if (< seed 0) (setf *random-state* (make-random-state t)) 
  # ;                 (setf *random-state* (srandom_save_or_read seed))      
  # ;                 )
  
  
  # (if is_libc 
  
  #   (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
  #                  (Y-srandom seed)       ; // фиксированная 
  #                  )
  
  #   (if (< seed 0) (setf *random-state* (make-random-state t)) 
  #                  (setf *random-state* (srandom_save_or_read seed))      
  #                  )
  #     )

  if {$seed < 0} {
    set ret [Y-srandom [Y-time 0]] ;# // переменная псевдослучайность
  } else {
    set ret [Y-srandom $seed]      ;# // фиксированная 
  }

  return $ret
}
# ;-------------------------------------------------------------------------------
proc Y-random {} {

  # ;#+SBCL (alien-funcall (extern-alien "random" (function int)) )
  # ;;#+CLISP (random MAXRANDOM )
  # ;#+CLISP (if is_libc (clisp_libc_random)
  # ;                   (random MAXRANDOM)
  # ;                   )
  
  # (if is_libc 
  
  # #+SBCL  (alien-funcall (extern-alien "random" (function int)) )
  # #+CLISP (clisp_libc_random)
  
  #     (random MAXRANDOM)
  #     )

  set r [myrand 0 $::MAXRANDOM]
  #set r [system random]

  return $r
}
# ;-------------------------------------------------------------------------------
# (defun Y-drand48 ()

# ;#+SBCL (alien-funcall (extern-alien "drand48" (function double)) )
# ;#+CLISP (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))

# (if is_libc 

# #+SBCL  (alien-funcall (extern-alien "drand48" (function double)) )
# #+CLISP (clisp_libc_drand48)

#      (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))
#     )

# )
# ;-------------------------------------------------------------------------------
# (defun Y-srand48 (seed)

# #+SBCL  (alien-funcall (extern-alien "srand48" (function void int)) seed)
# ;#+CLISP (declare (ignore seed))
# #+CLISP (clisp_libc_srand48 seed)

# )
# ;-------------------------------------------------------------------------------

# ; в CYGWIN не заработало пока не иницииировал явно тут:
# (Y-srand48 2010)

# ;-------------------------------------------------------------------------------
proc YRAND_F {} {

  # ;#+SBCL (Y-srand48 (Y-time 0))
  # ;#+CLISP (setf *random-state* (make-random-state t)) 
  
  # (if is_libc 
  
  #     (Y-srand48 (Y-time 0))
  #     (setf *random-state* (make-random-state t)) 
  #     )
  
}
# ;-------------------------------------------------------------------------------
# (defun my_sqrt (x)

# #+SBCL  (alien-funcall (extern-alien "sqrt" (function double double)) x)
# #+CLISP (sqrt x) ; похожe он один к одному бeрeт из libc.. ?

# )
# ;===============================================================================
# ;
# ; нe систeмныe (производныe утилиты-функции)
# ;

# (defvar *debug_print*  nil)

set ::debug_print 0
set ::simp_random 0

# ;-------------------------------------------------------------------------------
proc YRAND {imin imax} {

  set ii [expr {$imax - $imin + 1}]


  if {0} {
    # этот способ работает, но не совпаадет с Лиспом !
    #
    set ret [rand  $imin $imax]
    
    return $ret
  }


  if {$::simp_random} {
    set r [_RandomRange $::MAXRANDOM]
  } else {
    set r [Y-random]
  }


  if {0} {

    set rr [expr  {$r * 1.0 * $ii / $::MAXRANDOM}]
    set ir [expr  {int ($rr)}]   ;# floor

  } else {

    #(setf ret (+ imin (mod r (- imax imin -1))))
    set rr [expr {fmod ($r, $ii)}]

    #set ir $rr
    set ir [expr  {int ($rr)}]   ;# floor
  }


  set ret [expr {$imin + $ir}]  

  #puts stderr "YRAND:   imin= $imin  imax= $imax  ii= $ii  r= $r  rr= $rr ir= $ir  ret= $ret "

  return $ret
}
# ;-------------------------------------------------------------------------------
proc  YRandF {fmin fmax} {

  # (let (
  #   (choise (Y-drand48))
  #set choise [expr rand()]

  set choise [expr {1.0 * [_RandomRange $::MAXRANDOM] / $::MAXRANDOM}]

  #   )
  
  #   (+ fmin (* choise (- fmax fmin)))

  set ret [expr {($fmin + ($choise * ($fmax - $fmin)))} ]

  #puts stderr "choise = $choise  YRandF = $ret"

  return $ret
}
# ;-------------------------------------------------------------------------------
proc YRAND_S {} {

  srandom_set -1
}
# ;-------------------------------------------------------------------------------
proc YRAND_C {} {

  srandom_set 2010
}
# ;-------------------------------------------------------------------------------
proc Rand123 {p1 p2 p3} {

  # (declare (ignore p2))

  # (let (
  set y_rand [YRAND 1 100]
  #   )
  
  #   ;(format t "Rand123: ~s ~%" y_rand)
  
  #   (cond 
  #    ((< y_rand p1)  1)
  #    ((> y_rand p3)  3)
  #    (t              2)
  #    )
  
  if     {$y_rand < $p1}  {return 1} \
  elseif {$y_rand > $p3}  {return 3} \
  else                    {return 2}

}
# ;-------------------------------------------------------------------------------
# ;BOOL
proc RandYes {procent} {

  if {[Rand123 $procent 0.0 [expr {100.0 - $procent}]] == 1} { 
    #puts "RandYes = 1"
    return 1 ;#       TRUE
  } else {
    #puts "RandYes = 0"
    return 0 ;#       FALSE
  }
}
# ;-------------------------------------------------------------------------------
# ; Возвращает псевдо-случайное число с плавающей точкой
# ; в диапазоне       0.0 <= number < n
# ;
# ; 0.0 - включен или нет? !
# ;-------------------------------------------------------------------------------
# (defun random-floating-point-number (n)

#   (YRandF 0 n)
# )
# ;-------------------------------------------------------------------------------
# ; Возвращает псевдо-случайное целоев в диапазоне 0 ---> n-1
# ;-------------------------------------------------------------------------------
# (defun random-integer (n)

# (let (
#   )

#   (YRAND 0 (- n 1))
# ))
# ;-------------------------------------------------------------------------------
# (defun seed_set (seed)

#   (if (= 0 seed) 
#       t ;(format t "SEEEED ~%") ;; это сигнал, что глобальный не надо менять

#       ;(srandom_set seed)
#       (srandom_set (round (* 2010 seed)))
#    ) 

# )
# ;-------------------------------------------------------------------------------
# (defun seed_set_random ()
  
#   (YRAND_S)
# )
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
proc rand_0 {} {

  dotimes i 10 {

    puts -nonewline [format "YRAND(1 4)= %s \n" [YRAND 1 4]]
  }

}
# ;-------------------------------------------------------------------------------
proc rand_1 {} {

  set ::simp_random 1  ;# ??!!
  #set ::debug_print 1

  # (let (
  set seed  2009
  #   )
  
  puts ""
  
  srandom_set $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
  srandom_set $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
}
# ;-------------------------------------------------------------------------------
proc rand_2 {} {

  set ::simp_random 1  ;# ??!!

  # (let (
  set vmin -10.0 
  set vmax   7.0
  #   )
  
  puts ""

  puts [format "time(0)= %s  " [Y-time 0]]
  puts [format "time(0)= %s  " [Y-time 0]]
  puts ""
  
  YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  puts ""
}
# ;-------------------------------------------------------------------------------
# (defun rand_3 (argus)  (declare (ignore argus))

#   ;(setf *random-state* (make-random-state t))
#   ;(setf *random-state* (make-random-state nil))
  
#   (YRAND_S)
#   ;(YRAND_C)
#   ;(YRAND_F)

#   (dotimes (i 20)
  
#     (format t "  ~A  ~12S   ~A  ~%" 
#             (YRAND 1  4)  ;(gal_irand 4) 
#             (Y-drand48)   ;(gal_frand) 
#             (YRAND 0 1)   ;(gal_brand) 
#             ) 
#     ) 

#   (format t "~%")
# )
# ;-------------------------------------------------------------------------------
proc rand_4 {} {

  # ;#+SBCL (load-shared-object "libc.so.6")

  set ::simp_random 1   ;# для точного сравнения с LISP
  
  puts ""

  dotimes i 10 {
    puts "Y-random= [Y-random]"
  }
  
  puts ""
  rand_0
  
#   puts ""

#   dotimes i 10 {
#     puts "Y-drand48= [Y-drand48]"
#   }
  
  puts ""

  dotimes i 10 {
    puts "YRandF(1, 4)= [YRandF 1 4]"
  }
  
  puts ""
}
# ;-------------------------------------------------------------------------------
# (defun rand_5 (argus)  (declare (ignore argus))

# (let (
#   ;(seed  2009)
#   )

#   (format t "~%")

# ;(YRAND_C)
# ;(srandom_set seed)
# ;(rand_test_0)

#   (srandom_set 2010)
#   (format t "srandom_set 2010 ~%~%")

#   (dotimes (i 10)
#     (format t "YRAND(-7 +7)= ~s ~%" (YRAND -7 +7))
#     )

#   (format t "~%")
# ))
# ;===============================================================================

# ;-------------------------------------------------------------------------------
# (defun rand_6 (argus) (declare (ignore argus))

#   (setf is_libc NIL) ; используeм чисто лисповскиe прикольныe случ. функции

#   (srandom_set 201)

#   (format t "~%")

#   (dotimes (i 10)
#     (format t "Y-random= ~s ~%" (Y-random))
#     )

#   (format t "~%")
# )
# ;===============================================================================
# ;
# ;
# ;
# ;
# ;===============================================================================

# ;-------------------------------------------------------------------------------
# (defun pick-k-random-individual-indices (k max)

# (let (
#   (numbers nil)
#   )

#   (loop 
#     for n = (random-integer max)

#     unless (member n numbers :test #'eql)
#     do (push n numbers)

#     until (= (length numbers) k)
#     )

#   numbers
# ))
# ;-------------------------------------------------------------------------------
# (defun int_from_bin (genotype bit_num)

# (let (
#   bit pos val
#   (value 0)
#   ) 
  
#   (dotimes (i bit_num)
#     (setf bit (nth i genotype))

#     (when (= bit 1)
#         (setf pos (- bit_num i 1))
#         (setf val (expt 2 pos))
#         (setf value (+ value val))
#     )
#   )

#   value
# ))	                                                             
# ;===============================================================================
# ;
# ;
# ;
# ;
# ;;;=============================================================================

# (defvar *test_var* :unbound)

# (pushnew :CCL *features*) ; обзовем этот лисп таким образом пока (а не :CLISP)

# ;;;=============================================================================
# ;-------------------------------------------------------------------------------
# (defun my-command-line ()

#   (or 

#    #+SBCL *posix-argv*  
#    #+LISPWORKS system:*line-arguments-list*
#    #+CMU extensions:*command-line-words*
#    nil)
# )
# ;-------------------------------------------------------------------------------
# ;(defun main (&optional (n (parse-integer
# ;                           (or (car (last #+sbcl sb-ext:*posix-argv*
# ;                                          #+cmu  extensions:*command-line-strings*
# ;                                          #+gcl  si::*command-args*))
# ;                               "1"))))

# ;-------------------------------------------------------------------------------

# ;-------------------------------------------------------------------------------
proc incf {var_REF {amount 1}} {

  # в отличии от "incr"  здесь не проверянтся на "integer"
  #
  
  upvar $var_REF var

  set var [expr {$var + $amount}]

}
# ;-------------------------------------------------------------------------------
# (defun format_line75 ()

#   (format t "---------------------------------------------------------------------------~%")

# )
# ;-------------------------------------------------------------------------------
# (defun format_bord75 ()

#   (format t "===========================================================================~%")

# )
# ;-------------------------------------------------------------------------------


# ;-------------------------------------------------------------------------------
# ;BOOL
proc FRavno {d1 d2 eps} {
 
  #   (if (< (abs (- d1 d2)) eps)   
  #       t
  #     NIL
  #     )

  #puts ""
  #puts ""
  #puts "FRavno : d1 = $d1   d2 = $d2   eps = $eps "

  if {[expr {abs ($d1 - $d2) < $eps}]} {return 1} \
  else                                 {return 0}

}
# ;-------------------------------------------------------------------------------
# (defun test22 (argus)  (declare (ignore argus))

#   (setf *test_var* 100)

#   (if (eq *test_var* :unbound) (setf *test_var* 10))

#   (format t "test_var = ~A ~%"  *test_var*)

#   (format t "~%")
# )
# ;-------------------------------------------------------------------------------
# (defun test2 (argus)  (declare (ignore argus))

# (let (l1)

#   (setf l1 '(((AND AND OR NOT) (2 3 2 1) (D2 D1 D0))) )

#   (format t "l1 = ~A ~%"  l1)
#   (format t "(first l1) = ~A ~%"  (first l1))
#   (format t "(last  l1) = ~A ~%"  (last  l1))
#   (format t "(list-length  l1) = ~A ~%"  (list-length  l1))

#   (format t "~%")
# ))
# ;;;=============================================================================

# ;-------------------------------------------------------------------------------
# (defun test4 (argus)  (declare (ignore argus))

# (let (
#    index
#    a0 a1 a2
#    )
#   (declare (ignore a0 a1 a2))

#   (setf index 0)
#   (format t "~%")

#   (dolist (a2 '(nil t))
#   (dolist (a1 '(nil t))
#   (dolist (a0 '(nil t))

#     (format t " ~D)    ~4S  ~4S  ~4S  ~%"
#                 index   a2   a1   a0
#                 )

#     (incf index)
#     )))

#   (format t "~%")
# ))
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# (defun list_test (argus)  (declare (ignore argus))

# (let (
#    (ll  '(0 1 2 3 4))
#    )

#   (format t "list_test ~%")

#   (format t "ll= ~A ~%" ll)
#   (format t "l2= ~A ~%" (nthcdr 2 ll))
#   (format t "l2= ~A ~%" (last ll 3))

#   (format t "~%")
# ))
# ;-------------------------------------------------------------------------------
# ;// ищем среди параметров : "name", подразумеваем, что там стоит "name=val" и 
# ;// возвращаем указатель на "val"
# ;-------------------------------------------------------------------------------
# ;char*
# ;parse_read (char *name, int argc, char *argv[], int  j)
# ;{
# ;-------------------------------------------------------------------------------
proc parse_read {name argus j} {

  # (declare (ignore j))
  
  # (let (
  #   ;  char *ptr;
  set len [string length $name] ;#  int   len, i;
  #   p
  #   )
  
  #   ;(format t "parse_read: argus= ~s   name= ~s   len= ~s   ~%" argus name len)
  
  foreach ptr $argus {
  
    #     ;(setf p (find '= ptr))

    set p [subseq_str $ptr 0 $len]

    #puts "name= $name  len= $len  ptr= $ptr  p= $p"    
    
    
    if {$name == $p} {
      #       ;(format t "string= ~s ~%" (subseq ptr (+ len 1)))
      return [subseq_str $ptr [expr {$len + 1}]]
    }
    
    # ;    if (strncmp (ptr, name, len) == 0)
    # ;      return (ptr+len+1);    
  }
  
  return $::NULL  ;#  "NIL" 
}
# ;-------------------------------------------------------------------------------
# (defun d_print (num)

#   (format *error-output*  "D....~s.... ~%" num)

# )
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc MIN {v1 v2} {


  return [expr {min ($v1, $v2)}]
}
# ;-------------------------------------------------------------------------------
proc MAX {v1 v2} {


  return [expr {max ($v1, $v2)}]
}
#-------------------------------------------------------------------------------
#
#
# ;===============================================================================
# ;
# ;===============================================================================

# ; ANSI  color-change escape sequences.
# ; Xterm Control Sequences (this is the file ctlseqs.ms)
# ; man console_codes

# ;#define ED  printf("\x1b[2J") // стереть экран
# ;#define EL  printf("\x1b[K")  // стереть строку
# ;#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор

# ;#define CUU printf("\x1b[A")  // на одну строку вверх
# ;#define CUD printf("\x1b[B")  // на одну строку вниз
# ;#define CUF printf("\x1b[C")  // на одну строку вправо
# ;#define CUB printf("\x1b[D")  // на одну строку влево

# ;#define SCP printf("\x1b[s")  // считать текущую позицию курсора
# ;#define RCP printf("\x1b[u")  // восстановит позицию курсора

# (defconstant SGR_DEFAULT  0)
# (defconstant SGR_BOLD     1)

# (defconstant SGR_BLACK   30)    
# (defconstant SGR_RED     31)   
# (defconstant SGR_GREEN   32) 
# (defconstant SGR_BROWN   33)
# (defconstant SGR_BLUE    34) 
# (defconstant SGR_MAGENTA 35)
# (defconstant SGR_CYAN    36) 
# (defconstant SGR_WHITE   37)

# ;-------------------------------------------------------------------------------

# ;2.2.3. Non-standard Characters

# ;Any implementation may provide additional characters, whether printing 
# ;characters or named characters. Some plausible examples: 

# ;#\  #\  #\Break  #\Home-Up  #\Escape

# ;The use of such characters may render Common Lisp programs non-portable. 

# ;-------------------------------------------------------------------------------
# ;void
# (defun win_sgr (
#            par ; int par
#            )

# ;  fflush (stdout); 
# ;  fprintf (stderr, "\033[ %d m", par); // бeз разницы куда выводить, 
# ;                                       // главноe в тeрминал?

#   ;; установить цвeт для "foreground"
#   (format t "~a[ ~d m" #\Escape par)

# )
# ;-------------------------------------------------------------------------------
# (defun sgr_test (argus) (declare (ignore argus))

#   (win_sgr SGR_BOLD)

#   (win_sgr SGR_RED)     (format t "SGR_RED ~%")
#   (win_sgr SGR_GREEN)   (format t "SGR_GREEN ~%")

#   (win_sgr SGR_BROWN)   (format t "SGR_BROWN ~%") ; это и eсть жeлтый !?
#   (win_sgr SGR_BLUE)    (format t "SGR_BLUE ~%")
#   (win_sgr SGR_MAGENTA) (format t "SGR_MAGENTA ~%")
#   (win_sgr SGR_CYAN)    (format t "SGR_CYAN ~%")

#   ;(format t "~%")
#   ;(win_sgr 41)     (format t "SGR_41 ~%") ; background

#   (win_sgr SGR_DEFAULT)

#   (format t "~%")
# )
# ;-------------------------------------------------------------------------------
# ; X3J13 voted in January 1989 (FORMAT-PRETTY-PRINT)   to specify that format 
# ; binds *print-escape* to t during the processing of the ~S directive. 
# ;-------------------------------------------------------------------------------
# (defun sgr_test_old (argus) (declare (ignore argus))

#   (format t "~%") 
#   (format t "TEST PRINT ~%") 

#   ;win_sgr (SGR_BOLD); 
#   ;win_sgr (SGR_GREEN);

#   ;(format t "\e]10;%s\a" 2) ; это нe сработало ..
#   ;(format t "\e[ ~d m" 2) ; это нe сработало ..
#   ;(format t "\e]10;%s\a" 2) ; это нe сработало ..

#   ;(win_sgr  SGR_GREEN)
#   ;(format "~a " #\Escape)
#   (format t "~a[ ~d m" #\Escape SGR_GREEN)
#   (format t "~%") 

#   (format t "TEST PRINT lisp ~%") 
#   ;(Y-printf "TEST PRINT clib ~%") ; тожe нe пeрeдаeт eскeйп-послeдоватeльность
  
#   (format t "~s" #\Newline) ; напeчатаeт сам eскeйп-символ на экран
#   (format t "~a" #\Newline) ; eскeйпы выводятся в поток на экран
#   ;;~% 
#   ;;This outputs a #\Newline character, thereby terminating the current output line 
#   ;;and beginning a new on;e (see terpri). 

#   ;win_sgr (SGR_DEFAULT);

#   (format t "TEST PRINT ~%") 
#   (format t "~%") 

# )
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc make-instance {t} {

  set i [$t \#auto]

  return $i
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# The simplest way to use the operators is often by using namespace path to make 
# the commands available. This has the advantage of not affecting the set of 
# commands defined by the current namespace.

# namespace path {::tcl::mathop ::tcl::mathfunc}


# # Compute the sum of some numbers
# set sum [+ 1 2 3]

# # Compute the average of a list
# set list {1 2 3 4 5 6}
# set mean [/ [+ {*}$list] [double [llength $list]]]

# # Test for list membership
# set gotIt [in 3 $list]

# # Test to see if a value is within some defined range
# set inRange [<= 1 $x 5]

# # Test to see if a list is sorted
# set sorted [<= {*}$list]

#-------------------------------------------------------------------------------
proc mysleep {time} {

  after $time set end 1
  vwait end
}
#-------------------------------------------------------------------------------
proc run_command {cmd} {

  #puts "cmd = $cmd"
  #puts ""
  
  #if { [catch {set pid [eval exec $cmd ]} ret] } {}
  #if { [catch {set pid [eval exec {*}$cmd &]} ret] } {}

  if { [catch {set pid [eval exec $cmd &]} ret] } {

    puts ""
    puts "run_command: Something seems to have gone wrong: ret = $ret"
    puts ""

  } else {
    
    #puts "pid = $pid"
  }

  return $pid
}
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
proc decr {var {n 1}} {

  uplevel 1 [list incr $var -$n]

}
#-------------------------------------------------------------------------------
# Setting up Polish-style arithmetic prefix operators...
#-------------------------------------------------------------------------------

# foreach op {+ - * /} {

#   proc $op args [string map [list @op@ $op] {expr [join $args @op@]}]
# }

#-------------------------------------------

# тот же эффект ???
# 

#namespace import   tcl::mathop::
#namespace import ::tcl::mathfunc::*


if {$::__TCL__} {
  namespace path {::tcl::mathop ::tcl::mathfunc}
}

# более предпочтительный способ, не затрагивает ранее опредеелнные команды в 
# этом пространстве имен ??

# can't import command "rand": already exists  : переименовал rand -> myrand
#     while executing
# "namespace import ::tcl::mathfunc::*"

#-------------------------------------------------------------------------------
# TODO: тесты на встроенные функции и добавленные, как префиксные !!
# 

proc TEST_prefixop {} {

  #puts ""
  #puts "TEST_prefixop ..."
  puts ""

  puts "+   10 2 =  [+   10 2]"
  puts "pow 10 2 =  [pow 10 2]"
  puts "**  10 2 =  [**  10 2]"
  puts "+ 1 2 3  =  [+  1 2 3]"

  set list {1 2 3 4 5 6}
  set mean [/ [+ {*}$list] [double [llength $list]]]
  puts "mean {1 2 3 4 5 6} = $mean"
  puts ""

  puts "if 3 in {1 2 3 4 5 6} = [in 3 $list]"
  puts "if 7 in {1 2 3 4 5 6} = [in 7 $list]"

  set x 3
  puts "if $x in range {1 6}   = [<= 1 $x 6]"
  set x 7
  puts "if $x in range {1 6}   = [<= 1 $x 6]"
  puts ""

  puts "is list $list sorted = [<= {*}$list]"
  set list {2 1 3 4 5 6}
  puts "is list $list sorted = [<= {*}$list]"

  puts ""
}

# a~.tl TEST_prefixop

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#https://wiki.tcl-lang.org/13920
#package require Tcl 8.5

# lmap, a built-in Tcl command introduced in version 8.6, iterates through items 
# in one or more lists and processes those items into a new list.

if {[info commands ::lmap] eq {}} {

  proc lmap args {
    
    set body [lindex $args end]
    set args [lrange $args 0 end-1]
    set n 0

    set pairs [list]

    foreach {varname listval} $args {
      upvar 1 $varname var$n
      lappend pairs var$n $listval
      incr n
    }

    set temp [list]

    foreach {*}$pairs {
      lappend temp [uplevel 1 $body]
    }

    set temp
  }
  
}
# ==============================================================================

# Emulate append feature for pre Tcl 8.6

# HaO 2016-07-01: With TIP #331 for Tcl 8.6, lset may add to lists:

# % set l {1 {1 2}}
# 1 {1 2}
# % lset l 1 end+1 3
# % set l
# 1 {1 2 3}

# Only this feature may be added to the Tcl 8.5 version of lset by the following 
# script: 
# (I implemented this for Tcl8.5.7 (eTCL for Windows CE)) (this might work for 
# Tcl 8.4 which is untested by me)

#-------------------------------------------------------------------------------

#if { [package vsatisfies [info patchlevel] 8.5-8.6] } {}
#jimtcl
if {1} {

  # версия удовлетворят условию min-max (т.е >= min и < max)
  #
  #puts "package vsatisfies  = OK"

  rename lset lset_ori
  
  proc lset {listname args} {

    upvar 1 $listname list

    # > Decode listified or not listified arguments

    if {2 == [llength $args]} {
      lassign $args indexlist newvalue
    } else {
      set newvalue [lindex $args end]
      set indexlist [lrange $args 0 end-1]
    }

    if {0 < [llength $indexlist]} {

      # > Check end index
      set endindex [lindex $indexlist end]
      set indexpath [lrange $indexlist 0 end-1]
      set sublist [lindex $list {*}$indexpath]
      # substitute end in endindex
      set endindex [string map [list end [expr {[llength $sublist]-1}]]\
                      $endindex]
      # evaluate any "+"
      set endindex [expr $endindex]

      if {$endindex == [llength $sublist]} {
        lappend sublist $newvalue
        lset list $indexpath $sublist
        return $list
      }
    }

    return [lset_ori list {*}$args]
  }

} else {

  #puts "package vsatisfies  = NOT !" ;# для проверки тут печатаем
}

################################################################################
#-------------------------------------------------------------------------------
# Маленький отладчик:

proc d+ {}  {
  proc dputs    s {puts stderr $s} ;# включаем реальную печать отладки
  #DebugOn
} 

proc d- {}  {
  proc dputs args {}            ;# печать-пустышка
}        


d- ;# initially, debug mode off


#-------------------------------------------------------------------------------

#interp alias {} pn {} puts -nonewline ;# простой алиас


# Вспомогательная процедурка для трюка со списками.
#
proc K {a b} {set a}

################################################################################
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc class_method {classname methodname vars body} {
#proc class_method {classname methodname args body} {}

   # puts "class_method: methodname = $methodname vars = $vars body = $body"

  if {$::__JIM__} {

    $classname method $methodname $vars $body
    #$classname method $methodname {*}$args $body
  
  } else {

    #oo::define $classname method $methodname AAA $body
    oo::define $classname method $methodname $vars $body
    #oo::define $classname method $methodname $args $body
  }

}
#-------------------------------------------------------------------------------
proc define_vars_for_OBJ {obj vars } {


  dict for {var val} $vars {
    
    $obj SET_$var $val
    variable $var
  }

  return
}
#-------------------------------------------------------------------------------
proc define_vars_for_CLASS {classname classvars} {


  dict for {var val} $classvars {
    
    if {$var == ";\#"} {continue} ;# пропускаем "комментарии"

    #puts "define_vars_for_CLASS: var = $var, val = $val"

    oo::define $classname variable $var     
    set $var $val
    
    #set body [subst -nocommand {return $$var}]
    
    oo::define $classname method GET_$var {} [subst -nocommand {return $$var}]
    oo::define $classname export GET_$var
    
    set body [subst -nocommand {set $var \$v}]
    #puts "body = $body"
    
    oo::define $classname method SET_$var {v} $body
    oo::define $classname export SET_$var

    oo::define $classname variable $var $val
  }

  return
}

##proc # args {}

#-------------------------------------------------------------------------------
proc SETGET {classname} {

  uplevel 1 $classname method set \{var val\} \{ set \$var \$val \}

  foreach var [$classname vars] {

    #puts stderr "SETGET for $classname: var = $var"

    if {$var == ";\#"} {continue} ;# пропускаем "комментарии"


    uplevel 1 $classname method SET_$var \{val\} \{set $var \$val\}
    uplevel 1 $classname method GET_$var \{\}    \{set $var \}
  }

  #puts stderr "SETGET for $classname: --------------------------- \n"

  return
}
#-------------------------------------------------------------------------------
proc class_create {mode classname {baseclasses {}} classvars constructorbody} {


  if {$::__JIM__} {
    #---------------------------------------------------------

    class $classname $baseclasses $classvars

    SETGET $classname

    $classname method constructor args $constructorbody
    #$classname method constructor {} $constructorbody

    #---------------------------------------------------------
  } else {
    #---------------------------------------------------------

    #if {$classname == "AccountNext"} {
    #  set classbody { superclass AccountMore }
    #} else {
    set classbody {}
    #}

    #foreach b $baseclasses {
    #  puts "b = $b"
      #append classbody "\{ superclass  $b \}"
    #}

    #
    #superclass POP
    #puts "classbody = $classbody"

    oo::class create $classname  $classbody
 
    #----------------------------------------

    #puts "classvars = $classvars"

    define_vars_for_CLASS $classname $classvars 

    #----------------------------------------

    set    fullbody {}

    if {$mode == 1} {

      #puts "info object variables  = [info object variables $tst]"
      #puts "info object vars       = [info object vars      $tst]"
      
      # подготавливаем конструктор --------------
      
      #if {$classname == "AccountNext"} {
      #  set body2 {next {*}$args}
      #} else {
      set body2 {}
      #}
      
      set body1 {
        
        set cl [self class]
        
        set classvars    [info class  variables    $cl]
        set superclasses [info class  superclasses $cl]
        
        puts "info class  variables    = $classvars"
        puts "info class  superclasses  = $superclasses"
        puts "constructor args = $args"
        
        define_vars_for_OBJ [self] $classvars
        define_vars_for_OBJ [self] {*}$args
        
        puts "cl = $cl"
        #if {$cl == "::AccountNext"} {
        #  set nextvars [info class  variables AccountMore]
        #  puts "..................  nextvars = $nextvars"
        #  define_vars_for_OBJ [self] $nextvars
        #} 
      }

      append fullbody $body2
      append fullbody $body1
    }

    append fullbody $constructorbody

    #-------------------------------------------

    #foreach b $baseclasses {
    #  puts "b = $b"
      #append classbody "\{ superclass  $b \}"
    #}

    oo::define $classname superclass {*}$baseclasses    

    # теперь делаеи  конструктор ---------------

    #puts "constructor_fullbody = $fullbody"

    oo::define $classname constructor {args} $fullbody

    #----------------------------------------------------
  } 

}
#--------------------------------------------------------
proc SUPER {method args} {

  if {$::__JIM__} {
    uplevel 1 super $method {*}$args
  } else {
    uplevel 1 next {*}$args
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# a-dict.tl
#
#alias SET dict_set
#alias GET dict_get

# if {$::__JIM__} {

#   rename dict_set SET_old
#   rename dict_get GET_old

# } else {

# #   rename SET SET_old
# #   rename GET GET_old
# }

#-------------------------------------------------------------------------------
proc OBJ_TYPE {o} {

  #if [string equal -length  8 $o "::G_DICT"]    {return 0}
  if [string equal -length  4 $o "::G_"]    {return 0}

  if [string equal -length 11 $o "<reference."] {return 1}
  
  if [string equal -length  6 $o "::oo::"] {return 2}
  
}
#-------------------------------------------------------------------------------
proc SET {args} {

  #puts stderr "SET: args = $args"

  set d    [lindex $args 0]

  #set is_obj [info object isa object $d] ;# объект или словарь?

  set type [OBJ_TYPE $d];

  #puts "SET: d = $d   type = $type"
  # 
  # > SET: d = ::G_DICT_184
  # a = <reference.<Account>.00000000000000000000>
  # > SET: d = ::oo::Obj15

  if {$type == 0} { ;# dictionary

    #uplevel 1 SET_old $args
    uplevel 1 dict_set $args

  } else { ;# object JIM or TCL

    set key  [lindex $args 1]
    set val  [lindex $args 2]

    set len [llength $val]

    if {$type == 1} {
      #puts "SET for JIM: d= $d key= $key val= $val   len= $len"

      #$d SET_$key $val

      if {$len == 1} {
        $d eval "set $key $val"
      } else {
        $d eval "set $key \{ $val \}"
      }

    } else {
      $d SET_$key $val
    }

    #$d SET_$key $val
  }
}
# ----------------------------------------------
# 
# g_stru.jm _01_test 10 10
# g-corA.tl:542: Error: invalid command name ""
# 
#-------------------------------------------------------------------------------
proc GET {args} {

  #puts stderr "GET: args = $args"

  set d    [lindex $args 0]

  #set is_obj [info object isa object $d]

  set type [OBJ_TYPE $d];

  if {$type == 0} { ;# dictionary

    #uplevel 1 GET_old $args
    uplevel 1 dict_get $args

  } else { ;# object JIM ot TCL

    set key  [lindex $args 1]
    #set val  [lindex $args 2]

    if {$type == 1} {
      #puts stderr "GET (for JIM): key= $key val= $val"

      return [$d eval "set $key"]
    } else {
      return [$d GET_$key]
    }

    #return [$d GET_$key]
  }

}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc SELF {} {


  if {$::__JIM__} {

    #upvar self self_local
    #return $self_local

    uplevel 1 {return $self} 
  } else {

    uplevel 1 {return [self]} 
  }

}
# ==============================================================================
#-------------------------------------------------------------------------------
