# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#

set COMPOT "./COMPOT"  ;# "../compot"


set auto_path [linsert $auto_path 0 $COMPOT]

#lappend auto_path \
  [file join [file dirname [info script]] "./COMPOT"] 


#package require compot::common 1.0
package require compot::common 

#-------------------------------------------

#source "COMPOT/common/a-comp.tl"

source "g-graf.tl"

source "e_meta.tl"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc tao_draw_PLOT {tao} {


  set plot [tao_prepare_and_draw_plot_to_console $tao]

  set is_gnu [GET $tao "IS_GNU"]

  if {$is_gnu} {
    
    draw_plot_to_gui $plot
  }

  return
}
#-------------------------------------------------------------------------------
proc tao_draw_GUI {tao} {


  #set plot [tao_prepare_PLOT $tao]
    
  set plot [GET $tao "P_LOT"]

  draw_plot_to_gui $plot

  return
}
#-------------------------------------------------------------------------------
proc tao_file_draw_plot {flag} {


  MAKE_GLOBAL_NAME_set_timed ;# временные метки в глобальные имена

  # наверное это имя файла разреза
  # 
  source "$flag"
  
  tao_draw_PLOT $TAO 
  
  #       set plot [tao_prepare_PLOT $TAO]
  
  #       plot_print_one_NEW $plot 0      
  #       puts ""
  #       puts ""
  
  #       plot_save_NEW  $plot "./t_save.pl"    
  #       run_command "COMPOT/common/d_plot.tk 6" ;# отдельной программой!
  
}
#-------------------------------------------------------------------------------
proc tao_file_next_calc {file} {


  set ::is_meta_saving 1 ;# запуск теста с сохранением разрезов!
  
  # надо запустить адлее тест с сохраненной точки !!
  # 
  
  MAKE_GLOBAL_NAME_set_timed ;# временные метки в глобальные имена
  
  source "$file"
  
  tao_loop_MAIN $TAO  ;# ОСНОВНОЙ ЦИКЛ !!!!!!!!!!!!!!
 
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc kill_draw_PLOT {} {

  #run_command "killall tclsh" ;# убивает всех, в том числе и саму главную прогу !

}
#-------------------------------------------------------------------------------
proc exit_proc {} {

  #puts ""
  #puts ""

  run_command "killall tclsh" ;# убивает всех, в том числе и саму главную прогу !

}
#--------------------x-----------------------------------------------------------
proc tao_moretest {tao} {

  set ::skip_simple_menu 0

  puts ""
  puts "tao_moretest ..."
  puts ""

  tao_loop_MAIN $tao

  return
}
#-------------------------------------------------------------------------------
proc tao_main_menu {tao} {


  flush stdout  ;# все данные должны быть выведены
  flush stderr  ;# 

  set menu_list {}

  lappend menu_list   [list " d"  "DRAW PLOT" [list tao_draw_GUI $tao]]

  lappend menu_list   {"  "  "" {}} ;# ???? как то это мешает дальше двигаться!!

  lappend menu_list   [list " m"  "MORE TEST" [list tao_moretest $tao]]

  call_menu "mainmain" $menu_list

  return
}
#-------------------------------------------------------------------------------
proc MAIN_NEW {} {


  set command  "test"  ;# по умолчанию
  set prog    "loop1"

  global argc argv arg0

  if {$argc > 0}  {set command [lindex $argv 0]}

  switch -- $command {

    "test"   {

      if {$argc > 0} {set prog [lindex $argv 1]}
      
      set ::NEW 1 ;# побольше и получше печатаем про граф
      
      set tao [$prog] ;# вызываем саму программу инициации/выполнения, 
                       # возвращаем разрез, 
                       # в нем уже будет будет основная функция выполнения,
      # которую потом можно будет повторить

      tao_main_menu $tao  
    }

    "calc"   {

      if {$argc > 0} {set prog [lindex $argv 1]}

      MAKE_GLOBAL_NAME_set_timed ;# временные метки в глобальные имена
      set ::is_meta_saving 1 ;# запуск теста с сохранением разрезов!
  
      set nn    300  
      set nums  300 

      $prog  $nn $nums
    }

    "plot"   {
      set file [lindex $argv 1]
      tao_file_draw_plot $file
    }

    "next"   {
      set file [lindex $argv 1]
      tao_file_next_calc $file
    }


  }

  return
}
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------

#MAIN

MAIN_NEW

# -------------------------------------------------------------------------------

# t_test.tl test loop0

# TODO: 
#
# - для невзаимодействующего распараллеливания и, возможно, выполнения законов
#   сохранения можно использовать выч.модель "шахматной доски", т.е., например, 
#   сначала работаем с узлами, а потом с ребрами!
#
# - расширить понятие графов "стеками" узлов и ребер, и алгоритмически стягивать
#   (копировать) топологическую информацию; может обойтись вообще без чисел?
#
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
