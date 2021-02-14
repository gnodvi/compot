# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

namespace eval ::joy {}

set ::joy::debug 0

set     ::tdebug 0


#set ::joy_sources {} ;# для временного хранения исходников ?

set       ::defined_glob {}
array set ::builtin_glob {}

#set ::ST {}  ;# The VM stack,  datastack - уже определен


set ::print_defines 0

#-------------------------------------------------------------------------------

# А это уже внутренние, определяемые функции:
# 
# Core Lib: parts of Joy written in Apathy.
#
# This has many advantages: we are lazy, to implement a number of
# combinators and operators in Joy is simpler.

# Another advantage is that we are sure to don't break continuations
# nor tail recursion, because we directly used the language to
# implement itself.
# The side effect is that's slow... but again, we don't search the speed ;)

#-------------------------------------------------------------------------------

# record define JOY_T {

#   # current    ;#
#   #ip         ;#

#   #len        ;#

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   #local      ;#

#   # baza_user_types 
#   # baza_user_symbols 

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   #auxstack   ;# для отключения рекурсии в IFTE ?
#   #retstack   ;# для оптимизации хвостовой рекурсии ?

# }

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc joy_create_NEW {} {

  set j [dict_create]
  

  #   #$j configure -defined_locl  {} ;# определенные фунции Joy;
  #   #$j configure -builtin_dict  {} ;# TCL-процедуры с префиксами;
  #   #$j configure -datastack     {} ;# стек данных
   
  dict_set $j      "ip"        0 ;# оставить для имитации паралельности?
  dict_set $j      "len"       0 ;# 
  dict_set $j      "current"  {} ;# програмный код
  
  #   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  dict_set $j  "baza_user_types"   [list_create_num_val] ;# спец.обрабока (переменные)
  dict_set $j  "baza_user_symbols" [list_create_num_val]  
  dict_set $j  "local" {} ;# локальные переменые?
  
  
  dict_set $j  "auxstack" {}  ;# [list_create]  ;# для отключения рекурсии в IFTE ?
  dict_set $j  "retstack" {}  ;# для оптимизации хвостовой рекурсии ?
  
  return $j
}
#-------------------------------------------------------------------------------
proc v3_init_null {} {


  #-----------------------------------------------------------------------------
  # положить элемент в дата-стек
  #-----------------------------------------------------------------------------
  # 
  proc push {ele} {
    
    #set s [joy_datastack_get_ ]
    #lappend s $ele
    #joy_datastack_set_ $s
    
    #lappend [VGET $::ctx "datastack"] $ele
    lappend ::ST $ele
    
  }
  #-----------------------------------------------------------------------------
  # 
  proc pop {} {
    
    if {![llength [joy_datastack_get_ ]]} {
      
      error "Stack underflow"
    }
    
    # получить последний элемент стека
    set t [lindex [joy_datastack_get_ ] end]
    
    # proc K {x y} {set x}
    #
    # set s [lreplace [K [set ${ctx}::datastack] [unset ${ctx}::datastack]] end end]
    #
    # тут видимо такой хитрожопый трюк, чтобы удалить этот последний элемент стека:
    # 
    # 1) запихиваем старый стек в К-процедуру первым параметром
    # 2) при формимровании второго параметра удаляем стек
    # 3) в вернувшемся из К-процедуры старом стеке заменяем последний элемент НИЧЕМ
    
    
    set s [lreplace [joy_datastack_get_ ] end end]
    
    joy_datastack_set_ $s
    
    # возвращаем взятый последний элемент стека
    return $t
  }
  #-----------------------------------------------------------------------------
  

  #set joys [joy_create_] 

  #joy_builtin_set_all_globals_  

  #   joy_builtin_set_item_ "+"
  #   joy_builtin_set_item_ "-"
  #   joy_builtin_set_item_ "*"
  #   joy_builtin_set_item_ "/"
  #   joy_builtin_set_item_ "@"
  
  #   joy_builtin_set_item_ "^"

 
  set ::ST {}  ;# The VM stack

  set ::ctx_NEW [joy_create_NEW] 

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# proc dict_create {} {

#   set pd [MAKE_GLOBAL_NAME]
    
#   #dict set $pi  FIT {}
#   #dict set $pi  PRG {}
    
#   return $pd ;# "указатель" (глобальное имя)
# }
#------------------------------------------------------
proc joy-push-type {type val} {

  if {$::_NEW} {

    # !!!!!!!!!!!!!! неправильный словарь !!!! надо как в a_dict !!
    #
    #set obj [dict_create]

    #dict set $obj  TYP $type
    #dict set $obj  VAL $val

  } else {

    set obj [list $type $val]
  }

  push  $obj

}
#------------------------------------------------------
proc parse_op {op  &op_type &op_vals} {

  USE_REFS

  if {$::_NEW} {
  } else {

    set op_type  [lindex $op 0]      
    set op_vals  [lindex $op 1] 
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Joy->Tcl Data conversion


#-------------------------------------------------------------------------------
# Joy->Tcl integer conversion. Nothing to do...
#-------------------------------------------------------------------------------
proc joy->v3-integer data {

  return $data
}
#-------------------------------------------------------------------------------
# Joy->Tcl float conversion. Nothing to do...
#-------------------------------------------------------------------------------
proc joy->v3-float data {

  return $data
}
#-------------------------------------------------------------------------------
# Joy->Tcl string conversion.
#-------------------------------------------------------------------------------
proc joy->v3-string data {

  subst -nocommands -novariables [string range $data 1 end-1]
}
#-------------------------------------------------------------------------------
# Joy->Tcl char conversion. Internally stored as integers.
#-------------------------------------------------------------------------------
proc joy->v3-char data {

  scan [string index $data 1] %c
}
#-------------------------------------------------------------------------------
# Joy->Tcl symbols convertion.
# We use late binding, so we just return the name of
# the symbol.
#-------------------------------------------------------------------------------
proc joy->v3-symbol data {

  return $data
}
#-------------------------------------------------------------------------------
# Joy->Tcl list conversion. Using recursiob is easy.
#-------------------------------------------------------------------------------
proc joy->v3-list data {

  set list {}
  
  foreach t [joy-tokenize-no-comments [string range $data 1 end-1]] {

    lappend list [list [joy-token-type $t] [convert_joy_to_33 $t]]
  }

  return $list
}
#-------------------------------------------------------------------------------
# Joy->Tcl truth value conversion.
#-------------------------------------------------------------------------------
proc joy->v3-truth data {

  expr {$data eq {true}}
}
#-------------------------------------------------------------------------------
# Joy->Tcl locals capture conversion.
#-------------------------------------------------------------------------------
proc joy->v3-capture data {

  set list {}
  
  foreach t [split [string range $data 1 end-1]] {
    lappend list $t
  }

  return $list
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Convert a Joy literal to the 33 representation (list)
#-------------------------------------------------------------------------------
proc convert_joy_to_33 data { 

  set tt [joy-token-type $data]

  joy->v3-$tt $data
}
#-------------------------------------------------------------------------------
# Tcl->Joy Data conversion

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Tcl->Joy integer conversion. Nothing to do...
#-------------------------------------------------------------------------------
proc v3->joy-integer data {

  return $data
}
#-------------------------------------------------------------------------------
# Tcl->Joy float conversion. Nothing to do...
#-------------------------------------------------------------------------------
proc v3->joy-float data {

  return $data
}
#-------------------------------------------------------------------------------
# Tcl->Joy string conversion.
#-------------------------------------------------------------------------------
proc v3->joy-string data {

  return \"$data\"
}
#-------------------------------------------------------------------------------
# Tcl->Joy char conversion.
#-------------------------------------------------------------------------------
proc v3->joy-char data {

  format "'%c" $data
}
#-------------------------------------------------------------------------------
# Tcl->Joy symbols convertion.
# We use late binding, so we just return the name of
# the symbol.
#-------------------------------------------------------------------------------
proc v3->joy-symbol data {

  return $data
}
#------------------------------------------------------------------------------
# Tcl->Joy list conversion. Using recursion is easy.
#-------------------------------------------------------------------------------
proc v3->joy-list data {

  set joylist {[}

  foreach t $data {
    append joylist [v3->joy $t] { }
  }

  if {[string length $joylist] != 1} {
    set joylist "[string range $joylist 0 end-1]"
  }
    
  append joylist {]}

  return $joylist
}
#-------------------------------------------------------------------------------
# Tcl->Joy truth type conversion.
#-------------------------------------------------------------------------------
proc v3->joy-truth data {

  if {$data} {
    return "true"
  } else {
    return "false"
  }

}
#-------------------------------------------------------------------------------
# Tcl->Joy locals capture conversion.
#-------------------------------------------------------------------------------
proc v3->joy-capture data {

  set joycap {(}

  foreach t $data {
    append joycap $t { }
  }

  if {[string length $joycap] != 1} {
    set joycap "[string range $joycap 0 end-1]"
  }

  append joycap {)}
}
#-------------------------------------------------------------------------------
# Convert
#-------------------------------------------------------------------------------
proc v3->joy data {

  set tt      [joy-objtype $data]

  v3->joy-$tt [joy-objval  $data]

}
#-------------------------------------------------------------------------------
proc joy_functext_to_v3_code {functext} {

  # functext - это простой исходник Joy в чистом виде, без определений !
  # 

  set code {} ;# сюда будем складывать код в формате v3 : (тип данные).
    
  foreach t $functext { 
         
    set tt [joy-token-type $t]
    
    if {$tt eq {comment}} continue
    
    lappend code [list $tt [convert_joy_to_33 $t]]
  }

  return $code
}
#-------------------------------------------------------------------------------

set ::_NEW 0


#-------------------------------------------------------------------------------
# Access the two different fields of Tcl representation of Joy objects
#-------------------------------------------------------------------------------
proc joy-objtype obj {

  if {$::_NEW} {

    set type [dict get [set $obj] TYP]
  } else {

    set type [lindex $obj 0]
  }

  return $type
}
#------------------------------------------------------
proc joy-objval  obj {

  if {$::_NEW} {

    set type [dict get [set $obj] VAL]
  } else {

    set val [lindex $obj 1]
  }

  return $val
}
# ------------------------------------------------------------------------------
proc  convert_33_to_22 {prg_33  &prg_22} {

  USE_REFS


  foreach a $prg_33 {

    set a_v [joy-objval  $a]
    set a_t [joy-objtype $a]

    if {$a_t eq "list"} { 

      lappend   prg_22  {*}"BEG "
      convert_33_to_22  $a_v  prg_22
      lappend   prg_22  {*}" END"

    } elseif {$a_t eq "string"} {

      lappend   prg_22  {*}"BEG "
      #convert_33_to_22  $a_v  prg_22
      #lappend   prg_22  {*}" THISISSTRING"      
      lappend   prg_22  {*}$a_v      
      lappend   prg_22  {*}" END"

    } else {

      lappend  prg_22 "$a_v"
    }

  }

  return
}
#-------------------------------------------------------------------------------
proc translate_ndict_33_to_22 {&ndict} {

  USE_REFS

  dict for {symbol code} $ndict {

    #puts "symbol= $symbol"
    #puts "code33= $code"

    set prg_22 {}
    convert_33_to_22  $code  prg_22

    #puts "code22= $prg_22"
    #puts ""

    dict set ndict $symbol $prg_22
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
proc joy_ip_set_ {ip} {


  #$::ctx configure -ip $ip

  dict_set $::ctx_NEW "ip" $ip

}
#-------------------------------------------------
#
proc joy_ip_get_ {} {

 # return [$::ctx cget -ip]

  return [dict_get $::ctx_NEW "ip"]
}
#-------------------------------------------------
#
proc joy_ip_incr_ {} {

  #incr [VGET $::ctx "ip"] ;# 

  set  ip [dict_get $::ctx_NEW "ip"]
  incr ip
  dict_set $::ctx_NEW "ip" $ip
}
#-------------------------------------------------------------------------------
#-------------------------------------------------
#
proc joy_len_set_ {len} {


  #$::ctx configure -len $len

  dict_set $::ctx_NEW "len" $len

}
#-------------------------------------------------
proc joy_len_get_ {} {


  #return [$::ctx cget -len]

  return [dict_get $::ctx_NEW "len"]

}
#-------------------------------------------------
proc v3_add_to_defined_glob {symbol code} {

  set d $::defined_glob

  dict set d  $symbol $code

  set ::defined_glob $d

}
#-------------------------------------------------
proc v3_defined_get_by_name {symbol} {


  return [dict get $::defined_glob  $symbol]
}
#-------------------------------------------------
proc v3_defined_is_name_exist {symbol} {


  return [dict exist $::defined_glob $symbol]
}
#-------------------------------------------------
#-------------------------------------------------
proc v3_current_set {proglist} {


  #$::ctx configure -current $proglist

  dict_set $::ctx_NEW "current" $proglist

  joy_len_set_ [llength $proglist]
}
#-------------------------------------------------
proc v3_current_get {} {


  #set c  [$::ctx cget -current]

  set c  [dict_get $::ctx_NEW "current"]

  return $c
}
#-------------------------------------------------
#-------------------------------------------------
#
proc joy_datastack_set_ {datastack} {

  #$::ctx configure -datastack $datastack
  set ::ST $datastack

}
#-------------------------------------------------
#
proc joy_datastack_get_ {} {

  #return [$::ctx cget -datastack]
  return $::ST

}
#-------------------------------------------------------------------------------
# что за странная функция ???
# 
# proc joy_builtin_set_all_globals_ {} {


#   #array set builtin_copy [array get ::builtin_glob]
#   set d {}

#   foreach key [array names ::builtin_glob] {

#     dict set d $key $::builtin_glob($key)
#   }


#   set ::builtin_dict  $d
  
# }
#-------------------------------------------------------------------------------
# proc joy_builtin_get_all {} {


#   set ret [array names ::builtin_glob]

#   return $ret
# }
#-------------------------------------------------------------------------------
# proc joy_builtin_set_item_ {name} {


#   set b [$::ctx cget -builtin_dict]

#   if {[info exists ::builtin_glob($name)]} {

#     set prog ::builtin_glob($name)

#   } else {
#     puts ""
#     puts "!! joy_builtin_set_item_ : DON'T exist NAME = $name !!!"
#     puts ""

#     return
#   }

#   dict set b  $name $prog ;#

#   $::ctx configure -builtin_dict $b
  
# }
#-------------------------------------------------------------------------------
# proc joy_builtin_get_item_ {name} {


#   return $::builtin_glob($name)
# }
#-------------------------------------------------------------------------------
# proc is_builtin_name_exist {name} {

#   set b  $::builtin_dict
 

#   if {! [dict exists $b $name]} {

#     #puts ""
#     #puts "run_builtin_func: DON'T exist SYMBOL = $name"
#     #puts "run_builtin_func: builtin = $b"
#     #puts ""
    
#     #foreach key [array names ::builtin_glob] {
#     #  puts "$key -> ::builtin_glob($key) "
#     #}

#     #puts ""

#     return false;
#     #return {};
#   }
 

#   return true
# }
#-------------------------------------------------------------------------------
proc v3_find_tclproc {name} {


  #------------------------------------------
  #   foreach i $::tclproclist {

  #     if {$i == $name} {
  
  #       return $i
  #     }
  #   }
  
  #   return {};
  #------------------------------------------


  #if {! [is_builtin_name_exist $name]} {}
    
  if {! [info exists ::builtin_glob($name)]} {
    
    return {};
  }


  # если есть уже во встроенных функциях, то 
  # вызываем TCL-функцию
  
  Debug "          FUNC builtin ($name)"
  

  #set F [joy_builtin_get_item_ $name]
  set F $::builtin_glob($name)


  #puts "F      = $F"
  #puts "name = $name"

  #------------------------------------------


  return $F
}
#-------------------------------------------------------------------------------
proc run_builtin_func {symbol} {


  set F [v3_find_tclproc  $symbol]

  if {$F == {}} {

    return false;
  }


  $F $symbol 
  
  return true;
  
}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc joy_add_defarr {&defarr} {

  USE_REFS

  set ip      [joy_ip_get_ ]
  #set ip  [joy_len_get_ ]   ;# нет, так не проходит


  dict for {name code} $defarr {

    # для include определения обычных функций можно вносить в любое место
    # массива, а вот для основного кода {}, надо "вставлять" внутрь ..

    if {$name == {}} {
      
      # предполагается, что это основная программ MAIN

      # http://wiki.tcl.tk/17158
      # One might say {*} is the inverse function of list:
      # {*}[list a b c] <==> a b c
      #
      v3_current_set  [linsert [v3_current_get ] $ip {*}$code]

    } else {

      # а это описание функций-процедур
      # 
      v3_add_to_defined_glob    $name $code
    }
  }

}
#-------------------------------------------------------------------------------
# перезаписываем локальный словарь в глобальный массив
# 
#-------------------------------------------------------------------------------
proc v3_add_to_defined {&namecodedict} {

  USE_REFS

  dict for {name code} $namecodedict {

    v3_add_to_defined_glob  $name $code ;# записываем в массив "define"
                                           # под именем "symbol" код "code"
  }

  return
}
#-------------------------------------------------------------------------------
# перезаписываем локальный словарь в глобальный массив
# и также определяем стартовое (основное) имя - пустое имя {}
#-------------------------------------------------------------------------------
proc v3_add_to_defined_and_set_current_ret {&namecodedict} {

  USE_REFS

  v3_add_to_defined  namecodedict

  # делаем код верхнего уровня (который под пустым именем) как "current".
  # ??? всегда ??? тут видимо из-за добавки RET !!

  v3_add_ret_and_set_as_curent  [v3_defined_get_by_name {}]

}
#-------------------------------------------------------------------------------
proc v3_add_code {name code} {


  set defarr [dict create]  ;# обнулили словарь
  
  dict set defarr  $name $code
  
  # а, ну где указатель текущий стоит - туда и вставляет
  #
  joy_add_defarr  defarr
  
  # уже вставили. а теперь обновим указатель
  #
  joy_ip_set_  [joy_len_get_ ] 

}
#-------------------------------------------------------------------------------
proc run_builtin_or_defined_func {symbol} {


  if {[run_builtin_func $symbol]} {

    # если есть уже во встроенных функциях, то 
    # вызываем TCL-функцию

  } elseif {[v3_defined_is_name_exist $symbol]} {

    # если символ определен ранее в это программе, то
    # вызываем тело процедуры в виде JOY-функции

    Debug "          FUNC defined ($symbol)"

    set F [v3_defined_get_by_name $symbol]

    set len [joy-call  $F] 

  } else { 

    puts ""
    win_set_color RED
    puts  "ERROR ......... run_builtin_or_defined_func"
    win_set_color DEFAULT

    puts ""
    puts  "datastack: $::ST"
    puts ""
    puts  "Definition needed for symbol: '$symbol'"

    #win_set_color DEFAULT
    puts ""

    error ".... run_builtin_or_defined_func"
  }
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc joy-check-stack {args} {

  set datastack [joy_datastack_get_ ]

  set len       [llength $args]        ;# сколько параметров для оператора нужно
  set stacklen  [llength $datastack]
  
  if {[llength $datastack] < $len} {

    #puts ""
    #puts ".... joy-check-stack ERROR !!"
    #puts ".... stacklen= $stacklen"
    #puts ""
    # надо подумать, что тут лучше:
    # 1) пропустить плохой оператор и идти дальше (как в progen)
    # 2) попробовать его исправить?
    # 3) перехватить прерывание и вообще не выполнять прогу (с плохим фитнесом)
    # exit
    error "joy-check-stack:  Stack underflow"
  }
  
  # проверим часть стека (верхнюю длиной len) на наличие нужных типов:

  for {set i 0} {$i < $len} {incr i} {

    set types [lindex $args      [expr {$len      - $i - 1}]]
    set     e [lindex $datastack [expr {$stacklen - $i - 1}]]

    if {[llength $types] && [lsearch -exact $types [joy-objtype $e]] == -1}\
      {
        puts ""
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts "Type mismatch. Expected '$types', got '[joy-objtype $e]'"
        puts "e = $e"
        puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        puts ""
        error "ERROR: joy-check-stack \n" ;# инициируем статус ошибки
      }
  }

}
#-------------------------------------------------------------------------------
proc check_defined_user_name_prog {baza_user_types   name vals} {


  foreach b $baza_user_types {

    set user_name [lindex $b 0]
    set user_prog [lindex $b 1]

    if {[string match $user_name $name]} {

      #$user_prog $::ctx $vals
      $user_prog $vals

      return true
    } 
  }

  return false    
}
#-------------------------------------------------------------------------------
proc run_v3_current_prog_from_begin {} {

  #set current [v3_current_get ]

  # joy-run_from_begin
  # идем циклом по буферу команд слева направо
      
  joy_ip_set_ 0 ;# !! ??
  #set ip 0

  #set len [joy_len_get_]

  while {1} {

    set ip  [joy_ip_get_ ] ;# получили текущий указатель на программу ??
    set len [joy_len_get_] ;# ??

    if {$ip >= $len} break
      
    # текущая программа, указатель и команда на выполнение
    #
    set current [v3_current_get ] ;# ?? меняется при чтении с файла??

    #set ip      [joy_ip_get_ ]

    set op      [lindex $current $ip]      
    

    if {$::joy::debug} {

      puts ""
      print_retstate  
      gena_show_joylist  [joy_datastack_get_ ] "DATASTACK: "  -1  GREEN DEFAULT

      print_curstate 
      #puts ""
    }

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    joy_ip_incr_  ;# уже заранее увеличим указатель 
    #incr ip

    #  чтобы, если уйдем на подфункцию, сохранить это состояние новым
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # а как еж сделано в простом случае i-варианта ?
    # там рекурсивно выполняется встроенная функция!

    # теперь смотрим, что это за текущая операция:
    # 
    parse_op $op  op_type op_vals


    # ------------------------------------------------------
    #set user_types   [$::ctx.baza_user_types]
    set user_types [get_baza_user_types] 

    #set user_symbols [$::ctx.baza_user_symbols]
    set user_symbols [get_baza_user_symbols] 

    # ------------------------------------------------------
    if       {[check_defined_user_name_prog  $user_types $op_type $op_vals]} {

    } elseif {[string match "symbol" $op_type]}  { 

      set symbol $op_vals ;# здесь "символ", будем с ним разбираться
      
      if  {[check_defined_user_name_prog  $user_symbols $symbol $symbol]} {

      } else {

        run_builtin_or_defined_func  $symbol
      }

    # ------------------------------------------------------
    } else {
    # ------------------------------------------------------

      Debug "          -> STACK"
      push  $op 

    }
    # ------------------------------------------------------


  } ;# while end
  
}
#-------------------------------------------------------------------------------
#
################################################################################

# Joy language implementation for Tcl ...
# or better Apathy, a superset of Joy (Joy + locals).
#
# Copyright (C) 2004 Salvatore Sanfilippo <antirez@invece.org>
# All rights reserved
#
# Version: 10 Feb 2004 
#-------------------------------------------------------------------------------


#source "./i-cell.tl"

#-------------------------------------------------------------------------------
proc JOY_init_builtins_B {} {

  #
  #
  # Будем делать встраиваемые функции
  
  #source "s-vera.tl" ;# самые основные (например математические)

  #source "j-incl.tl"

}
#-------------------------------------------------------------------------------

#JOY_init_builtins ;# лучше вставим это в стартовую инициализацию

#-------------------------------------------------------------------------------
proc joy-set-auxstack {auxstack} {

  #$::ctx configure -auxstack $auxstack

  dict_set $::ctx_NEW "auxstack" $auxstack
}
#-------------------------------------------------
proc joy-get-auxstack {} {

  # return [$::ctx cget -auxstack]

  return [dict_get $::ctx_NEW "auxstack"]
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc joy-set-retstack {retstack} {

  #$::ctx configure -retstack $retstack

  dict_set $::ctx_NEW "retstack" $retstack
}
#-------------------------------------------------
proc joy-get-retstack {} {

  #return [$::ctx cget -retstack]

  return [dict_get $::ctx_NEW "retstack"]
}
#-------------------------------------------------
proc joy-retstack-lappend {l} {

  set s [joy-get-retstack ]

  lappend s $l

  joy-set-retstack $s

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# locals ... переменные?

#-------------------------------------------------------------------------------

proc joy-set_locals {arr} {

  #$::ctx configure -local $arr

  dict_set $::ctx_NEW "local" $arr

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc joy-get_locals {} {

  #return [$::ctx cget -local]

  return [dict_get $::ctx_NEW "local"]

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc joy-locals-is-exist {sym} {

  #set d  [$::ctx cget -defined_locl]
  set d  $::defined_glob

  return [dict exist $d $sym]

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc joy-set-local_item {item obj} {

  set l [joy-get_locals]

  dict set l  $item $obj

  joy-set_locals $l

}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc joy-get-local_item {item} {


  set l [joy-get_locals]

  if {[catch {set i [dict get $l $item]} err]} {
    
    error "Local '$local' does not exists"
  } 
  
  return $i
    
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Capture locals. Quite slow, may be optimized.

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc joy-capture_locals {locals} {

  #set len_datastack [llength [set ${ctx}::datastack]]
  set len_datastack [llength [joy_datastack_get_ ]]

  set len_locals    [llength $locals]

  #if {[llength [set ${ctx}::datastack]] < [llength $locals]} {}

  if {$len_datastack < $len_locals} {
    error "Stack underflow in locals capture"
  }

  for {set i [expr {[llength $locals]-1}]} {$i >= 0} {incr i -1} {

    joy-set-local_item [lindex $locals $i] [pop ]
  }

}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc type_proc_capture {op_vals} {

  Debug "          CAPTURE -> $op_vals"

  joy-capture_locals $op_vals
     
}
#-------------------------------------------------------------------------------
proc symb_proc_capture {symbol} {


  push  [joy-get-local_item  [string range $symbol 1 end]] 
       
}
#-------------------------------------------------------------------------------
proc get_ctx_list {name} {


  set list_name  [dict_get $::ctx_NEW $name]
  
  #puts stderr ""
  #puts stderr "list_name = $list_name"

  set list   [set $list_name]

  #puts stderr "list = $list"

  return $list ;# список
}
#-------------------------------------------------------------------------------
proc get_baza_user_types {} {


  return [get_ctx_list "baza_user_types"]

}
#-------------------------------------------------------------------------------
proc joy_add_user_types_ {itemlist} {


  #   if (0) {  
  #     set s [$::ctx.baza_user_types]  
  #     lappend s $itemlist  
  #     $::ctx configure -baza_user_types $s  
  #   } else {
  
  # Теперь, наверное, можно заменить на просто:
  #

  #lappend [VGET $::ctx "baza_user_types"] $itemlist
  
  lappend [dict_get $::ctx_NEW "baza_user_types"] $itemlist

  #check_user_types 

  #   }

}
#-------------------------------------------------------------------------------
proc joy_add_user_symbols_ {itemlist} {

  #   if {0} {
  
  #     set s [$::ctx.baza_user_symbols]
  #     lappend s $itemlist
  #     $::ctx configure -baza_user_symbols $s
  
  #   } else {
  
  # почему енльзя явно по имену списка добавить элемнт ?
  # 
  
  #lappend [VGET $::ctx "baza_user_symbols"] $itemlist

  lappend [dict_get $::ctx_NEW "baza_user_symbols"] $itemlist
  #   }
    
}
#-------------------------------------------------------------------------------
proc get_baza_user_symbols {} {


  return [get_ctx_list "baza_user_symbols"]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc v3_init_SIMP {} {

  v3_init_null  ;# без встроенных DEFINE

  # добавим поодержку локальных переменных (в стандарте нет, но так
  # реализация удобнее ?
  # 

  joy_add_user_types_   {"capture" type_proc_capture}
  joy_add_user_symbols_ {"$*"      symb_proc_capture}

  return 
}
#-------------------------------------------------------------------------------
# устанавливаем программу в текущий контекст для выполнения
# но без текущего указателя "ip" ??
#-------------------------------------------------------------------------------
proc proglist_add_ret {&proglist} {

  USE_REFS

  set is_proglist_empty [expr {[llength $proglist] == 0}]

  set is_endop_ret [expr {\
                            [lindex $proglist end 0] eq "symbol" && \
                            [lindex $proglist end 1] eq "ret"} \
                     ]

  #puts -nonewline  stderr "joy-set-current: "
  #puts -nonewline  stderr "($is_proglist_empty $is_endop_ret) "

  # если программка пустая или не кончается на RET, то добавим этот RET

  if {$is_proglist_empty || !$is_endop_ret} \
    {
      #puts -nonewline  stderr "add RET to |$proglist|"
      lappend proglist [list symbol ret]
    }

  return
}
#-------------------------------------------------------------------------------
proc v3_add_ret_and_set_as_curent {proglist} {

  # добавим в конец RET (если программка пустая или не кончается на RET)
  # 
  proglist_add_ret  proglist

  # реально устанавливаем в контекст
  # 
  v3_current_set  $proglist

}
#-------------------------------------------------------------------------------
proc joy-dump-state ctx {
  
  puts "-----STATE DUMP------"

#   puts "RETSTACK : [joy-get-retstack ]"
#   puts "DATASTACK: [joy_datastack_get_ ]"
#   puts "AUXSTACK : [joy-get-auxstack ]"

  #set current [v3_current_get ]

  puts "CURRENT  : [v3_current_get ]"
  puts "IP       : [joy_ip_get_ ]"
  puts "LEN      : [joy_len_get_]"

  puts "---------END---------"

  puts {}
}
#-------------------------------------------------------------------------------
proc joy-get-continuation {} {

  set cont {}

  lappend cont [list string  [joy-get-retstack ]]
  lappend cont [list list    [joy_datastack_get_ ]]
  lappend cont [list list    [joy-get-auxstack ]]
  lappend cont [list list    [v3_current_get ]]
  lappend cont [list integer [joy_ip_get_ ]]
  lappend cont [list integer [joy_len_get_]]

  #lappend cont [list string  [array get ${ctx}::local]]
  lappend cont [list string  [joy-get_locals ]

  return [list list $cont]
}
#-------------------------------------------------
proc joy-set-continuation {cont} {

  foreach {retstack datastack auxstack current ip len locals} [joy-objval $cont] break

  joy-set-retstack   [joy-objval $retstack]
  joy_datastack_set_ [joy-objval $datastack]
  joy-set-auxstack   [joy-objval $auxstack]
  v3_add_ret_and_set_as_curent   [joy-objval $current]
  joy_ip_set_        [joy-objval $ip]
  joy_len_set_       [joy-objval $len]

  #array unset ${ctx}::local
  #array set   ${ctx}::local [joy-objval $locals]
  #
  joy-set_locals $locals

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# добавим определения (словарь)  функций в массив определений, 
# и определим основной код
#-------------------------------------------------------------------------------
proc joy-compile {text} {

  if {$::joy::debug} {
    
    puts "joy-compile ... "
  }

  # компилируем joy-программу в словарь tcl-списков
  # 
  set namecodedict [joy-compile_to_namecodedict $text]

  v3_add_to_defined_and_set_current_ret  namecodedict

}
#-------------------------------------------------------------------------------
# отдельная добавлялка для INCLUDE:
#
# добавим определения (словарь)  функций в массив определений, а основной код 
# вставим в нужное текущее место:
#-------------------------------------------------------------------------------
proc joy-compile_add {add_text} {

  # компилируем joy-программу в словарь tcl-списков
  # 
  set defarr [joy-compile_to_namecodedict $add_text]

  joy_add_defarr  defarr

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Runtime API

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# The aux stack is just a trick to hold additional environment
# information to avoid recursive calls to the interpreter.
# It is used by 'ifte' to save the true/false quoted programs
# while the 'condition' quoted program is running.

#-------------------------------------------------------------------------------
proc joy-auxpush {} {

  set s [joy-get-auxstack ]

  lappend s  [pop ]

  joy-set-auxstack $s

  #lappend ${ctx}::auxstack [joy-pop ]
}
#-------------------------------------------------------------------------------
proc joy-auxpop {} {


  if {![llength [joy-get-auxstack ]]} {

    error "Aux Stack underflow"
  }

  set t [lindex [joy-get-auxstack ]  end]

  set s [lreplace [joy-get-auxstack] end end]

  joy_datastack_set_ $s


  push  $t
}
#-------------------------------------------------------------------------------
# 'size' operation for aggregate types.
#-------------------------------------------------------------------------------
proc joy-objsize obj {

  #foreach {type val} $obj break  # ??????
  #
  parse_op $obj  type val

  switch -- $type {

    string {return [string length $val]}
    list   {return [      llength $val]}

    default {error "joy-objsize called against non-aggregate type"}
  }
}
#-------------------------------------------------------------------------------
# 'at' operation for aggregate types.
#-------------------------------------------------------------------------------
proc joy-objat {obj idx} {

  #foreach {type val} $obj break ;# ??????
  #
  parse_op $obj  type val
  
  set len [joy-objsize $obj]

  if {$idx >= $len} {
    error "smaller index needed for at"
  }

  switch -- $type {
    string {return [list char [scan [string index $val $idx] %c]]}

    list {return [lindex $val $idx]}

    default {error "joy-objat called against non-aggregate type"}
  }

}
#-------------------------------------------------------------------------------
# return an empty aggregate of the same type of 'obj'.
#-------------------------------------------------------------------------------
proc joy-objempty obj {

  #foreach {type val} $obj break  ;# ??????
  #
  parse_op $obj  type val
  
  switch -- $type {
    string {return [list string {}]}
    list {return [list list {}]}
    default {error "joy-emtpy called against non-aggregate type"}
  }
  
}
#-------------------------------------------------------------------------------
# return the cons between the non-aggregate 'e' and the aggregate 'l'
#-------------------------------------------------------------------------------
proc joy-objcons {e l} {

  foreach {etype eval} $e break  ;# ??????
  foreach {ltype lval} $l break  ;# ??????
  
  switch -- $ltype {

    string {return [list string [format %c $eval]$lval]}
    list   {return [list list [concat [list $e] $lval]]}

    default {error "joy-objcons called against non-aggregate type"}
  }

}
#-------------------------------------------------------------------------------
# reverse of cons. Return the two objects in a Tcl list.
#-------------------------------------------------------------------------------
proc joy-objuncons l {

  foreach {type val} $l break  ;# ??????
  #
  parse_op $l  type val
  

  switch -- $type {
    string {
      set first [list char [scan [string index $val 0] %c]]
      set rest [list string [string range $val 1 end]]
    }
    list {
      set first [lindex $val 0]
      set rest [list list [lrange $val 1 end]]
    }
  }
  return [list $first $rest]
}

# first
proc joy-objfirst l {
  lindex [joy-objuncons $l] 0
}

# rest
proc joy-objfirst l { ;#???????
  lindex [joy-objuncons $l] 1
}

#-------------------------------------------------------------------------------
# Test for object 'nullity'. That's zero value for numerical types
# and zero elements for aggregate types.
#-------------------------------------------------------------------------------
proc joy-objnull obj {

  foreach {type val} $obj break  ;# ??????
  #
  parse_op $obj  type val

   
  switch -- $type {
    integer -
    float -
    char {
      return [expr {$val == 0}]
    }
    string -
    list {
      return [expr {[joy-objsize $obj] == 0}]
    }
  }

}
#-------------------------------------------------------------------------------
# Virtual Machine
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
proc gena_show_joylist {ll name curi maincolor curscolor} {

  set len  [llength $ll]
  
  puts -nonewline $name

  for {set i 0} {$i < $len} {incr i} {

    set l [lindex $ll $i]
    #puts -nonewline "|l=$l|"

    set op [v3->joy $l]
    
    # установим нужный цвет 
    if {$i == $curi} {
      win_set_color  $curscolor
    } else {
      win_set_color  $maincolor
    }

    puts -nonewline $op

    win_set_color DEFAULT

    puts -nonewline " " ;# просто пробел между командами
  }
  
  puts ""
}
#-------------------------------------------------------------------------------
# Call a function. Take care of tail recursion.
# Optimize tail calls if possible
# 
# Да вроде тут ничего не вызывается (не выполняется), а только подставляется
# в текущую строку программы ??

#-------------------------------------------------------------------------------
proc joy-call {code} {

  set current  [v3_current_get ]
  set  ip      [joy_ip_get_ ] 

  # мы ж уже увеличили счетчик, т.е. это счетчик будущего состояния
  #а нам для анализа нужен еще пока счетчик текущей операции !!

  set ip_cur [expr $ip - 1]

  set op       [lindex $current $ip_cur]
  Debug "          OP = $op"

  set is_this_last [expr {[llength $current] == $ip_cur}] 
  set is_this_ret  [expr {\
                            [joy-objtype $op] eq "symbol" && \
                            [joy-objval  $op] eq "ret"}]

  #puts stderr "          is_this_last = $is_this_last"
  #puts stderr "          is_this_ret  = $is_this_ret"

  # пока не будем оптимизировать хвостовую рекурсию... ??

  #if {$is_this_last || $is_this_ret} \

  if {$is_this_ret} \
      {
        Debug "          is_this_ret=$is_this_ret Don't  need return stack"
      } else {       
        Debug "          is_this_ret=$is_this_ret Save CIL to return stack"

        # сохраним в стек-вызовов-joy-функций полное текущее состояние:
        #
        set l [list  $current $ip [joy-get_locals ]]

        joy-retstack-lappend $l     
      }

  # установим новый код функции в качестве текущего, обнулим счетчики и локпеременные: 
  
  v3_add_ret_and_set_as_curent $code
  joy_ip_set_     0
  joy-set_locals  {}
  
  return [llength [v3_current_get ]]
}
#-------------------------------------------------------------------------------
proc print_retstate {} {

  # на самом едле это не просто стек, а целое состояние - список из трех
  #
  #set retstack "[set ${ctx}::retstack]"
  #set retstack [set ${ctx}::retstack]
  set retstack [joy-get-retstack ]

  #set SKIP "         "
  set ind 0

  foreach t $retstack {
    #puts "$SKIP t = $t"

    # хитрожопо разберем его по "косточкам", т.е. получим значения списка
    foreach {current ip locals} $t break

    # local - пока не показываем !

    set ip_call [expr $ip - 1] ;# будем показыввать вызвавшую программу

    gena_show_joylist  $current  "RETSTACK${ind}: "  $ip_call  BLUE CYAN

    incr ind
  }

}
#-------------------------------------------------------------------------------
proc print_curstate {} {

  set ip  [joy_ip_get_ ]

  gena_show_joylist  [v3_current_get ] "CURR PROG: "  $ip YELLOW RED

  # альтернативный способ перебора содержимого массива (через список-словарь)
  
  #foreach {name value} [array get ${ctx}::local] {}
  foreach {name value} [joy-get_locals ] {

     puts "    $name = $value"
     #gena_show_joylist  $value  "   $name = "  -1  WHITE CYAN
  }
  
}
#-------------------------------------------------------------------------------
# Built-ins
#-------------------------------------------------------------------------------

#
# Core language stuff
#
#-------------------------------------------------------------------------------
proc joy-pop-retstack {} {

  set s [joy-get-retstack ]

  #if {![llength [set ${ctx}::retstack]]} {}
  if {![llength $s]} {

    error "Retstack underflow"
  }

  # берем последнее значение из стека вызовов
  #set t [lindex [set ${ctx}::retstack] end]
  set t [lindex $s end]

  # lreplace список i j параметр параметр - заменяет элементы, занимающие от 
  #          i-й по j-ю позицию в списке, указанными параметрами; 
  #          возвращает новый список.
  # 
  # здесь такой же прием по удалению последнего элемента, как в joy-pop 

  set s [lreplace [joy-get-retstack ] end end]

  #set ${ctx}::retstack $s
  joy-set-retstack $s
  #joy-init-retstack $::ctx $s

  #set ${ctx}::retstack [lreplace [K [set ${ctx}::retstack] [unset ${ctx}::retstack]] end end]
  


  return $t
}
#-------------------------------------------------------------------------------
# Read-Eval loop
#-------------------------------------------------------------------------------
proc joy-rel-getline {} {


  while 1 {
    puts -nonewline "joy> "
    flush stdout
    set line [string trim [gets stdin]]
    if {[string length $line]} {
      return $line
    }
    joy-rel-showstack 
  }

}
#-------------------------------------------------------------------------------
proc joy-rel-showstack {} {

  set l [llength [joy_datastack_get_ ]]
  
  for {set i 0} {$i < $l} {incr i} {
    
    puts -nonewline [v3->joy [lindex [joy_datastack_get_ ] $i]]

    puts -nonewline { }
  }
  
  puts {}
}
#-------------------------------------------------------------------------------
proc joy-print-error-context {} {

  #puts stderr "ctx = $::ctx"

  #for {set i 0} {$i < [set ${ctx}::len]} {incr i} {}
  for {set i 0} {$i < [joy_len_get_ ]} {incr i} {

    if {[joy_ip_get_ ]-1 == $i} {

      #puts "==> [lindex [lindex [set ${ctx}::current] $i] 1]"
      puts "==> [lindex [lindex [v3_current_get ] $i] 1]"

    } else {

      #puts [lindex [lindex [set ${ctx}::current] $i] 1]
      puts [lindex [lindex [v3_current_get ] $i] 1]
    }
  }

}
#-------------------------------------------------------------------------------
proc joy_print_runtimeerror {errstr} {

  puts "=== Runtime error: $errstr ==="

  joy-print-error-context 

  puts "=== Data Stack trace follows ==="

}
#-------------------------------------------------------------------------------
proc joy-eval {text} {

  # зачитаем (т.е. скомпилируем) ядро системы (уже заданные функции на Joy)
  # и не только компилируем, но и выполняем !! ??????

  joy-compile  $text

  run_v3_current_prog_from_begin 

}
#-------------------------------------------------------------------------------
proc joy-rel {} {

 while 1 {

   set line [joy-rel-getline ]

   set e [catch {

     # Если ошибку не перехватывать, то программа завершится.
     # Для перехвата используем программу: 
     # catch тело_команды ?переменная_нуль(норма)_или_ненуль(ошибка)?
     #  
     
     # вообще-то это в точности 
     joy-eval $line
     
     joy-rel-showstack 
   } errstr]
   
   if {$e} { ;# истина, т.е. не нуль, т.е. было ошибка - распечатаем ее:
     
     joy_print_runtimeerror $errstr
     
     joy-rel-showstack 

     # TODO: reset-after-error, clean retstack, auxstack.
   }
 }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
#  З А П У С К А Л К А   п р о г р а м м

#-------------------------------------------------------------------------------
# proc JIN_eval {v3_prg} {


#   set      defarr [dict create]
#   dict set defarr  {} $v3_prg

#   #puts  "JIN_eval: dict = $defarr"
#   #pdict "JIN_eval: pdict= $defarr"

#   v3_add_to_defined_and_set_current_ret  defarr

#   #v3_add_to_defined_and_set_current_ret  "{} $v3_prg"

#   run_v3_current_prog_from_begin 

# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
# proc get_result_from_one_arg_VER2 {prg i} {

#   if {[catch {set result [run_prg_VER2  $prg $i]} err ]} {
#     set result {}
#   } else {
#   }

#   return $result
# }
#-------------------------------------------------------------------------------
# 
# надо тоже самое, но для формата JIN
#
#-------------------------------------------------------------------------------
# proc get_result_from_one_arg_VER2_v3 {v3_prg i} {

# #   if {[catch {set result [run_v3_src_VER2  $v3_prg $i]} err ]} {
# #     set result {}
# #   } else {
# #   }

#   set ctx  [v3_init_context]

#   #joy-eval "$valstack $prg" ;# сначала положили в стек начальное значение

#   if {[catch {JIN_eval "$v3_prg"} err]} {
#     #puts "err = $err"
#     return $err
#   }

#   set e    [pop ]
#   set ret  [v3->joy $e]

#   return $ret
# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Some tests


#-------------------------------------------------------------------------------
# 
# либо интерактивная работа, либо загружаем скрипт из файла
# 
#  пока будем просто искать строку "include "file""
#  и затем вставлять в текст куски включаемого текста;
#  только потом надо будет подумать о циклической вложенности

# К сожалению в файле ./L/inilib.joy описываются функции для динамического
# включения:
# 
#    libload ==
#	[ '_ swons intern body null ]
#	[ ".joy" concat include ]
#-------------------------------------------------------------------------------
proc is_find_include_on_line {line} {

  if [string match "*include*" $line] {

    # делаем простую проверку на кооментарий (в начале строки!)
    #
    set ind [string first "(*" $line]

    if {$ind == 0} {return 0} ;# эта строка вроде как закоментированна

    # пока просто явно обйдем определение, это конечно ненормально ((
    #
    if [string match "*concat include*" $line] {return 0}

    return 1;
  }

  return 0;
}
#-------------------------------------------------------------------------------
proc list_append {&list_old  list_add} {

  USE_REFS

  foreach line $list_add {
    
    lappend list_old $line
  }

}
#-------------------------------------------------------------------------------
# а мне же надо построчно, т.е. доюавлять к результирующему списку
# по отдельности каждый элемент списка !!
#-------------------------------------------------------------------------------
proc list_append_and_include {&list_old  list_add} {

  USE_REFS

  foreach line $list_add {

    #puts stderr "..... line = $line"

    if [is_find_include_on_line  $line] {

      set include_fname [lindex $line 0]
      #puts stderr "    !!! INCLUDE find! = $include_fname"

      #joy_readfile_doincludes  $include_fname l_text_all
      joy_readfile_doincludes  $include_fname list_old

    } else {
      #puts "..... lappend list_old "
      lappend list_old $line
    }
  }

}
#-------------------------------------------------------------------------------
#  ЕЩЕ варианты на чтение:
#  
#  while {[gets $fd line] >= 0} {
#    puts "LINE = $line"
#  }
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc read_file_to_lines {fname} {

  set r_text [read_file_to_rtext $fname]

  # здесь надо, наверное разбить текст на строки и с ними работать
  # для предпроцессинга, а r_text_all на выходе - это уже единая строка

  # а вообще-то считается, что нельзя применять каманду split к произвольным
  # символьным данным, без предварительной проверки, иначе могут быть искажения
  # структуры списков на сложных данных ...
  # но пока вроде проходит ..

  set l_text [split $r_text "\n"] 

  return $l_text
}
#-------------------------------------------------------------------------------
# читаем файл  и делаем глобальные инклуды (жесткие, т.е. ничего не проверяем!)
#
#-------------------------------------------------------------------------------
proc joy_readfile_doincludes {fname &l_text_all} {

  USE_REFS

  set l_text [read_file_to_lines $fname]

  # идем построчно, ищем и добавляем include
  #
  list_append_and_include  l_text_all $l_text

}
#-------------------------------------------------------------------------------
proc readfile_to_rtext_with_include {fname} {

  # здесь будет полный текст скрипта (построчный с включениями include)
  set l_text_all {} 
  
  joy_readfile_doincludes  $fname  l_text_all
  #puts stderr "\nL_TEXT_ALL  = \n\n$l_text_all\n\n" 
  
  set r_text_all [join $l_text_all "\n"]   ;# вернулись к единой строке
  #puts stderr "\nR_TEXT_ALL  = \n\n$r_text_all\n\n" 
  
  return $r_text_all
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc print_current_ip {} {


  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #set ip      [set ${ctx}::ip]
  set ip    [joy_ip_get_ ]

  #set current [set ${ctx}::current] ;# это основной код
  set current [v3_current_get ] ;# это основной код

  puts "ip     = $ip"
  puts "current = $current"
  puts ""

  #set op [lindex [set ${ctx}::current] [set ${ctx}::ip]] 
  #incr ${ctx}::ip
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# Register a built-in.
#-------------------------------------------------------------------------------
proc v3_make_tclproc_by_proc {symbol tclfunc} {

  #set global_ctx ::joy

  # пока функции регистрируются в  общей системе TCL и здесь, т.е. в 
  # глобальном списке. 
  # И отдельно, некоторую часть этих функций (не обязательно все) переносить в 
  # конкртеный контескт?

  #
  # ???
  #puts "........... ${ctx}"   ::joy - это мы явно указывали при создании proc

  set ::builtin_glob($symbol) $tclfunc

  #set ${ctx}::builtin($symbol) $tclfunc

}
#-------------------------------------------------------------------------------
# Более удобная процедура для создания builtin и ее регистрации
#-------------------------------------------------------------------------------
proc v3_make_tclproc {symbol body} {

  #set global_ctx ::joy

  #set procname ::builtin_glob::${symbol} ;# делаем имя более уникальным!
  # а зачем нам эта уникальность? лучше вручную задать требуюмеую!
  #
  # ну или хотя бы не такое дурацкое
  #
  set procname  builtin_${symbol} 


  #proc $procname {ctx symbol} $body      ;# регистрируем процедуру в системе 

  proc $procname {symbol} $body      ;# регистрируем процедуру в системе 

  # а зачем symbol как параметр процедуры??
  # и вообще эта регистрация потом используется? 

  # наверное используется и символ как раз нужен чтобы передать например 
  # "*" в процедуру "+" -  может упростить?
  #puts stderr "joy_global_builtin_make_: procname= $procname"

  v3_make_tclproc_by_proc $symbol $procname


  return $procname
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# 
proc V3_INIT_01 {} {


  # нужен флажок, чтобы повторно не пееропределять!!
  #
  if {[info exist ::is_v3_init_01]}  return
  
  set ::is_v3_init_01 "true"
  

  v3_init_SIMP

  #-------------------------------------------------
  v3_make_tclproc "." {
    
    # The dot is a NOP in this implementation. We just exec
    # the program without to wait for a dot.
    #Debug "    .................. !!"
    #puts "    \".\" NOT inlement, use instead \"^\""
    
    # а надо бы вообще-то сделать, чтобы можно было повторить все тесты
    # из OLDJOY
    #puts "......... DOT ............ "
    
    # хорошо бы проверить - если в стеке ничего нет, ну пусть с ним!!
    #
    set               datastack [joy_datastack_get_ ]
    set len [llength $datastack]
    if {$len == 0} return; 
    
    
    set e [pop] ;# вытащим последнее значение из стека

    #set val [joy-objval $e]   
    #puts "$val" ;# будем выводить, как это делается в оригинале
    # нет, тут нужен полный контроль.

    # это для простых чисел хорошо, а для сложных структур надо:
    
    puts "    = [v3->joy $e]" 
    
  }   
  #-------------------------------------------------
  v3_make_tclproc  "ret" {
    
    if {! [llength [joy-get-retstack ]]} {     
      Debug "          RET return"
      return ;# если ничего в стека возврата-сохранения нет? а так может?

    } else {
      Debug "          RET restack"
    }
    
    # возьмем последний элемент из стека возвратов
    #
    set t [joy-pop-retstack ]
    
    # хитрожопо разберем его по "косточкам", т.е. получим значения списка
    #
    foreach {current ip locals} $t break
    
    # восстанавливаем сохраненный контекст исполнения
    # 
    
    v3_add_ret_and_set_as_curent $current
    joy_ip_set_     $ip
    joy-set_locals $locals
    
  }
  #-------------------------------------------------
  v3_make_tclproc "putchars" {
    
    joy-check-stack  string
    
    set e [pop ]
    puts -nonewline [joy-objval $e]
    
    flush stdout
  }
  #-------------------------------------------------
  v3_make_tclproc "setautoput" {
    
  # USETOP ( setautoput_,    "setautoput",    NUMERICTYPE, autoput = stk->u.num )

  # {"setautoput",		setautoput_,	"I  ->",
  # "Sets value of flag for automatic put to I (if I = 0, none; \n
  # if I = 1, put; if I = 2, stack."},
  }
  #-------------------------------------------------
  v3_make_tclproc "setundeferror" {


  }
  #-------------------------------------------------
  v3_make_tclproc "include" {
    
    set pop [pop ] ;# вытащим последнее значение из стека
    set val [joy-objval $pop]
    set fname $val
    
    #puts ""
    #puts "INCLUDE: "
    #puts "pop     = $pop"
    #puts "val     = $val"
    #puts "INCLUDE FNAME  = $fname" 
    
    #print_current_ip 
    
    set r_text_all [read_file_to_rtext  $fname]
    
    joy-compile_add  $r_text_all
    
    #print_current_ip 
    
  }
  #-------------------------------------------------
  # 
  # разберем определение команды ifte:
  
  # (T PT PF) - специальная форма, присваивает локально значения в стеке именам
  # 
  # 
  # 
  
  # уберем пока его совсем раз он такая сука !
  # 
  # (он стоял после linrec)
  
  # 	binrec == (B T R1 R2)
  # 	    $B $T
  # 	    $R1 [(a b)] concat
  # 	    [$a] $B $T $R1 $R2 [] cons cons cons cons concat [binrec]
  # 	    [$b] $B $T $R1 $R2 [] cons cons cons cons concat [binrec]
  # 	    $R2 concat concat concat concat concat
  # 	    ifte;

  # 
  #-------------------------------------------------
  v3_make_tclproc "branch" {
    
    joy-check-stack  truth list list
    
    set falsebranch [pop ]
    set truebranch  [pop ]
    set bool        [pop ]
    
    if {[lindex $bool 1]} {
      joy-call  [joy-objval $truebranch]
    } else {
      joy-call  [joy-objval $falsebranch]
    }
    
  }
  #---------------------------------------
  v3_make_tclproc "stack" {
    
    #push  [list list [set ${ctx}::datastack]]
    push  [list list [joy_datastack_get_ ]]
    
  }
  #---------------------------------------
  
  v3_make_tclproc "unstack" {
    
    joy-check-stack  list
    
    #set ${ctx}::datastack [joy-objval [pop ]]
    joy_datastack_set_ [joy-objval [pop ]]
    
  }
  #---------------------------------------
  v3_make_tclproc "i" {
    
    joy-check-stack  list ;# это должен быть квотированный список!
        
    set l [pop ] ;# подняли из стека
    
    joy-call  [joy-objval $l] ;# выполняем внутренность списка
    
  }
  #---------------------------------------
  #
  # Stack manipulation functions
  #
  #---------------------------------------
  v3_make_tclproc "pop" {
    
    set e [pop ]
    
  }
  #---------------------------------------
  
  v3_make_tclproc "swap" {
    
    joy-check-stack  {} {}
    
    set a [pop ]
    set b [pop ]
    
    push  $a
    push  $b
    
  }
  #-------------------------------------------------
  v3_make_tclproc "dup" {
    
    set e [pop ] ;# вытащили значение из стека
    
    push   $e    ;# положили обратно два раза
    push   $e    ;# 
    
  }
  #-----------------------------------------------------------------------------
  v3_make_tclproc "cons" {
    
    joy-check-stack  {} {string list}
    
    set l [pop ]
    set e [pop ]

    if {[joy-objtype $l] eq "string" && [joy-objtype $e] ne "char"} {
      push  $e
      push  $l
      error "To cons with a string require a character"
    }
    
    push  [joy-objcons $e $l]
    
  }
  #-----------------------------------------------------------------------------
  # Gets a string and returns it's synmbol.
  # "sym" -> sym
  #-----------------------------------------------------------------------------
  v3_make_tclproc "intern" {
    
    joy-check-stack  string
    
    set obj [pop ]
    
    joy-push-type  symbol [joy-objval $obj]
    
  }
  #-------------------------------------------------
  #body      :  U  ->  [P]
  #Quotation [P] is the body of user-defined symbol U.
  #-------------------------------------------------
  v3_make_tclproc "body" {
    
    joy-check-stack  symbol
    set sym [joy-objval [pop ]]
    
    if {[info exists ::builtin_glob($sym)]} {

      error "User define symbol needed for body"
    }
    
    if {[v3_defined_is_name_exist $sym]} {
      
      #joy-push-type  list [set ${ctx}::define($sym)]
      joy-push-type  list [v3_defined_get_by_name $sym]
      
    } else {
      joy-push-type  list {}
    }
  }
  #-------------------------------------------------
  v3_make_tclproc "null" {
    
    
    set e [pop ]
    
    if {[joy-objnull $e]} {
      joy-push-type  truth 1
    } else {
      joy-push-type  truth 0
    }
    
  }
  #-------------------------------------------------
  v3_make_tclproc "concat" {
    
    joy-check-stack  {string list} {string list}
    
    set b [pop ]
    set a [pop ]
    
    if {[joy-objtype $a] != [joy-objtype $b]} {
      push  $a
      push  $b
      error "two parameters of the same type needed for concat"
    }
    
    set aval [joy-objval $a]
    set bval [joy-objval $b]
    
    switch -- [joy-objtype $a] {
      string {
        joy-push-type  string $aval$bval
      }
      list {
        joy-push-type  list [::concat $aval $bval]
      }
    }
    
  }
  #-------------------------------------------------
  # дополнение к стандарту
  #-------------------------------------------------
  v3_make_tclproc "^" {
    
    puts "    = [pop ]"
    
  }
  #-----------------------------------------------------------------------------
  # Note that seems quite natural to implement 'map' calling
  # the interpreter recursively, but this breaks continuations
  # so we create a Joy quoted function doing the work for us,
  # then calling it.
  #
  # The alternative solution is to implement map in Joy as a
  # library function.
  #
  # FIXME: this is too slow compared to the rest of the implementation.
  # Not that a Joy implementation written in Tcl will win the race... but.. ;)
  #-----------------------------------------------------------------------------
  v3_make_tclproc "at" {
    
    joy-check-stack  {string list} integer

    set i [joy-objval [pop ]]
    set l [pop ]
    push  [joy-objat $l $i]
    
  }
  #-----------------------------------------------------------------------------
  v3_make_tclproc "map" {
    
    joy-check-stack  {list string} list
    
    set f [pop ]
    set l [pop ]
    set len [joy-objsize $l]
    set empty [joy-objempty $l]
    
    set code {}
    for {set i 0} {$i < $len} {incr i} {
      lappend code [list list [list [joy-objat $l $i]]]
      lappend code [list integer 0]
      lappend code [list symbol at]
      lappend code $f
      lappend code [list symbol i]
      lappend code $empty
      lappend code [list symbol cons]
    }
    for {set i 1} {$i < $len} {incr i} {
      lappend code [list symbol concat]
    }
    
    joy-call  $code
    
  }
  #-----------------------------------------------
  #
  # Types related functions
  #

  proc builtin_types {symbol} {
    
    if {$symbol eq {character}} {set symbol char}
    
    set obj [pop ]
    
    joy-push-type  truth [expr {[joy-objtype $obj] eq $symbol}]
    
  }
  #-----------------------------------------------
  
  v3_make_tclproc_by_proc "integer"   builtin_types
  v3_make_tclproc_by_proc "character" builtin_types
  v3_make_tclproc_by_proc "float"     builtin_types
  v3_make_tclproc_by_proc "string"    builtin_types
  v3_make_tclproc_by_proc "list"      builtin_types
  v3_make_tclproc_by_proc "truth"     builtin_types
  
  
  #-------------------------------------------------
  # 
  # Math related functions
  # 

  proc builtin_math {symbol} {
    
    if {$symbol eq {rem}} {set symbol %}
    
    #puts stderr "func ... " ;# это выполнится только при вызове функции
    #  а сама она остается зарегистрирована в системе как 
    # "..+" что не очень правильно !!
    
    # проверка:  должно быть два значения в стеке, нужных типов!
    
    joy-check-stack   {integer float char} {integer float}
    
    set b [pop ]
    set a [pop ]
    set c [expr "\[joy-objval \$a\] $symbol \[joy-objval \$b\]"]
    
    if {[string first . $c] == -1} {
      set type integer
    } else {
      set type float
    }
    
    if {[joy-objtype $a] eq {char}} {
      set c [expr {$c%256}]
      set type char
    }
    
    joy-push-type  $type $c
    
  }
  #-------------------------------------------------

  v3_make_tclproc_by_proc "+"    builtin_math
  v3_make_tclproc_by_proc "*"    builtin_math
  v3_make_tclproc_by_proc "-"    builtin_math
  v3_make_tclproc_by_proc "/"    builtin_math
  
  v3_make_tclproc_by_proc "rem"  builtin_math ;# ???
  
  #-------------------------------------------------
  #-------------------------------------------------

  set ::joy_sources_CANONICAL {

    DEFINE

	ifte == (T PT PF) stack (S)
		    $T i (T) $S unstack
		    $T $PT $PF branch;
	

	swons  ==  swap  cons;

	filter == (a t)
	    $a list [[]] [""] branch dup (e) $a
	    $t
	    $e [] cons [cons concat] concat [pop]
	    [] cons cons cons [ifte] concat
	    step;

    .
  }

  # скомпилим и добавим наши определения в основные
  #

  joy-compile  $::joy_sources_CANONICAL

  #-------------------------------------------------


  
} ;# V3_INIT_01
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

proc V3_INIT_02 {} {


  # нужен флажок, чтобы повторно не переопределять!!
  #
  if {[info exist ::is_v3_init_02]}  return

  set ::is_v3_init_02 "true"


  V3_INIT_01 ;# подключим !!
  

  #---------------------------------------------------------
  
  set ::joy_sources_MAX {

    DEFINE

	swapd  ==  [swap] dip;

	popd   ==  [pop ] dip;
	dupd   ==  [dup ] dip;
	rollup     ==  swap [swap] dip;
	rolldown   ==  [swap] dip swap;
	rotate     ==  swap [swap] dip swap;
	unitstring  ==  "" cons;
	unitlist    ==  [] cons;
	pairstring  ==  "" cons cons;
	pairlist    ==  [] cons cons;
	unpair  ==  uncons uncons pop;
	second  ==  rest first;
	third  ==  rest rest first;
	unconsd == [uncons] dip;
	uncons2   ==  [uncons ] dip uncons  swapd;
	unswons2  ==  [unswons] dip unswons swapd;
	succ == 1 +;
	pred == 1 -;
	y == [dup cons] swap concat dup cons i;
	unitlist == [] cons;
	unswons == uncons swap;

	linrec == (P T R1 R2)
	    $P $T
		    $R1
		    $P $T $R1 $R2 [] cons cons cons cons
		    [linrec] $R2 concat concat concat
		    ifte;

	tailrec == [] linrec;

	primrec ==
	(* primrec can be written in terms of linrec *)
	    [null] rollup swap [pop] swap concat swap [dup pred] swap linrec;

	while == (B D)
	    $B $D $B $D [while] cons cons concat [] ifte;

	times == (n p)
	    $n null [] [] $p [i] cons $n [pred] cons $p [times] cons
	    concat concat concat branch;

	cond ==
	    uncons (rest)
	    uncons
	    $rest size 1 [=] cons cons
	    $rest first
	    $rest [] cons [cond] concat
	    [] cons cons concat [branch] concat
	    ifte;

	fold == (a v0 p) $v0 $a $p step;

	split == (a t)
	    $a list [[]] [""] branch dup dup (e) $a
	    $t
	    $e [] cons [cons (a b) $b concat $a] concat
	    $e [] cons [cons concat] concat
	    [] cons cons cons [ifte] concat
	    step;

	step == (A P)
	    $A $P
	    $A size
	    [(a p) $a uncons (a) $p i $a $p]
            times pop pop

	    .

  }

  # скомпилим и добавим наши определения в основные
  #

  joy-compile  $::joy_sources_MAX

  #---------------------------------------------------------
  
  set ::joy_sources_ADD {

    DEFINE
        cleave == (X P1 P2)  $X $P1 i   $X $P2 i ;
        unary2 == (X1 X2 P)  $X1 $P i   $X2 $P i ;
        unary  == (X1 P)  $X1 $P i  .
	.
  }

  # добавим наши определения в основные
  #
  #append ::joy_sources  [set ::joy_sources_ADD]
    
  joy-compile  $::joy_sources_ADD

  #---------------------------------------------------------
  v3_make_tclproc "size" {
    
    joy-check-stack  {string list}
    
    joy-push-type  integer [joy-objsize [pop ]]
    
  }
  #---------------------------------------------------------
  #
  # Functions on aggregate types
  #
  #---------------------------------------------------------
  v3_make_tclproc "uncons" {
    
    
    joy-check-stack  {string list}
    
    set l [pop ]
    if {![joy-objsize $l]} {
      push  $l
      error "non empty aggregate needed for uncons"
    }
    
    foreach {first rest} [joy-objuncons $l] break
    
    push  $first
    push  $rest
    
  }
  #---------------------------------------------------------
  v3_make_tclproc "first" {
    
    
    joy-check-stack  {string list}
    
    set l [pop ]
    if {![joy-objsize $l]} {
      push  $l
      error "non empty aggregate needed for first"
    }

    foreach {first rest} [joy-objuncons $l] break
    push  $first
  }
  #---------------------------------------------------------
  v3_make_tclproc "rest" {
    
    
    joy-check-stack  {string list}
    
    set l [pop ]
    if {![joy-objsize $l]} {
      push  $l
      error "non empty aggregate needed for rest"
    }
    foreach {first rest} [joy-objuncons $l] break
    
    push  $rest
  }
  #---------------------------------------------------------
  v3_make_tclproc "small" {
    
    
    joy-check-stack  {string list integer char}
    
    set obj [pop ]
    switch -- [joy-objtype $obj] {
      string -
      list {
        set t [expr {[joy-objsize $obj] <= 1}]
      }
      integer -
      char {
        set t [expr {[joy-objval $obj] <= 1}]
      }
    }
    
    joy-push-type  truth $t
  }
  #---------------------------------------------------------
  # попробуем как-то реализовать
  #---------------------------------------------------------
  v3_make_tclproc "putch" {
    
    set pop [pop ] ;# вытащим последнее значение из стека
    set val [joy-objval $pop]
    
    puts -nonewline "    = [v3->joy $pop]" 
    
  }
  
  #---------------------------------------------------------
  # вместо   newline == '\n putch;
  #---------------------------------------------------------
  v3_make_tclproc "newline" {
    
    puts -nonewline "\n" 
    
  }
  #---------------------------------------------------------
  #
  # Comparison functions
  #
  #---------------------------------------------------------
  # set func [
  #     v3_make_tclproc = {
  # 	if {$symbol eq {=}} {set symbol ==}
  
  # 	joy-check-stack  {integer string float char} {integer string float char}
  
  # 	set b [pop ]
  # 	set a [pop ]
  # 	if {[joy-objtype $a] ne [joy-objtype $b]} {
  # 	    push $a
  # 	    push $b
  # 	    error "Can't compare objects of differnt types"
  # 	}
  # 	set aval [joy-objval $a]
  # 	set bval [joy-objval $b]
  # 	set x [expr "\$aval $symbol \$bval"]
  # 	joy-push-type  truth $x
  #     }
  # ]
  
  # v3_make_tclproc_by_proc >  $func
  # v3_make_tclproc_by_proc >= $func
  # v3_make_tclproc_by_proc <  $func
  # v3_make_tclproc_by_proc <= $func
  # v3_make_tclproc_by_proc != $func
  
  #---------------------------------------------------------
  proc builtin_comparison {symbol} {
    
    if {$symbol eq {=}} {set symbol ==}
    
    joy-check-stack  {integer string float char} {integer string float char}
    
    set b [pop ]
    set a [pop ]
    
    if {[joy-objtype $a] ne [joy-objtype $b]} {
      push $a
      push $b
      error "Can't compare objects of differnt types"
    }
    
    set aval [joy-objval $a]
    set bval [joy-objval $b]
    
    set x [expr "\$aval $symbol \$bval"]
    
    joy-push-type  truth $x
    
  }
  #---------------------------------------------------------
  
  v3_make_tclproc_by_proc "="  builtin_comparison
  v3_make_tclproc_by_proc ">"  builtin_comparison
  v3_make_tclproc_by_proc ">=" builtin_comparison
  v3_make_tclproc_by_proc "<"  builtin_comparison
  v3_make_tclproc_by_proc "<=" builtin_comparison
  v3_make_tclproc_by_proc "!=" builtin_comparison
  
  
  #---------------------------------------------------------
  # We use again the trick used in to implement the map combinator.
  # Create a joy program that implements the combinator at runtime.
  #---------------------------------------------------------
  v3_make_tclproc "dip" {
    
    joy-check-stack  {} list
    
    set l [pop ]
    set item [pop ]
    lappend code $l [list symbol i] $item
    
    joy-call  $code
  }
  #---------------------------------------------------------
  v3_make_tclproc "abs" {
    
    set pop [pop ] ;# вытащим последнее значение из стека
    
    set v [joy-objval  $pop]
    set t [joy-objtype $pop]
    
    set abs_val [expr abs($v)]
    #puts "v       = $v"
    #puts "t       = $t"
    #puts "abs_val = $abs_val"
    
    # joy> -12.3 abs .
    # v       = -12.3
    # t       = integer  ?????
    # abs_val = 12.3
    #     = 12.3
    
    joy-push-type  $t $abs_val
    
    #return [expr abs($val)]
  }
  #---------------------------------------------------------
  # argc 	-> I
  # 	Pushes the number of command line arguments. This is quivalent to 'argv size'.
  
  # argv 	-> A
  # 	Creates an aggregate A containing the interpreter's command line arguments.
  
  #---------------------------------------------------------
  v3_make_tclproc "argc" {
    
    global argc argv
    
    joy-push-type   integer $argc
  }
  #---------------------------------------------------------
  v3_make_tclproc "argv" {
    
    global argc argv
    
    joy-push-type   string $argv
  }
  #---------------------------------------------------------  
  v3_make_tclproc "in" {
      
    set aggr [pop ] ;# вытащим последнее значение из стека
    set aggr_v [joy-objval  $aggr]
    set aggr_t [joy-objtype $aggr]
    
    set elem [pop ] ;# вытащим последнее значение из стека
    set elem_v [joy-objval  $elem]
    set elem_t [joy-objtype $elem]
    
    if {0} {
      puts "aggr_v       = $aggr_v"
      puts "aggr_t       = $aggr_t"
      puts ""
      puts "elem_v       = $elem_v"
      puts "elem_t       = $elem_t"
      puts ""
      puts "elem         = [convert_joy_to_33 $elem]"
    }
    
    # предположим, что у нас список точно, пройдемся по нему циклом:
    # 
    set resl_v "false"
    
    foreach l $aggr_v {
      #puts "l = $l"
      
      if {$l == $elem} {
        #puts "OKKKK!!"
        set resl_v "true"
      }
    }
    
    joy-push-type   truth  $resl_v
    
  }
  #---------------------------------------------------------  
  # тоже заглушка
  #---------------------------------------------------------  
  v3_make_tclproc "quit" {
    
    # может сделать exit ??
    
  }
  #---------------------------------------------------------


} ;# V3_INIT_02
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
#
#
#-------------------------------------------------------------------------------
proc V3_INIT_03 {} {


  # нужен флажок, чтобы повторно не пееропределять!!
  #
  if {[info exist ::is_v3_init_03]}  return
  
  set ::is_v3_init_03 "true"
  
  
  V3_INIT_02 ;# подключим !!

  
  #---------------------------------------------------------
  v3_make_tclproc "exit" {
    
    ::exit
  }
  #---------------------------------------------------------
  v3_make_tclproc "auxpush" {
    
    joy-auxpush 
  }
  #---------------------------------------------------------
  v3_make_tclproc "auxpop" {
    
    joy-auxpop 
  }
  #---------------------------------------------------------
  v3_make_tclproc "newstack" {
    
    #set ${ctx}::datastack {}
    
    joy_datastack_set_ {}
    
  }
  #---------------------------------------------------------
  # Combinators
  #---------------------------------------------------------
  #---------------------------------------------------------
  # S -> B
  # B is true if the symbol is a valid local variable name. False otherwise.
  #---------------------------------------------------------
  v3_make_tclproc "local" {
    
    joy-check-stack  symbol
    
    set obj [pop ]
    
    set r [string range [joy-objval $obj] 1 end]
    
    #set b [info exists ${ctx}::local($r)]
    set b [joy-locals-is-exist $r]
    
    
    joy-push-type  truth $b
  }
  #---------------------------------------------------------
  # Truth type related stuff
  #
  #---------------------------------------------------------
  v3_make_tclproc "and" {
    
    joy-check-stack  truth truth
    
    set b [pop ]
    set a [pop ]
    
    joy-push-type  truth [expr {[joy-objval $a]&&[joy-objval $b]}]
  }
  #---------------------------------------------------------
  v3_make_tclproc "or" {
    
    joy-check-stack  truth truth
    
    set b [pop ]
    set a [pop ]
    
    joy-push-type  truth [expr {[joy-objval $a]||[joy-objval $b]}]
  }
  #---------------------------------------------------------
  v3_make_tclproc "xor" {
    
    joy-check-stack  truth truth
    
    set b [pop ]
    set a [pop ]
    
    joy-push-type  truth [expr {([joy-objval $a]+[joy-objval $b]) == 1}]
  }
  #---------------------------------------------------------
  v3_make_tclproc "not" {
    
    joy-check-stack  truth
    
    set a [pop ]
    
    joy-push-type  truth [expr {![joy-objval $a]}]
  }
  #---------------------------------------------------------
  # I/O related functions
  #
  #---------------------------------------------------------
  
  v3_make_tclproc "put" {
    
    set e [pop ]
    puts -nonewline "[v3->joy $e] "
    
    flush stdout
  }
  #---------------------------------------------------------
  v3_make_tclproc "tclrepr" {
    
    set e [pop ]
    puts $e
  }
  #---------------------------------------------------------
  v3_make_tclproc "stacktrace" {
    
    joy-rel-showstack 
  }
  #---------------------------------------------------------
  #   v3_make_tclproc "help" {
  
  #     set bi  [array names ::builtin_glob]
  
  #     #set def [array names ${ctx}::define]
  #     set def  [joy_define_get_names_ ]
  
  
  #     puts [lsort [::concat $bi $def]]
  #   }
  #---------------------------------------------------------
  # Continuations
  #
  #---------------------------------------------------------  
  v3_make_tclproc "callcc" {
    
    joy-check-stack  list
    
    set p [pop ]
    set continuation [joy-get-continuation ]
    push  $continuation

    joy-call  [joy-objval $p]
  }
  #---------------------------------------------------------  
  v3_make_tclproc "continue" {
    
    joy-check-stack  list
    
    set cont [pop ]
    joy-set-continuation $cont
  } 
  #---------------------------------------------------------  
  # 
  #   ПЕЧАТЬ-ВЫВОД     ПЕЧАТЬ-ВЫВОД     ПЕЧАТЬ-ВЫВОД  
  # 
  #---------------------------------------------------------  
  # сделаем обычную процедуру вывода верхушки стека, но в удобном формате TCL
  #---------------------------------------------------------  
  v3_make_tclproc "putn" {
    
    set e [pop ]
    
    #puts -nonewline "[v3->joy $e] "
    puts "    = [v3->joy $e]"
    
    flush stdout
  }
  #---------------------------------------------------------  
  # http://www.latrobe.edu.au/phimvt/joy/j01tut.html:
  
  # To compute the average or arithmetic mean of the members of a set or a list, we 
  # have to divide the sum by the size. (Because of the integer arithmetic, the 
  # division will produce an inaccurate average.) The aggregate needs to be looked 
  # at twice: once for the sum and once for the size. So one way to compute the 
  # average is to duplicate the aggregate value first with the dup operator. Then 
  # take the sum of the top version. Then use the swap operator to interchange 
  # the position of the sum and the original aggregate, so that the original is 
  # now on top of the stack. Take the size of that. Now the stack contains the sum 
  # and the size, with the size on top. Apply the division operator to obtain 
  # the average value.
  
  #         dup  0  [+]  fold  swap  size  /
  
  # One nice feature of this little program is that it works equally for set 
  # values as for list values. This is because the constituents fold and size 
  # work for both types.
  
  # But there are two aspects of this program which are unsatisfactory. One concerns 
  # the dup and swap operators which make the program hard to read. The other 
  # concerns the sequencing of operations: The program causes the computation of 
  # the sum to occur before the computation of the size. But it does not matter 
  # in which order they are computed, in fact on a machine with several processors 
  # the sum and the size could be computed in parallel. Joy has a combinator which 
  # addresses this problem: there is one data parameters, the aggregate, which is 
  # to be fed to two functions. From each of the functions a value is to be 
  # constructed, by calling both functions by means of a combinator cleave which 
  # produces two values, one for the sum and one for the size. The program for 
  # the average looks like this:
  
  #         [0 [+] fold]   [size]   cleave   /
  
  #---------------------------------------------------------  
  # void cleave_()
  # {			/*  X [P1] [P2] cleave ==>  X1 X2	*/
  #   THREEPARAMS ("cleave");
  #   TWOQUOTES   ("cleave");
  #   SAVESTACK;
  
  #   stk = SAVED3;
  #   exeterm (SAVED2->u.lis);			/* [P1]		*/
  #   dump1 = newnode(stk->op, stk->u, dump1);	/*  X1		*/
  #   stk = SAVED3;
  
  #   exeterm (SAVED1->u.lis);			/* [P2]		*/
  #   dump1 = newnode (stk->op, stk->u, dump1);	/*  X2		*/
  #   stk = dump1; dump1 = dump1->next->next; stk->next->next = SAVED4;
  
  #   POP (dump);
  #   return;
  # }
  #---------------------------------------------------------  
  v3_make_tclproc "cleave_" {
    
    # НЕТ! лучше реализуем это все в ::joy_sources
    # ------------------------------------------------------
    
    #set pop [pop ] ;# вытащим последнее значение из стека
    
    #set v [joy-objval  $pop]
    #set t [joy-objtype $pop]
    
    #set abs_val [expr abs($v)]
    #puts "v       = $v"
    #puts "t       = $t"
    #puts "abs_val = $abs_val"
    
    #joy-push-type   $t $abs_val
  }
  #---------------------------------------------------------  
  # 
  #---------------------------------------------------------  
  #A Joy Library for Online Help Generation:
  #
  # in 	X A -> B
  # 	Tests whether X is a member of aggregate A.
  #---------------------------------------------------------  
  
  # файл "mthlib.joy":
  #
  # (* - - -          N U M E R I C A L   C A L C U L A T O R         - - - *)
  # (*	e.g.   [* 10 [+ 2.2 3.3]]  calc.   *)
  
  #     calc == 
  # 	[ numerical ]
  # 	[ ]
  # 	[ unswons
  # 	  [ dup [+ - * /] in ]
  # 	  [ [ [calc] map uncons first ] dip
  # 	    call ]
  # 	  [ "bad operator\n" put ]
  # 	  ifte ]
  # 	ifte ;
  #---------------------------------------------------------  
  
  # jm-intr.c
  # 
  #---------------------------------------------------------  
  
  # #define INHAS(PROCEDURE,NAME,AGGR,ELEM)				\
    # void PROCEDURE()					        \
    # {   int found = 0;						\
    #     TWOPARAMS(NAME);						\
    #     switch (AGGR->op)						\
    #       { case SET_:						\
    # 	    found = ((AGGR->u.set) & (1 << ELEM->u.num)) > 0;	\
    # 	    break;						\
    # 	case STRING_:						\
    # 	  { char *s;						\
    # 	    for (s = AGGR->u.str;				\
    # 		 *s != '\0' && *s != ELEM->u.num;		\
    # 		 s++);						\
    # 	    found = *s != '\0';					\
    # 	    break; }						\
    # 	case LIST_:						\
    # 	  { Node *n = AGGR->u.lis;				\
    # 	    while (n != NULL && n->u.num != ELEM->u.num)	\
    # 		n = n->next;					\
    # 	    found = n != NULL;					\
    # 	    break; }						\
    # 	default:						\
    # 	    BADAGGREGATE(NAME); }				\
    #     BINARY(BOOLEAN_NEWNODE,(long)found);			\
    # }
  #---------------------------------------------------------  
  # INHAS (in_,  "in",  stk,stk->next)
  # INHAS (has_, "has", stk->next, stk)
  
  #---------------------------------------------------------  
  # void linrec_()
  # {
  #   FOURPARAMS ("linrec");
  #   FOURQUOTES ("linrec");
  #   SAVESTACK;
  
  #   stk = SAVED5;
  #   linrecaux ();
  
  #   POP (dump);
  #   return;
  
  # }
  #---------------------------------------------------------  
  # непосредственно процедура линейной рекурсии
  #---------------------------------------------------------  
  # void linrecaux()
  # {
  #   int result;
  
  #   dump1 = LIST_NEWNODE (stk, dump1);
  #   exeterm (SAVED4->u.lis);      // выполнить терм (4-й справа, т.е. [1]-й)
  #   result = stk->u.num;
  #   stk = DMP1; POP (dump1);
  
  #   if (result)                   // если условие [1] выполняется, то
  #     exeterm (SAVED3->u.lis);    // выполнить [2] и все!
  #   else                          // иначе :
  #   { 
  #     exeterm (SAVED2->u.lis);    // выполняем [3]
  #     linrecaux ();               // вызываемся рекурсивно
  #     exeterm (SAVED1->u.lis);    // выполняем [4]
  #   }
  #   return;
  # }
  #---------------------------------------------------------  
  #---------------------------------------------------------  
  v3_make_tclproc "linrec_gena" {
    
    # проверка:  должно быть два значения в стеке, нужных типов!
    #joy-check-stack  $::ctx  {integer float char} {integer float}
    joy-check-stack  {list} {list} {list} {list}
    
    set s4  [pop ] ;# вытащим последнее значение из стека
    set s3  [pop ] 
    set s2  [pop ] 
    set s1  [pop ] 
    
    set s1_v [joy-objval  $s1]
    set s1_t [joy-objtype $s1]
    set s2_v [joy-objval  $s2]
    set s2_t [joy-objtype $s2]
    set s3_v [joy-objval  $s3]
    set s3_t [joy-objtype $s3]
    set s4_v [joy-objval  $s4]
    set s4_t [joy-objtype $s4]
    
    if {1} {
      
      puts "s1_v       = $s1_v"
      puts "s1_t       = $s1_t"
      puts ""
      puts "s2_v       = $s2_v"
      puts "s2_t       = $s2_t"
      puts ""
      puts "s3_v       = $s3_v"
      puts "s3_t       = $s3_t"
      puts ""
      puts "s4_v       = $s4_v"
      puts "s4_t       = $s4_t"
      puts ""
      
      #     puts "elem         = [convert_joy_to_33 $elem]"
    }
    
    #   push  $continuation
    #   joy-call  [joy-objval $p]
    
    set val    [pop ] ;# вытащим последнее значение из стека
    set val_v  [joy-objval  $val]
    
    # выполнить функцию, но чего-то я не пойму над каким числом?
    # в стеке ведь нет ничего ..
    #
    # похоже тут только подстановка идет !!
    # 
    joy-call  $s2_v
    joy-call  $s2_v
    
    
    joy-push-type   integer $val_v
    
  }
  #---------------------------------------------------------  
  # ИЛИ можно проще тест:
  # 
  # jm_main          j__00.joy
  # j~.tl TEST_main j__00.joy
  
  # j~.tl TEST_main j__02_min.joy     ... PASSED
  # j~.tl TEST_main js_tst0.jt        ... PASSED
  # j~.tl TEST_cleave                 ... PASSED
  # j~.tl TEST_main j__02.joy         ... PASSED
  
  #---------------------------------------------------------  
  v3_make_tclproc "qsort" {
    
    set pop [pop ] ;# вытащим последнее значение из стека
    
    #set v [joy-objval  $pop]
    #set t [joy-objtype $pop]
    #puts ""
    #puts "pop = $pop"
    #puts "v   = $v"
    #puts "t   = $t"
    
    # здесь бы где-то (или дальше) проверить, что там только интежеры?!
    
    set pop_joy [v3->joy $pop]
    #puts "pop_joy = $pop_joy"   ;# [5 2 3 4]
    
    set pop_l [string map {[ list\  ] \   } $pop_joy]
    #puts "pop_l = $pop_l"       ;# list 5 2 3 4
    
    set t [eval $pop_l]
    #puts "t = $t"            ;# 5 2 3 4
    
    set t_sort [lsort $t]
    #puts "t_sort = $t_sort"  ;# 2 3 4 5
    
    set l "\[ $t_sort \]"
    #puts "l = $l"            ;# [ 2 3 4 5 ]
    
    # нормальный отсортированный список, теперь бы его засунуть в стек списком JOY
    # сначала сделае строку типа [2 3 4 5] и затем конвертнем ее convert_joy_to_33 
    
    set ret [convert_joy_to_33 $l]
    
    joy-push-type   list $ret
  }
  #---------------------------------------------------------  
  #---------------------------------------------------------  

  
} ;# V3_INIT_03
#-------------------------------------------------------------------------------


################################################################################
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc TEST_errs {} {


  V3_INIT_03  ;# куча дополнительных функций

  
  # надо бы добавить проверки на ошибки исключения
  # 

  puts ""

  if {[catch {joy-eval "2 * ^"} err]} {
    joy_print_runtimeerror $err
  } 
  
  puts ""

  if {[catch {joy-eval "2 haha * ^"} err]} {
    joy_print_runtimeerror $err
  } 
  
  puts ""

  if {[catch {joy-eval "2 i"} err]} {
    joy_print_runtimeerror $err
  } 
  
}
################################################################################
#
#-------------------------------------------------------------------------------
proc TEST_01 {} {

  V3_INIT_03  ;# куча дополнительных функций


  puts ""
  #DebugOn
  Debug " "

# In order to push the object bound to a local on the stack
# the program should contain a symbol that is composed
# using a $ character followed by the local name, like "$this"
#
# An example to swap two elements on the swap:
#
# 1 2 (a b) $b $a -> 2 1
#
  joy-eval {
    [1 2] ^
    [1 2] putn

    1 2 (a b) $b $a
  }

  #joy_print_ 


  puts ""
  puts "joy-rel-showstack: "
  joy-rel-showstack 

  DebugOff

}
#-------------------------------------------------------------------------------
proc v3_run_file {fname} {


  # включим include на стадии препроцессинга
  #set r_text_all [readfile_to_rtext_with_include $fname]
  
  # не будем включать include на стадии препроцессинга
  set r_text_all [read_file_to_rtext             $fname]
  
  # здесь уже есть полностью готовый текст программы в одной строке
  # вот только зачем там комменты ??
  
  #puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts stderr "r_text_all = $r_text_all"
  #puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


  if {!$::joy::debug} {
    # если не отладочный вариант, то возможную ошибку перехватываем
    # системно
    # основной ЗАПУСК СКРИПТА:
    
    if {[catch {joy-eval $r_text_all} err]} {
      
      joy_print_runtimeerror $err
    }
    #puts stderr "\nALL_TEXT  = \n$r_text_all\n" 
    #puts stderr "\n    TEXT2 = \n$text\n" 
    
  } else {
    # отладочный вариант
    joy-eval $r_text_all
  }
  
  return
}
#-------------------------------------------------------------------------------
#
# TESTS ..................
#
#-------------------------------------------------------------------------------
proc TEST_more {} {


  V3_INIT_03  ;# куча дополнительных функций


  joy-eval    "1 2 + ."
  joy-eval    "2 3 + ."
  joy-eval    "2 3 * ^"
  
  joy-eval    {
      DEFINE ccc == concat ; cc2 == concat.
      [2 3] [4 5] ccc ^
      [2 3] [8 9] cc2 ^
  }
  
  joy-rel-showstack 

}
#-------------------------------------------------------------------------------
proc TEST_more_new {} {


  V3_INIT_03  ;# куча дополнительных функций


  puts ""

  joy-eval    { [1 2  ] 3  . } ;# печатаем верхний элемент без типа
  joy-eval    { [1 2  ] 3  ^ } ;# ......................... с типом

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ "
  puts ""

  v3_init_null 

  joy-eval    { [1 2 ]}

  joy-rel-showstack 
  joy-eval    { ^ }   ;# выводит не только на печать, но 
                            # и совсем из стека!
  joy-rel-showstack 


  puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ "
  #puts ""

  v3_init_null 

  joy-eval    { [1 2  ] i } ;# т.е. тоже запихивает

  joy-rel-showstack 

  joy-eval    { ^ ^ } ;# теперь там два элемента без скобок


  puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~ "
  #puts ""

  #v3_init_null 

  #   joy-eval    "2 3 + ."
  
  #   joy-eval    "2 3 * ^"
  
  #   joy-eval    {
  #       DEFINE ccc == concat ; cc2 == concat.
  #       [2 3] [4 5] ccc ^
  #       [2 3] [8 9] cc2 ^
  #   }
  
  #  joy-rel-showstack 
  
}
################################################################################
#
#-------------------------------------------------------------------------------
proc run_i_v3prg {v3_prg valstack} {

  #set v3_prg [joy_functext_to_v3_code  $joy_prg]

  v3_init_SIMP ; # context

  #if {$::ctx == 0} {
  #  set ctx [v3_init_context]
  #}

  # положили начальное значение в стек, потом программу и выполнили ее
  #joy-eval "$valstack $prg"
  
  # можно либо в стек сразу положить JIN-значение (список), либо к программе
  # присоединить, она сама при выполнении попадет в стек данных


  #puts "valstack = $valstack"
  #set valstack {integer 2}
  #puts "valstack = $valstack"
  #puts "valstack2 = $valstack"

  push  $valstack

#   set v3_prg [concat {integer 2} $v3_prg]

  # надо бы перехватывать полностью аварию
  #     
  #if {[catch {JIN_eval  "$v3_prg"} err]} {}
  if {[catch {run_v3_src $v3_prg} err]} {

    puts "run_i_v3prg .. err = $err"
    #return $err
    exit
  }


  # взяли со стека предпологаемый результат
  # 
  set e   [pop ]

  # преобразовали его из внутреннего в JOY-формат
  # 
  set ret [v3->joy $e]

  #set ret 1

  return $ret
}
#-------------------------------------------------------------------------------
proc getresult_i_v3prg {v3_prg i} {

  #puts "1 ... "

  if {[catch {set result [run_i_v3prg  $v3_prg $i]} err ]} {
    set result {}
    #puts "getresult_i_v3pr .. ERROR  = $err"

  } else {
    #puts "getresult_i_v3pr .. result = $result"
  }

  return $result
}
#-------------------------------------------------------------------------------
proc length_v3_prg {v3_prg} {

  llength $v3_prg

}
#-------------------------------------------------------------------------------
proc squareFitness_v3 {v3_prg} {

  set fitness 0

  #foreach i {1 2 3 4 5} o {1 4 9 16 25} {}
  foreach i {1 2 } o {1 4 } {

    # формируем код v3 lдля переменной
    
    set i_v3 "integer $i" 
    #set i_v3 [joy_functext_to_v3_code  $i] ;# ??? список ?

    set result [getresult_i_v3prg  $v3_prg $i_v3]
 	
    puts "i_v3   = $i_v3"
    puts "result = $result"
    puts ""

    if {$result eq {}}  {

      #puts "NOT run? NOT result !!"
      #exit
      incr fitness 1000 ;# при каждой ошибке добавляем дельту
    } else {

      set delta [expr {abs($o-$result)}]

      if {$delta > 1000} {
        # anti overflow
        set delta 1000
      }
      incr fitness $delta
    }
  }
    
  #return [expr {$fitness + [llength $joy_prg]}]
  #return [expr {$fitness + [length_v3_prg $v3_prg]}]
  return $fitness

}
#---------------------------------------------------------------------------
proc TEST_fitness {} {


  V3_INIT_03  ;# куча дополнительных функций


  set joy_prg {dup *}

  #   set fit [squareFitness_new $joy_prg]  
  #   puts ""
  #   puts "joy_fit = $fit"
  #   puts ""

  set v3_prg [joy_functext_to_v3_code  $joy_prg]

  puts ""
  puts "joyprg = $joy_prg"
  puts "v3_prg = $v3_prg"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  set fit [squareFitness_v3 $v3_prg]

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  puts "v3_fit = $fit"

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_readfile {} {

  puts ""


  v3_init_SIMP
  

  # зачитаем (т.е. скомпилируем) ядро системы (уже заданные функции на Joy)
  #joy-eval [set ::joy_sources] ;# скормим определения встроенные
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #run_joy_file "i__00.joy"

  #set fname "i__00.joy"
  #set fname "1__00.joy"
  #set fname "1__00.joy"

  set fname "2_tst0.jt"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # не будем включать include на стадии препроцессинга
   
  #set r_text_all [read_file_to_rtext             $fname]
  

  # включим include на стадии препроцессинга
  
  set r_text_all [readfile_to_rtext_with_include $fname]
  
  puts "r_text_all = $r_text_all"


  # компилируем joy-программу в словарь 
  # 
  joy-compile $r_text_all


  puts "defarr = $defarr"

  v3_print_all 
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return

  # j~.tl 3333 TEST_readfile
  # 
  # Ошибка: не хватает каких-то определений
  # 

  run_v3_current_prog_from_begin 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  return
}
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/23526   
# pdict: Pretty print a dict
#RS 2014-08-05 Here is my version, working similar to parray:
#-------------------------------------------------------------------------------
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

   return
}
#-------------------------------------------------------------------------------
proc v3_print_all {} {


  set fd "stdout"
  #set fd "stderr"

  puts $fd ""
  puts $fd "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  
  puts $fd "ALL PRINT : \n"
  puts $fd ""

  puts $fd "builtin_glob: [array names ::builtin_glob]"
 
  puts $fd ""
  puts $fd "defined_glob: "

  # здесь хорошо бы распечатать более красиво:
  #
  puts $fd ""
  pdict  $::defined_glob

  puts $fd ""
  puts $fd ""
  #puts $fd "current  : [$::ctx.current]"
  puts $fd "current  : [dict_get $::ctx_NEW current]"

  puts $fd ""

  #puts $fd "ip       : [$::ctx.ip]"
  puts $fd "ip       : [dict_get $::ctx_NEW ip]"
  puts $fd ""

  puts $fd "datastack: $::ST"

  puts $fd ""
  puts $fd "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts $fd ""

  #baza_user_types 
  #baza_user_symbols 

}
##-------------------------------------------------------------------------------
proc TEST_inn_03 {} {


  V3_INIT_01 

  v3_init_SIMP

  # формируем тест основной программы последовательно:
  # 
  v3_add_code {} {{integer 1} {integer 2} {symbol +} {symbol ^}}
  v3_add_code {} {{integer 2} {integer 3} {symbol +} {symbol ^}}

  # распечатаем инфу
  #
  v3_print_all 

  # указатель на начало и вперед
  #
  run_v3_current_prog_from_begin 

  puts ""

}
#-------------------------------------------------------------------------------
proc run_v3_src {v3_prg} {


  #run_v3_current_prog_from_begin 

  #set current [v3_current_get ]

  # joy-run_from_begin
  # идем циклом по буферу команд слева направо
      
  #joy_ip_set_ 0 ;# !! ??
  set ip 0

  set len [llength $v3_prg] ;# [joy_len_get_]

  while {1} {

    #set ip  [joy_ip_get_ ] ;# получили текущий указатель на программу ??
    #set len [joy_len_get_] ;# ??

    if {$ip >= $len} break
      
    # текущая программа, указатель и команда на выполнение
    #
    #set current [v3_current_get ] ;# ?? меняется при чтении с файла??
    #
    #set ip      [joy_ip_get_ ]

    #set op      [lindex $current $ip]      
    set op      [lindex $v3_prg $ip]      
    

#     if {$::joy::debug} {

#       puts ""
#       print_retstate  
#       gena_show_joylist  [joy_datastack_get_ ] "DATASTACK: "  -1  GREEN DEFAULT

#       print_curstate 
#       #puts ""
#     }

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    #joy_ip_incr_  ;# уже заранее увеличим указатель 
    incr ip

    #  чтобы, если уйдем на подфункцию, сохранить это состояние новым
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    # а как же сделано в простом случае i-варианта ?
    # там рекурсивно выполняется встроенная функция!

    # теперь смотрим, что это за текущая операция:
    # 
    parse_op $op  op_type op_vals


    # ------------------------------------------------------
    #set user_types   [$::ctx.baza_user_types]
    set user_types [get_baza_user_types] 

    #set user_symbols [$::ctx.baza_user_symbols]
    set user_symbols [get_baza_user_symbols] 

    # ------------------------------------------------------
    if       {[check_defined_user_name_prog  $user_types $op_type $op_vals]} {

    } elseif {[string match "symbol" $op_type]}  { 

      set symbol $op_vals ;# здесь "символ", будем с ним разбираться
      
      if  {[check_defined_user_name_prog  $user_symbols $symbol $symbol]} {

      } else {

        run_builtin_or_defined_func  $symbol
      }

    # ------------------------------------------------------
    } else {
    # ------------------------------------------------------

      Debug "          -> STACK"
      push  $op 

    }
    # ------------------------------------------------------


  } ;# while end
  

}
#-------------------------------------------------------------------------------
proc TEST_inn_05 {} {


  V3_INIT_01 

  set ctx [v3_init_null] ;# без встроенных DEFINE, остаются


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v3_make_tclproc "dup" {

    set e [pop ] ;# вытащили значение из стека

    push   $e    ;# положили обратно два раза
    push   $e    ;#   
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  set v3_prg {{integer 3} {symbol dup} {symbol *}}

  v3_add_code {} $v3_prg

  # распечатаем инфу
  #
  v3_print_all 

  puts ""

  # указатель на начало и вперед
  #
  run_v3_current_prog_from_begin 

  set e   [pop ]
  puts "EE = $e"


  # а хорошо бы по-простому запускать: 
  # 
  #JIN_eval $v3_prg 
  run_v3_src $v3_prg 

  puts "EE = [pop ]"


  # а еще лучше - без использования current!
  # 
  #run_v3_src  $v3_prg
  #puts "EE = [pop ]"

  puts ""

}
#-------------------------------------------------------------------------------
# === Runtime error: Definition needed for 'unary2' ===
# 
#-------------------------------------------------------------------------------
# void unary2_()
# {			/*   Y  Z  [P]  unary2     ==>  Y'  Z'  */
#   THREEPARAMS("unary2");
#   ONEQUOTE("unary2");
#   SAVESTACK;

#   stk = SAVED2->next;				/* just Y on top */
#   exeterm (SAVED1->u.lis);			/* execute P */
#   dump1 = newnode (stk->op, stk->u, dump1);	/* save P(Y) */
#   stk = newnode (SAVED2->op, SAVED2->u,
#                  SAVED3->next);			/* just Z on top */
#   exeterm(SAVED1->u.lis);			/* execute P */
#   dump1 = newnode (stk->op, stk->u, dump1);	/* save P(Z) */
#   stk = dump1; dump1 = dump1->next->next; stk->next->next = SAVED4;

#   POP (dump);
#   return;
# }
#-------------------------------------------------------------------------------
# unary     X [P] -> R
# 	    Executes P, which leaves R on top of the stack. No matter how many 
#           parameters this consumes, exactly one is removed from the stack.

# unary2    X1 X2 [P] -> R1 R2
# 	    Executes P twice, with X1 and X2 on top of the stack. 
#           Returns the two values R1 and R2.
#-------------------------------------------------------------------------------
proc TEST_unary {} {


  #   puts "------------------------------------------------------------"
  #   puts "::joy_sources = $::joy_sources"
  #   puts "------------------------------------------------------------"
  #   return
  

  V3_INIT_03  ;# куча дополнительных функций

  #
  #v3_init_SIMP
  #joy-compile  $::joy_sources

  #puts "::joy_sources = $::joy_sources"

  puts ""

  joy-eval {

    DEFINE mysquare   ==   dup  * .
    DEFINE unary == (X1 P)  $X1 $P i  .

    2 3 [mysquare] unary2  . .
  }

  return
}
#-------------------------------------------------------------------------------
proc TEST_unary2 {} {


  V3_INIT_03  ;# куча дополнительных функций


  puts ""

  joy-eval {

    DEFINE mysquare   ==   dup  * .
    DEFINE unary2 == (X1 X2 P)  $X1 $P i   $X2 $P i  .

    4 5 [mysquare] unary2  . .
  }

}
#-------------------------------------------------------------------------------
proc TEST_argc_argv {} {
    

  V3_INIT_03  ;# куча дополнительных функций

  
  puts ""
  
  joy-eval {
    
    argc .
    argv .
  }
  
}
#-------------------------------------------------------------------------------
proc TEST_cleave {} {
  

  V3_INIT_03  ;# куча дополнительных функций

  
  puts ""
  
  #[2 5 3 2]      0  [+]  fold .
  #[3 5 ] dup  0  [+]  fold  swap  size  / .
  #  DEFINE cleave == (X P1 P2) 22 2 .
  #  DEFINE cleave == (X P1 P2)  $X $P1 i   $X $P2 i .
  
  # вычисляем среднее значение списка чисел, используя функцию "cleave", т.е.
  # получая два значения в рузультате последовательного применения к исходному
  # списку двух функций
  
  joy-eval {
    [5 5 7 7]     [0  [+]  fold]  [size]  cleave  / .
  }
  
}
#-------------------------------------------------------------------------------
proc TEST_simp {} {

  puts ""
  
  V3_INIT_03  ;# куча дополнительных функций

  
  joy-eval   "1 2 + ^"
  joy-eval   "2 3 + ^"
  joy-eval   "2 3 * ^"
  
  #joy-rel-showstack 

  puts ""
  puts "----------------------------------"
  puts ""

  v3_init_null
 
  joy-eval   "3 2 1  ." 
  joy-eval   "       ." 
  joy-eval   "       ." 


  puts ""
  puts "----------------------------------"
  puts ""

  joy-eval   { [1 2]    .} 
  joy-eval   { [1 2]  i  }
  joy-rel-showstack 

  puts ""
  puts "----------------------------------"
  puts ""

  joy-eval   { [3]    .}  
  joy-eval   { [3]  i .}

  puts ""
  puts "----------------------------------"
  puts ""

  v3_init_null

  joy-eval    { [2 3 +] i }  ;# раскрываем и сразу выполняем ??
  joy-rel-showstack          ;# 3
  puts "EE = [pop ]"

  puts ""

  v3_init_null

  joy-eval   { [1 2 3]  [4 5 6 7]  .  .}  

  joy-eval   { [1 2 3]  [4 5 6 7]  concat .}  

  puts ""

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc run_joy_file {fname} {


  # не будем включать include на стадии препроцессинга
  # 
  set r_text_all [read_file_to_rtext   $fname]
  
  #puts "run_joy_file: r_text_all = $r_text_all"
  #puts "======================================"

  joy-compile  $r_text_all

  #puts "======================================"

  if {$::joy::debug} {
    v3_print_all 
  }
  
  run_v3_current_prog_from_begin 

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_00 {} {


  V3_INIT_03  ;# куча дополнительных функций

  puts ""

  #set ::joy::debug 1

  run_joy_file "j__00.joy"

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_01 {} {


  V3_INIT_03  ;# куча дополнительных функций
  
  puts ""

  #set ::joy::debug 1

  run_joy_file "j__01.joy"

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_02 {} {


  V3_INIT_03  ;# куча дополнительных функций
  
  puts ""

  run_joy_file "j__02.joy"

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_03 {} {


  V3_INIT_03  ;# куча дополнительных функций
  
  puts ""

  run_joy_file "j__03.joy"

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_06 {} {


  V3_INIT_03  ;# куча дополнительных функций
  
  puts ""

  run_joy_file "j__06.joy"

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_07 {} {


  V3_INIT_03  ;# куча дополнительных функций
  
  puts ""

  run_joy_file "j__07.joy"

  return
}
#-------------------------------------------------------------------------------
proc v3_redefine_NEW {} {



  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  proc joy-call {code} {

    #puts "This is NEW ..... joy-call ! code = $code"

    run_v3_src  $code ;# просто вызываем, используя стек Tcl
   
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v3_make_tclproc "ret" {
    
    #puts "ret ...."

  }
  #-----------------------------------------------------------------------------

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc TEST_main {} {

  global argc argv
  
  #set ind 1
  
  V3_INIT_03  ;# куча дополнительных функций

  puts ""

  # если нет доп. параметров (только имя ?), то работаем интерактивно

  if {$argc == 1} {
    joy-rel 
    
  } else {

    # первым параметром д.б. имя файла скрипта
    # лучше от конца считать?

    set last_arg  [lindex $argv end]

    # ---------------------------------------------
    # может быть и дополнительный флаг для отладки
    # например: j~.tl TEST_main j__00.joy @
    
    if {$last_arg == "@"} {

      set ::joy::debug 1
      DebugOn
      set fname [lindex $argv end-1]

    } else {
      set fname $last_arg
    }

    #puts "fname = $fname"
    #return

    # ---------------------------------------------
 
    v3_run_file  $fname

    joy-rel-showstack  ;# а это зачем тут??

    # ---------------------------------------------
   }
  
}
#-------------------------------------------------------------------------------
proc doinclude {fname} {


  # не будем включать include на стадии препроцессинга
  # 
  set r_text_all [read_file_to_rtext   $fname]
  
  #puts ""
  #puts ""
  #puts "run_joy_file: r_text_all = $r_text_all"
  #puts ""
  #puts "========================================================================"
  #puts ""

  joy-compile  $r_text_all

  #puts "========================================================================"
  #puts ""

  #if {$::joy::debug} {
  #v3_print_all 
  #}
  
}
#-------------------------------------------------------------------------------
proc set_language_JOY_CANONICAL {} {


  #V3_INIT_01 

  #V3_INIT_02 

  V3_INIT_03 

  doinclude "inilib.joy" ;# ? 

  doinclude "usrlib.joy" 

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc compile_joy_to_33 {joy_prg} {

  # компилируем joy-программу в словарь tcl-списков, в том числе и в главную
  # программу {}.

  # TODO: это хорошо, но надо бы сделать "игтерпретатор", т.е. прямо 
  # последовательное
  # выполнение инструкций, без общей сборки главной программы {} ???


  set namecodedict [joy-compile_to_namecodedict $joy_prg]

  v3_add_to_defined  namecodedict


  set main_prog [v3_defined_get_by_name {}] 

  return $main_prog
}
#-------------------------------------------------------------------------------
proc run_joy_prg_compiled {joy_prg} {


  set main_prog [compile_joy_to_33  $joy_prg]

  puts "main_prog = $main_prog"

  run_v3_src  $main_prog

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
proc TEST_all_files_by_V3 {} {

  puts ""

  set_language_JOY_CANONICAL 

  #run_v3_current_prog_from_begin 

  puts ""

  # проверить на общих тестах JOY, где-то была ошибка?  возможно связанная с 
  # компиляцией?  сделать интерпретатор ??

  #--------------------------------------------

  #   i_main grmtst.joy J 
  #   i_main i__01.joy 
  #   i_main i__02.joy 
  #   i_main i__03.joy ARGGG 
  #   i_main joytut.inp J 
  #   i_main jp-church.joy J 
  #   i_main jp-joytst.joy J 
  #   i_main jp-nestrec.joy J 
  #   i_main laztst.joy J 
  #   i_main lsptst.joy J 
  #   i_main modtst.joy J 
  #   i_main mtrtst.joy J 
  #   i_main plgtst.joy J 
  #   i_main symtst.joy J 
  
  #--------------------------------------------

  #set ::joy::debug 1

  #--------------------------------------------

  #run_joy_file "grmtst.joy"  

  run_joy_file "j__00.joy"  
  run_joy_file "j__01.joy"  
  run_joy_file "j__02.joy"  
  run_joy_file "j__03.joy"   ;# ARGGG 

  puts ""

  # ERROR
  #
  run_joy_file "joytut.joy"  
  #
  # {"time",		time_,		"->  I",
  # "Pushes the current time (in seconds since the Epoch)."},

  # v3_run_file ??? (with include ?)

  #--------------------------------------------

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_new_02 {} {

  v3_init_SIMP  ;# _context

  joy-compile  { [2 3 +  ^] ^ }


  # joy-rel-showstack 

  #joy-eval     { [2 3 +  ^] ^ }
  #joy-rel-showstack 

}
#-------------------------------------------------------------------------------
# k~.tl JOY3  TEST_new_02 
#
#-------------------------------------------------------------------------------
proc TEST_test {} {


  V3_INIT_01


  # распечатаем инфу
  #
  puts ""
  v3_print_all   


  run_v3_src  {{integer 3} {symbol dup} {symbol *}}
  puts "EE = [pop ]"

  run_v3_src  {{integer 3} {symbol dup} {symbol *}}
  puts "EE = [pop ]"

  puts ""

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set src_JY {[2 3 +] i } ;# раскрываем и сразу выполняем 


  # без использования "current" !
  # 
  v3_redefine_NEW 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set src_33 [compile_joy_to_33  $src_JY]


  run_v3_src  $src_33
  puts ""
  puts "run_v3_src = [pop ]"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  V3_INIT_03

  set prog_33 [compile_joy_to_33  {"John Smith"  ['Z >]  filter .}]

  run_v3_src  $prog_33

  puts ""


  #---------------------------------------------------

  #TEST_test_11_22 

  #---------------------------------------------------

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc  convert_33_to_11 {src_33  &src_11} {

  USE_REFS

  #set src_11 {}

  #convert_00_to_22  $src_33  src_22
  #convert_22_to_11  $src_22  src_11

}
#-------------------------------------------------------------------------------
proc translate_ndict_33_to_11 {&ndict} {

  USE_REFS

  dict for {symbol code} $ndict {

    #puts "symbol= $symbol"
    #puts "code33= $code"

    set src_11 {}

    convert_33_to_11  $code  &src_11

    #puts "code22= $src_22"
    #puts ""

    dict set ndict $symbol $src_11
  }

}
#-------------------------------------------------------------------------------
proc TEST_test_11_22 {} {


  # без использования "current" !
  # 
  v3_redefine_NEW 

  V3_INIT_01


  set src_JY {[2 3 +] i } ;# раскрываем и сразу выполняем 

  set src_33 [compile_joy_to_33  $src_JY]


  set src_11 {}
  set src_22 {}

  convert_33_to_22  $src_33  src_22
  convert_22_to_11  $src_22        src_11

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  puts "src_JY = $src_JY"
  puts "src_33 = $src_33"  
  puts ""
  puts "src_11 = $src_11"
  puts "src_22 = $src_22"

  v1_init_all 
  run_v1_src  $src_11


  puts ""
  puts "run_v1_src = [pop ]"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# TODO:
# 

# - j~.tl 3333 TEST_test 


# повторить все тесты JOY в формате v3
#

# - j~.tl 3333 TEST_all_files_by_V3

# - k~.tl 3333 TEST_file_v1

################################################################################


