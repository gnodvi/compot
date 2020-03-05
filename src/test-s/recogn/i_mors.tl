# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/Morse+Code
# Morse code
# 
#-------------------------------------------------------------------------------
# Morse en/decoder: works both ways ASCII <-> Morse
#-------------------------------------------------------------------------------

proc morse {s} {

  # \u00C4 - ц└ (Auml)
  # \u00D6 - ц√ (Ouml)
  # \u00DC - ц° (Uuml)

  set _morse {
    A ._ \u00C4 ._._ B _... C _._. D _.. E . F .._.
    G __. H .... I .. J .___ K _._ L ._.. M __
    N _. O ___ \u00D6 ___. P .__. Q __._ R ._. S ...
    T _ U .._ \u00DC ..__ V ..._ W .__ X _.._ Y _.__ Z __..
    0 _____ 1 .____ 2 ..___ 3 ...__ 4 ...._ 5 .....
    6 _.... 7 __... 8 ___.. 9 ____.
    . ._._._ , __..__ ? ..__.. / _.._. ( _.__. ) _.__._
    + ._._. : ___... ; ...___ - _...._ = _..._
    ~ ._... # ..._._ $ _..._._ 
  }

  set res ""

  if [regexp {^[._ ]+$} $s] {

    regsub -all {  +} $s " B " s
    foreach i [split $s] {
      if {$i==""}  continue
      if {$i=="B"} {append res " "; continue}
      set ix [lsearch $_morse $i]
      if {$ix>=0} {
        append res [lindex $_morse [expr {$ix-1}]]
      } else {append res ?}
    }

  } else {
    foreach i [split [string toupper $s] ""] {
      if {$i==" "} {append res "  "; continue}
      set ix [lsearch -exact $_morse $i]
      if {$ix>=0 && $ix%2==0} {
        append res "[lindex $_morse [expr {$ix+1}]] "
      }
    }
  }

  set res

} ;#RS - slightly uncrufted 2001-12-04
#-------------------------------------------------------------------------------
proc test1 {} {

  puts ""

  set res [morse "1"];  puts "res = $res"
  
  set res [morse "2"];  puts "res = $res"

  puts ""
}
#-------------------------------------------------------------------------------

# KBK (2002-04-09)

#  QST QST QST DE KE9TV/2 KE9TV/2 KE9TV/2 BT

# added punctuation, plus added procedural signs

#  ~ - Stand by (AS)
#  # - End of work (SK or VA)
#  $ - Break (BK)

# Procedural signs AR, BT and KN are encoded by +, = and ( respectively, since
# those are the meaning of those signs within a message body.

# Ampersand should be sent as the two characters ES.

# Still to do: AAA is a period, but a decimal point is sent as a character R.

#  VY 73 DE KE9TV/2 SK AR

# For practizing, see also A little Morse trainer

#-------------------------------------------------------------------------------
proc test2 {} {

  global t MORSE_CODE

  # DKF: Here's a morse code player I wrote for Rosetta Code that uses Snack to
  # do the playing:
  
  # This uses the GUI-free part of the Snack library
  
  if {[catch {package require sound} ret]} {
    # возникновение ошибки
    puts ""
    puts $ret 
    puts ""

    set ::is_sound 0
    #exit
    
  } else {
    # корректное выполнение команды       
    set ::is_sound 1
  }
  


  # A simple pause while running the event loop, in terms of basic time units
  proc pause n {
    
    global t
    after [expr {$t * $n}] set ok 1
    vwait ok
  }
  # Generate using a sine-wave filter
  proc beep n {
    
    global frequency
    set f [snack::filter generator $frequency 30000 0.0 sine -1]
    set s [snack::sound -rate 22050]
    $s play -filter $f
    pause $n
    $s stop
    $s destroy
    $f destroy
    pause 1
  }
  
  # The dits and the dahs are just beeps of different lengths
  interp alias {} dit {} beep 1
  interp alias {} dah {} beep 3
  
  set MORSE_CODE {
    
    "!"  "---."      "\"" ".-..-."    "$"  "...-..-"    "'"  ".----."
    "("  "-.--."     ")"  "-.--.-"    "+"  ".-.-."      ","  "--..--"
    "-"  "-....-"    "."  ".-.-.-"    "/"  "-..-."
    ":"  "---..."    ";"  "-.-.-."    "="  "-...-"      "?"  "..--.."
    "@"  ".--.-."    "["  "-.--."     "]"  "-.--.-"     "_"  "..--.-"
    "0"  "-----"     "1"  ".----"     "2"  "..---"      "3"  "...--"
    "4"  "....-"     "5"  "....."     "6"  "-...."      "7"  "--..."
    "8"  "---.."     "9"  "----."
    "A"  ".-"        "B"  "-..."      "C"  "-.-."       "D"  "-.."
    "E"  "."         "F"  "..-."      "G"  "--."        "H"  "...."
    "I"  ".."        "J"  ".---"      "K"  "-.-"        "L"  ".-.."
    "M"  "--"        "N"  "-."        "O"  "---"        "P"  ".--."
    "Q"  "--.-"      "R"  ".-."       "S"  "..."        "T"  "-"
    "U"  "..-"       "V"  "...-"      "W"  ".--"        "X"  "-..-"
    "Y"  "-.--"      "Z"  "--.."
  }
  #--------------------------------------------------------------------
  # The code to translate text to morse code and play it
  
  proc morse {str wpm} {
    
    global t MORSE_CODE
    
    set t [expr {1200 / $wpm}]
    
    # Backslash and space are special cases in various ways
    set map {"\\" {} " " {[pause 4]}}
    
    puts "map = $map \n"

    # Append each item in the code to the map, with an inter-letter pause after
    #
    foreach {from to} $MORSE_CODE {
      lappend map $from "$to\[pause 3\]"
    }
    
    puts "map = $map \n"

    # Convert to dots and dashes
    set s [string map $map [string toupper $str]]
    
    puts "s = $s \n"

    if $::is_sound {
      # Play the dots and dashes by substituting commands for them
      subst [string map {"." [dit] "-" [dah]} $s]
    }
    
    return
  }
  #-------------------------------------------------------
  
  # We'll play at a fairly high pitch 
  set frequency 700 
  
  morse "Morse code with Tcl and Snack." 20
  
  puts  ""
}
#-------------------------------------------------------------------------------

# ZB 2012-05-24 There is an unpleasant "pitter-pattering", which I'm unable to
# dispose of. Most probably Snack's command "play" and "stop" are switching on
# and off the volume, causing this effect. It would be handy to have "stop" with
# option "stop playing all sounds, but don't change present volume level". Or
# the mentioned action should be valid for "pause" command rather (currently
# it's causing "pitter-pattering" too).

#-------------------------------------------------------------------------------

test1

test2

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

