# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
if [info exists ::F_PROG_TL] {
  return
} else {
  set  ::F_PROG_TL ""
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# /*
#  * Constant definitions.
#  */

# // к сожалению DBL_MAX и DBL_MIN используется в алгоритмах мутации, случ. чисел
# // и т.д. поэтому просто так поменять не получистя !
# // 

# /* Define lower bound on fitness. */
# #define GA_MIN_FITNESS			-DBL_MAX

# DBL_MAX is defined in <float.h>. Its availability in <limits.h> on unix 
# DBL_MAX = 1.79769e+308
#

set ::DBL_MAX  999999999999999999
set ::DBL_MIN -999999999999999999


# set ::DBL_MIN 0.000000 
# set ::DBL_MAX 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000 

#set ::GA_MIN_FITNESS 999999999999999999
#set ::GA_MIN_FITNESS [expr {- $::DBL_MAX}]

#set ::GA_MIN_FITNESS  $::DBL_MIN
#set ::GA_MIN_FITNESS  $::DBL_MAX

#set ::GA_MIN_FITNESS  -9999 
#set ::GA_NOT_FIT   "NOT-FIT"
set ::GA_NOT_FIT   "NOT"

;#  - почему-то ошибка на  g_ping.tl _sa  1 1 1
#                                неверная инициация?  @@@@@@@
#set ::GA_MIN_FITNESS  ABCD 

# ------------------------------------------------------------------------------
# g~.jm ALL_TESTS

package require tcltest
namespace import tcltest::*

# ----------------------------------------------
# формируется динамически (словарная библиотека)

set ::gp_dict [dict_create]


biblio_push $::gp_dict ;# запихнуть в глобальную библиотеку 
#
# ?????

set ::gp_dict_NUMER 0 ;# для имен в динамическом словаре

#-------------------------------------------------------------------------------
proc gp_list_to_librarys {gp_list} {

  # если src == {}, то это tcl-функция ?

  set bibl  [list "p3" {src {}}] 

  librarys_push $bibl ;# запихнуть в глобальную библиотеку 

}
#-------------------------------------------------------------------------------
proc gp_dict_print {} {


  set dict [set $::gp_dict]

  dict for {key val} $dict {

    set src [dict get  $val "src"]
    puts "$key : $src"
  }

}
# ------------------------------------------------------------------------------
proc argo_print {argo} {

  puts ""
  puts "argo = $argo"
  puts ""

  #dict_print_real $argo 
  #dict_print $argo  "ARGO" "true" 
  dict_print $argo  "" "true" 


}
# ------------------------------------------------------------------------------
################################################################################
proc dict_parse_all_minus {d args} {

  dict for {key value} $args {

    set key [string trimleft $key "-"] ;# убираем слева минус, зачем?

    SET $d  $key $value
  }

}
#-------------------------------------------------------------------------------
proc task_create {args} {

  set t [dict_create]


  SET $t fit_tobest  "MIN" ;# т.е. чем меьше, тем лучше 
  SET $t fit_target  0
  SET $t fit_error   0.01

  #SET $t randinstr   "randinstr_MAIN" 
  SET $t quotes_proc "quotes_proc_NULL"

  
  SET $t ios_BEGIN {} ;# входы/выходы списком типов
  SET $t ios_FINAL {}

  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #
  dict_parse_all_minus $t {*}$args ;# заносив убирая минусы если что-то есть !
  #
  # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  set ios_BEGIN [GET $t ios_BEGIN] 
  set ios_FINAL [GET $t ios_FINAL] 

  SET $t ios_begin  [llength $ios_BEGIN] ;# входы/выходы размерами списков IOS_begin
  SET $t ios_final  [llength $ios_BEGIN] ;#  


  #SET $t gp_list "MUT"

  return $t
}
#-------------------------------------------------------------------------------
proc task_print {t} {

  puts "-------------------------- task --------------"
  puts "fit_func = [GET $t fit_func]"
  puts "fit_target   = [GET $t fit_target]" 
  puts "fit_error    = [GET $t fit_error]" 
  puts "-------------------------- task --------------"
  puts ""

  return $t
}
################################################################################
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# программная статистика

set ::IOS {}      ;# можно вполне оставить как есть

#set ::IOS_begin 0 ;# эти параметры нужно в TASK -ios_begin 
#set ::IOS_final 0

# ------------------------------------------------------------------------------
proc ios_add_new {name INP OUT} {

  set params {}
  
  #set   I [dict get $params "I"] ;#  входные типы
  #set   O [dict get $params "O"] ;# выходные типы

  set inp [llength $INP] ;# [dict get $params "inp"] ;# сколько берет из стека
  set out [llength $OUT] ;# [dict get $params "out"] ;# сколько кладет

  set sum [expr {- $inp + $out}]

  dict set params "inp" $inp
  dict set params "out" $out
  
  dict set params "INP" $INP
  dict set params "OUT" $OUT
    
  #puts "ios_add_new: params = $params"

  dict set ::IOS  $name $params    ;# name {"inp" 0 "out" 0}
  dict set ::IOS  $name "sum" $sum ;# name {"inp" 0 "out" 0  "sum" 0}
}
# ------------------------------------------------------------------------------
# proc ios_add {name params} {

#   set   I [dict get $params "I"] ;#  входные типы
#   set   O [dict get $params "O"] ;# выходные типы

  
#   ios_add_new $name $I $O
#   return


#   set inp [llength $I] ;# [dict get $params "inp"] ;# сколько берет из стека
#   set out [llength $O] ;# [dict get $params "out"] ;# сколько кладет

#   set sum [expr {- $inp + $out}]

#   dict set $params "inp" $inp
#   dict set $params "out" $out

#   dict set ::IOS  $name $params    ;# name {"inp" 0 "out" 0}
#   dict set ::IOS  $name "sum" $sum ;# name {"inp" 0 "out" 0  "sum" 0}
# }
# ------------------------------------------------------------------------------
#ios_init 
#-------------------------------------------------------------------------------

#namespace import ::struct::*

#-------------------------------------------------------------------------------

set ::GA_BOLTZMANN_FACTOR	1.38066e-23

set ::ISPRINT 0

# #define GA_TINY_DOUBLE		(1.0e-9)

#-------------------------------------------------------------------------------

# item - это prog через указатель !!

#-------------------------------------------------------------------------------
#  ENTITY_T    ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T
#-------------------------------------------------------------------------------

# (defstruct ORGANISM  
#   genotype  ; project program 

#   (standardized-fitness 0)
#   (adjusted-fitness     0)
#   (normalized-fitness   0)
#   (hits                 0)
# )

# record define ENTITY_T {

#   chrom_some ;# vpointer* : The chromosomes (the genotype)
#   ch_form    ;# "% 6.3f" ;#  " %02d"

#   fitness    ;# double    : Fitness score
#   # vpointer  data; // User data containing physical properties. (the phenotype)
# }

#-------------------------------------------------------------------------------
proc make_list {num val} {

  set ret ""

  for {set i 0} {$i < $num} {incr i} {

    lappend ret $val
  }

  return $ret
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc item_set_mainsrc {item ch} {


  SET $item "main" "src" $ch

}
#-------------------------------------------------------------------------------
proc item_get_mainsrc {item} {


  return [GET $item "main" "src"]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc item_get_main_src {item} {

  set prog [item_get_prog $item]

  return [prog_get_prg_src $prog "main"]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# ITEMS - со струкурой реальных программ (ьфшт)
# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc item_create {len_chromosome} {
    
  set item [dict_create]
  
  # зачем здесь задавать жесткую длину ??
  # 
  set tmp  [make_list $len_chromosome "@"]

  item_set_mainsrc $item $tmp
          
  SET $item ch_form    "%s " ;#  " %02d" "% 6.3f " 
 
  return $item
}
#-------------------------------------------------------------------------------
proc item_CH {item} {


  return [item_get_mainsrc $item]

}
#-------------------------------------------------------------------------------
proc item_set_chromo_gen {item i val} {
  
  set  tmp [item_get_mainsrc $item]

  lset tmp $i $val

  item_set_mainsrc  $item $tmp

  return
}
#-------------------------------------------------------------------------------
proc item_get_chromo_gen {item i} {

  set  tmp [item_get_mainsrc $item]
  
  return [lindex $tmp $i]
}
#-------------------------------------------------------------------------------
proc item_get_chromo_len {item} {

  set  tmp [item_get_mainsrc $item]
  
  return [llength $tmp]
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc item_make {{src @}} {

  set item [dict_create]
  
  dict_set $item  "main" [list "src" $src]

  item_set_fitn   $item $::GA_NOT_FIT ;# "@"  ;# $fitness

  return $item ;# указатель на словарь
}
#-------------------------------------------------------------------------------
proc item_set_fitn {item fitness} {


  dict_set  $item "fitn" $fitness

}
#-------------------------------------------------------------------------------
proc item_get_fitn {item} {

  # dict get работает не с именем, а непосредственно со словаоем, и получить его 
  # можно используя $name, либо надежнее, если имя уже по ссылке, то [set $name]

  #puts "item_get_fitn: iten = $item"

  return  [dict_get  $item "fitn"]

}
#-------------------------------------------------------------------------------
proc item_get_prog {item} {

  # item - это prog через указатель !!

  return [set $item]

}
#-------------------------------------------------------------------------------

set ::is_fitn_first 1

#-------------------------------------------------------------------------------
proc item_print {item} {

  set src   [item_get_main_src   $item] 
  set fitn  [item_get_fitn       $item] 

  if {$::is_fitn_first} {
    puts [format "  fitn = %s :   %s" $fitn $src]
  } else {
    puts [format "  %s     fitn = %s" $src $fitn]
  }

  return 
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc item_as_string {item ch_form} {

  if {$ch_form == ""} {
    set ch_form [GET $e ch_form] ;# локальная переменная
  }

  set ch  [item_get_mainsrc $item]
  
  set buf {}

  foreach c $ch {

    append buf [format $ch_form $c]
  } 
  
  return $buf
}
#-------------------------------------------------------------------------------
proc item_print_ch {item {name "ch=   "} {out "stdout"} {ch_form "%s "}} {


  puts -nonewline $out $name
  
  set buf [item_as_string  $item $ch_form]
  
  puts -nonewline $out $buf

  flush $out  ;# все данные должны быть выведены
}
#-------------------------------------------------------------------------------
proc item_print_oneline {item {out "stdout"} {ch_form "%s "}} {


  set fi [item_get_fitn $item]
  
  if {[string equal $fi $::GA_NOT_FIT]} {

    puts -nonewline $out "fitn = NOT_FITS"
  } else {
    puts -nonewline $out "fitn = [format "%8.3f"  $fi]"
  }
  
  item_print_ch $item " :   " $out $ch_form
  
  puts $out ""
}
#-------------------------------------------------------------------------------
proc itemlist_print {itemlist ind_form gen_form {out "stdout"}} {

  set i 1 ;# лучше с 1  ??  

  foreach item $itemlist {
    
    puts -nonewline $out [format $ind_form $i]    
    item_print_oneline $item $out $gen_form

    incr i
  }

  return
}
#-------------------------------------------------------------------------------
################################################################################

#set ::len_is_constant 0

#set ::randinstr   "randinstr_MAIN"
#set ::quotes_proc "quotes_proc_NULL"

##set ::A(news) 0


set ::gp_NEWS 0 ;# флажок формирования новейших изменений в алгоритмах:

set ::gp_DEEP 5 ;# глубина последовательности мутации

set ::gp_AUTO 0 ;# флажок применения динамического словаря

#-------------------------------------------------------------------------------
proc dict_parse_GLOBAL {name argv} {


  # set ::gp_NEWS [dict_parse $argv "::gp_NEWS"  $::gp_NEWS]

  set $name [dict_parse $argv $name  [set $name]]

}
#-------------------------------------------------------------------------------
# сфомируем совокупный на этот момент список: GP_LIST = gp_list + gp_dict
#
# !!!! TODO !!! они же разной структуры !!
#   gp_list - это простой список имен
#   gp_dict - рефльный словарь со структурой "src" ...
#
#-------------------------------------------------------------------------------
proc only_names_from_gpdict {gp_dict} {


  set d [set $gp_dict]   ;# сделали из указателя простой словарь

  set ret [dict keys $d] ;# только ключи

  return $ret
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc make_GP_LIST {gp_list gp_dict} {


  if {$::gp_AUTO} {

    set GP_LIST {} 
    
    lappend GP_LIST  {*}$gp_list ;# это заданные в задаче
    
    
    set names [only_names_from_gpdict $gp_dict] ;# формируется динамически
    
    lappend GP_LIST {*}$names ;# добавили в общий список откуда выбираем
    
    #puts stderr "gp_dict = [set $gp_dict]"
    #puts stderr "names = $names, GP_LIST = $GP_LIST"

    return $GP_LIST

  } else {

    return $gp_list
  }

}
#-------------------------------------------------------------------------------
# возвращаем случайную инструкцию
# пока упрощенный вариант -  не получается анализ аргументов
#-------------------------------------------------------------------------------
proc randinstr_MAIN {gp_list} {

  # здест будем еще смотреть в глобальной (пока не в локальной) формруемой библиотеке
  # ::gp_list_library, а ее формировать автоматически в ...


  set GP_LIST [make_GP_LIST  $gp_list $::gp_dict]

  set   instr [lrand_new     $GP_LIST] ;# нет уверенности в этой функции!

  return $instr
  
  #-----------------------------------------------------------
  
  #if {[llength $arglist] == 0} {} #if {$arglist eq {}}  - для Tcl-8.4 
  if {$arglist eq {}} {

    return $instr
    
  } else {
    # здесь есть примитивное предположение о конкретной ф-ции
    # с двумя параметрами - выбор константы из интервала, но
    # а что делать в общем случае??
    #
    # так может пока обойтись без таких особенностей?
    
    puts "??"
    
    info default $instr [lindex $arglist 0] l ;# возвращает TRUE
    # если для заданного параметра есть значение по умолчанию
    # (оно и записывается в переменную в конце (l)
    
    foreach {min max} $l break ;# ??? интервал для константы?

    # команда foreach используется "не по назначению", т.е. не для
    # организации цикла, а лишь для присвоения элементов списка
    # сразу нескольким переменным..
    # команда break нужна чтобы случайно не захватить больше
    
    return [list $instr [rand $min $max]]
  }
  
} 
#-------------------------------------------------------------------------------
proc quotes_proc_NULL {oldprg} {

  set newprg $oldprg

  return $newprg
}
#-------------------------------------------------------------------------------
# уже используется в t_ants.tl
#-------------------------------------------------------------------------------
proc lappend_BE_list {prg i1 i2 &ret} {

  USE_REFS

  set B "BEG"
  set E "END"

  #set B  "{"
  #set E  "}"

  # потом формируем саму пару:
  #

  lappend ret $B
  
  for {set i $i1} {$i <= $i2} {incr i} {
    lappend ret [lindex $prg $i]
  }
  
  lappend ret $E
  
  return
}
#-------------------------------------------------------------------------------
proc make_quotes_BE {prg} {

  set n [llength $prg]

  set paras  [make_paras $n]

  set newprg [make_quotes_by_paras  $prg $paras $n  "lappend_BE_list"]

  return $newprg
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc GET_default {d name defvalue} {

  set ret [GET $d $name]

  if {$ret == ""} {
    set ret $defvalue
  }

  return $ret
} 
#-------------------------------------------------------------------------------
# создать случайную программу (список?) длиной не больше 'n' или равно ??
# 
#-------------------------------------------------------------------------------
proc make_randprog {task  n} {


  #set quotes_proc [GET_default $task "qproc" "quotes_proc_NULL"]

  set quotes_proc  [GET $task "quotes_proc"]
  set gp_list      [GET $task "gp_list"]

  #set randinstr   [GET $task randinstr]
  #set quotes_proc [GET $task quotes_proc]

  while {[incr n -1] >= 0} {

    set instr [randinstr_MAIN $gp_list]

    lappend prg $instr
  }
  
  # а здесь надо бы вставить скобочки, т.е. заквотить часть инструкций
  # но что тогда с длиной?

  #if {![info exist ::quotes_proc]} {
  #  set ::quotes_proc quotes_proc_NULL
  #}

  set prg [$quotes_proc $prg]


  return $prg
}
#-------------------------------------------------------------------------------
# proc get_randprog_unikum {task result 
# 			  minlen maxlen attempts max_attempts 
#                           gp_list
# 			  randinstr quotes_proc} {


#   set attempts 0

#   set prg [make_randprog  $task [comm_random_int_minmax  $minlen $maxlen] \
#             $randinstr \
#             $quotes_proc]

#   set ix [lsearch -exact $result $prg]

#   if {$ix >= 0} {
   
#    #continue ;# не возьмем уже такую же особь в популяцию  
#    # но тогда популяция станет маленькой, надо пробовать другие..
   
#    if {$attempts < $max_attempts} {
#      set prg {} ;# если попыток подряд мало, 
#      # то вернем пустой список, как сигнал, что не найдено

#    }  else {
#      # а иначе пусть останется дубляж ..
#      puts "NOT FIND:  $prg"
#    }
   
#  }
 
#  return $prg 
# }
#-------------------------------------------------------------------------------
# создаем начальную популяцию программ с заданным числом особей
# и с размерами в заданном интервале (UNICUM) 
#
# n - требуемое кол-во особей в популяции
#
#-------------------------------------------------------------------------------
proc make_rand_prgpop_unikum {task n 
                              minlen maxlen 
                              gp_list} {

  set prgpop {}

  set attempts      0
  set max_attempts  [expr {$n / 3}] 

  # счетчик увеилчим в конце 
  # 
  for {set i 0} {$i < $n} {} {
    
    # set p [get_randprog_unikum  $task $prgpop \
    # 	     $minlen $maxlen                  \
    #          $attempts $max_attempts          \
    #          $gp_list  $randinstr $quotes_proc]
    
    set p [make_randprog  $task [comm_random_int_minmax  $minlen $maxlen]]


    # проверим, есть ли уже такой итем (программа) в популяции
    # 
    set ix [lsearch -exact $prgpop $p]
    if {$ix >= 0} {set prg {} ;}
    

    if {$p == {}} { 

      # неудачная по пытка создания уникума
      #puts "NOT find PRG !! attempts = $attempts"

      #incr  attempts ;# сколько неудачных попыток уже было
      continue 

      # но тогда популяция станет маленькой, надо пробовать другие..
    } else {
      set attempts 0
    }
    
    lappend prgpop $p ;# добаляем программу в популяцию !! списком !!

    incr i ;# счетчик полученных особей (надо  именно здесь)
  }
  
  return $prgpop
}
#-------------------------------------------------------------------------------
# создать начальную популяцию программ с заданным числом особей и
# длинами (этих программ) из заданного диапазона

alias  make_rand_prgpop  make_rand_prgpop_unikum

#-------------------------------------------------------------------------------
# proc make_rand_prgpop {task bnums minlen maxlen  gp_list randinstr quotes_proc} {

#   set prgpop {}

#   while {[incr bnums -1] >= 0} {

#     set n [comm_random_int_minmax  $minlen $maxlen]

#     set prg [make_randprog  $task $n $randinstr $quotes_proc]

#     lappend prgpop $prg
#   }

#   return $prgpop
# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc make_prgpop {task args} {

  #puts "make_prgpop: args = $args"

  # Если забыли задать нужные параметры задачи
  #
  set lpop  [dict_parse $args "-lpop" 30]
  set lsrc  [dict_parse $args "-lsrc" 15]

  set gp_list [GET $task gp_list]

  # создаем стартовую популяцию (здесь пока только сами программы, не агенты!!!)
  # т.е. сырые заготовки в формате JOY
  #

  #----------------------------------------
  #if {$::len_is_constant} {
  #  set minlen $len
  #} else {

  set minlen 1
  #}

  set maxlen $lsrc

  #puts "make_prgpop: maxlen = $maxlen"

  #----------------------------------------
  #make_rand_prgpop make_rand_prgpop_unikum
  #set prgpop [$randpop_proc  $task \
  
  set prgpop [make_rand_prgpop_unikum  $task $lpop  $minlen $maxlen \
                $gp_list]
  
  if {$::is_print} {
    puts ""
    puts "[procname]: INIT POPULATION:~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""
    #puts stderr "randpop_proc = $randpop_proc"
    #puts stderr "randinstr    = $::randinstr"
    #puts stderr "quotes_proc  = $::quotes_proc"
    puts ""

    puts stderr "lpop = $lpop, minlen = $minlen, maxlen = $maxlen"
    puts stderr "gp_list         = $gp_list"

    puts ""
    puts "prgpop = $prgpop"
    puts ""
    #pop_print_B  $prgpop 
    #puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  \n"
  }

  return $prgpop
}
#-----------------------------------------------------------------------------
# 
#   СТРОКИ + БЛОКИ = ПРОГРАММЫ
# 
# TODO: ключевая точка роста, надо понять:
#
# - куда записывать fitness (main должна быть такой же функцией как все!)

# - в чем разница "prog" и "libra"
# - нужно ли делать через глобальные указатели ? тогда изменения будут видны сразу
#   для всех организмов
# - но можно сделать и локально, просто скопировав!

#-------------------------------------------------------------------------------
proc make_itemlist_from_prgpop {prgpop} {


  set itemlist {}
  
  # идем списком по "сырым заготовкам" - только программы
  # 

  foreach src $prgpop {

    set item  [item_make $src] ;# здесь указатели !!

    # пока фитнеса нет, только программы

    lappend itemlist  $item ;# добавляем организма (указатели)
  }

  return $itemlist
}
#-------------------------------------------------------------------------------
proc make_itemlist {task args} {
 
  #set lpop  [dict_parse $args "-lpop"]
  #set lsrc  [dict_parse $args "-lsrc" 10]

  # делаем стартовую популяцию prg
  # 
  set prgpop [make_prgpop  $task {*}$args]
 
  # а вот здесь уже можно сделать реальные программы с "main" и т.д.
  #
  set itemlist [make_itemlist_from_prgpop   $prgpop]


  return $itemlist
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------

set ::IN  {}  ;# стек интервалов зарисовки 

set ::RN 100  ;# процент случайного возврата 1

set ::proc_index 1

#-------------------------------------------------------------------------------
proc is_equal {item1 item2} {

  set len [llength $item1]

  if {$len == 1} {return $::false}

  for {set i 0} {$i < $len} {incr i} {


    if {[lindex $item1 $i] != [lindex $item2 $i]} {return $::false}
  }

  return $::true
}
#-------------------------------------------------------------------------------
proc add_num_to_item {i item w} {

  set subs [lindex $item 0]
  set nums [lindex $item 1]

  set ret [list  $subs [lappend nums $i]  $w]

  #puts "item = $item  i = $i  ret = $ret"

  return $ret
}
#-------------------------------------------------------------------------------
proc add_sub_to_list {prg  i w  &L} {

  USE_REFS


  set i_beg  $i
  set i_end  [expr $i + $w -1]   
  set sub    [lrange $prg  $i_beg $i_end]
  
  #dputs "add_sub_to_lis:   w = $w  i = $i  sub = $sub"
  

  set len [llength $L] ;# текущая длина словаря

  # смотрим в словаре, если уже есть совпадение, добавляем ссылку, если нет, то
  # добавляем запись:

  for {set d 0} {$d < $len} {incr d} {

    set item [lindex $L $d 0]

    if {[is_equal  $item $sub]} {

      # найдено совпадение, добавить номер (i, смещение) подсписка SUB 
      # в уже существующую запись словаря
      # 

      lset L $d   [add_num_to_item  $i [lindex $L $d] $w]

      return
    } 
  }

  # не найдено совпадений, добавим подсписок SUB в словарь
  # 

  lappend L  [list $sub [list $i]]

  return
}
#-------------------------------------------------------------------------------
proc substrings_to_dict_find {prg len w  &L} {

  USE_REFS

  # скользим окошком ширины "w":
  # 

  for {set i 0} {$i < [expr $len - $w +1]} {incr i} {
    
    add_sub_to_list $prg $i $w  L 
  }
  
}
#-------------------------------------------------------------------------------
proc substrings_find_by_w_expand {prg w_prev &L_prev} {

  USE_REFS

  set w [expr $w_prev + 1]

  set L_ret {}

  foreach item $L_prev {

    set subs [lindex $item 0]
    set nums [lindex $item 1]

    if {[llength $nums] == 1} {continue}

    #puts "item   = $item"

    foreach i $nums {

      add_sub_to_list  $prg $i $w L_ret 
    }

  }

  return $L_ret
}
#-------------------------------------------------------------------------------
proc clean_compressed {L} {

  set L_ret {}

  foreach item $L {

    set nums [lindex $item 1]
    
    if {[llength $nums] == 1} {continue}

    lappend L_ret $item
  }

  return $L_ret
}
#-------------------------------------------------------------------------------
proc substrings_find_all {prg start_w} {

  #set start_w 2

  set len   [llength  $prg]
  set max_w [expr $len / 2] ;# 

 
 if {0} {

   puts "substrings_find_all: ~~~~~~~~~"
   puts ""
   puts "prg   = $prg"
   puts "len   = $len"
   puts "max_w = $max_w"
   puts ""

   exit
  }


  for {set w $start_w} {$w <= $max_w} {incr w} {

    set L($w) "" ;# здесь будем складывать результаты сканирования

    #puts ""
    #puts "w = $w ........................... "
    #puts ""

    if {$w == $start_w} {

      substrings_to_dict_find  $prg $len $w  L($w) 
    } else {
      
      set w_prev [expr $w - 1]
      set L($w) [substrings_find_by_w_expand  $prg $w_prev L($w_prev) ]
    }

    
    set  L($w) [clean_compressed [set L($w)]] ;# очистим от одиночных

  }


  set ret      [dict create]
  #puts "ret = |$ret| ................  "
  set ret_list {} ;# сделаем по-новому - "новичок"

  set names [array names L]

  set sortnames [lsort -decreasing $names]

  foreach w $sortnames {

    set L_w [set L($w)] ;# items

    if {$L_w == {}} {continue} ;# оставляем только те, где есть повторения

    #puts "substrings_find_all: w = $w  L_w = $L_w" 
    # TODO: надо дописать туда w в каждый item !!!!

    #dict set ret      $w $L_w ;# для JIM получается не тот порядок
    lappend  ret_list $w $L_w
  }

  if {0} {

    puts ""
    puts "substrings_find_all: names = $names, sortnames = $sortnames"
    #puts "substrings_find_all: ret      = $ret"
    puts "substrings_find_all: ret_list = $ret_list"
    puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""

    exit
  }

  #return [list $ret] ;# уже по убыванию!
  return [list $ret_list] 
}
#-------------------------------------------------------------------------------
proc interval_set_null {} {
  
  set ::IN {}

}
#-----------------------------------------------------------------------------
proc interval_push args {
  
  # последовательно все аргументы помещаем в стек:
  # 
  # а если аргументы сами представляют списки?
  # если это список, то он добавится как список tcl, а нужно поэелментно! 
  
  foreach a $args {lappend ::IN  $a}
  
  return
}
#-----------------------------------------------------------------------------
proc interval_pop {} {
  
  # хитрый приемчик, чтобы быстро "вытащить" последний (верхний) элемент
  # стека:
  # возьмем элемент из списка, а сам список "укоротим"
  
  set element [ K [lindex $::IN end] [set ::IN [lrange $::IN 0 end-1]] ]
  
  return $element
}
#-------------------------------------------------------------------------------
proc random_set {procent} {

  set ::RN $procent

  return
}
#-------------------------------------------------------------------------------
proc random_0_or_1 {} {

  if {$::RN == 100}  {return 1}

  return [RandYes $::RN]

  #return 1 ;# пока никаких случайностей
}
#-------------------------------------------------------------------------------
proc interval_draw_check_new {i1 i2} {


  foreach i $::IN {

    set i_beg [lindex $i 0]
    set i_end [lindex $i 1]

    set is_1 [expr {$i2 < $i_beg}] ;# целиком слева  от проверяемого
    set is_2 [expr {$i1 > $i_end}] ;# целиком справа от проверяемого

    if {[expr ! ($is_1 || $is_2)]} {return $::false} ;# пересекаются?
  }

  # вроде бы место свободно, все хорошо. но !
  # можно в этом месте ввести элемент случайности

  if {[random_0_or_1] == 0} {

    return $::false ;# колесо фортуны
  }

  return $::true
}
#-------------------------------------------------------------------------------
proc interval_draw {fl_ptr  i1 i2} {

  # это более совершенный вариант, кладем в стек интервал (границы отрезка)
  # 


  if {! [interval_draw_check_new  $i1 $i2]} {return $::false}

  interval_push  [list $i1 $i2] 

  return $::true
}
#-------------------------------------------------------------------------------
proc interval_init {} {


  interval_set_null

}
#-------------------------------------------------------------------------------
# proc is_this_main {key} {

#   if {$key == "main"} {return true}

#   return false
# }
#-------------------------------------------------------------------------------
proc proc_name_index_init {{index_start 1}} {

  set ::proc_index $index_start

}
#-------------------------------------------------------------------------------
proc get_new_proc_name {} {

  set proc_name "proc$::proc_index"

  incr ::proc_index ;# увеличили индекс наименования

  return $proc_name
}
#-------------------------------------------------------------------------------
proc set_clean_items_proc {clean_items  &prog} {

  USE_REFS

  set clean_items_with_proc {}

  foreach item $clean_items {

    set proc_name [get_new_proc_name]

    set subs [lindex $item 0]
    set nums [lindex $item 1]
    set w    [lindex $item 2]

    # тут надо бы сразу добавлять в библиотеку !!
    #
    #set prog "" ;# <-------- & для Jim?

    prog_set_prg_src  prog $proc_name $subs

    # на место строки записываем уже готовое имя процедуры
    # 
    lappend  clean_items_with_proc [list $proc_name $nums $w]
  }

  return $clean_items_with_proc
}
#-------------------------------------------------------------------------------
proc find_equal_index {nums i} {

  foreach n $nums {

    if {$n == $i} {return $::true}
  }

  return $::false
}
#-------------------------------------------------------------------------------
proc find_proc_index_w {clean_items_with_proc i} {


  set p {} ;# возвращаемое значение 

  foreach item $clean_items_with_proc {

    #dputs "item = $item"

    set name [lindex $item 0]
    set nums [lindex $item 1]
    set w    [lindex $item 2]

    set is_ok [find_equal_index $nums $i]

    if {$is_ok} {
      set p $name
      break
    }
  }



  return [list $p $w]
}
#-------------------------------------------------------------------------------
proc prog_add_NEW {clean_items_with_proc  prg} {

  #set prog_ret $prog ;# просто делаем копию,  и будем заполнять

  set prg_new {}

  set i 0
  set i_max [expr [llength $prg] -1]

  #dputs ""
  #dputs "clean_items_with_proc = $clean_items_with_proc"
  #dputs "prg  = $prg"
  #dputs ""

  # поэлементо и последовательно будем преобразовывать
  # 

  while {1} {

    if {$i > $i_max} {break}

    # здесь надо искать для этого индекса, есть ли интеравл, брать его и 
    # сдвигаться, а если нет, то просто копировать итем. !!!!!!!!!

    foreach {p w} [find_proc_index_w  $clean_items_with_proc $i] {break}

    #dputs "i = $i"
    #dputs "p = $p"
    #dputs "w = $w"
    #dputs ""

    if {$p == {}} {
      lappend prg_new [lindex $prg $i]

    } else {
      lappend prg_new $p
      incr i $w
      continue
    }

    incr i
  }

  # а надо ли уж тут это заносить?
  #
  #dict set prog_ret {} $prg_new
  
  #return [list $prog_ret $prg_new]

  return $prg_new

}
#-------------------------------------------------------------------------------
proc recurse_find  {fl n0 nums w  &nums_new } {

  USE_REFS

  set len [llength $nums]


  dputs "recurse_find:  n0   = $n0"
  dputs "recurse_find:  nums = $nums"
  dputs ""
   

  # взяли первое значение и рисуем для него интервал
  # 
  
  set is_ok [interval_draw  $fl $n0 [expr $n0 + $w -1]]
  
  if {$is_ok} {
    lappend nums_new  $n0
  }
  
  

  for {set i $n0} {$i < $len} {incr i} {
    
    set ni [lindex $nums $i]
    
    recurse_find  $fl $ni [lrange $nums [expr $i +1] end] $w  nums_new      
  }

  return
}
#-------------------------------------------------------------------------------
proc clean_on_border_one_item_NEW {item fl  &ret} {

  USE_REFS

  dputs "clean_on_border_one_item_NEW:  item = $item"
  dputs ""

  # главное. чтобы хоть два отрезко не пересеклись, т.е. правильно - это их
  # все сочетания перебрать и выбрать максимальное!   будем их подсчитывать

  set subs  [lindex $item 0]
  set nums  [lindex $item 1]
  set w     [lindex $item 2]

  set len [llength $nums]

  set nums_new  "" ;# здесь и посчитаем, должно быть >= 2

   
  for {set i 0} {$i < $len} {incr i} {
    
    set ni [lindex $nums $i]
    
    recurse_find  $fl $ni [lrange $nums [expr $i +1] end] $w  nums_new      
  }

  # посмотрим. сколько вообще сформировалось "правильных" интервалов
  # 
   
  set len_new [llength $nums_new]
   
  # можно тут подумать как задавать "коэффициент рефакторинга", и потом
  # добиваться его выполнения, удаляя лишние принятые интервалы, но, наверное,
  # лучше использовать "вероятностность" ? да, но одиночная проц не проходит?

  if {[expr $len_new >= 2]} {
    
    # сформируем новый итем, c правильно уложенными интервалами
    # 
    
    lappend ret [list  $subs $nums_new $w]

    return $::true;
  }

  if {$len_new == 1} {

    # одни нас не устроит, это не "рефакторинг", надо отыграть назад
    # 

    interval_pop
  }

  return $::false; ;# не найдено пары интервалов, так и ничего не запишем.
}
#-------------------------------------------------------------------------------
proc witems_to_prog_main_NEW {prg witems} {


  set prog [list "main" {}] ;# чтобы по порядку сдеовало в начеле словаря!?

  set fl [interval_init] ;# список зарисовки интервалов

  set all_items   {} ;# избавимся от группировки по W
  set clean_items {} ;# сначала ничего нет


  dict for {w items}  $witems {

    lappend all_items {*}$items
  }

  dputs "witems_to_prog_main_NEW:  all_items   = $all_items"
  dputs ""
  dputs "-----------------------------------------"
  dputs ""

  # теперь идем по всем возможным вариантам интервалов и формируем подходящий
  # вариант распределения подстрок (подпрограмм)

  foreach item $all_items {

    #dputs ""
    #dputs "---------------------"
    #dputs ""

    clean_on_border_one_item_NEW  $item $fl  clean_items

    dputs ""
    dputs "::IN  = $::IN"
    dputs "clean_items = $clean_items"
    dputs ""
    dputs "---------------------"
    dputs ""
  }


  dputs "-----------------------------------------"
  dputs ""

  if {$clean_items == {}} {

    return [list $prog $prg] 
  }


  # и окончательно пишем библиотеку 
  # 
  dputs "clean_items           = $clean_items"
  dputs "prog                  = $prog"

  set clean_items_with_proc [set_clean_items_proc  $clean_items  prog]

  dputs "clean_items_with_proc = $clean_items_with_proc"
  dputs ""

  # меняем программу заменяя библ. процами
  # 
  set prg_new [prog_add_NEW  $clean_items_with_proc $prg]

  dputs "prg                   = $prg"
  dputs "prg_new               = $prg_new"
  dputs ""
  dputs "-----------------------------------------"
  dputs ""


  return [list $prog $prg_new] 
}
#-------------------------------------------------------------------------------
proc commit_to_from {prog_new  prog_old} {


  # а если в библиотеках совпадают имена ?? надо переименовать !!
  # 

  set prg_new [prog_get_prg_src $prog_new "main"]

  set prog_ret $prog_new

  # от "prog_old" берем только библиотеки
  #

  dict for {key value} $prog_old {

    #puts "key= $key value= $value"

    if {$key == "main"} {continue}

    # здесь надо проверять, есть ли такая проца (key/value) уже в prg_new 
    # (и по имени и по содержанию) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # 

    #dict set prog_ret $key $value 
    lappend prog_ret $key $value 
  }

  prog_set_prg_src  prog_ret "main" $prg_new ;# !!!

  return $prog_ret
}
#-------------------------------------------------------------------------------
proc set_max_starter {prog} {


  set max_numer 0 ;# будем искать максимум

  dict for {key value} $prog {

    if {$key == "main"} {continue}

    #set numer [lrange $key 0 end] ;# это же для списка !!
    set numer [string range $key 4 end]

    if {$numer > $max_numer} {set max_numer $numer}

    #puts "set_max_starter: key= $key numer= $numer max_numer= $max_numer "
  }

  proc_name_index_init [expr $max_numer + 1]

}
#-------------------------------------------------------------------------------
proc libra_refactoring {prog {start_w 2}} {

  set prog_old $prog
  set  prg_old [prog_get_prg_src  $prog_old "main"]

  dputs ""

  # можно согласовывать все имена на этом этапе рефакторинга
  # 
  # TODO: нельзя сделать рефакторинг отдельно тела MAIN программs без
  # учета продпроцедур в библиотеке !!!

  # получаем словарь для всех ширин W (исключая пустые) по убыванию
  # 
  foreach {all_witems} [substrings_find_all  $prg_old $start_w] {break}

  #puts "libra_refactoring: all_witems = $all_witems"

  # TODO: здесь надо посмотреть все имена в библиотеке
  # и установить стартер (начальный номер?)
  #
  set_max_starter  $prog_old ;#??

  # возвращает отдельно библиотеку, отдельно программу
  # 
  foreach {prog prg_new} [witems_to_prog_main_NEW  $prg_old $all_witems] {break}


  # занесем главную программу
  # 
  prog_set_prg_src  prog "main" $prg_new

  dputs "prog_old = $prog_old"
  dputs "prog     = $prog"
  dputs ""

  set    prog_new [commit_to_from  $prog $prog_old] 

  return $prog_new
}
#-------------------------------------------------------------------------------
proc proc_find  {prog p} {

  if {[dict exists $prog $p]} {

    #set f [dict get $prog $p]
    set f [prog_get_prg_src $prog $p]

  } else {

    set f {}
  }

  return $f
}
#-------------------------------------------------------------------------------
proc make_unfactoring_prog {prog_old} {

  set prog_new {}
  set  prg_new {}

  set prg_old [prog_get_prg_src $prog_old "main"]

  foreach p $prg_old {

    #puts "p = $p"

    set f [proc_find  $prog_old $p]
    
    if {$f == {}} {

      lappend prg_new $p ;# нет такого имени в библиотеке, просто копируем
    } else {
      lappend prg_new {*}$f
    }


  }

  #dict set prog_new "main" $prg_new
  prog_set_prg_src  prog_new "main" $prg_new

  return $prog_new
}
#-------------------------------------------------------------------------------

# http://www.wellho.net/mouth/3638_Sorting-dicts-and-arrays-in-Tcl.html

# Once version 8.6 ofTcl gets to a production release (and you have it on all 
# your systems), you'll be able to use the -stride and index options on lsort, 
# which will directly return you a sorted dict if you pass in a parameter 2 to 
# the stride. Thus:

#  lsort -stride 2 {grapefruit 10 banana 110 cherry 25}
# will return
#  banana 110 cherry 25 grapefruit 10

# and
#  lsort -stride 2 -index 1 -integer {grapefruit 10 banana 110 cherry 25}
# wlll return
#  grapefruit 10 cherry 25 banana 110

#-------------------------------------------------------------------------------
proc dict_sort {d} {

  if {$::__TCL__} {

    return [lsort -stride 2 $d]
  } else {

    # в JIM такого ключа нет, но тут, похоже и не нужна сортировка?
    # 
    return $d
  }

}
#-------------------------------------------------------------------------------
proc canonical_form {prog} {

  set prog_ret {}

  dict for {key value} $prog {

    #puts "canonical_form: key= $key value= $value"

    set prg_src [dict get $value "src"]    
    #dict set prog_ret $key $prg_src
    lappend prog_ret $key $prg_src

  }

  # но словарь может быть в произвольном порядке 
  # поэтому надо бы отсортировать по алфавиту

  set prog_ret [dict_sort $prog_ret] 

  return $prog_ret
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
################################################################################
# 
#  T R A N S F O R M    T R A N S F O R M    T R A N S F O R M    
# 
################################################################################


#set ::item_OLD 0

#set ::OLD 0

#-------------------------------------------------------------------------------
proc string_replace_first {prg_old str1 str2  &ind_start} {

  USE_REFS

  set str1_len [string length  $str1]
  set str2_len [string length  $str2]

  set  i1 [string first $str1 $prg_old $ind_start]

  if {$i1 == -1} {
    # return 0  ;# можно наверное придумать признак какой-нибудь..
    set ind_start -1
    return $prg_old
  }

  set i2 [expr $i1 + $str1_len - 1] 
  set prg_new [string replace  $prg_old $i1 $i2  $str2]

  set ind_start [expr $i1 + $str2_len]

  return $prg_new
}
#-------------------------------------------------------------------------------
proc get_transform {prg_old  trans_rule} {

  set str1 [lindex $trans_rule 0] ;# будем менять эту подстроку
  set str2 [lindex $trans_rule 1] ;# на эту

  set prg_new $prg_old

  set ind_start 0
  #puts "prg = $prg_new ind_start = $ind_start"

  # выполняем все подобные трансформации в строке, но
  # в целях экономии каждый раз с более дальнего места
  # и заканчиваем по достижении конца (-1)
  
  while {$ind_start >= 0} {
    set prg_new [string_replace_first  $prg_new $str1 $str2   ind_start]
    #puts "prg = $prg_new ind_start = $ind_start"
  }

  puts ""

  return $prg_new
}
#-------------------------------------------------------------------------------
proc get_transform_s {prg_old  trans_rule_s} {

  set prg_new $prg_old

  # можно вообще-то и в обратноу сторону заменять, но тогда
  # отмечать, наверное, уже отработанную схему ..

  # а смысл заменять в обратную? тут наверное нужен точечный подход:
  # где надо, там и менять в какую надо сторону..

  foreach r $trans_rule_s {
    
    # выплним трансформацию для каждого правила
    set prg_new [get_transform $prg_new $r]
  }

  return $prg_new
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc get_arglist {instr} {

  #set

  #set arglist [info args $instr]

  #return $arglist
}
#-------------------------------------------------------------------------------
# получить случайную инструкцию
# вариант с анализом аргументов
#-------------------------------------------------------------------------------
# proc randinstr_ARGS {gp_list} {

#   #set instr [lrand $gp_list]
#   set instr [lrand_new $gp_list]
  
#   set arglist [info args $instr]
  
#   if {[llength $arglist] == 0} { #if {$arglist eq {}}  - для Tcl-8.4 
#     #puts "111111111111"
#     return $instr
    
#   } else {
    
#     #puts "222222222222"
#     info default $instr [lindex $arglist 0] l

#     foreach {min max} $l break
#     return [list $instr [rand $min $max]]
#   }

# }
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка  (a_comm.tl)

#-------------------------------------------------------------------------------
# proc lrand {list} {
    
#   lindex $list [expr {int(rand()*[llength $list])}]
    
# }
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#namespace import tcltest::*

#-------------------------------------------------------------------------------
proc set_argc_argv_null {} {

  global argc argv

  set argc 0
  set argv "" ;# где-то эти параметры используются внутри тестов !!

}
#-------------------------------------------------------------------------------
proc make_simple_main_prog {src} {


  return [list "main" [list "src" $src]]
}
#-------------------------------------------------------------------------------
proc ONE_TEST {} {


  set_argc_argv_null 

  #-----------------------------------------------

  #tcltest::test intro-111 {
  #  "EXAMPLE"
  #
  #} -body {
  #  expr 3 * 5
  #} -result 15

  #-----------------------------------------------

    
  proc_name_index_init
  
  set src {p0 p0  p1 p1 p1  p2 p2  p2 p2  p1 p1 p1  p3 p3}
  
  set prog [make_simple_main_prog $src]
  
  set prog [libra_refactoring $prog] 
  
  return [canonical_form $prog]
  

  # {main {p0 p0 proc1 proc2 proc2 proc1 p3 p3} proc1 {p1 p1 p1} proc2 {p2 p2}}

}
#-------------------------------------------------------------------------------
proc ALL_TESTS {} {


  set_argc_argv_null 

  #-----------------------------------------------

  #tcltest::test intro-111 {
  #  "EXAMPLE"
  #
  #} -body {
  #  expr 3 * 5
  #} -result 15

  #-----------------------------------------------

  test simple_01 {} {
    
     proc_name_index_init

     set src {p0 p0  p1 p1 p1  p2 p2  p2 p2  p1 p1 p1  p3 p3}

     set prog [make_simple_main_prog $src]

     set prog [libra_refactoring $prog] 

     return [canonical_form $prog]

   } {main {p0 p0 proc1 proc2 proc2 proc1 p3 p3} proc1 {p1 p1 p1} proc2 {p2 p2}}

  #-----------------------------------------------

  test simple_01_a {} {
    
    proc_name_index_init

    set src {p0 p0  p1 p1 p1  p2 p2  p2 p2  p1 p1 p1  p0 p0}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

   } {main {proc2 proc1 proc3 proc3 proc1 proc2} proc1 {p1 p1 p1} proc2 {p0 p0} proc3 {p2 p2}}

  #-----------------------------------------------

  test simple_02 {} {
    
    proc_name_index_init

    set src {p1 p1 p1    p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 proc1} proc1 {p1 p1 p1}}

  #-----------------------------------------------

  test simple_03 {} {
    
    proc_name_index_init

    set src {p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {p1 p1 p1}}

  #-----------------------------------------------

  test simple_04 {} {
    
    proc_name_index_init

    set src {p1 p1 p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 p1 proc1} proc1 {p1 p1}}

  #-----------------------------------------------

  test simple_05 {} {
    
    proc_name_index_init

    set src {p1 p1 p1   p2 p2  p2 p2   p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 proc2 proc2 proc1} proc1 {p1 p1 p1} proc2 {p2 p2}}

  #-----------------------------------------------

  test simple_06 {} {
    
    proc_name_index_init

    set src {p1 p1 p1  p2  p1 p1 p1  p3  p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 p2 proc1 p3 proc1} proc1 {p1 p1 p1}}

  #-----------------------------------------------

  test simple_07 {} {
    
    set prog_old [list \
                    "main"  {"src" {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {"src" {p1 p1 p1}}]

    proc_name_index_init ;# 2 ;# !! новые имена генерим с этой цифры (заплатка)

    set prog_new [libra_refactoring  $prog_old 2]

    return [canonical_form $prog_new]

  } {main {proc2 proc2 proc1} proc2 {proc1 p2 p2} proc1 {p1 p1 p1}}

  # {} {main {proc2 proc2 proc1} proc1 {p1 p1 p1} proc2 {proc1 p2 p2}}
  # {} {main {proc2 proc2 proc1} proc2 {proc1 p2 p2} proc1 {p1 p1 p1}}

  #-----------------------------------------------

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc ITEM_test {} {

  puts ""
  puts "----------------------------------------------------"
  puts ""

  ALL_TESTS

  puts "----------------------------------------------------"
  puts ""

  # TODO:
  #
  # нужно научиться выделять схожие последовательности и складывать в 
  # библиотеку!
  #
  # алгоритм lz77 делает похожее, но он последовательный, т.е. надо дополнительно
  # его рихтовать и кроме того, он - на строках из символов и надо переделывать
  # в списки токенов!
  #
  # поэтому пока сделаю тут вручную простейший, а потмо, если совсем медлено
  # будет. вернусь к lz77!


  #set prg { p1 p1 p1} 
  #set prg { p1 p1 p1 p1 p1 } 

  #set prg {p0 p0  p1 p1 p1   p2 p2  p2 p2  p1 p1 p1   p0 p0}
  #set prg { p1 p1 p1  p1 p1 p1} 

  set src {p1 p1 p1  p2  p1 p1 p1  p3  p1 p1 p1} 

  #set src  {p1 p1 p1   p2 p2  p2 p2  p1 p1 p1} 



  #puts ""
  #puts "----------------------------------------------------"
  #puts ""

  set item_prog  [item_make             $src]  
  set orig_prog  [make_simple_main_prog $src]


  puts " src = $src"
  puts ""

  puts "item_prog = [set $item_prog]"
  puts "orig_prog = $orig_prog"

  puts ""
  puts "----------------------------------------------------"
  puts ""

  #set item_prog    [item_make $src]  

  #puts " src = $src"
  #puts "item = [set $item_prog]"

  #puts ""
  
  #return

  #d+

  set start_w 2   ;# минимальное окно сканирования

  #random_set  70 ;# вероятносность


  proc_name_index_init

  set orig_prog_refact [libra_refactoring   $orig_prog $start_w] 

  #puts "prg_origin = $prg"
  #puts ""

  #puts "prog1 = $prog1"  
  #puts ""
  puts "orig_prog_refact = $orig_prog_refact"  
  puts ""

  #puts ""
  #puts "----------------------------------------------------"
  #puts ""

  #return

   
  #puts "RandYes 100 = [RandYes 100]"
  #puts "RandYes  90 = [RandYes  90]"
  #puts "RandYes  50 = [RandYes  50]"
  #puts "RandYes  10 = [RandYes  10]"
  #puts ""

  #return

  set orig_prog_unfact [make_unfactoring_prog  $orig_prog_refact]

  #puts ""
  puts "orig_prog_unfact = $orig_prog_unfact"  
  puts ""
  puts "----------------------------------------------------"
  puts ""


  #------------------------------------------------------------

  #return

  set prog4_old  [list \
                    "main"  {src {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {src {p1 p1 p1}}] 

  puts "prog4_old = $prog4_old"  
  puts ""

  #return

  #set prog_new = main {src {proc1 proc1 proc1}} proc1 {src {proc1 p2 p2}}

  set prog_new  [list \
                    "main"  {src {proc1 proc1 proc1}}  \
                    "proc1" {src {proc1 p2 p2}}] 

  set      prog_new [commit_to_from  $prog_new $prog4_old] 

  #return

  #------------------------------------------------------------


  proc_name_index_init  ; #2 ;# !!;# новые имена генерятся с 1 и забивают старые! 
  # 
  # в любом случае, если будем где-то хранить уже готовые процы, то
  # надо вопрос совместимости имен решать !!

  #d+

  set prog4_new [libra_refactoring  $prog4_old 2] 

  puts "prog4_new = $prog4_new"  
  puts ""


  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# BEGIN ......................... GOODS_MUTATE  
#-------------------------------------------------------------------------------

set ::is_find_in_goods 0

set ::good_mutate_cmd_list {}

#-------------------------------------------------------------------------------
proc find_in_goods {prg_current} {

  return {} ;# !!!!!!!!!!!!!!!!! TODO

  #----------------------------------------

  set cmd {}

  if {$::good_mutate_cmd_list == {}} {return $cmd} ;# нет ничего еще

  set goods $::good_mutate_cmd_list ;# уже сортировано, начиная с большего

  #puts "goods = $goods"


  foreach g $goods {

    set pro         [lindex $g  0] ;# прогресс этой команды
    set mutate_cmd  [lindex $g  1] ;# сама команда (в которую включен контекст и )

    set index [lindex $mutate_cmd 0]
    set mdict [lindex $mutate_cmd 1]
    
    set p   [dict get $mdict -p]
    set inp [dict get $mdict -i]
    set s   [dict get $mdict -s]

    set cur [lrange $prg_current $index $index]

    #if {[lindex $prg_current $index] == $i} {break}
    if {$cur == $inp} {
      #puts stderr "find_in_goods: cur = $cur, inp = $inp"
      #break
      return $mutate_cmd ;# полное совпадение
    }
    
  }

  # ничего и не найдено, а чего возвращаем??

  #puts stderr "find_in_goods: prg = $prg_current, pro = $pro, mutate_cmd = $mutate_cmd"

  return {} ;# $mutate_cmd
}
#-------------------------------------------------------------------------------
proc  find_this_cmd {mutate_cmd} {

  foreach l $::good_mutate_cmd_list {

    set pro [lindex $l  0]  ;# прогресс этой команды
    set mut [lindex $l  1]  ;# сама команда (в которую включен контекст и )

    if {$mut == $mutate_cmd} {
      return 1
    }
  }

  return 0
}
#-------------------------------------------------------------------------------
proc save_good_mutate_cmd {mutate_cmd progress_abs} {

  # только не надо добавлять уже существующие команды ??
  # 
  if {! [find_this_cmd  $mutate_cmd]} {
  
    lappend ::good_mutate_cmd_list [list $progress_abs $mutate_cmd]
  }

  # здесь хорошо бы отсортировать
  #
  set ::good_mutate_cmd_list [lsort -decreasing  $::good_mutate_cmd_list]

}
#-------------------------------------------------------------------------------
proc good_mutate_print {} {


  puts stderr "  ::good_mutate_cmd_list = "
  
  foreach g $::good_mutate_cmd_list  {

    set pro         [lindex $g  0] ;# прогресс этой команды
    set mutate_cmd  [lindex $g  1] ;# сама команда (в которую включен контекст и )

    puts stderr [format "     % 4.2f  %s"  $pro $mutate_cmd]
  }
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc get_i_context {prg i} {

  set len [llength $prg]

  if {$i == 0} {
    #set pre "B"
    set pre {}
  } else {
    set pre [lindex $prg [- $i 1]]
    #set pre [lrange $prg [- $i 1] [- $i 1]]
    #set pre [list [lindex $prg [- $i 1]]]
  }

  set val [lindex $prg $i]

  if {$i == [- $len 1]} {
    #set suf "E"
    set suf {}
  } else {
    set suf [lindex $prg end]
  }

  # сформировали контекст значения $val (которое стоит в позиции i)
  # 

  return [list -p $pre -i $val -s $suf]
}
#-------------------------------------------------------------------------------
proc do_out {&prg  mutate_cmd_new} {

  USE_REFS

  #puts ""
  #puts "[procname] ........ "
  #puts ""

  set index1  0       ;# [lindex $mutate_cmd_new  0]
  set index2  $index1 ;# пока заменяем только строку в один символ

  set context [lindex $mutate_cmd_new  1]
  set out     [lindex $mutate_cmd_new  2]

  set inp     [dict get $context -i]

  #puts "context = $context"
  #puts "out     = $out"
  #puts "inp     = $inp"
  #puts ""

  set prg  [lreplace $prg $index1 $index2]  ;# удаляем из начального кусок
  set prg  [linsert  $prg $index1 {*}$out]  ;# заменяем его модификацией
 
  return $prg
}
#-------------------------------------------------------------------------------
# proc make_mutate_cmd_new {mutate_cmd_old} {

#   USE_REFS

#   set index   [lindex $mutate_cmd_old  0]
#   set context [lindex $mutate_cmd_old  1]
#   set mcmd    [lindex $mutate_cmd_old  2]

#   #set ret {}
#   set mutate_cmd_new {}

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  
#   set inp [dict get $context -i]
#   set out $inp
  
#   set cmd [lindex $mcmd 0]
#   set i   [lindex $mcmd 1]
#   set gen [lindex $mcmd 2]

#   # попробуем другим способом (сначала меняем подстроку)
#   set j 0 ;# 
#   #set j $i 
  
#   switch -- $cmd {
    
#     "not" {
#       #????????????????
#     }  
#     "del" {
#       ##set prg  [lremove $prg $i] ;# invalid command name "lremove"
#       set out  [lreplace $out $j $j] ;# удаляем
#     }  
#     "set" {
#       lset out $j $gen  ;# либо заменяем итем 
#     }  
#     "add" {
#       set out  [linsert $out $j $gen]  ;# либо добавляем
#     }
#   } 


  
#   return [list $index $context $out]  
# }
#-------------------------------------------------------------------------------
proc make_mcmd {prg gp_list index cmd_list} {


  # нельзя удалять единственный элемент

  if {[llength $prg] <= 1} {
    regsub "del" $cmd_list "" cmd_list
  } 
  

  if {[llength $cmd_list] == 1} {
    set mode [lindex $cmd_list 0]
  } else {
    set mode [lrand  $cmd_list] ;# взяли случайную команду  из списка
  }


  # надо делать мутацию ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  # сначала сформируем команду мутации
  

  if       {$mode == "del"} {
    
    set mcmd "del $index @" ;# удалим gen
    
  } elseif {$mode == "mut"} {
    
    set mcmd "mut $index @" ;# мутируем gen (может быть и с заменой, но это после)
    
  } else {
    
    # выберем из списка (или списков !!!) 
    # 
    set gen [randinstr_MAIN $gp_list]
    
    set mcmd "$mode $index $gen"  ;# set or add 
  }
  
  return $mcmd 
}
#-------------------------------------------------------------------------------
# а вот теперь выполним команду мутации:  
#-------------------------------------------------------------------------------
# proc make_mutate_cmd_for_index {&prg  gp_list  index} {

#   USE_REFS

#   set mcmd [make_mcmd  $prg $gp_list $index] 
#   set context [get_i_context $prg $index]
  
#   set mutate_cmd [list $index $context $mcmd]
  
#   return $mutate_cmd 
# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# По заданной программе возвращается мутированная программа
# 
#-------------------------------------------------------------------------------
# proc ga_joyprg_mutate_one_gen {prg  gp_list point} {

#   # Mutate by tweaking a single allele.
  
#   set point_gen_old [lindex $prg $point]


#   set is_digital [expr {[string is integer $point_gen_old] || [string is double $point_gen_old]}]

#   if {$is_digital} {
#     # -------------------------------------------

#     # The direction of drift. 
#     # 
#     if {[comm_random_boolean]} {
#       set dir -1
#     } else {
#       set dir  1
#     }
    
#     set point_gen_new [expr {$point_gen_old + $dir}]  ;# новое  значение
#     # и это реально новое значение всегда

#     # -------------------------------------------
#   } else {
#     # -------------------------------------------

#     #if {1} {
#     #  #set gp_list $::gp_list ;# в список входит и старый ген !
#     #} else {
#     #  # исключить элемент из списка, чтоб мутация была реальной
#     #  # 
#     #  set gp_list  [lsearch  -inline -all -not -exact $gp_list $point_gen_old]
#     #}

#     set point_gen_new [randinstr_MAIN $gp_list]

#     # -------------------------------------------
#   }

#   lset prg  $point $point_gen_new ;# новая измененная хромосома

  
#   #return [list $prg ""]
#   return $prg 
# }
#-------------------------------------------------------------------------------
proc ga_joyprg_mutate {task prg} {


  # task_create
  set gp_list [GET $task "gp_list"]

  #puts stderr "1............. gp_list = $gp_list"
  #puts stderr ""

  set len_chromo [llength $prg]


  # случайно выбираем точку в хромосоме? тогда ее длину и надо же брать?
  # 
  set point [comm_random_int  $len_chromo]
  
  
  # TODO: а почему меням только один ген, этого же мало !! !!!!
  # 
  #set prg  [ga_joyprg_mutate_one_gen  $prg  $gp_list $point]

  set prg  [gp_joyprg_mutate_one_gen  $prg  $gp_list $point "mut"] 


  # r~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums 10 -vers ga
  # 
  # can't read "gp_list": no such variable


  return $prg 
}
#-------------------------------------------------------------------------------
proc make_mutate_by_mcmd {prg mcmd gp_list} {


  #puts stderr "2................... gp_list = $gp_list"

  set cmd [lindex $mcmd 0]
  set i   [lindex $mcmd 1]
  set gen [lindex $mcmd 2]

  if {$::is_print == 4} {
    puts ""
    puts "[procname] BEG: prg_old = $prg, mcmd = $mcmd"
  }

  # попробуем другим способом (сначала меняем подстроку)
  #set j 0 ;# 

  set prg_new $prg

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  switch -- $cmd {
    
    "not" {
      #???
    }  

    "del" {
      ##set prg  [lremove $prg $i] ;# invalid command name "lremove"
      set prg_new  [lreplace $prg_new $i $i] ;# удаляем
    }  

    "set" {
      set point_gen_new $gen ;## [randinstr_MAIN $gp_list]

      lset prg_new $i $point_gen_new  ;# заменяем итем 
    }  

    "mut" {
      set point_gen_old [lindex $prg $i]

      set is_digital [expr {[string is integer $point_gen_old] || [string is double $point_gen_old]}]

      if {$is_digital} {
        # -------------------------------------------
        
        # The direction of drift. 
        # 
        if {[comm_random_boolean]} {
          set dir -1
        } else {
          set dir  1
        }
        
        set point_gen_new [expr {$point_gen_old + $dir}]  ;# новое  значение
        # и это реально новое значение всегда
        
        # -------------------------------------------
      } else {
        #set point_gen_new $gen ;## [randinstr_MAIN $gp_list]
        set point_gen_new [randinstr_MAIN $gp_list]
      }

      lset prg_new $i $point_gen_new  ;# либо заменяем итем 
    }  

    "add" {
      set prg_new  [linsert $prg_new $i $gen]  ;# либо добавляем
    }

  } 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  if {$::is_print >= 3} {
    puts "[procname] END: prg_new = $prg_new"
  }

  return $prg_new
}
#-------------------------------------------------------------------------------
proc gp_joyprg_mutate_one_gen {prg gp_list point cmd_list} {

  #set cmd_list "del set add"

  # надо упростить

  #if {0} {
  #  set mutate_cmd_old [make_mutate_cmd_for_index  prg $gp_list  $i] ;# ?????
  #  set mutate_cmd_new [make_mutate_cmd_new        $mutate_cmd_old]  ;# ?????
  #  set ret [do_out  prg $mutate_cmd_new]

  #} else {

  #puts stderr "3................... gp_list = $gp_list"

  set mcmd [make_mcmd           $prg $gp_list $point $cmd_list]

  #puts stderr "4................... gp_list = $gp_list"

  set ret  [make_mutate_by_mcmd $prg $mcmd $gp_list]
  #}  
  
  #puts stderr "9................... gp_list = $gp_list"

  return $ret;
}
#-------------------------------------------------------------------------------
#proc gp_joyprg_mutate {task prg mutprob} {}
proc gp_joyprg_mutate {task prg} {

  set cmd_list "del set add"

  # TODO: привести к общему виду с 

  # gaul_mutation {pop task}
  # ga_mutate_printable_singlepoint_drift {pop father son}

  set gp_list [GET $task gp_list]


  #set mutate_cmd_new {}

  # 0 - удаляем 
  # 1 - заменяем
  # 2 - добавляем
      
  #if {$::gp_NEWS} {

    # по новому алгоритму - хотим ьенять точечно и семантически осмыслено 
    # 

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # ищем мутирующую команду в списке сохраненных
    # 
    #if {$::is_find_in_goods} {

    #  set mutate_cmd_new [find_in_goods $prg]
    #  set ::is_find_in_goods 0

    #} else {
    #  set ::is_find_in_goods 1
    #}

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # если нет, то формируем мутирующую команду случайным образом
    # 
    
    #if {$mutate_cmd_new == {}} {

    set    i [comm_random_int_minmax  0 [- [llength $prg] 1]]
      
    #  set mutate_cmd_old [make_mutate_cmd_for_index  prg $gp_list  $i]
    #  set mutate_cmd_new [make_mutate_cmd_new  $mutate_cmd_old]
    #}

    #do_out  prg $mutate_cmd_new

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #} else {

  # gо старому алгоритму - мутируем всю программу целиком и хаотично
  # 

  #for {set i 0} {$i < [llength $prg]} {incr i} {

    #puts "gp_joyprg_mutate: i = $i, prg = $prg"


    #if {0} {
    #  set mutate_cmd_old [make_mutate_cmd_for_index  prg $gp_list  $i] ;# ?????
    #  set mutate_cmd_new [make_mutate_cmd_new        $mutate_cmd_old]  ;# ?????

    #  do_out  prg $mutate_cmd_new                                      ;# ?????
    #} else {
      
    set prg [gp_joyprg_mutate_one_gen  $prg $gp_list $i $cmd_list] 
    
    #set mcmd [make_mcmd           $prg $gp_list $i]
    #set prg  [make_mutate_by_mcmd $prg $mcmd]
    #}
    
    #set prg [ga_joyprg_mutate_one_gen  $prg $gp_list $i] ;# без добавления генов не работает
  #}

  #}
  
  return [list $prg {}]
  ## return [list $prg $mutate_cmd_new] - пока упростим, без мутирующей команды
}
#-------------------------------------------------------------------------------
proc TEST_make_mutate {} {

  puts ""
  puts "................. TEST_make_mutate"
  puts ""

  set prg_old {dup dup * +}
  set gp_list {dup * +}

  puts ""
  puts "prg_old = $prg_old"

  set prg_new [gp_joyprg_mutate_one_gen  $prg_old $gp_list 1 "del set add"] 

  puts "prg_new = $prg_new"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  set prg_old {1 1 1 1 1}
  set gp_list {8 9}

  puts ""
  puts "prg_old = $prg_old"
  puts ""

  set ::is_print 4

  #comm_random_seed 2023 
  #set prg_new [ga_joyprg_mutate_one_gen  $prg_old $gp_list 1] 
  #puts "prg_new = $prg_new"

  comm_random_seed 2023 
  set prg_new [gp_joyprg_mutate_one_gen  $prg_old $gp_list 1 "mut"] 
  puts "prg_new = $prg_new"

  return
}
#-------------------------------------------------------------------------------
# FINAL ......................... GOODS_MUTATE  
#-------------------------------------------------------------------------------
#------g-------------------------------------------------------------------------
proc make_mutant_from_item {item task} {

  # пока смотрим только отдельный исходник, без возможных библиотек
  # 
  set prg   [item_get_main_src $item] ;# исходник на JOY в виде строки
  
  
  #set l [ios_calc_balans_list  $prg]

  foreach {prg_mutant mutate_cmd} \
    \
    [gp_joyprg_mutate  $task $prg]  {}
  
  set mutant [item_make $prg_mutant]  ;# цельный агент-мутант
  
  # пока фитнеса нет, только программы

  return [list $mutant $mutate_cmd]
}
#-------------------------------------------------------------------------------
proc is_items_equal {item1 item2} {

  set src1 [item_get_main_src $item1]
  set src2 [item_get_main_src $item2]

  # puts "is_items_equal: src1 = $src1, src2 = $src2"

  if {$src1 == $src2} {
    return 1
  } else {
    return 0
  }     

  #return 0
}
#-------------------------------------------------------------------------------
proc is_this_mutant_unikum {mutant items} {

  foreach i $items {

    if {[is_items_equal $mutant $i]} {

      # встретили идентичного итема, уходим на еще попытку
      #exit
      return 0
    }
  }

  return 1
}
#-------------------------------------------------------------------------------
proc make_mutant_unikum {task parent items num_probes} {

  #set num_probes 10

  # выполняем циклом попытки сделать мутанта
  # 

  for {set i 0} {$i < $num_probes} {incr i} {
    
    foreach {mutant mutate_cmd} \
      [make_mutant_from_item  $parent $task] break

    if [is_this_mutant_unikum $mutant $items] {
      break
    }
  }

  return $mutant
  #return [list $mutant $mutate_cmd]
}
#-------------------------------------------------------------------------------
proc make_mutated_from_items {task sorted_items m} {

  set l_items [llength $sorted_items]
  set mutated {} ;# сформируем список мутантов
  set parents {} ;# 
  
  # случайным выбором от всех?

  #-------------------------
  if {1} {
  #-------------------------


  # приготовим список для мутации (n ?  mutprob ?)
  # 
  while {1} {

    if {[llength $parents] ==  $m} {break} ;# список уже готов


    set j [comm_random_int_minmax 0 [- $l_items 1]] 

    set parent [lindex $sorted_items $j] ;# родителем взяли случайного из всего списка
  
    lappend parents $parent   
  }

  foreach parent $parents {

    set mutant [make_mutant_unikum  $task $parent $sorted_items 10]

    # добавим мутанта в список
    #
    lappend mutated $mutant
  }

  #-------------------------
  } else {
  #-------------------------

  while {1} {

    if {[llength $mutated] ==  $m} {break}


    set j [comm_random_int_minmax 0 [- $l_items 1]] 

    set parent [lindex $sorted_items $j] ;# родителем взяли случайного из всего списка
  

    # сделаем уникального мутанта (c 10-ти поыток) для этого списка
    # 
    set mutant [make_mutant_unikum  $task $parent $sorted_items 10]


    # добавим мутанта в список
    #
    lappend mutated $mutant
  }

  #-------------------------
  }
  #-------------------------

  return $mutated
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#

#-------------------------------------------------------------------------------
# proc is_progress_OLD {tobest fitn_old fitn_new  fit_target} {

  
#   if {$tobest == "MIN" && $fitn_new < $fitn_old} {
#     set ret 1
#   } else {
#     set ret 0
#   }

#   return $ret
# }
#-------------------------------------------------------------------------------
proc is_progress {fitn_old fitn_new  fit_target} {

  
  set delta_old [expr {abs ($fitn_old - $fit_target)}] 
  set delta_new [expr {abs ($fitn_new - $fit_target)}] 

  # сравниваем расстояния до цели

  if {$delta_new < $delta_old} {
    set ret 1
  } else {
    set ret 0
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc get_best_from_history {history fit_target} {


  set best_item {}
  set best_fitn {}

  for {set i 0} {$i < [llength $history]} {incr i} {

    set h [lindex $history $i]

    set item [lindex $h 0]
    set fitn [lindex $h 1]

    if {$i == 0} {
      set best_item $item
      set best_fitn $fitn

      #puts "best_item1 = $best_item"
    } else {

      set is_progress [is_progress  $best_fitn $fitn  $fit_target]
  
      if {$is_progress} {    
        set best_item $item
        set best_fitn $fitn
      } 
    }

  }

  #puts "best_item = $best_item"

  return $best_item
}
#-------------------------------------------------------------------------------

set ::line_context_format "  %-31s : %-28s "

#-------------------------------------------------------------------------------
proc try_mutate_to_best {deep_mutate task  item_start fitn_start} {


  set fitnessfunc [GET $task "fit_func"]  

  # "MIN" ;# т.е. чем меьше, тем лучше
  # 
  set tobest     [GET $task "fit_tobest"]

  set fit_target [GET $task "fit_target"]

  # TODO: 

  # - при первом улучшении - заканчиваем цикд
  # - если дошли до конца, т.е. улучшений не было, то 2 варианта (рандомно):
  #   - либо оставляем старый вариант(т.е. нет мутации), но надо учитывать всю популяцию!
  #   - либо берем из списка истории мутаций - самый лучший вариант (хоть и хуже начального)

  set history {}
  #lappend history [list $item_old $fitn_old] ;# положили первую пару

  set mutprob 1.0

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # седлаем несколько попыток улучшить этот итем
  # 
  # TODO:

  # 1) попытки должны быть боле осознанными, учитывать статистику
  # 2) учитывать как хорошую так и плохую статистику 
  # 3) понять как сочетать шаблоны действий и шаблоны конечных состояний или
  #    выбрать одно общее понятие?
  # 4) зачем я клонирую (дублирую), если все равно потом делаю попытки?


  set ::max_try_variant 2

  for {set i 1} {$i <= $::max_try_variant} {incr i} {

  set item_old $item_start
  set fitn_old $fitn_start

  # идем в глубину
  # цикл последовательных мутаций item_old -> item_new -> item_old
  # 
  if {$::is_print >= 2} {
    #puts stderr [format "  try $i ..."]
    puts stderr [format "  try $i ... item_old = [set $item_old] "]
  }

  for {set j 0} {$j < $deep_mutate} {incr j} {

    #item_print_fitness    $item_old 0 
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    foreach {item_new mutate_cmd} \
      \
      [make_mutant_from_item  $item_old $task]  break ;# сделали мутанта 

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    item_calc_fitness   $item_new $fitnessfunc $task  ;# посчитали мутанта
    
    #item_print_fitness  $item_new 1   
    #set src   [item_get_main_src   $item] 
    
    set fitn_new  [item_get_fitn   $item_new] 
    
    # посмотрим, есть ли уже улучшение от начального ??
    # так может не от начального, а от текущего, пока мы идем в глубину ..
    #
    set is_progress [is_progress  $fitn_old $fitn_new  $fit_target]

    set progress_val [- $fitn_new $fitn_old]

    if {$::is_print >= 2} {

      puts stderr [format "          :$::line_context_format:  %5.2f :  %5.2f :  %d : " \
		     $mutate_cmd  [item_get_main_src $item_new] $progress_val $fitn_new $is_progress 
                  ]
    }


    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # да надо бы всех сохранять - это информация и опыт - пригодится!
    # все хорошо, сохраняем удачную команду мутации с контекстом
    
    #save_good_mutate_cmd  $mutate_cmd $progress_val
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    lappend history [list $item_new $fitn_new] ;# положили в историю
    #
    # TODO: но надо бы туда положить еще и метод мутации? 
    #       нет, его надо в отдельную историю, глобальную, чтобы пользоваться
    #   
   
    set item_old $item_new ;# готовимся к  след. шагу цикла
    # т.е. мы сделали неудачную мутацию, на надеемся на будущие улучшения
    set fitn_old $fitn_new

  }
  } ;# закончиличь ничем все попытки улучшить исходный итем
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$::is_print >= 2} {puts stderr ""}

  # улучшений не было, тогда возьмем хоть что-то из истории:

  set r [comm_random_int_minmax_1  1 10]

  if {$r <= 3} {

    set item_best $item_start ;# оставили начальный вариант

  } else {

    # возьмем лучший из истории (исключая начальный)
    # TODO: жедательно отличающийся от начального, если фитнесы равны!
    # 
    set item_best [get_best_from_history  $history $fit_target]
  }

 
  return $item_best
}
#-------------------------------------------------------------------------------
proc try_mutate_for_all_items {pop_items_old  task deep_mutate} {


  set pop_items_new {} ;# сюда будем формировать новых мутантов
  

  if {$::is_print >= 2} {
    puts stderr "try_mutate_for_all_items: \n"

    set ind_form  "    %d]   "
    set gen_form  "%s " 
    itemlist_print $pop_items_old $ind_form $gen_form stderr 
    puts stderr ""
  }

  # идем циклом и каждого бота пытаемся смутировать к лучшему
  #
  set index 1

  foreach item_old $pop_items_old {

    set fitn_old  [item_get_fitn   $item_old] 

    set src [item_get_main_src $item_old]
    #set lst [ios_calc_balans_list $src]

    #if {$::is_print >= 2} {
    # puts stderr "  item_old:  [item_get_main_src $item_old] "
    #}

    if {$::is_print >= 2} {

      puts stderr \
        [format "  $index] ..................................................... " \
           "" $index]

#       puts stderr [format "          :  %-37s : %-30s :  %5.2f :  %d : " \
# 		     $mutate_cmd  [item_get_main_src $item_new] $fitn_new $is_progress 

      puts stderr [format "  item_old:$::line_context_format:        :  %5.2f " \
    		   "" $src  $fitn_old ]
    }

    set item_new [try_mutate_to_best  $deep_mutate $task \
		    $item_old $fitn_old]

    if {$::is_print >= 2} {
      puts stderr "  item_new:  [item_get_main_src $item_new]"
      good_mutate_print  
      puts stderr "\n"
    }

    
    lappend pop_items_new  $item_new
    incr index
  }

  return $pop_items_new
}
#-------------------------------------------------------------------------------
proc dict_print_real_all_in_list {name list_pd} {

  puts stderr "$name : " 

  foreach item $list_pd {
    dict_print_real $item
  }

}
#-------------------------------------------------------------------------------
proc item_print_fitness {item i} {


  puts -nonewline [format "  %3d) " $i]
  
  set src   [item_get_main_src   $item] 
  set fitn  [item_get_fitn       $item] 

  # а если фитнес уже есть, зачем его вычилять ????????
  # 
  
  if {$::is_fitn_first} {

    # TODO - isdigit isfloat 
    #
    set is_digital [expr {[string is integer $fitn] || [string is double $fitn]}]

    ##if {$fitn == "NOT-FIT"} {}
    if {! $is_digital} {
      puts [format "  fitn = % 8s :   %s" $fitn $src]
    } else {
      puts [format "  fitn = % 8.3f :   %s" $fitn $src]
    }
    
  } else {
    
    puts -nonewline [format "  %s     " $src]
    flush stdout               ;# все данные должны быть выведены
    
    puts [format "fitn = %s" $fitn]
  }
  

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# t-proJ.tl  FOR JOY
#-------------------------------------------------------------------------------
proc itemspop_print {itemspop} {


  foreach item $itemspop {

    puts "item = [set $item]"

  }

  return
}
#-------------------------------------------------------------------------------
# proc mp_create {} {


#   v1_init_all  ;# !!!!!!!!!!! ???

# }
#-------------------------------------------------------------------------------
# proc mp_init {pb args} {


#   dict with args {} ;# name value - присвоили переменным значения (локально?)


# #  set ::randinstr   "randinstr_MAIN"
# #  set ::quotes_proc "quotes_proc_NULL"

#   # ?? проверяем существование локальных переменных ??
#   #
# #  if [info exists "randinstr"]   {set ::randinstr   $randinstr}
# #  if [info exists "quotes_proc"] {set ::quotes_proc $quotes_proc}

# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc test_joy_savestack {} {


  v1_init_all  ;# !!!!!!!!!!! ???

  set ::error_print1 1
  set ::error_print2 1
  set ::error_print3 1
  
  set ::error_saverestore 1
  
  #---------------------------------------------------

  #set proga "+ + + dup *"
  set proga "+ dup * + + "
  set val 3
  
  puts ""
  puts "proga = $proga, val = $val"
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  v0_set_stack_null 

  set result [v1_get_result_from_one_arg $proga  $val]
  
  
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
  puts "result = $result"
  puts "joy_ST = $::joy_ST"
  puts ""
 
 
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc v1_get_result_from_one_arg {prg_11 val} {

  # кладем одно значение в стек
  # 
  push $val 

  # выполняем программку
  # 
  #run_v1_src_or_prog $prg_11 ;### $prog_11
  run_v1_src $prg_11

  # забираем одно значение из стека
  # 
  set result [pop]


  return $result
}
#-------------------------------------------------------------------------------
# кладем один аргумент в стек и выполняем joy-программу
#
# proga - обобщенное название программы, там могут быть разные варианты (типы) 
#
#-------------------------------------------------------------------------------
proc getresult_prg_val_11 {prg_11 val} {


  #convert_22_to_11  $prg_22 prg_11
  #set prg_11 $prg_22 ;# ??

  v0_set_stack_null ;# и не более того !!!!

  #-----------------------------------------------------------------
  if {0} {
  #-----------------------------------------------------------------

    # да вроде уже отлавливаем на уровне команд
    # 
    # отлпаливаем аварийное завершение целиком полность программы !?
    # 
    
    if {[catch {set result [v1_get_result_from_one_arg  $prg_11 $val]} err ]} {
      
      if {$::error_print1} {
        puts stderr "r_error_print1: getresult_prg_val_11: err = $err"
        puts stderr ""
      }
      
      return {}
    } else {
      return $result
    }

  #-----------------------------------------------------------------
  } else {
  #-----------------------------------------------------------------

    set result [v1_get_result_from_one_arg  $prg_11 $val]

    return $result

  #-----------------------------------------------------------------
  }
  #-----------------------------------------------------------------


}
#-------------------------------------------------------------------------------
proc getresult_prg {prg_22} {


  #convert_22_to_11  $prg_22 prg_11
  set prg_11 $prg_22

  if {[catch {set result [v1_get_result_from_not_arg  $prg_11]} err ]} {

    if {[IsDebug]} {

      puts stderr "ERROR = $err"
    }
    return {}

  } else {

    return $result
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc calc_12345_results {prg_11} {


  #convert_22_to_11  $prg_22 prg_11
  #set prg_11 $prg_22

  v0_set_stack_null ;# и не более того !!!!

  foreach i {1 2 3 4 5}  {

    set res [v1_get_result_from_one_arg  $prg_11 $i]

    lappend results $res
  }

  return $results
}
#-------------------------------------------------------------------------------
proc check_tranform_s {trans_rule_s  prg1  calc_proc} {

  # делаем новую трансформированную программу
  # 
  set prg2 [get_transform_s  $prg1 $trans_rule_s]
  

  set res1 [eval {$calc_proc $prg1}] ;# результаты по исходной проге
  set res2 [eval {$calc_proc $prg2}] ;# по трансормной

  # puts ""
  puts "prg1 = $prg1"
  puts "prg2 = $prg2"
  puts ""

  puts "res1 = $res1"
  puts "res2 = $res2"
  puts ""

  if {[string equal $res1 $res2]} {
    puts "OK .... !!!!"
  } else {
    puts "NO .... (((("
  }

}
#-------------------------------------------------------------------------------
proc TEST_trans_01 {} {

  set  trans_rule_s {
    {"2 *"     "dup +"   }
    {"100 +"   "99 + 1 +"}
  }

  puts ""
  puts "trans_rule_s = $trans_rule_s"

  set prg1  "2 *  100 +  2 *  dup +"

  #DebugOn
  v1_init_all  

  check_tranform_s  $trans_rule_s $prg1  calc_12345_results

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# надо добить этот тест, для запуска по 
# VER3 !!
#-------------------------------------------------------------------------------
# proc run_i_joyprg {prg valstack} {


#   set ctx [v3_init_context]

#   # положили начальное значение в стек, потом программу и выполнили ее
#   # 
#   joy-eval "$valstack $prg"

#   # взяли со стека предпологаемый результат
#   # 
#   set e   [pop ]

#   # преобразовали его из внутреннего в JOY-формат
#   # 
#   set ret [v3->joy $e]

#   return $ret
# }
#-------------------------------------------------------------------------------
# proc calc_list_results {prg} {

#   set ll {[1 2 3 4 5]}

#   catch {set res [eval {run_i_joyprg  $prg $ll}]} res

#   return $res
# }
#-------------------------------------------------------------------------------
# proc TEST_trans_02 {} {


#   set trans_rule_s {
#     {"reverse size"    "size"}
#   }

#   set prg1  "reverse size"

#   check_tranform_s  $trans_rule_s  $prg1 calc_list_results

# }
#-------------------------------------------------------------------------------
################################################################################
#
# сначала научимся просто разбивать большой интервал на случайные подинтревалы
#
#-------------------------------------------------------------------------------
proc make_test_prg {n} {

  set prg {}
  set ind 0

  repeat $n {
    lappend prg $ind
    incr ind
  }

  return $prg
}
#-------------------------------------------------------------------------------
proc make_prelist {n} {

  set ret {}

  set ind 0

  repeat $n {

    if {[comm_random_int_minmax 0 3] == 0} {

      lappend ret $ind 
    }

    incr ind
  }
 
  return $ret
}
#-------------------------------------------------------------------------------
proc make_paras_from_prelist {prelist} {

  set ret {}

  foreach {i1 i2} $prelist {
    
    if {$i2 == {} } {break} ;# не нашлось конца для пары

    set l [list $i1 $i2]
   
    #puts "($i1 $i2) [llength $l]"
    lappend ret $l    
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc make_paras {n} {

  set preli  [make_prelist $n]  ;# случайное подмножество из  0 1 2 .. n

  #puts "preli = $preli"
  set paras  [make_paras_from_prelist $preli]

  return $paras
}
#-------------------------------------------------------------------------------
proc make_quotes_TCL {prg} {

  set n [llength $prg]

  set paras  [make_paras $n]

  set newprg [make_quotes_by_paras  $prg $paras $n  "lappend_TCL_list"]

  return $newprg
}
#-------------------------------------------------------------------------------
proc randinstr_or_LIST {gp_list} {

  # здесь уже можно подумать, а не сделать ли квотированный список
  #if {[myrand 0 3] == 0} {

  #  set size [myrand 2 4]

    #set  instr { nop nop} ;# очень простой список!

  #} else {
    set  instr   [lrand_new  $gp_list]
  #}

  return $instr
} 
#-------------------------------------------------------------------------------
# PP (primitive programming is NOT genetic programming !

# TODO: эту функцию надо будет интегрировать потом с основной (из j-core)
#
#-------------------------------------------------------------------------------
proc squareFitness_check_true {joy_prg } {

  set fitness 0

  foreach i {1 2 3 4 5} o {1 4 9 16 25} {

    set result [getresult_prg_val_11  $joy_prg $i]

    if {$result eq {}}  {
      return 0

    }
     
  }
    
  return 1
}
#-------------------------------------------------------------------------------
# создать случайную тру-программу длиной не больше 'n'
#-------------------------------------------------------------------------------
proc make_randtrueprog {gp_list num_max ind_max fitnessfunc_check} {

  set ind 0 ;# это всего, чтобы не зациклиться
  set num 0 ;# а это макс длина программы? а зачем? пусть уж какая получится?
  set prg {}

  while {[incr ind] <= $ind_max} {

    #set instr [randinstr_SIMP]  - здесь можем получить и список инструкций 
    # 
    #set instr [randinstr_SIMP] 
    set instr [randinstr_or_LIST $gp_list] 

    set rab $prg       ;# делаем рабочую копию для теста

    lappend rab $instr ;# добавляем новую инструкцию
    # и проверяем опять полностью всю программу, а ведь это не рационально
    # мы же уже все посчитали, надо только досчитать !

    set is_true [$fitnessfunc_check  $rab] 

    #puts -nonewline [format "ind= %2d check= " $ind]

    if {! $is_true}  {
      #puts "NULL    rab= $rab"
      continue ;# попробуем другую инструкцию
    } else {
     # puts "TRUE !! rab= $rab"
            }


    # хорошая инструкция, добавим в программу:
    #
    lappend prg $instr
    if {[incr num] >= $num_max} {break}
  }
  
  return $prg
}
#-------------------------------------------------------------------------------
proc TEST_pp {args} {

  #incr ::ind0
  #set ind $::ind0 

  #read_seedflag  ind 
  #read_seedflag [+ $::ind0 1] 

  puts ""
  puts "args = $args"
  puts ""
  #return

  set flag [lindex $args 0]
  set_seedflag $flag 


  set num_max  10
  set ind_max 100

  set gp_list  "dup i i" 

  v1_init_all  

  # делаем выполнимую программу
  # 
  set prg [make_randtrueprog  $gp_list $num_max $ind_max \
             squareFitness_check_true]

  puts ""
  puts "RANDTRUEPROG = $prg"
  puts "SIZETRUEPROG = [llength $prg]"

  # а теперь проверяем, что именно она выполняет:

  set x 3 
  set result [getresult_prg_val_11  $prg $x]
 
  # печатаем резудьтат (того, что было в стеке)
  # 
  puts ""

  if {$result eq {}}  {
    puts "NOT result !!"

  } else {
    puts "x= $x  result= $result"
  }
  

}
#-------------------------------------------------------------------------------
proc v1_get_result_from_not_arg {prg_11 {prog @}} {


  v0_set_stack_null

  #push $val 
  set ::sum 0

  #run_v2_src_old $prg 

  run_v1_src $prg_11 

  #set result [pop]
  set result $::sum

  #puts stderr "result = $result"

  return $result
}
#-------------------------------------------------------------------------------
proc lappend_TCL_list {prg i1 i2 &ret} {

  USE_REFS

  # потом формируем саму пару:
  #
  set quoted_list {} ;# [lrange $prg $i1 $i2]
  

  for {set i $i1} {$i <= $i2} {incr i} {

    lappend quoted_list  [lindex $prg $i]
  }
  
  lappend ret $quoted_list

}
#-------------------------------------------------------------------------------
proc make_quotes_by_paras {prg paras n lappend_list_proc} {

  set ret {} ;# здесь будем формировать результат

  set i0 0


  foreach para $paras {

    set i1 [lindex $para 0]
    set i2 [lindex $para 1]

    # сначала "скопируем" одиночные элементы до начала пары
    #
    for {set i $i0} {$i < $i1} {incr i} {
      lappend ret [lindex $prg $i]
    }


    $lappend_list_proc  $prg $i1 $i2  ret 

    set i0 [expr $i2 + 1] ;# устанавливаем новое начало цикла
  }


  # и в после всех пар надо добавить одиночные в конце
  # 

  for {set i $i0} {$i < $n} {incr i} {
    lappend ret [lindex $prg $i]
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc TEST_makeparas {args} {


  # f~.tl TEST TEST_makeparas 2014
  #incr ::ind0
  #ncr ::ind0

  #read_seedflag ::ind0

  puts "args = $args"
  puts ""

  set_seedflag [lindex $args 0]
  #---------------------------------

  set n 10

  puts ""

  set prg [make_test_prg $n]    ;# 0 1 2 .. n - самая простая программа из n оп.

  puts "oldprg = $prg"


  set paras [make_paras $n]

  puts "paras  = $paras"


  set lappend_list_proc "lappend_TCL_list"
  #
  #set lappend_list_proc "lappend_BE_list@

  set newprg [make_quotes_by_paras \
                $prg $paras $n  $lappend_list_proc]

  puts "newprg = $newprg"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc item_calc_fitness {item fitnessfunc task} {

  
  set fitn  [$fitnessfunc  $item $task]  

  incr ::eval_count

  item_set_fitn  $item  $fitn
  
}
# //------------------------------------------------------------------------------
proc item_calc_fitness_nov {item fitnessfunc task} {


  set fit [item_get_fitn  $item]
  
  if {[string equal $fit  $::GA_NOT_FIT]} {
    
    item_calc_fitness  $item $fitnessfunc  $task
  }

}
# //------------------------------------------------------------------------------
# //  synopsis:	Fitness evaluations.
# //		Evaluate all previously unevaluated entities.
# //		No adaptation.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc itemlist_calc_fitness_nov {itemlist task} \
{

  #set itemlist    [GET $pop  "itemlist"] 
 
  set fitnessfunc [GET $task "fit_func"]
 
  foreach item $itemlist {

    item_calc_fitness_nov  $item $fitnessfunc  $task
  }

  return
}
################################################################################
################################################################################
  #set itemlist [make_itemlist $task \
  #                 $population_size $len_chromosomes]
  

  #itemlist_calc_fitness_nov  $itemlist $task
  #itemlist_print $itemlist " %4d)   " "%s " stdout

  
  #set pop_items [try_mutate_for_all_items   $itemlist $task $::DEEP]
  #puts ""
  #itemlist_print $pop_items " %4d)   " "%s " stdout

  #puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts ""

  #set prgpop [make_prgpop  $task \
  #              $population_size $len_chromosomes]
 
  #puts "prgpop = $prgpop"
  
  #puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts ""
  
  # set mutprob [dict_parse  $args "-mutprob" 0.1]
  # set m [expr {$len - $l}]  ;# сделаем сколько-то мутантов
  # set mutated_items  [make_mutated_from_items  $task $sorted_items $m  $mutprob]
  
  # хорошо бы попробовать по одному итему поработать ..

  #set item_old [lindex $itemlist 0]

  #item_print $item_old
  
  #set fitn_old  [item_get_fitn   $item_old] 
  #set item_new  [try_mutate_to_best  $::DEEP $task \
		   $item_old $fitn_old]

  #item_print $item_new

  #puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts ""
  
#-------------------------------------------------------------------------------

# NEXT_01  - простейший тест из плюсов и минусов

set ::sum        0  ;# начальное значение сумматора 
set ::sum_target 0  ;# к чему стремимся, что надо получить 

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
v0_make_tclproc  null {} {

  set ::sum 0

}
#-------------------------------------------------------------------------------

v0_make_tclproc  p1 {} {incr ::sum +1}
v0_make_tclproc  p3 {} {incr ::sum +3}
v0_make_tclproc  p5 {} {incr ::sum +5}

v0_make_tclproc  m1 {} {incr ::sum -1}
v0_make_tclproc  m3 {} {incr ::sum -3}
v0_make_tclproc  m3 {} {incr ::sum -5}

#-------------------------------------------------------------------------------
proc FITPROC_01_NEW {p task args} {

  set joy_prg  [item_get_mainsrc $p]

  set result [getresult_prg  $joy_prg]

  set fitness [expr {abs($::sum_target-$result)}]  ;# ??

  #puts stderr "FITPROC_01_NEW: result = $result, joy_prg = $joy_prg"

  #set fitness [expr {($::sum_target - $result)}] 
  #set fitness [expr {sqrt ( abs ($::sum_target * $::sum_target - $result * $result))}] 
  #set fitness $result

  return $fitness
}
#-------------------------------------------------------------------------------
proc TEST_randprog {args} {


  # f~.tl TEST TEST_randprog 2014
  #incr ::ind0
  #incr ::ind0

  #read_seedflag ::ind0

  set_seedflag [lindex $args 0]

  #   set minlen 1
  #   set maxlen 8
  #

  set n 10

  set gp_list     "+ - * dup i" 

  #------------------------------------------
  #set ::randinstr randinstr_MAIN

  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc "quotes_proc_NULL"
  #------------------------------------------


  v1_init  ;# ERROR = can't use non-numeric string as operand of "*"
            # NOT result !!
  # stack= | 3 {i dup dup i i dup - +} {2op *} |  instr= tcl  
  # ERROR = can't use non-numeric string as operand of "*"

  set task [task_create  \
	      -quotes_proc "make_quotes_TCL" \
              -gp_list     $gp_list \
	      -ios_BEGIN {N} -ios_FINAL {N} \
	     ]
  

  #set prg [make_randprog  $task $n $::randinstr $::quotes_proc]
  set prg [make_randprog  $task $n]

  #set prg "dup *"

  set x 3 

  DebugOn
  d+
  set result [getresult_prg_val_11  $prg $x]
 	
  puts ""

  if {$result eq {}}  {
    puts "NOT result !!"
  } else {
    puts "x= $x  result= $result"
  }
  
}
#-------------------------------------------------------------------------------
proc NEXT_test {args} {


  # f~.tl TEST NEXT_test 2014
  #incr ::ind0
  #incr ::ind0

  #read_seedflag ::ind0
  #----------------------------------

  #puts ""
  puts "args = $args"
  puts ""

  #set flag [lindex $args 0]
  #set_seedflag $flag 

  set_seedflag [lindex $args 0]

  set gp_list "p1 p3" 
  #set gp_list "dup * +"

  ios_add_new  p1  {} {}
  ios_add_new  p3  {} {}

  set ::sum_target 10

  set task [task_create  \
	      -quotes_proc "quotes_proc_NULL" \
              -fit_func  FITPROC_01_NEW  -fit_tobest  "MIN" -fit_target  0  \
	      -gp_list  $gp_list]
  
  v1_init
  
  set len_chromosomes  3
  
  set p [make_randprog  $task [comm_random_int_minmax 1 $len_chromosomes]]

  puts "p = $p"

  return
}
#-------------------------------------------------------------------------------

# j~.tl TEST NEXT_test

# f~.tl TEST TEST_randprog @
# f~.tl TEST TEST_makeparas
# f~.tl TEST TEST_trans_01
# f~.tl TEST TEST_pp @
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# TODO :

# +) печатать подробно все шаги 
# +) при клонировании рефакторить с выделением новых библю функций

# -) в библ. добавить крайние значения, т.е. контекст и + статистика использования
# -) мутировать не произвольно а в соотвт. с плюсовой статистикой 
# -) возможно запоминать хорошие "практики мутирования"
#

# В общем, надо отслеживать и использовать, следующие статистики :
#   - динамические шаблоны полезных мутаций
#   - статическое распределение шаблонов по популяции (библиотеки?)
#   - полезность отдельных операций в рантайме (и сразу реагировать на крах?)

#   - учитывать арность операций и текущий размер стека ?!!!! !!!!!!!!!!!!!

#-------------------------------------------------------------------------------

# Основные идеи:

# -) поиск и выделение частей-функций в программах, занесение их в библиотеку,
#   и рефакторинг шаблонов, как основной путь эволюции;

# -) шаблоны вырезаются и записываются в библиотеку вместе c некоторой инфой об 
#   их окружении; эта инфа используется как "описание типов" для адекватной
#   подстройки программ в эволюции;

# -) универсальная передача параметров через args (dict_print);

# -) gp_list --> ::mainlib (с индексом пригодности и его привязкой к 
#                "окружению" потом)
# -) лучшие проги заносим в ::mainlib (аналог как у новосибирцев)
# -) 
# -) запуск joy_run ? с использованием сторонних библиотек (::mainlib);

# run_v1_src_or_prog ->  run_v1_src   $proga 
#                    ->  run_v1_prog  $prog  - будет через библиотеки !!


# +) обратный анфакторинг (распаковка процедур) : make_unfactoring_prog
# +) слияние нескольких программ с локальными библиотеками : commit
# -) слияние и рtфакторинг с использованием общей библиотеки.

# +) перевод всех алгоритмов : prg --> prog ;
# -) поиск лучшего решения путем рефакторинга;

#-------------------------------------------------------------------------------
# 
# f~.tl TEST TEST_lips
# 
#-------------------------------------------------------------------------------
proc ios_init_TEST_xx {} {

  #::IOS
  
  ios_add_new  nop {}    {} 
  ios_add_new  dup {A  } {A A} 
  ios_add_new  *   {N N} {N  }
  ios_add_new  +   {N N} {N  }

  #set ::IOS_begin 1
  #set ::IOS_final 1

}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc ios_calc_balans_prg {prg} {

  set balans 0

  foreach p $prg {

    #set inp [dict get $::IOS $p "inp"] ;# сколько берет из стека
    #set out [dict get $::IOS $p "out"] ;# сколько кладет
    set sum [dict get $::IOS $p "sum"] ;# суммарный баланс

    #incr balans [expr {- $inp + $out}]
    incr balans $sum

    #puts "p = $p, balans = $balans"
  }

  return $balans
}
# ------------------------------------------------------------------------------
proc ios_calc_balans_full {ios_begin prg ios_fina} {

  
  set balans [ios_calc_balans_prg  $prg]

  return [expr {$ios_begin + $balans - $ios_final}]
}
# ------------------------------------------------------------------------------
proc ios_calc_balans_list {ios_begin prg ios_final} {


  set balans $ios_begin ;# сразу жобавим начальную арность стека
  
  set ret {}
  set len [llength $prg]

  for {set i 0} {$i < $len} {incr i} {

    set p [lindex $prg $i]

    set sum [dict get $::IOS $p "sum"] ;# суммарный баланс
    incr balans $sum

    if {$i == [- $len 1]} {
      incr balans -$ios_final ;# последний элемент уже сравним с нужным выходным
    }

    lappend ret $balans
  }
 
  # программа будкт считаться семантически корректной, если все элеметы вых.
  # списка >= 0 (== 0 могут быть такие операторы), а последний элемент == 0.
  # 
  # к этому и надо стремится мутируя программу

  # TODO - нет, неверно, слишком упрощенно, надо не только сумму баланса,
  #        но именно по входу чтобы небыло ошибки, т.е. нужна пара !!!

  return $ret
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc ios_print {} {

  # структура
  #
  # dup {inp 1 out 2 INP {A  } OUT {A A} sum 1}
  #
  # 
  #
  #
  #
  ##############################################


  dict for {prgname iosdict} $::IOS {

    set INP [dict get $iosdict "INP"]
    set OUT [dict get $iosdict "OUT"]

    puts [format "  %10s : %7s  -->  %7s" $prgname $INP $OUT]
  }

  return
}
#-------------------------------------------------------------------------------
proc TEST_ios1 {args} {

  puts ""
  puts "TEST_lips"
  puts ""

  ios_init_TEST_xx 


  #puts "::IOS = [set $::IOS]"
  puts "::IOS = $::IOS"
  puts ""
  ios_print 
  puts ""

  #set b [ios_calc_balans_prg  "dup dup"]

  set ios_begin 1
  set ios_final 1
  
  #set prg   "dup dup * +"
  set prg   "* dup dup +"

  #set f [ios_calc_balans_full  $begin $prg $final]
  #set f [ios_calc_balans_full  $prg]

  set lst [ios_calc_balans_list $ios_begin $prg $ios_final]
  #set lst [ios_calc_balans_list $prg ]

  puts "full balans: $ios_begin | $prg | $ios_final,  lst = $lst   ???"

}
#-------------------------------------------------------------------------------
proc ios_init_test_operators {} {

  # TODO
  #    - заменить реальную программу тестовой по типам
  #    - провеить типы и скорректировать?
  #    - в дальнейшем можно интегрировать все это в общуюу схему?


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_make_tclproc  _ {} {
    
    #eval [pop]
    
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_make_tclproc  _A {} {
    
    #eval [pop]
    
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


}
#-------------------------------------------------------------------------------
proc pop_N {num} {

  # вытащим из стека сразу несколько элементов "списком как есть"
  #
  
  set ret {}
  
  for {set i 0} {$i < $num} {incr i} {
    
    lappend ret [pop]
    #puts "pop_N: i = $i, ret = $ret"
  }
 
  return [lreverse $ret]
}
#-------------------------------------------------------------------------------

  # A - all types
  # N - number
  # D - decimal
  # F - float
  # L - list (можно дальше уточнять подтип этой структуры, т.е. список типов)

#-------------------------------------------------------------------------------
proc lequal {l1 l2} {

  foreach elem $l1 {
    if {$elem ni $l2} {return false}
  }

  foreach elem $l2 {
    if {$elem ni $l1} {return false}
  }

  return true
}
#-------------------------------------------------------------------------------
# proc is_gen_correct {is_not_final gen} {


#   set INP_true [dict get $::IOS $gen "INP"] ;# входы  для этого оператора (гена)
#   set OUT_true [dict get $::IOS $gen "OUT"] ;# выходы для этого оператора (гена)
  
#   set INP_true_len [llength $INP_true] ;# длина входов
#   set OUT_true_len [llength $OUT_true] ;# длина выходов
  
#   # лучше бы здесь сразу взять часть стека? или хотя бы для информации  
#   #set INP_stack [lrange $::joy_ST end-[- $INP_len 1] end]
  
#   puts -nonewline \
#     [format "%d  gen= %5s, ::joy_ST= %5s, INP_true= %5s ; .. " \
#        $is_not_final $gen $::joy_ST $INP_true]
  
  
#   set INP_real [pop_N   $INP_true_len] ;# взять из стека несколько элементов
  
  
#   if [lequal  $INP_real $INP_true]  {
#     puts "ok"
#     return 1;
#   } else {
#     puts "error"
#     return 0;
#   }
    
# }
#-------------------------------------------------------------------------------
proc ios_check_prg_from_left {prg ios_BEGIN} {


  set ::joy_ST {}  ;# The VM stack 
  # 
  # воспользуемся программным стеком и функциями работы с ним
  # для оценки соответсвия по типа, при этом имитировать работу отдельных генов
  # не будем, только типы..

  push {*}$ios_BEGIN   ;# положим в стек начальный список (типов) как есть, т.е.
                       ;# по одному элементу за раз (как бы перемещая список целиком)

  set len [llength $prg]

  set ret [list 0 {}]
  set err 0

  #puts "ios_check_prg_from_left: prg = $prg"

  for {set p 1} {$p <= $len} {incr p} {

    set gen [lindex $prg [- $p 1]]


    set INP_true [dict get $::IOS $gen "INP"] ;# входы  для этого оператора 
    set OUT_true [dict get $::IOS $gen "OUT"] ;# выходы для этого оператора 
    
    set INP_true_len [llength $INP_true] ;# длина входов
    set OUT_true_len [llength $OUT_true] ;# длина выходов
    
    # лучше бы здесь сразу взять часть стека? или хотя бы для информации  
    #set INP_stack [lrange $::joy_ST end-[- $INP_len 1] end]
    
    #puts -nonewline \
      [format "gen= %5s, ::joy_ST= %5s, INP_true= %5s ; .. " \
         $gen $::joy_ST $INP_true]
    
    
    set INP_real [pop_N   $INP_true_len] ;# взять из стека несколько элементов
    
    
    if [lequal  $INP_real $INP_true]  {
      #puts "ok"
      #return 1;
    } else {
      #puts "error"
      #return 0;
      set ret [list $p $gen [list $INP_real $INP_true]]
      break;
    }
    
    #-----------------------------------------------------

    # теперь надо положить в стек выходные типы этого оператора

    set OUT [dict get $::IOS $gen "OUT"] ;# выходы для этого оператора (гена)
    push {*}$OUT

  } ;# for {set p 0} 


  # надо забрать из стека остатки и добавить в выход, как доп. инфу 
  # 

  lappend ret $::joy_ST

  set ::joy_ST {}

  return  $ret
}
#-------------------------------------------------------------------------------
proc ios_check_prg {prg ios_BEGIN ios_FINAL} {


  set ret [ios_check_prg_from_left  $prg $ios_BEGIN]

  set err_code [lindex $ret 0]
  set err_more [lindex $ret 1]
  set retstack [lindex $ret 2]

  #puts ""
  #puts "ret = $ret"
  #puts "::joy_ST  = $::joy_ST"
  #puts "ios_FINAL = $ios_FINAL"
  #puts ""

  if {$err_code } {
    return $ret
  } ;# ошибка была обнаружена



  # надо посмотреть финал
  #puts "ios_check_prg : ret = $ret !!!!!!!!!!!!!!!!!!!!!!!!!!"

  set len [llength $prg]
  set gen_last [lindex $prg [- $len 1]]

  if {$retstack == $ios_FINAL} {
    #puts "1111111111111111111"
    # на выходе то что надо, совпадает с ожидаемым результатом в стеке
    # так что вернем то что было найдено 
    set ret [list 0 {} {}]

  } else {
    ;# ошибка на выходе

    #puts "ios_check_prg : ret = $ret ????????????????????????"

    # len      - 
    # gen_last - 
    # {}       - входы совпадали, не было ошибки 
    # {$retstack $ios_FINAL} - а вот выходы финала не те
    #  
    #  
    #set ret [list $len $gen_last {} [list $retstack $ios_FINAL]] ;# ????
    set ret [list   $len {} $retstack] ;# ????
    #puts "ios_check_prg : ret = $ret ~~~~~~~~~~~~~~~~~~~~~~~~~!!"
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc list_not_exist_in_list {prg rez} {

  #return 1

  foreach r $rez {

    if { $r eq $prg } {
      return 0
    }
  }

  return 1
}
#-------------------------------------------------------------------------------
proc add_to_try  {try try_add} {

  upvar $try t

  #lappend t {*}$try_add

  foreach a $try_add {

    #lappend t $a

    if [list_not_exist_in_list $a $t] {
      lappend t $a
    }
  }

}
#-------------------------------------------------------------------------------
proc ios_find_correct_prgs {nums ios_BEGIN ios_FINAL} {


  set rez {} ;# для найденных вариантов
  set try { START } ;# поисковые варианты (с выходами?) затравочный

  #set deep 1 ;# длина создаваемых программ на этом шаге 

  for {set i 1} {$i <= $nums} {incr i} {

  foreach try_prg $try { 

    set try_len [llength $try]
    set try_add {} ;# добавим на этом шаге

    dict for {gen value} $::IOS {     

      set INP [dict get $::IOS $gen "INP"]
      #set OUT [dict get $::IOS $gen "OUT"]
      #puts "len = $len"

      if {$try_len == 1} {
        # пока кроме затравки-пустышки ничего нет
        set prg {} ;# не нужна эта "затравка"
      } else {
        set prg $try_prg
      }
      

      lappend prg $gen ;# добавим к незавершенной программе еще ген
      # 
      # TODO: здесь надо еще смотреть особые случаи, например
      #       если на входе треба список, надо его бы создать !!?
      # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
      #puts "INP = |$INP| ????"

      if { $INP == "L  " } {
        puts "INP = $INP !!!!!!!!!!!!!!!"
      }
      
      set ret [ios_check_prg  $prg  $ios_BEGIN $ios_FINAL]
      
      foreach {err_code err_more retstack} $ret {break;}
      
      #puts [format "prg = %10s, ret = $ret" $prg]
      
      if {$err_code} {
        #
        # не надо все добавлять! А только те у которых ошибка на выходе пока
        # 
        #puts "err_more = $err_more"

        if {$err_more eq {}} {
          #puts "retstack = $retstack, prg = $prg"
          lappend try_add $prg ;# в список на этом шаге добавим плохую прогу
        }
        #
        # TODO: надо добавлять в словарь по выходам !!!!
        #
      } else {
        # программа корректная, добавим если такой еще нет
        if [list_not_exist_in_list $prg $rez] {
          lappend rez $prg
        }
      }
      
    } ;# dict 
    

    if {[llength $try_add] && $try_len == 1} {
      # это особый начальный случай
      set try $try_add
    } else {
      #lappend try {*}$try_add
      add_to_try  try $try_add
    }
    
    if {1} {
      #puts ""
      #puts "try_add = $try_add"
      puts "try     = $try \n"
      #puts "rez     = $rez"
      #puts ""
    }
    
  }}

  #puts "try     = $try"

  return $rez
}
#-------------------------------------------------------------------------------
proc compare_two_lists_with_hash_table {list1 list2} {

  #compare two lists with hash table

  if {[llength $list1] ne [llength $list2]} {
    puts "number of list elements is different"
  } else {
    puts "there are [llength $list1] list elements"
  }

  set i 1

  foreach aa {$list1} bb {$list2} {
    set a($i) $aa
    set b($i) $bb
    incr i
  }

  for {set j 1} {$j <= [llength $list1]} {incr j} {
    if { $a($j) ne $b($j) } {
      puts "No Match $a($j) $b($j)"
    } else {
      puts "Match $a($j) $b($j)"
    }
  }

}
#-------------------------------------------------------------------------------
proc compare_two_lists {list1 list2} {


  set len1 [llength $list1]
  set len2 [llength $list2]

  if {$len1 ne $len2} {
    return false
  } 
  
  for {set i 1} {$i <= $len1} {incr i} {

    set l1 [lindex $list1 $i]
    set l2 [lindex $list2 $i]

    if { $l1 ne $l2 } {
      return false
    } 
  }

  return true
}
#-------------------------------------------------------------------------------
proc TEST_ios2 {args} {

  puts ""
  puts "TEST_ios2"
  puts ""

  #           имя   вход   выход
  ios_add_new  A_   {A  }  { } 
  ios_add_new  _A   {   }  {A}
  ios_add_new  NA_  {N A}  { } 
  ios_add_new  L_   {L  }  { } 
 
  puts "::IOS = $::IOS"
  puts ""
  ios_print

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

  v1_init ;# воспользуемся стеком?

  set ios_BEGIN {N A}
  set ios_FINAL {N}   ;# {F} {}
  
  #set prg   "_ NA_"
  #set prg   "_ _A A_"
  #set prg   "_ _"
  set prg   "_A  A_"

  puts ""
  puts "ios_BEGIN = $ios_BEGIN, prg = $prg, ios_FINAL = $ios_FINAL"
  puts ""

  set ret [ios_check_prg  $prg  $ios_BEGIN $ios_FINAL]
  foreach {err_code  err_more  retstack}   $ret {break;}

  puts ""
  puts "ios_check_prg: ret = $ret"
  puts ""
      
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  return





  set rez [ios_find_correct_prgs   3 $ios_BEGIN $ios_FINAL]

  puts ""
  puts "ios_find_correct_prgs: rez = $rez"
  puts ""

  return

  #set prg1 {_A A_  _A A_ A_}
  #set prg2 {_A A_  _A A_ A_}

  #set prg1 {_A A_  _  A A_ A_}
  #set prg2 {_A {_A B} A_ A_ A_}

  set prg1 {_A {A_ _B {A C}} _A A_ A_}
  set prg2 {_A {A_ _B {A A}} _A A_ A_}

  if { $prg1 ne $prg2 } {
    puts "ne !!!"
  } else {
    puts "equal !!!"
  }
  

  #set e [lequal $prg1 $prg2]
  #set e [compare_two_lists_with_hash_table $prg1 $prg2]
  set e [compare_two_lists $prg1 $prg2]
  
  puts "e = $e"

  return
}
#-------------------------------------------------------------------------------
#
# f~.tl TEST TEST_ios2
# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
