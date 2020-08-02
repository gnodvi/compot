# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------


set ::razd_____________________________line \
  "---------------------------------------------------"

#-------------------------------------------------------------------------------
#
#
#-------------------------------------------------------------------------------
proc get_opts_startxterm {} {

  #set x 1200 
  #set w  100 ; #в буквах ;# маловато, уже длинные строки не влазят

  set x 1150 
  set y 500

  set w  110
  set h   30

  #set FNAME "-*-fixed-bold-*-*-*-15-*-*-*-*-*-iso8859-5"
  #SIZES="130x55+2+262"

  # это только для Linux (не QNX)
  # 

  #set color_opts  "-fg RED -bg CYAN"
  set color_opts  "-fg WHITE -bg BLACK -cr yellow"
  set  geom_opts  "-g ${w}x${h}+${x}+${y}"

  set all_opts [concat $geom_opts $color_opts]
  #set all_opts [concat "-fn $FNAME"  $all_opts]
    
  return $all_opts
}
#-------------------------------------------------------------------------------
# это только для Linux (не QNX)
#-------------------------------------------------------------------------------
proc get_opts_startxterm_new {} {


  set color_opts  "-fg WHITE -bg BLACK -cr yellow"

  set w  91 ; #в буквах
  set h  36

  set x 1060
  set y  500

  set  geom_opts  "-g ${w}x${h}+${x}+${y}"


  set FNAME "-*-fixed-bold-*-*-*-15-*-*-*-*-*-iso8859-5"

  set all_opts [concat $geom_opts $color_opts]

  set all_opts [concat "-fn $FNAME"  $all_opts]
    
  return $all_opts
}
#-------------------------------------------------------------------------------
proc wait_press_enter {} {

  puts " "
  #puts "is_color_menu = $::is_color_menu "

  puts_rus -nonewline  "ДЛЯ " 

  with_color $::is_color_menu $::SGR_CYAN {
    puts_rus -nonewline  "ЗАВЕРШЕНИЯ " 
  }

  puts_rus -nonewline  "НАЖМИТЕ " 

  with_color $::is_color_menu $::SGR_CYAN {
    puts -nonewline "ENTER: " 
  }
  
  flush stdout  ;# все данные должны быть выведены
  set answer [gets stdin]

  puts " "

}
#-------------------------------------------------------------------------------
proc callmenu_print {menu {is_add_q 1}} {

  set imax 0
  
  
  foreach m $menu {
    set menu_item [lindex $m 0]
    
    # предпологаем, что весь внутренний текст в кодировке KOI8
    set text_koi8 [lindex $m 1]
    
    # здесь текст перекодируется к соответствующей системе:
    #      if {$::OS == "QNX" } {
    #        set menu_text [koi_to_866 $text_koi8] 
    #      } else {
    #        set menu_text [koi_to_utf $text_koi8]
    #      }
    
    #set menu_text [latinica_from_koi8  $text_koi8] 
    set menu_text [koi_to_console  $text_koi8] 
    
    # хотелось также бы получать имя динамически через функцию
    #
    if {[is_proc_exist $menu_text]} {
      set menu_text [eval $menu_text]
    }
    
    # а динамическая подстановка глобальных переменных?
    #
    set menu_text [subst $menu_text]
    
    # подсчитываем максимальную длину итема
    set l_item [string length $menu_item]
    if {$l_item > $imax} {set imax $l_item}
    
    with_color $::is_color_menu $::SGR_CYAN {
      puts -nonewline  "  $menu_item" ;# не добавлять символ конца строки
    }
    
    puts            " - $menu_text"
  }
  
  if {$is_add_q} {

    # добавим в конце меню выхода Q (выровняв на максимальноый итем)
    # 
    set menu_item [format "%*s"  $imax "q"]
    puts " "
    
    with_color $::is_color_menu $::SGR_CYAN {
      puts -nonewline  "  $menu_item"
    }
    
    puts -nonewline " - "
    puts_engrus {"RETURN/EXIT" "ВОЗВРАТ/ВЫХОД"}
    #puts_rus  "ВОЗВРАТ/ВЫХОД"
  }
  

  return
}
#-------------------------------------------------------------------------------
proc call_menu {name menu {is_add_q 1}} {

  set break_flag 0

  while {1} {

    puts $::razd_____________________________line

    puts_engrus -nonewline {"MENU" "МЕНЮ"}  
    puts " ($name) :"
    puts " "
   
    callmenu_print $menu  $is_add_q

    if {$is_add_q} {
      puts $::razd_____________________________line
    }

    puts " "

    # меню напечатали, теперь хотим получить ответ:
    # 
    #puts_rus -nonewline "ВЫБЕРИТЕ "
    puts_engrus -nonewline {"CHOICE " "ВЫБЕРИТЕ "}

    with_color $::is_color_menu $::SGR_CYAN {
      puts_engrus -nonewline {"KEY" "КЛЮЧ"} 
    }

    puts_engrus -nonewline  {" and PUSH " " и НАЖМИТЕ "} 

    with_color $::is_color_menu $::SGR_CYAN {
      puts -nonewline "ENTER: " 
    }

    flush stdout  ;# все данные должны быть выведены
    set answer [gets stdin]
    puts " "
    
    # 
    # 
    if {$is_add_q} {
      if {$answer == "q"}        {set break_flag 1 ; break} 
    } else {
      #
      # по ентеру выходим, только если нет выхода по q
      # 
      if {$answer ==  ""}        {set break_flag 1 ; break} ;# быстрее выходить !
    }

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # получили ответ, теперь сравним его с тем, что есть в менюшке: 
    # но сравнивать надо очищенные от крайних пробелов строки
    # 
    foreach m $menu {

      # почему это тут в цикле?!
      # 
      #if {$answer == "q"}        {set break_flag 1 ; break} ;# а это можно убрать
      #if {$answer ==  ""}        {set break_flag 1 ; break} ;# быстрее выходить !

      set menu_item [string trim [lindex $m 0]]

      #----------------------------------------
      #if {$menu_item == ""} {break}  
      # 
      if {$menu_item != ""} {

        set menu_prog  [lindex $m 2] ;# а если это список?

        if {$answer == $menu_item} {eval {*}$menu_prog  ; break} 
      }
      #----------------------------------------
    }

    if {$break_flag} {break} ;# выход по выбору
    
    if {[info exist ::meun_break_flag] && $::meun_break_flag} {break} 

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }

  set ::meun_break_flag 0 ;# глоюальное управление

  puts " "
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc menu_TESTS {} {

  set menu_list {
      {" 2"  "color_print"      {TEST_color}}
      {" 3"  "array_test"       {array_test}}
      }

  call_menu "maun" $menu_list

}
#-------------------------------------------------------------------------------
proc rand_test {} {

  puts ""
  puts "RAND_TEST"
  puts ""

  set ll {0 0 0 0 1}
  puts "lrand = [lrand $ll]"

  puts ""
}
#-------------------------------------------------------------------------------
proc TEST_menu {} {
  
  global argc argv

  if {$::__JIM__} {
    set_en
  } else {
    set_ru
  }

  if {$argc == 2} { # любой флажок отменит цвет
    set ::is_color_menu 0
    set_en
  }

  set menu_list {
      {" r"  "RAND TEST"        {rand_test}}
      {"  "  "" {}}
      {"st"  "SIMPLE TESTS .."  {menu_TESTS}}
      }

  call_menu "main" $menu_list

}
#-------------------------------------------------------------------------------
# 
# a~.tl TEST_menu
#-------------------------------------------------------------------------------
