# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#set ::COMPOT ".."

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#
# #define  MULT(x,y)        {x=YInt((x)*(KERN->x_mult)); y=YInt((y)*(KERN->y_mult));}
# #define  ANTIMULTX(x)     {x=YInt((x)/(KERN->x_mult));}
# #define  ANTIMULTY(y)     {y=YInt((y)/(KERN->y_mult));}
# #define  ANTIMULT(x,y)    {ANTIMULTX(x);  ANTIMULTY(y);}

# #define  CALCXY(x,y)      {MULT(x,y);  x=x+(KERN->x0); y=y+(KERN->y0);}
# #define  ANTICALCXY(x,y)  {x=x-(KERN->x0);  y=y-(KERN->y0); ANTIMULT(x,y);}

# #define  CALCWH(w,h)      {MULT(w,h); }
# #define  ANTICALCWH(w,h)  {ANTIMULT(w,h);}


set ::KERN(x0) 0
set ::KERN(y0) 0

set ::Y_IDLAST 0

set ::x0group  0
set ::y0group  0

# /*------------------------------YSetOrigin--------------------------------*/ 
proc \
YSetOrigin {x0 y0} {
 
  set ::KERN(x0) $x0 
  set ::KERN(y0) $y0 

  return 
} 
# /*------------------------------YGetOrigin--------------------------------*/ 
proc \
YGetOrigin {&x0 &y0} {
 
  USE_REFS

  set x0 $::KERN(x0) 
  set y0 $::KERN(y0) 

  return
} 
#-------------------------------------------------------------------------------
proc CALCXY {&x &y} {

  USE_REFS

  incr x $::KERN(x0)
  incr y $::KERN(y0)

}
#-------------------------------------------------------------------------------
#
#
# The W3C maintains a list [1] of "Web-safe" colors.
# KPV - here's that list, along with the closest named Tk color:

#    W3C NAME    RGB        Closest TK color (~ means not an exact match)

#     black     #000000   =>   black
#     silver    #C0C0C0   =>   ~gray75 (or SystemButtonFace on classic Windows)
#     gray      #808080   =>   ~gray50
#     white     #FFFFFF   =>   white
#     maroon    #800000   =>   ~darkred
#     red       #FF0000   =>   red
#     purple    #800080   =>   ~DarkMagenta
#     fuchsia   #FF00FF   =>   magenta
#     green     #008000   =>   ~green4
#     lime      #00FF00   =>   green
#     olive     #808000   =>   ~Gold4
#     yellow    #FFFF00   =>   yellow
#     navy      #000080   =>   navy
#     blue      #0000FF   =>   blue
#     teal      #008080   =>   ~turquoise4
#     aqua      #00FFFF   =>   cyan


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc WND_w {wid} {

  set win $::WINO($wid)

  return  [dict get [set $win] "w"]
}
#-------------------------------------------------------------------------------
proc WND_h {wid} {

  set win $::WINO($wid)

  return  [dict get [set $win] "h"]
}
#-------------------------------------------------------------------------------
proc WND_name {wid} {

  set win $::WINO($wid)

  return  [dict get [set $win] "name"]
}
#-------------------------------------------------------------------------------
proc WND_name_set {wid name} {

  set win $::WINO($wid)

  dict set $win "name" $name

}
#-------------------------------------------------------------------------------
proc WND_prog {fid} {

  set win $::WINO($fid)

  return  [dict get [set $win] "prog"]
}
#-------------------------------------------------------------------------------
proc WND_parent {wid} {

  set parent [winfo parent $wid]

  return $parent
}
#-------------------------------------------------------------------------------
proc WND_color {wid} {

  set win $::WINO($wid)

  return  [dict get [set $win] "color"]
} 
#-------------------------------------------------------------------------------
proc YPaintLine {cid x1 y1 x2 y2 color args} { 

  CALCXY  x1 y1 
  CALCXY  x2 y2 

  eval {$cid create line  $x1 $y1 $x2 $y2 -fill $color}  $args ;# можно так
 
 return 
} 
#-------------------------------------------------------------------------------
proc YDrawLine {cid  x1 y1 x2 y2  color args} { 


  YPaintLine $cid $x1 $y1 $x2 $y2 $color {*}$args ;# а можно и так?
 
  return 
} 
#/*-----------------------------YPaintRectF---------------------------------*/ 
#
proc YPaintRectF {can x y w h f_color} {
 
  #puts "YPaintRectF: x= $x  y = $y"
  CALCXY  x y 
  #   CALCWH (w, h);
  
  #   XSetForeground (DPY, SV->gc, f_color); 
  #   XFillRectangle (DPY, SV->win, SV->gc, x, y, w, h); 
  #   XFlush (DPY); 

  #puts "YPaintRectF: x= $x  y = $y"

  set x1 $x
  set y1 $y

  set x2 [expr $x1 + $w - 1]
  set y2 [expr $y1 + $h - 1]

  # "рисуем" в канвасе (и создаем новый объект, который можно пометить тагом)
  # 
  $can create rect $x1 $y1 $x2 $y2 -fill $f_color

} 
#/*-----------------------------YPaintRectF---------------------------------*/ 
proc \
YDrawRectF {can x y w h f_color} {
 
  YPaintRectF $can $x $y $w $h $f_color

} 
# /*--------------------------------------------------YPaintRectB--------------*/ 
proc  YPaintRectB {cid  x y w h  color} { 

  CALCXY  x y 

  incr w -1 ;#   w--; 
  incr h -1 ;#   h--; 
  
  YDrawLine  $cid $x $y             [expr $x + $w] $y $color
  YDrawLine  $cid $x [expr $y + $h] [expr $x + $w] [expr $y + $h] $color 

  YDrawLine  $cid $x                [expr $y + $h] $x $y $color 
  YDrawLine  $cid [expr $x + $w] $y [expr $x + $w] [expr $y + $h] $color
  
} 
# /*------------------------------YDrawRectB----------------------------------*/ 
proc  YDrawRectB {cid  x y w h  color} { 

  YPaintRectB  $cid  $x $y $w $h  $color
  
} 
# /*------------------------------YDrawRectFB---------------------------------*/ 
proc \
YPaintRectFB {can x y width height fcolor lcolor} {
 
  YDrawRectF  $can  $x $y $width $height $fcolor
  #YDrawRectB  $can  $x $y $width $height $lcolor 

  return 
} 
# /*------------------------------YDrawRectFB---------------------------------*/ 
proc \
YDrawRectFB {can x y width height fcolor lcolor} {
 
  YPaintRectFB $can $x $y $width $height $fcolor $lcolor

  return 
} 
# /*-------------------------------draw_group---------------------------------*/
#
proc draw_group {can sText xx yy ww hh color} {

  YDrawRectFB  $can $xx $yy $ww $hh $color "black" 
  #YDrawRectB  $can $xx $yy $ww $hh "black" 

  set xt [expr $xx + 10]

  YPaintLine   $can $xt $yy [expr $xt + [YStringW $can $sText]] $yy $color

  YPaintString $can $sText $xt $yy "black"
  
  return;
}
# /*-----------------------------begin_group----------------------------------*/
#
proc begin_group  {can name x y w h color} {
      
  #   if (name != NULL) {
  draw_group  $can $name $x $y $w $h $color
  #   }
  
  YGetOrigin ::x0group ::y0group

  #puts "x0group = $::x0group"
  #puts "y0group = $::y0group"

  #CALCWH  x y  ?????

  YSetOrigin [expr $::x0group + $x] [expr $::y0group + $y]
  
}
# /*-------------------------------end_group----------------------------------*/
# 
proc end_group {} {

  YSetOrigin $::x0group $::y0group

}
# /*-----------------------------------YGoto-------------------------------------*/ 
# long 
# YGoto (int message, int mes1, int mes2, long mes3, long mes4) 
##------------------------------------------------------------------------------
proc YGoto {message mes1 mes2 mes3 mes4  args} {
 
  #   YT_PFUNC proc; 
  #   int     id = Y_IDLAST; 
  #   int  from = ID_NULL; 
  
  #   if (IN_WND(id))  proc = WND->proc; 
  #   else  { 
  #     fprintf (stderr, "YGoto: error id = %d \n", id); 
  #     return (YNULL); 
  #   } 
 
  upvar fid fid
  set id $::WINO($fid)

  uplevel {
    # перешли на предыддущий уровень и выполняемся там:

    set list_of_cmds [info level 0] ;# список команд для текущего уровня
    set ::prog_last [lindex $list_of_cmds 0]
  }

  #puts "YGoto: prog = $prog"
  set from "ID_NULL"


  $::prog_last  $id $from $message $mes1 $mes2 $mes3 $mes4  {*}$args

  #   return (CALL (proc, id, from, message, mes1, mes2, mes3, mes4)); 
} 
# /*-------------------------------YSendFrom----------------------------------*/ 
# long 
# YSendFrom (int id, int from, int message, int mes1, int mes2, long mes3, long mes4) 
##------------------------------------------------------------------------------
proc \
YSendFrom {fid from  message mes1 mes2 mes3 mes4  args} { 

  #   long    ret; 
  #   int     old_id_last; 
  #   YT_PFUNC proc; 
  #   YT_BOOL debug = FALSE; 
  
  #   if (id == ID_NULL)  { 
  #     if (debug) fprintf (stderr, "YSend-war: [%d] to ID_NULL \n", Y_IDLAST); 
  #     return (YNULL);   
  #   } 
  #   if (!(IN_WND(id)))  {    
  #     if (debug) fprintf (stderr, "YSend-err: [%d] to [%d] \n", Y_IDLAST, id); 
  #     return (YNULL); 
  #   } 
  #   if (!(WND_CREATED(id))) { 
  #     if (debug) fprintf (stderr, "YSend-err: [%d] to [%d] - not created \n", Y_IDLAST, id); 
  #     return (YNULL); 
  #   } 
  
  #   proc = WNDI(id)->proc;   
  
  #set wnd $::WINS($fid)
  #set prog [$wnd.prog]

  set prog [WND_prog $fid]
 
  #     if (KERN->sys_proc != NULL) YDrawContext (TRUE, id); 
  
  #     old_id_last = Y_IDLAST; 
  #     Y_IDLAST = id; 

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # при переходе в окно обнуляем оригины, посколку у нас окна реальные, со своей
  # нулевой системой координат:
  #
  YGetOrigin x0group  y0group
  YSetOrigin 0 0

  set id $::WINO($fid) ;# mop

  set ret [$prog  $id $from $message  $mes1 $mes2 $mes3 $mes4  {*}$args]

  YSetOrigin $::x0group $::y0group

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #     Y_IDLAST = old_id_last; 
  
  #     if (KERN->sys_proc != NULL) YDrawContext (FALSE, ID_NULL); 
 
 
  return $ret 
} 
# /*----------------------------------YSend----------------------------------*/ 
# long 
# YSend (int id, int message, int mes1, int mes2, long mes3, long mes4) 
#------------------------------------------------------------------------------
proc \
YSend {fid  message mes1 mes2 mes3 mes4  args} {
 
  set from $::Y_IDLAST

  # TODO: система не должна быть привязана к окнам !!
  # 

  if {! [winfo exists $fid]}  {return}
  #
  #if {! [winfo exists $from]} {return}

  return [YSendFrom $fid $from $message $mes1 $mes2 $mes3 $mes4 {*}$args] 
 
} 
#------------------------------------------------------------------------------
proc MSend {mop  message mes1 mes2 mes3 mes4  args} {
 
  set from $::Y_IDLAST

  set prog [GET $mop "prog"]

  return [$prog  $mop $from $message  $mes1 $mes2 $mes3 $mes4 {*}$args]
} 
# /*-------------------------------YPostFrom----------------------------------*/ 
# YT_BOOL 
# YPostFrom (int id, int from, int message, int mes1, int mes2, long mes3, long mes4) 
# { 
#   YT_SVMSG *pBuf; 
 
#   if (KERN_S->q.num == MQ_LENGHT - 2) { 
#     YBeep (); 
#     return (FALSE); 
#   } 
#   pBuf = &KERN_S->q.buf[KERN_S->q.tail]; 
 
#   pBuf->id = id; 
#   pBuf->from = from; 
#   pBuf->message = message; 
#   pBuf->mes1 = mes1; 
#   pBuf->mes2 = mes2; 
#   pBuf->mes3 = mes3; 
#   pBuf->mes4 = mes4; 
 
#   KERN_S->q.num++; 
#   KERN_S->q.tail++; 
#   if (KERN_S->q.tail == MQ_LENGHT) 
#     KERN_S->q.tail = 0; 
 
#   return (TRUE); 
# } 
# /*------------------------------------YPost----------------------------------*/ 
# YT_BOOL 
# YPost (int id, int message, int mes1, int mes2, long mes3, long mes4) 
#-------------------------------------------------------------------------------
proc \
YPost {fid message mes1 mes2 mes3 mes4  args} {
 
  #   int from = Y_IDLAST;   
  #   return (YPostFrom (id, from, message, mes1, mes2, mes3, mes4)); 
 

  # пока пусть будет YSend:
  #
  YSend  $fid $message $mes1 $mes2 $mes3 $mes4  {*}$args

  return
} 
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc YCreateModule {name prog   long1 long2 long3 long4} {
 

  set mop [dict_create]
  
  dict set $mop "name"  $name
  dict set $mop "prog"  $prog

  dict set $mop "long1" $long1
  dict set $mop "long2" $long2
  dict set $mop "long3" $long3
  dict set $mop "long4" $long4

  return $mop
}
#-------------------------------------------------------------------------------
proc WIN_set {fid name value} {


  dict set $::WINO($fid) $name $value 

}
#-------------------------------------------------------------------------------
proc WIN_get {fid name} {


  return [dict get [set $::WINO($fid)] $name]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc FID {fid} {

  set mop $fid
  set fid [GET $mop "fid"]
  return $fid
  
}
#-------------------------------------------------------------------------------
# ButtonPress
# ButtonRelease
# KeyPress
# 
#-------------------------------------------------------------------------------
# proc set_busy {fid} {


#   bind $fid <ButtonPress-1>   {} ;# [list ${prog} $fid FROM "YLMOUSEDOWN" %x %y 0 0]
#   bind $fid <ButtonPress-2>   {} ;# [list ${prog} $fid FROM "YMMOUSEDOWN" %x %y 0 0]
#   bind $fid <ButtonPress-3>   {} ;# [list ${prog} $fid FROM "YRMOUSEDOWN" %x %y 0 0]
  
#   bind $fid <ButtonRelease-1> {} ;# [list ${prog} $fid FROM "YLMOUSEUP"   %x %y 0 0]
#   bind $fid <ButtonRelease-2> {} ;# [list ${prog} $fid FROM "YMMOUSEUP"   %x %y 0 0]
#   bind $fid <ButtonRelease-3> {} ;# [list ${prog} $fid FROM "YRMOUSEUP"   %x %y 0 0]

# }
#-------------------------------------------------------------------------------
proc set_bind {fid mop prog} {


  # 
  # %X %Y - абсолютные координаты
  #
  bind $fid <ButtonPress-1>   [list ${prog} $mop FROM "YLMOUSEDOWN" %x %y 0 0]
  bind $fid <ButtonPress-2>   [list ${prog} $mop FROM "YMMOUSEDOWN" %x %y 0 0]
  bind $fid <ButtonPress-3>   [list ${prog} $mop FROM "YRMOUSEDOWN" %x %y 0 0]
  
  bind $fid <ButtonRelease-1> [list ${prog} $mop FROM "YLMOUSEUP"   %x %y 0 0]
  bind $fid <ButtonRelease-2> [list ${prog} $mop FROM "YMMOUSEUP"   %x %y 0 0]
  bind $fid <ButtonRelease-3> [list ${prog} $mop FROM "YRMOUSEUP"   %x %y 0 0]


}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc YWndFinish {fid} {

  #destroy $fid ;# только внутренность большого фрейма изчезает !!!
  #destroy .big  ;# так работает  WND_parent
  
  set parent [WND_parent $fid]
  
  #puts "YWndFinish ... fid= $fid  parent= $parent"  
  
  # надо его удалить из нашей системы модулей? (и дочерние окна также!)
  # или хотя бы из оконного списка:
  
  # для начала посмотрим какие там вообще имена:
  # 
  set names [reverse [lsort [array names ::WINO]]] ;# сначала дочерние
  
  puts ""
  puts "::WINO = $names"
  puts ""

  foreach name $names {
    puts "name = $name"
    
    if {[string match "${fid}*" $name]} {
      puts "!!"      
      YSend  $name "YClose"  0 0 0 0  

      unset ::WINO($name)        
    }
  }
  
  #unset ::WINO($fid) 
  #unset ::WINO(${fid}.okey) ;# работает, но надо бы автоматически !
  
  destroy $parent ;# удаляем окошко Tk верхнего уровня (вместе с дочерними)
  
  return
}
#-------------------------------------------------------------------------------
proc YWndOpenOrDraw {message fid \
                   prog name x y w h  \
                   w_long1 w_long2 w_long3 w_long4 args} { 
   

  # создаем модуль и записываем на него ссылку в словарь 
  # под именем fid

  set mop [YCreateModule  $name $prog   $w_long1 $w_long2 $w_long3 $w_long4]

  MSend  $mop "YCREATE"  $w_long1 $w_long2 $w_long3 $w_long4  {*}$args

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # теперь займемся окошком гуи

  SET $mop "fid" $fid

  set ::WINO($fid) $mop

  dict set $mop "color" [dict_parse $args "-color"  "lightgreen"]

  dict set $mop "w" $w
  dict set $mop "h" $h

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  # пошлем сообщение для отрисовки либо в уже готовом окне YDRAW
  # либо нужно сначала создать окошко (фрейм)

  #   if {$toopen} {
  
  #     set message "YOPEN"
  #   } else {
  #     set message "YDRAW"
  #   }

  dict set $mop "message" $message ;# запомним

  # если окно будет создаваться внутри процедуры, то надо MSend !
  # 
  MSend  $mop  $message  $x $y $w $h  {*}$args

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # окно fid может быть уже создано (биг-окно, например)Ю а может и нет еще!
  # но, биндинг надо делать уже к готовому окошку
  # 
  # а если это окошко верхнего уровня, то все сообщения пойдут и для
  # дочерних?

  if [winfo exists $fid] { # а то вдруг не созадлось окошко
    
    set_bind  $fid $mop $prog
  }

}
#-------------------------------------------------------------------------------
proc check_is_message {fid args} {


  set message [dict_parse $args "-message"  ""]

  if {$message == ""} {

    # явно не указано, как открывать/рисовать, поэтому по признаку:
    # 
    set win_exist [winfo exists $fid]
    
    if {$win_exist} {
      
      set message "YDRAW" ;# уже открыто окошко с таким именем

    } else {
      set message "YOPEN" ;# еще нет окошка с таким именем
   }
  }

  return $message
}
#-------------------------------------------------------------------------------
proc YWnd {fid prog name x y w h  \
           w_long1 w_long2 w_long3 w_long4  args} { 
   

  CALCXY x y

  set mod_exist [info exists ::WINO($fid)]

  # окно с таким именем уже существует?
  # а может я не хочу создавать новый фрейм, а хочу добавлять в родительский ?
  #
  # надо привязываться не к имени в контексте Tk. а к модулям!?
  # 
  # например уже есть Tk-биг-окно и мы в него хотим писать!
  # но в нашей системе его еще нет!


  set message [check_is_message $fid $args]

  puts "YWnd ($fid): prog= $prog  mod_exist= $mod_exist message= $message"


  if {$mod_exist} {

    set w_old [WIN_get $fid "w"]
    set h_old [WIN_get $fid "h"]

    if {$w_old != $w || $h_old != $h} {
      puts "w_old = $w_old,  w = $w"
      puts "h_old = $h_old,  h = $h"
      puts ""
    }

    raise $fid 

    # надо, конечно, когда ходим между уже открытыми окнами !
    #
    # но "поднимает" только канвасные? и не перерисовываем размеры!!! 
    # пока холст по новой не пееррисовываем! хотя, при желании, можно!
 
  } else {

    YWndOpenOrDraw $message \
      $fid \
      $prog $name $x $y $w $h    \
      $w_long1 $w_long2 $w_long3 $w_long4  {*}$args
  }
  

  return
} 
#-------------------------------------------------------------------------------
proc YWndOpen {fid prog name x y w h  \
           w_long1 w_long2 w_long3 w_long4  args} { 
  

  YWnd  $fid $prog $name $x $y $w $h  \
    $w_long1 $w_long2 $w_long3 $w_long4  {*}$args -message YOPEN 

} 
#-------------------------------------------------------------------------------
proc YWndDraw {fid prog name x y w h  \
           w_long1 w_long2 w_long3 w_long4  args} { 
  

  YWnd  $fid $prog $name $x $y $w $h  \
    $w_long1 $w_long2 $w_long3 $w_long4  {*}$args -message YDRAW 

} 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

  #wm protocol . WM_DELETE_WINDOW [list Exit] ;# можно перехватить
  #update 
  #wm deiconify .

  # [winfo width]  to get the actual width of the window (для нового = 1 пока не 
  #  появится в реальности)
  # [font measure]    to compute the width of the string

  # puts "WINFO CHILDREN = [winfo children $w]"

#   puts ""
#   puts "pointerx . =  [winfo pointerx  .]"
#   puts "pointery . =  [winfo pointery  .]"
#   puts ""

#-------------------------------------------------------------------------------

  # ТИПЫ СОБЫТИЙ: (стр. 622)
  # 
  # Configure - изменение размеров, позиции, обрамдения окна или положения его 
  #             в стеке.
  # 
  # Expose    - Отображение окна. 
  # 
  # ...................
  # 
  # event generate - программная генерация событий. Генерировать можно, как 
  #       стандартные события оконной системы, так и виртуальные события.
  #       (только в рамках текущего приложения)
  # 
#-------------------------------------------------------------------------------
#
#
#
#-------------------------------------------------------------------------------
proc M {fid_parent} {


  if {$fid_parent == "."} {

    set fid  ""
  } else {

    set fid  $fid_parent
  }
  
  return $fid
}
#-------------------------------------------------------------------------------
proc N {fid_parent name} {


  set fid [M $fid_parent]

  return $fid.$name
}
#-------------------------------------------------------------------------------
proc make_child_name {fid_parent} {

  #set randname [MAKE_GLOBAL_NAME]
  #set randname  [MAKE_UNICUM_NAME] ;# window name starts with an upper-case letter: "G_NAME_3"

  #set randname _[MAKE_UNICUM_NAME] 

  #set randname _[MAKE_UNICUM_NAME ""] 
  set randname [MAKE_UNICUM_NAME ""] 

  return [N $fid_parent $randname]
}
#-------------------------------------------------------------------------------
proc add_name_to_bigwindow {fid} {

  # ен очень сам понял. зачем это?

  return [N $fid "m"]
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc redraw_or_reopen {fid x y w h} {


  set mop $::WINO($fid)
  
  set message [GET $mop "message"]
  
  puts "YWnd ($fid): redraw_or_reopen : mod_exist: message_save = $message"
  
#   if {$message == "YOPEN"} {
    
#     set mes "YREOPEN"
#   } else {
#     set mes "YREDRAW"
#   }

  set mes "${message}_RESIZE"
  
  YSend $fid $mes  $x $y $w $h 
  
  return
}
#-------------------------------------------------------------------------------
proc BigWH_check {fid  ww hh} {

  # что за мрак через глобальные массивы?
  #
  # к сожалению, пока так! необходимость отдельного описания 
  # (вне системы модулей/окон) связана с тем, что биг-окно и верхенне окно Wdn
  # могут не совпадать по имени!
  #
  # TODO: создавать для биг-окна тоже модуль с одной функцией BIGWINDOW ?


  #set ww_old [WND_w $fid]
  #set hh_old [WND_h $fid]

  set is_size_change 0
  
  if {$ww != $::Warr($fid)} {

    set ::Warr($fid)   $ww
    set is_size_change 1
  }
  
  if {$hh != $::Harr($fid)} {

    set ::Harr($fid)   $hh
    set is_size_change 1
  }

  return $is_size_change
}
#-------------------------------------------------------------------------------
proc BigWH_init {fid} {

  # установили пока размеры топ-окна
  # 

  set ::Warr($fid) 0 ;# ?????
  set ::Harr($fid) 0

}
#-------------------------------------------------------------------------------
proc YToplevelResize {fid} {


  #..... ............ ...... .. .... ........ ...... ??
  #
  if {$fid != [winfo toplevel $fid]} {
    return 0
  }

  set W [winfo  width $fid];
  set H [winfo height $fid];

  #if {! [YCheckChangedWH  $fid $W $H]} {}
  if {! [BigWH_check  $fid $W $H]} {
    return 0
  }
                            
  return 1
}
#-------------------------------------------------------------------------------
proc YBindConfigure {main_fid user_fid proc_name} {
  

  BigWH_init  $main_fid

  # сформируем процедуру обработки событий окна
  # 
  set configure_procbody {

    set fid "%W"

    # будем обрабатывать только от окон верхнего уровня 
    # (отсекаем начальный старт дочерних окон)
    # 
    if {$fid != [winfo toplevel $fid]} {
      return
    }

    set W [winfo  width $fid]; 
    set H [winfo height $fid]; 
    
    # будем отрисовывать, только если меняется размер (а если стек изменился?)
    # 
    if {! [BigWH_check  $fid $W $H]} {
      return
    }

    puts "<Configure>:  fid= $fid  W= $W H= $H  user_fid = NAME"

    PROC  NAME  0 0 $W $H    ;# шаблон имени далее заменим 
  }


  # а теперь заменим шаблон (только одно вхождение?? -all):
  #
  regsub -all "PROC"      $configure_procbody   "${proc_name}" configure_procbody 
  regsub -all "NAME"      $configure_procbody   "${user_fid}"  configure_procbody 
 
  puts ""
  puts "YBindConfigure ..... : main_fid = $main_fid"

  #if {0} {
  #  puts "BindConfigureNEW: configure_procbody = $configure_procbody"
  #}
  puts ""


  bind $main_fid <Configure> $configure_procbody ;# изменение размеров, позиции, 
                                      # обрамления окна или положения его в стеке.
  
  return
}
#-------------------------------------------------------------------------------
proc TopLevelSet {top_fid  xx yy ww hh  title} {


  if {$top_fid == ""} { # на всякий случай
    set top_fid "."
  }

  puts ""
  puts "TopLevelSet ........ : top_fid = $top_fid "

  # создаем требуемое окно верхнего уровня
  #
  if {$top_fid != "."} {

    toplevel $top_fid
  }


  wm iconify $top_fid ;# сначала спрячем

  wm    title $top_fid    $title

  wm geometry $top_fid    ${ww}x${hh}+$xx+$yy


  return $top_fid
}
#------------------------------------------------------------------------------- 
proc BigWindowMain {main_fid user_level proc_name xx yy ww hh  args} {


  set title [dict_parse $args "-title" ""]


  set main_fid [TopLevelSet $main_fid  $xx $yy $ww $hh  $title]

  puts ""
  puts "YBigWindowMain ..... : main_fid = $main_fid  proc_name= $proc_name"


  if {$user_level == ""} {
    set user_fid $main_fid
  } else {
    set user_fid [N $main_fid $user_level]
  }

  # для пееррисовки размеров (по биг-окну !!!) или еще для чего-то ???
  # 
  if {1} {
    YBindConfigure  $main_fid  $user_fid  $proc_name 
  }

  return $user_fid
}
#------------------------------------------------------------------------------- 
proc YBigWindowNew {main_fid user_level proc_name  xx yy ww hh  args} {

  if {$main_fid == ""} { # на всякий случай
    set main_fid "."
  }

  set user_fid [BigWindowMain  $main_fid $user_level \
                  "redraw_or_reopen" \
                  $xx $yy $ww $hh  {*}$args]


  YWnd  $user_fid  $proc_name "" 0 0 $ww $hh  0 0 0 0 {*}$args

  puts ""
  puts "YBigWindowNew ..... : main_fid = $main_fid"
  puts ""


  wm deiconify $main_fid  ;# теперь появляется окошко (надо бы так?)

  return $user_fid
}
#-------------------------------------------------------------------------------
proc YBigWindowOld {main_fid  proc_name  xx yy ww hh  args} {


  set user_fid [BigWindowMain  $main_fid "" \
                  $proc_name \
                  $xx $yy $ww $hh  {*}$args]


  wm deiconify $main_fid  ;# теперь появляется окошко (надо бы так?)

  ${proc_name} $user_fid  0 0 $ww $hh

  return
}
#-------------------------------------------------------------------------------
proc ModDialog {main_fid  proc_name  xx yy ww hh  title} {

  set user_level "user" 

  YBigWindowNew  $main_fid $user_level $proc_name  $xx $yy $ww $hh -title $title 

  puts ""
  puts "ModDialog:  main_fid = $main_fid"
  puts ""


  # надо временно отключить прием сообщений
  #  
  # 1) закрыть невидимым окном-заглушкой?

  #set_busy "."
  #set_busy ".main" ;# но и всем потомкам?? а как? проще перекрыть ...

  #tk busy hold .main
  #tk busy  .

  grab  $main_fid ;# !!!!! перенаправляет все события только в окно диалога !!!

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
  # стр. 225
  # 
  # Поскольку $args - это список, то необходимо использовать команду eval; 
  # при этом происходит объединение всех параметров в один список, а значит
  # в корректную Tcl-команду.
  # 
  # Скобки после eval: дважды будет обрабатываться только $args (заменяется 
  # списком и подклеивается к другим параметрам, которые в скобках - именно
  # важны скобки; если будут кавычки, то сложные параемтры (в виде строки, напрммер)
  # - могут излишне раскрыться !
  # 
#-------------------------------------------------------------------------------
proc YPlace {fid   x y w h} {

  # по умолчанию считам, что рисуем в рамках родительского (в иерархии) окна:
  # 
  set parent [winfo parent $fid]

  place $fid -in $parent -x $x -y $y -width $w -height $h

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc YFrame {fid args} {

  if {! [winfo exists $fid]} {

    frame $fid ;# -bg "blue" 

  } 

  return
}
#----------------------------YCanvas--------------------------------------------
# 
# Canvas - виджет для отрисовки графики и картинок
# 
#-------------------------------------------------------------------------------
proc YPlaceCanvas {can x y w h  args} {

  set is_first "false"


  if {! [winfo exists $can]} {

    puts "PlaceCanvas: NOT EXISTS: can= $can"

    #eval {canvas $can -bg "green" {*}$args}

    eval {canvas $can {*}$args}

    set is_first "true"
    
  } else {
  
    puts "PlaceCanvas EXISTS: can= $can"
  }

  # а эту часть всегда выполняем, тогла лостаточно одного прохода!
  #

  #$can config -bg $color -borderwidth 0 -highlightthickness 0

  $can config -borderwidth 0 -highlightthickness 0

  YPlace  $can  $x $y $w $h 
 

  return $is_first
}
#-------------------------------------------------------------------------------
proc YPlaceFrame {fid  x y w h  {color "red"}} {

  if {! [winfo exists $fid]} {

    frame $fid -bg "blue" 

  } else {

    #$fid config -bg $color
    #YPlace  $fid   $x $y $w $h
  }

  $fid config -bg $color

  YPlace  $fid   $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
proc YPlaceFrameNEW {fid  x y w h  args} {

  if {! [winfo exists $fid]} {

    frame $fid {*}$args ;# -bg "blue" 

  } else {

    #$fid config -bg $color
    #YPlace  $fid   $x $y $w $h
  }

  $fid config ;# -bg $color

  YPlace  $fid   $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
proc YCanvasFrame {fid  x y w h  {color "red"}} {

  #if {! [winfo exists $fid]} {

  frame $fid -bg $color 

  #} else {

  #  $fid config -bg $color
  #  YPlace  $fid   $x $y $w $h
  #}

  YCanvasWindow  $fid  $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
proc YPlaceButton {pid text x y w h  args} {

  if {! [winfo exists $pid]} {

    eval {button $pid -text $text} $args

  } else {

    #YPlace  $pid  $x $y $w $h
  }

  YPlace  $pid  $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
proc YButton {pid text args} {

  if {! [winfo exists $pid]} {

    eval {button $pid -text $text} $args
  } 

  return
}
#-------------------------------------------------------------------------------
proc YScale {pid args} {

  if {! [winfo exists $pid]} {

    eval {scale $pid} $args
  } 

  return
}
#-------------------------------------------------------------------------------
proc YCanvasWindow {fid   x y w h} {


  # по умолчанию считам, что рисуем в рамках родительского (в иерархии) окна:
  # 
  set parent [winfo parent $fid]

  # объект window позволяет распологать на холсте другие компоненты Tk
  # (которые обычно укладываются в контейнер $fid)
  #
  $parent create window  $x $y   -width $w -height $h  -window $fid  -anchor nw

}
#-------------------------------------------------------------------------------     
proc YCanvasButton {fid text x y w h   args} {

  # рисуем в канвасе !!!
  # 

  #       YPost (WND->parent, YPUSH, id, 0, 0l, 0); 
  #set parent = [WND_parent $fid]
  #set cmd [list YPost $parent FROM "YPUSH" 0 0 0 0]
  #set cmd [list puts "YPUSH !!!!!!!!!!!!!!!!!!!!!!"]


  # TODO: может тут надо заносить что-то во внутренюю структуру?
  # 

  eval {button $fid -text [koi_to_utf $text]} $args

  YCanvasWindow  $fid  $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
# TODO: надо будет сделать более аккуратно, возможно все через YFrame
# 
#-------------------------------------------------------------------------------
proc run_tkscript_in_frame {script fid arg_s} {
  
  set frameid [winfo id $fid]

  # в скрипт же надо параметры передавать !! ??
  # 

  #set fullpath_script "[pwd]/$script"

  set fullpath_script "tclsh [pwd]/$script"

  # проблема запустить в Windows (хотя уже указал полный путь)
  # 
  # the window to use is not a Tk container (когда вызываем  package require Tk)
  # 

  if [catch {set pid [eval exec $fullpath_script -use $frameid $arg_s  &]} ret] {

    puts ""
    puts "run_tkscript_in_frame ERROR: frameid = $frameid,  ret = $ret "
    puts ""

    #set answer [tk_messageBox -message "run_tkscript_in_frame ERROR" -type yesno -icon question]
  } else {

    puts ""
    puts "run_tkscript_in_frame OK: frameid = $frameid,  ret = $ret  pid = $pid"
    puts ""
  }
  
  return
}
#-------------------------------------------------------------------------------
proc run_program_in_frame {program fid} {
  

  set frameid [winfo id $fid]   ;# 0x4600014 

  set frameid_int [format "%d" $frameid]
  
  if [catch {set pid [exec $program $frameid_int & ]} ret] {
  # 
  #if [catch {set pid [exec {*}$program $frameid_int & ]} ret] {}

    puts ""
    puts "run_program_in_frame ERROR: frameid_int = $frameid_int,  ret = $ret "
    puts ""

  } else {

    puts ""
    puts "run_program_in_frame OK: frameid_int = $frameid_int,  ret = $ret  pid = $pid"
    puts ""
  }
  
  return
}
#-------------------------------------------------------------------------------
proc YPlaceProgram {fid  x y w h color program} {

  if {! [winfo exists $fid]} {

    frame $fid -bg $color 

    run_program_in_frame $program $fid
  
  } else {
    YPlace  $fid   $x $y $w $h
  }

  return
}
#-------------------------------------------------------------------------------
proc YCanvasProgram {fid  x y w h color program} {

  #if {! [winfo exists $fid]} {

  frame $fid -bg $color 
  
  run_program_in_frame $program $fid
  
  #} else {
  
  YCanvasWindow  $fid   $x $y $w $h
  #}

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc run_video_player {fid mvname} {


  set frameid     [winfo id $fid]        ;# 0x4600014 ??
  set frameid_int [expr int($frameid)]

  #puts "frameid= $frameid  frameif(int)= $frameid_int"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # XANIM
  # 
  #catch {set pid [exec xanim +Ze -Zr  +W$frameid $mvname & ]}
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # MPLAYER
  # 
  #catch {set pid [exec "mplayer-zoom"  -wid $frameid $mvname 2> /dev/null > /dev/null & ]}
  #catch {set pid [exec "mplayer -zoom"  -wid $frameid $mvname 2> /dev/null > /dev/null & ]}


  if [catch {set pid [exec mplayer -loop 0  -wid $frameid $mvname 2> /dev/null > /dev/null & ]} ret] {

    puts ""
    puts "run_video_player ERROR: frameid = $frameid,  ret = $ret "
    puts ""

  if [catch {set pid [exec mpv -wid $frameid $mvname 2> /dev/null > /dev/null & ]} ret] {

    puts ""
    puts "run_video_player ERROR: frameid = $frameid,  ret = $ret "
    puts ""
  }

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # MPV

  # --wid=<ID>

  #   This tells mpv to attach to an existing window. If a VO is selected 
  # that supports this option, it will use that window for video output. mpv 
  # will scale the video to the size of this window, and will add black bars 
  # to compensate if the aspect ratio of the video is different.

  #   On X11, the ID is interpreted as a Window on X11. Unlike MPlayer/mplayer2, 
  # mpv always creates its own window, and sets the wid window as parent. The 
  # window will always be resized to cover the parent window fully. The value 0 
  # is interpreted specially, and mpv will draw directly on the root window.

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # VLC
  # 
  #Embedded window video
  #    --drawable-hwnd=<integer [-2147483648 .. 2147483647]>
  #                               Window handle (HWND)
  #        Video will be embedded in this pre-existing window. If zero, a new
  #        window will be created.
  #
  #catch {set pid [exec vlc --drawable-hwnd=$frameid_int $mvname 2> /dev/null > 
  # /dev/null & ]}


  #https://forum.videolan.org/viewtopic.php?f=32&t=86381
  #
  #If you do, show me how to use it, because I've tried in so many ways but it 
  #fail in an error. Those errors always begin with the message below:
  #"vlc: unknown option or missing mandatory argument `--drawable-hwnd'
  #Try `vlc --help' for more information."

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # летящие астероиды
  # 
  #catch {set pid [exec asters.tcl -use $frameid & ]} ret
  #
  # это уже извращения по связи с программой ..... 


  # связь идет через gets-puts (т.е. pipe) - и asters наверное тоеж, вот и конфликт !?
  #
  # stop and start the movie
  # after 100
  # puts stop
  
  #catch {exec kill -STOP $pid}
  
  #after 2000
  #puts start

}
#-------------------------------------------------------------------------------
proc YPlaceScript {fid  x y w h color program arg_s} {

  #set arg_s {10 10 100 100}

  if {! [winfo exists $fid]} {

    frame $fid -bg $color 

    # frame $pid -bg "blue" -container true ;# ???
    #Error in startup script: can't create window: its parent has -container = yes

    run_tkscript_in_frame  $program $fid $arg_s
  
  } else {
    #$fid config -bg "lightgreen"
    YPlace  $fid   $x $y $w $h
  }

  return
}
#-------------------------------------------------------------------------------
proc YCanvasScript {fid  x y w h color program arg_s} {


  #if {! [winfo exists $fid]} {

  frame $fid -bg $color 
  
  run_tkscript_in_frame  $program $fid $arg_s
  
  #} else {
  
  #YPlace  $fid   $x $y $w $h
  YCanvasWindow  $fid   $x $y $w $h
  #}

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc YPlaceListbox {pid  x y w h  args} {

  if {! [winfo exists $pid]} {

    eval {listbox $pid} $args

  } else {

    YPlace  $pid  $x $y $w $h
  }

  return
}
#-------------------------------------------------------------------------------
proc YPlaceLabel {pid text x y w h  args} {

  if {! [winfo exists $pid]} {

    eval {label $pid -text [koi_to_utf $text]} $args

  } else {

    YPlace  $pid  $x $y $w $h
  }

  return
}
#-------------------------------------------------------------------------------
proc YPlaceLabelCentre {pid text xc yc w h} {


  if {! [winfo exists $pid]} {

    label $pid -text $text
  } else {

    set x [expr $xc - $w / 2]
    set y [expr $yc - $h / 2]

    YPlace  $pid  $x $y $w $h
  }

#   set x [expr $xc - $w / 2]
#   set y [expr $yc - $h / 2]

#   YPlaceLabel $pid $text  $x $y $w $h ;# почему-то с русскими - крякозябры !

  return
}
#-------------------------------------------------------------------------------
proc YCanvasLabel {fid text x y w h  args} {

  #   if {! [winfo exists $pid]} {
  #     eval {label $pid -text [koi_to_utf $text]} $args
  #   } else {
  #     YPlace  $pid  $x $y $w $h
  #   }

  eval {label  $fid -text [koi_to_utf $text]} $args

  YCanvasWindow  $fid  $x $y $w $h

  return
}
#-------------------------------------------------------------------------------
proc YCanvasLabelCentre {pid text xc yc w h} {


  #if {! [winfo exists $pid]} {

  label $pid -text $text
  #} else {
  
  set x [expr $xc - $w / 2]
  set y [expr $yc - $h / 2]
  
  YCanvasWindow  $pid  $x $y $w $h
  #}

#   set x [expr $xc - $w / 2]
#   set y [expr $yc - $h / 2]

#   YPlaceLabel $pid $text  $x $y $w $h ;# почему-то с русскими - крякозябры !

  return
}
#-------------------------------------------------------------------------------
proc get_coor_label {&x &y  W H ww hh} {

  USE_REFS

  set xc [expr $ww / 2]
  set yc [expr $hh / 2]
  
  #puts "xx= $xx" ;#   1 - это координаты относительно родителя! и зачем?
  #puts "yy= $yy" ;#  32
  #puts "ww= $ww"
  #puts "hh= $hh"
  
#   puts "x = $x"
#   puts "y = $y"
#   puts "w = $w"
#   puts "h = $h"
#   puts "label_xc = $label_xc"
#   puts "label_yc = $label_yc"
  
  set x [expr $xc - $W/2]
  set y [expr $yc - $H/2]
  
  return
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# /*-----------------------------YPaintString--------------------------------*/ 
# 
proc YPaintString {can text x y color} {
 
  CALCXY x y 
  
  #   y += 4; /*??!!!*/
  #   XSetForeground (DPY, SV->gc, color); 
  #   XDrawString (DPY, SV->win, SV->gc, x, y, text, strlen (text)); 
  #   XFlush (DPY); 
 
  $can create text  $x $y -text $text -fill $color -anchor w

  return
} 
# /*-----------------------------draw_rect_text--------------------------------*/
# void
# draw_rect_text (char *text, int xx, int yy, int ww, int hh, YT_COLOR color)
#-------------------------------------------------------------------------------
# 
proc draw_rect_text {can text  xx yy ww hh  color} {

  #   int x0, y0;
  #   int     x, y, w, h;
  
  #   x0 = xx + ww / 2;
  #   y0 = yy + hh / 2;
  
  set x0 [expr $xx + $ww / 2]
  set y0 [expr $yy + $hh / 2]
  
  #   w = YStringW (text);
  #   h = YStringH (text);
  #   ANTICALCWH (w, h);

  #set w [$can cget -width];# 100
  #set h [$can cget -height];# 20
  
  #set w [winfo width  $can];# 100
  #set h [winfo height $can];# 20  
  #puts "w = $w ??"
  #puts "h = $h ??"
  
  #set  x [expr $x0 - $w / 2]
  #set  y $y0

  set  x $x0
  set  y $y0

  #   YPaintString (text, x, y, color);
  #$can create text $x $y -text $text

  #puts "draw_rect_text: xx= $xx yy= $yy  ww= $ww hh= $hh    text= $text"

  $can create text $x $y -text $text -fill $color ;# -anchor n
  
  return
}
# /*------------------------------YStringH------------------------------------*/ 
# int 
# YStringH (char *string) 
#------------------------------------------------------------------------------
proc YStringH {can string} {
 
  
  return 8 ;# ????
} 
# /*-------------------------------YStringW-----------------------------------*/ 
# int 
# YStringW (char *string) 
#------------------------------------------------------------------------------
proc YStringW {can string} { 

  #   return (XTextWidth (KERN_S->font_struct, string, strlen (string))); 

  #set f [$can cget -font]
  #set w [font measure $f]

  set l [string length $string]

  #puts "l = $l"

  set w 8 ;# примерная ширина одного символа ?

  set ret [expr $w * $l]

  return $ret 
} 

# /*-------------------------------YError----------------------------------*/ 
proc YError {string} { 
 
  #   YErrorS ("YError", string); 
 
  puts ""
  puts "YError:  $string"
  puts ""

  exit
} 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc YDrawCirc {fid  cx cy r  color} {


  set x1 [- $cx $r]
  set y1 [- $cy $r]

  set x2 [+ $cx $r]
  set y2 [+ $cy $r]

  set ret [$fid create oval $x1 $y1 $x2 $y2  -fill $color]

  #$fid create oval $x1 $y1 $x2 $y2 

  return $ret
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


