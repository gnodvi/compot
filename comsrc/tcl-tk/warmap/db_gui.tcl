#------------------------------------------------------------------------------
# dbgui.tcl - TITLE: A little database GUI
#------------------------------------------------------------------------------

if 0 {

[Richard Suchenwirth] - In [A little database API] it was shown how a
single proc can add basic database functionalities to an array. Present-
day computer users are accustomed to graphical user interfaces (GUIs),
so here comes an extension that lets you browse (offering a simple hypertext
facility with automatic cross-referencing, plus full-text search) little
databases.}

#------------------------------------------------------------------------------

 source "db_api.tcl"

#------------------------------------------------------------------------------
 namespace eval db::ui {
        variable topic ""
 } ;# required before procs can be defined

#------------------------------------------------------------------------------
proc db::ui::browse {database} {

  set t [toplevel .[clock clicks]]
  wm title $t $database
  db $database

  set m [frame $t.main]
  listbox $m.lb -bg white -height 5 -yscrollcommand [list $m.y1 set]
  bind    $m.lb <ButtonRelease-1> [list db::ui::select %W %y $database]
  scrollbar $m.y1 -command [list $m.lb yview]
  htext $m.t $database -yscrollcommand [list $m.y2 set]
  scrollbar $m.y2 -command [list $m.t yview]

  eval pack [winfo children $m] -side left -fill y
  pack $m.t -fill both -expand 1
  set     b [frame $t.bottom]

  #button $b.edit -text Edit -command [list db::edit $database]
  #button $b.new -text New -command [list db::new $database]
  #button $b.del -text Delete -command [list db::delete $database]

  label  $b.find -text Find:
  entry  $b.tofind
  bind   $b.tofind <Return> [list db::ui::find %W $m.t $database]
  button $b.action -text " ! " -command {db::ui::callback $db::ui::topic}

  eval pack [winfo children $b] -side left -fill x
  pack $b.tofind -expand 1
  pack $b -side bottom -fill x
  pack $m -fill both -expand 1

  foreach i [lsort -dic [$database]] {$m.lb insert end $i}

  set t
}
#------------------------------------------------------------------------------

 proc db::ui::callback args {} ;# redefine this for specific action

#------------------------------------------------------------------------------
 proc db::ui::htext {w database args} {
    eval text $w -bg grey90 -padx 3 -wrap word -height 7 -width 50 $args
    $w tag config title -font {Times 12 bold}
    $w tag config link -foreground blue -underline 1
    $w tag bind link <Enter> "$w config -cursor hand2"
    $w tag bind link <Leave> "$w config -cursor {}"
    $w tag bind link <ButtonRelease-1> [list db::ui::click %W %x %y $database]
    $w insert end \n\n$database\n\n title "Select topic from listbox"
    $w insert end "\n\n[llength [$database]] entries in database"
    set w
 }
#------------------------------------------------------------------------------
 proc db::ui::click {w x y database} {
    set range [$w tag prevrange link [$w index @$x,$y]]
    if [llength $range] {
        Show $w [eval $w get $range] $database
    }
 }
#------------------------------------------------------------------------------
 proc db::ui::select {w y database} {
    Show [winfo parent $w].t [$w get @0,$y] $database
 }
#------------------------------------------------------------------------------
 proc db::ui::Show {w title database} {
    variable topic
    set topic $title
    $w delete 1.0 end
    $w insert end $title\n title \n
    set titles [$database]
    foreach {item value} [$database $title] {
        if {$item == "@" && [file exists $value]} {
            set img [image create photo -file $value]
            $w image create 1.0 -image $img
            $w insert 1.1 " "
        } else {
            $w insert end $item\t
            foreach word $value {
                if {[lsearch $titles $word]>=0} {set tag link} else {set tag {}}
                $w insert end $word $tag " "
            }
        }
        $w insert end \n
    }    
 }
#------------------------------------------------------------------------------
 proc db::ui::find {w textw database} {
    set tofind [$w get]
    set found {}
    foreach key [$database] {
        set data [$database $key]
        if [regexp -indices -nocase ($tofind) $data -> pos] {
            lappend found [list $key [lindex $pos 0] $data]
        }
    }
    switch [llength $found] {
        0       {error "No match for $tofind"}
        1       {Show   $textw [lindex [lindex $found 0] 0] $database}
        default {choice $textw $database $tofind $found}
    }
 }
#------------------------------------------------------------------------------
 proc db::ui::choice {w database tofind found} {
    $w delete 1.0 end
    $w insert end "Search results for '$tofind':\n" title \n
    foreach pair $found {
        foreach {title pos data} $pair break
        set context [string range $data [expr $pos-15] [expr $pos+25]]
        $w insert end $title link \t...$context...\n "" pos=$pos\n
    }
 }
#------------------------------------------------------------------------------
 #----------------------------- a sample application...

if {[file tail $argv0] == [file tail [info script]]} {

  db::ui::browse [source tclworld.db]
  
  wm withdraw .
  # 
  # отменяет отображение окна, не заменяя его пиктограммой; позднее можно 
  # восстановить нормальный вид окна операцией "deiconify";

 }
#------------------------------------------------------------------------------
