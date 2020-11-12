# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# from  ...  tcllib-1.14/modules/struct/record.tcl
#-------------------------------------------------------------------------------

set ::NEWEST 0



# ::struct::record --
#
#    Implements a container data structure similar to a 'C' 
#    structure. It hides the ugly details about keeping the
#    data organized by using a combination of arrays, lists
#    and namespaces.
#   
#    Each record definition is kept in a master array 
#    (_recorddefn) under the ::struct::record namespace. Each
#    instance of a record is kept within a separate namespace
#    for each record definition. Hence, instances of
#    the same record definition are managed under the
#    same namespace. This avoids possible collisions, and
#    also limits one big global array mechanism.
#
# Copyright (c) 2002 by Brett Schwarz
#
# See the file "license.terms" for information on usage and redistribution
# of this file, and for a DISCLAIMER OF ALL WARRANTIES.
#
# This code may be distributed under the same terms as Tcl.
#
# $Id: record.tcl,v 1.10 2004/09/29 20:56:18 andreas_kupries Exp $
#
#-------------------------------------------------------------------------------
#
####  FIX ERROR MESSAGES SO THEY MAKE SENSE (Wrong args)


# namespace eval namespace arg ?arg ...?
#     Activates a namespace called namespace and evaluates some code in that 
#     context. If the namespace does not already exist, it is created. If more 
#     than one arg argument is specified, the arguments are concatenated together 
#     with a space between each one in the same fashion as the eval command, and 
#     the result is evaluated.

#     If namespace has leading namespace qualifiers and any leading namespaces 
#     do not exist, they are automatically created. 


namespace eval ::struct {}

namespace eval ::struct::record {

    ##
    ##  array of lists that holds the 
    ##  definition (variables) for each 
    ##  record
    ##
    ##  _recorddefn(some_record) var1 var2 var3 ...
    ##
    variable _recorddefn

    ##
    ##  holds the count for each record
    ##  in cases where the instance is
    ##  automatically generated
    ##
    ##  _count(some_record) 0
    ##

    ## This is not a count, but an id generator. Its value has to
    ## increase monotonicaly.

    variable _count

    ##
    ##  array that holds the defining record's
    ##  name for each instances
    ##
    ##  _defn(some_instances) name_of_defining_record
    ##
    variable  _defn
    array set _defn {}

    ##
    ##  This holds the defaults for a record definition.
    ##  If no default is given for a member of a record,
    ##  then the value is assigned to the empty string
    ##
    variable _defaults

    ##
    ##  These are the possible sub commands
    ##
    variable commands
    set commands [list   define delete exists show] 

    ##
    ##  This keeps track of the level that we are in
    ##  when handling nested records. This is kind of
    ##  a hack, and probably can be handled better
    ##
    set _level 0

    #
    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    namespace export record 
    namespace export dictrecord ;# ??

}
#-------------------------------------------------------------------------------
# ::struct::record::record --
#
#    main command used to access the other sub commands
#
# Arguments:
#    cmd_   The sub command (i.e. define, show, delete, exists)
#    args   arguments to pass to the sub command
#
# Results:
#  none returned

#-------------------------------------------------------------------------------
proc ::struct::record::record {cmd_ args} {

  variable commands
  
  if {[lsearch $commands $cmd_] < 0} {
    error "Sub command \"$cmd_\" is not recognized. Must be [join $commands ,]"
  }
  
  set cmd_ [string totitle "$cmd_"] ;# define -> Define
  
  return [uplevel 1 ::struct::record::${cmd_} $args]
  # 
  # т.е. вместо, например,  "record define" выполним ""record Define 
  # в том же внешнем контексте
  
};
#-------------------------------------------------------------------------------
#proc ::struct::record::dictrecord {args} {}
proc dictrecord {args} {

  set ::NEWEST 1

  #puts "dictrecord: ::NEWEST !!"
  
  ::struct::record::record  {*}$args

}
#-------------------------------------------------------------------------------
# ::struct::record::Define --
#
#    Used to define a record
#
# Arguments:
#    defn_    the name of the record definition
#    vars_    the variables of the record (as a list)
#    args     instances to be create during definition
#
# Results:
#   Returns the name of the definition during successful
#   creation.
#-------------------------------------------------------------------------------
#
proc ::struct::record::Define {defn_ vars_ args} {

  if {[IsDebug]} {
    puts "::struct::record::Define .............................."
    puts ""
    puts "defn_ = $defn_"
    puts "vars_ = $vars_"
    puts "args  = $args"
    puts ""
  }

  #-------------------------------------------------------------------

  variable _recorddefn
  variable _count
  variable _defaults
    
  set defn_ [Qualify $defn_]  ;# Contructs the qualified name of the calling scope
  
  if {[IsDebug]} {
    puts ""
    puts "defn_ = $defn_"
    puts ""
  }
  
  if {[info exists _recorddefn($defn_)]} {
    
    # это имя уже занято в определении структуры
    # 
    error "Record definition $defn_ already exists"
  }
  
  if {[lsearch [info commands] $defn_] >= 0} {
    
    # это имя уже занято как Tcl-команад
    # 
    error "Structure definition name can not be a Tcl command name"
  }
  
  
  set _defaults($defn_)   [list]
  set _recorddefn($defn_) [list]    
  

  #-------------------------------------------------------------------

  ##
  ##  Loop through the members of the record
  ##  definition
  ##

  foreach V $vars_ {
    
    set len [llength $V]
    set D ""
    
    ##
    ##  2 --> there is a default value
    ##        assigned to the member
    ##
    ##  3 --> there is a nested record
    ##        definition given as a member
    ##

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if {$len == 2} {
      
      set D [lindex $V 1]
      set V [lindex $V 0] ;# !
      
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    } elseif {$len == 3} {
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
      if {![string match "record" "[lindex $V 0]"]} {
        
        Delete record $defn_
        error "$V is a Bad member for record definition
                definition creation aborted."
      }
      
      set new [lindex $V 1]
      
      set new [Qualify $new]
      
      ##
      ##  Right now, there can not be circular records
      ##  so, we abort the creation
      ##
      if {[string match "$defn_" "$new"]} {

        Delete record $defn_
        error "Can not have circular records. Structure was not created."
      }

      ##
      ##  Will take care of the nested record later
      ##  We just join by :: because this is how it
      ##  use to be declared, so the parsing code
      ##  is already there.
      ##
      set V [join [lrange $V 1 2] "::"]

    }
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if {[IsDebug]} {puts "V = $V"}
    if {[IsDebug]} {puts "D = $D"}
    

    lappend _recorddefn($defn_) $V
    lappend _defaults($defn_)   $D
  }
  

  if {[IsDebug]} {
    puts ""
    puts "_recorddefn($defn_) = $_recorddefn($defn_)"
    puts "_defaults($defn_)   = $_defaults($defn_)"
    puts ""
  }


  # выполнить на верхнем уровне!!: 
  #
  # interp alias srcPath srcCmd targetPath targetCmd ?arg arg ...? - 
  # creates an alias between one slave and another; 
  #
  
  # создаем алиас, типа    ::myrecord := Create ::myrecord
  # 
  uplevel \#0 [list interp alias {} $defn_ {} ::struct::record::Create $defn_]
  
  # чего-то не пошел такой вариант
  # 
  #uplevel \#0 [list alias $defn_ ::struct::record::Create $defn_]
  
  set _count($defn_) 0
  
  
  # в отдельном пространстве имен для этой структуры создадим список для объектов
  #
  namespace eval ::struct::record${defn_} {
    
    variable values
    variable instances
    
    #if {[IsDebug]} {puts "values = $values"}
    
    set instances [list]
  }
  
  ##
  ## If there were args given (instances), then
  ## create them now
  ##
  ## А если имен не задано, то структуры будут созданы позже, Create ...
  ##
  foreach A $args {
    
    uplevel 1 [list ::struct::record::Create $defn_ $A]
  } 
  

  return $defn_
  
}; # end proc ::struct::record::Define
#-------------------------------------------------------------------------------
#
# proc ::struct::record::Define_DICT {defn_ vars_ args} {

#   puts "::struct::record::Define_DICT ............ \n"

#   set defn_ [dict_create] 


#   return $defn_
# }
#
#-------------------------------------------------------------------------------
# ::struct::record::Create --
#
#    Creates an instance of a record definition
#
# Arguments:
#    defn_    the name of the record definition
#    inst_    the name of the instances to create
#    args     values to set to the record's members
#
# Results:
#   Returns the name of the instance for a successful creation
#-------------------------------------------------------------------------------
#
proc ::struct::record::Create {defn_ inst_ args} {


  if {[IsDebug]} {
    
    puts "::struct::record::Create .............................."
    puts ""
    puts "defn_ = $defn_"
    puts "inst_ = $inst_"
    puts "args  = $args"
    #puts ""
  }
  
  #-------------------------------------------------------------------
  
  variable _recorddefn
  variable _count
  variable _defn
  variable _defaults
  variable _level
  
  set inst_ [Qualify "$inst_"]
  
  if {[IsDebug]} {
    
    puts "inst_ = $inst_"
    puts ""
  }
  
  ##
  ##    test to see if the record
  ##    definition has been defined yet
  ##
  if {![info exists _recorddefn($defn_)]} {

    error "Structure $defn_ does not exist"
  }
  
  ##
  ##    if there was no argument given,  ??????  auto !!!
  ##    then assume that the record
  ##    variable is automatically
  ##    generated
  ##
  if {[string match "[Qualify #auto]" "$inst_"]} {
    
    set c $_count($defn_)
    set inst_ [format "%s%s" ${defn_} $_count($defn_)] ;# новое имя !!

    incr _count($defn_)
  }

  if {$::NEWEST} {

    if {[IsDebug]} {
      puts ""
      puts "inst_ =============== $inst_"
      #puts ""
    }
    #set inst_ [dict_create]

    if {1} {
      set  d [MAKE_GLOBAL_NAME "DICT"] 
      set $d [dict create] 
      set inst_ $d
    } else {

      set $inst_ [dict create] ;# ??
    }

    if {[IsDebug]} {
      puts "inst_ =============== $inst_"
      puts ""
    }
  } 
  
  #-------------------------------------------------------------------

  ##
  ##    Test to see if this instance is already
  ##    created. This avoids any collisions with
  ##    previously created instances
  ##
  if {[info exists _defn($inst_)]} {

    incr _count($defn_) -1
    error "Instances $inst_ already exists"
  }
  
  set _defn($inst_) $defn_

  # установим алиас типа   ::r =  Cmd ::r
  # 

  uplevel \#0 [list interp alias {} ${inst_} {} ::struct::record::Cmd $inst_]
  
  #-------------------------------------------------------------------
  ##
  ##    Initialize record variables to
  ##    defaults
  ##
  
  #if {[IsDebug]} {    
  #}

  set cnt 0

  foreach V $_recorddefn($defn_) D $_defaults($defn_) {
    
    # утановим значения по умолчанию:
    # 

    set Vname [Ns $inst_]values($inst_,$V)

    set $Vname $D  ;# это переменные    
 
    if {[IsDebug]} {puts "inst_         = $inst_"}
    if {[IsDebug]} {puts "V             = $V"}
    if {[IsDebug]} {puts "D             = $D"}
    if {[IsDebug]} {puts "variable name = $Vname"}
    #if {[IsDebug]} {puts ""}
    
    if {$::NEWEST} {

      SET $inst_ $V $D
    } 


    ##
    ##  Test to see if there is a nested record
    ##

    set is_nested [regexp -- {([\w]*)::([\w]*)} $V m def inst]


    if {$is_nested} {
      
      if {$::NEWEST} {
        ERROR "Nested Records for NEWEST"
      }


      if {$_level == 0} {
        set _level 2
      }

      ##
      ##  This is to guard against if the creation
      ##  had failed, that there isn't any
      ##  lingering variables/alias around
      ##
      set def [Qualify $def $_level]
      
      if {![info exists _recorddefn($def)]} {
        
        Delete inst "$inst_"
        
        return
      }

      ##
      ##    evaluate the nested record. If there
      ##    were values for the variables passed
      ##    in, then we assume that the value for
      ##    this nested record is a list 
      ##    corresponding the the nested list's
      ##    variables, and so we pass that to
      ##    the nested record's instantiation.
      ##    We then get rid of those args for later
      ##    processing.
      ##

      set cnt_plus [expr {$cnt + 1}]
      set mem [lindex $args $cnt]

      if {![string match ""       "$mem"]} {
      if {![string match "-$inst" "$mem"]} {

          Delete inst "$inst_"
          error "$inst is not a member of $defn_"
      }}

      incr _level
      set narg [lindex $args $cnt_plus]
      eval [linsert $narg 0 Create $def ${inst_}.${inst}]
      set args [lreplace $args $cnt $cnt_plus]
      
      incr _level -1

    } else {
     
      #
      # #0 - выполнить команду в начальном глобальном уровне, т.е. 
      #      в данном случае создать алиас типа: 
      #
      #      ::r.mem1 =  Acces ::myrecord ::r mem1
      
      set a1 ${inst_}.$V
      set a2 "::struct::record::Access $defn_ $inst_ $V"

      if {[IsDebug]} {

        puts "alias :  $a1 =  $a2"
        puts ""
      }

      uplevel \#0 [list interp alias \
                     {} $a1 {} {*}$a2]
      incr cnt 2
    }
    
  }; # end foreach variable
  
  
  
  
  lappend [Ns $inst_]instances $inst_
  
  foreach {k v} $args {
    
    Access $defn_ $inst_ [string trimleft "$k" -] $v
    
  }; # end foreach arg {}
  


  if {$_level == 2} {
    set _level 0
  }
    
  
  if {[IsDebug]} {
    
    puts ""
    puts "......................................................."
    puts ""
  }
  
  return $inst_
  
}; # end proc ::struct::record::Create
#
#-------------------------------------------------------------------------------
# ::struct::record::Access --
#
#    Provides a common proc to access the variables
#    from the aliases create for each variable in the record
#
# Arguments:
#    defn_    the name of the record to access
#    inst_    the name of the instance to create
#    var_     the variable of the record to access
#    args     a value to set to var_ (if any)
#
# Results:
#    Returns the value of the record member (var_)
#-------------------------------------------------------------------------------
#
proc ::struct::record::Access {defn_ inst_ var_ args} {

  if {[IsDebug]} {
    
    puts "::struct::record::Access .............................."
    puts ""
    puts "defn_ = $defn_"
    puts "inst_ = $inst_"
    puts "var_  = $var_"
    puts "args  = $args"
    puts ""
    puts "......................................................."
    puts ""
  }
  
  #-------------------------------------------------------------------
  
  variable _recorddefn
  variable _defn
  
  set i [lsearch $_recorddefn($defn_) $var_]
  
  if {$i < 0} {
    error "$var_ does not exist in record $defn_"
  }
  
  if {$::NEWEST} {
  } else {

    if {![info exists _defn($inst_)]} {     
      error "$inst_ does not exist"
    }
  }
  
  if {[set idx [lsearch $args "="]] >= 0} {

    # усли есть знак равенства, то просто удаляем его из списка,
    # сдвигая значение влево ?

    set args [lreplace $args $idx $idx]
  } 
  
  ##
  ##    If a value was given, then set it
  ##
  if {[llength $args] != 0} {
    
    set val_ [lindex $args 0]
    
    if {$::NEWEST} {   
      SET $inst_ $var_ $val_
    } else {
      set [Ns $inst_]values($inst_,$var_) $val_
    }
  }
 
  # возвращаем значение для этой переменной (либо которое уже было, либо
  # которое только установили.

  if {$::NEWEST} {   
    set ret [GET $inst_ $var_]
  } else {
    set ret [set [Ns $inst_]values($inst_,$var_)]
  }

  return $ret
     
}; # end proc ::struct::record::Access
#
#-------------------------------------------------------------------------------
# ::struct::record::Cmd --
#
#    Used to process the set/get requests.
#
# Arguments:
#    inst_    the record instance name
#    args     For 'get' this is the record members to
#             retrieve. For 'set' this is a member/value
#             pair.
#
# Results:
#   For 'set' returns the empty string. For 'get' it returns
#   the member values.
#-------------------------------------------------------------------------------
#
proc ::struct::record::Cmd {inst_ args} {

  variable _defn

  set result [list]
  
  set len [llength $args]
  if {$len <= 1} {return [Show values "$inst_"]}
  
  set cmd [lindex $args 0]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # To get a member value, then use the instance built-in cget method:
  # instanceName cget -mem1 
  #
  # To get multiple member values, you can specify them all in one command:
  # instanceName cget -mem1 -mem2
  # 
  # To get a list of the key/value of all of the members, there are 3 ways:
  # - instanceName cget
  # - instanceName configure
  # - instanceName
  # 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {[IsDebug]} {
    
    puts "::struct::record::Cmd ................................."
    puts ""
    puts "inst_ = $inst_"
    puts "args  = $args"
    puts "cmd   = $cmd"
    puts ""
    puts "......................................................."
    puts ""
  }
  
  if {[string match "cget" "$cmd"]} {
    
    set cnt 0
    foreach k [lrange $args 1 end] {
      
      #if {[catch {set r [${inst_}.${k}]} err]} {}

      if {[catch {set r [${inst_}.[string trimleft ${k} -]]} err]} {

        puts "err = $err \n"
        error "Bad option \"$k\""
      }
      
      lappend result $r
      incr cnt
    }

    if {$cnt == 1} {set result [lindex $result 0]}

    return $result
    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } elseif {[string match "vget" "$cmd"]} { 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    # получит имя (полное, глобальное) переменной!
    #
    #if {[IsDebug]} {puts "args = $args"}
    # args = vget -param1 : предполагаем, что там одна переменная

    set k [lindex $args 1]   
    set k [string trimleft ${k} -]

    if {[catch {set v [VGET ${inst_} $k]} err]} {

      puts "err = $err \n"
      error "Bad option \"$k\""
    }
    
    #if {[IsDebug]} {puts "v = $v"}

    return $v

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } elseif {[string match "config*" "$cmd"]} {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    set L [lrange $args 1 end]

    if {[IsDebug]} {
      
      puts "L     = $L"
      puts "inst_ = $inst_"
      puts ""
    }
  
    foreach {k v} $L {

      set varname [string trimleft ${k} -]

      if {$::NEWEST} {
    
        SET $inst_ $varname $v
        #dict set  $inst_ $v
      } else {

        ${inst_}.$varname $v
        #${inst_}.${k} $v ;# pilot - временно
      }


    }
    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } else {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    error "Wrong argument.
            must be \"object cget|configure args\""
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  return [list]
  
}; # end proc ::struct::record::Cmd
#
#-------------------------------------------------------------------------------
# ::struct::record::Ns --
#
#    This just constructs a fully qualified namespace for a
#    particular instance.
#
# Arguments;
#    inst_    instance to construct the namespace for.
#
# Results:
#    Returns the fully qualified namespace for the instance
#-------------------------------------------------------------------------------
#
proc ::struct::record::Ns {inst_} {

    variable _defn

    if {[catch {set ret $_defn($inst_)} err]} {
        return $inst_
    }

    return [format "%s%s%s" "::struct::record" $ret "::"]

}; # end proc ::struct::record::Ns
#
#-------------------------------------------------------------------------------
# ::struct::record::Show --
#
#     Display info about the record that exist
#
# Arguments:
#    what_    subcommand
#    record_  record or instance to process
#
# Results:
#    if what_ = record, then return list of records
#               definition names.
#    if what_ = members, then return list of members
#               or members of the record.
#    if what_ = instance, then return a list of instances
#               with record definition of record_
#    if what_ = values, then it will return the values
#               for a particular instance
#-------------------------------------------------------------------------------
#
proc ::struct::record::Show {what_ {record_ ""}} {

    variable _recorddefn
    variable _defn
    variable _defaults

    ##
    ## We just prepend :: to the record_ argument
    ##
    if {![string match "::*" "$record_"]} {set record_ "::$record_"}

    if {[string match "record*" "$what_"]} {
        return [lsort [array names _recorddefn]]
    } elseif {[string match "mem*" "$what_"]} {

       if {[string match "" "$record_"] || ![info exists _recorddefn($record_)]} {
           error "Bad arguments while accessing members. Bad record name"
       }

       set res [list]
       set cnt 0
       foreach m $_recorddefn($record_) {
           set def [lindex $_defaults($record_) $cnt]
           if {[regexp -- {([\w]+)::([\w]+)} $m m d i]} {
               lappend res [list record $d $i]
           } elseif {![string match "" "$def"]} {
               lappend res [list $m $def]
           } else {
               lappend res $m
           }

           incr cnt
       }

       return $res

    } elseif {[string match "inst*" "$what_"]} {

        if {![info exists ::struct::record${record_}::instances]} {
            return [list]
        }
        return [lsort [set ::struct::record${record_}::instances]]

    } elseif {[string match "val*" "$what_"]} {

           set ns $_defn($record_)

           if {[string match "" "$record_"] || ([lsearch [set [Ns $record_]instances] $record_] < 0)} {

               error "Wrong arguments to values. Bad instance name"
           }

           set ret [list]
           foreach k $_recorddefn($ns) {

              set v [set [Ns $record_]values($record_,$k)]

              if {[regexp -- {([\w]*)::([\w]*)} $k m def inst]} {
                  set v [::struct::record::Show values ${record_}.${inst}]
              }

              lappend ret -[namespace tail $k] $v
           }
           return $ret

    }

    return [list]

}; # end proc ::struct::record::Show
#
#-------------------------------------------------------------------------------
# ::struct::record::Delete --
#
#    Deletes a record instance or a record definition
#
# Arguments:
#    sub_    what to delete. Either 'instance' or 'record'
#    item_   the specific record instance or definition
#            delete.
#
# Returns:
#    none
#
#-------------------------------------------------------------------------------
#
proc ::struct::record::Delete {sub_ item_} {

  variable _recorddefn
  variable _defn
  variable _count
  variable _defaults
  
  ##
  ## We just semi-blindly prepend :: to the record_ argument
  ##
  if {![string match "::*" "$item_"]} {set item_ "::$item_"}
  
  switch -- $sub_ {
    
    instance -
    instances -
    inst    {
      
      
      if {[Exists instance $item_]} {
        
        set ns $_defn($item_)
        foreach A [info commands ${item_}.*] {
          Delete inst $A
        }
        
        catch {
          foreach {k v} [array get [Ns $item_]values $item_,*] {
            
            unset [Ns $item_]values($k)
          }
          set i [lsearch [set [Ns $item_]instances] $item_]
          set [Ns $item_]instances [lreplace [set [Ns $item_]instances] $i $i]
          unset _defn($item_)
        }
        
        # Auto-generated id numbers increase monotonically.
        # Reverting here causes the next auto to fail, claiming
        # that the instance exists.
        # incr _count($ns) -1
        
      } else {
        #error "$item_ is not a instance"
      }
    }
    record  -
    records   {
      
      
      ##
      ##  Delete the instances for this
      ##  record
      ##
      foreach I [Show instance "$item_"] {
        catch {Delete instance "$I"}
      }
      
      catch {
        unset _recorddefn($item_)
        unset _defaults($item_)
        unset _count($item_)
        namespace delete ::struct::record${item_}
      }
      
      
    }
    default   {
      error "Wrong arguments to delete"
    }
    
  }; # end switch
  
  catch { uplevel \#0 [list interp alias {} $item_ {}]}
  
  return
  
}; # end proc ::struct::record::Delete
#
#-------------------------------------------------------------------------------
# ::struct::record::Exists --
#
#    Tests whether a record definition or record
#    instance exists.
#
# Arguments:
#    sub_    what to test. Either 'instance' or 'record'
#    item_   the specific record instance or definition
#            that needs to be tested.
#    
# Tests to see if a particular instance exists
#
#-------------------------------------------------------------------------------
#
proc ::struct::record::Exists {sub_ item_} {


  switch -glob -- $sub_ {
    inst*    {
      
      if {([lsearch ::[Ns $item_]instances $item_] >=0) || [llength [info commands ::${item_}.*]]} {
        return 1
      } else {
        return 0
      }
    }
    record  {
      
      set item_ "::$item_"
      if {[info exists _recorddefn($item_)] || [llength [info commands ${item_}]]} {
        return 1
      } else {
        return 0
      }
    }
    default  {
      error "Wrong arguments. Must be exists record|instance target"
    }
  }; # end switch
  

}; # end proc ::struct::record::Exists
#
#-------------------------------------------------------------------------------
# ::struct::record::Qualify --
#
#    Contructs the qualified name of the calling scope. This
#    defaults to 2 levels since there is an extra proc call in
#    between.
#
# Arguments:
#    item_   the command that needs to be qualified
#    level_  how many levels to go up (default = 2)
#    
# Results:
#    the item_ passed in fully qualified
#
#-------------------------------------------------------------------------------
#
proc ::struct::record::Qualify {item_ {level_ 2}} {

  if {![string match "::*" "$item_"]} {
    set ns [uplevel $level_ [list namespace current]]
    
    if {![string match "::" "$ns"]} {
      append ns "::"
    }
    
    set item_ "$ns${item_}"
  }
  
  return "$item_"
  
}; # end proc ::struct::record::Qualify

#-------------------------------------------------------------------------------

# ### ### ### ######### ######### #########
## Ready

namespace eval ::struct {

  # Get 'record::record' into the general structure namespace.

  namespace import -force record::record
  namespace export record
}


package provide struct::record 1.2.1

#-------------------------------------------------------------------------------
# 
# Получить полное имя переменной (параметра) в структуре (для прямого доступа).
# Почему такой нет ??
#
# Лучше ьы сделать, чтоб создавалась отдельная функция для Cmd ??
# Чтобы вызывать не [VGET $t param1] , а [$t VGET param1]    ?? или ладно?!
#
#-------------------------------------------------------------------------------
proc VGET {t param} {

  if {$::NEWEST} {
    set V  [GET $t $param]

  } else {
    set V [::struct::record::Ns $t]values($t,$param)
  }

}
#-------------------------------------------------------------------------------
# puts "Ns inst_ = [::struct::record::Ns $t]" ;# !! invalid command name "Ns"
#-------------------------------------------------------------------------------

namespace import ::struct::*
namespace import struct::record


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_com0_time {} {

  
  #set nums 10000
  set nums 100

  record define A {

    NN
  }

  puts ""

  set i 0
  puts "Create:   [time {A $i;   incr i} $nums]"
  
  set i 0
  puts "SG_1= :   [time {$i.NN = $i;  [$i.NN];  incr i} $nums]"

  set i 0
  puts "SGcget:   [time {$i configure -NN $i;  $i cget -NN;  incr i} $nums]"


  set i 0
  puts "SGvget:   [time {set name [$i vget -NN]; append $name NAME; incr i} $nums]"


  set i 0
  puts "Delete:   [time {record delete instance $i; incr i} $nums]"

  record delete record A

}
#-------------------------------------------------------------------------------

# ~/.pilot/s/compot/common$ b~.tl COM_0 TEST_com0_time

# Create:   25.81 microseconds per iteration
# SG_1= :   28.34 microseconds per iteration
# SGcget:   18.78 microseconds per iteration
# SGvget:    6.39 microseconds per iteration
# Delete:   79.81 microseconds per iteration

#-------------------------------------------------------------------------------
proc TEST_record_VGET {} {

  set pname [package require struct::record]  

  puts ""
  puts "package struct::record VERSION : $pname"
  puts ""
  
  # Record members can either be variables, or other records, However, the same 
  # record can not be nested witin itself (circular). To define a nested record, 
  # you need to specify the record keyword, along the with name of the record, 
  # and the name of the instance of that nested record. For example, it would 
  # look like this: 

  
  #namespace import ::struct::record::*
  #namespace import ::struct::*

  

  # this is the nested record
  #
  record define mynestedrecord {
    nest1
    nest2
  }

  # This is the main record
  #
  record define myrecord {
    mem1
    mem2
    {record mynestedrecord mem3}
  }

  # You can also assign default or initial values to the members of a record, 
  # by enclosing the member entry in braces: 

  #   record define myrecord {
  #     mem1
  #     {mem2 5}
  #   }

  # Alias access ------------------------------------------------------

  # In the original implementation, access was done by using dot notation 
  # similar to how 'C' structures are accessed. However, there was a concensus 
  # to make the interface more Tcl like, which made sense. However, the original 
  # alias access still exists. It might prove to be helpful to some.

  # Basically, for every member of every instance, an alias is created. This 
  # alias is used to get and set values for that member. An example will 
  # illustrate the point, using the above defined records: 


  # Сначала сделаем с автоматическим именованием!
  #

  set ret [myrecord inst0]
  puts "ret = $ret"
  puts ""

  $ret.mem2 = {1 2 3} 

  puts "NAME of ret.mem2 =  [VGET $ret mem2]"

  lappend [VGET $ret mem2] 45

  puts "ret.mem2 = [$ret.mem2]"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  # Create an instance first (ручное указание имени - возможно проблема!)
  #
  myrecord inst1

  # To get a member of an instance, just use the 
  # alias (it behaves like a Tcl command):  
  #
  puts "inst1.mem1 = [inst1.mem1]"

  inst1.mem1 = {1 2 3} 
  puts "inst1.mem1 = [inst1.mem1]"

  inst1.mem1  {4 5} 
  puts "inst1.mem1 = [inst1.mem1]"

  puts "NAME of inst1.mem =  [VGET inst1 mem1]"
  lappend [VGET inst1 mem1]  6 
  puts "inst1.mem1 = [inst1.mem1]" ;# ?? почему не срабатывает?

  puts ""

  # For nested records, just continue with the 
  # dot notation (note no equal sign)
  #
  puts "inst1.mem3.nest1 = [inst1.mem3.nest1]"
  inst1.mem3.nest1 10
  puts "inst1.mem3.nest1 = [inst1.mem3.nest1]"

  puts ""

  # just the instance by itself gives all 
  # member/values pairs for that instance
  #
  puts "inst1 = [inst1]"

  # and to get all members within the nested record
  #
  puts "inst1.mem3 = [inst1.mem3]"

  puts ""

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

