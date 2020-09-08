# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------


package require tcltest

namespace import tcltest::*


#-----------------------------------------------------------------------------
# 
#   СТРОКИ + БЛОКИ = ПРОГРАММЫ
# 
#
# TODO: ключевая точка роста, надо понять:
#
# - куда записывать fitness (main должна быть такой же функцией как все!)

# - в чем разница "prog" и "libra"
# - нужно ли делать через глобальные указатели ? тогда изменения будут видны сразу
#   для всех организмов
# - но можно сделать и локально, просто скопировав!

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc make_itemslist_from_prgpop {prgpop} {


  set itemslist {}
  
  # идем списком по "сырым заготовкам" - только программы
  # 

  foreach prg $prgpop {

    set item  [item_make $prg] ;# здесь указатели !!

    # пока фитнеса нет, только программы

    lappend itemslist  $item ;# добавляем организма (указатели)
  }

  return $itemslist
}
#-------------------------------------------------------------------------------
# создаем начальную популяцию программ с заданным числом особей
# и с размерами в заданном интервале (UNICUM) 
#
# n - требуемое кол-во особей в популяции
#
#-------------------------------------------------------------------------------
proc make_rand_prgpop_unikum {n 
                               minlen maxlen 
                               gp_list randinstr quotes_proc} {

  set prgpop {}

  set attempts      0
  set max_attempts  [expr {$n / 3}] 
  
  for {set i 0} {$i < $n} {} {
    
    set p [get_randprog_unikum  $prgpop $minlen $maxlen \
                                $attempts $max_attempts \
                                $gp_list  $randinstr $quotes_proc]
    
    if {$p == {}} { 

      # неудачная по пытка создания уникума
      #puts "NOT find PRG !! attempts = $attempts"

      incr  attempts ;# сколько неудачных попыток уже было
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

#-------------------------------------------------------------------------------
proc make_rand_prgpop {bnums minlen maxlen  gp_list randinstr quotes_proc} {

  set prgpop {}

  while {[incr bnums -1] >= 0} {

    set n [myrand $minlen $maxlen]

    lappend prgpop [make_randprog $n  $gp_list $randinstr $quotes_proc]
  }

  return $prgpop
}
#-------------------------------------------------------------------------------
proc pop_print_B {pop} {


  set i 1
  
  foreach item $pop {

    puts -nonewline [format "  %2d)  " $i]

    #item_print  $item
    puts "$item"

    incr i
  }

  puts ""
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set ::len_is_constant 0

#-------------------------------------------------------------------------------
proc make_prgpop {randpop_proc 
                            population_size len 
                            is_print 
                          } {


  # создаем стартовую популяцию (здесь пока только сами программы, не агенты!!!)
  # т.е. сырые заготовки в формате JOY
  #

  #----------------------------------------
  if {$::len_is_constant} {
    set minlen $len
  } else {
    set minlen 1
  }

  set maxlen $len
  #----------------------------------------

  set prgpop [$randpop_proc  $population_size  $minlen $maxlen \
                           $::gp_list   $::randinstr $::quotes_proc]
  
  if {$is_print} {
    puts ""
    puts "INIT POPULATION = \n"
    puts "$prgpop \n"
    puts ""
    pop_print_B  $prgpop 
    puts ""
  }

  return $prgpop
}
#-------------------------------------------------------------------------------
proc make_itemslist {randpop_proc 
                            population_size len 
                            is_print 
                          } {

  
  set prgpop [make_prgpop  $randpop_proc \
                            $population_size $len \
                             $is_print]

  puts ""
  puts stderr "randpop_proc = $randpop_proc"
  puts stderr "prgpop       = $prgpop"
  puts ""

  # TODO:
  # 
  # а вот здесь уже можно сделать реальные программы с "main" и т.д.
  #

  set itemslist [make_itemslist_from_prgpop  $prgpop]


  return $itemslist
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------

set ::IN  {}  ;# стек интервалов зарисовки 

set ::RN 100  ;# процент случайного возврата 1

set ::proc_index 1

#-------------------------------------------------------------------------------
proc is_equal {item1 item2} {

  set len [llength $item1]

  if {$len == 1} {return false}

  for {set i 0} {$i < $len} {incr i} {


    if {[lindex $item1 $i] != [lindex $item2 $i]} {return false}
  }

  return true
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


  #dputs "substrings_find_all: ~~~~~~~~~"
  #dputs ""
  #dputs "prg   = $prg"
  #dputs "len   = $len"
  #dputs "max_w = $max_w"
  #dputs ""


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



  set ret [dict create]

  set ret_list {} ;# сделаем по-новому - "новичок"

  
  foreach w [lsort -decreasing [array names L]] {

    set L_w [set L($w)] ;# items

    if {$L_w == {}} {continue} ;# оставляем только те, где есть повторения

    #puts "w = $w  L_w = $L_w" ;# TODO: надо дописать туда w в каждый item !!!!

    dict set ret  $w $L_w
    lappend ret_list $L_w
  }

  #dputs ""
  #dputs "ret = $ret"
  #dputs ""
  #dputs "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #dputs ""

  return [list $ret] ;# уже по убыванию!
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

    if {[expr ! ($is_1 || $is_2)]} {return false} ;# пересекаются?
  }

  # вроде бы место свободно, все хорошо. но !
  # можно в этом месте ввести элемент случайности

  if {[random_0_or_1] == 0} {

    return false ;# колесо фортуны
  }

  return true
}
#-------------------------------------------------------------------------------
proc interval_draw {fl_ptr  i1 i2} {

  # это более совершенный вариант, кладем в стек интервал (границы отрезка)
  # 


  if {! [interval_draw_check_new  $i1 $i2]} {return false}

  interval_push  [list $i1 $i2] 

  return true
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
    prog_set_prg_src  prog $proc_name $subs

    # на место строки записываем уже готовое имя процедуры
    # 
    lappend clean_items_with_proc [list $proc_name $nums $w]
  }

  return $clean_items_with_proc
}
#-------------------------------------------------------------------------------
proc find_equal_index {nums i} {

  foreach n $nums {

    if {$n == $i} {return true}
  }

  return false
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

    return true;
  }

  if {$len_new == 1} {

    # одни нас не устроит, это не "рефакторинг", надо отыграть назад
    # 

    interval_pop
  }

  return false; ;# не найдено пары интервалов, так и ничего не запишем.
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

    dict set prog_ret $key $value 
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
  foreach {all_witems} [substrings_find_all $prg_old $start_w] {break}


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

  if {[dict exist $prog $p]} {

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

    puts "p = $p"

    set f [proc_find $prog_old $p]
    
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
proc canonical_form {prog} {

  set prog_ret {}

  dict for {key value} $prog {

    #puts "canonical_form: key= $key value= $value"

    set prg_src [dict get $value "src"]    
    dict set prog_ret $key $prg_src

  }

  return $prog_ret
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


set ::randinstr   "randinstr_SIMP"
set ::quotes_proc "quotes_proc_NULL"

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
proc randinstr_ARGS {gp_list} {

  set instr [lrand $gp_list]
  
  set arglist [info args $instr]
  
  if {[llength $arglist] == 0} { #if {$arglist eq {}}  - для Tcl-8.4 
    #puts "111111111111"
    return $instr
    
  } else {
    
    #puts "222222222222"
    info default $instr [lindex $arglist 0] l

    foreach {min max} $l break
    return [list $instr [rand $min $max]]
  }

}
#-------------------------------------------------------------------------------
# возвращаем случайную инструкцию
# пока упрощенный вариант -  не получается анализ аргументов
#-------------------------------------------------------------------------------
proc randinstr_SIMP {gp_list} {

  #puts ""
  #puts "RANDINSTR ... !!"

  set  instr   [lrand $gp_list]

  #------------------------------------------------------------
  #set  procname ::joy::builtin::${instr} ;# делаем имя более уникальным!
  #puts "instr= $instr  procname= $procname"

  # проверяем наличие переменной массива (туда записывали инфу)
  #if {[info exists ::joy::builtin($instr)]} {
  #  # если есть уже во встроенных функциях, то 
  #  puts "222"
  #} else {
  #  puts "333"
  #}

  #puts ""
  #set arglist [info args $instr]  ;# список параметров процедуры

  #set arglist [info args $procname]  ;# список параметров процедуры
  #"::joy::builtin::-" isn't a procedure
  #while executing "info args $procname"

  # тут проблема в "Math related functions":
  # все они регистрируются через одну функцию "+",
  # "::joy::builtin::+" что не очень правильно !!
  # !!! TODO: сделать раздельную регистрацию этих функций !!!

  #puts "arglist= $arglist"
  #puts ""
  #------------------------------------------------------------
  
  # если простые процедуры без аргументов:
  return $instr
  


  #------------------------------------------------------------
  #puts "instr= $instr   arglist= $arglist"
  
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
  #------------------------------------------------------------
  
} 
#-------------------------------------------------------------------------------
proc quotes_proc_NULL {oldprg} {

  set newprg $oldprg

  return $newprg
}
#-------------------------------------------------------------------------------
# создать случайную программу (список?) длиной не больше 'n' или равно ??
# 
#-------------------------------------------------------------------------------
proc make_randprog {n gp_list {randinstr "randinstr_SIMP"} {quotes_proc "quotes_proc_NULL"}} {

  while {[incr n -1] >= 0} {

    set instr [$randinstr $gp_list]

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
proc get_randprog_unikum {result minlen maxlen attempts max_attempts 
                          gp_list randinstr quotes_proc} {

 #puts "... 1"

 set prg [make_randprog [myrand $minlen $maxlen] \
            $gp_list $randinstr \
            $quotes_proc]

 #puts "prg = $prg "
 #puts "result = $result"
 #puts "... 2"

 # 
 # здесь надо бы сравнить на уникальность?
 #
 set ix [lsearch -exact $result $prg]

 if {$ix >= 0} { 
   #puts "ALREADYyyy: result= $result  prg= $prg "
   #continue ;# не возьмем уже такую же особь в популяцию
   # но тогда популяция станет маленькой, надо пробовать другие..
   #puts "attempts = $attempts"
   
   if {$attempts < $max_attempts} {
     set prg {} ;# если попыток подряд мало, 
     #puts "attempts < 2 "
     # то вернем пустой список, как сигнал, что не найдено

   }  else {

     # а иначе пусть останется дубляж ..
     #puts "NOT FIND:  $prg  attempts=$attempts max_attempts=$max_attempts"
     puts "NOT FIND:  $prg"
   }
 }
 
 return $prg 
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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

  test simple_06 {} {
    
    set prog_old [list \
                    "main"  {"src" {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {"src" {p1 p1 p1}}]

    proc_name_index_init ;# 2 ;# !! новые имена генерим с этой цифры (заплатка)

    set prog_new [libra_refactoring  $prog_old 2]

    return [canonical_form $prog_new]

  } {main {proc2 proc2 proc1} proc2 {proc1 p2 p2} proc1 {p1 p1 p1}}

  #-----------------------------------------------

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc ITEM_test {} {

  puts ""
  puts "----------------------------------------------------"
  puts ""

  ALL_TESTS

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


  #set prog_origin  [make_simple_main_prog $src]
  #puts "prog_origin = $prog_origin"

  set item_prog    [item_make $src]  

  puts " src = $src"
  puts "item = [set $item_prog]"

  #puts ""
  #puts "----------------------------------------------------"
  #puts ""

  #set ::NEW 1

  #set item_prog    [item_make $src]  

  #puts " src = $src"
  #puts "item = [set $item_prog]"

  #puts ""
  
  return

  #d+

  set start_w 2   ;# минимальное окно сканирования

  #random_set  70 ;# вероятносность


  proc_name_index_init

  set prog2 [libra_refactoring   $prog_origin $start_w] 

  puts "----------------------------------------------------"
  puts ""
  puts "prg_origin = $prg"
  puts ""

  #puts "prog1 = $prog1"  
  puts "prog2 = $prog2"  
  puts ""

   
  puts "RandYes 100 = [RandYes 100]"
  puts "RandYes  90 = [RandYes  90]"
  puts "RandYes  50 = [RandYes  50]"
  puts "RandYes  10 = [RandYes  10]"
  puts ""

  set prog3 [make_unfactoring_prog  $prog2]

  puts ""
  puts "prog3 = $prog3"  
  puts ""
  puts "----------------------------------------------------"
  puts ""


  set prog4_old  [list \
                    "main"  {src {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {src {p1 p1 p1}}] 

  puts "prog4_old = $prog4_old"  
  puts ""

  #------------------------------------------------------------

  #set prog_new = main {src {proc1 proc1 proc1}} proc1 {src {proc1 p2 p2}}

  #set prog_new  [list \
                    "main"  {src {proc1 proc1 proc1}}  \
                    "proc1" {src {proc1 p2 p2}}] 

  #set      prog_new [commit_to_from  $prog_new $prog_old] 

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
