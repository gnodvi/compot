# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::A_COMP_TL] {
  return
} else {
  set  ::A_COMP_TL ""
}

#-------------------------------------------------------------------------------

# ;;
# ;;   Формирование символьной экранной информации
# ;;   с дальнейшим выводом на терминал
# ;;
# ;; сдeлали простым двумeрным массивом

# ;(defmacro WIN_H () (list 'array-dimension 'win 0))
# ;(defmacro WIN_W () (list 'array-dimension 'win 1))

# (defmacro WIN_H () (list 'array-end 'win 0))
# (defmacro WIN_W () (list 'array-end 'win 1))

# ;(defmacro WIN_XY (x y) (list 'aref 'win y x))


# ------------------------------------win_init-----------------------------------
#proc win_init {&win ch} {}
proc win_init {win ch} {

  #USE_REFS

  set w [set ${win}(w)]
  set h [set ${win}(h)]

  #puts "w = $w"
  #puts "h = $h"

  for {set x 0} {$x < $w} {incr x} {
  for {set y 0} {$y < $h} {incr y} {

    set ${win}($x,$y) $ch
  }
  }

}
# -----------------------------------win_create----------------------------------
#proc win_create {&win w h} {}
proc win_create {w h} {

  set win [MAKE_GLOBAL_NAME]
 
  #USE_REFS

  #   (win (make-array (shape 0 h 0 w))) 
  set ${win}(w) $w
  set ${win}(h) $h

  #win_init  $win " "
  win_init  $win " "

  return $win
}
#---------------------------------------------------------------------------------
proc WIN_W {win} {

  #USE_REFS

  return [set ${win}(w)]
}
#---------------------------------------------------------------------------------
proc WIN_H {win} {

  #USE_REFS

  return [set ${win}(h)]
}
#---------------------------------------------------------------------------------
# macro WIN_H_ {} {

#   return $win(h)
# }
# ;------------------------------------win_char-----------------------------------
proc win_char {win ch x y {color "DEFAULT"}} {

  #USE_REFS

  set  ${win}($x,$y) $ch

  set ::clr($x,$y) $color ;# записываем в массив цвет 

}
# ;-------------------------------------------------------------------------------
proc win_text  {win text x0 y {color "DEFAULT"}} {

  #USE_REFS

  for {set i 0} {$i < [string length $text]} {incr i} {

    set ch [string index  $text $i]

    set x [expr {$x0 + $i}]    ;# вычисляем координаты (через смещение) след. буквы

    win_char  $win $ch  $x $y $color ;# записываем в массив букву (и цвет)
  }

}
# ;-------------------------------------------------------------------------------
proc win_horz {win ch y_horz x1 x2 {color "DEFAULT"}} {

  #USE_REFS

  for {set x $x1} {$x <= $x2} {incr x} {

    win_char  $win $ch $x $y_horz   $color
  }

}
# -------------------------------------------------------------------------------
proc win_vert {win ch  x_vert y1 y2  {color "DEFAULT"}} {

  #USE_REFS

  # надо уточнить дельту смещения (вверх или вниз) ?
  # и вообще  лучше просто другой алгоритм:

  if {$y1 < $y2} {
    set delta 1
    set condi {$y <= $y2}

  } else {
    set delta -1
    set condi {$y >= $y2}
  }


  for {set y $y1} $condi {incr y $delta} {

    win_char  $win $ch $x_vert $y   $color
  }

}
# -------------------------------------------------------------------------------
proc win_rect_fill {win  ch  x y w h {color "DEFAULT"}} {

  #USE_REFS

  for {set i 0} {$i < $w} {incr i} {
  for {set j 0} {$j < $h} {incr j} {

    win_char  $win $ch [expr {$x + $i}] [expr {$y + $j}]   $color
  }
  }

}
# -------------------------------------------------------------------------------
proc win_rect {win  ch_horz ch_vert  x y w h {color "DEFAULT"} 
                 {colchar "NONE"} {colfill "CYAN"} } {

  #USE_REFS

  if {$colchar != "NONE"} {
    win_rect_fill  $win $colchar  $x $y $w $h $colfill
  }

  set w     [expr {$w - 1}]
  set h     [expr {$h - 1}]

  set x_end [expr {$x + $w}]
  set y_end [expr {$y + $h}]

  win_horz  $win $ch_horz    $y       $x    $x_end  $color
  win_horz  $win $ch_horz    $y_end   $x    $x_end  $color

  win_vert  $win $ch_vert    $x       $y    $y_end  $color
  win_vert  $win $ch_vert    $x_end   $y    $y_end  $color

}
#---------------------------------------------------------------------------------
proc win_get_color {win x y} {

  if {[info exist ::clr($x,$y)]} {

    return $::clr($x,$y)
  }

  return "DEFAULT"
}
#---------------------------------------------------------------------------------
proc win_draw {win {is_color 1}} {

  #set is_color 1 ;# 1 - будет цвет, но и ввывод посимвольный, что очень долго
                  # ? а может вставлять упр.цвет.символы тоже в строку?
                  # !!! долго не сам вывод посимвольный !  а именно переключение
                  # цвета, т.е. вывод управляющих символов !

  #USE_REFS

  set w [WIN_W $win]
  set h [WIN_H $win]

  #if {$is_print_WH} {

  #  puts "WIN_W = $w"
  #  puts "WIN_H = $h"
  #}

  # однако попробуем сделать мкакрос, т.е. не надо указывать переменную win -
  # он раскроется в текущем контексте;
  # интересно бы сравнить время раскрытия макроса и честного вызова процедуры
  #
  #puts "WIN_H = [WIN_H_]"


  for {set y 0} {$y < $h} {incr y} {

    set str ""
    for {set x 0} {$x < $w} {incr x} {
      
      set ch   [set ${win}($x,$y)]  ;# взяли нужный символ
      
      if {$is_color} {

        set color [win_get_color $win $x $y]

        #win_set_color $color
        #puts -nonewline $ch   ;# печатаем его (каждый символ отдельно? !!)
        #win_set_color "DEFAULT"

        append str [win_set_color_upr $color]  ;# 
        append str $ch 
        append str [win_set_color_upr "DEFAULT"]

      } else {

        append str $ch ;# сначала сформируем простую строку
      }
      
    }
    puts $str ;# выводим строку (пустую, если без света)
  }

}
# ;-------------------------------------------------------------------------------

# ;typedef struct {
# ;  int     i, x, y, delta_x, delta_y, exchange, err, incx, incy;
# ;  int     x_old, y_old, x_left, x_right;
# ;  BOOL    begin, end;
# ;  int     align;
# ;} VT_HANDLINE;

# ;(defvar p-i)
# ;(defvar p-x)
# ;(defvar p-y)

# (defvar p_delta_x)
# (defvar p_delta_y)

# ;(defvar p-exchange)
# (defvar p_err)
# (defvar p_incx)
# (defvar p_incy)

# (defvar retun_x)
# (defvar retun_y)

# (defclass HANDLINE () (  
#   (i        :accessor I)
#   (x        :accessor X)
#   (y        :accessor Y)
#   (exchange :accessor EXCHANGE)
# ))

# ;-------------------------------------------------------------------------------
proc VHandPixel {win x y ch color} {

  #USE_REFS

  win_char  $win  $ch $x $y  $color

}
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;(defun VHandLineFunc (VT_HANDLINE *p, BOOL flag, int *px1, int *py1,
# ;                 int *px2, int *py2)
# ;  int     x1, y1, x2, y2, delta;

# ;-------------------------------------------------------------------------------
proc VHandLineFunc {@line flag  x1 y1  x2 y2} {

  #USE_REFS
  #upvar ${&line} line
  upvar ${@line} line

  global  p_delta_x p_delta_y
  global  p_incy p_incx p_err  retun_x retun_y 

  if {$flag == 0} {
    set p_delta_x  [expr {$x2 - $x1}]
    set p_delta_y  [expr {$y2 - $y1}]
    set line(X)    $x1
    set line(Y)    $y1

    if      {$p_delta_x  > 0} {set p_incx  1} \
    elseif  {$p_delta_x == 0} {set p_incx  0} \
    else                      {set p_incx -1}

    if      {$p_delta_y  > 0} {set p_incy  1} \
    elseif  {$p_delta_y == 0} {set p_incy  0} \
    else                      {set p_incy -1}

    set p_delta_x [expr {abs($p_delta_x)}]
    set p_delta_y [expr {abs($p_delta_y)}]

    if {$p_delta_y  >  $p_delta_x} {
      set delta      $p_delta_x
      set p_delta_x  $p_delta_y
      set p_delta_y  $delta
      set line(EXCHANGE) 1
    } else {
      set line(EXCHANGE) 0
    }

    set p_err [expr {(2 * $p_delta_y) - $p_delta_x}]
    set line(I)  1

    return 1
  }


  #puts "@@@@@@ -- $line(I)"
  #puts "@@@@@@ -- $p_delta_x" ;# минус нельзя в имя переменной !!

  if {$line(I) > $p_delta_x} {
    return 0
  }


# ;  *px1 = p->x;
# ;  *py1 = p->y;
  set retun_x $line(X)
  set retun_y $line(Y)

  while {$p_err >= 0} {
    if  {$line(EXCHANGE) == 1}  {set line(X) [expr  {$line(X) + $p_incx}]} \
    else                        {set line(Y) [expr  {$line(Y) + $p_incy}]}               
    set p_err [expr $p_err - (2 * $p_delta_x)]
  }

  if  {$line(EXCHANGE) == 1}  {set line(Y) [expr  {$line(Y) + $p_incy}]} \
  else                        {set line(X) [expr  {$line(X) + $p_incx}]}        
  set p_err [expr {$p_err + (2 * $p_delta_y)}]

  set line(I) [expr {1 + $line(I)}]

  return 1
}
#-------------------------------------------------------------------------------
proc VHandLine {win  x1 y1  x2 y2  ch  color} {

  #USE_REFS

  # ;  VT_HANDLINE line;
  # ;  int     x, y, dx, dy;
  # ;  BOOL by_y;
  global  retun_x retun_y
  
  # (let (
  #   (line (make-instance 'HANDLINE))
  
  set dx  [expr {$x2 - $x1}]
  set dy  [expr {$y2 - $y1}]
  #   ;by_y  ?????????????
  #  )
  
  if {$dx == 0 && $dy == 0} {
    ERROR "VHandLine"
  }
  
  # ;  if (abs (dy) > abs (dx))  by_y = TRUE;
  # ;  else                      by_y = FALSE;
  # ;  (if (> (abs dy) (abs dx)) 
  # ;    (setf by_y t)
  # ;    (setf by_y NIL)
  # ;    )
  
  VHandLineFunc line 0  $x1 $y1 $x2 $y2 

  while {[VHandLineFunc line 1  0 0 0 0]} {

    VHandPixel  $win  $retun_x $retun_y  $ch $color
  }
  
}
# ;-------------------------------------------------------------------------------
proc win_line {win ch x1 y1 x2 y2 {color "DEFAULT"}} {

  #USE_REFS

  VHandLine  $win $x1 $y1 $x2 $y2 $ch  $color

}
# ;-------------------------------------------------------------------------------
proc win_triangle {win ch x1 y1 x2 y2 x3 y3 {color "DEFAULT"}} {

  #USE_REFS

  win_line  $win  $ch  $x1 $y1  $x2 $y2  $color
  win_line  $win  $ch  $x2 $y2  $x3 $y3  $color
  win_line  $win  $ch  $x1 $y1  $x3 $y3  $color

}
# ;-------------------------------------------------------------------------------
# ; Подпрограмма для черчения эллипса : 
  #                          x y              точка черчения 
  #                          xcentre ycentre  центр эллипса
  #                          asp_ratio        коэффициент "сжатия" пиксела
# ;-------------------------------------------------------------------------------
proc bj_drawellps {win ch  x y  xcentre ycentre  asp_ratio {color "DEFAULT"}} { 
   
  #USE_REFS

  set starty  [expr {floor(      $y * $asp_ratio)}]
  set startx  [expr {floor(      $x * $asp_ratio)}]
  set endy    [expr {floor(($y + 1) * $asp_ratio)}]
  set endx    [expr {floor(($x + 1) * $asp_ratio)}]
 
  #   puts "startx = $startx"
  #   puts "starty = $starty"
  #   puts "endx   = $endx"
  #   puts "endy   = $endy"
  #   puts ""
  set startx  [expr {int($startx)}]
  set starty  [expr {int($starty)}]
  set endx    [expr {int($endx)}]
  set endy    [expr {int($endy)}]
  puts "$startx $endx : $starty $endy"
  puts ""

  # выдает:
  # 0 1 : 5 6
  # 1 2 : 5 6
  # 2 3 : 5 6
  # -4 -3 : -4 -3
  
  # лисп выдает: 
  # 0 1 : 5 6 
  # 1 2 : 5 6 
  # 2 3 : 5 6 
  # 3 4 : 4 5 
  # 3 4 : 3 4 

  for {set x1 $startx} {$x1 < $endx} {incr x1} { 
  # ;  for (x1 = startx; x1<endx; ++x1) {} 
# ;  (loop for x1 from (1+ startx) to (1- endx) do
# ;  (do ((x1 startx)) ((not (< x1 endx)))
#   (do ((x1 startx)) (NIL)

    set xr [expr {$xcentre + $x1}]
    set xl [expr {$xcentre - $x1}]

    set yt [expr {$ycentre + $y}]
    set yb [expr {$ycentre - $y}]

    win_char  $win $ch  $xr $yt  $color
    win_char  $win $ch  $xr $yb  $color
    win_char  $win $ch  $xl $yt  $color 
    win_char  $win $ch  $xl $yb  $color 

#     (setf x1 (1+ x1))
#     (when (not (< x1 endx)) (return))
  }


  for {set y1 $starty} {$y1 < $endy} {incr y1} { 
# ;  for (y1 = starty; y1<endy; ++y1) {} 
# ;  (loop for y1 from (1+ starty) to (1- endy) do
# ;  (do ((y1 starty)) ((not (< y1 endy)))
#   (do ((y1 starty)) (NIL)

#     (win_char  win ch (+ y1 xcentre) (+ x ycentre)) 
#     (win_char  win ch (+ y1 xcentre) (- ycentre x)) 
#     (win_char  win ch (- xcentre y1) (+ x ycentre)) 
#     (win_char  win ch (- xcentre y1) (- ycentre x)) 

    win_char  $win $ch [expr $y1 + $xcentre] [expr $x + $ycentre]  $color 
    win_char  $win $ch [expr $y1 + $xcentre] [expr $ycentre - $x]  $color
    win_char  $win $ch [expr $xcentre - $y1] [expr $x + $ycentre]  $color
    win_char  $win $ch [expr $xcentre - $y1] [expr $ycentre - $x]  $color 


#     (setf y1 (1+ y1))
#     (when (not (< y1 endy)) (return))
  }


} 
#---------------------------------------------------------------------------------
proc win_ellipse {win ch left  top right bottom  {color "DEFAULT"}} {

    
  #USE_REFS

  set xradius  [expr {($right  - $left) / 2}]
  set yradius  [expr {($bottom - $top)  / 2}]
  set xcentre  [expr {$left + $xradius}] 
  set ycentre  [expr {$top  + $yradius}] 
 
  set asp_ratio  1.0


  if {$yradius != 0} {
    set asp_ratio [expr {$asp_ratio * ((1.0 * $xradius) / $yradius)}]
  }

# ;  /* алгоритм Брезенхама */ 
# ;  // size=max(xradius,yradius); 
  set y $xradius 
  set delta [expr {3 - (2 * $xradius)}] 


  for {set x 0} {$x < $y} {incr x} { 

    bj_drawellps  $win $ch  $x $y $xcentre $ycentre $asp_ratio   $color

    if {$delta < 0} { 
      set  delta [expr {$delta + ((4 * $x) + 6)}] 
    } else {
      set  delta [expr {$delta + ((4 * ($x - $y)) + 10)}] 
      set  y [expr {1 - $y}] ;#?? конeц цикла ужe посчитан ??
    }
  }

# ;  x = y; 
# ;  if (y) bj_drawellps (/* obj, */win, ch, x, y, xcentre, ycentre, asp_ratio);

  set x $y

  if {$y != 0}  {
    bj_drawellps  $win  $ch $x $y $xcentre $ycentre $asp_ratio   $color
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_win_test1 {} {

  set iw  60  
  set ih  30

  puts ""
  puts "TEST_win_test1 .."
  puts ""


  #set win winname

  # создаем экранную форму и рисуем главную рамочку
  #win_create win $iw $ih 
  set win [win_create $iw $ih] 
 
  #puts "W = $win(w)"
  win_rect  $win "=" "=" 0 0 60 30  "RED"


  win_line     $win "*"   2  2  15 15  "CYAN"
  win_line     $win "*"   2  2  15  5  "CYAN"
  win_ellipse  $win "@"  15 15  25 25  "GREEN"            
  win_triangle $win "$"  40  5  35 20  50 15 "YELLOW"
  
  win_text  $win  "win_text" 5 15  "BLUE"
  
  win_draw  $win ;# выводим экранную форму

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
