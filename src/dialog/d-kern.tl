# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc CanvasMark { x y w } {

  puts "CanvasMark ..............."

  global canvas  
  # Rememer the object and its location

  # puts "CanvasMark ... "

  #set canvas($w,obj) [$w find closest $x $y] ;# список объектов, удовлетворяющих

  set canvas($w,x) $x ;# запоминаем координаты первого нажатия мыши
  set canvas($w,y) $y

}
#-------------------------------------------------------------------------------
proc CanvasDrag { x y w } {

  # Move the current object
  global canvas
  
  puts "CanvasDrag ........ (w= $w)   x= $x y= $y"


  set dx [expr $x - $canvas($w,x)]
  set dy [expr $y - $canvas($w,y)]
  
  if {0} { 
  #     $w move $canvas($w,obj) $dx $dy ;# двигаем объект (в данном случае - картинку)
  #     #
  #     # но тогда надо двигать и все объекты на канвасе !!
  #     #
  #     loops_move_all_drons  $dx $dy ;# нет, это не верное направление !!!
  
  } elseif {1} {
  
  #     #puts "w = $w  x = $x  y = $y"
  #     #w = .f1.c.canvas  x = 42  y = 91
  
  #     #$w  xview moveto $fraction - надо предварительно посчитать 
  #     #$w  xview scroll [expr - $dx] units

  $w config -xscrollincrement 1
  $w config -yscrollincrement 1

  #$w  xview scroll  +1 units ;# xScrollIncrement
  $w  xview scroll  [expr - $dx] units 
  $w  yview scroll  [expr - $dy] units 
  
  #     #${fid_parent}.c.canvas xview moveto .35 ;# как процент окна будет нвидим слева
  #     #${fid_parent}.c.canvas yview moveto .35 ;# как процент окна будет нвидим вверху  

  } else {
  
    set allobjlist [$w find withtag "all"] ;# список всех объектов
    
    #puts "allobjlist = $allobjlist"
    
    foreach obj $allobjlist {
      
      $w move $obj $dx $dy ;# двигаем объект
    }
  }
  
  set canvas($w,x) $x
  set canvas($w,y) $y

  return
}
#-------------------------------------------------------------------------------
# this sets up the canvas that displays everything on the map
#-------------------------------------------------------------------------------
proc ScrolledCanvas_NEW {c region {color "cyan"}} {

  #set w_reg [lindex $region 2] ;# 1359
  #set h_reg [lindex $region 3] ;# 1836


  frame $c ;# -bg red -bd 3 - цвет фона и ширина полей
  
  #-----------------------------------------------------

  scrollbar $c.xscroll -orient horizontal -command [list $c.canvas xview]
  pack $c.xscroll -side bottom -fill x

  scrollbar $c.yscroll -orient   vertical -command [list $c.canvas yview]
  pack $c.yscroll -side  right -fill y


  # а начальные координаты ???
  # смысла в размерах нет, поскольку потом укладывет на всё внешнее окно
  #
  canvas $c.canvas \
    -scrollregion $region \
    -xscrollcommand [list $c.xscroll set] \
    -yscrollcommand [list $c.yscroll set] -bg $color

  pack $c.canvas  -side   left -fill both -expand true

  #-----------------------------------------------------
  # укладываем на весь размер !!  
  #
  pack $c         -side    top -fill both -expand true
  
  #-----------------------------------------------------

  #$c.canvas bind movable <Button-1>  {CanvasMark %x %y %W}
  #$c.canvas bind movable <B1-Motion> {CanvasDrag %x %y %W}
    
  bind $c.canvas <Button-1>  {CanvasMark %x %y %W}
  bind $c.canvas <B1-Motion> {CanvasDrag %x %y %W}
  
  
  return $c.canvas
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# MODMAP   MODMAP   MODMAP   MODMAP   MODMAP   MODMAP   MODMAP   MODMAP   MODMAP 
#  
#-------------------------------------------------------------------------------
# proc modmap_fid_from_name {mod_name} {

#   set l_mod_name [string tolower $mod_name]

#   set fid  $::bot_fid.${l_mod_name} ;# именя окошек 

#   return $fid
# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Вспомогательная процедурка для трюка со списками.
#
proc K {a b} {set a}

#-------------------------------------------------------------------------------
# proc modmap_stack_create {mop} {

  
  set ::modmap_ST {}  ;# The MODMAP stack


# }
#-------------------------------------------------------------------------------
proc modmap_stack_push args {

  # что мы будем сохранять? 
  # 
  # имя процедуры? - но оно же может использоваться многократно в рамках атласа?
  # fid окна ? 
  # mop модуля?

  # An atlas is a collection of maps !  YMODATLAS  ?

  foreach a $args {lappend ::modmap_ST  $a}

}
#-------------------------------------------------------------------------------
proc modmap_stack_pop {} {
  
  set element [ K [lindex $::modmap_ST end] [set ::modmap_ST [lrange $::modmap_ST 0 end-1]] ]
  
  return $element
}
#-------------------------------------------------------------------------------
proc modmap_go_up {} {


  puts "modmap_go_up (BEG):   ::modmap_ST = $::modmap_ST"

  if {[llength $::modmap_ST] == 1} {return}


  modmap_stack_pop ;# убрали с верха последний элемент, т.е. имя текущего окна

  set map_proc [modmap_stack_pop] ;# имя предпоследнего куда надо идти

  puts "modmap_go_up (MID):   ::modmap_ST = $::modmap_ST, map_proc = $map_proc"

  #if {$map_proc != ""} {
  modmap_draw_name_NEW $map_proc
  #}

  puts "modmap_go_up (END):   ::modmap_ST = $::modmap_ST"

  return
}
#-------------------------------------------------------------------------------
proc modmap_go_home {} {


  #modmap_draw_name_NEW  [WIN_get $::modmap_fid "modmap_home_proc"]

  #return

  # TODO: а лучше по стеку поработать !!
  #

  set home_proc [lindex $::modmap_ST 0]
  
  set ::modmap_ST [list $home_proc] ;# принудительно установили новый стек

  modmap_draw_name_NEW  $home_proc


  return
}
#-------------------------------------------------------------------------------

#set ::NEW 0;# 0 or 1

#-------------------------------------------------------------------------------
proc modmap_draw_name_NEW {map_proc {newmap_name ""}} {


  if {$newmap_name == ""} {
    # 
    # делаем имя (суфикс) по имени процедуры? 
    # 
    set newmap_name [string tolower $map_proc]  
  } 


  set modmap_fid $::modmap_fid ;# а может нужно имя модуля, а не окна?

  # придумаем новое имя (относительное)
  # 

  #if {$::NEW} {
  #  set can [WIN_get $modmap_fid "modmap_canvas"]
  #  set new_fid $can.$newmap_name ;# делаем полный ID    
  #} else {

  set new_fid ${modmap_fid}.f.$newmap_name ;# делаем полный ID
  #}

  set color "red" ;#??


  modmap_begin $modmap_fid
  YWnd            $new_fid $map_proc "" 0 0  $::bot_w $::bot_h  0 0 0 0 -color $color
  modmap_final $modmap_fid


  modmap_stack_push  $map_proc


  return
}
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc YMODMAP {mop from message mes1 mes2 mes3 mes4  args} {


  puts "YMODMAP:   message = $message"

  metaswitch -- $message {

  "YCREATE" {

    SET $mop "modmap_home_proc" $mes4 ;# TODO: нужно создать стек и положить в него первым

    #puts "YMODMAP:  YCREATE !!!!!!!!!!!!!!!!!!!"

    #modmap_stack_create $mop
    #modmap_stack_push   $mop $mes4 ;# процедура/карта нулевого уровня (HOME)?
  }
    
  "*" * {
    set fid [FID $mop]

    #puts "***** fid = $fid"

    set x $mes1
    set y $mes2
    set w $mes3
    set h $mes4
    set color [GET $mop "color"] 

  }

  "YOPEN" + {

    YPlaceCanvas $fid $x $y $w $h  -bg "green" ;# $color ;# 

    puts "YMODMAP:  YOPEN ......................."
    #metabreak

  }
  "YDRAW" {

    puts "YMODMAP:  YDRAW ......................."


    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #set fidparent "" ;# для топлевела
    #set fid .m
    
    set h_control 30
    
    set top_x 0
    set top_y 0
    set top_w $w
    set top_h [expr $h_control + 2]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    set x1   1
    set y1   1
    set w1  80
    set h1  $h_control
    

    YCanvasButton $fid.buthome "HOME"  $x1 $y1 $w1 $h1  -command "modmap_go_home"

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set x2  [expr $x1 + $w1 + 2]
    set y2  $y1
    set w2  [expr $w - $w1 * 2]
    set h2  $h1
    
    YCanvasLabel $fid.buttext "главное окно" $x2 $y2 $w2 $h2  -bg "cyan"
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    set x3  [expr $x2 + $w2 + 2]
    set y3  $y1
    set w3  [expr $w - $x3 - 2]
    set h3  $h_control
    
    YCanvasButton $fid.butback ".."    $x3 $y3 $w3 $h3 \
                               -command [list modmap_go_up]
        
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # теперь займемся основной частью !??

    #

    set ::bot_x  [expr $top_x + 1]
    set ::bot_y  [expr $top_y + $top_h ]
    
    set ::bot_w  [expr $w - 2]
    set ::bot_h  [expr $h - $::bot_y - 1]
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    #
    set ::modmap_fid  $fid  

    #if {$::NEW} {

    #  set xx $::bot_x
    #  set yy $::bot_y
    #  set ww $::bot_w ;# [WND_w $fid]
    #  set hh $::bot_h ;# [WND_h $fid]
      
    #  set marg  10
    #  set mar2  [* $marg 2]

    #  #-----------------------------------------------
    #  YCanvasFrame       $fid.f  $xx $yy $ww $hh  "black" 

    #  # надо бы ту "скользящий канвас"
    #  # а нужны ли здесь размеры, если он во во фрейме растягивается?
    #  #
    #  set can [ScrolledCanvas_NEW $fid.f.c  [list 0 0 1000 1000]] 
    #  #-----------------------------------------------

    #  SET $mop "modmap_canvas" $can
    #  modmap_draw_name_NEW  [WIN_get $fid "modmap_home_proc"] 

    #} else {

    #YPlaceFrame  $fid.f ...  - можно и так и так?
    #
    YCanvasFrame   $fid.f  \
      $::bot_x $::bot_y  $::bot_w $::bot_h ;# "black" 
    
    # возможно, что фрейм лишний, ну или хотя бы цвет отключить!
    # 
   
    modmap_draw_name_NEW  [WIN_get $fid "modmap_home_proc"] 
    #}
      
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
  } ;# YDRAW 
  } ;# metaswitch 
  

  return
}
#-------------------------------------------------------------------------------     
proc modmap_begin {fid} {
  

  set ::modmap_fid  $fid  

}
#-------------------------------------------------------------------------------     
proc modmap_final {fid} {
  

  # TODO:
  # 
  #unset ::modmap_fid   


}
#-------------------------------------------------------------------------------     
proc YWndModmap {fid  x y w h home_proc} {
  

  puts "YWndModmap ..... ??????????? -message YDRAW  ????????"

  modmap_begin $fid

  YWnd   $fid  YMODMAP "" \
    $x $y $w $h   0 0 0 $home_proc  -color "lightblue" ;#  -message YDRAW ;#  ?? 

  modmap_final $fid



  #     YWndOpen   $fid.modmap  YMODMAP "" \
  #       10 10 [expr $w - 20] [expr $h - 20]   0 0 0 "HOMEMAP_proc"  -color "lightblue"
  
  # хочу рисовать (YDRAW) окошко в уже готовый фрейм 
  # а реально ли это ????????????? видимо это не просто фрейм, а окошко уже
  # со своей оконной функцией?
  #
  
#   #YWndDraw   $fid  YMODMAP "" \
#     \#  10 10 [expr $w - 20] [expr $h - 20]   0 0 0 "HOMEMAP_proc"  -color "lightblue"
  
}
#-------------------------------------------------------------------------------
# -> v_16sc.tk
#-------------------------------------------------------------------------------
proc MapButton {fid  name x y w h page_proc color {newmap_name ""}} {

  upvar fid fid_parent ;# верхняя переменная <-> локальная


  if {$fid == ""} { ;# нам не задали конкретное имя

    set fid [make_child_name $fid_parent] ;# придумали по родительскому

  } else {
  }

  # TODO: надо сделать, как у меня было в Yzone, т.е. созданное по
  #       требованию имя, нужно  пеерзаписать в переменную, чтобы при
  #       повторном вызове оно взялось ??

  #puts "MapButton: fid_parent = $fid_parent  child_name = $child_name"

  set cmd [list modmap_draw_name_NEW $page_proc $newmap_name]

  YCanvasButton  $fid $name \
     $x $y $w $h    \
     -command $cmd  \
     -activebackground $color -relief "solid" 

  return
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

