#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# http://www2.tcl.tk/9085

# Sailplane Flying Game
#-------------------------------------------------------------------------------

# Этот проект я начал, когда пытался изучать Tcl/Tk. Это движущаяся карта, 
# использующая авиационную диаграму сечения (aviation sectional chart).
# Вы можете запускать в полет планеры (sailplanes) над картой после выбора набора 
# целей, обычно - триангулярного курса (triangular course). Вы можете запустить
# несколько планеров. Каждому будет дан уникальный соревновательный номер ("contest ID").
# Вы должны остановить или задержать полеты прежде чем запустить новый планер.
#
# Вы можете стрелочками выбирать контролируемые планеры в списке. Пауза или стоп
# для изменяемого ID не влияет на другой планер. Они продолжат тот же курс на той
# же скорости.
# Стрелочки Влево и Вправо - направляют влево или вправо.
# Стрелка вниз - увеличивает скорость планера. Стрелка вниз - уменьшает.
#
# Ваш планер стартует на высоте 5000 ft. над уровнем моря. Используется полярная
# характеристическая кривая (polar performance curve) аналогичная реальному планеру.
# Т.е. если вы попробуете лететь быстрее, продвигаясь вперед, вы быстрее потеряете 
# высоту и рискуете преждевременно приземлиться.
# Вы можете вернуть себе потерянную высоту замедляясь или задерживаясь в случайно
# генерируемых термпльных потоках различной мощности, которые представляются на 
# карте в виде изображения коричневого столба дыма. 
#
# Полет быстрее не сделает вас победителем. Победит тот пилот, который имеет лучшее 
# суждение о том как быстро или медленно лететь взависимости от условий подьема.
# В общем случае, если условия подъема хорошие и множество термальных потоков
# могут быть достигнуты, выгоднее лететь быстрее достичь следующего потока быстрее
# несмотря на большую скорость потери высоты. Если потоковые условия плохия, т.е.
# чтобы вернуть потерянную высоту потребуется больше времени, то предпочтительнее 
# лететь медленне между теральными потоками и сохранять свою высоту.
# Если вы потеряете высоту и преждевременно приземлитесь - игра для вас закончиться.
# Есть одно утешение недоступное в реальных соревнованиях планеров. Если вы 
# маневрируете вашим глайдером позади опонента и ваш курсы пересекается в его
# направлении, нажатие клавиши пробела запустит крылатую ракету (? cruise missle)
# в его направлении. Если она попадает в ограничительные рамки планера противника,
# он будет разрушен и удален из соревнования.
#

# Проблемы:

# Вычисления расстояний для этой конкретной карты плохо реализованы в программе. 
# Нужно добавить возможность импортировать любую карту и более гибко выислять на 
# них. 
# Код нарушает ряд хороших Tcl-практик, которые я не знал, когда начинал 
# программировать и может сбивать с толку. 

# Цели:

# - у меня есть предварительная версия сетевой игры через сервер, где два клиента
# могут играть друг против друга с удаленных компьютеров, она работает, но имеет
# некоторые замедляющие проблемы;
#
# -   Use Tcl's new serial connection abilities to connect directly to a GPS 
# receiver and plot courses in real time. Possibly on a PDA. The program is able 
# now to read a Garmin .trk file and plot the positions on the map.

# -    Add ability to import an "IGC" file, a special GPS file format used by 
# glider pilots. So you can replay a GPS recording of a real glider flight.

# - добавить круговой полет, так чтобы, когда скорость опускается ниже определенного
# значения, глайдер начинает вращение в случайном направлении вправо или влево.
# или когда руль (steering input) достигает определенного значения, глайдер
# начинает кружиться в этом направлении. Меньшее значение продолжит прямой курс.
#
# -    A 3-D version using Tkogl, the Tcl extension to OpenGL
# -    Hook it up to a joystick for speed and steering input.

#-------------------------------------------------------------------------------

# 06/15/2003 Alex Caldwell 

# I added some code to the calcheadingchange proc that 
# now enables the gliders to circle in thermals, instead of just making "S" turns. 
# New global variable "angle_radians" added that gets increased by .01 x the 
# number of radians in a circle with each frame until the steering input decreases 
# back below the circling threshold. When the steering input value reaches a 
# threshold of absolute value 40 or more, the glider will circle right or left 
# depending on left arrow or right arrow input. The radius of the circle decreases 
# proportional to the absolute value of the steering input.

#-------------------------------------------------------------------------------
# soarmap2.tcl
#-------------------------------------------------------------------------------

## #!/usr/local/bin/wish8.2
#
# program for Tcl/Tk (free standing version - not for plug-in)
# By Alex Caldwell M.D.
# alcald@psnw.com

# Jan 5, 1997
# Feb 11, 1999
# Feb 16, 1999
# Feb 21, 1999

#-------------------------------------------------------------------------------

# This section doesn't really do anything. It's just a convenient
# place to document what all the global variables do

global i              ;# background image data for sectional map
global g              ;# background image data for little gliders
global bmp            ;# bitmap image

global IC             ;# used in great circle distance calculation
global COURSE         ;# compass course calculated from the course leg selected
global HEADING        ;# array of currently selected contestant's heading
global TURNPOINT1     ;# name of turnpoint1
global TURNPOINT2     ;# name of turnpoint2
global turnpoints     ;# list of turnpoint names
global latdegrees     ;# list of the turnpoint latitude degrees with the minutes truncated.
global latmin
global londegrees
global lonmin
global latdeg1
global latmin1
global londeg1
global lonmin1
global latdeg2
global latmin2
global londeg2
global lonmin2
global XAXIS          ;# difference between the x coordinates of the two turnpoints.
global YAXIS          ;# difference between the y coordinates of the two turnpoints.
global X1             ;# the x coordinate of the first turnpoint.
global X2             ;# the x coordinate of the second turnpoint.
global Y1             ;# the y coordinate of the first turnpoint.
global Y2             ;# the y coordinate of teh second turnpoint.
global SPEED          ;# array of each contestant's current speed
global ALTITUDE       ;# array of each contestant's current altitude
global text           ;# array of each contestant's contest no.
global ID             ;# array id of each contestant's small altitude text display
global shadow         ;# array id of each contestant's shadow so it can be 
                       # moved closer as altitude diminishes
global fileposition
global filecounter
global filelinenumber
global fileid
global glider          ;# array canvas id no.'s of the glider images.
global contestno       ;# current contest no.
global yfraction       ;# I can't remember what this was supposed to do but I was afraid to delete it
global xfraction       ;# I can't remember what this was supposed to do but I was afraid to delete it
global combatants      ;# a list of the players by their contest no.
global thermals        ;# a list of the thermals by no.
global thermalstrength ;# array strength of each thermal
global daystrength     ;# ramndom range for the average thermal strength
global autoscroll      ;# controls whether the map scrolls along with the glider
global tracking        ;# controls whether tracking is on or off
global distanceflown   ;# array distance flown for each glider
global angle_radians   ;# angle that changes to make the glider fly in a circle


#-------------------------------------------------------------------------------
#This does initialize some of the important global variables

set contestno IB
set yfraction 0
set xfraction 0
set TURNPOINT1 "Avenal"
set TURNPOINT2 "Delano"
set SPEED(IB) 60
set ALTITUDE(IB) 5000
set HEADING(IB) 0
set fileposition 332
set filecounter 0
set filelinenumber 0
set daystrength 6
set autoscroll on
set tracking on
set angle_radians 0


#-------------------------------------------------------------------------------


set turnpoints {Avenal Corcoran Delano Porterville "New Cuyama"}
set latdegrees  {36 36 35 36 34}
set latmin {0 6.15 44.74 1.78 57}
set londegrees {120 119 119 119 119}
set lonmin {8 35.69 14.19 3.76 42}

#-------------------------------------------------------------------------------

proc RandomInit {seed} {

  global randomSeed
  set randomSeed $seed
}

proc Random {} {
  global randomSeed

  set randomSeed [expr ($randomSeed*9301 + 49297) % 233280]
  return [expr $randomSeed/double(233280)]
}


proc RandomRange { range } {

  expr int([Random]*$range)
}


RandomInit [pid]

#-------------------------------------------------------------------------------
proc destroybuttons {} {
    
  foreach item [winfo children .frame] {
    destroy $item
  }
  
}
#-------------------------------------------------------------------------------
# this is for launching a new glider whenever the launch glider button is pressed.
# it is always launched at the first turnpoint that is currently selected with 5000 ft of altitude.
#-------------------------------------------------------------------------------
proc launchGlider { } {
    
  global XAXIS YAXIS COURSE ALTITUDE ID shadow contestno combatants X1 Y1 glider text

  set Y1 [expr $Y1 * 2136]
  set X1 [expr $X1 * 1759]
  
  ;# this creates the glider image
  ;# depending on the direction of flight, a different image is chosen.
      
  ;# this creates the glider image and the shadow image
  ;# this creates the shadow of the glider first so the glider will be over it in the object order
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {$XAXIS < 0 } {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if {$COURSE > 225 } {
      set shadow($contestno) [.c.canvas create image \
          [expr $X1 + ($XAXIS/2)] [expr $Y1 + ($YAXIS/2)] \
          -image glidershadowwest  -anchor center -tags "st $contestno"]

      set glider($contestno)  [.c.canvas create image $X1 $Y1 \
          -image gliderpairwest -anchor center -tags "st $contestno"]

    } else {

      set shadow($contestno)  [.c.canvas create image \
          [expr $X1 + ($XAXIS/2)] [expr $Y1 + ($YAXIS/2)] \
          -image glidershadowsouthwest  -anchor center -tags "st $contestno"]

      set glider($contestno)  [.c.canvas create image $X1 $Y1 \
          -image gliderpairsouthwest -anchor center -tags "st $contestno"]
    }
    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } else {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    if {$COURSE > 28 && $COURSE < 349} {
      set shadow($contestno) [.c.canvas create image \
          [expr $X1 + ($XAXIS/2)] [expr $Y1 + ($YAXIS/2)] \
          -image glidershadow -anchor center -tags "st $contestno" ]

      set glider($contestno)  [.c.canvas create image $X1 $Y1 \
          -image gliderpair -anchor center -tags "st $contestno"]

    } else {

      set shadow($contestno) [.c.canvas create image \
          [expr $X1 + ($XAXIS/2)] [expr $Y1 + ($YAXIS/2)] \
          -image glidershadownortheast -anchor center -tags "st $contestno" ]

      set glider($contestno) [.c.canvas create image $X1 $Y1 \
          -image gliderpairnortheast -anchor center -tags "st $contestno"]
    }
    
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   
  
  # place the contest no near the glider and move it along with it.
  #
  set text($contestno) [.c.canvas create text [expr $X1 + 22] [expr $Y1 + 3] \
      -text "$contestno" -fill red -tags "st $contestno"]
  
  # place some text that has the altitude displayed near the glider image
  #
  set ALTITUDE($contestno) 5000
  set ID($contestno) [.c.canvas create text [expr $X1 + 22] [expr $Y1 + 25] \
     -text "$ALTITUDE($contestno)" -fill black -tags "st $contestno"]
  
  
  # this raises the gliders and their shadows above the course line
  # 
  .c.canvas raise st line
  
  # these lines scroll the map to center the first  turnpoint where the 
  # new glider is launched.
  
  set Y1 [expr $Y1/2136]
  .c.canvas yview moveto $Y1

  set X1 [expr $X1/1759]
  .c.canvas xview moveto $X1
  
  # this adds the newly launched glider's contest no. to the list of "combatants"
  # 
  lappend combatants $contestno
    
}
#-------------------------------------------------------------------------------
# this calculates the great circle distance between the current two turnpoints 
#
#-------------------------------------------------------------------------------
proc calcdist  {latdeg1a latmin1a londeg1a lonmin1a latdeg2a latmin2a londeg2a lonmin2a} {
    
  global IC
  
  set A [ expr (($latdeg1a + $latmin1a / 60)  * 3.1416 / 180) ]
  
  set B [ expr  (($latdeg2a + $latmin2a / 60) * 3.1416 / 180) ]
  set X [ expr  (($londeg1a + $lonmin1a / 60) * 3.1416 / 180) ]
  set Y [ expr  (($londeg2a + $lonmin2a / 60) * 3.1416 / 180) ]

  set IT [ expr sin($A) * sin($B) + cos($A) * cos($B) * cos($X -$Y)]
  set IC [ expr 3.1416 / 2 - 2 * atan($IT / (1 + sqrt(1 - $IT * $IT)))]
  
}
#-------------------------------------------------------------------------------
# this plots the course line between the two turnpoints selected see below for more info.
#
#-------------------------------------------------------------------------------
proc plotline  {latdeg1a latmin1a londeg1a lonmin1a latdeg2a latmin2a londeg2a lonmin2a} {
    
  global contestno  combatants X1 Y1 X2 Y2 ALTITUDE ID shadow daystrength XAXIS YAXIS
  
  # this calculates the X Y coordinates of the two selected turnpoints and
  # plots a line between them on the canvas widget
  
  # upper left corner of map is 37deg 00min N. and 120deg 33min W
  # this is equal to 2220 and 7233 in minutes respectively
  # there are 14.23 pixels per minute of latitude (vertical direction)
  # there are 9.37 pixels per minute of longitude (horizontal direction)
  # this would have to be changed for each different map
  # but would be cool to have a routine like winGPS that could calibrate the
  # map by sensing the mouse position and entering two known positions
  
    
  # this calibrates the latitude and longitude coodinates to the pixel coordinate system
  # that Tcl/Tk uses for the background image.  This will have to be redone with different
  # numbers for different maps.
  
  set X1 [ expr 7232.5 - (($londeg1a * 60) + $lonmin1a) ]
  set X1 [expr $X1 * 11.6 ]
  
  set Y1 [ expr 2222 - (($latdeg1a *60) + $latmin1a) ]
  set Y1 [ expr $Y1 * 13.8 ]
  
  set X2 [ expr 7232.5 -(($londeg2a * 60) + $lonmin2a) ]
  set X2 [ expr $X2 * 11.6 ]
  
  set Y2 [ expr 2222 -(($latdeg2a * 60) + $latmin2a) ]
  set Y2 [ expr $Y2 * 13.8 ]
  
        
  # this puts a glider bitmap cursor over the first turnpoint selected
  
  #.c.canvas delete st
  .c.canvas delete rm
  .c.canvas delete line
  .c.canvas delete logo
  .c.canvas delete logo2
  .c.canvas delete thermal
  .c.canvas delete strength
  .c.canvas delete shadow
  .c.canvas delete laser
  
  # draws the yellow line on the canvas after the start new leg button is pressed
  
  .c.canvas create line $X1 $Y1 $X2 $Y2 -width 3 -fill yellow -tag line
  
  
  # This calls the procedure that generates some random thermals and plots their position on the map
  # See comment above the procedure code
  
  generateThermals $X1 $Y1 $X2 $Y2 $daystrength
  
  # this places the green circles around the selected goal turnpoint
  
  .c.canvas create oval [expr $X2 - 70] [expr $Y2 - 70] [expr $X2 + 70] [expr $Y2 + 70] -outline green -width 2 -tags rm
  .c.canvas create oval [expr $X2 - 140] [expr $Y2 - 140] [expr $X2 + 140] [expr $Y2 + 140] -outline green -width 2 -tags rm
  .c.canvas create oval [expr $X2 - 210] [expr $Y2 - 210] [expr $X2 + 210] [expr $Y2 + 210] -outline green -width 2 -tags rm
  
  
  ;# this raises the course line above the green circles around the goal.
  
  .c.canvas raise line rm
  
  
  # this scrolls the map to appoximately center the first turnpoint in view.
  
  set Y1 [expr $Y1/2136]
  #.c.canvas yview moveto [expr $Y1/2136]
  .c.canvas yview moveto $Y1
  set X1 [expr $X1/1759]
  #.c.canvas xview moveto [expr $X1/1759]
  .c.canvas xview moveto $X1
    
}
#-------------------------------------------------------------------------------
# this calculates the compass heading based on the trigonometric funtions of the angles
# determined by which turnpoints are selected and whether the numbers are negative or
# positive which translates into east/west north/south directions. The compass variation
# of 15 deg. E. is subtracted. This would be different for different locations.
#
#-------------------------------------------------------------------------------
proc calcheading {latdeg1a latmin1a londeg1a lonmin1a latdeg2a latmin2a londeg2a lonmin2a} {
    
  global COURSE
  global XAXIS
  global YAXIS
  global HEADING
  
  if {[expr $latdeg2a + $latmin2a] != [expr $latdeg1a + $latmin1a]} {
    set YAXIS [expr (($latdeg1a * 60) + $latmin1a) - (($latdeg2a * 60) + $latmin2a)]
    
  }
  
  if {[expr $londeg2a + $lonmin2a] != [expr $londeg1a + $lonmin1a]} {
    set XAXIS [expr (($londeg1a * 60) + $lonmin1a) - (($londeg2a * 60) + $lonmin2a)]
    
  }
  
  if {$XAXIS != 0 } {
    set TN [expr $YAXIS / $XAXIS]
    set ANGLE [expr atan($TN) * (180 / 3.1416)]
    
  }
  
  if {$XAXIS > 0 && $YAXIS < 0} {
    set COURSE [expr 90 + $ANGLE - 15]
    
    
    if {$COURSE <= 0} {
      set COURSE [expr $COURSE + 360]
    }
    
    
  }
  if {$XAXIS > 0 && $YAXIS > 0} {
    set COURSE [expr 90 + $ANGLE -15]
  }
  
  
  if {$XAXIS < 0 && $YAXIS < 0} {
    set COURSE [expr 270 + $ANGLE -15]
  }
  
  if {$XAXIS < 0 && $YAXIS > 0 } {
    set COURSE [expr 270 + $ANGLE  -15]
  }
  
  if {$XAXIS == 0 && $YAXIS > 0 } {
    set COURSE [expr 180 -15]
  }
  
  if {$XAXIS == 0 && $YAXIS < 0} {
    set COURSE [expr 360   -15]
  }
    
}
#-------------------------------------------------------------------------------
# this is used for stearing the gliders. Each frame of the animation will add or
# subtract a bit to the direction of movement of the gliders in the x and y direction
# depending on the value of the slider widget variable and the COURSE variable
# I think this could be used to make them circle also 
#
#-------------------------------------------------------------------------------
proc calcheadingchange {heading_change} {

  global XAXIS YAXIS HEADING XCHANGE YCHANGE contestno COURSE SPEED angle_radians
  
  # if heading change input is > 40 or < -40, make the glider circle
  # radius of circle tightens as absolute value of heading_change input increases
  # 100 points of the circle are plotted with each circle
  
  if {$heading_change > 40 || $heading_change < -40} {
    # reduce the glider speed to 0 so the circle will not continue on the course line
    set SPEED($contestno) 0
    # increase the angle in radians to 1/100th of the number of radians in a circle
    set angle_radians  [expr $angle_radians + (6.2332/100)]
    # this makes the glider circle to the right if the heading_change input is positive,
    # or right arrow input and to the left if negative, or left arrow input.
    if {$heading_change > 0} {
      set XCHANGE($contestno) [expr cos($angle_radians) * (12000/$heading_change)]
      set YCHANGE($contestno) [expr sin($angle_radians) * (12000/$heading_change)]
    } else {
      set XCHANGE($contestno) [expr (cos($angle_radians) * (12000/$heading_change))]
      set YCHANGE($contestno) [expr -(sin($angle_radians) * (12000/$heading_change))]
    }
    # return now, so the normal heading change calculations below will not be performed
    # when circling
    return 
  } else {
    # if the glider has been circling, but now you decrease the steering input below
    # the circling threshold in order
    # to stop circling, set the speed back to a default value of 60kts. 
    if {$SPEED($contestno) == 0} {  
      set angle_radians 0
      set SPEED($contestno) 60
    }
    
    
  }
  
  #if {$heading_change > 15 || $heading_change < 15} {
  #   set SPEED($contestno) 0 
  #}

  # this is like for Delano to Porterville - eastward direction
  if {$XAXIS > 0 && $YAXIS < 0 } {
    if {$COURSE < 30} {
      set XCHANGE($contestno) [expr $XCHANGE($contestno) + (10 * tan($heading_change/57.295))]
      set XCHANGE($contestno) [format "%3.2f" $XCHANGE($contestno)]
    } else {
      set YCHANGE($contestno) [expr $YCHANGE($contestno) + (10 * tan($heading_change/57.295))]
      set YCHANGE($contestno) [format "%3.2f" $YCHANGE($contestno)]
    }
  }
  
  # this is like for Avenal to Delano - southeastward direction
  
  if {$XAXIS > 0 && $YAXIS > 0} {
    if {$COURSE > 119 } {
      set XCHANGE($contestno) [expr $XCHANGE($contestno) - (10 * tan($heading_change/57.295))]
      set XCHANGE($contestno) [format "%3.2f" $XCHANGE($contestno)]
    } else {
      set YCHANGE($contestno) [expr $YCHANGE($contestno) + (10 * tan($heading_change/57.295))]
      set YCHANGE($contestno) [format "%3.2f" $YCHANGE($contestno)]
    }
  }
  
  # this is like for Porterville to Corcoran - westward direction
  
  if {$XAXIS < 0 && $YAXIS < 0} {
    if {$COURSE > 290 } {
      set XCHANGE($contestno) [expr $XCHANGE($contestno) + (10 * tan($heading_change/57.295))]
      set XCHANGE($contestno) [format "%3.2f" $XCHANGE($contestno)]
    } else {
      set YCHANGE($contestno) [expr $YCHANGE($contestno) - (10 * tan($heading_change/57.295))]
      set YCHANGE($contestno) [format "%3.2f" $YCHANGE($contestno)]
    }
  }
  
  # this is like for Porterville to Avenal or New Cuyama - southwestward direction
  if {$XAXIS < 0 && $YAXIS > 0 } {
    if {$COURSE < 215 } {
      set XCHANGE($contestno) [expr $XCHANGE($contestno) - (10 * tan($heading_change/57.295))]
      set XCHANGE($contestno) [format "%3.2f" $XCHANGE($contestno)]
    } else {
      set YCHANGE($contestno) [expr $YCHANGE($contestno) - (10 * tan($heading_change/57.295))]
      set YCHANGE($contestno) [format "%3.2f" $YCHANGE($contestno)]
    }
  }
     
}
#-------------------------------------------------------------------------------
# this just gets the coordinates from the lists that store those 
#-------------------------------------------------------------------------------
proc getcoord {} {

  global TURNPOINT1
  global TURNPOINT2
  global turnpoints
  global latdegrees
  global latmin
  global londegrees
  global lonmin
  global latdeg1
  global latmin1
  global londeg1
  global lonmin1
  global latdeg2
  global latmin2
  global londeg2
  global lonmin2
  set index [lsearch $turnpoints $TURNPOINT1]
  set latdeg1 [lindex $latdegrees $index]
  set latmin1 [lindex $latmin $index]
  set londeg1 [lindex $londegrees $index]
  set lonmin1 [lindex $lonmin $index]
  
  
  set index [lsearch $turnpoints $TURNPOINT2]
  set latdeg2 [lindex $latdegrees $index]
  set latmin2 [lindex $latmin $index]
  set londeg2 [lindex $londegrees $index]
  set lonmin2 [lindex $lonmin $index]
    
}
#-------------------------------------------------------------------------------
# this sets up the canvas that displays everything on the map
#-------------------------------------------------------------------------------
proc ScrolledCanvas {c width height region } {

  frame $c -bg red -bd 3
  
  canvas $c.canvas -width $width -height $height \
    -scrollregion $region \
    -xscrollcommand [list $c.xscroll set] \
    -yscrollcommand [list $c.yscroll set]
  scrollbar $c.xscroll -orient horizontal \
    -command [list $c.canvas xview]
  scrollbar $c.yscroll -orient vertical \
    -command [list $c.canvas yview]
  pack $c.xscroll -side bottom -fill x
  pack $c.yscroll -side right -fill y
  pack $c.canvas -side left -fill both -expand true
  pack $c -side top -fill both -expand true
  
  
  $c.canvas create image 1359 1836 -image sectional -anchor se
  $c.canvas create image 40 40 -image gliders -anchor center -tag movable
  $c.canvas create image 40 40 -image gliderpair -anchor center -tag  movable
  $c.canvas bind movable <Button-1> {CanvasMark %x %y %W}
  $c.canvas bind movable <B1-Motion> {CanvasDrag %x %y %W}
    
}
#-------------------------------------------------------------------------------
proc CanvasMark { x y w } {

  global canvas  
  # Rememer the object and its location

  set canvas($w,obj) [$w find closest $x $y]
  set canvas($w,x) $x
  set canvas($w,y) $y

}
#-------------------------------------------------------------------------------
proc CanvasDrag { x y w } {

  # Move the current object
  global canvas
  
  set dx [expr $x - $canvas($w,x)]
  set dy [expr $y - $canvas($w,y)]
  
  $w move $canvas($w,obj) $dx $dy
  
  set canvas($w,x) $x
  set canvas($w,y) $y
}
#-------------------------------------------------------------------------------
# code for animating the glider bitmaps stolen from the Tcl Cookbook website
# this is the code that moves everything on the canvas display tim is the 
# argument that determines how fast the screen updates
# 
#-------------------------------------------------------------------------------
proc movie {tim} {

  global id              ;# used in movie procedure to restart it after the tim interval
  global ID              ;# array that keeps track of the altitude display for each combatant glider
  global XAXIS           ;# the amount of movement in the x direction for each screen update
  global YAXIS           ;# the amount of movement in the y direction for each screen update
  global SPEED           ;# array current speed value for each combatant indexed by contestno from the combatant list
  global ALTITUDE        ;# array current altitude for each combatant indexed by contestno from the combatant list
  global X1              ;# x coordinate of the first turnpoint currently selected
  global Y1              ;# y coordinate of the first turnpoint currently selected
  global combatants      ;# list contest no's of each contestant or "combatant"
  global contestno       ;# for each glider on the display
  global shadow          ;# array shadows for each glider indexed by their contest no. from the combatant list
  global HEADING         ;# array heading change right or left for each glider indexed by contest no from combatant list
  global COURSE          ;# calculated course heading between the two selected turnpoints
  global text            ;# array that holds each contestant's contest no.
  global thermals        ;# list of the thermals
  global thermalstrength ;# array that stores the stregth of each thermal
  global autoscroll      ;# variable that controls whether autoscrolling is enabled
  global tracking        ;# variable that controls whether tracking is enabled
  global glider          ;# array canvas id no.'s of the glider images
  global XCHANGE         ;# array amount of heading change for each glider
  global YCHANGE         ;# array amount of heading change for each glider.

  set headingchange 0
  focus .c.canvas        ;# this prevents the space bar from entering spaces in the contest No. entry box when you press it
  ;# to fire the projectiles
  
  ;# go through list of combatants and move each one and change altitude display
  
  
  for {set x 0} {$x < [llength $combatants]} {incr x} {
    set thermalfactor 0
    
    if {[lindex $combatants $x] == ""} {continue}
    ;# this creates the laser missles when the spacebar is pressed
    
    bind . <KeyPress-space> ".c.canvas create line \
                [expr [lindex [.c.canvas coords $glider([lindex $combatants $x])] 0] + ($XAXIS/15)] \
                [expr [lindex [.c.canvas coords $glider([lindex $combatants $x])] 1] + ($YAXIS/15)] \
                [expr [lindex [.c.canvas coords $glider([lindex $combatants $x])] 0] - ($XAXIS/15)] \
                [expr [lindex [.c.canvas coords $glider([lindex $combatants $x])] 1] - ($YAXIS/15)] \
                -width 3 -fill purple -arrow first -arrowshape {1 10 6} -tags laser "
    
    
    ;# check if the altitude has reached 0 and stop that glider, change altitude display to LANDED OUT
    if { $ALTITUDE([lindex $combatants $x]) > 0 } {
      
      
      ;# check to see if there has been an input to the steering slider
      if {$HEADING([lindex $combatants $x]) != 0} {
        
        calcheadingchange $HEADING([lindex $combatants $x])
        
                
      }
      
      ;# this plots the track of the glider in red if tracking is enabled
      
      if {$tracking == "on"} {
        .c.canvas create oval [lindex [.c.canvas coords $glider([lindex $combatants $x])] 0]\
          [lindex [.c.canvas coords $glider([lindex $combatants $x])] 1] \
          [lindex [.c.canvas coords $glider([lindex $combatants $x])] 0] \
          [lindex [.c.canvas coords $glider([lindex $combatants $x])] 1] \
          -width 1 -outline red -tags track
        catch {.c.canvas lower track $contestno}
        catch {.c.canvas lower $shadow([lindex $combatants $x]) [lindex $combatants $x]}
        catch {.c.canvas lower track st}
      }
      
      ;# move the current glider a distance proportional to it's speed along the course direction
      .c.canvas move $glider([lindex $combatants $x]) [expr ($XCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x])))]\
        [expr ($YCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x])))]
      
      ;# move the other objects tagged with the glider's contest no.
      .c.canvas move $shadow([lindex $combatants $x]) \
        [expr ($XCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x]))) - (.00001 * $ALTITUDE([lindex $combatants $x]))]\
        [expr ($YCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x]))) - (.0000075 * $ALTITUDE([lindex $combatants $x]))]
      
      
      
      
      .c.canvas move $ID([lindex $combatants $x]) [expr ($XCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x])))] \
        [expr ($YCHANGE([lindex $combatants $x])/(275 -$SPEED([lindex $combatants $x])))]
      
      .c.canvas move $text([lindex $combatants $x]) [expr ($XCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x])))] \
        [expr ($YCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x])))]
      
      ;# this moves the laser missles
      
      .c.canvas move laser [expr ($XCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x]))) + ($XCHANGE([lindex $combatants $x])/25)] \
        [expr ($YCHANGE([lindex $combatants $x])/(275 - $SPEED([lindex $combatants $x]))) + ($YCHANGE([lindex $combatants $x])/25)]
      
      
      ;# check current coordinate and check to see if inside bounding box of any thermals then adjust altitude change by thermal strength
      
      for {set y 0 } {$y < [llength $thermals]} { incr y} {
        
        set coordinates [.c.canvas coords $glider([lindex $combatants $x])]
        
        set thermalbox [.c.canvas bbox [lindex $thermals $y]]
        
        if {[lindex $coordinates 0] >= [lindex $thermalbox 0] && [lindex $coordinates 0] <= [lindex $thermalbox 2]
            && [lindex $coordinates 1] >= [lindex $thermalbox 1] && [lindex $coordinates 1] <= [lindex $thermalbox 3]} {
          set thermalfactor $thermalstrength([lindex $thermals $y])
          
        }
        
      }
      
      
      ;# check to see if the glider has been hit by a missle
      foreach item [.c.canvas find withtag laser] {
        set coordinates [.c.canvas coords $item]
        
        set gliderbox [.c.canvas bbox $glider([lindex $combatants $x])]
        
        if {[lindex $coordinates 0] >= [lindex $gliderbox 0] && [lindex $coordinates 0] <= [lindex $gliderbox 2]
            && [lindex $coordinates 1] >= [lindex $gliderbox 1] && [lindex $coordinates 1] <= [lindex $gliderbox 3]
            && [lindex $combatants $x] != $contestno } {
          catch { .c.canvas itemconfigure $glider([lindex $combatants $x]) -image destroyed}
          catch { .c.canvas itemconfigure $shadow([lindex $combatants $x]) -image destroyedshadow}
          set ALTITUDE([lindex $combatants $x]) 0
          .c.canvas dchars $ID([lindex $combatants $x]) 0 end
          .c.canvas insert $ID([lindex $combatants $x]) 0 "DESTROYED"
          
          
          
        }
        
      }
      
            
            
      # this tries to approximate a sailplane polar performance curve by subtracting some altitude
      # proportional to the speed. It is somewhat parabolic. Little is subtracted at lower speeds 
      # but much more at a rapidly increasing rate is subtracted at high speeds
      
      set ALTITUDE([lindex $combatants $x]) [expr $ALTITUDE([lindex $combatants $x]) - [expr int(pow($SPEED([lindex $combatants $x]),1.8)/1000)]]
      
      # add some altitude if inside a thermal
      
      set ALTITUDE([lindex $combatants $x])  [expr $ALTITUDE([lindex $combatants $x]) + (2 * $thermalfactor)]
      
      # delete and update the altitude display for each framechange
      if {[.c.canvas itemcget $ID([lindex $combatants $x]) -text] != "DESTROYED"} {
        .c.canvas dchars $ID([lindex $combatants $x]) 0 end
        .c.canvas insert $ID([lindex $combatants $x]) 0 $ALTITUDE([lindex $combatants $x])
      }
               
    } elseif { [.c.canvas itemcget $ID([lindex $combatants $x]) -text] != "DESTROYED"} {
      
      .c.canvas dchars $ID([lindex $combatants $x]) 0 end
      .c.canvas insert $ID([lindex $combatants $x]) 0 "LANDED OUT"
      .c.canvas delete $shadow([lindex $combatants $x])
    }
      
  }
  
  ;# this scrolls the background map proprotional to the speed and direction of the course line
  
  if {$autoscroll == "on" } {
    
    set Y1 [expr (($YAXIS/(275 - $SPEED($contestno))) * .0007) + $Y1]
    .c.canvas yview moveto $Y1
    
    set X1 [expr (($XAXIS/(275 - $SPEED($contestno))) * .0007) + $X1]
    .c.canvas xview moveto $X1
     
  }
  
  set id [after $tim movie $tim]
  
}
#-------------------------------------------------------------------------------
# this gets called to start up the animation it calls the movie proc
# that loops to cause the actual animation
#-------------------------------------------------------------------------------
proc displayInfo {} {
    
  global X1 Y1
  global contestno
  global SPEED
  global COURSE
  global HEADING
  global XAXIS
  global YAXIS
  global XCHANGE
  global YCHANGE
  global combatants
  
  .turnpointframe.speedscale config -variable SPEED($contestno)
  .turnpointframe.speedscale config -label "SPEED $contestno - kts."
  set SPEED($contestno) 60
  .turnpointframe.headingscale config -variable HEADING($contestno)
  .turnpointframe.headingscale config -label "Steer $contestno  - L/R"
  set HEADING($contestno) 0
  
  set XCHANGE($contestno) $XAXIS
  set YCHANGE($contestno) $YAXIS
  
  
  movie 250

  .turnpointframe.flybutton configure -text " Stop Flying  " -command \
    {global id
      
      after cancel $id
      .turnpointframe.flybutton configure -text {The End}
      after 1000
      .turnpointframe.flybutton configure -text " Start Flying  " -command {displayInfo}
    }

}
#-------------------------------------------------------------------------------
# this is one attempt to read the Garman .trk file and plot on map
# not currently used.
#-------------------------------------------------------------------------------
proc gpsdisplay1 { } {

  set fileid [open "test2.trk" r]
  seek $fileid -54 end
  
  set dataline [gets $fileid]
  set latitude1 [string range $dataline 4 5]
  set latitude2 [string range $dataline 6 10]
  set longitude1 [string range $dataline 16 18]
  set longitude2 [string range $dataline 19 23]
  
  
  close $fileid
  set X1 [ expr 7232.5 - (($longitude1 * 60) + $longitude2) ]
  set X1 [expr $X1 * 11.6 ]
  
  set Y1 [ expr 2222 - (($latitude1 *60) + $latitude2) ]
  set Y1 [ expr $Y1 * 13.8 ]
  
  .c.canvas create image $X1 $Y1 -image gliderpair -anchor center -tags st
  
}
#-------------------------------------------------------------------------------
# Another attempt to plot the Garman .trk file - not currently used
#-------------------------------------------------------------------------------
proc gpsdisplay2 {} {
    
  global fileid
  global filelinenumber
  
  set filelinenumber 0
  
  set fileid [open "test2.trk" r]
  while {[eof $fileid] != 1}  {
    
    set a  [gets $fileid]
    set b [eof $fileid]
    incr filelinenumber
    
  }
  set filelinenumber [expr $filelinenumber - 15]
  close $fileid
  
      
  for {set x 0} {$x < $filelinenumber} {incr x 1} {
    ;# time {set a "Hello World"} 20000
    set fileid [open "test2.trk" r]
    seek $fileid [ expr (($x * 54)+ 332)] start
    set dataline [gets $fileid]
    set latitude1 [string range $dataline 4 5]
    set latitude2 [string range $dataline 6 10]
    set longitude1 [string range $dataline 16 18]
    set longitude2 [string range $dataline 19 23]
    
    close $fileid
    set X1 [ expr 7232.5 - (($longitude1 * 60) + $longitude2) ]
    set X1 [expr $X1 * 11.6 ]
    
    set Y1 [ expr 2222 - (($latitude1 *60) + $latitude2) ]
    set Y1 [ expr $Y1 * 13.8 ]
    
    ;#      .c.canvas create image $X1 $Y1 -image gliderpair -anchor center -tags st
    .c.canvas create oval [expr $X1 - 2] [expr $Y1 - 2] [expr $X1 + 2] [expr $Y1 + 2] -outline red -width 2 -tags rm
    
  }

}
#-------------------------------------------------------------------------------
# this was another attempt to plot Garman .trk file - this is current one
# in use along with gpsdisplay4 which calls it
#-------------------------------------------------------------------------------
proc gpsdisplay3 {} {

  global fileposition
  global filecounter
  global filelinenumber
  global fileid
    
  set fileid [open "test2.trk" r]
  while {[eof $fileid] != 1}  {
    
    set a  [gets $fileid]
    set b [eof $fileid]
    incr filelinenumber
    
  }
      
  set filelinenumber [expr $filelinenumber - 13]
  seek $fileid [ expr (($filecounter * 54)+ $fileposition)] start
  set filecounter [expr $filecounter + 1]
  set dataline [gets $fileid]
  set latitude1 [string range $dataline 4 5]
  set latitude2 [string range $dataline 6 10]
  set longitude1 [string range $dataline 16 18]
  set longitude2 [string range $dataline 19 23]
  
  set X1 [ expr 7232.5 - (($longitude1 * 60) + $longitude2) ]
  set X1 [expr $X1 * 11.6 ]
  
  set Y1 [ expr 2222 - (($latitude1 *60) + $latitude2) ]
  set Y1 [ expr $Y1 * 13.8 ]
  
  .c.canvas create image $X1 $Y1 -image gliderpair -anchor center -tags st
  
  gpsdisplay4
      
}
#-------------------------------------------------------------------------------
proc gpsdisplay4 {} {

  global filecounter
  global filelinenumber
  global fileid
  
  
  if {$filecounter <= $filelinenumber} {
    set filelinenumber 0
    gpsdisplay3
    
  } else {
    set filecounter 0
    set filelinenumber 0
    close $fileid
  }
    
}
#-------------------------------------------------------------------------------
# The code to generate some random thermals of random strength in the area
# of the bounding box associated with the line that represents the course
# line of the current leg which is created in the plotline procedure
#-------------------------------------------------------------------------------
proc generateThermals {X1 Y1 X2 Y2 daystrength} {
    
  global thermals thermalstrength
  ;# this makes sure that there is always one tiny thermal, then even if you by chance get 0 for the random no. of thermals,
  ;# the proc won't crash.
  set ID1 [.c.canvas create oval 1 3 5 7 -fill black -stipple gray12]
  
  lappend thermals $ID1
  
  ;# attempt to generate a set of thermals randomly - the number, strength and size in area are all set
  ;# separately but have a higher chance of being more numerous and stronger depending on the daystrength
  ;# variable that the user can set.
  
  for {set x 0} {$x < [RandomRange $daystrength]} {incr x} {
    
    ;# find out the lengths of the sides of the bounding box of the course line - all the thermals will be in
    ;# this area only, prevents plotting thermals where you are never going to fly for the current course.
    set xrange [expr $X2 - $X1]
    set yrange [expr $Y2 - $Y1]
    
    ;# this calculates the upper left and lower right corners of the bounding box for each thermal oval
    set bboxx1 [expr $X1 + [RandomRange $xrange]]
    set bboxy1 [expr $Y1 + [RandomRange $yrange]]
    
    ;# this actually plots the thermal ovals in the randomly generated positions determined above
    ;# the size is a random range up to 100 pixels but you could set this to a different number if desired.
    ;#  set ID2 [.c.canvas create oval $bboxx1 $bboxy1  [expr $bboxx1 + [RandomRange 100]] [expr $bboxy1 + [RandomRange 100]] -fill black -stipple gray12 -tag thermal]
    set ID2 [.c.canvas create image [expr $bboxx1 + [RandomRange 100]] [expr $bboxy1 + [RandomRange 100]] -image dustdevil -tag thermal]
    
    ;# this adds the id no. of each thermal to the list thermals for later querying when a glider flies into it's bounding box
    ;# the value of the thermal's strength can be queried.
    lappend thermals $ID2
    
    ;# this sets the thermal strength to a random value but max is determined by the user controllable daystrength variable
    set thermalstrength($ID2) [RandomRange $daystrength]
    if {$thermalstrength($ID2) == 0 } {set thermalstrength($ID2) 1}
    .c.canvas scale $ID2 [lindex [.c.canvas coords $ID2] 0] [lindex [.c.canvas coords $ID2] 1]  $thermalstrength($ID2) $thermalstrength($ID2)
    
    ;# this plots a text representation of the thermal's strength in the upper left corner of the thermal's bounding box
    .c.canvas create text [lindex [.c.canvas coords $ID2] 0] [lindex [.c.canvas coords $ID2] 1] -text "$thermalstrength($ID2)" -fill red -tags strength
    
  }
    
}
#-------------------------------------------------------------------------------
# the code for the bitmap display for the small glider images - supposed to be
# an AS-H 25. The first one is for a glider flying southeast.
#-------------------------------------------------------------------------------

set g {R0lGODdhXQBbAPUAAAAAAP///1WSVf+SqgBJVVVJAFVJ/6q2VQAkqlUkVVVtqlWS/6ptVaqS
    qv+2/wAAVQBJAABJ/1VJqlVtAKpJVaq2qv+2Vf+2qgAkAAAkVQBJqlUkAFVJVVVtVVVt/1WS
    qqptqqqSVarbqqrb///bqv/b/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
    AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAAXQBbAAAG
    /kCAcEgsGo/IpHLJbDqf0Kh0Sq1ar9isdsvter/gsHhMLpvP4wsGzU4yOu14EXOR24UX+D3e
    OOzjBBYZf20XFYRsISRriGYJFSGNZxVqkmUMInqWXQpEGJSbXg2aAAMHHKFdJUQcFSSpXBWk
    FweMsEakTQSrQw0WDbdHDZFQJRNDBa7BRopRIbxCrqjLQ60btk0jmiGG1ERqDdNNFdAblNjU
    qB3ETB0lmpQC3rgM4koj0CGg80Uc60wNSOjhcOECBH5zCnBY8wBCAoX+IuKDYMiQAAkIMjxA
    yGTDtRIC3xygdEBBBxAKNGSwx9FIAxG8CjS4MIEDBwofOjCot6Hl/hEMJUowonQIADqfSC6M
    KNqqEqxOVxSAFELn1K0QwK6IIAFV3ytY7o5GaVBihBCCFcQSSrArl5QMMAsIUcTS0rtBVkiU
    EDG3QtFU8Rr0pMIAnxAIAQeHagUARIcGapmA/ICnglxYBITo/FB3nIgAQhjsW0bA8agoHMrK
    TSDCQmRJGPw1EACicxIHMIUcuICXHweHZ6dBTmBTdoC9JRREMKBhgUakP4UQ2KBAALkKHyRo
    qOBBgQcNCmxDB7A3bUQQAroraFAh6/hvIhwIGYwtw+uWDfCtweCA3fskIMB0EAAB/bcEUH7N
    l5aBSuAmXzQMMJhEBTAxwoEFEiLBnlBDYXyVYT8VDhHCff9dx8qHRpSHohIvQbOiS/GRmGGI
    Lx5RlngrVjBChDW6BEmPuCQIpCcluDekEA78dSQAQi4JQAdKHgmUjBly6OSVWGap5ZZcdunl
    l2CGKeaYZJZp5plgBgEAOw}

#-------------------------------------------------------------------------------
# this one is for a glider flying about due west
#-------------------------------------------------------------------------------

set west {

  #define west_width 42
  #define west_height 52
  static char west_bits[] = {
    0x01,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x02,0x00,0x00,
    0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,
    0x0c,0x00,0x00,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x00,0x00,0x18,0x00,0x00,
    0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,0x00,
    0x60,0x00,0x00,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x00,0xc0,0x00,0x00,
    0x00,0x00,0x00,0x80,0x01,0x00,0x00,0x00,0x00,0x80,0x01,0x00,0x00,0x00,0x00,
    0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x06,0x00,
    0x00,0x08,0x00,0x00,0x0e,0x00,0x00,0x10,0x00,0x00,0x0c,0x00,0x00,0x20,0x00,
    0x00,0x1c,0x00,0x00,0x60,0x00,0x00,0x18,0x00,0x00,0xf0,0x00,0x00,0x30,0x00,
    0x00,0xb8,0x01,0x00,0x70,0x00,0x00,0x1c,0x03,0x00,0x60,0x00,0x00,0x1e,0x00,
    0x00,0xe0,0xff,0xff,0x0f,0x00,0x00,0xfe,0xff,0x1f,0x00,0x00,0xc0,0xff,0x0f,
    0x00,0x00,0x00,0xf0,0x7f,0x03,0x00,0x00,0x00,0x00,0x00,0x07,0x00,0x00,0x00,
    0x00,0x00,0x0e,0x00,0x00,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x00,0x00,0x1c,
    0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,
    0x00,0x00,0xe0,0x00,0x00,0x00,0x00,0x00,0xc0,0x00,0x00,0x00,0x00,0x00,0xc0,
    0x01,0x00,0x00,0x00,0x00,0x80,0x03,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,
    0x00,0x00,0x00,0x0e,0x00,0x00,0x00,0x00,0x00,0x0c,0x00,0x00,0x00,0x00,0x00,
    0x18,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,
    0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x00,0x00,0xc0,0x00,0x00,0x00,0x00,0x00,
    0x80,0x01,0x00,0x00,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x00,0x00,0x02,0x00,
    0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x08,0x00};
}

#-------------------------------------------------------------------------------
# this one is for a glider flying northeast
#-------------------------------------------------------------------------------

set northeast {

  #define northeast_width 30
  #define northeast_height 57
    static char northeast_bits[] = {
        0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x60,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x80,0x00,0x00,0x00,0x80,0x00,
        0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x03,0x00,0x00,0x00,0x07,0x00,0x00,0x00,
        0x06,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x0c,0x00,0x00,0x00,0x18,0x00,0x00,
        0x00,0x38,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x70,0x00,0x02,0x00,0x60,0x00,
        0x02,0x00,0xe0,0x80,0x01,0x00,0xc0,0xc0,0x01,0x00,0x80,0xf1,0x00,0x00,0x80,
        0x73,0x00,0x00,0x00,0x7b,0x00,0x00,0x00,0x3f,0x00,0x00,0x00,0x3e,0x00,0x00,
        0x00,0x1f,0x00,0x00,0x00,0x07,0x00,0x00,0x80,0x1f,0x00,0x00,0x80,0x1b,0x00,
        0x00,0xc0,0x1b,0x00,0x00,0xc0,0x38,0x00,0x00,0x60,0x30,0x00,0x00,0x70,0x78,
        0x00,0x00,0x30,0x60,0x00,0x00,0x38,0x60,0x00,0x00,0x18,0x60,0x00,0x00,0x0c,
        0xc0,0x00,0x00,0x04,0xc0,0x01,0x01,0x02,0x80,0x01,0x81,0x03,0x80,0x03,0xf0,
        0x01,0x80,0x01,0xfe,0x00,0x00,0x02,0xee,0x00,0x00,0x03,0x06,0x00,0x00,0x03,
        0x04,0x00,0x00,0x02,0x0c,0x00,0x00,0x0c,0x04,0x00,0x00,0x0c,0x00,0x00,0x00,
        0x08,0x00,0x00,0x00,0x18,0x00,0x00,0x00,0x18,0x00,0x00,0x00,0x18,0x00,0x00,
        0x00,0x10,0x00,0x00,0x00,0x30,0x00,0x00,0x00,0x20,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x20};
}

#-------------------------------------------------------------------------------
# this one is for a glider flying southwest
#-------------------------------------------------------------------------------

set southwest {
    #define southwest_width 61
    #define southwest_height 29
    static char southwest_bits[] = {
        0x00,0x00,0x00,0x00,0x00,0x5f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x4e,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x0c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0c,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x0e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x01,0x00,0x00,
        0x00,0x80,0x00,0x00,0x00,0x0a,0x00,0x00,0x00,0xc0,0x00,0x00,0x00,0x60,0x00,
        0x00,0x00,0x70,0x00,0x00,0x00,0xc0,0x06,0x00,0x00,0x30,0x00,0x00,0x00,0x00,
        0x1e,0x00,0x00,0x18,0x00,0x00,0x00,0x00,0xf8,0x01,0x00,0x1e,0x00,0x00,0x00,
        0x00,0x80,0x0f,0x80,0x07,0x00,0x00,0x00,0x00,0x00,0x3d,0x80,0x01,0x00,0x00,
        0x00,0x00,0x00,0xec,0xc2,0x01,0x00,0x00,0x00,0x00,0x00,0xe0,0xf7,0x01,0x00,
        0x00,0x00,0x00,0x00,0x00,0xff,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0xf8,0x9f,
        0x00,0x00,0x00,0x00,0x00,0x00,0xbc,0xff,0x01,0x00,0x00,0x00,0x00,0x00,0x1e,
        0xf8,0x9f,0x00,0x00,0x00,0x00,0x00,0x1f,0x00,0xfe,0x07,0x00,0x00,0x00,0x00,
        0x07,0x00,0xa0,0x6e,0x01,0x00,0x00,0x00,0x03,0x00,0x00,0xf0,0x13,0x00,0x00,
        0xc0,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x40,0x00,0x00,0x00,0x00,0x00};
}


#-------------------------------------------------------------------------------
# this one is for a destroyed glider
#-------------------------------------------------------------------------------
set destroyed {
    #define destroyed_width 29
    #define destroyed_height 61
    static unsigned char destroyed_bits[] = {
        0x00, 0x00, 0x80, 0x07, 0x00, 0x00, 0xc0, 0x1f, 0x00, 0x00, 0xc0, 0x1f,
        0x01, 0x00, 0xc0, 0x10, 0x01, 0x00, 0xc0, 0x10, 0x03, 0x00, 0xe0, 0x00,
        0x0f, 0x00, 0xe0, 0x00, 0x0c, 0x00, 0x60, 0x00, 0x18, 0x00, 0x60, 0x00,
        0x30, 0x00, 0xe0, 0x00, 0x40, 0x40, 0x60, 0x00, 0x80, 0x67, 0x30, 0x00,
        0x00, 0x7f, 0x30, 0x00, 0x00, 0x7f, 0x30, 0x00, 0x00, 0x40, 0x30, 0x00,
        0x00, 0x00, 0x18, 0x00, 0x00, 0x60, 0x10, 0x00, 0x00, 0x00, 0x38, 0x00,
        0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x18, 0x00,
        0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x0c, 0x00,
        0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x0c, 0x00,
        0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x04, 0x00, 0x20, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x08, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00,
        0x03, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
        0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x10, 0x01, 0x00, 0x00, 0x18,
        0x00, 0x00, 0x00, 0x10, 0x00, 0x00, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x1c,
        0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x80, 0x02, 0x06,
        0x00, 0x00, 0x03, 0x06, 0x00, 0x00, 0x1e, 0x03, 0x00, 0x00, 0x3c, 0x07,
        0x00, 0x00, 0x78, 0x03, 0x00, 0x00, 0xf0, 0x01, 0x00, 0x00, 0xf0, 0x03,
        0x00, 0x00, 0xc0, 0x03};
}
#-------------------------------------------------------------------------------

set dustdevil {
    #define dustdevil_width 81
    #define dustdevil_height 89
    static char dustdevil_bits[] = {
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10,0x28,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x20,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0x00,
        0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x40,0x4c,0x09,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x82,0x92,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x0c,0xb6,0x01,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x90,0x05,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x64,0x45,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,
        0x00,0x41,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x99,0x13,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x34,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xac,0x52,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x10,0x0a,
        0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0xc0,0x0a,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x20,0xf4,0x16,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x22,0x0c,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x90,0x02,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x64,0x5a,0x15,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x20,0xd3,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xa0,
        0x21,0x18,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x42,0xa2,0x52,0x01,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x9d,0x21,0x3a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x40,0x41,0xc1,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf0,0x8a,0x05,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x60,0x3a,0x08,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0xa6,0xa9,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x10,
        0x28,0x59,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x82,0xfa,0x2b,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x40,0x40,0xa0,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x20,0x62,0xa9,0x25,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x58,0x29,
        0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,0xa9,0x15,0x0a,0x00,0x00,0x00,
        0x00,0x00,0x00,0xa0,0xed,0xef,0x95,0x32,0x00,0x00,0x00,0x00,0x00,0x00,0x20,
        0xf8,0xaf,0xa0,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x9c,0x39,0x22,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x80,0xeb,0xe2,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xa0,0x3b,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0x3f,
        0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf8,0x7e,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0xf2,0x3e,0x10,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0xfe,0x2b,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfd,0x27,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xbc,0x0f,0x06,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0xfe,0x0f,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0xfe,0x17,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x7d,0x87,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x20,0xfe,0x0f,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x40,0xfd,0x27,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xf2,
        0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0xf6,0x07,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0xff,0x04,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xbb,0x20,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xbe,0x05,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0x03,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x40,0x7a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x40,0xff,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0xfe,0x07,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,0xf6,0x01,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0xda,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x40,
        0x7f,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfd,0x01,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x40,0xdf,0x01,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x7e,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xee,
        0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0xff,0x01,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0xff,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0xfb,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0x01,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xee,0x01,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0xdf,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0xfe,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0x01,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xb6,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0xf6,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
        0xf6,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xce,0x01,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfe,0x01,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0x00,0x40,0x7f,0x12,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0xfd,
        0x05,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xc0,0xff,0x5d,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00,0x00,0xe4,0x7d,0xff,0x02,0x00,0x00,0x00,0x00,0x00,0x00,
        0x00,0xfd,0xaf,0xbe,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xd9,0x6b,0xbe,
        0x03,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x7d,0x7c,0xf7,0x00,0x00,0x00,0x00,
        0x00,0x00,0x00,0x00};
}

#-------------------------------------------------------------------------------

set bmp {
    #define pic45tra_width 93
    #define pic45tra_height 91
    static unsigned char pic45tra_bits[] = {
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x60, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x70, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x38, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x3c, 0x00, 0x00, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x3c, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x76, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xf0, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xe0, 0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xc0, 0x3f, 0x00, 0x1c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0xc0, 0xff, 0xff, 0xff, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x80, 0xff, 0x7f, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x80, 0xc3, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xc0, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0xe0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x38, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x80, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0xc0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x0c, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x80, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};
    
    
}
#-------------------------------------------------------------------------------
# this puts the distance of the current leg in statute mi., nautical mi.,  and km
# in the label boxes on the left. 
#-------------------------------------------------------------------------------
proc showdist {} {
    
  global IC
  global COURSE
  global TURNPOINT1
  global TURNPOINT2
  global autoscroll
  global tracking
  global distanceflown
  global contestno
  
  set COURSE [format "%3.2f" $COURSE]
  .turnpointframe.turnpointframe1.menu1 config -text $TURNPOINT1
  .turnpointframe.turnpointframe2.menu2 config -text $TURNPOINT2
  
  label .frame.label1 -text "distance from $TURNPOINT1 to $TURNPOINT2..." -relief groove
  label .frame.label3 -text "Auto Scroll ON/OFF"
  label .frame.label4 -text "Tracking ON/OFF"

  radiobutton .frame.button5 -text OFF -variable autoscroll -value off
  radiobutton .frame.button6 -text " ON" -variable autoscroll -value on
  radiobutton .frame.button3 -text OFF -variable tracking -value off
  radiobutton .frame.button4 -text " ON" -variable tracking -value on
  
  label .frame.[string tolower $contestno] -text "Distance flown by $contestno -"
  ;#if [info exists combatants] {
  ;#foreach item [split $combatants " "] {
  ;#label .frame.[string tolower $item] -text "Distance flown - $item"
  ;#}
  ;#}
  
  button .frame.button7 -text "[format "%3.2f" [expr $IC * (180 / 3.1416) * (60 / .54042)]] KM" \
         -relief sunken -borderwidth 3 -bg skyblue

  button .frame.button8 -text "[format "%3.2f" [expr $IC * (180 / 3.1416) * (60 / .8674)]] SM" \
         -relief sunken -borderwidth 3 -bg skyblue

  button .frame.button9 -text "[format "%3.2f" [expr $IC * 60 * 180 / 3.1416]] NM" \
         -relief sunken -borderwidth 3 -bg skyblue
  
  label .frame.label2 -text "Course - $COURSE deg.mag." -relief groove -bg peachpuff
  
  ;#pack .frame
  
  pack .frame.label3
    
  pack .frame.button5
  pack .frame.button6
  pack .frame.label4
     
  ;#if [info exists combatants] {
  ;#foreach item [split $combatants " "] {
  ;#pack  .frame.[string tolower $item]
  ;#}
  ;#}
  
  pack .frame.button3
  pack .frame.button4
  pack .frame.[string tolower $contestno]
  pack .frame.label1
  
  for {set i 7} {$i <= 9 } {incr i} {
    pack .frame.button$i
  }
  
  pack .frame.label2
  
}
#-------------------------------------------------------------------------------
proc getturnpoint {} {
    
  global TURNPOINT1
  global TURNPOINT2
  global X1 X2 Y1 Y2
  global contestno
  global SPEED
  global HEADING
  global daystrength
  
  frame .turnpointframe
  frame .turnpointframe.turnpointframe1
  frame .turnpointframe.turnpointframe2
  label .turnpointframe.turnpointframe1.label1 -text {Select Turnpoint 1} -relief groove
  label .turnpointframe.turnpointframe2.label2 -text {Select Turnpoint2 } -relief groove

  menubutton .turnpointframe.turnpointframe1.menu1 -text $TURNPOINT1 -menu .turnpointframe.turnpointframe1.menu1.sub1 -relief raised
  set men1 [menu .turnpointframe.turnpointframe1.menu1.sub1]
  $men1 add radio -label Avenal -variable TURNPOINT1 -value Avenal -command ".turnpointframe.turnpointframe1.menu1 configure -text Avenal"
  $men1 add radio -label Corcoran -variable TURNPOINT1 -value Corcoran  -command ".turnpointframe.turnpointframe1.menu1 configure -text Corcoran"
  $men1 add radio -label Delano -variable TURNPOINT1 -value Delano  -command ".turnpointframe.turnpointframe1.menu1 configure -text Delano"
  $men1 add radio -label Porterville -variable TURNPOINT1 -value Porterville  -command ".turnpointframe.turnpointframe1.menu1 configure -text Porterville"
  $men1 add radio -label {New Cuyama} -variable TURNPOINT1 -value {New Cuyama} -command ".turnpointframe.turnpointframe1.menu1 configure -text {New Cuyama}"
  menubutton .turnpointframe.turnpointframe2.menu2 -text $TURNPOINT2 -menu .turnpointframe.turnpointframe2.menu2.sub1 -relief raised
  set men2 [menu .turnpointframe.turnpointframe2.menu2.sub1]
  $men2 add radio -label Avenal -variable TURNPOINT2 -value Avenal -command ".turnpointframe.turnpointframe2.menu2 configure -text Avenal"
  $men2 add radio -label Corcoran -variable TURNPOINT2 -value Corcoran -command ".turnpointframe.turnpointframe2.menu2 configure -text Corcoran"
  $men2 add radio -label Delano -variable TURNPOINT2 -value Delano -command ".turnpointframe.turnpointframe2.menu2 configure -text Delano"
  $men2 add radio -label Porterville -variable TURNPOINT2 -value Porterville -command ".turnpointframe.turnpointframe2.menu2 configure -text Porterville"
  $men2 add radio -label {New Cuyama} -variable TURNPOINT2 -value {New Cuyama} -command ".turnpointframe.turnpointframe2.menu2 configure -text {New Cuyama}"

  label .turnpointframe.turnpointframe1.contestnolabel -text {Enter Contest No.}
  label .turnpointframe.turnpointframe1.daystrength -text {Thermal Strength}
  entry .turnpointframe.turnpointframe2.contestnoentry -textvariable contestno -width 5

  menubutton .turnpointframe.turnpointframe2.daystrength -text weak -menu .turnpointframe.turnpointframe2.daystrength.m -relief raised

  menu .turnpointframe.turnpointframe2.daystrength.m
  .turnpointframe.turnpointframe2.daystrength.m add radio -label weak -variable daystrength -value 6
  .turnpointframe.turnpointframe2.daystrength.m add radio -label medium  -variable daystrength -value 11
  .turnpointframe.turnpointframe2.daystrength.m add radio -label strong -variable daystrength -value 18
  
  button .turnpointframe.updatebutton  -text "Start New Leg " -command {destroybuttons
    getcoord
    calcdist $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2
    calcheading $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2
    plotline $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2
    showdist}
  
  button .turnpointframe.launchglider -text "Launch Glider " -command {launchGlider;destroybuttons;showdist}
  button .turnpointframe.flybutton -text { Start Flying  } -command {displayInfo}
  
  scale .turnpointframe.speedscale -from 40 -to 200 -length 250 -variable SPEED($contestno) -orient horizontal \
    -label "Speed $contestno - kts" -tickinterval 50 -showvalue true

  bind . <KeyPress-Down> {set SPEED($contestno) [expr $SPEED($contestno) - 1]}
  bind . <KeyPress-Up> {set SPEED($contestno) [expr $SPEED($contestno) + 1]}

  scale .turnpointframe.headingscale -from -75  -to 75  -length 250  -variable HEADING($contestno) -orient horizontal \
    -label "Steer  $contestno - L/R" -tickinterval 15 -showvalue true

  bind . <KeyPress-Left> {set HEADING($contestno) [expr $HEADING($contestno) -1]}
  bind . <KeyPress-Right> {set HEADING($contestno) [expr $HEADING($contestno) +1]}

  button .turnpointframe.gpsbutton1 -text { last GPS fix } -command {gpsdisplay1}
  button .turnpointframe.gpsbutton2 -text {plot GPS fixes} -command {gpsdisplay2}

  pack .frame .turnpointframe -side left
  pack .turnpointframe.turnpointframe1 .turnpointframe.turnpointframe2 -side left
  pack .turnpointframe.turnpointframe1.label1
  pack .turnpointframe.turnpointframe1.menu1 -padx 5 -pady 5
  
  pack .turnpointframe.turnpointframe2.label2
  pack .turnpointframe.turnpointframe2.menu2 -padx 5 -pady 5
  pack .turnpointframe.turnpointframe1.contestnolabel
  pack .turnpointframe.turnpointframe1.daystrength
  pack .turnpointframe.turnpointframe2.contestnoentry
  pack .turnpointframe.turnpointframe2.daystrength
  
  pack .turnpointframe.updatebutton .turnpointframe.launchglider .turnpointframe.flybutton .turnpointframe.gpsbutton1 .turnpointframe.gpsbutton2 \
    .turnpointframe.speedscale .turnpointframe.headingscale
  
}
#-------------------------------------------------------------------------------
# Main Body of Program
#-------------------------------------------------------------------------------

# next two lines create the images use for non plugin version comment out for plugin version
image create photo sectional -file largeclr.gif -gamma 1
image create photo   gliders -file pic45tra.gif -gamma 1

# uncomment next 2 lines for plugin version (non plugin can't use -data statement)
#image create photo gliders -data $g
#image create photo sectional -date $i

# bitmaps work with -data in both versions

image create bitmap gliderpair            -data $bmp       -foreground white
image create bitmap gliderpairwest        -data $west      -foreground white
image create bitmap glidershadow          -data $bmp       -foreground gray50
image create bitmap glidershadowwest      -data $west      -foreground gray50
image create bitmap gliderpairnortheast   -data $northeast -foreground white
image create bitmap glidershadownortheast -data $northeast -foreground gray50
image create bitmap gliderpairsouthwest   -data $southwest -foreground white
image create bitmap glidershadowsouthwest -data $southwest -foreground gray50
image create bitmap destroyed             -data $destroyed -foreground white
image create bitmap destroyedshadow       -data $destroyed -foreground gray50
image create bitmap dustdevil             -data $dustdevil -foreground brown

ScrolledCanvas .c 400 300 { 0 0 1359 1836 }

frame .frame ;#frame for holding the great circle distance calculation
pack  .frame


getturnpoint  ;#procedure to get the index value of the selected turnpoints
#bind . <KeyPress-Left> {set SPEED(IB) [expr $SPEED(IB) - 1]}

getcoord      ;#gets the coordinates from the list for the selected turnpoints

calcdist    $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2
calcheading $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2

#plotline $latdeg1 $latmin1 $londeg1 $lonmin1 $latdeg2 $latmin2 $londeg2 $lonmin2

#set HEADING($contestno) $COURSE
showdist

.c.canvas yview moveto .45
.c.canvas xview moveto .1

# .c.canvas create text [expr 400 + 105] [expr 1025 - 45] \
#          -text "Glider Combat!!!" \
#          -font -freefont-futura_poster-*-r-*-*-*-400-*-*-*-*-*-* -fill black \
#          -tags logo

# .c.canvas create text [expr 400 + 95] [expr 1025 - 55] \
#           -text "Glider Combat!!!" \
#           -font -freefont-futura_poster-*-r-*-*-*-400-*-*-*-*-*-* -fill olivedrab \
#           -tags logo2

# .c.canvas create text [expr 400 + 110] [expr 1025 - 10] \
#           -text "by Alex Caldwell" \
#           -font -freefont-futura_poster-*-r-*-*-*-400-*-*-*-*-*-* -fill purple  \
#           -tags logo


# End of Program
#-------------------------------------------------------------------------------


