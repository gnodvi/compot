# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
if [info exists ::F_1111_TL] {
  return
} else {
  set  ::F_1111_TL ""
}

#-------------------------------------------------------------------------------
# #!/bin/sh
# # \
# exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#
# http://wiki.tcl.tk/13742
#
#-------------------------------------------------------------------------------

# Richard Suchenwirth 2005-05-07 

# Почти каждый год я читал литературу по Forth 
# и Joy и мне приспичило седлать RPN на Tcl - смотри "Minimal RPN", 
# "Playing Joy" and "RPN again for earlier takes". Это было в далеком 2005.

# В стремлении к минимализму, "runtime engine" сейчас называется просто "r" 
# (не путать с  R-языком), и сводится к 3-х позиционному switch для каждого 
# слова :

#  1) "tcl" определяет (выполняет) верхушку стека как Tcl-скрипт;
#  2) известные слова в массиве ::joy_proglist - рекурсивно выполняются в "r";
#  3) другие слова просто задвигаются (pushed);

# Обильное цитирование для типов в Joy ([list], {set}, "string", 'char) конфликтует 
# с Tcl-парсером, поэтому списки в "r" оформляются фигурными скобками {braced},
#  если их длина не 1, и круглыми скобками (parenthesized), если ровно 1 - и само 
# слово не вычиляется тогда. Это выглядит для меня предпочтительнее, чем /slashing 
# в Postscript, и также в  RPN.

# Поскольку "everything is a string", и в Tcl "a" это {a} и это a , полиморфизм Joy
# нужно сделать явным. 
# Я добавил конверторы между "characters" и "integers", и между "strings" и "lists"
# (см. словарь ниже).
# Но Для "Joy's sets" я до сих пор не удосужился это седлать
# - они ограничены областью 0..31, вероятно реализованы битами в 32-битных словах.

# Поскольку это все из Joy, это все было проверено примерами из статей 
# Manfred von Thun's. Я насмешливо до сих пор называю это "Pocket Joy" - это для 
# меня в прошлом, на iPaq... 
# Тестовый набор в конце дает много примеров того, что можно сделать в "r".

#-------------------------------------------------------------------------------
#

set ::pref_quote      ~ 
set ::pref_movetovar  = 
set ::pref_pushbyvar  @ 

#-------------------------------------------------------------------------------
proc prefix_work {a} {


  # TODO: Сделать в общем виде: по префиксу (1-2 символа?) выполняем
  #       не стандартные действия:
  
  #       (name - поместить просто в стек (квотирование)
  #       >name - записать значение из стека в переменную   set_name
  #       $name - записать значение из переменной в стек    get_name
  # 
  
  # а наверное и не надо очищать от квоты?
  # но тогда надо будет очищать во всех остальных местах, при получении
  # 
  
  if {[string length $a] == 1} {

    #puts "a = $a"
    return 0
  }

  set pref [string index $a 0]
  
  #-------------------------------------------------------------
  if {$pref == $::pref_quote} {
    
    # сделаем такое квотирование особым вспомогательным методом
    # помещать в стек по сути, сразу очищая от квотирования
    # 
    
    push [string trim $a $::pref_quote]
    
    #return "continue" 
    retyrn 1
  }    
  #-------------------------------------------------------------
  # v0_: set     {set ::[pop] [pop]}            tcl
  # v0_: $       {push [set ::[pop]]}           tcl
  #-------------------------------------------------------------
  #if {0} {

  if {$pref == $::pref_movetovar} {
    
    # переместить значание из стека в переменную
    # 
    
    set name [string trim $a $::pref_movetovar]

    #push $name ;# на всякий случай квотируем !?
    #push set

    #puts "r_one : name = $name"

    set ::$name [pop]

    return "continue"  
  }  
  
  #-------------------------------------------------------------
  if {$pref == $::pref_pushbyvar} {
    
    # переместить значание из стека в переменную
    # 
    
    set name [string trim $a $::pref_pushbyvar]

    set var [set ::$name]

    #puts "r_one : var = $var"    

    #push [set ::$name]
    push $var

    return "continue"  
  } 

  #}   
  #-------------------------------------------------------------
  #if {$pref == "("} {
    
    # сделаем такое квотирование особым вспомогательным методом
    # помещать в стек по сути, сразу очищая от квотирования
    # ????
    # зачем дуьлировать эту фичу квотрирования ??
    #     
    #push [string trim $a ()]   
    #return "continue"  

    # лучше оставим пока как резерв, используем ждя чего-то другого

  #}    

  return 0
}
#-------------------------------------------------------------------------------
proc r_one {a} {
  
  #puts "r_one: a = $a"

  #-------------------------------------------------------------
  # TODO: а если команда - это указатель на словарь!?
  #
  # например {cmd p1  ver 0.5  type ... left ... rigth ...}

  #if {$::R_ONE_CMD} {}
    # сюда могут попасть внутренние "простые" команды, например . 

  if {[is_GLOBAL_DICT $a]} {

    set ver [GET $a "ver"] ;# посмотрим, задана ли вероятность !
    set cmd [GET $a "cmd"]

    if {$ver == {}} {
      set ver 1.0 ;# вероятность исполнения команды в потоке
    }

    #puts "R_ONE_CMD: cmd = $cmd, ver = $ver" 

    # и еще посмотрим вероятность, может и не будем выполнять
    # TODO:
 
    #set r [YRandF 0 1.0]
    set r [random_double_range 0 1.0]

    #puts "r = $r, ver = $ver"

    if {$r < $ver} {return} ;# return "continue"

    set a $cmd
  }

  #-------------------------------------------------------------


  # [info level] - уровень стека для текущей процедуры (для глобальной
  #                области видимости = 0)
  #dputs -nonewline [format "%s: " [info level]]
  
  if {[IsDebug]} {
    puts [format "stack= | %25s |  instr= %s  " $::joy_ST $a]
  }
  
  #-------------------------------------------------------------

  if [prefix_work $a] {
    return "continue"
  }

  #-------------------------------------------------------------
  # обрабатываем непосредственно инструкцию
  #-------------------------------------------------------------
  
  #if {$::NEW} {
  #} else {
  
  #  # 1) сначала смотрим в JOY-процедурах (системная библиотека)
  #  # 
  #  if       {[set prg [v0_find_joyprog $a]] != {}} {
  
  #    eval r $prg ;# рекурсивно выполняем 
  #    continue
  #  } 
  #}
  
  
  # 2) теперь смотрим в подключенных библиотеках c "prog"
  # 
  if       {[set progbody [biblio_find_progbody  $a]] != {}} {
    
    set src [dict get $progbody "src"]

    #puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    #puts "src = $src"
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    
    eval r $src ;# рекурсивно выполняем
    #
    # TODO отслеживать глуибну рекурсии, чтобы при аварии откатываться
    # на начало рекурсии ??
    
    return "continue"
  } 
  
  # 3) теперь смотрим в TCL-процедурах (лучше сделать через tcl-команду ?)
  # 
  if   {[set tclproc [v0_find_tclproc $a]] != {}} {
    
    $tclproc ;# выполняем зарегистрированную TCL-процедуру
    
    # 4) все остальное
    
  } else {
    
    push $a ;# все остальное "пихаем" в стек в том числе и группы
  }
  

  return ""
}
#-------------------------------------------------------------------------------

set ::error_saverestore 0

set ::error_print1 0
set ::error_print2 0
set ::error_print3 0

set ::r_one_level 0

set ::ST_save ""

#-------------------------------------------------------------------------------
proc r args {
  

  # идем списком по элементам команды
  # 

  foreach a $args {

    if {$::error_print3} {
      puts stderr [format "r: stack = %25s  |  a = %25s | %10s " $::joy_ST $a $::ST_save]
    }

    # перед попыткой выполнить оператор, сохраним стек, чтобы
    # в случае аварии - восстановить его и продолжить, как бы
    # пропустив этот "ошибочный" оператор
    
    # операторы могут быть сложные и прилично испортить стек
    # до того как дойдут до вложенного ошибочного оператора !!!
    # рекурсия  при вызове r_one -> r
    #
    
    if {$::r_one_level == 0} {
      set ::ST_save $::joy_ST
    }
    
    incr ::r_one_level +1
    
    #-------------------------------------------------
    if {[catch {set ret [r_one $a]} err]} {
    #-------------------------------------------------
      
      # перехвачена ошибка при выполнении опреатора $a
      
      if {$::error_print2} {
        puts "r_error_print2: r: err = $err, ST = $::joy_ST, ST_save = $::ST_save"
        puts ""
      }
      
      if {$::error_saverestore} {
        set ::joy_ST $::ST_save ;# ??
      }
      
      incr ::r_one_level -1
      
    #-------------------------------------------------
    } else {
    #-------------------------------------------------
      
      # все прошло нормально, без ошибок
      #puts "all ok, ret = $ret, r_one_level = $::r_one_level"
      
      incr ::r_one_level -1
      
      if {$ret == "continue"} {continue}  
          
      #incr ::r_one_level -1
      
    #-----------------------------------------------------------------
    }
    #-----------------------------------------------------------------
    
    
  } ;# foreach a $args


  #if {$::error_print3} {
  #  puts stderr [format "r: stack = %25s  |  " $::joy_ST]
  #}


  set ::joy_ST  ;# ??
}
#-------------------------------------------------------------------------------
proc run_v1_src {prg} {

  # prg - программа явным списком

  if {[IsDebug]} {

    puts ""
    puts "run_v1_src:  PRG = $prg"
    puts ""
  }


  r {*}$prg ;# раскроим список и выполним последовательность команд

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# functions written in Tcl
#
#-------------------------------------------------------------------------------

proc rifte {else then cond} {

  eval r dup $cond
  eval r [expr {[pop]? $then: $else}]

}
#-------------------------------------------------------------------------------
proc choice {z y x} {

  push [expr {$x? $y: $z}]

}
#-------------------------------------------------------------------------------
proc cleave { g f x} {

  #11_erase f

  eval [list r $x] $f [list $x] $g
}

#-------------------------------------------------------------------------------

# слишком упроещенная версия,к онфликтуют с ::tcl::mathfunc
# 

# proc max {x y} {expr {$x>$y ? $x:$y}}
# proc min {x y} {expr {$x<$y ? $x:$y}}


#-------------------------------------------------------------------------------
proc step {f list} {

  #foreach e $list {eval [list r ($e)] $f}

  #foreach e $list {eval [list r {nop $e}] $f}

  #foreach e $list {eval [list r '$e] $f} 

  foreach e $list {eval [list r ~$e] $f} 

}
#-------------------------------------------------------------------------------
proc rsplit {f list} {
 
  # нужно разбить список на два, в соответствии с условием
  #

  foreach i {0 1} {set $i {}} ;# зануляем два списка результатов
                              ;# 0 и 1 - э

  #11_erase f ;# очистим, если надо от ()

  foreach e $list {

    #puts "rsplit: e = $e"

    eval [list r   $e] $f ;# кладем e в стек и выполняем над ней функцию

    # какой-то хитрый приемчик распределения:
    
    #lappend [expr {!![pop]}] $e

    set res [pop]

    #set ind [expr {!! $res}] - так нельзя! мне нужно имя!!

    lappend  [expr {!! $res}] $e

  }

  push  $0 $1
}
#-------------------------------------------------------------------------------
proc primrec {f init n} {

  if {$n > 0} {

    push $n

    while {$n > 1} {
      eval [list r [incr n -1]] $f
    }

  } else {push $init}

}
#-------------------------------------------------------------------------------
proc rfold {f init list} {

  #puts "rfold:  f= $f  init= $init  list= $list"

  #11_erase_LIST f ;# почему не сработало?
  #11_erase  f ;# почему не сработало?

  #uts "rfold:  f= $f  init= $init  list= $list"


  push $init

  foreach e $list {eval [list r $e] $f}  
  
}
#-------------------------------------------------------------------------------
# фигня какая-то !
#-------------------------------------------------------------------------------
proc quote {instr} {

  eval $instr

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc v1_init_all_operators {} {


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_make_tclproc  tcl {} {
    
    eval [pop]
    
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # можно бы сделать и обычной tcl-процедурой, т.е. не регистрировать 
  # в ::instructios, ведь все равно map через .... tcl вызываем !
  #
  v0_make_tclproc  rmap {f list} {
    
    set res {}
    
    foreach e $list {
      
      eval [list r $e] $f ;# r  $e $f - т.е. выполняем f над каждым e
      
      lappend res [pop]
    }
    
    push $res
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  proc 2op op {
    
    set t [pop]  
    push [expr {[pop]} $op {$t}]
  }

  # functionality is exposed for binary operators and one-arg functions:
  #
  foreach op {+ - * / > >= != <= <} {

    v0_: $op [list 2op $op] tcl
  }
  
  # здесь не создаются "реальные" процедуры TCL, а пока только заготовки,
  # которые в дальнейшем будут интерпретироваться!

  v0_: =  {2op ==} tcl
  
  #--------------------------------------------------------------
  
  proc 1f  f {push [expr $f ([pop])]}
  # 
  #proc 1f  f {push [expr $f [to_quote [pop]] ]}
  
  foreach f {abs double exp int sqrt sin cos acos tan} {

    v0_: $f [list 1f $f] tcl
  }
  
  #--------------------------------------------------------------
  # The "dictionary" has all one-liners:
  #--------------------------------------------------------------
  
  #--------------------------------------------------------------
  # рекурсивно выполняем?

  #v0_: i    {eval r [pop]}    tcl  
 
  v0_: i  {
    set a [pop]  
    eval r $a
  }  tcl  

  #--------------------------------------------------------------

  #v0_: .       {pn "[pop] "}                  tcl
  v0_: .       {puts "[pop] "}                 tcl
  v0_: .s      {puts  $::joy_ST}               tcl
  
  #--------------------------------------------------------------
  # вот, это команды !!!! 
  # 
  #v0_: '       {push [scan [pop] %c]}         tcl  ;# char -> int
  #v0_: `       {push [format %c [pop]]}       tcl  ;# int -> char

  v0_: char2int   {push [scan [pop] %c]}         tcl  ;# char -> int
  v0_: int2char   {push [format %c [pop]]}       tcl  ;# int -> char

  #--------------------------------------------------------------

  v0_: and     {2op &&}                       tcl
  v0_: at      1 - swap {push [lindex [pop] [pop]]} tcl

  v0_: c       {set ::joy_ST {}}              tcl ;# clear stack
  v0_: choice  {choice [pop] [pop] [pop]}     tcl
  v0_: cleave  {cleave [pop] [pop] [pop]}     tcl
  v0_: cons    {push [linsert [pop] 0 [pop]]} tcl

  v0_: dup     {push [set x [pop]] $x}        tcl

  v0_: dupd    {push [lindex $::joy_ST end-1]}    tcl
  v0_: emit    {pn [format %c [pop]]}         tcl

  v0_: explode {push [split [pop] ""]}        tcl ;# string -> char list
  v0_: implode {push [ join [pop] ""]}        tcl ;# char list -> string

  v0_: first   {push [lindex [pop] 0]}        tcl
  v0_: fold    {rfold [pop] [pop] [pop]}      tcl

  v0_: ifte    {rifte [pop] [pop] [pop]}      tcl

  v0_: in      {push [lsearch [pop] [pop]]}   tcl 0 >=

  v0_: map     {rmap [pop] [pop]}             tcl ;# напрямую выпоняет команд

  v0_: max     {push [max [pop] [pop]]}       tcl
  v0_: min     {push [min [pop] [pop]]}       tcl
  v0_: not     {1f !}                         tcl
  v0_: or      {2op ||}                       tcl

  #--------------------------------------------------------------
  # от скобочек освобождаем, когда засовываем в стек
  #  именно в угоду команде tcl ?

  #v0_: pop     (pop)                          tcl
  #v0_: pop     ~pop                          tcl

  v0_: pop     {quote pop}                    tcl
  #?????????????????????????

  #--------------------------------------------------------------

  v0_: primrec {primrec [pop] [pop] [pop]}    tcl

#   v0_: qsort   {push [lsort [pop]}            tcl
# #  v0_: qsort   (lsort)                       tcl
#   v0_: qsort1  {lsort -index 0}               tcl

  #--------------------------------------------------------------

  v0_: rem     {2op %}                        tcl
  v0_: rest    {push [lrange [pop] 1 end]}    tcl

  #--------------------------------------------------------------

  v0_: set     {set ::[pop] [pop]}            tcl
  v0_: $       {push [set ::[pop]]}           tcl

#   v0_: set     {set [pop] [pop]}            tcl
#   v0_: $       {push [set [pop]]}           tcl

  #--------------------------------------------------------------

  v0_: size    {push [llength [pop]]}         tcl
  v0_: split   {rsplit [pop] [pop]}           tcl

  v0_: step    {step [pop] [pop]}             tcl
  v0_: swap    {push [pop] [pop]}             tcl

  #--------------------------------------------------------------
  
  #v0_: gcd     swap {0 >} {swap dupd rem swap gcd} (pop) ifte
  #v0_: gcd     swap {0 >} {swap dupd rem swap gcd} ~pop ifte
  #v0_: gcd     swap {0 >} {swap dupd rem swap gcd} {nop pop} ifte

  v0_: even    odd not
  #v0_: fact  1 (*) primrec 
  v0_: fact  1 {nop *} primrec 

  v0_: filter  split swap pop
  v0_: has  swap in
  v0_: newstack  c
  v0_: odd  2 rem
  v0_: of  swap at
  v0_: pred 1 -

  #v0_: product 1 (*) fold
  v0_: product 1 {nop *} fold

  #v0_: reverse {} swap (swons) step
  v0_: reverse  {} swap {nop swons} step

  v0_: sign  {0 >}  {0 <} cleave -
  v0_: succ  1 +

  #v0_: sum   0 (+) fold
  v0_: sum   0 ~+ fold
  #v0_: sum   0 '+ fold

  v0_: swons  swap cons
  v0_: xor  !=

  #--------------------------------------------------------------  
  # TODO: выделить самые простые операции, через которые можно 
  # определить остальные!
  #--------------------------------------------------------------

  # еще свои добавим:
  # 

  v0_: ^          {puts "    = [pop]"} tcl ;# надо ли здесь так хитро?

  v0_: nop    {} tcl    ;# пустышка  !!!!! 
  #v0_: quote      ;# пустышка, но ведь уже определена?
  
  v0_: old_concat {push [concat [pop] [pop]]} tcl ;# наоборот
  

  return
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc v1_init {} {


  joy_init ;# самая начальная инициация


  #-----------------------------------------------------------------------------
  #
  proc push args {
    
    # последовательно все аргументы помещаем в стек:
    # 
    # а если аргументы сами представляют списки?
    # если это список, то он добавится как список tcl, а нужно поэелментно! 
    # 
    
    foreach a $args {lappend ::joy_ST  $a}
    
    return
  }
  #-----------------------------------------------------------------------------
  # извлечь из стека (куда? в человечью программу !)
  #-----------------------------------------------------------------------------
  #
  proc pop {} {
    
    # хитрый приемчик, чтобы быстро "вытащить" последний (верхний) элемент
    # стека:
    # возьмем элемент из списка, а сам список "укоротим"
    # 
    
    set element [ K [lindex $::joy_ST end] [set ::joy_ST [lrange $::joy_ST 0 end-1]] ]
    
    # после этого процедура "pop" "возвращает" этот последний элемент;
    # пока не понятно как можно это организовать на нижнем физическом
    # уровне? т.е. как перейти от тьюринговой машины?
    
    return $element
  }
  #-----------------------------------------------------------------------------

  v0_set_stack_null  ;# #set ::joy_ST {}  ;# зануляем стек 

 
  return
}
#-------------------------------------------------------------------------------
proc v1_init_all {} {


  v1_init

  v1_init_all_operators ;# инициализируем основные процедуры (команды)


  # определяем как встроенную функцию 
  # 
  v0_: "concat" {
    #v0_needlen 2

    set l2 [pop]
    set l1 [pop]

    push [concat $l1 $l2] 
  } tcl

 
  return
}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc TEST_list {} {

  puts ""
  puts "TEST_list ..."
  puts ""
  
  #------------------------------------------
  v1_init_all 

  #------------------------------------------
  puts ""

  v0_set_stack_null

  r  c  {1 {2 3}}  dup .s 

  #------------------------------------------
  puts ""

  v0_set_stack_null

  set src_1 {   {1 {2 3}}  dup }

  run_v1_src   $src_1 

  r  .s 
  #------------------------------------------

  return
}
#-------------------------------------------------------------------------------
proc TEST_more {} {

  puts ""
  puts "TEST_more ..."
  puts ""
  
  v1_init_all  
  
  #set ::NEWFORMAT  1


  # нужно научиться выполнять простые операции со списками
  # 

  r   {1 2} ^
  r  {1 2 3}  {4 5 6 7}  old_concat ^

  puts ""
  v0_set_stack_null

  r    {1 2 3}  {4 5 6 7}  concat ^

  # а теперь надо задать функцию в терминах самого языка JOY,
  # как было сделано во 2-й версии:
  #
  #joy-eval    $ctx {
  #    DEFINE ccc == concat ; cc2 == concat.
  #    [2 3] [4 5] ccc ^
  #    [2 3] [8 9] cc2 ^
  #}

  #: ccc {concat} ;# почему здесь в скобочках, а дальше нет?
  v0_: ccc   concat  ;# просто потуму-что оин не играют роли!

  r   {1 2 3} {4 5 6 7}  ccc ^

  puts ""

  v0_:_prg kvadrat {dup *}

  r c  3 kvadrat ^

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_simp {} {

#   puts ""
#   puts "........ TEST_simp ... "
  puts ""
  
  #set ::NEWFORMAT 1

  v1_init_all  
 
  r  1 2 + ^ 
  r  2 3 + ^ 
  r  2 3 * ^ 

  #r .s ;# напечатаем стек, там нет ничего?
  puts ""

  v1_init_all  
 
  r  3 2 1 ^ 
  r        ^ 
  r        ^ 

  puts "" ;# -------------------------------------------------

  r c  {1 2}    .s 
  r c  {1 2}  i .s

  puts "" ;# -------------------------------------------------


  r c   ~3    .s  ;# т.е. в стеке уже не квотированный
  r c   ~3  i .s


  puts ""
  puts "----------------------------------"
  puts ""

  r c {2 3 +} i .s  ;# раскрывает скобки и выполняет

  r c nop 2 3 + ^ 

  puts ""
  puts "----------------------------------"
  puts ""

  #r c {   1 2   }      .s 
  #r c {   1 2   }  dup .s 

  r c    {nop 3}        .s
  r c    {nop 3 nop} i  .s  ;# такие универсальные скобки

  # (* склеиваем две строки *)
  # [1 2 3]  [4 5 6 7]  concat .

  #joy-eval  { [1 2 3]  [4 5 6 7]  concat .}  

  puts ""
  puts "----------------------------------"
  puts ""

  r c  {1 2 3}  {4 5 6 7}  . .         ;# завели и вывели наружу на печать два элемента
  r c  {1 2 3}  {4 5 6 7}  concat .    ;# завели, соединили и вывели на печать
  r c  {1 2 3}  {4 5 6 7}  concat .s   ;# просто печвтвем стек 

  puts ""

  r c  {6 1 5 2 4 3} {3 >} filter . ;# {6 5 4}

  r c  {6 1 5 2 4 3} {3 >} split . 

  return
}
#-------------------------------------------------------------------------------
proc selftesting {} {

  
  ? {r 2 3 +}      5
  ? {r 2 *}       10
  ? {r c 5 dup *} 25

  v0_: sqr dup *
  v0_: hypot sqr swap sqr + sqrt
  ? {r c 3 4 hypot}            5.0        ;# считаем гипотенузу по катетам

  ? {r c {1 2 3} {dup *} map}  {{1 4 9}}
  ? {r size}                   3

  #? {r c {2 5 3} 0 (+) fold}                       10
  ? {r c {2 5 3} 0 ~+ fold}                       10
  #? {r c {2 5 3} 0  '+ fold}                       10
  #? {r c {2 5 3} 0 [+] fold}                       10

  ? {r c {3 4 5} product}                          60
  ? {r c {2 5 3} 0 {dup * +} fold}                 38
  ? {r c {1 2 3 4} dup sum swap size double /}    2.5

  #? {r c {1 2 3 4} [to_quote sum] {size double} cleave /} 2.5
  ? {r c {1 2 3 4} {sum nop}      {size double} cleave /} 2.5
  ? {r c {1 2 3 4} ~sum           {size double} cleave /} 2.5
  ? {r c {1 2 3 4} {nop sum}      {size double} cleave /} 2.5

  v0_: if0 {1000 >} {2 /} {3 *} ifte
  ? {r c  1200 if0}                     600
  ? {r c   600 if0}                    1800

  ? {r c   42 sign}                       1
  ? {r c    0 sign}                       0
  ? {r c  -42 sign}                      -1
  ? {r c    5 fact}                       120

  ? {r c  1 0 and}                        0
  ? {r c  1 0  or}                        1
  ? {r c  1 0 and not}                    1

  ? {r c  3 {2 1}  cons}          {{3 2 1}}
  ? {r c  {2 1} 3 swons}          {{3 2 1}}
  ? {r c  {1 2 3} first}          1
  ? {r c  {1 2 3}  rest}          {{2 3}}

  #? {r c  {1 2 3 4} [to_quote odd]  split}      {{2 4} {1 3}}
  ? {r c  {1 2 3 4} {odd      nop}  split}      {{2 4} {1 3}}
  ? {r c  {1 2 3 4} {nop      odd}  split}      {{2 4} {1 3}}

  ? {r c  {6 1 5 2 4 3} {3 >} filter} {{6 5 4}}

  ? {r c  1 2 {+ 20 * 10 4 -} i}      {60 6}
  ? {r c  42 succ}                    43
  ? {r c  42 pred}                    41
  ? {r c  {a b c d} 2 at}              b
  ? {r c  2 {a b c d} of}              b
  ? {r c  1 2 pop}                     1

  #---------------------------------------------------
  # что за хрень?? ' `
  # 
  #? {r c  A ' 32 + succ succ `}        c
  ? {r c  A char2int 32 + succ succ int2char}        c
  #---------------------------------------------------

  ? {r c  {a b c d} reverse}          {{d c b a}}

  ? {r c  1 2 dupd}                   {1 2 1}
  #? {r c  6 9  gcd}                   3
  ? {r c  true  yes no choice}        yes
  ? {r c  false yes no choice}        no

  ? {r c  a {a b c}  in}    1
  ? {r c  d {a b c}  in}    0
  ? {r c  {a b c} b has}    1
  ? {r c  {a b c} e has}    0
  ? {r c  3 4 max}          4
  ? {r c  3 4 min}          3

  ? {r c  hello explode reverse implode} olleh

  v0_: palindrome   dup explode reverse implode =
  ? {r c  hello palindrome}  0
  ? {r c  otto  palindrome}  1
  
  #----------------------------------------------------------------
  #-- reading (varname $) and setting (varname set) global Tcl vars

  set ::tv 42
  
  #? {r c (::tv) $ 1 + dup (::tv) set} 43  - можно и без квотирования 
  ? {r c  ::tv  $ 1 + dup  ::tv  set} 43 
  
  ? {expr $::tv==43} 1
  
}
#-------------------------------------------------------------------------------
proc TEST_2005 {} {

  v1_init_all       ;# начальная инициализация

  #set ::NEWFORMAT  1

  selftesting  ;# самотестирование
  
  puts "" 

  #d+           ;# включим  отладчик 
  r c 2 3 +  .s
  #d-           ;# выключим отладчик 

  puts ""

  r c {1 2 3 4} {nop odd} split   .s ;# ?   {{2 4} {1 3}}
  r c {1 2 3 4} ~odd      split   .s   
  
  puts ""

  r c  A char2int 32 +           int2char  .s
  r c  A char2int 32 + succ succ int2char  .s

 # puts ""
  
}
#-------------------------------------------------------------------------------
proc TEST_test {} {


  #set ::NEWFORMAT  1

  puts ""

  v1_init_all 
 
  r c  {a b c d} reverse  . ;#  {{d c b a}}

  r c  {}  {2 8 3 6 5}  ~swons  step  .

  puts ""



  #----------------------------------------------------------------
  #-- reading (varname $) and setting (varname set) global Tcl vars

  set ::tv 42
  
  ? {r c  ::tv   $  1 + dup  ::tt set} 43 
  
  #? {r c  ::tv get  1 + dup  ::tt set} 43 
  
  ? {expr $::tt == 43} 1

  #----------------------------------------------------------------

  #v0_: explode {push [split [pop] ""]}        tcl  ;# string -> char list
  #v0_: implode {push [ join [pop] ""]}        tcl ;# char list -> string

  #r c  "John Smith"  {'Z char2int >}  filter .
  #r c  "John Smith"  {90 >} filter .

  #v0_: string_filter  explode filter implode
  #v0_: filter  split swap pop
  #v0_: string_filter  explode swap pop implode

  #r c  "John Smith"  explode .
  #v0_: split   {rsplit [pop] [pop]}           tcl

  r c  {6 1 5 2 4 3} {3 >} split . . 

  puts ""

  #r c  "615243" explode {3 >} split  implode swap implode swap . .
  #r c  "615243" {3 >}  swap explode swap split  implode swap implode swap . .

  v0_: string_split  swap explode swap split  implode swap implode swap 

  r c  "615243" {3 >}  string_split . .

  puts ""

  # разделяем и левый выбрасываем из стека
  #
  v0_: string_filter  string_split swap pop

  #r c  "John Smith"  {90 >}  string_filter .

  r c  "615243"      { 3 >}  string_filter .

  r c  "John Smith"  {90 >}  string_split . .

  #r c  "John Smith"  {90 >}  string_filter .

  #----------------------------------------------------------------

  #puts ""

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_sort {} {

  puts ""
  puts "TEST_sort ..."
  puts ""
  
  v1_init_all  
  
  #-------------------------------------------------
  # определим еще функции

  v0_: list_inp {5 4 3 2 1}

  #  v0_: qsort   (lsort)                     tcl
  #  v0_: qsort1  {lsort -index 0}            tcl

  v0_: tclsort  {push [lsort [pop]]}  tcl

  #-------------------------------------------------

  #DebugOn

  r c  {5 4 3 2 1} tclsort  .s
  r c  list_inp    tclsort  .s

}
#-------------------------------------------------------------------------------
proc TEST_vars {} {

  puts ""
  puts "TEST_vars ..."
  puts ""
  
  v1_init_all 
  
  #-------------------------------------------------

  set ::tv 42
  
  puts "tv = $::tv"

  r c  ~tv $ 1 + dup ~::tv set  ;# 43
  
  puts "tv = $::tv"

  r c   tv $ 1 + dup  tv set   ;# 44 -  т.е. можно и без скобок вполне,
                                  # главное чтобы под эти именем для переменной
                                  # не оказалось команды?  
  puts "tv = $::tv"

  # не очень понял, зачем я дублирую dup ?? лишнее

  r c   tv $  1 +   ::tv set

  puts "tv = $::tv"


  #-------------------------------------

  puts ""
  puts "-------------------------------"
  puts ""

  r c  10 20  =bb =aa  @bb .

  puts "::aa = $::aa"
  puts "::bb = $::bb"


}
#-------------------------------------------------------------------------------
proc TEST_solv_qroots_old {} {

  # :: solveq ( a b c -- x )
  #   b neg
  #   b b * 4 a c * * - sqrt
  #   +
  #   2 a * / ;
  
  # проверим пошагово
  # 

  r c  1 0 -1   ~c set ~b set ~a set  

  puts "::a = $::a"
  puts "::b = $::b"
  puts "::c = $::c"

  r c  ~b $  neg                                .s  
  r    ~b $  ~b $  *  4 ~a $ ~c $  * * -  sqrt  .s 
  r    + .s 
  r    2 ~a $  * / .s 

}
#-------------------------------------------------------------------------------
proc TEST_solv {} {

  puts ""
  puts "TEST_solv ..."
  puts ""
  
  v1_init_all  
  
  #set ::NEWFORMAT 1

  TEST_vars 

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  # но это все были предварительные тесты по пере
  # менным.
  # дальше тесты на решение квадратного уровнения

  v0_: neg   {push [expr - [pop]]} tcl

  TEST_solv_qroots_old

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  v0_: solveq   =c =b =a        \
    @b  neg                     \
    @b @b  * 4 @a @c * * - sqrt \
    +                           \
    2 @a * /
  
  r c  2 -16 30 solveq  .s   ;# 2x^2 -16x + 30 = 0 ; D=4, x= (16 +- 4)/4. x1= 3, x2= 5
  r c  1   0 -4 solveq  .s   ;# x^2   +0x -  4 = 0                        x1=-2, x2=+2


# мз файла numlib.joy

#     (* find roots of the quadratic equation with coefficients a b c :
# 				  a * X^2  +  b * X   +  c  =  0	*)
#     qroots ==					(*  a  b  c		*)
# 	[	pop pop null ]			(* a = 0 ?		*)
# 						(* degenerate cases:	*)
# 	[	[   pop null ]			(* b = 0 ?		*)
# 		[   [ null   ]			(* c = 0 ?		*)
# 		    [ [_INF] ]			(* =>  [_INF]		*)
# 		    [ [] ]			(* =>  []		*)
# 		    ifte
# 		    [ pop pop pop ] dip ]
# 		[   0 swap - swap 1.0 * /	(* float divisor	*)
# 		    [] cons popd ]		(* =>  [ -c/b ]		*)
# 		ifte ]
# 						(* standard cases:	*)
# 	[	[   [ dup * swap ] dip
# 		      4 * * - ] unary		(* b^2 - 4ac		*)
# 		[   0 < ]			(* b^2 - 4ac negative ?	*)
# 		[   pop pop pop [_COMPLEX] ]	(* =>  [_COMPLEX]	*)
# 		[   [ 0 swap - 1.0 *		(* -b  (floated)	*)
# 		      swap 2 * ] dip		(* 2a			*)
# 		    [ 0 = ]			(* b^2 - 4ac zero ?	*)
# 		    [ pop / [] cons ]		(* =>  [-b / 2a]	*)
# 		    [ sqrt swapd dup2 - [+] dip	(*   -b+s      -b-s     *)
# 			[] cons cons 		(* [ -b+s      -b-s    ]*)
# 		      swap [/] cons map ]   (* =>  [(-b+s)/2a (-b-s)/2a]*)
# 		    ifte ]
# 		ifte ]
# 	ifte;

# если попробовать упростить

# 	 	   [[ dup * swap ] dip
# 		      4 * * - ] unary		(* b^2 - 4ac		*)
#                   [ 0 swap - 1.0 *		(* -b  (floated)	*)
# 		      swap 2 * ] dip		(* 2a			*)
# 		    [ sqrt swapd dup2 - [+] dip	(*   -b+s      -b-s     *)
# 			[] cons cons 		(* [ -b+s      -b-s    ]*)
# 		      swap [/] cons map ]   (* =>  [(-b+s)/2a (-b-s)/2a]*)
# 		    ifte 

# как же сделать два значения?

  #puts ""
  #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  #puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_test_NEW {} {

  puts ""
  puts "TEST_test_NEW ..."
  puts ""
  
  v1_init_all  

  v0_: neg   0 swap - 1.0 *

  v0_: dip  {
    set l    [pop ]
    set item [pop ]
    lappend code $l i $item
    
    eval r   $code
  }  tcl  

  v0_: dupd   ~dup  dip       ;# A B   -> A A B
  v0_: swapd  ~swap dip       ;# A B C -> B A C
  v0_: dup2    dupd dup swapd ;# A B   -> A B A B 


  #r c  .s 
  r c  1 2   ~+ i    .s 
  r c  1 2 9 ~+ dip  .s 

# pop2     == pop pop;
# popd     == [pop ] dip;
# rollup   == swap [swap] dip;
# rolldown == [swap] dip swap;
# rotate   == swap [swap] dip swap;

  r c  6 2  dup2 - ~+ dip  .s ;# все верно -> 8 4, сначала дублируем пару, выполняем
  #                             операцию - и затем + с двумя элементами ниже

  puts ""

  r c    A B  dupd  .s ;# -> A A B
  r           dup   .s ;# -> A A B B
  r           swapd .s ;# -> A B A B - дублируем сразу пару
  
  puts ""

  r c  6 2  dup2 - ~+ dip  .s 
  r    cons {2 /} map .s 

  puts ""

  r c   10.2 {2 1 * /} map .s ;# можно мапировать и одиночный итем

  puts ""


  v0_: solveq_NEW   =c =b =a    \
    @b  neg                     \
    @b @b  * 4 @a @c * * - sqrt \
    dup2 - ~+ dip               \
    cons                        \
    {2 @a * /} map 
  
  r c  2 -16 30 solveq_NEW  .s   ;# 2x^2 -16x + 30 = 0 ; D=4, x= (16 +- 4)/4. x1= 5, x2= 3
  r c  1   0 -4 solveq_NEW  .s   ;# x^2   +0x -  4 = 0                        x1=+2, x2=-2

  puts ""
  puts "-----------------------------------"
  puts ""

  #  The following binary operators are defined on all stacks containing at least two 
  #   elements:

  #         swap    popd    popop    dupd
  
  #  The swap operator interchanges the top two elements. The popd operator removes 
  #  the second element. The popop operator removes the first and the second element. 
  #  The dupd operator duplicates the second element.
  
  #  The following ternary operators are defined for all stacks containing at least 
  #  three elements:
  
  #         swapd    rollup    rolldown
  
  #  The swapd operator interchanges the second and third elements but leaves the 
  #  first element in place. The rollup operator moves the third and second element 
  #  into second and third position and moves the first element into third position. 
  #  The rolldown operator moves the second and first element into third and second 
  #  position and moves the third element into first position.
  

  v0_: while  {

    set do_part    [pop ]
    set while_part [pop ]

    puts "stack = $::joy_ST"

    while {1} {
    
      eval r  $do_part
      puts "stack = $::joy_ST"

      eval r  dup  ;# продублировали верхний элемент, чтобы использовать его в сравнении

      eval r  $while_part
      puts "stack = $::joy_ST"
 
      set ret [pop]  ;# забрали результат сравнения
      #puts "ret = $ret, stack = $::joy_ST"

      if {$ret == 0} {
        break
      } 
    }
    
  }  tcl  

  #v0_: while  =D =B  @B @D @B @D ~while cons cons concat [] ifte

  #r c  10 {> 0} {1 - } while  .s  
  r c  10 {0 > } {1 - } while  .s  

  #  в оригинальном файле numlib.joy tcnm jghtltktybt 
  #
  #  gcd == [0 >] [dup rollup rem] while pop;

  #  The next program computes the greatest common divisor of two numbers, using 
  #  Euclid's algorithm. The algorithm uses two numbers and repeatedly takes the 
  #  remainder after dividing one by the other. The remainder obtained is then used 
  #  to replace the dividend. The process is repeated as long as the potential 
  #  divisor is positive. So, unlike the previous programs, we cannot use the times
  #   combinator. Instead a combinator called while is used which resembles 
  #  while-loops in imperative languages. It takes two parameters: the while-part 
  #  is a quoted program which must return a truth value, and the do-part is a 
  #  quoted program which can compute anything. The while-part in the following gcd 
  #  program is of course very similar to a corresponding part in the fib program.
  
  v0_:   gcd   {0 >} {dup ~rem dip swap} while pop

  # понять что за алгоритм
  # 

  puts ""

  r c  12 8  gcd  .s  ;# это верно ! !


}  
#-------------------------------------------------------------------------------
# 
# 
#-------------------------------------------------------------------------------
proc joy->v2-list data {

  set data_string [joy-tokenize-no-comments [string range $data 1 end-1]]
  set len [llength $data_string]

  #puts "data_string = $data_string"
  #puts "len = $len"

  if {$len == 1} {return ~$data_string}

  set ret {}
  
  foreach t $data_string {

    lappend ret   [convert_joy_to_11 $t]
  }

  return $ret
}
#-------------------------------------------------------------------------------
# Convert a Joy literal to the 11 representation 
#-------------------------------------------------------------------------------
proc convert_joy_to_11 data { 

  set tt [joy-token-type $data]

  #puts "tt = $tt  data = $data"

  #joy->v3-$tt $data

  switch -- $tt {

    "list" {
      return [joy->v2-list $data]
    }

    "char" {
      #return [format "'%c" $data]
      return [scan [string index $data 1] %c]
    }

    default {
      return $data
    }
  }

  #return $data
}
#-------------------------------------------------------------------------------
proc joy_functext_to_v1_code {functext} {

  # functext - это простой исходник Joy в чистом виде, без определений !
  # 

  set code {} ;# сюда будем складывать код в формате v3 : (тип данные).
    
  foreach t $functext { 
         
    set tt [joy-token-type $t]
    
    if {$tt eq {comment}} continue
    

    set 11_code [convert_joy_to_11 $t]

    #if {$tt == "list"} {
    #  puts "!!!!!!!!!!!!!!!!!!!!!!!!!"
    #}

    #puts "11_code = $11_code"

    lappend code  $11_code ;# без всяких типов

  }

  #puts ""

  return $code
}
#-------------------------------------------------------------------------------
# TEST_convert_joy_to_11
#-------------------------------------------------------------------------------
proc TEST_00_to_11 {} {
  

  set text_1 {

    (* this is comment 
    'a [quoted] [2 1 +] i . *) 

    2 3 + .  
    2 3 + dup * .

    [1 2 3]  [4 5 6 7]  concat .

    (* применяем некую функцию к массиву, здесь возведение в квадрат  *)
    [1 2 3 4]  [dup *]  map .
  
    (* i - выполняет верхний итем на стеке: результатом будут в стеке "100 6"   *)
    2 3  [ + 20 * 10 4 - ]  i . .

    (* применяем фильтр к строке: убираем заглавные буквы и пробелы ? *)
    "John Smith"  ['Z >]  string_filter .

  }

  set text_2 {

    [2 5 3]  0  [+]  fold .
    [2 5 3]  0  [dup * +]  fold .  

    4  [null] [succ] [dup pred] [*] linrec  . 

    (* вычислим факториал для каждого элемента списка [1 2 3 4] *)
    [1 2 3 4]  [ [null]  [succ]  [dup pred]  [*]  linrec ]   map .
  }

  #-------------------------------------------------------------

  # 	linrec == (P T R1 R2)
  # 	    $P $T
  # 		    $R1
  # 		    $P $T $R1 $R2 [] cons cons cons cons
  # 		    [linrec] $R2 concat concat concat
  # 		    ifte;
  
  # i_main i__01.joy

  #-------------------------------------------------------------


  puts ""
  puts "text_1 = $text_1"
  puts ""

  # скомпилируем исходный текст в выходной формат
  #
  set ::print_defines 1

  set joy_functext_to_proc "joy_functext_to_v1_code" 

  set ndict [joy-compile_to_namecodedict \
                $text_1 \
                $joy_functext_to_proc]

  puts ""
  puts "ndict = $ndict"
  puts ""

  v1_init_all       ;# разные ништяки

  #v0_set_stack_null 
  
  v0_: string_split   swap explode swap split  implode swap implode swap 
  v0_: string_filter  string_split swap pop


  set v1_src [dict get $ndict {}]

  run_v1_src  $v1_src 

}
#-------------------------------------------------------------------------------
proc run_joy_file_v1 {fname} {


  # не будем включать include на стадии препроцессинга
  # 
  set r_text_all [read_file_to_rtext   $fname]
  
  set ndict [joy-compile_to_namecodedict \
                $r_text_all \
                "joy_functext_to_v1_code"]

  puts "ndict:  $ndict"
  puts ""


  v1_init_all       ;# разные ништяки

  set v1_src [dict get $ndict {}]

  run_v1_src  $v1_src 

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_v1 {} {


  puts ""

  run_joy_file_v1 "F/j__00.joy"

  puts ""
  puts "----------------------------------------------"
  puts ""

  run_joy_file_v1 "F/j__01.joy"

#   puts ""
#   puts "----------------------------------------------"
#   puts ""

#   run_joy_file_v1 "F/j__02.joy"

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
  # может слишком усложнена иерархия, не нужно для процедур src ?????????
  # а может нужны все же ссылки на тексты? или ссылки на подпрограммы ???

#-------------------------------------------------------------------------------
proc run_v1_prog {prog} {


  if [is_GLOBAL_DICT $prog]  { 

    # это была ссылка на словарь

    set prog [set $prog] ;# сам словарь

  } 

  # получим  "исходник" главной программы
  # 
  set src [prog_get_prg_src $prog "main"]


  biblio_push $prog ;# запихнуть "локальную библиотеку" в стек библиотек
                       # (в данном случае - это сама программа)

  run_v1_src $src     ;# выполнить исходник

  biblio_pop        ;# убрать библиотеку из стека  

  return 
}
#-------------------------------------------------------------------------------
proc calc_len_prog {prog} {

  if [is_GLOBAL_DICT $prog]  { 
    set prog [set $prog] ;# сам словарь
  } 

  set src [prog_get_prg_src $prog "main"]

  set len [llength $src] ;# ?? 

  return $len
}
#-------------------------------------------------------------------------------
# proga - обобщенное название программы, там могут быть разные варианты (типы) 
#
#-------------------------------------------------------------------------------
#proc run_v1_src_or_prog {src prog} {}
# proc run_v1_src_or_prog {proga} {

#   # для переходного периода лучше просто смотреть тип, словарь это или список !
#   # но, JOY-программа тоже может быть похожа на словарь, если есть скобки !!
#   #
#   # поэтому просто ищем в словаре "main" 


#   #if [is_GLOBAL_DICT $proga]  { 

#     # это ссылка на словарь

#    # set prog [set $prog] ;# сам словарь
#   #}

#   #set prog @
#   #set src  $src_or_prog
#   #set src  $proga

#   run_v1_prog $proga
#   return


#   if {1} {

#     run_v1_src   $proga 
#     #run_v1_src   $src 
#   } else {

#     run_v1_prog  $prog
#   }

#   return
# }
#-------------------------------------------------------------------------------
proc TEST_dict_NEW {} {

  v1_init_all       ;# начальная инициализация


  # TODO^ все дело в операторе nop !! он - пустышка !!!!
  # 
  #? {r c  {1 2 3 4} {nop      odd}  split}      {{2 4} {1 3}}

  #------------------------------------------------

  puts ""

  set src1 {3 kvadrat ^}

  set src2 {dup *}

  puts "src1 = $src1"
  puts "src2 = $src2"

  puts ""
  puts "-------------------------------------------"
  puts ""

  #set prog [list "main" [list "src" $src1] "kvadrat" [list "src" {dup *}] ]
  #set prog [list "main" [list "src" $src1] "kvadrat" [list "src" $src2] ]
  set prog [list \
              "main"    [list "src" [list_create {*}$src1]] \
              "kvadrat" [list "src" [list_create  dup *] ]  ]

  puts "prog = $prog"
  puts ""

  dict_print $prog 
                   

  puts ""
  puts "-------------------------------------------"
  puts ""

  # всё таки это лишнее, через указатели на списки делать?
  # пока попробуем обойтис!

  set prog [list \
             "main"    [list "src"  $src1] \
             "kvadrat" [list "src"  {dup *}] \
             ]

  puts "prog = $prog"
  puts ""

  dict_print $prog 
                   
  #dict print $prog
  #dict print [set $prog]

  # TODO:
  #
  # но первая прога печатается "правильно" как список ? а, там нечетно!
  # и она думает, что это не словарь !!!
  #
  # просто надо печать ограничить нужным уровнем!

  puts ""
  puts "-------------------------------------------"
  puts ""

  #return

  run_v1_prog  $prog ;# а вот здесь чего? нужна девятка !!!!


  # и теперь просто попрограмме-списку
  # 

  run_v1_src  {{1 {2 3}}  dup}

  r  .s ;# посмотреть стек

  puts ""
  puts "-------------------------------------------"
  puts ""

  # TODO запихнуть сначала  в общую библиотеку библ.функцию
  # 

  set bibl [list \
             "kvadrat" [list "src"  {dup *}] \
             ]

  set prog [list \
             "main"    [list "src"  $src1] \
             ]


  biblio_push $bibl ;# запихнуть в глобальную библиотеку 

  # ::BIBLIO - но работаем с ним как со стеком

  run_v1_prog  $prog 

  return

}
#-------------------------------------------------------------------------------
proc TEST_dict_VER {} {

  # тестируем систему выполнения команд с некоторой вероятностью
  # 

  global argc argv argv0

  set seed  [dict_parse $argv "-seed"  @] ;# каждый вызов случаен

  comm_random_seed_null $seed ;# случайно 


  v1_init_all       ;# начальная инициализация

  puts ""

  set cmd1 [dict_create  "cmd" 1 "ver" 0.5] ;# команда с заданной вероятностью исполнения
  set cmd2 [dict_create  "cmd" 2 "ver" 0.5]
  set cmd3 [dict_create  "cmd" 3 "ver" 0.5]

  puts ""

  #set ::R_ONE_CMD 1
  run_v1_src "$cmd1 $cmd2 $cmd3"

  #puts ""
  r  .s ;# посмотреть стек

  #set ver [GET $cmd1 "ver"]
  #puts "ver = $ver"

  #if {$ver == {}} {
  #  set ver 1.0
  #  puts "1...."
  #} 

  #puts "ver = $ver"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
# Архитектупа описания программ: 
# 
# 1) prog = libr : программа - это библиотека в которой есть прога (prg) "main"
# 
# 2) прога "prg" состоит из исходников "src" и дополнительных полей.
# 
# 3) для проги "main" должно быть поле "fitness"
# 
# 
#-------------------------------------------------------------------------------
# 
# TODO:

# + надо всё пеередлать на указатели словарей и списков!

# - run_v1_src  -> run_v1_prog

# j~.tl 1111 TEST_dict_NEW

#-----------------------------------------------

# j~.tl 1111 TEST_file_v1

# j~.tl 1111 TEST_convert_joy_to_11

# j~.tl 1111 TEST_test
#  
# j~.tl MORE TEST_sort
# j~.tl MORE TEST_solv
# 

#-------------------------------------------------------------------------------
proc TEST_1111 {} {


  puts ""
  puts "TEST_1111 ... "
  puts ""


  v0_make_tclproc  proctest1 {} {
    puts "proctest1 .. !!"
  }

  v0_make_tclproc  proctest2 {} {   
    puts "proctest2 .. !!" 
  }


  #v1_init_all  
  v1_init


  v0_: progtest1       {puts "progtest1 .. ??"} tcl
  #v0_:_prg progtest11 {{puts "progtest1 .. ??"} tcl}
  #v0_: .       {puts "[pop] "}                 tcl


  puts ""
  puts "::BIBLIO = $::BIBLIO"
  puts ""
  puts "::joy_proglist = $::joy_proglist"
  puts ""
  puts "::joy_tcl_list = $::joy_tcl_list"
  puts ""

  run_v1_src  {proctest1 proctest2}

  #r c    .s 
  #r c  3 ^
  biblio_print

  set ::error_print1 1
  set ::error_print2 1
  set ::error_print3 1

  run_v1_src  {progtest1}

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# f~.tl 1111 TEST_1111

################################################################################

