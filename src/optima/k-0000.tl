# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
################################################################################
#
# That's it. Stack (list) and Command array are global variables:


#set ::OLD 0

set ::joy_proglist {} ;# будет dict - библиотека процедур

set ::LI {} ;# это должен быть стек, в который будем складывать
#              словари-библиотеки (общая по задаче, локальные по программе)
#


# список, заполняемый процедурой [v0_make_tclproc] 
#
set ::joy_tcl_list {}  ;# TCL-процедуры с префиксами ? или без ?
                        # вообще бы от него отказаться?

set ::joy_ST {}  ;# The VM stack



#set ::NEW 1 ;# ???!!!

#-------------------------------------------------------------------------------
proc joy_init {} {


  set ::joy_proglist [dict_create]

  #if {$::NEW} {

  librarys_push $::joy_proglist ;# запихнуть указатель на СИСТЕМНУЮ библиотеку 
                                   # в стек библиотек
  #}

  return
}
################################################################################
#-------------------------------------------------------------------------------
# Определение Joy-процедуры; 
# тело (body) задается в виде списка.
#
#-------------------------------------------------------------------------------
proc v0_:_prg {name body} {


  # TODO: слишком простая схема, нужна структура [list "src" $body]
  # 

  dict_set $::joy_proglist $name "src" $body

  return
}
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
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
proc librarys_push args {
  
  foreach a $args {lappend ::LI  $a}
  
  return
}
#-----------------------------------------------------------------------------
proc librarys_pop {} {
  
  set element [ K [lindex $::LI end] [set ::LI [lrange $::LI 0 end-1]] ]
  
  return $element
}
#-------------------------------------------------------------------------------
proc v0_find_prg_in_librarys {instr} {


  # перебираем все библиотеки в списке, начиная с верхушки стека
  # 

  foreach lib [lreverse $::LI] {

    set lib [dict_get_D $lib] ;# уитывая возможный указатель на словарь


    dict for {key value} $lib {

      if {$key == "main"} {continue} ;# TODO: не должно быть в библиотеке

      if {$key == $instr} {

        #return $value
        return [dict get $value "src"]

      }
    }
            
  }

  return {}
}
################################################################################
#-------------------------------------------------------------------------------
proc v0_make_tclproc {name  arglist body} {


  lappend ::joy_tcl_list $name   ;# добавить имя в список инструкций
  
  proc $name $arglist $body ;# создать процедуру (средствами Tcl) 

}
#-------------------------------------------------------------------------------
proc v0_make_tclproc_alias {aliasname realname} {


  lappend ::joy_tcl_list $aliasname   ;# добавить имя в список инструкций

  alias $aliasname $realname

}
#-------------------------------------------------------------------------------
proc v0_make_tclproc_alias_NEW {aliasname realname} {


  lappend ::joy_tcl_list $aliasname   ;# добавить имя в список инструкций

  # ??
  # 
  #alias $aliasname $realname

  interp alias {} $aliasname {} $realname

}
#-------------------------------------------------------------------------------
proc v0_find_tclproc {name} {

  foreach i $::joy_tcl_list {

    if {$i == $name} {

      return $i
    }
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
