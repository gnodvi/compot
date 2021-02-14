# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/Morse+Code
# Morse code
# 
#-------------------------------------------------------------------------------
# Morse en/decoder: works both ways ASCII <-> Morse
#-------------------------------------------------------------------------------

proc morse {s} {

  # \u00C4 - Ä (Auml)
  # \u00D6 - Ö (Ouml)
  # \u00DC - Ü (Uuml)

  set  MORSE_CODE_OLD {

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

 set MORSE_CODE_NEW {
    
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

  set _morse $MORSE_CODE_NEW

  #------------------------------------------------------------

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

} 
;#RS - slightly uncrufted 2001-12-04

#-------------------------------------------------------------------------------
proc MORSE_test {} {

  puts ""
  puts "MORSE_test ..........."
  puts ""


  set res [morse "1"];    puts "res = $res"
  set res [morse "2"];    puts "res = $res"
  set res [morse "SOS"];  puts "res = $res"

  set res [morse "..."];  puts "res = $res"

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

MORSE_test


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

