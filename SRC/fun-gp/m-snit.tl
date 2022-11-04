# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------



#-------------------------------------------------------------------------------

# пока пусть все установлено будет в стандартных  местах
# 
#set auto_path [linsert $auto_path 0 "O/tcl-tk/tcllib/1.15/snit"]


#set auto_path [linsert $auto_path 0 "../s"] ;# нет, так не работает!
# Always use an absolute path, not a relative one. ??

package require snit

#-------------------------------------------------------------------------------
snit::widget MINEXAMPLE {
  
  delegate option  * to hull
  component  main

  #...........................................
  constructor {args} {

    bind $win <Configure> [mymethod YDRAW %x %y %w %h]
    $self configurelist $args
  }
  #...........................................
  method YDRAW {xx yy ww hh} {

    
    set space 10
    
    set x $space
    set y $space
    set w [expr $ww - 2 * $space]
    set h [expr $hh - 2 * $space]

    INSTALL  main  "frame"  {-bg "yellow"}  ;# установка локально
    YPlace  $main  $x $y $w $h 
  }  
  #...........................................
  
}
#-------------------------------------------------------------------------------
# WHAT DOES THE INSTALL COMMAND DO?

# The install command creates an owned component using a specified command, and 
# assigns the result to the component's instance variable. For example:

# snit::type dog {
#     component mytail

#     constructor {args} {

#         # set mytail        [tail %AUTO% -partof $self]
#         install mytail using tail %AUTO% -partof $self

#         $self configurelist $args
#     }
# }

# In a snit::type's code, the install command shown above is equivalent to the 
# set mytail command that's commented out. 
# In a snit::widget's or snit::widgetadaptor's, code, however, the install command 
# also queries 
# THE TK OPTION DATABASE and initializes the new component's options accordingly.
 
# For consistency, it's a good idea to get in the habit of using install for 
# all owned components. 

#-------------------------------------------------------------------------------
macro INSTALL {compname snitwidget args} {


  set fullname $win.$compname

  set cmd [list install $compname using $snitwidget $fullname]
  set cmd_full [concat $cmd $args]

  if {! [winfo exists $fullname]} {

    eval $cmd_full
  }

  # это важно! а иначе в какой-то бесконечный тупор впадаем !
  # 
  unset fullname
  unset cmd
  unset cmd_full

}
#-------------------------------------------------------------------------------
proc SnitBigWindow {next_name nextfid  xx yy ww hh title} {

  wm withdraw . ;# спрячем лишнее?


  # создали SNIT-окно
  # 
  #$next_name  $nextfid  $xx $yy $ww $hh  -bg "red" ; !!!! надо цвет пеердавать
  $next_name  $nextfid  $xx $yy $ww $hh ;

  wm geometry $nextfid  ${ww}x${hh}+$xx+$yy

  wm    title $nextfid  $title

  return
}
#-------------------------------------------------------------------------------
proc YToplevelBindConfigure {fid proc_name} {

  #set ::Warr($fid) 0
  #set ::Harr($fid) 0

  #YInitWH  $fid
  BigWH_init  $fid

  bind $fid <Configure> [list  $fid $proc_name  %x %y %w %h]
  
  # но почему-то вызывает еще и дочерние окна на начальном этапе создания!
  # поэтому надо их отсекать по этапе приема !

  return
}
#-------------------------------------------------------------------------------
snit::widget MODMAP {
#-------------------------------------------------------------------------------
  
  delegate option  * to hull

  component  buthome
  component  buttext
  component  butback

  component  winmain ;# - нужен ли здесь этот непонятный черный пустой фрейм?
                      # да !! нужен для симметрии !!
  component  win_00

  variable bot_x 
  variable bot_y
  variable bot_w 
  variable bot_h
  variable curent_fid
  variable list_frames

  #...........................................
  constructor {args} {

    set list_frames {}

    bind $win <Configure> [mymethod YDRAW %x %y %w %h]

    $self configurelist $args
  }
  #...........................................
  #method YDRAW {xx yy ww hh} {}
  method YDRAW {x y w h} {

    set h_control 30
    
    set fid $self
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    set top_x 0
    set top_y 0
    set top_w $w
    set top_h [expr $h_control + 2]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    set x1   1
    set y1   1
    set w1  80
    set h1  $h_control
    
    #YButtonPlace $fid.buthome "HOME"  $x1 $y1 $w1 $h1 -command "modmap_to_home"
    INSTALL  buthome  "button"  {-text "HOME" -command [mymethod button_home_proc]}
    YPlace  $buthome  $x1 $y1 $w1 $h1 
   
    set x2  [expr $x1 + $w1 + 1]
    set y2  $y1
    set w2  [expr $w - $w1 * 2]
    set h2  $h1
    
    #YLabel $fid.buttext "главное окно" $x2 $y2 $w2 $h2  -bg "cyan"
    INSTALL  buttext  "label"  {-text [koi_to_utf "главное окно"] -bg "cyan"}
    YPlace  $buttext  $x2 $y2 $w2 $h2 
    
    
    set x3  [expr $x2 + $w2 + 1]
    set y3  $y1
    set w3  [expr $w - $x3 - 1]
    set h3  $h_control
    
    #YButtonPlace $fid.butback ".."    $x3 $y3 $w3 $h3
    INSTALL  butback  "button"  {-text ".." -command [mymethod button_prev_proc]}
    YPlace  $butback  $x3 $y3 $w3 $h3 
    
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # это как раз место для отображения рабочих окошек
    # 
    set   bot_x [expr $top_x + 1]
    set   bot_y [expr $top_y + $top_h ]
    
    set bot_w   [expr $w - 2]
    set bot_h   [expr $h - $bot_y - 1]
    
    #YFrame  $::bot_fid  $bot_x $bot_y $::bot_w $::bot_h  "black"  ;# пустая основа
    INSTALL  winmain  "frame"  {-bg "yellow"}
    YPlace  $winmain  $bot_x $bot_y $bot_w $bot_h 
    
    set curent_fid $winmain
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # здесь устанавливаем основное домашнее окно:

    $self button_home_proc
  }  
  #...........................................
  method button_home_proc {} {
   
    # ??????????????????????
    # 
    INSTALL  win_00  "SENS_HOME"  {-bg "orange" } 

    $self open_frame $win_00
  }
  #...........................................
  method button_prev_proc {} {
   
    puts "list_frames = $list_frames"

    # надо обрезать последний элемент ??
    # 
  }
  #...........................................
  method open_frame {fid} {
   
    # компонент (окно-фрейм snit) создается 
    # 
    #puts "open_frame : fid = $fid"

    YPlace  $curent_fid  0 0 0 0 ;# просто свернем в точку
    YPlace  $fid         $bot_x $bot_y $bot_w $bot_h 

    set      curent_fid  $fid
    lappend  list_frames $fid
  }
  #...........................................
  #...........................................

  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc SnitWnd {fid compName snitwidget  x y w h  args} {

  #set win $fid

  #INSTALL $compName  $snitwidget {-bg "green"}
  #YPlace  $compName  $x $y $w $h

  #return - нет, такое не пройдет !!
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {! [winfo exists $fid]} {
    set cmd [list install $compName using $snitwidget $fid ]
    uplevel $cmd $args
  } 

  upvar  $compName C ;# свяжемся с переменной верхнего уровня
  YPlace $C  $x $y $w $h


  return
}
#-------------------------------------------------------------------------------
proc YPlaceIn {fid  x y args} {

  # по умолчанию считам, что рисуем в рамках родительского (в иерархии) окна:
  # 
  set parent [winfo parent $fid]

  # точно фиксируем начальные координаты, а вот остальное - опционно
  # 
  eval {place $fid -in $parent -x $x -y $y } $args

}
#-------------------------------------------------------------------------------
# TODO:
# - надо бы везед делать install (но это уже для SNIT только) !!
# - более гибко задавать параметры !
#-------------------------------------------------------------------------------
proc YButtonPack {fid text comm args} {

  if {! [winfo exists $fid]} {

    button $fid -text $text -command $comm
  } 

  # надо именно здесь, чтобы и за один (первый) проход отрисовывать!
  # 
  eval {pack $fid}  $args

  return
}
#-------------------------------------------------------------------------------
