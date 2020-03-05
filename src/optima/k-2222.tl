# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

################################################################################
# 
#   В И Р Т У А Л Ь Н А Я   М А Ш И Н А (типа Joy)
# 
#   JOYS - Joy Simple (простой вариант без типов !!!!)
# 
################################################################################
  

#namespace import ::struct::*
# record define JOY_CTX_T {

#   ch_form    ;# "% 6.3f" ;#  " %02d"
# }

#--------------------------------------------------

set ::BEG "BEG"
set ::END "END"

set ::is_mode_list 0 ;# флаг-счетчик списков BEG-END


#-------------------------------------------------------------------------------
proc set_BEG_END {beg end} {

  set ::BEG  $beg
  set ::END  $end

}
# ------------------------------------------------------------------------------
proc  read_BEG_END {list &i l} {

  USE_REFS

  set ret {}

  set count  99

  while {1} {

    if {$i == $l} { ;# не дождались завершающего END !!
      set ret -1    ;# надо бы как-то отметить ошибку ?
      break
    }

    set item [lindex $list $i]  ;# взяли элемент вх. списка

    lappend ret $item           ;# добавили к выходному списку

    if {$item == $::BEG} {
      incr count +1
    }

    if {$item == $::END} {
      incr count -1
      if {$count == 99}  {
        break
      }
    }

    incr i
  }


  return $ret
}
#-------------------------------------------------------------------------------
# Освобождение от граничных символов "списка". Прцедура нужна будет далее
# чтоб работать с этими "списками". Получается не очень красиво, поскольку вводится
# дополнительная к Tcl семантика языка!
#
#-------------------------------------------------------------------------------
proc erase_LIST {l} {
  
  dputs [format "erase_LIST:  l = %s " $l]


  # может одновременно условие должно выполнятся? 
  
  if {[lindex $l 0] == $::BEG  && [lindex $l end] == $::END} {

    set l [lreplace $l   0   0]  
    set l [lreplace $l end end] 
  }

  return $l 
}
# ------------------------------------------------------------------------------
# proc BE_erase {list} {


#   return [erase_LIST $list] ;# пока так !!

# }
# ------------------------------------------------------------------------------
proc 22_erase {&a} {

  USE_REFS

  set a [erase_LIST $a]

  return
}
# ------------------------------------------------------------------------------
proc  BE_foreach {item_NAME list script {is_only_length_calc 0}} {

  upvar $item_NAME item

  # TODO: сначала надо освободиться от крайних BEG_END !!!!!!!!!!!!!
  #       если они есть ??

  #set list [BE_erase $list]
  22_erase  list

  set length 0

  set l [llength $list]
  set i 0

  while {1} {

    if {$i == $l} break

    set item [lindex $list $i]
    
    if {$item == $::BEG} {

      set item [read_BEG_END  $list i $l]

      # а если "список" не корректный, т.е. нет закрывающей скобки?
      # 
      if {$item == -1} {

        if {$is_only_length_calc} {
          return -1
        } else {
          #ERROR "BE_foreach ............ !!!!!!!111"
          # просто выходим с тем, что есть 
          break
        }
      }

    }

    if {$is_only_length_calc} {
      incr length
    } else {
      uplevel 1 $script 
    }

    incr i
  }
 
  return $length
}
# ------------------------------------------------------------------------------
proc  BE_length {list} {

  set l_be [BE_foreach  a $list {} 1] ;# не выполняем скрипт, а только считаем 
                                       # длину

  return $l_be
}
# ------------------------------------------------------------------------------
proc  convert_22_to_11 {src_22  &src_11} {

  USE_REFS

  set src_11 {} ;# зададим пустышку вначале ??

  #   set len [BE_length $src_22]
  
  #   if {$len == -1} {
  #     #ERROR "convert_22_to_11"
  #     return ;# просто будет пустышка на выходе (хотя если ошибка в самом конце?
  #             # - лучше бы хоть что-то передавать ?)
  #   }


  BE_foreach a $src_22 {

    dputs "convert_22_to_11: a = $a"
    set l    [llength   $a]

    if {$l == 1} {

      lappend  src_11 $a ;# едиинчный элемент просто добавляем

    } else {
      
      # список сначала "распаковываем" в "обычный"
      22_erase a

      if {[llength $a] == 1} {

        set a "~$a"
        #set a "($a)"
        lappend  src_11 $a
        #lappend  src_11 "($a)"

      } else {

        set tmp {}
        convert_22_to_11 $a  tmp
        lappend  src_11   $tmp
      }

    }
  }

  return
}
# ------------------------------------------------------------------------------
proc  convert_11_to_22 {src_11  &src_22} {

  #set src_22 {}

  USE_REFS


  foreach a $src_11 {

    set l [llength $a]
    # 
    #puts "a = $a , llength = $l"

    set list_flag 0

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if {$l > 1} { 
      # т.е. это нормальный список

      set list_flag "1"
     
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    } else {
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #if { [check_ONELIST_mode  $a] } {}
      if {[string index $a 0] == "~"} {

        # т.е. это единичный "псевдосписок"

        set a [string trim $a ~] ;# очистили
        #11_erase a

        set list_flag 1
      }
    }
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if {$list_flag} {
      lappend  src_22 {*}"BEG "
      convert_11_to_22  $a  src_22 ;# очищенный единичный будет лишний раз
                                    # обрабатываться, ну да ладно
      lappend  src_22 {*}" END"
    } else {
      lappend  src_22 "$a"
    }

  }

  return ;#$src_22
}
#-------------------------------------------------------------------------------
proc TEST_convert_11_to_22 {} {

  puts ""
  puts ""

  set src_11  { M M M M   {L ~L R M  {L L}}  ~M }
  #set src_11 { M M M M   {L (L) R M  {L L}}  (M) }
  set src_22  {}

  puts "PRG_11 = $src_11"
  puts ""


  convert_11_to_22  $src_11 src_22


  puts "PRG_22 = $src_22"
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_convert_22_to_11 {} {

  puts ""
  puts ""

  set src_22 { M M M M   R  M M  L  M M    BEG nop END   BEG prog1 BEG prog2 END END }
  set src_11 {}

  puts "PRG_22 = $src_22"
  puts ""

  convert_22_to_11  $src_22 src_11


  #puts ""
  puts "PRG_11 = $src_11"
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_convert_22_to_11_err {} {

  puts ""
  puts ""

  set src_22 {i MOVE i BEG IF_FOOD_AHEAD IF_FOOD_AHEAD i RIGHT IF_FOOD_AHEAD IF_FOOD_AHEAD i IF_FOOD_AHEAD nop i i}
  set src_11 {}

  puts "PRG_22 = $src_22"
  puts ""

  convert_22_to_11  $src_22 src_11


  puts ""
  puts "PRG_11 = $src_11"
  puts ""

  return
}
################################################################################
# 
#   В М   и н с т р у к ц и и
# 
################################################################################
# 
# 
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc v2_init_all_operators {} {



  #-----------------------------------------------------------------------------
  # Combinator
  #-----------------------------------------------------------------------------
  v0_make_tclproc "i" {} {
    
    v0_needlen 1
    
    set prg [pop]
    
    #set prg [erase_LIST  $prg] ;# освобождаемся от скобок!
    22_erase  prg
    
    run_v2_src $prg ;# и выполняем 
  }
  #---------------------------------------
  v0_make_tclproc "peek" {} {
    v0_needlen 2
    
    push [lindex $::joy_ST end-1]
  }
  #-----------------------------------------------------------------------------
  #
  #
  #-----------------------------------------------------------------------------
  v0_make_tclproc "+" {} {
    v0_needlen 2
    
    push [expr {[pop]+[pop]}]
  }
  #---------------------------------------
  v0_make_tclproc "-" {} {
    v0_needlen 2
    
    push [expr {[pop]-[pop]}]
  }
  #---------------------------------------
  v0_make_tclproc "*" {} {
    v0_needlen 2
    
    push [expr {[pop]*[pop]}]
  }
  #---------------------------------------
  proc divmod op {
    v0_needlen 2
    
    set a [pop]
    set b [pop]
    if {!$b} {
      push $b
      push $a
      return
    }
    push [expr "$a $op $b"]
  }
  
  v0_make_tclproc   / {} {divmod /}
  v0_make_tclproc mod {} {divmod %}
  
  #---------------------------------------
  v0_make_tclproc "dup" {} {
    v0_needlen 1
    
    set a [pop]
    
    # мы здечь уже избавляемся от скобок? ент!!
    # тогда теряется информация о списке из 1-го элемента !!
    # и обратно кладутся уже "голые" значения без скобок BEG..END
    
    push $a ;# это ен должен бытьп ростой Lappend!
    push $a
    
  }
  #---------------------------------------
  v0_make_tclproc "dup2" {} {
    v0_needlen 2
    
    set a [pop]
    set b [pop]
    push $b
    push $a
    push $b
    push $a
  }
  #---------------------------------------
  v0_make_tclproc "swap" {} {
    v0_needlen 2
    
    set a [pop]
    set b [pop]
    push $a
    push $b
  }
  #---------------------------------------
  v0_make_tclproc "drop" {} {
    v0_needlen 1
    
    pop
  }
  #---------------------------------------
  v0_make_tclproc "rot" {} {
    v0_needlen 3
    
    set c [pop]
    set b [pop]
    set a [pop]
    push $c
    push $a
    push $b
  }
  #---------------------------------------
  v0_make_tclproc ">" {} {
    v0_needlen 2
    
    push [expr {[pop]>[pop]}]
  }
  #---------------------------------------
  v0_make_tclproc "<" {} {
    v0_needlen 2
    
    push [expr {[pop]<[pop]}]
  }
  #---------------------------------------
  v0_make_tclproc "==" {} {
    v0_needlen 2
    
    push [expr {[pop]==[pop]}]
  }
  #---------------------------------------
  # Nop istruction is important to kill some 
  # istruction by mutation.
  #---------------------------------------
  v0_make_tclproc "nop" {} {
    
    
  }
  #---------------------------------------
  # Not
  #---------------------------------------
  v0_make_tclproc "not" {} {
    v0_needlen 1
    
    push [expr {![pop]}]
  }
  
  #---------------------------------------
  v0_make_tclproc "joy_concat" {} {
    
    v0_needlen 2
    
    set l2 [pop]
    set l1 [pop]
    
#     set l2 [erase_LIST  $l2] ;# освободились от внешних "скобок"
#     set l1 [erase_LIST  $l1]
    22_erase  l2
    22_erase  l1
    
    set ret [concat $l1 $l2] ;# объединили "голые" списки
    
    push "$::BEG $ret $::END"
  }
  #---------------------------------------
  
  v0_:_prg  concat       joy_concat

  v0_:_prg  filter {split swap pop}
  
  #---------------------------------------
  # ПЕЧАТЬ-ВЫВОД   
  #---------------------------------------
  v0_make_tclproc "^" {} {
    
    puts "    = [pop]"
    
  }
  #---------------------------------------
  v0_make_tclproc "map" {} {
    
    set f     [pop]
    set list  [pop]
    
    22_erase  f     ;# освобождаем списки от BEG END, остаются чистые списки
    22_erase  list

    set res {}
  
    foreach e $list {
      
      run_v2_src  "$e $f"

      lappend res [pop]
    }
  
    push "$::BEG $res  $::END"
  }
  #---------------------------------------
  v0_make_tclproc "split" {} {

    set f     [pop]
    set list  [pop]

    22_erase  f     ;# освобождаем списки от BEG END, остаются чистые списки
    22_erase  list

   # нужно разбить список на два, в соответствии с условием
    #
    
    foreach i {0 1} {set $i {}} ;# зануляем два списка результатов
    
    #11_erase f ;# очистим, если надо от ()
    
    foreach e $list {
      
      #eval [list r   $e] $f ;# кладем e в стек и выполняем над ней функцию
      
      run_v2_src  "$e $f"

      set res [pop]
      #puts "res = $res"
      
      lappend  [expr {!! $res}] $e     
    }
    
    #push  $0 $1
    push  "$::BEG $0 $::END"
    push  "$::BEG $1 $::END"
  }
  #---------------------------------------


  #-----------------------------------------------------------------------------
}


#v2_init_all_operators

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc p_init_all_operators_BE {} {


  proc 2op op {
    
    set t [pop]  
    push [expr {[pop]} $op {$t}]
  }

  # functionality is exposed for binary operators and one-arg functions:
  #
  foreach op {+ - * / > >= != <= <} {

    #  v0_: $op [list 2op $op] tcl
    v0_make_tclproc $op {} [list eval 2op $op]
  }
  
#   # здесь не создаются "реальные" процедуры TCL, а пока только заготовки,
#   # которые в дальнейшем будут интерпретироваться!

#   v0_: =  {2op ==} tcl
  
#   #--------------------------------------------------------------
  
  proc 1f  f {push [expr $f ([pop])]}
  
  foreach f {abs double exp int sqrt sin cos acos tan} {

    #: $f [list 1f $f] tcl
    v0_make_tclproc $f {} [list eval 1f $f]
  }
  
#   #--------------------------------------------------------------
#   # The "dictionary" has all one-liners:
  
#   v0_: .       {pn "[pop] "}                        tcl



  #--------------------------------------------------------------

  # Применение такой конструкции { .... } tcl подразумевает, что
  # мы должны использовать в стеке синтаксис TCL !! скобки и т.д!
  # что противоречит нашему пожеланию работать только с плоскими конструкциями
  # BEG-END !?

  #:  c      {set ::joy_ST {}}                  tcl ;# clear stack
  v0_make_tclproc "c"   {} {set ::joy_ST {}}

  #: .s      {puts $::joy_ST}                   tcl
  v0_make_tclproc ".s"  {} {puts $::joy_ST}
  v0_make_tclproc "."   {} {puts [pop]}

  #: dup     {push [set x [pop]] $x}        tcl
  v0_make_tclproc "dup" {} {v0_needlen 1 ; push [set x [pop]] $x}

  
  v0_make_tclproc "swap" {}   {push [pop] [pop]}  

  #   v0_make_tclproc "map" {}  {rmap [pop] [pop]}

  #--------------------------------------------------------------
  
  # TODO: выделить самые простые операции, через которые можно 
  # определить остальные!

  #--------------------------------------------------------------

  return
}
#-------------------------------------------------------------------------------
proc v2_init {} {


  joy_init ;# самая начальная инициация


  #-----------------------------------------------------------------------------
  #
  proc push args {
    
    # последовательно все аргументы помещаем в стек:
    # 
    # а если аргументы сами представляют списки?
    # если это список, то он добавится как список tcl, а нужно поэелментно! 
    # 
    #
    # тогда их надо раскрывать для BE-списков? но это противоречит спискам TCL
    # скорее всего. надо опреедлиться с моделью и разделять их обработку!
    #
    
    #   if {$::VER == "2222"} {
    
    foreach a $args {lappend ::joy_ST {*}$a}   
    #   } else {
    
    #     foreach a $args {lappend ::joy_ST    $a}
    #   }
    
    return
  }
  #
  #----------------------------------------------------------------------------
  #
  proc pop_LIST {} {
    
    set l $::END
    
    while {1} {
      
      set element [pop]  ;# если там встроенный BEG-END-список, то он пойдет 
      # как Tcl-список
      
      set r [lreverse $element] 
      lappend l {*}$r       ;# тот же эффект !!
      
      
      if {[string match $::BEG $element]} {break}
    }
    
    set l [lreverse $l] ;# перевернем строку
    
    return $l
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
    
    
    if {$::END == $element} {
      
      set element [pop_LIST] ;# считываем целиком BE-список!
      
    }
    
    return $element
  }
  #
  #-----------------------------------------------------------------------------


  #set ::stack {} 
  p_init_all_operators_BE ;# инициализируем основные процедуры (команды)

  # Применение такой конструкции { .... } tcl подразумевает, что
  # мы должны использовать в стеке синтаксис TCL !! скобки и т.д!
  # что противоречит нашему пожеланию работать только с плоскими конструкциями
  # BEG-END !?

  v2_init_all_operators

  set ::joy_ST {}  ;# зануляем стек 

  #set ::BEG "BEG"
  #set ::END "END"

  #: ^     {puts "    = [pop]"} tcl ;# надо ли здесь так хитро?
  v0_make_tclproc "^"  {} {puts "    = [pop]"}

  #: nop   ;# пустышка
  v0_make_tclproc "nop" {} {}

  #: joy_concat {push [concat [pop] [pop]]} tcl
  

}
#-------------------------------------------------------------------------------
# для совместимости с другими версиями ?
#-------------------------------------------------------------------------------
# proc ver1-create-context {} {

#   v0_set_stack_null  ;# это в общем файле "j-0000.tl"

#   return {}
# }
#-------------------------------------------------------------------------------
# proc JOY_create_context {} {

#   # такие функции есть в 3-версии

#   #return [ver1-create-context]
#   v0_set_stack_null  ;# это в общем файле "j-0000.tl"

# }
#-------------------------------------------------------------------------------
#  З А П У С К А Л К А   п р о г р а м м (НЕ рекурсивная !!)
#
#-------------------------------------------------------------------------------
proc check_BEG_END_mode {instr} \
{

#   if {$::VER == "2222"} {

    # в будущем сделаем операции BEG и END стандартными, а пока - это 
    # частный случай включения режима чтения списка в стек:
    
    if {$instr == $::BEG} {
      incr ::is_mode_list
    } 
    
    if {$::is_mode_list} {
      
      push $instr ;# все что внутри BE-списка смело помещаем в стек
      
      if {$instr == $::END} {
        incr ::is_mode_list -1 ;# а если это был признак конца, то уменьшаем 
        # счетчик-флаг
      }
      
      return $::TRUE
    }

#   }

  return $::FALSE
}
#-------------------------------------------------------------------------------
# работаем над одиночной инструкцией
#
#-------------------------------------------------------------------------------
proc work_on_this_instr {instr} \
{

  if {[check_BEG_END_mode  $instr]} return

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # ищем сначала среди встроенных процедур ::makeproclist
  # 
  set prog [v0_find_tclproc $instr] ;# !!! можно ведь сразу посмотреть,
  # ести ли такая программа в соответсвии с префиксом ? или даже 
  # попробовать выполнить?

  
  if {$prog != {}} {
    
    $instr 

  } else {
    
    # не найдено в ::joy_tcl_list - поищем в ::joy_proglist
    # 

    set func_body [v0_find_joyprog $instr]
  
    if {$func_body != {}} {

      # а вот и рекурсия
      run_v2_src  $func_body ;# выполняем как встроенную функцию

    } else {  
  
      if {[IsDebug]} {
         puts stderr   "NOT symbol: instr= $instr (push to datastack)"
        
      }
      push $instr
    }

  }

}
#-------------------------------------------------------------------------------
proc run_v2_src {prg} {


  if {[IsDebug]} {
    puts ""
    puts "run_v2_src: PRG = $prg"
    puts ""
  }

  set __ip -1 

  # работаем с программой, как со списком (хотя он может быть и не корректный?)
  #
  while 1 {

    incr __ip                     ;# сдвигаем указатель
    set instr [lindex $prg $__ip] ;# берем по нему инструкцию
                                   # инструкция берется просто из списка ..!
    
    if {[IsDebug]} {
      puts [format "stack= | %25s |  instr= %s  " $::joy_ST $instr]
    }


    if {$instr eq {}} break ;# если просто строка prg закончилась?
    
    
    if {[llength $instr] >= 2} {

      # в нашей новой версии никаких списков (в смысле Tcl) быть не должно!
      #
      puts ""
      
      ERROR "run_v2_src ERROR:  llength >= 2, instr = $instr "
    } 

    work_on_this_instr  $instr

  } ;# while
  

  if {[IsDebug]} {puts ""}

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------


#DEFINE square  ==  dup  * . 
#[1 2 3 4]  [square]  map 

#-------------------------------------------------------------------------------

  # нужно научиться выполнять простые операции со списками
  #  
  # т.е. мы договоримся, что несколько элементов квотируются как список {.. ..},
  # а один элемент квотируется префиксом "_", который, при помещении в стек 
  # отбрасывается
  #
  #set prg " {1 2}  {1} _MOVE " -- это ПЛОХАЯ идея !! - но !!
  #                             у чела сделано квотирование скобками () !!
  #

#-------------------------------------------------------------------------------
# proc TEST_test__ {} {

#   #ver1-create-context

#   v2_init       ;# разные ништяки
#   v0_set_stack_null  ;# 
  
#   set prg " {1 2}  {1 nop} {nop MOVE} "

#   #test_prg_eval $ctx $prg

#   puts ""
#   puts "prg= $prg"
#   puts ""
#   run_v2_src  $prg

#   v0_print_stack 

# }
#-------------------------------------------------------------------------------
proc TEST_lnew {} {

  puts ""
  puts "TEST_lnew ..."
  puts ""
  
  #ver1-create-context
  v2_init       ;# разные ништяки
  v0_set_stack_null  ;# 
  
  #DebugOn

  # нужно научиться выполнять простые операции со списками
  # 
  #run_v2_src  " BEG 1 2 + END i ^"


  # продобрать более визуально заметные скобки ??
  # 
  #set_BEG_END  "<BEG" "END>"

  #run_v2_src   $ctx { <BEG 1 2 + END> i ^}

  #set_BEG_END  "BEG" "END"

  #puts " ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "

  #run_v2_src   $ctx { BEG 1 END dup }

  #run_v2_src   $ctx { BEG 1 2 END dup }

  #return

  #DebugOff

  #v0_set_stack_null


  #set prg { BEG MOVE END  BEG RIGHT END  IF_FOOD_AHEAD }

  #set prg { MOVE RIGHT  IF_FOOD_AHEAD } ;# хотелось, чтобы и так работало !!

  #set e {BEG MOVE END}
  #puts stderr "e (origin) = $e"

  #set e [erase_LIST $e]
  #puts stderr "e (erase ) = $e"

  #puts stderr ""

  #set e {MOVE}
  #puts stderr "e (origin) = $e"

  #set e [erase_LIST $e]
  #puts stderr "e (erase ) = $e"

  #run_v2_src   $ctx { BEG 1 BEG 2 3 END END ^}

  #run_v2_src   $ctx { BEG 1 BEG 2 3 END END }



  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  set prg { BEG 1 BEG 2 3 END END  dup }

  DebugOn

  run_v2_src  $prg
  #run_v2_src  $prg


  puts "::joy_ST = $::joy_ST"

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_more {} {

  puts ""
  puts "TEST_more ..."
  puts ""
  
  v2_init       ;# разные ништяки
  v0_set_stack_null  ;# 
  
  #DebugOn

  # нужно научиться выполнять простые операции со списками
  # 

  run_v2_src   " BEG 1 2 END ^"

  run_v2_src   " BEG 1 2 3 END  BEG 4 5 6 7 END  joy_concat ^"

  # определяем как встроенную функцию (нельзя пока определить как concat
  # - будет конфликтовать с реальной TCL-функцией
  # 

  v0_:_prg ccc  joy_concat

  run_v2_src   " BEG 1 2 3 END   BEG 4 5 6 7 END  ccc ^"

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_simp_BE {} {

  puts ""
  puts "TEST_simp_BE ..."
  puts ""
  
  #set ctx [ver1-create-context]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v2_init    ;# 

  #d+
  
  #r c  1 2 + .s 
  #r       1 2 + ^ 

  run_v2_src  "1 2 + ^" ;# чего это не работает ??

  run_v2_src  "2 3 + ^"    ;# #ver1-eval   $ctx "2 3 + ^"
  run_v2_src  "2 3 * ^"    ;# #ver1-eval   $ctx "2 3 * ^"

  puts ""

  run_v2_src "nop 1 2 + ^" ;# #ver1-eval   $ctx "nop 1 2 + ^"
  run_v2_src ".s"

  puts ""
  puts "-------------------------------------"
  puts ""

  run_v2_src "c  BEG 2 3 END   .s"

  set_BEG_END  "B" "E"

  run_v2_src "c  B 1 2 E  dup . ." 

  v0_:_prg  kvadrat {dup *}
    
  run_v2_src "c  6   dup * ." 
  run_v2_src "c  6 kvadrat ." 

  run_v2_src "c  3 4 swap .s" 

  run_v2_src "c  B 6 1 5 2 4 3 E  B 3 > E split . ." 

  #puts ""
}
#-------------------------------------------------------------------------------
# BE: уходим от синтаксиса Tcl к "плоскому" списку BEG_END
#-------------------------------------------------------------------------------
proc TEST_list_BE {} {

  #puts ""
  #puts "TEST_list_BE: ... begin"
  puts ""
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v2_init
  #d+


  #v2_init    

  #puts ""
  #puts "............... i-prog"
  #puts ""

  #r c  BEG 2 3  + END  i .s ;# TODO: ?????????? должно быть :  5
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  puts ""
  v2_init

  run_v2_src   "c  BEG 1 BEG 2 3 END END   dup" ;# тоже самое
  run_v2_src  ".s"  ;# посмотрим стек

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  puts ""
  v2_init ;# очистим стек

  set prg_1 { BEG 1 BEG 2 3 END END   dup}

  run_v2_src  $prg_1 
  run_v2_src      ".s" ;# посмотрим стек

  #puts ""

  return
}
#-------------------------------------------------------------------------------
#
# TODO: 
#
# r c  BEG 1 2 + END   i .s 
#
# j~.tl 1111 TEST_2005_BE
#
# 
#-------------------------------------------------------------------------------
proc TEST_simp {} {

#   puts ""
#   puts "........ TEST_simp ... "
  puts ""
  
  v2_init       ;# разные ништяки
  v0_set_stack_null 
  
  run_v2_src   "1 2 + ^"
  run_v2_src   "2 3 + ^"
  run_v2_src   "2 3 * ^"

  puts ""

  v0_set_stack_null 
 
  run_v2_src   "3 2 1 ^" 
  run_v2_src   "      ^" 
  run_v2_src   "      ^" 

  puts "" ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  v2_init ;# а там дублируется, напрмер "i"
  #d+

  run_v2_src  "c  BEG  1 2  END     .s" 
  run_v2_src  "c  BEG  1 2  END   i .s"


  puts "" ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #r c    (3)    .s  ;# ?? т.е. в стеке уже не квотированный? разве это правильно?
  #r c    (3)  i .s

  run_v2_src  "c  BEG    3  END     .s"
  run_v2_src  "c  BEG    3  END   i .s"


  puts "" ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #d+ ;# чего-то пока не получается

  run_v2_src  "c  BEG  1 2 + END  i .s"  ;# TODO: ?????????? !!! д.б. = 3!!


  return
}
#-------------------------------------------------------------------------------
proc TEST_todo {} {


  puts ""

  v2_init       ;# разные ништяки
  v0_set_stack_null 

  #d+ ;# чего-то пока не получается

  run_v2  BEG  1 2 + END  i ^  ;# 
  #run_v2  BEG  1 2 + END  i .  ;# 
  run_v2  BEG  1 2 + END  i .s ;# TODO: ?????????? !!! д.б. = 3!!

  puts ""
}
################################################################################

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc translate_ndict_11_to_22 {&ndict} {

  USE_REFS

  dict for {symbol code} $ndict {

    set prg_22 {}
    convert_11_to_22  $code  prg_22

    dict set ndict $symbol $prg_22
  }

}
#-------------------------------------------------------------------------------
proc TEST_new_01 {} {

  puts ""

  #v3_init_SIMP ;#  _context
#   V3_INIT_01 

#   set text  {

#       DEFINE ccc == concat ; cc2 == concat.

#       (* -------*)

#       [2 3] [4 5] ccc ^
#       [2 3] [8 9] cc2 ^

#       1 (A) $A 2 + 
#   }

#   set text  { 

#     DEFINE mysquare   ==   dup * .
    
    
#     1 2 + . 
#     3 mysquare .
#   }


  #V3_INIT_01 
  # V3_INIT_02  ;# куча дополнительных функций
  
#   set text {

#     DEFINE mysquare   ==  dup  * .

#     2 1 +  mysquare . 
#     [1 2] dup .
#   }

  set text {
    2 1 + . 
  }

  #joy-eval $text

  #run_joy_prg_compiled  $text

  #return


  # скомпилируем исходный текст в выходной формат
  #
  set ::print_defines 1

#   set joy_functext_to_proc "joy_functext_to_v3_code" 
#   #set  joy_functext_to_proc "joy_functext_to_v1_code" 

#   set ndict [joy-compile_to_namecodedict \
#                 $text \
#                 $joy_functext_to_proc]

  set ndict [joy-compile_to_namecodedict \
                $text \
                "joy_functext_to_v1_code"]

  # а теперь распечатаем все полученные определения:
  # 

  #puts ""
  puts "-------------------------------------------"
  puts ""


  translate_ndict_11_to_22  ndict

  puts ""
  puts "-------------------------------------------"
  puts ""


  puts "$ndict"

  # а теперь выполним код

  v2_init       ;# разные ништяки
  v0_set_stack_null 
  
  #run_v2_src   "1 2 + ^"

  set v2_src [dict get $ndict {}]

  puts "v2_src = $v2_src"

  run_v2_src  $v2_src 

  puts $::joy_ST

  return
}
#-------------------------------------------------------------------------------

# - проверить можно ли будет резать/сливать строки непосредственно в v1?
# - или все же в v2? сделать обобщенный тип v1/v2 ?

# - вернуться к формату v3. основной? вспомогательный?
#   а может будет достаточно расширенного формата v1/v2 со статистикой?
# 
#
# TODO:
# 
# - сделать наконец парсинг для  v1/v2 и тесты с запуском
# - и все тесты пройти в формате v1/v2, дописывая недостающие функции
# 
# повторить часть тестов JOY в формате v1, аналогично  i0 и м3:
#
# i_main               i__01.joy
# k~.tl  JOY3   TEST_file_01 
    
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc run_joy_file_v2 {fname} {


  # не будем включать include на стадии препроцессинга
  # 
  set r_text_all [read_file_to_rtext   $fname]
  
  #puts "run_joy_file: r_text_all = $r_text_all"
  #puts "======================================"

  #joy-compile  $r_text_all

  #set ndict [joy-compile_to_namecodedict $r_text_all]

  set ndict [joy-compile_to_namecodedict \
                $r_text_all \
                "joy_functext_to_v1_code"]

  translate_ndict_11_to_22  ndict


  v2_init       ;# разные ништяки
  v0_set_stack_null 
  
  #run_v2_src   "1 2 + ^"

  set v2_src [dict get $ndict {}]

  #puts "v2_src = $v2_src"

  run_v2_src  $v2_src 

  return
}
#-------------------------------------------------------------------------------
proc TEST_file_v2 {} {


  #V3_INIT_03  ;# куча дополнительных функций
  #V3_INIT_01
  #v3_init_null  ;# без встроенных DEFINE

  puts ""

  #set ::joy::debug 1

  #run_joy_file_v2 "i__00.joy"

  run_joy_file_v2 "i__01.joy"

  puts ""

  return
}
# ------------------------------------------------------------------------------
################################################################################
################################################################################


# j~.tl 2222 TEST_convert_11_to_22
# j~.tl 2222 TEST_convert_22_to_11

# j~.tl 2222 TEST_convert_22_to_11_err
# 

# k~.tl 2222 TEST_new_01

# k~.tl 2222 TEST_file_v2

# ------------------------------------------------------------------------------
################################################################################
