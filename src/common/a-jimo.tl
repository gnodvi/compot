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
# proc VAR {args} {
  
#   set setfix "SET_"
#   set getfix "GET_"


#   foreach {vn val} $args {

#     #uplevel 1 variable $vn $val  ;# сначала создаем переменную
#     uplevel 1  $vn $val  ;# сначала создаем переменную

#     # а затем к ней методы доступа:
#     #

#     #uplevel 2 proc testproc {} {puts "TESTPROC !!!!!!!!!!!!!!!"}


#     #set setproc ${setfix}${vn} 
#     #set getproc ${getfix}${vn}

#     #uplevel 1 Account method SET_b {val} {set b $val}

#     #uplevel 2 Account method $setproc \{v\} \{[subst -nocommand {set $vn \$v}] \}
#     #uplevel 1 method $getproc \{\}  \{[subst -nocommand {return $$vn}] \}

#     #The  method  will  be
#     #          exported  if  name  starts  with  a  lower-case letter, and non-
#     #          exported otherwise; this behavior can be overridden  via  export
#     #          and unexport.

#     #uplevel 1 export $setproc $getproc ;# теперь можно слюбых букв начинать!
#   }

# }
#-------------------------------------------------------------------------------
proc SETGET {classname} {

  uplevel 1 $classname method set \{var val\} \{ set \$var \$val \}

  #foreach var [Account vars] {}
  foreach var [$classname vars] {

    #puts "var = $var"

    uplevel 1 $classname method SET_$var \{val\} \{set $var \$val\}
    uplevel 1 $classname method GET_$var \{\}    \{set $var \}
  }


}
#-------------------------------------------------------------------------------

##oo::class create POP {}

#-------------------------------------------------------------------------------
# proc oo_tcl_parse_classvars {classname classvars} {


#   dict for {var val} $classvars {
    
#     #set classname [self class]
#     #puts "classname = $classname"
    
#     oo::define $classname variable $var 
    
#     set $var $val
    
#     #set body [subst -nocommand {return $$var}]
    
#     oo::define $classname method GET_$var {} [subst -nocommand {return $$var}]
#     oo::define $classname export GET_$var
    
#     set body [subst -nocommand {set $var \$v}]
#     #puts "body = $body"
    
#     oo::define $classname method SET_$var {v} $body
#     oo::define $classname export SET_$var
#   }
   
# }
#-------------------------------------------------------------------------------
proc define_variables_and_SET_GET {obj classname classvars } {

if {$::__JIM__} {
} else {

  #set obj [self] ;# здесь не прокатывает!

  #set classname [self class]
  #puts "THIS IS classname = $classname"
  
  dict for {var val} $classvars {
    
    oo::define $classname variable $var     
    #set $var $val
    
    #set body [subst -nocommand {return $$var}]
    
    oo::define $classname method GET_$var {} [subst -nocommand {return $$var}]
    oo::define $classname export GET_$var
    
    set body [subst -nocommand {set $var \$v}]
    #puts "body = $body"
    
    oo::define $classname method SET_$var {v} $body
    oo::define $classname export SET_$var
  }

  dict for {var val} $classvars {      
    $obj SET_$var $val
    oo::define $classname variable $var $val
  }


  #   #dict for {var val} {*}$args {}
  #   dict for {var val} $classvars {
  
  #     #puts "NEXT: var=$var val = $val" 
  #     oo::define $classname variable $var $val
  #   }
  
}

  return
}
#-------------------------------------------------------------------------------
# if {$::__JIM__} {
# } else {

#   oo::class create SUPERJIM {
    
#   }
  
#   oo::define SUPERJIM constructor {args} { 
   
#     define_variables_and_SET_GET  [self]  [self class]  {*}$args 
#   }

# }
#-------------------------------------------------------------------------------
# proc NEXT {obj classname args} {

#   #
#   #uplevel 1 next $args
  
#   # TODO:
#   # 
#   define_variables_and_SET_GET $obj  $classname {*}$args 


# #   dict for {var val} {*}$args {

# #     puts "NEXT: var=$var val = $val"

# #     oo::define $classname variable $var $val
# #   }
  
# }
#-------------------------------------------------------------------------------
proc class_create {classname {baseclasses {}} classvars} {


  if {$::__JIM__} {

    class $classname $baseclasses $classvars

    SETGET $classname

  } else {

    oo::class create $classname  {

      #superclass SUPERJIM
    }

    #oo::define $classname  constructor {args} {
    #  NEXT [self class] {*}$args ;; 
    #}

  } 

}
#-------------------------------------------------------------------------------
#proc class_method {classname methodname vars body} {}
proc class_method {classname methodname args body} {

  if {$::__JIM__} {

    #$classname method $methodname $vars $body
    $classname method $methodname {*}$args $body
  
  } else {

    #oo::define $classname method $methodname $vars $body
    oo::define $classname method $methodname $args $body
  }

}
#-------------------------------------------------------------------------------
#proc class_constructor {classname vars body} {}
proc class_constructor {classname args body} {

  #puts "class_constructor:  vars = $vars"
  puts "class_constructor:  body = $body"

  if {$::__JIM__} {

    #define_variables_and_SET_GET [self] [self class] {*}$args 

    #class_method $classname constructor $vars $body
    #class_method $classname constructor $vars {}
    class_method $classname constructor $args {

      puts "balance = $balance !!!!!!!!!!"
      
      if {$balance < 0} {
        error "Can't initialise account with a -ve balance \n"
      }
    }
  
    #-------------------------------
  } else {
    #-------------------------------

    #set newbody " NEXT \[self class\] \{*\}\$args ;;  $body "
    
    #puts "class_constructor (TCL): newbody = "
    #puts $newbody
  
    #[subst -nocommand {return $$var}]
  
#     set nextbody {
#       NEXT [self class] {*}$args 

#       #puts "balance = $balance !!!!!!!!!!"

#     }

    #puts "nextbody = $nextbody"
    #set newbody [concat $nextbody $body]
    #puts "newbody = $newbody"

    #oo::define $classname  constructor {args} $nextbody
    #oo::define $classname constructor {args}  $nextbody

    oo::define $classname constructor {args} {

      #set obj [self]

      #NEXT [self] [self class] {*}$args 

      define_variables_and_SET_GET [self] [self class] {*}$args 
    }
  }

}
#-------------------------------------------------------------------------------
proc TEST_next {} {

  puts ""

  class_create AccountMore {} {
    balance 0
    name    "Unknown"

  }

  class_constructor AccountMore {args} {
  }
  
  #-----------------------------------------------------


  set a [AccountMore new  {name "Bob Smith"  balance +1}]
  
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

  exit

  #-----------------------------------------------------

  puts "balance = [$a see]"
  puts "name    = [$a seename]"


  puts "name    = [$a get name]    [$a GET_name]"
  puts "balance = [$a get balance]"

  $a SET_name "hjhjkjhkj"
  puts "name    = [$a get name]    [$a GET_name]"

  puts "vars = [$a vars]"

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
