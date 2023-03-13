#!/bin/sh
# \
exec wish "$0" ${1+"$@"}
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# http://wiki.tcl.tk/2987
#------------------------------------------------------------------------------




#------------------------------------------------------------------------------

# tclworld.tcl
# Richard Suchenwirth, Konstanz 2002-01-31
set ::version 0.6

cd [file dirname [info script]] ;# requires all files in one directory

#~~~~~~~~~~~~~~~~~~~~~~~~~

source strimj.tcl

#~~~~~~~~~~~~~~~~~~~~~~~~~

 if 0 {
     rename proc _proc
     _proc proc {name argl body} {
        set prefix {puts [info level]:[info level 0]}
        _proc $name $argl $prefix\n$body
    }
 }

#------------------------------------------------------------------------------
#
# Формируется пространство имен с переменными и затем к этому пространству 
# добавляются процедуры, по сути формируя "зачаток" класса.
#
# Пространства имен позволяют группировать процедуры и переменные, ограничивая
# их область видимости.
#
# variable - создание переменной в пространстве имен (аналог команды set);
#            а также для обращения изнутри процедур;
#
# !!! - внимательно следить за глобальными переменными !!!
#
#------------------------------------------------------------------------------
#
# По умолчанию процедуры обратного вызова выполняются в глобальной области 
# видимости. (namespace code)
#
#------------------------------------------------------------------------------
namespace eval geo {

  variable scale 2.
  variable db        ;# array that holds our database
  variable oval 1    ;# determine projection: 0: rectangular, 1: oval

  variable colors {
    green2 green3 olivedrab2 olivedrab3 palegreen3 limegreen
    chartreuse3 seagreen3 yellowgreen springgreen3
    darkolivegreen2 darkolivegreen3 forestgreen
  }
  
  variable bitmaps
  set bitmaps(city) [image create bitmap -data [strimj::xbm "
    ..##..
    .####.
    ######
    ######
    .####.
    ..##.."] -foreground red]

  set bitmaps(opencircle) [image create bitmap -data [strimj::xbm "
    ..##..
    .#..#.
    #....#
    #....#
    .#..#.
    ..##.."]]

  set bitmaps(box) [image create bitmap -data [strimj::xbm "
    ####
    ####
    ####
    ####"]]

  set bitmaps(mount) [image create bitmap -data [strimj::xbm "
    ..#..
    .###.
    .###.
    #####
    #####"] -foreground brown]
}
#------------------------------------------------------------------------------
proc geo::dat {filename} {

  # reader for ASCII files like the 1997 census outlines
  variable canvas; variable scale

  set c $canvas
  set fp [open $filename]
  while {[gets $fp line]>=0} {
    switch -- [llength $line] {
      1 {
        set color [lpick {red blue yellow orange pink purple brown}]
        eval Set dt$id area $buf
        after 0 [list $c show dt$id -outline black]
        update
      }
      2 {
        foreach {lon lat} $line break
        if {abs($lat-$lastlat)>=0.01 || abs($lon-$lastlon)>=0.01} {
          lappend buf [list [format %.2f $lat] [format %.2f [expr {-$lon}]]]
        }
        set lastlon $lon; set lastlat $lat
      }
      3 {
        set id [lindex $line 0]
        set buf "";#poly
        set lastlat 0; set lastlon 0
      }
    }
  }

  close $fp
}
#------------------------------------------------------------------------------
proc geo::dmc {filename} {

  # reader for ASCII files from DCW (Digital Chart of the World)
  variable canvas; variable scale
  set mode 0 ;# outside of regionset
  set c $canvas
  set fp [open $filename]
  while {[gets $fp line]>=0} {
    switch -- [llength $line] {
      1 {
        if {$line=="END"} {
          incr mode -1
          if {$mode==1} {
            set color [lpick {red blue yellow orange pink purple brown}]
            eval Set $name area $buf
            after 0 [list $c show $name -outline black]
            update
          }
          continue
        }
        switch -- $mode {
          0 {set setname [string tot $line]}
          1 {set name $setname/$line}
          default {error "can't understand $line"}
        }
        incr mode
        set buf ""
        set lastlat 0; set lastlon 0
      }
       2 {
         foreach {lon lat} $line break
         if {abs($lat-$lastlat)>=0.01 || abs($lon-$lastlon)>=0.01} {
           lappend buf [list [format %.2f $lat] [format %.2f [expr {-$lon}]]]
         }
         set lastlon $lon; set lastlat $lat
       }
    }
  }

  close $fp
 }
#------------------------------------------------------------------------------
proc geo::js2tg {fn} {

  #reader for Javascript HTML pages from the Map gallery
  set fp [open $fn]
  set res ""
  set re {dcc\('(.+)<br>(.+)<br>Lat: (.+)[NS].+Lon: (.+)[EW]','(.+)'}
  foreach line [split [read $fp] \n] {
    if [regexp $re $line -> type where lat lon name] {
      set s "\$db [list $name] : [list $type in $where loc [list $lat -$lon]]"
      regsub -all {[.]} $s "" s;# elim. decimal dots from minutes
      regsub -all {╟} $s "." s
      append res $s\n
    }
  }

  close $fp
  set res
}
#------------------------------------------------------------------------------

proc geo::Canvas {} {variable canvas; set canvas}

#------------------------------------------------------------------------------
proc geo::flash {name} {

  variable canvas

  if {![catch {$canvas itemcget $name -fill} color]} {
    for {set t 0} {$t<=2500} {incr t 250} {
      after $t $canvas itemconf $name -fill red
      incr t 250
      after $t $canvas itemconf $name -fill $color
    }
  }
}
#------------------------------------------------------------------------------
proc geo::Get arg {

  variable db
  
  if {[info exists db($arg)]} {
    set value $db($arg)
  } elseif {![catch {expr [join $arg +]}]} {
    set value [concat point $arg] ;# constant point specified
  } else {return ""}
  set rest [lrange $value 1 end]
  if {[llength $rest]==1} {set res [lindex $rest 0]}
  switch -- [lindex $value 0] {
    area - lake   {set res [Make polygon $rest]}
    bound - grid {set res [Make line    $rest]}
    city - mount - point {
      if {[llength $rest] < 2} {
        puts "pair error in $arg"
        return
      }
      foreach {x y} $rest break
      set res [list point [expr {-$x}] [expr {-$y}]]
    }
    is            {set res $value}
    road - rail - river {set res [Make line $rest]}
    default       {return -code error "cannot get $arg"}
  }

  set res
}
#------------------------------------------------------------------------------
proc geo::Grid {c {delta 20}} {
  
  $c create line -360    0 360   0 -fill white ;# equator
  $c create line    0 -180   0 180 -fill white ;# Greenwich meridian
  for {set i -80} {$i<=80} {incr i $delta} {
    set cmd {line}
    for {set j -180} {$j<=180} {incr j $delta} {
      lappend cmd  $i $j
    }
    eval $c create [transform $cmd] [list -tag "grid lon$i" -fill white]
  }
  set d4 [expr {$delta/4}]
  for {set j -180} {$j<=180} {incr j $delta} {
    set cmd {line}
    for {set i -90} {$i<=90} {incr i $d4} {
      lappend cmd $i $j
    }
    eval $c create [transform $cmd] [list -tag "grid lat$j"  -fill white]
  }
  
  set t [lrevert2 [$c coords lat-180]]
  set bg [eval $c create polygon [$c coords lat180] $t -fill lightblue -tag Ocean]
  $c lower Ocean
}
#------------------------------------------------------------------------------
proc geo::Join list {

  set res [lrange $list 0 2]
  foreach {- lastx lasty} $res break
  foreach {x y} [lrange $list 3 end] {
    if {$x!=$lastx || $y!=$lasty} {lappend res $x $y}
    set lastx $x
    set lasty $y
  }

  join $res
}
#------------------------------------------------------------------------------
proc geo::Make {item argl} {

  foreach arg $argl {
    eval lappend item [lrange [Get $arg] 1 end]
  }

  Join $item
}
#------------------------------------------------------------------------------
proc geo::Map {w args} {

  puts ""
  puts "geo::Map : w = $w  args = $args"
  puts ""

  variable scale; 
  variable canvas

  eval canvas $w -width 720 -height 360   $args ;# base widget

  set canvas $w
  rename ::$w ::_$w

  proc ::$w {cmd args} [string map [list @w@ _$w] {

    variable db
    set w [lindex [info level 1] 0]
    set name [lindex $args 0]
    set rest [lrange $args 1 end]

    switch -- $cmd {
      see     {geo::see  $w $name}
      show    {geo::show $w $name $rest}
      default {eval @w@ $cmd $args}
    }
  }]

  bind $w +   {geo::Scale %W . . 2.0}
  bind $w -   {geo::Scale %W . . 0.5}
  bind $w <1> {geo::Scale %W %x %y 2.0}
  bind $w <2> {puts -nonewline "[list [string map {N {} E {} S {} W {}} $geo::position]] "}
  bind $w <3> {geo::Scale %W %x %y 0.5}

  bind $w <Left>  {%W xview scroll -2 units}
  bind $w <Right> {%W xview scroll 2 units}
  bind $w <Up>    {%W yview scroll -2 units}
  bind $w <Down>  {%W yview scroll 2 units}
  bind $w <Motion> {geo::where %W %x %y}

  $w bind bound <Enter> {%W itemconfig current -fill red}
  $w bind bound <Leave> {%W itemconfig current -fill black}

  set w
}
#------------------------------------------------------------------------------
proc geo::mark {type name} {

  variable db; variable canvas
  variable bitmaps

  foreach {- x y} [transform $db($name)] break
  set w $canvas
  set item [$w create image [expr {-$x}] [expr {-$y}] \
              -image $bitmaps($type) -tag [list $name $type txt]]
  $w create text [expr {-$x}] [expr {-$y}]\
    -text "  $name" -tag [list $name txt] -anchor w
  set item
} 
#------------------------------------------------------------------------------

proc geo::Names {{pattern *}} {variable db; array names db $pattern}

#------------------------------------------------------------------------------
proc geo::NamesBySize {{pattern *}} {
  
  variable db
  
  set sizelist {}
  foreach name [array names db $pattern] {
    lappend sizelist [list $name [llength $db($name)]]
  }
  set res {}
  foreach pair [lsort -index 1 -integer -decreasing $sizelist] {
    lappend res [lindex $pair 0]
  }

  set res
}
#------------------------------------------------------------------------------
proc geo::Set args {

  variable db
  
  if {[llength $args]==1} {set args [lindex $args 0]}
  foreach line [split $args \n] {
    set name [lindex $line 0]
    if {[llength $line]>2 && $name !="#"} {
      set db($name) [lrange $line 1 end]
    }
  }
}
#------------------------------------------------------------------------------
proc geo::transform L {
  
  variable scale
  variable oval
  
  set res [lindex $L 0]
  if {$oval} {
    foreach {lat lon} [lrange $L 1 end] {
      set x [expr {$lon*sqrt(1.-$lat*$lat/8100.)}]
      set y [expr {$lat*sqrt(1.+$x*$x/64800.)}]
      set y [expr {($y>90)? 90: ($y<-90)? -90: $y}]
      lappend res [expr {$x*$scale}] [expr {$y*$scale}]
    }
  } else {
    foreach {lat lon} [lrange $L 1 end] {
      set x $lon
      set y $lat
      set y [expr {($y>90)? 90: ($y<-90)? -90: $y}]
      lappend res [expr {$x*$scale}] [expr {$y*$scale}]
    }
  }
  set res
}
#------------------------------------------------------------------------------
proc geo::retransform {x y} {

  variable oval; variable scale
  
  set x [expr {$x/-$scale}]
  set y [expr {$y/-$scale}]
  if {$oval} {        
    set lat [expr {$y/sqrt(1+$x*$x/64800.)}]
    set lon 0
    catch {set lon [expr {$x/sqrt(1.-$lat*$lat/8100.)}]}
  } else {
    set lat $y
    set lon $x
  }

  set lat [expr {($lat>90)?   90: ($lat<-90)?   -90: $lat}]
  set lon [expr {($lon>180)? 180: ($lon<-180)? -180: $lon}]
  list $lat $lon
} 
#------------------------------------------------------------------------------
proc geo::show {w name rest} {

  puts ""
  puts "geo::show :  w= $w  name= $name  rest= $rest"
  puts ""

  if {[llength [$w  find withtag $name]]} {

    $w raise $name
    return
  }  
  
  puts "0 ...."

  variable db; variable colors; variable scale

  set data [Get $name]
  if {$data == ""} return
  set type [lindex $db($name) 0]

  puts "1 ...."

  if {$type=="is"} {
    foreach part [lrange $data 1 end] {
      geo::show $w $part $rest
    }
    return
  }

  if {!([llength $data]%2)} {
    puts "geo::show error on $name"; return
  }

  puts "2 ...."

  set data [transform $data]
  if {[lindex $data 0]!="point"} {
    set item [eval _$w create $data -tag [list [list $name $type]]]
    eval [list _$w itemconfig $item] $rest
  } else {set item ""}

  puts "3 ...."

  switch -- $type {
    area  {
      set bbox [_$w bbox $item]
      if {[lindex $bbox 3]>60*$scale || [lindex $bbox 3] < -59*$scale} {
        _$w itemconfig $item -fill white
      } else {
        _$w itemconfig $item -fill [lpick $colors]
      }
    }
    city - mount  {set item [geo::mark $type $name]}
    lake  {_$w itemconfig $item -fill lightblue}
    road  {_$w itemconfig $item -fill yellow}
    rail  {_$w itemconfig $item -fill black}
    river {_$w itemconfig $item -fill blue}
    grid  {_$w itemconfig $item -fill white}
  }

  puts "4 ...."

  set item
}
#------------------------------------------------------------------------------
proc geo::Scale {w x y factor} {

  variable scale
  
  if {$x=="."} {
    set x [expr {[$w cget -width]/2}]
    set y [expr {[$w cget -height]/2}]
  }

  if {$factor==0} {set factor [expr {2./$scale}]}

  foreach {x0 y0 x1 y1} [$w bbox all] break
  set width  [expr {double($x1-$x0)}]
  set height [expr {double($y1-$y0)}]
  set cx [$w canvasx $x]
  set cy [$w canvasy $y]    
  $w scale all 0 0 $factor $factor
  $w config -scrollregion [$w bbox all]
  set scale [expr {$scale*$factor}]    
  $w xview moveto [expr {($cx-$x0-$x/$factor)/$width}]
  $w yview moveto [expr {($cy-$y0-$y/$factor)/$height}]
  $w lower txt

  for {set i 1; set 2i 1} {$2i<$scale} {incr i; incr 2i $2i} {
    $w raise level$i
  }
}
#------------------------------------------------------------------------------
proc geo::see {w tag} {

  variable scale

  if {![llength [$w find withtag $tag]]} {
    return;
    # error "no object $tag"
  }

  foreach {x0 y0 x1 y1} [$w bbox $tag] break

  set width [expr {($x1-$x0)/$scale}]
  set height [expr {($y1-$y0)/$scale}]
  set xfac [expr {[$w cget -width]/$width}]
  set yfac [expr {[$w cget -height]/$height}]
  set fac [min $xfac $yfac]
  # find nearest lower power of two
  for {set i 2} {$i<$fac/2. && $i<=64.0} {incr i $i} {}
  set oldscale $scale
  Scale $w . . [expr {$i/$scale}]
  set x [expr {$x0/$oldscale - $width/10}]
  set y [expr {$y0/$oldscale - $height/10}]
  $w xview moveto [expr {(180+$x)/360.}]
  $w yview moveto [expr {( 90+$y)/180.}]
}
#------------------------------------------------------------------------------
proc geo::where {w x y} {

  variable scale; variable position; variable where
  
  set here [$w find withtag current]    
  if {[llength $here]} {
    set where [string map {
      current {} lake {} txt {} area {}
    } [$w itemcget $here -tags]]
  } else {set where ""}

  foreach {lat lon} [retransform [$w canvasx $x] [$w canvasy $y]] break

  set lat [format %.2f $lat]
  if {$lat>0} {append lat N} else {set lat [string trim $lat -]S}
  set lon [format %.2f $lon]
  if {$lon>0} {append lon W} else {set lon [string trim $lon -]E}
  set position [list $lat $lon]
}
#------------------------------------------------------------------------------
#------- end namespace geo
#---------------------------------------------------- some utilities...

#------------------------------------------------------------------------------

proc min {p q} {expr {$p<$q? $p: $q}}

#------------------------------------------------------------------------------
# 
# создаем прокручиваемое окно (общего вида? типа type)
# 
#------------------------------------------------------------------------------
proc scrolled {type w args} {

  frame $w

  set res [eval $type $w.0 \
             [list -xscrollc "$w.x set" -yscrollc "$w.y set"] $args]

  scrollbar $w.x -ori hori -command "$w.0 xview"
  scrollbar $w.y -ori vert -command "$w.0 yview"

  grid $w.0 $w.y -sticky news
  grid $w.x      -sticky news
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure    $w 0 -weight 1

  #set res    ;# почему автор везде использует такой прием ???
  return $res ;# возвращаем созданное окно
}
#------------------------------------------------------------------------------
proc lpick L {lindex $L [expr {int(rand()*[llength $L])}]}
#------------------------------------------------------------------------------
proc lrevert2 L {

  # invert an even-lengthed list in steps of two
  set res {}
  set i [llength $L]

  while {[incr i -2]>=0} {lappend res [lindex $L $i] [lindex $L [expr {$i+1}]]}
  set res
}
#------------------------------------------------------------------------------


#-----------------------------------------------begin app Tclworld
set ::isdebug 1

#proc geo::mainn {} {}
#------------------------------------------------------------------------------

  global argc argv
  
  set tcl_precision 15
  
  set c [scrolled  geo::Map .m -bg black]
  
  #wm geometry . 400x300+100+100
  wm geometry . +500+400
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~TOP~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  frame  .top
  
  label  .top.scale -textvar geo::scale -width 10
  button .top.plus  -text +    -width 3 -pady 0 -command "geo::Scale $c . . 2.0"
  button .top.minus -text -    -width 3 -pady 0 -command "geo::Scale $c . . 0.5"
  button .top.all   -text {[]} -width 3 -pady 0 -command "geo::Scale $c . . 0"
  label  .top.pos   -textvar geo::position -width 14
  label  .top.where -textvar geo::where -width 40 -bg white
  
  button .top.info -bitmap info -command {
    #raise $info - надо сделать по-другому вызывалку
    db::ui::browse $db
  }
  
  eval pack [winfo children .top] -side left
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  pack .top -fill x
  pack .m   -fill both -expand 1
  
  $c create text 0 0 -text "TclWorld..." -font "Helvetica 112 italic" \
    -fill blue -tag waitMessage
  geo::Grid $c
  $c config -scrollregion [$c bbox all]
  
  update
  
  wm title . "Loading geo data..."
  

  set TGDIR "G" ;# только earth.tg -> G/world.tg ???
    
  if {$argv=="" || $argv=="{}"} {
    #
    # если при старте не указаны базы для загрузки, то укажем их
    # 
    set argv {worldcities earth}
  }

  foreach file $argv {
    # подключаем указанные файлы баз
    #
    if [catch {source $TGDIR/$file.tg} res] {puts $res}
  }
  

  foreach name [geo::NamesBySize] {
    
    puts "name= $name   c= $c"

    $c show $name

    #if {[llength $geo::db($name)] > 50} update
  }
  

  # name= Asia   c= .m.0 
  # geo::show :  w= mainn  name= Asia      rest= ??? mainn ??? 
  # geo::show :  w= .m.0   name= Pretoria  rest=  

  # Error in startup script: wrong # args: should be "geo::mainn"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if {$::isdebug} {
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  foreach kind {lake river rail bound} {$c raise $kind}
  foreach kind {grid Ocean txt}        {$c lower $kind}
  
  $c itemconfig bound -fill black
  $c delete waitMessage
  
  
  source "db_gui.tcl"
  set db [source $TGDIR/tclworld.db]
  
  
  # не будем вызывать диалог сразу ?!
  #
  #set info [db::ui::browse $db]
  #wm withdraw $info
  
  # App-specific implementation
  #
  proc db::ui::callback args {
    after 0 [list $::c see [lindex $args 0]]
  }
  
  foreach i [geo::Names] {
    if {[lindex $geo::db($i) 0] == "city"} {
      
      "Tclworld database" $i : {city} loc [lrange $geo::db($i) 1 end]
    }
  }
  
  foreach i [$db] {
    set loc [$db $i loc]
    
    if {[llength $loc]} {
      
      set level [$db $i level]
      if {[llength $level] == 0} {set level 5}
      $c addtag level$level withtag $i
    }
  }
  
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

geo::Scale $c . . 1.0

wm title . "TclWorld $::version"

bind . ? {console show}

raise .

focus $c

#------------------------------------------------------------------------------
#{}
#------------------------------------------------------------------------------

#mainn 

#------------------------------------------------------------------------------

# Error in startup script: wrong # args: should be "main"
#     while executing
# "$w find withtag $name"
#     (procedure "geo::show" line 3)
#     invoked from within
# "geo::show $w $name $rest"
#     (procedure ".m.0" line 8)
#     invoked from within
# "$c show $name"
#     (procedure "main" line 52)
#     invoked from within
# "main "
#     (file "./warmap.tcl" line 649)

#------------------------------------------------------------------------------

