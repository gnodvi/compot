# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
if [info exists ::J_0000_TL] {
  return
} else {
  set  ::J_0000_TL "this module loaded"
}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set ::BIBLIO {} ;# - список (стек), в который будем складывать
#              словари-библиотеки (общая по задаче, локальные по программе)


set ::joy_proglist {}  ;# будет dict - библиотека процедур


# список, заполняемый процедурой [v0_make_tclproc] 
#
set ::joy_tcl_list {}  ;# TCL-процедуры с префиксами ? или без ?
                        # вообще бы от него отказаться?


# That's it. Stack (list) and Command array are global variables:
#
set ::joy_ST {}  ;# The VM stack


set  ::NEW_tclproc 0


################################################################################
#
#-----------------------------------------------------------------------------
proc biblio_print args {
  
  puts ""
  puts "::BIBLIO = $::BIBLIO"
  puts ""


  foreach lib $::BIBLIO {

    dict_print $lib
  }

  
  return
}
#-----------------------------------------------------------------------------
proc biblio_push args {
  
  foreach a $args {lappend ::BIBLIO  $a}
  
  return
}
#-----------------------------------------------------------------------------
proc biblio_pop {} {
  
  set element [ K [lindex $::BIBLIO end] [set ::BIBLIO [lrange $::BIBLIO 0 end-1]] ]
  
  return $element
}
#-------------------------------------------------------------------------------
proc biblio_find_progbody {progname} \
{

  # перебираем все библиотеки в списке, начиная с верхушки стека
  # 

  foreach lib [lreverse $::BIBLIO] {

    set lib [dict_get_D $lib] ;# уитывая возможный указатель на словарь


    dict for {name progbody} $lib {

      if {$name == "main"} {continue} ;# TODO: не должно быть в библиотеке

      if {$name == $progname} {

        return $progbody
      }
    }          
  }

  return {}
}
################################################################################
#-------------------------------------------------------------------------------
proc joyprogs_create {} {

  set jp [dict_create]

  return $jp
}
#-------------------------------------------------------------------------------
proc joy_init {} {


  #set ::joy_proglist [dict_create]

  set ::joy_proglist [joyprogs_create]


  biblio_push $::joy_proglist ;# запихнуть указатель на СИСТЕМНУЮ библиотеку 
                                 # в стек БИБЛИО

  return
}
################################################################################

# Определение Joy-процедуры; 
# тело (body) задается в виде списка.
#
#-------------------------------------------------------------------------------
#proc v0_:_prg {name body} {}
proc v0_make_joyprog {name body} {

  # TODO: слишком простая схема, нужна структура [list "src" $body]
  # 

  dict_set $::joy_proglist $name "src" $body

  return
}

#interp alias {} v0_:_prg {} v0_make_joyprog
alias v0_:_prg v0_make_joyprog

#-------------------------------------------------------------------------------
# Определение процедур сделано в стиле Forth, поскольку выглядит много более
# компактно , чем Joy-евское  DEFINE n == args;
#
# здесь args - системная переменная, собирающая в список аргументы
# 
#-------------------------------------------------------------------------------
proc v0_: {name args} {

  # $args - уже автоматом сформировался список из аргументов

  v0_:_prg  $name $args ;# выраизм лучше через эту функцию для общности
} 
#-------------------------------------------------------------------------------
proc v0_find_joyprog {instr} {


  set syslib [set $::joy_proglist] ;# взяил словарь по ссылке


  if {[dict exist    $syslib $instr]} {

    return [dict get $syslib $instr "src"]
  } 

  return {}
}
#-------------------------------------------------------------------------------
proc prog_get_prg_src {prog prg_name} {

  #if [is_GLOBAL_DICT $prog] { 
  #   # это была ссылка на словарь
  #  set prog [set $prog] ;# сам словарь
  #} 
  
  return [dict get $prog  $prg_name "src"] 
}
#-------------------------------------------------------------------------------
proc prog_set_prg_src {&prog prg_name prg_src} {

  # TODO: наверное главная проблема - нужно сделать через ссылки на словари!!
  # 

  USE_REFS

  dict set prog $prg_name "src" $prg_src  ;# занесем процедуру в библиотеку

}
#-----------------------------------------------------------------------------
################################################################################
#-------------------------------------------------------------------------------
proc v0_make_tclproc {name  arglist body} {

  if {$::NEW_tclproc} {

    dict_set $::joy_tcl_list $name {}

  } else {
    lappend ::joy_tcl_list $name   ;# добавить имя в список инструкций
  }
  
  proc $name $arglist $body ;# создать процедуру (средствами Tcl) 

}
#-------------------------------------------------------------------------------
proc v0_make_tclproc_alias_NEW {aliasname realname} {


  if {$::NEW_tclproc} {
    dict_set $::joy_tcl_list $aliasname {}
  } else {
    lappend ::joy_tcl_list $aliasname   ;# добавить имя в список инструкций
  }

  # ??
  # 
  #alias $aliasname $realname

  interp alias {} $aliasname {} $realname

}
#-------------------------------------------------------------------------------
proc v0_find_tclproc {name} {

  if {$::NEW_tclproc} {


    if {[dict exist ::joy_tcl_list $name]} {
      
      return $name
    } 

  } else {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    foreach i $::joy_tcl_list {
      
      if {$i == $name} {
        
        return $name
      }
    }
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  }
  
  return {};
}
################################################################################
#
#-------------------------------------------------------------------------------
#
# Stack routines
#

#-------------------------------------------------------------------------------
# подготовить состояние ВМ для выполнения новой программы
#-------------------------------------------------------------------------------
proc v0_set_stack_null {} {


  set ::joy_ST {}  ;# The VM stack

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# а где эта процедура используется ?? !!
#-------------------------------------------------------------------------------
#
proc v0_print_stack {} {

  puts "stack = $::joy_ST"
  
  set index 0

  foreach i $::joy_ST {
    puts "   s$index = $i"
    incr index
  }

}
#-------------------------------------------------------------------------------
# проверить что стек длиной по крайней мере 'n', иначе 
# принудить вызвавшую процедуру "закончить"
#
# хотя можно сделать проверку и в каждом локальном "pop".
#-------------------------------------------------------------------------------
proc v0_needlen n {

  if {[llength $::joy_ST] < $n} {

    # Debug "LenStack= [llength $::stack]"
    #return -code return
    error "joy-check-stack:  Stack underflow"
  }

}
# т.е. "хранимая" процедура просто тупо не выполняется !!
#
#-------------------------------------------------------------------------------
# The test suite:
#-------------------------------------------------------------------------------
#
proc ? {cmd expected} {
                       
 catch {uplevel 1 $cmd} res
                       
 if {$res ne $expected} {puts "$cmd -> $res, not $expected"}

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Joy program compilation

# Joy program parsing

# The parser core. Joy parsing is trivial like many other
# stack based languages.
# Note that to parse truth values is not needed since they
# are the same as symbols (at least from the syntax point of view).

#-------------------------------------------------------------------------------
proc pop-joy-token textvar {

  upvar $textvar text

  if {![string length $text]} {return {}}

  set text   [string  trim $text]
  set first  [string index $text 0]
  set second [string index $text 1]

  switch -- $first {
    \-  {
      if {$second ne {} && [string is digit $second]} {
        pop-num-token text
      } else {
        pop-symbol-token text
      }
    }
    0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 {pop-num-token text}
    \[ {pop-list-token text}
    \" {pop-string-token text}
    \' {pop-char-token text}
    \; {pop-singlechar-token text}
    \. {pop-singlechar-token text}
    \] {pop-singlechar-token text}
    (  {
      if {$second eq {*}} {
        pop-comment-token text
      } else {
        pop-capture-token text
      }
    }
    default {pop-symbol-token text}
    }

}
#-------------------------------------------------------------------------------
# Parse a number literal
#-------------------------------------------------------------------------------
proc pop-num-token textvar {

  upvar $textvar text

  regexp {[0-9\.E\-]+} $text match
  set text [string range $text [string length $match] end]
  
  return $match
}
#-------------------------------------------------------------------------------
# Parse a symbol literal
#-------------------------------------------------------------------------------
proc pop-symbol-token textvar {

  upvar $textvar text
  
  regexp {([^ \s;.\]]+\]{0,1})(.*)} $text => match text
  
  return $match
}
#-------------------------------------------------------------------------------
# Parse a string literal
#-------------------------------------------------------------------------------
proc pop-string-token textvar {

  upvar $textvar text
  
  set l [string length $text]
  for {set i 1} {$i < $l} {incr i} {
    switch -- [string index $text $i] {
      \\ {incr i}
      \" break
    }
  }
  if {$i == $l} {
    error "Syntax error: missing close \""
  }
  set match [string range $text 0 $i]
  set text [string range $text [expr {$i+1}] end]
  
  return $match
}
#-------------------------------------------------------------------------------
# Parse a character literal
#-------------------------------------------------------------------------------
proc pop-char-token textvar {

  upvar $textvar text
  
  set match [string range $text 0 1]
  set text [string range $text 2 end]
  
  return $match
}
#-------------------------------------------------------------------------------
# Parse a list literal. Proper parsing of lists is done
# recursively calling the main parser from this function
# in order to parse all the sub-lists.
#-------------------------------------------------------------------------------
proc pop-list-token textvar {

  #if {$::joy::debug} {puts " pop-list-token .. !!"}
  #if {$::tdebug} {puts " pop-list-token .. !!"}

  # формируется список TCL ?? (псевдорекурсивно) из входного синтаксиса
  # [ []  []  ]
  # вызывается по первой открывающей скобочке

  upvar $textvar text
  
  # skip the first [
  set text [string range $text 1 end]

  append match {[}

  while {[set token [pop-joy-token text]] ne {}} {

    #if {$::tdebug} {puts "token = $token"}

    # читаем токены подряд, добавляем в результат пробел
    # 
    append match $token " "

    if {[string index $token 0] ne {[}} {
      if {[string index $token end] eq {]}} {
        if {[string index $token 0] ne {'}} {
          set match [string range $match 0 end-1]
          break
        }
      }
      }
  }

  if {[string range $match end-1 end] eq { ]}} {
      set match [string range $match 0 end-2]

      append match {]}
  }

  return $match
}
#-------------------------------------------------------------------------------
# Parse a local capture literal.
#-------------------------------------------------------------------------------
proc pop-capture-token textvar {

  upvar $textvar text

  regexp {(\([^\(]*\))(.*)} $text => match text

  return $match
}
#-------------------------------------------------------------------------------
# Parse a single char, like ";" and "."
#-------------------------------------------------------------------------------
proc pop-singlechar-token textvar {

  upvar $textvar text

  set match [string index $text 0]
  set text [string range $text 1 end]

  return $match
}
#-------------------------------------------------------------------------------
# Parse a comment, support nested comments.
#-------------------------------------------------------------------------------
proc pop-comment-token textvar {

  upvar $textvar text
  
  set l {expr {[string length $text]-1}}
  set level 1

  for {set i 1} {$i < $l} {incr i} {

    set t [string range $text $i [expr {$i+1}]]

    switch -- $t {
      {(*} {incr level 1}
        {*)} {incr level -1}
    }

    if {!$level} break
  }

  if {$level} {
    error "Never closed comment (* ... "
  }
  set match [string range $text 0 [expr {$i+1}]]
  set text [string range $text [expr {$i+2}] end]
  
  return $match
}
#-------------------------------------------------------------------------------
# Split the pre-parsed code in symbol names and associated code.
# The top-level code is put inside the symbol name {} (empty string).
#
# Returns a list, every element is a three elements list
# where:
#  - the first element is "define" or "library", in relation to the use
#    of DEFINE or LIBRARY Joy keywords.
#  - the second element is the name of the symbol to bind.
#  - the third element is the code associated to the symbol.
#
# The top-level code is always the first element of the returned list.
#-------------------------------------------------------------------------------
proc joy-split-defines tokens {

  set result {}; # окончательный список

  set tlcode {}; # "toplevel" накопитель кода
  set type   {}
  set symbol {}
  set code   {}
  
  set state TOPLEVEL
  
# Надо разобраться в разнице определений DEFINE и LIBRA
#
# -------------------------------------
# (* LIBRA *)
# DEFINE

# square   ==   dup  * ;

# DEFEND == "".
# (* END  *)
# (* END. *) 
# -------------------------------------

# JOY : определения идут через ';' и заканчиваются '.'
# тоже и для LIBRA ?? только там в конце особый оператор END.
#
# Да надо от LIBRA наверное просто отказываться ?!

  foreach t $tokens {

    switch -- $state {

      TOPLEVEL {
        switch -- $t {
          #LIBRA  {set type library;  set state GETNAME} ;# не работает !?
          LIBRA - DEFINE {
            set type  define;  
            set state GETNAME
          }
          
          default {lappend tlcode $t}
        }
      }

      GETNAME {
        if {
            [string range $t 0 1] ne {(*}
              &&
            $t ne "HIDE"
              &&
            $t ne "IN"
            } {
          set symbol $t
          set state SKIPNEXT
        }
      }

      SKIPNEXT {
        if {$t ne {==}} {
          puts "
!!---------------------------------------------------------!!
   tlcode = 
   $tlcode

   result = 
   $result

   symbol = '$symbol'
   Expected ==, got ''$t''
!!---------------------------------------------------------!! "

          #code   = '$code'
          puts ""
          #error "Expected ==, got ''$t''"
          error ""

        }
        set state GETCODE
        set code {}
      }

      GETCODE {
        switch -- $t {

          END {
            # просто пропускаем это слово (за ним либо . либо ;? )
            #puts "END............ t = $t"
          }

          . {
            lappend result [list $type $symbol $code]
            #puts "............... t = $t  result = $result"
            set state TOPLEVEL
          }

          \; { 
            lappend result [list $type $symbol $code]
            set state GETNAME
          }
          default {lappend code $t} 
        }
      }
    }
  }

  # здесь имеем:
  # 
  # tlcode - список верхнего уровня, т.е. сама основная программа
  # result - список определений (типа define)
  # 

  #The top-level code is put inside the symbol name {} (empty string)
  #
  set top_level_code [list define {} $tlcode]

  # а теперь переставим список с основным кодом вперед
  #
  set result [linsert $result 0 $top_level_code]

# result = {
#     {define {} <maincode>}  
#     {define <name> <code>} .. 
#     {define <name> <code>}
#   }

  return $result 
}
#-------------------------------------------------------------------------------
# Convert a program in tokens, returned as a Tcl list.
#-------------------------------------------------------------------------------
proc joy-tokenize text {

  #if {$::joy::debug} {    
  #  puts "joy-tokenize ... BEG text ="
  #  puts ""
  #  puts "$text"
  #  puts ""
  #  puts ""
  #}


  set copy $text ;# а для чего это?
  set tokens {}

  # разбираем исходный текст на токены, пока они не закончатся
  # 
  while {[set token [pop-joy-token  copy]] ne {}} {

    #if {$::joy::debug} {    
    #  puts "token = $token"
    #}

    lappend tokens $token
  }


  #if {$::joy::debug} {    
  #  puts "joy-tokenize ... END"
  #}

  return $tokens
}
#-------------------------------------------------------------------------------
# Tokenize discarding comments
#-------------------------------------------------------------------------------
proc joy-tokenize-no-comments text {

  set tokens [joy-tokenize $text]
  set result {}
  
  foreach t $tokens {
    if {[joy-token-type $t] eq {comment}} continue

    lappend result $t
  }

  return $result
}
#-------------------------------------------------------------------------------
# Return the data type associated with a literal
#-------------------------------------------------------------------------------
proc joy-token-type token {

 if {$token eq {true} || $token eq {false}} {
     return truth
 }
 
 set first  [string index $token 0]
 set second [string index $token 1]
 
 switch -- $first {

     \- {
         if {$second ne {} && [string is digit $second]} {
             return integer
         } else {
             return symbol
         }
     }

     0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 {
         if {[string first . $token] == -1} {
             return integer
         } else {
             return float
         }
     }

     \[ {return list}
     \" {return string}
     \' {return char}

     (  {
         if {$second eq {*}} {
		return comment
	    } else {
		return capture
	    }
	}
	default {return symbol}
    }
}
#-------------------------------------------------------------------------------
proc read_file_to_rtext {fname} {

  set paths {
    ""
    "./J/"
  }

  set fd [open_fname $fname $paths] ;# открыли файл на чтение

  #puts "fd = $fd"

  set r_text [read $fd]      ;# прочитали в список слов (вместе с "\n")

  #puts "r_text = $r_text"
  #puts "---------------------------------------------------------"

  close $fd                  ;# закрыли файл
  
  return $r_text
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Compile a Joy program into a Tcl list.
#-------------------------------------------------------------------------------
proc joy-compile_to_namecodedict {joy_text 
                                  {joy_functext_to_proc "joy_functext_to_v3_code"}} {

  #set joy_functext_to_proc "joy_functext_to_v3_code" 


  #if {$::joy::debug} {    
  #  puts "joy-compile_to_namecodedict ... BEG"
  #}

  set tokens [joy-tokenize $joy_text]

  #if {$::joy::debug} {    
  #  puts "joy-compile_to_namecodedict ... tokens = $tokens"
  #}


  # получаем разделенный на определения текст
  #
  set defines [joy-split-defines $tokens]

  #if {$::joy::debug} {    
  #  puts "joy-compile_to_namecodedict ... defines = $defines"
  #}

  # result = {
  #     {define {} <maincode>}  
  #     {define <name> <code>} .. 
  #     {define <name> <code>}
  #}
  

  # словарь, который мы сформируем со списком откомпилированных функций
  # 
  set defarr [dict create]


  # компилируем каждую определенную функцию
  #
  foreach def $defines {

    # хитрый трюк - получаем элементы списка
    # 
    foreach {type name functext} $def break  ;# ?????? 
    # 
    
#     if {$::print_defines} {

#       puts "type     = $type"
#       puts "name     = $name"
#       puts "functext = $functext"
#       puts ""
#     }

    # формируем код на выходном языке в словарь
    #
    set code [$joy_functext_to_proc  $functext]


    # здесь надо бы аккуратнее разделить, сначала в отдельные массивы
    #
    dict set defarr  $name $code
  }
 
  #if {$::joy::debug} {    
  #  puts "joy-compile_to_namecodedict ... END"
  #}

  return $defarr
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#source "j-1111.tl"
#-------------------------------------------------------------------------------


# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
if [info exists ::J_1111_TL] {
  return
} else {
  set  ::F_1111_TL "this module loaded"
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
  
  #       ~name - поместить просто в стек (квотирование)
  #       >name - записать значение из стека в переменную   set_name
  #       $name - записать значение из переменной в стек    get_name
  # 
  
  
  #puts stderr "prefix_work, a = $a"

  if {[string length $a] == 1} {

    return 0
  }

  set pref [string index $a 0]
  set next [string index $a 1]
  
  #-------------------------------------------------------------
  if {$pref == $::pref_quote} {
    
    if {$next == " "} {

      ;; # это одиночный символ квотирования в начале группы, наверное
      ;; # пока ничего не делаем ?
      #puts stderr "next eq spzce !!!!!"

    } else {

      # сделаем такое квотирование особым вспомогательным методом
      # помещать в стек по сути, сразу очищая от квотирования - 
      
      # облегчая работу, например, функци pop, в которой группа из более чем 1-го
      # элемента читается естественным для tcl способом.
      
      # Но правильно ли это? Ведь может быть вариант с иерархической группировкой
      # в стеке (linrec ?) и тогда нарушается структура программы - внутри
      # по лигике должен быть квотированный элемент, а он уже раскрыт?
      
      push [string trim $a $::pref_quote]
      
      return 1 ;#
    }
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

    return 1 ;#  "continue"  
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

    return 1 ;#  "continue"  
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
#
# непосредственно выполнялка одной команды
# 
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

    #return "continue"
    return 
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
    
    #return "continue"
    return
  } 
  
  # 3) теперь смотрим в TCL-процедурах (лучше сделать через tcl-команду ?)
  # 
  if   {[set tclproc [v0_find_tclproc $a]] != {}} {
    
    $tclproc ;# выполняем зарегистрированную TCL-процедуру
    
    # 4) все остальное
    
  } else {
    
    push $a ;# все остальное "пихаем" в стек в том числе и группы
  }
  

  ##return ""
  return 
}
#-------------------------------------------------------------------------------
proc r_begin {} {

  set ::rr_level  0
  set ::rr_index -1
  set ::rr_is_reterror 0

  set ::ST_save ""

  #set ::joy_ST {}    ;# ???????????

}
#-------------------------------------------------------------------------------
#
# глобальные переменные рекурсивнго выполнения команд

set ::rr_is_restore 0

set ::rr_errorprint 0

r_begin ;# начальная инициализация перед рекурсивным выполнением

#-------------------------------------------------------------------------------
# процедура рекурсивно вызывается из r_one
# 
#-------------------------------------------------------------------------------
proc r args {
  

  # ~~~~~ идем списком по элементам команды ~~~~~~~~~~~~~~~~~
  # 

  # пока упрощенно следим только по верхнему уровню
  #if {$::rr_level == 0} {
  #  set ::rr_index 0
  #}

  foreach a $args {

    if {$::rr_level == 0} {
      incr ::rr_index +1
    }

    if {$::rr_errorprint} {
      puts stderr [format "r: S = %26s  |  a = %26s | %10s, level = %d, ::rr_index = %d  " \
                     $::joy_ST $a $::ST_save $::rr_level $::rr_index]
    }

    # перед попыткой выполнить оператор, сохраним стек, чтобы
    # в случае аварии - восстановить его и продолжить, как бы
    # пропустив этот "ошибочный" оператор
    
    # операторы могут быть сложные и прилично испортить стек
    # до того как дойдут до вложенного ошибочного оператора !!!
    # рекурсия  при вызове r_one -> r
    #
    
    if {$::rr_level == 0} {
      set ::ST_save $::joy_ST
    }
    
    incr ::rr_level +1
    
    #-------------------------------------------------
    if {[catch {set ret [r_one $a]} err]} {
    #-------------------------------------------------
      
      # перехвачена ошибка при выполнении опреатора $a, но это может быть вложенный оператор
      # - надо к этому моменту иметь "адрес" этого оператора во вложениях программы!
      # - но для начала можно упрощенно считать - только номер оператора верхнего уровня..
      
      if {$::rr_errorprint} {
        puts stderr ""
        puts stderr "r_one: ret = $ret, err = $err"
        puts stderr ".......ST = $::joy_ST, ST_save = $::ST_save, a = $a"
        puts stderr ""
      }
      
      if {$::rr_is_restore} {
        set ::joy_ST $::ST_save ;# ??

      } else {

        # TODO: при получении ошибки сразу вываливаться из цикла 
        #        с сохранением полной информации об ошибке:
        # - ошибочный оператор.
        # - точная координата ошибки, с учетом вложенности (список).
        # - содержимое стека на момент ошибки.
        # - код ошибки с расшифровокой (коментарием)

        set ::rr_is_reterror 1
      }
      
      incr ::rr_level -1 ;# 
      
    #-------------------------------------------------
    } else {
    #-------------------------------------------------
      
      # все прошло нормально, без ошибок
      #puts "all ok, ret = $ret, r_one_level = $::rr_level"
      
      incr ::rr_level -1
      
      #if {$ret == "continue"} {continue} ;# ???????
          
      #incr ::rr_level -1
      
    #-------------------------------------------------
    }
    #-------------------------------------------------
    
    if {$::rr_is_reterror == 1} {break}
    
  } ;# foreach a $args 

  # конец цикла по элементам команды
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  #if {$::rr_errorprint} {
  #  puts stderr [format "r: stack = %25s  |  " $::joy_ST]
  #}


  set ::joy_ST  ;# ?? возвращаем стек ??
}
#-------------------------------------------------------------------------------
proc get_rr_is_reterror {} {


  if {$::rr_is_reterror == 1} {
    #puts "run_v1_src: ERROR, ::rr_index = $::rr_index"
    set err_index $::rr_index
  } else {
    set err_index -1
  }

  return $err_index
}
#-------------------------------------------------------------------------------
proc run_v1_src {prg} {

  # prg - программа явным списком

  if {[IsDebug]} {

    puts ""
    puts "run_v1_src:  PRG = $prg"
    puts ""
  }

  r_begin

  r {*}$prg ;# раскроим список и выполним последовательность команд

  set err_index [get_rr_is_reterror]

  return $err_index
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

# слишком упроещенная версия, конфликтуют с ::tcl::mathfunc
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

#set ::quote_in_pop 1

#-------------------------------------------------------------------------------
#if {! $::quote_in_pop} {
#------------------------------------
# proc quote {instr} {

#   eval $instr

# }
#------------------------------------
#}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc v1_init_all_operators {} {


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  v0_make_tclproc  tcl {} {
    
    eval [pop]
    
  }
  #--------------------------------------------------------------

  v0_: .       {puts "[pop] "}                 tcl
  v0_: .s      {puts  $::joy_ST}               tcl 
  v0_: c       {set ::joy_ST {}; r_begin}               tcl ;# clear stack  r_begin ??

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
  # вот, это команды !!!! 
  # 
  #v0_: '       {push [scan [pop] %c]}         tcl  ;# char -> int
  #v0_: `       {push [format %c [pop]]}       tcl  ;# int -> char

  v0_: char2int   {push [scan [pop] %c]}         tcl  ;# char -> int
  v0_: int2char   {push [format %c [pop]]}       tcl  ;# int -> char

  #--------------------------------------------------------------

  v0_: and     {2op &&}                       tcl
  v0_: at      1 - swap {push [lindex [pop] [pop]]} tcl

  v0_: choice  {choice [pop] [pop] [pop]}     tcl
  v0_: cleave  {cleave [pop] [pop] [pop]}     tcl
  v0_: cons    {push [linsert [pop] 0 [pop]]} tcl

  v0_: dup     {push [set x [pop]] $x}        tcl

  #v0_: dupd    {push [lindex $::joy_ST end-1]}    tcl - неверно
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

  # ::quote_in_pop ?
  #if {! $::quote_in_pop} {
  #v0_: pop     {quote pop}                  tcl
  v0_: pop     {eval pop}                  tcl
  #}
  # а вот JOY-процедура push не нужна, не имеет смысла, поскольку
  # мы ее вызываем только из TCL-функции !?

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

  v0_: succ 1 +
  v0_: pred 1 -

  #v0_: product 1 (*) fold
  v0_: product 1 {nop *} fold

  #v0_: reverse {} swap (swons) step
  v0_: reverse  {} swap {nop swons} step

  v0_: sign  {0 >}  {0 <} cleave -

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
  v0_: ~      {} tcl    ;# пустышка  !!!!! - и так получается
  
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
    
    #v0_: pop     {quote pop}                  tcl
    #if {$::quote_in_pop} {
      #
    #  set element [eval $element] ;# !!??
      #return [eval $element]
    #}

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

  # ---------------------------------------------

  v0_: neg   0 swap - 1.0 *

  #r c  1 2 9 {~ +} dip  .s 

  v0_: dip  {
    set cmd [pop ]    ;# команда или список команд
    set tmp [pop ]    ;# 2-й элемент, который временно пропускаем

    lappend code    $cmd i $tmp  ;# составили подпрограмму i - может и список выполнить

    # вопрос - а если item был квотированной программой, два разных варианта?
    # для группы квота останется, а для едиинчного элемента изчезнет в итоге?
    #puts stderr "dip: code = $code"
    
    eval r   $code
  }  tcl  

  v0_: dupd    ~dup  dip       ;# A B   -> A A B
  v0_: swapd   ~swap dip       ;# A B C -> B A C
  v0_: dup2     dupd dup swapd ;# A B   -> A B A B 


#   v0_: null  {
#     set t    [pop ]          ;# верхний элемент
    
#     if {$t == 0} {
#       push 1
#     } else {
#       push 0
#     }    
#   }  tcl  

  v0_: DEBUG  {
    puts "debug, stack = $::joy_ST"
   }  tcl  


  v0_: null  {
    set t    [pop ]          ;# верхний элемент
    push $t
    
    if {$t == 0} {
      push 1
    } else {
      push 0
    }    
  }  tcl  


  v0_: linrec  {

    #puts "stack = $::joy_ST"

    set 4_part [pop ]
    set 3_part [pop ]
    set 2_part [pop ]
    set 1_part [pop ]

    #puts ".... $1_part , len = [llength $1_part]"
    #puts ".... $2_part , len = [llength $2_part]"
    #puts ".... $3_part , len = [llength $3_part]"
    #puts ".... $4_part , len = [llength $4_part]"

    eval r  $1_part i   ; set ret [pop]

    if $ret {
      #puts "...1"
      eval r  $2_part i

    } else {
      #puts "...2"

      eval r  $3_part i   
      #puts ".... $1_part $2_part $3_part $4_part"
      r  $1_part $2_part $3_part $4_part linrec  ;#  !!! не надо eval, которая
      # убивает группы !!!! 
      eval r  $4_part i
    }

  }  tcl  



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
  r c   ~3  i .s  ;# вроде работает


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

  #? {r c  1 2 dupd}                   {1 2 1} - это неверно
  ? {r c  1 2 dupd}                   {1 1 2}
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

  #TEST_vars 

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
# 
# 
#-------------------------------------------------------------------------------
proc joy->v2-list data {

  set data_string [joy-tokenize-no-comments [string range $data 1 end-1]]
  set len [llength $data_string]

  #puts "data_string = $data_string"
  #puts "len = $len"

  # если группа из одного элемента, то обрабатываем особым способом

  if {$len == 1} {
    #return ~$data_string
    return [list ~ $data_string]
  }

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
proc run_joy_as_v1 {text_joy} {

  set ndict [joy-compile_to_namecodedict \
                $text_joy \
                "joy_functext_to_v1_code"]


  set v1_src [dict get $ndict {}]

  run_v1_src  $v1_src 

}
#-------------------------------------------------------------------------------
#
# f~.tl 1111 TEST_00_to_11
# 
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



  puts ""
  puts "text_1 = $text_1"
  puts ""

  # скомпилируем исходный текст в выходной формат
  #
  set ::print_defines 1

  v1_init_all       ;# разные ништяки

  #v0_set_stack_null 
  
  v0_: string_split   swap explode swap split  implode swap implode swap 
  v0_: string_filter  string_split swap pop



  set ndict [joy-compile_to_namecodedict \
                $text_1 \
                "joy_functext_to_v1_code"]

  puts ""
  puts "ndict = $ndict"
  puts ""

  set v1_src [dict get $ndict {}]

  puts ""
  puts "v1_src = $v1_src"
  puts ""

  run_v1_src  $v1_src 

  # ------------------------------
  # и еще раз одной процедурой
  # 
  puts ""

  run_joy_as_v1  $text_1

}
#-------------------------------------------------------------------------------
  # может слишком усложнена иерархия, не нужно для процедур src ?????????
  # а может нужны все же ссылки на тексты? или ссылки на подпрограммы ???

#-------------------------------------------------------------------------------
proc v1_get_main_src {prog} {

  if [is_GLOBAL_DICT $prog] { 
    # это была ссылка на словарь
    set prog [set $prog] ;# сам словарь
  } 

  # получим  "исходник" главной программы
  # 
  set src [prog_get_prg_src $prog "main"]

  return $src;
}
#-------------------------------------------------------------------------------
proc run_v1_prog {prog} {


  #if [is_GLOBAL_DICT $prog] { 
  #  # это была ссылка на словарь
  #  set prog [set $prog] ;# сам словарь
  #} 

  # получим  "исходник" главной программы
  # 
  #set src [prog_get_prg_src $prog "main"]

  set src [v1_get_main_src $prog]


  biblio_push $prog ;# запихнуть "локальную библиотеку" в стек библиотек
                       # (в данном случае - это сама программа)

  set err_index [run_v1_src $src]     ;# выполнить исходник

  biblio_pop        ;# убрать библиотеку из стека  

  return $err_index
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

# j~.tl 1111 TEST_convert_joy_to_11

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

  set ::rr_errorprint 1

  run_v1_src  {progtest1}

}
#-------------------------------------------------------------------------------
proc v1_get_result_from_one_arg {prg_11 val} {

  # кладем одно значение в стек
  # 
  push $val 

  # выполняем программку
  # 
  #run_v1_src_or_prog $prg_11 ;### $prog_11

  run_v1_src $prg_11
  #r {*}$prg ;# раскроим список и выполним последовательность команд

  # забираем одно значение из стека
  # 
  set result [pop]


  return $result
}
#-------------------------------------------------------------------------------
proc test_joy_savestack {} {


  v1_init_all  ;# !!!!!!!!!!! ???

  # флажки отладочной печати
  set ::rr_errorprint 1
  
  # set ::rr_is_restore 1 ;# пропускаем ошибочный оператор
  

  #set proga "+ + + dup *"
  #set proga "+ dup * + + "

  set proga "11 12 + + +"

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
proc TEST_vars {} {

  puts ""
  puts "TEST_vars ..."
  puts ""
  
  v1_init_all 
  
  #-------------------------------------


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

  puts ""
  puts "-------------------------------"
  puts ""

  # 
  # флажки отладочной печати
  set ::rr_errorprint 1

  r c  10 20  =bb =aa  @bb .

  puts "::aa = $::aa"
  puts "::bb = $::bb"

  # r_error_print2: err = invalid bareword "continue"
  # in expression "continue";
  # should be "$continue" or "{continue}" or "continue(...)" or ...
  #                 ST = 10, ST_save = , a = =bb
  
  set ::rr_errorprint 0

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# r~.tl TEST test_joy_savestack
# j~.tl 1111 TEST_1111
# j~.tl 1111 TEST_vars
#
################################################################################



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#source "j-2222.tl"
#-------------------------------------------------------------------------------


# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
if [info exists ::J_2222_TL] {
  return
} else {
  set  ::F_2222_TL "this module loaded"
}

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
proc 2222_TEST_lnew {} {

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
proc 2222_TEST_more {} {

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
proc 2222_TEST_simp_BE {} {

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

  puts ""
  puts "-------------------------------------"
  puts ""

  DebugOn

  set_BEG_END  ( )

  run_v2_src {c  ( 1 2 )  dup . . } 

  #puts ""
}
#-------------------------------------------------------------------------------
# BE: уходим от синтаксиса Tcl к "плоскому" списку BEG_END
#-------------------------------------------------------------------------------
proc 2222_TEST_list_BE {} {

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
proc 2222_TEST_simp {} {

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


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
