# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
if [info exists ::A_COMO_TL] {
  return
} else {
  set  ::A_COMO_TL ""
}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# JimTcl OO

# OO support for Jim Tcl, with multiple inheritance

# Create a new class $classname, with the given
# dictionary as class variables. These are the initial
# variables which all newly created objects of this class are
# initialised with.
#
# If a list of baseclasses is given,
# methods and instance variables are inherited.
# The *last* baseclass can be accessed directly with [super]
# Later baseclasses take precedence if the same method exists in more than one

#-------------------------------------------------------------------------------

proc class {classname {baseclasses {}} classvars} {

  set baseclassvars {}

  foreach baseclass $baseclasses {

    # Start by mapping all methods to the parent class
    foreach method [$baseclass methods] { alias "$classname $method" "$baseclass $method" }

    # Now import the base class classvars
    set baseclassvars [dict merge $baseclassvars [$baseclass classvars]]

    # The last baseclass will win here
    proc "$classname baseclass" {} baseclass { 
      return $baseclass 
    }
  }
  
  # Merge in the baseclass vars with lower precedence
  set classvars [dict merge $baseclassvars $classvars]
  set vars [lsort [dict keys $classvars]]
  
  # This is the class dispatcher for $classname
  # It simply dispatches 'classname cmd' to a procedure named {classname cmd}
  # with a nice message if the class procedure doesn't exist

  proc $classname {{cmd new} args} classname {

    #static classname

    if {![exists -command "$classname $cmd"]} {
      return -code error "$classname, unknown command \"$cmd\": should be [join [$classname methods] ", "]"
    }
    tailcall "$classname $cmd" {*}$args
  }
  
  #------------------------------------------------------------------------
  # Constructor
  #------------------------------------------------------------------------
  # gnodvi proc "$classname new" {{instvars {}}} {classname classvars} {}
  proc "$classname new" {{instvars__ {}}} {classname classvars} {

    # gnodvi: set instvars [dict merge $classvars $instvars]
    # gnodvi: save arglist for next call
    #
    set instvars [dict merge $classvars $instvars__]
    
    # This is the object dispatcher for $classname.
    # Store the classname in both the ref value and tag, for debugging
    # ref tag (for debugging)

    set obj [ref $classname $classname "$classname finalize"]


    proc $obj {method args} {classname instvars} {

      if {![exists -command "$classname $method"]} {
        if {![exists -command "$classname unknown"]} {
          return -code error "$classname, unknown method \"$method\": should be [join [$classname methods] ", "]"
        }
        return ["$classname unknown" $method {*}$args]
      }

      "$classname $method" {*}$args
    }


    if {[exists -command "$classname constructor"]} {
      #puts "instvars__ = $instvars__"

      set info_args [info args "$classname constructor"]
      #puts "info args = $info_args"

      if {$info_args == ""} {
        $obj constructor 
      } else {
        $obj constructor $instvars__
      }

      #$obj constructor $instvars__
      #$obj constructor 
      #if {$instvars__ != ""} {
      #  $obj constructor $instvars__
      #}
    }

    #puts stderr "!!!!!!!!!!!!!! NEW !!!!!!!!!!!!!!!!!!!!!!"
    #puts stderr "instvars = $instvars ,,,,, instvars__ = $instvars__"
    #puts stderr "!!!!!!!!!!!!!! NEW !!!!!!!!!!!!!!!!!!!!!!"

    return $obj
  }
  #------------------------------------------------------------------------

  # Finalizer to invoke destructor during garbage collection
  proc "$classname finalize" {ref classname} { $ref destroy }

  # Method creator
  proc "$classname method" {method arglist __body} classname {

    proc "$classname $method" $arglist {__body} {
      # Make sure this isn't incorrectly called without an object
      if {![uplevel exists instvars]} {
        return -code error -level 2 "\"[lindex [info level 0] 0]\" method called with no object"
      }
      set self [lindex [info level -1] 0]
      # Note that we can't use 'dict with' here because
      # the dict isn't updated until the body completes.

      foreach __ [$self vars] {upvar 1 instvars($__) $__}
      unset __
      eval $__body
    }
  }

  # Other simple class procs

  proc "$classname vars"      {} vars      { return $vars }
  proc "$classname classvars" {} classvars { return $classvars }
  proc "$classname classname" {} classname { return $classname }
  proc "$classname methods"   {} classname {
    lsort [lmap p [info commands "$classname *"] {
      lindex [split $p " "] 1
    }]
  }

  # Pre-defined some instance methods

  $classname method destroy {}    { rename $self "" }
  $classname method get     {var} { set $var }
  $classname method eval   {{locals {}} __code} {
    foreach var $locals { upvar 2 $var $var }
    eval $__code
  }

  return $classname
}
#-------------------------------------------------------------------------------
# From within a method, invokes the given method on the base class.
# Note that this will only call the last baseclass given
#-------------------------------------------------------------------------------
proc super {method args} {

  #upvar self self

  #puts stderr ""
  #puts stderr "self classname = [$self classname]"
  #puts stderr "self baseclass = [$self baseclass]"

  #set baseclass [$self baseclass]
  #uplevel 2 $baseclass $method {*}$args

  # --------------------------------------------------------------
  # From: Steve Bennett <steveb@workware.net.au>
  # Date: Sun, 4 Oct 2020 13:46:01 +1000
  # Subject: [PATCH] oo: fix super for >2 levels of inheritance

  # Need to find the baseclass based on the current method class,
  # not based on the object class.

  # If we are called from "class method", we want to call "[$class baseclass] method"
  # 
  set classname [lindex [info level -1] 0 0]
  uplevel 2 [list [$classname baseclass] $method {*}$args]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
proc SELF {} {


  if {$::NEWMODE} {

    uplevel 1 {return $obj} 
  }

  #----------------------------------------------------
  if {$::__JIM__} {

    #upvar self self_local
    #return $self_local

    uplevel 1 {return $self} 
  } else {

    uplevel 1 {return [self]} 
  }
  #----------------------------------------------------

}
# ------------------------------------------------------------------------------
proc CLASSNAME {obj} {


  if {$::NEWMODE} {

    set classname [GET $obj "classname"]

    #puts stderr "CLASSNAME: .... $classname"

    #exit
    return $classname
  }

  #----------------------------------------------------

  if {$::__JIM__} {

    return [$obj classname]
  } else {
    
    return [string trimleft [info object class $obj] ":"]
  }

}
# ------------------------------------------------------------------------------
proc BASECLASS {classname} {

  if {$::NEWMODE} {
  
    set dclass $::DCLASSES($classname)

    set baseclasses  [GET $dclass "baseclasses"]

    return [lindex $baseclasses 0] ;# пока предполагаем не более одного
  }

  #----------------------------------------------------

  if {$::__JIM__} {

    return [$classname baseclass]

  } else {
    
    set superclasses [info class superclasses $classname]

    #puts "BASECLASS: superclasses = $superclasses"
    #
    # вообще то это список!
    # 
    return [string trimleft $superclasses ":"]
  }

}
#-------------------------------------------------------------------------------
      #set classname    [$classname baseclass]
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------





#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-----------------------------------------------------

foreach op {+ - * /} {
    
  proc $op args [string map [list @op@ $op] {expr [join $args @op@]}]
}
  
#-------------------------------------------------------------------------------
proc package_require_OO {} {

  if {$::__JIM__} {

    package require oo
  } else {

    package require TclOO;  
  } 

}
#-------------------------------------------------------------------------------

package_require_OO 

#package require oo

#-------------------------------------------------------------------------------
proc TEST_time {} {

  set nums 1000 ;# 1000

  class A {
    balance 0
    name    "Unknown"
  }

  A method deposit {amount} {
    set balance $amount
  }

  puts ""
  set i 0

  #   puts "Create:   [time {A create $i;   incr i} $nums]"
  
  puts "Create:   [time {set objs($i) [A new] ;  incr i} $nums]"

  set i 0
  puts "SetGet:   [time {$objs($i) deposit $i;  $objs($i) get balance;  incr i} $nums]"

  set i 0
  puts "Delete:   [time {$objs($i) destroy; incr i} $nums]"

  #   A destroy

  puts ""

}
#-------------------------------------------------------------------------------

# $ a~.jm JIMO TEST_time

# Create:   13 microseconds per iteration
# SetGet:   23 microseconds per iteration
# Delete:   12 microseconds per iteration


# b~.tl TEST_cloo_time
# b~.tl TEST TIME_all

# Create:   4.443 microseconds per iteration
# SetGet:   3.025 microseconds per iteration
# Delete:   4.556 microseconds per iteration

#-------------------------------------------------------------------------------
proc TEST_main {} {

  # Create a class, the usual bank account, with two instance variables:
  
  class Account {
    balance 0
    name "Unknown"
  }
  
  # We have some class methods predefined
  # Note we can call (e.g.) either Account.methods or 'Account methods'
  
  puts ""
  puts "------------------- class Account ------------------------------"
  puts ""
  puts "Account vars=[Account vars]"
  puts "Account methods=[Account methods]"
  puts ""
  
  # Create a constructor. This does validation, but it could
  # do other things
  
  #Account method constructor {args} {}
  Account method constructor {} {
    if {$balance < 0} {
      error "Can't initialise account with a -ve balance"
    }
  }
  
  # Now flesh out the class with some methods
  # Could use 'Account method' here instead
  Account method deposit {amount} {
    set balance [+ $balance $amount]
  }
  
  Account method see {} {
    set balance
  }
  
  Account method withdraw {amount} {
    if {$amount > $balance} {error "Sorry $name, can only withdraw $balance"}
    set balance [- $balance $amount]
  }
  
  Account method describe {} {
    puts "I am object $self of class [$self classname]"
    puts "My 'see' method returns [$self see]"
    puts "My variables are:"
    foreach i [$self vars] {
      puts "  $i=[set $i]"
    }
  }
  
  # Now an instance, initialisition some fields
  set a [Account new {name "Bob Smith"}]
  
  puts "------------------ object Account -------------------------------"
  puts ""
  # We can use class methods on the instance too
  puts a.vars=[$a vars]
  puts a.classname=[$a classname]
  
  # Now object methods
  $a deposit 100
  puts "deposit 100 -> [$a see]"
  
  $a withdraw 40
  puts "withdraw 40 -> [$a see]"
  
  catch {$a withdraw 1000} res
  puts "withdraw 1000 -> $res\n"
  
  # Tell me something about the object
  $a describe
  puts ""
  

  # Now create a new subclass
  # Could change the initial balance here too
  class CreditAccount Account {
    limit -1000
  }
  
  CreditAccount method constructor {} {
    # Dummy constructor
    # If desired, manually invoke the baseclass constructor
    super constructor
  }
  
  # Override the 'withdraw' method to allow overdrawing
  CreditAccount method withdraw {amount} {

    puts "CreditAccount method withdraw: limit = $limit"
    if {$balance - $amount < $limit} {
      error "Sorry $name, that would exceed your credit limit of [expr -$limit]"}

    set balance [- $balance $amount]
  }
  # Override the 'describe' method, but invoke the baseclass method first
  CreditAccount method describe {} {
    # First invoke the base class 'describe'
    super describe

    if {$balance < 0} {
      puts "*** Account is in debit"
    }
  }
  
  puts "----------------- class CreditAccount ------------------------------"
  puts ""
  puts "CreditAccount vars      = [CreditAccount vars]"
  puts "CreditAccount classvars = [CreditAccount classvars]"
  puts "CreditAccount methods   = [CreditAccount methods]"
  puts ""
  
  puts "----------------- object CreditAccount -----------------------------"
  puts ""
  set b [CreditAccount new {name "John White"}]
  
  puts "b.vars = [$b vars]"
  puts "b.classname = [$b classname]"
  puts "b.limit     = [$b get limit]"

  set var "limit"
  set val -998
  #set val {ee ff gg}

  #$b eval "set $var $val"
  #$b eval {set limit "111 222 555"}
  #$b eval "set limit \{ $val \}"

  puts "b.limit     = [$b get limit]"

  #exit
  #---------------------

  puts "b.limit     = [$b eval {set limit}]"
  puts "b.limit     = [GET $b limit]"
  SET $b limit -1000
  puts "b.limit     = [GET $b limit]"

  #---------------------

  #SET $b limit {aa bb cc}  ;# не установить список ????

  #puts "b.limit     = |[GET $b limit]|"
  puts ""

  #---------------------

  puts "CreditAccount classvars = [CreditAccount classvars]"
  
  puts ""

  #===================================================
  
  puts "initial balance -> [$b see]"

  $b deposit 100
  puts "deposit 100 -> [$b see]"
  
  $b withdraw 40
  puts "withdraw 40 -> [$b see]"
  
  $b withdraw 1000
  puts "withdraw 1000 -> [$b see]"
  puts ""
  
  # Tell me something about the object
  $b describe
  puts ""
  
  # 'eval' is similar to 'dict with' for an object, except it operates
  # in it's own scope. A list of variables can be imported into the object scope.
  # It is useful for ad-hoc operations for which it is not worth defining a method.

  set total 0

  $a eval total { incr total $balance }
  incr total [$b get balance]

  puts "Total of accounts [$a get name] and [$b eval {return "$name (Credit Limit: $limit)"}] is: $total"
  
  # Can we find all objects in the system?
  # Almost. We can't really distinguish those which aren't real classes.
  # This will get all references which aren't simple lambdas.
  
  puts ""
  puts "------------------- All objects ---------------------------------"
  puts ""
  
  Account new {name "Terry Green" balance 20}

  set x [Account] ;# ???? что за извращение?
  lambda {} {dummy}
  ref blah blah
  
  foreach r [info references] {

    if {[getref $r] ne {}} {
      try {
        $r eval {
          puts [format "Found %14s: Owner: %14s, Balance: %+5d, in object %s" [$self classname] $name $balance $self]
        }
      } on error msg {
        puts "Not an object: $r"
      }
    }
  }

  unset r
  
  # And goodbye
  $a destroy
  
  # Let the garbage collection take care of this one
  unset b
  collect
  
  puts ""
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_next {} {

  puts ""

  class_create 0 Account1 {} {

    balance 0          ;# _____________
    name    "Unknown"
    ch_form ""
  } {
    
    puts ""
    puts "Account1 Constructor: args = $args"
    puts ""

    puts "balance = $balance !!!!!!!!!!"
    set balance  123  ;# для JIM не нужно !!
    set name    "123"

    puts ""
    
    if {$balance < 0} {
      error "Can't initialise account with a -ve balance \n"
    }
  }

  #-----------------------------------------------------

  #set a [Account1 new  {name "Bob Smith"  balance +1}]
  set a1 [Account1 new  {name "Bob Smith" }]
  
  puts "a1 (Account1 new) = $a1"

  #exit

  puts ""
  puts "balance = [$a1 GET_balance]"
  puts "name    = [$a1 GET_name]"
  
  $a1 SET_balance 88
  puts "balance = [$a1 GET_balance]"
  puts ""
  
  #exit

  class_method Account1 see {} {
    set balance
  }

  class_method Account1 deposit  {amount} {
    set balance [+ $balance $amount]
  }
  
  class_method Account1 seename  {} {
    set name
  }
  
  #exit
  #-----------------------------------------------------

  #   puts ""
  #   set a [Account new  {name "Bob Smith"  balance 4}]
  #   puts "balance = [$a GET_balance]"
  #   puts ""
  
  #   exit
  #-----------------------------------------------------

  puts "balance = [$a1 see]"

  $a1 deposit 10

  #$a SET_b 10
  
  puts "balance = [$a1 see]"
  puts "name    = [$a1 seename]"
  #puts "b       = [$a GET_b]"

  puts ""

  #exit
  #-----------------------------------------------------

  puts ""
  puts "-----------------------------------------------"
  puts "----------------Account2-----------------------"
  puts "-----------------------------------------------"
  puts ""

  class_create 0 Account2 {Account1} {

    limit 100
  } {
    # Constructor

    puts ""
    puts "Account2 Constructor: args = $args"
    puts ""
    
    if {$::__JIM__} {
      
      puts "args      = $args"
      puts "vars      = [$self vars]"
      puts "classvars = [$self classvars]"

      #puts "instvars = [$self instvars]"
      #puts "balance = $balance !!!!!!!!!"
      #puts "-lone   = ${-lone}"

    } else {
      
      puts "args = $args"
    }

    puts ""
    puts "limit   = $limit "

    #SUPER constructor {*}$args
    # 
    if {$::__JIM__} {
      #super constructor  {*}$args
      super constructor 
    } else {
      next {*}$args
    }

    puts "limit   = $limit "

    set limit 101 ;# для JIM не нужно !!
    puts "limit   = $limit "
  }
  #----------------------------------------------------------------------------


  set a2 [Account2 new {-lone "one" -ltwo "two" limit 10} ]

  puts ""
  puts "-----------------------------------------------"
  puts ""

  #exit

  puts "balance = [$a2 see]"
  puts "name    = [$a2 seename]"

  puts "name    = [$a2 GET_name]"
  puts "balance = [$a2 GET_balance]"

  $a1 SET_name "hjhjkjhkj"
  puts "name    = [$a1 GET_name]"

  #exit
  puts ""

  if {$::__JIM__} {

      puts "vars      = [$a1 vars]"
      puts "classvars = [$a1 classvars]"
 
  } else {

    puts "info object variables  = [info object variables $a1]"
    puts "info object vars       = [info object vars      $a1]"      
    puts "info class  variables (Account1) = [info class  variables Account1]"
    puts "info class  variables (Account2) = [info class  variables Account2]"
  }

  puts ""
  puts "-------------------------------------------"
  puts ""
  puts -nonewline "name ................ "  ;
  puts ""


  if {1} {
    
    #set ch_form "%s "
    #set ch_form {%sss @}
    set ch_form {123 4}
    
    puts "ch_form = |$ch_form|"
    
    SET $a1   ch_form $ch_form    
    set ch_form [GET $a1 "ch_form"]
    
    puts "ch_form = |$ch_form|"
    puts ""

    #exit
  } 

  puts ""
  puts "-----------------------------------------------"
  puts "----------------Account3-----------------------"
  puts "-----------------------------------------------"
  puts ""

  class_create 0 Account3 {Account2} {

    limit 200
  } {
    # Constructor
    puts "Account3 Constructor: args = $args"
    puts ""
    
    #----------------------------------------
    if {0} {

      #SUPER constructor {*}$args
      #
      if {$::__JIM__} {
        #  #super constructor  {*}$args
        super constructor 
      } else {
        next {*}$args
      }
    }
    #----------------------------------------

  }

  set a3 [Account3 new]

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc dotimes_TEST {&i n body} {

  USE_REFS
  
  for {set i 0} {$i < $n} {incr i} {

    uplevel $body
  }

}
#-------------------------------------------------------------------------------
proc TEST_refs {}  {

  puts ""

  set i "ABCJJFKEFJD" ;# для JIM нужно чтобы переменная ссылки была определена ??


  dotimes_TEST i 10 {
    puts "dotimes: i = $i"
  }
  
  puts ""

}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc RUN1 {procname obj args} {

  # вызываемая проц-ра в маленьких буквах, т.е. CALC -> calc
  # 
  #set procname  [string tolower [lindex [info level -1] 0]]
  #set procname  "${procname}_"

  set classname [CLASSNAME $obj]

  # сделаем вызывемую процедуру-метод 
  #
  set procforclass "${procname}${classname}"

  # сдалано не правильно, должны бы идти по всем базовым классам, иерархически
  # и искать эту процедуру-метод?

  while {1} {
    
    if {! [exists_command $procforclass]} {
      
      set classname    [BASECLASS $classname]
      set procforclass "${procname}$classname" 

      #puts "new classname = $classname"
      #puts "procforclass = $procforclass"

    } else {
      break
    }
    
  }

  return [$procforclass $obj {*}$args]
}
# ------------------------------------------------------------------------------
proc ONEMETHOD {obj args} {

  # вызываемая проц-ра в маленьких буквах, т.е. например CALC -> calc
  # 
  set procname  [string tolower [lindex [info level -1] 0]]
  set procname  "${procname}_"

  return [RUN1 $procname $obj {*}$args]
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_simp {} {


  proc SEE {obj args} {
    
    #puts "SEE: classname= [$obj classname], baseclass= [$obj baseclass]"
    
    return [ONEMETHOD $obj {*}$args] 
  }


  proc see_A {obj args} {
    
   return [GET $obj balance]  
   #set balance
  }

  class A {
    balance 0
  }

  A method deposit {amount} {
    set balance [+ $balance $amount]
  }
  
  A method see {} {
   set balance
  }


  puts ""
  set a [A new]

  puts "a balance = [$a see]"
  $a deposit 100
  puts "a balance = [$a see]"

  puts ""
  #-----------------------------------------

  if {0} {
  proc see_B {obj args} {
    
   return [GET $obj balance]  
   #set balance
  }
  }

  class B {A} {
  }

  B method deposit {amount} {
    super deposit $amount 
  }
  
  #   B method see {} {
  #   #  super see
  #     set obj [SELF]
  
  #     return [see_B $obj]
  #     #return [GET $obj balance] 
  #   }


  puts ""
  set b [B new]

  puts "b balance = [$b see]"
  #puts "b balance = [see_B $b]"
  #puts "b balance = [SEE $b]"

  $b deposit 100
  puts "b balance = [$b see]"

  puts ""

  #-----------------------------------------
  #exit 
  #-----------------------------------------

  class C {B} {
  }

  C method deposit {amount} {
    super deposit $amount 
  }
  
  #C method see {} {
  #  super see
  #}


  puts ""
  set c [C new]

  puts "c balance = [$c see]"
  $c deposit 100
  puts "c balance = [$c see]"
  #puts "c balance = [SEE $c]"


  puts ""


  proc classtest {classname {baseclasses {M N O}} classvars} {

    puts ""
    puts "classname   = $classname"
    puts "baseclasses = $baseclasses"
    puts "classvars   = $classvars"
    puts ""
  }

  classtest C  {a A}

}
#-------------------------------------------------------------------------------

#TEST_simp

# Why i have a cyclic error? :

# ...... 
# ...... 
# ...... 
#
# in procedure 'super' called at file "./a_simp.jm", line 43
# in procedure 'B' called at file "oo.tcl", line 99
# at file "oo.tcl", line 65
# in procedure 'super' called at file "./a_simp.jm", line 43
# in procedure 'B' called at file "oo.tcl", line 99
# at file "oo.tcl", line 65
# in procedure 'super' called at file "./a_simp.jm", line 43
# in procedure 'B' called at file "oo.tcl", line 99
# at file "oo.tcl", line 65
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc test_CLASS {} {


  class A {} {
    
    balance 0
    name    "Unknown"
  }

}
#-------------------------------------------------------------------------------

#a~.jm JIMO test_CLASS

#TT add

#-------------------------------------------------------------------------------
