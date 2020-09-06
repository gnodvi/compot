# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


# a~.tl JIMO TEST_next
#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#lappend auto_path "[pwd]/.."

# #-------------------------------------------------------------------------------
# proc check_JIM {} {}

#   if [info exists tcl_version] {
#     set ::__TCL__ 1
#     set ::__JIM__ 0
#   } else {
#     set ::__TCL__ 0
#     set ::__JIM__ 1
#   }

# {}
#-------------------------------------------------------------------------------

# check_JIM 

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
  puts "CreditAccount vars=[CreditAccount vars]"
  puts "CreditAccount methods=[CreditAccount methods]"
  puts ""
  
  puts "----------------- object CreditAccount -----------------------------"
  puts ""
  set b [CreditAccount new {name "John White"}]
  
  puts b.vars=[$b vars]
  puts b.classname=[$b classname]
  
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

  set x [Account]
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

  class_create 1 AccountMore {} {

    balance 0
    name    "Unknown"
  } {
      puts ""
      puts "balance = $balance !!!!!!!!!!"
      puts ""
      
      if {$balance < 0} {
        error "Can't initialise account with a -ve balance \n"
      }
  }

  #-----------------------------------------------------

  #set a [AccountMore new  {name "Bob Smith"  balance +1}]
  set a [AccountMore new  {name "Bob Smith" }]
  
  #exit

  puts ""
  puts "balance = [$a GET_balance]"
  puts "name    = [$a GET_name]"
  
  $a SET_balance 88
  puts "balance = [$a GET_balance]"
  puts ""
  
  #exit

  class_method AccountMore see {} {
    set balance
  }

  class_method AccountMore deposit  {amount} {
    set balance [+ $balance $amount]
  }
  
  class_method AccountMore seename  {} {
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

  puts "balance = [$a see]"

  $a deposit 10

  #$a SET_b 10
  
  puts "balance = [$a see]"
  puts "name    = [$a seename]"
  #puts "b       = [$a GET_b]"

  puts ""

  #exit
  #-----------------------------------------------------

  puts ""
  puts "-----------------------------------------------"
  puts ""

  class_create 1 AccountNext {AccountMore} {

    limit 100
  } {

    puts ""
    #puts "balance = $balance !!"
    puts "limit   = $limit    !!!!!"
    puts ""
  }

  #set n [AccountNext new {limit 10}]
  set n [AccountNext new {}]

  #-----------------------------------------------------

  #exit

  puts "balance = [$a see]"
  puts "name    = [$a seename]"

  #exit

  puts "name    = [$a GET_name]"
  puts "balance = [$a GET_balance]"

  #exit

  $a SET_name "hjhjkjhkj"
  puts "name    = [$a GET_name]"

  #exit
  puts ""

  if {$::__JIM__} {
 
    puts "vars = [$a vars]"
  } else {

    puts "info object variables  = [info object variables $a]"
    puts "info object vars       = [info object vars      $a]"      
    puts "info class  variables (AccountMore) = [info class  variables AccountMore]"
    puts "info class  variables (AccountNext) = [info class  variables AccountNext]"
  }

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
