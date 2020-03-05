# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# from  ...  tcllib-1.14/modules/struct/record.test
#-------------------------------------------------------------------------------
#
# RECORD   RECORD   RECORD   RECORD   RECORD   RECORD   RECORD   RECORD  
#
# http://tcllib.sourceforge.net/doc/record.html
# 
#-------------------------------------------------------------------------------
proc TEST_record_00 {} {


  if {[IsDebug]} {
    puts ""
  }

  record define myrecord {

    {mem1 000}
    {mem2 999}
    mem3
  }

  # Create an instance first
  #
  set ret [myrecord r]

  if {$::NEWEST} {

    puts ""
    puts "ret = $ret"
    puts "ret = [set $ret]"
    puts "ret = [dict_print $ret]"
    SET  $ret "mem1" 111
  } 

  if {[IsDebug]} {
    puts ""
    puts "----------------------------------------------------"
  }

  puts ""
  puts "ret = $ret"
  puts ""

  if {[IsDebug]} {
    puts "----------------------------------------------------"
    puts ""
  }

  puts "$ret.mem2 = [$ret.mem2]"
  puts ""

  puts "$ret.mem1 = [$ret cget -mem1]"
  puts ""

  if {[IsDebug]} {
    puts "----------------------------------------------------"
    puts "----------------------------------------------------"
    puts "----------------------------------------------------"
    puts "----------------------------------------------------"
    puts ""
  }

  $ret configure -mem1 "HELLO"

  puts "$ret.mem1 = [$ret cget -mem1]"
  puts ""


  puts "$ret.mem3 = [$ret cget -mem3]"
  #puts ""

  #$ret.mem3 = 11111 

  # list_make $n "NIL"  - реальный список 
  # list_create         - глобальный указатель на пустой список
  # list_create_num_val - заполнили список по гл.указателю

  $ret.mem3 = [list_create_num_val 4 "NIL"] 

  puts "$ret.mem3         = [$ret cget -mem3]"
  puts "NAME of $ret.mem3 = [VGET $ret  mem3]" ;# то же самое
  puts "NAME of $ret.mem3 = [$ret vget  mem3]" ;# то же самое

  puts ""
  puts "mem3 = [set [$ret cget -mem3]]"
  puts ""
  lappend [VGET $ret mem3] 45555

  if {$::NEWEST} {
    puts "mem3 = [set [$ret cget -mem3]]"
    puts "mem1 = [GET $ret mem1]"
  }


  # ----------------------------------------------------------
  if {$::NEWEST} {return} ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # ----------------------------------------------------------

  puts "r.mem2   = [r.mem2]"

  puts "r.mem3   = [r.mem3]"
  
  puts ""
  
  #   #set i1 r
  
  $ret configure -mem3 "pilot"
  $ret.mem3 = {1 2 3} ;# работает в обоих вариантах!
  
  
  # пока убрали обрезалку слева всех "минусов"
  #

  puts "r.mem1 = [$ret cget -mem1]"
  puts "r.mem2 = [r.mem2]"
  puts "r.mem3 = [r.mem3]"
  
  puts ""
  

  # Фишка: обращаемся к элементу (добавляем в список) по имени:
  # 
  puts "NAME of ret.mem3 =  [VGET $ret mem3]"

  lappend [VGET $ret mem3] 45

  puts "r.mem3 = [$ret.mem3]"

  return
}
#-------------------------------------------------------------------------------
proc TEST_record_00_NEW {} {


  #DebugOn
  
  set ::NEWEST 1

  TEST_record_00

  return
}
#-------------------------------------------------------------------------------
proc TEST_record_11_NEW {} {


  #DebugOn
  
  #set ::NEWEST 1

  package require struct::record

  #::struct::record::dictrecord define myrecord {}

  dictrecord define MYRECORD {

    {mem1 000}
    {mem2 999}
  }

  set ret [MYRECORD  auto]

  puts ""
  puts "mem1 = [GET $ret mem1]" 

  SET $ret mem1 "PRIVET"

  puts ""
  puts "mem1 = [GET $ret mem1]"

  #invalid command name "dictrecord"
  #  while executing  ????????????????????????

  return
}
#-------------------------------------------------------------------------------

# b~.tl COM_0 TEST_record_00_NEW

#-------------------------------------------------------------------------------
proc TEST_record_02 {} {

  package require struct::record

  ##
  ##  This is an interactive example, to see what is 
  ##  returned by each command as well.
  ##

  #namespace import ::struct::record::*
  #namespace import ::struct::*

  # define a nested record. Notice that country has default 'USA'.
  record define locations {
    street
    street2
    city
    state
    zipcode
    {country USA}
    phone
  }
  #::locations

  # Define the main record. Notice that it uses the location record twice.
  record define contacts {
    first 
    middle 
    last 
    {record locations home}
    {record locations work}
  }
  #::contacts

  # Create an instance for the contacts record.
  contacts cont1

  # Display some introspection values
  puts ""
  puts "record show records = [record show record]"
  puts "record show records = [record show records]"
  puts ""

  puts "record show values cont1 = [record show values cont1]"
  puts ""
 
  puts "record show instances  contacts = [record show instances  contacts]"
  puts ""


  puts "cont1 config = [cont1 config]"
  puts ""

  puts "cont1 cget = [cont1 cget]"
  puts ""

  # copy one record to another record
  record define contacts2 [record show members contacts]

  puts "record show members contacts2 = [record show members contacts2]"
  puts "record show members contacts = [record show members contacts]"

}
#-------------------------------------------------------------------------------
proc TEST_record_03 {} {

  #package require struct::record
  #namespace import ::struct::*

  puts ""

  # define a very simple record for linked list
  record define llist {
    value
    next
  }

  llist lstart

  lstart config -value 1 -next [llist #auto] 
  [lstart cget -next] config -value 2 -next [llist #auto] 

  [[lstart cget -next] cget -next] config -value 3 -next "end"
  set next lstart

  lstart

  while 1 {
    lappend values [$next cget -value]
    set next [$next cget -next]
    if {[string match "end" $next]} {break}
  }

  puts "$values"
  # cleanup linked list
  # We could just use delete record llist also

  foreach I [record show instances llist] {
    record delete instance $I
  }

  record show instances llist

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_record_all {} {


  #namespace import ::struct::*

  #set ::NEWEST 0


  puts ""

  TEST_record_00

  #TEST_record_01

  #TEST_record_02

  TEST_record_03

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_record {} {

  #namespace import ::struct::*

  puts ""

  record define TEST_T {

    define 
  }

  set t [TEST_T  \#auto] ;#

  puts "t = $t"

  #TEST_T  t

  #t.define

  #lappend t.define "88" ;# просто создаст новое имя, но не то !!

  #puts "define = ::record::t.define"

  #puts "${t.define}"

  #puts "define = [t cget -define]"


  #puts [record show records]
  #puts [record show members JOY_T]
  #puts [record show members TEST_T]

  #return

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  $t configure -define   {01 02 03} ;#


  puts "define = [$t cget -define]" 

  ;# define =  01 02 03  - для COM_0
  ;# define = {01 02 03} - для COM_1

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {0} {

    set def [$t.define]
    lappend def "99"
    $t configure -define $def

  } else {

    # почему енльзя явно по имену списка добавить элемнт ?
    # 
    lappend $t.define "88" ;# просто создаст новое имя, но не то !!
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  puts "define = [$t cget -define]"

  #puts "t = $t"
  #puts "define = [set $t::define]"

  set ::VAAAAAAJHJHJHJHJHKHKAAAAA 12345

  puts "info globals = [info globals]"
         
  puts "info locals  = [info locals]"
         
  puts "info lvars  =  [info vars]"
       
  
  return
}
#-------------------------------------------------------------------------------
proc TEST_main {} {

  namespace import ::struct::*


  puts ""
  DebugOn

  record define STRUCT_T {

    param2 
    param3 
  }

  record define TEST_T {

    param1 
    {record STRUCT_T str}
  }

  set t [TEST_T  #auto] ;# уже создан алиас на эту команду


  # if {[IsDebug]} {puts "variable name = [Ns $inst_]values($inst_,$V)"}
  # if {[IsDebug]} {puts "variable val  = $D"}
  #variable name = ::struct::record::TEST_T::values(::TEST_T0,param1)
  #variable val  = 

  puts ""
  puts "t = $t"

  puts "param1 = [$t cget -param1]"

  $t.param1 = {22 33}

  puts "param1 = [$t.param1]"

  lappend  [VGET $t param1]  44

  puts "param1 = [$t.param1]"

  #~~~~~~~~~~~~~~~~~~~~~~~

  puts "str = [$t.str]"

  #[$[$t.str].param1]] = 55

  $t.str.param2  55

  puts "str = [$t.str]"

  lappend  [VGET $t.str param2] 66

  puts "str = [$t.str]"


  lappend  [VGET $t  param1]  88
  puts "param1 = [$t.param1]"

  lappend  [$t vget -param1]  99
  puts "param1 = [$t.param1]"

  return
}
#
#-------------------------------------------------------------------------------
#







# -------------------------------------------------------------------------
# record.test --
#
#    test suite for struct::record module
#
# Tcl tests for testing the struct::record package, which
# loosely immitates a 'C' structure. Invoke this test suite
# by: tclsh record.test
#

# -------------------------------------------------------------------------

# source [file join \
# 	[file dirname [file dirname [file join [pwd] [info script]]]] \
# 	devtools testutilities.tcl]

#source testutilities.tcl

#testsNeedTcl     8.2
#testsNeedTcltest 1.0 ;# ??

# -------------------------------------------------------------------------

package require tcltest
namespace import ::tcltest::*

#source "b-com0.tl"
#namespace import struct::record

# -------------------------------------------
proc sum {a b} {

  expr {$a + $b}
}
# -------------------------------------------
# -------------------------------------------------------------------------
proc ALLTESTS {} {


  test sum_addTwoZerosExpectZero {
    Test: [sum 0 0] == 0
  } -body {
    sum 0 0
  } -result 0
  
  # -------------------------------------------------------------------------
  #testing {
  #    useLocal record.tcl struct::record
  #}
  
  #exit
  # -------------------------------------------------------------------------
  #----------------------------------------------------------------------
  
  test record-0.1 {record define} {
    record define phones {home work cell}
  } ::phones
  
  test record-0.2 {record define - multi line} {
    record define contact {
      first
      middle
      last
      {record phones phlist}
    }
  } ::contact
  
  test record-0.3 {record define - multi line} {
    record define mycontact {
      age
      sex
      {record contact cont}
    }
  } ::mycontact
  
  test record-0.4 {definition with instantiation} {
    record define location {
      street
      city
      state
      {country USA}
    } loc(1) loc(5)
  } ::location
  
  test record-0.5 {test error with circular records} {
    catch {
      record define circular {
        one
        {record circular cir}
      } cir(1)
    } err
    set err
  } "Can not have circular records. Structure was not created."
  
  test record-0.6 {single instance} {
    contact cont(1)
  } ::cont(1)
  
  test record-0.7 {auto instance} {
    contact \#auto
  } ::contact0
  
  test record-0.8 {instance of double nested record} {
    set res [mycontact \#auto]
    lappend res [record show values $res]
    set res
  } {::mycontact0 {-age {} -sex {} -cont {-first {} -middle {} -last {} -phlist {-home {} -work {} -cell {}}}}}
  
  test record-0.9 {setting a instance var via alias} {
    cont(1).first Brett
  } Brett
  
  test record-1.0 {setting a nested instance var via alias} {
    cont(1).phlist.cell 425-555-1212
  } 425-555-1212
  
  test record-1.1 {setting a double nested instance var via alias} {
    mycontact0.cont.phlist.cell 206-555-1212
  } 206-555-1212
  
  test record-1.2 {setting values via config} {
    cont(1) config -middle Allen -last Schwarz
  } ""
  
  test record-1.3 {setting a double nested instance  via config} {
    mycontact0 config -cont.phlist.cell 206-555-1212
  } ""
  
  test record-1.4 {get a value via cget} {
    cont(1) cget -first -middle -last
  } [list Brett Allen Schwarz]
  
  test record-1.5 {get a double nested value via cget} {
    mycontact0 cget -cont.phlist.cell
  } 206-555-1212
  
  test record-1.6 {get a value via alias} {
    cont(1).first
  } Brett
  
  test record-1.7 {record default value} {
    loc(1) cget -country
  } USA
  
  test record-1.8 {setting values via config} {
    loc(1) config -street somestreet -city somecity -state somestate -country somecountry
  } ""
  
  test record-1.9 {setting nested vars via config} {
    cont(1) config -phlist.home 425-555-1212
  } ""
  
  test record-2.0 {test value of nested member} {
    cont(1) cget -phlist.home
  } 425-555-1212
  
  test record-2.1 {config with no values} {
    loc(1) config
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-2.2 {get with no values} {
    loc(1) cget
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-2.3 {get with just instance command} {
    loc(1)
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-2.4 {get a nest value via alias} {
    cont(1).phlist.cell
  } 425-555-1212
  
  test record-2.5 {set values during instantiation} {
    location loc(2) -street street2 -city city2 -state state2 -country country2
  } ::loc(2)
  
  test record-2.6 {get the above value via alias} {
    loc(2).street
  } street2
  
  test record-2.7 {set values during instantiation - nested record} {
    contact cont(2) -first John -middle Q -last Doe -phlist [list home 425-555-1212 work 425-555-1222 cell 425-555-1111]
  } ::cont(2)
  
  test record-2.8 {copy one instance to another during creation} {
    eval contact cont(3) [cont(1)]
  } ::cont(3)
  
  test record-2.9 {get the above values via alias} {
    cont(2).phlist.home
  } 425-555-1212
  
  test record-3.0 {copy one definition to another definition} {
    record define new_contact [record show members contact]
  } ::new_contact
  
  test record-3.1 {show defined records} {
    record show records
  } [lsort [list ::phones ::contact ::location ::new_contact ::mycontact]]
  
  test record-3.2 {show members} {
    record show members phones
  } [list home work cell]
  
  test record-3.3 {show members - with default value} {
    record show members location
  } [list street city state [list country USA]]
  
  test record-3.4 {show members - nested record} {
    record show members contact
  } [list first middle last [list record phones phlist]]
  
  test record-3.5 {show values} {
    record show values loc(1)
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-3.6 {show values - nested} {
    record show values cont(1)
  } [list -first Brett -middle Allen -last Schwarz -phlist [list -home 425-555-1212 -work {} -cell 425-555-1212]]
  
  test record-3.7 {show instances} {
    record show instance location
  } [list ::loc(1) ::loc(2) ::loc(5)]
  
  
  test record-3.8 {delete an instance} {
    record delete instance loc(2)
  } ""
  
  test record-3.9 {delete a nested instance} {
    record delete instance cont(2)
  } ""
  
  test record-4.0 {delete a record} {
    record delete record location
  } ""
  
  test record-4.1 {test existence of an instance that was deleted} {
    record exists instance loc(1)
  } 0
  
  test record-4.2 {show existence of an instance} {
    record exists instance cont(1)
  } 1
  
  test record-4.3 {show non-existent instance} {
    record exists instance junk
  } 0
  
  test record-4.4 {show existence of record} {
    record exists record contact
  } 1
  
  
  ##
  ##    NAMESPACE TESTS
  ##
  
  test record-5.0 {record define} {
    namespace eval myns {
      record define phones {home work cell}
    }
  } ::myns::phones
  
  test record-5.1 {record define - multi line} {
    record define ::myns::contact {
      first
      middle
      last
      {record phones phlist}
    }
  } ::myns::contact
  
  test record-5.2 {definition with instantiation} {
    namespace eval myns {
      record define location {
        street
        city
        state
        {country USA}
      } loc(1) loc(5)
    }
  } ::myns::location
  
  test record-5.3 {test error with circular records} {
    catch {
      namespace eval myns {
        record define circular {
          one
          {record ::myns::circular cir}
        } cir(1)
      }
    } err
    set err
  } "Can not have circular records. Structure was not created."
  
  test record-5.4 {single instance} {
    namespace eval myns {
      contact cont(1)
    }
  } ::myns::cont(1)
  
  test record-5.5 {auto instance} {
    namespace eval myns {
      contact \#auto
    }
  } ::myns::contact0
  
  test record-5.6 {setting a instance var via alias} {
    myns::cont(1).first Brett
  } Brett
  
  test record-5.7 {setting a nested instance var via alias} {
    myns::cont(1).phlist.cell 425-555-1212
  } 425-555-1212
  
  test record-5.8 {setting values via config} {
    myns::cont(1) config -middle Allen -last Schwarz
  } ""
  
  test record-5.9 {get a value via cget} {
    myns::cont(1) cget -first -middle -last
  } [list Brett Allen Schwarz]
  
  test record-6.0 {record default value} {
    myns::loc(1) cget -country
  } USA
  
  test record-6.1 {setting values via config} {
    myns::loc(1) config -street somestreet -city somecity -state somestate -country somecountry
  } ""
  
  test record-6.2 {setting nested vars via config} {
    myns::cont(1) config -phlist.home 425-555-1212
  } ""
  
  test record-6.3 {test value of nested member} {
    myns::cont(1) cget -phlist.home
  } 425-555-1212
  
  test record-6.4 {config with no values} {
    myns::loc(1) config
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-6.5 {get with no values} {
    myns::loc(1) cget
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-6.6 {get with just instance command} {
    myns::loc(1)
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-6.7 {get a nest value via alias} {
    myns::cont(1).phlist.cell
  } 425-555-1212
  
  test record-6.8 {set values during instantiation} {
    namespace eval myns {
      location loc(2) -street street2 -city city2 -state state2 -country country2
    }
  } ::myns::loc(2)
  
  test record-6.9 {get the above value via alias} {
    myns::loc(2).street
  } street2
  
  test record-7.0 {set values during instantiation - nested record} {
    namespace eval myns {
      contact cont(2) -first John -middle Q -last Doe -phlist [list home 425-555-1212 work 425-555-1222 cell 425-555-1111]
    }
  } ::myns::cont(2)
  
  test record-7.1 {get the above values via alias} {
    myns::cont(2).phlist.home
  } 425-555-1212
  
  
  test record-7.2 {show defined records} {
    record show records
  } [lsort [list ::contact ::myns::phones ::myns::contact ::myns::location ::new_contact ::phones ::mycontact]]
  
  test record-7.3 {show members} {
    record show members myns::phones
  } [list home work cell]
  
  test record-7.4 {show members - with default value} {
    record show members myns::location
  } [list street city state [list country USA]]
  
  test record-7.5 {show members - nested record} {
    record show members myns::contact
  } [list first middle last [list record phones phlist]]
  
  test record-7.6 {show values} {
    record show values myns::loc(1)
  } [list -street somestreet -city somecity -state somestate -country somecountry]
  
  test record-7.7 {show values - nested} {
    record show values myns::cont(1)
  } [list -first Brett -middle Allen -last Schwarz -phlist [list -home 425-555-1212 -work {} -cell 425-555-1212]]
  
  test record-7.8 {show instances} {
    record show instance myns::location
  } [list ::myns::loc(1) ::myns::loc(2) ::myns::loc(5)]
  
  
  test record-7.9 {delete an instance} {
    record delete instance myns::loc(2)
  } ""
  
  test record-8.0 {delete a nested instance} {
    record delete instance myns::cont(2)
  } ""
  
  test record-8.1 {delete a record} {
    record delete record myns::location
  } ""
  
  test record-8.2 {test existence of an instance that was deleted} {
    record exists instance myns::loc(1)
  } 0
  
  test record-8.3 {show existence of an instance} {
    record exists instance myns::cont(1)
  } 1
  
  test record-8.4 {show non-existent instance} {
    record exists instance myns::junk
  } 0
  
  test record-8.5 {show existence of record} {
    record exists record myns::contact
  } 1
  
  
  # Auto instances and deletion.
  
  test record-9.0 {auto instance & deletion} {
    set res {}
    lappend res [contact \#auto]
    lappend res [contact \#auto]
    
    record delete instance [lindex $res end]
    
    lappend res [contact \#auto]
    
  } {::contact1 ::contact2 ::contact3}
  
  test record-10.0 {nesting records more than one level} {
    set jmod aMacro
    
    record define fitParams {
      amp
      unmod
      jcoup
      t2star
    }
    
    record define fitData {
      delays
      values
    }
    
    record define fitInput {
      {reps 30}
      {sdev 0.1}
      {seed 12345}
      {record fitParams params}
      {record fitData data}
    }
    
    record define fitXYData {
      silent
      verbose
      macro
      confidence
      {record fitInput input}
    }
    
    set fitXYInputData [fitXYData \#auto]
    
    $fitXYInputData.silent  true
    $fitXYInputData.verbose true
    $fitXYInputData.macro $jmod
    $fitXYInputData.confidence 0.9
    
    set res [record show values $fitXYInputData]
    
    record delete instance $fitXYInputData
    set res
  } {-silent true -verbose true -macro aMacro -confidence 0.9 -input {-reps 30 -sdev 0.1 -seed 12345 -params {-amp {} -unmod {} -jcoup {} -t2star {}} -data {-delays {} -values {}}}}
  
} ;# ALLTESTS
#-------------------------------------------------------------------------------
#

#ALLTESTS

#-------------------------------------------------------------------------------
# тесты для пакета собраного из tclOO
#-------------------------------------------------------------------------------
proc DEMO_proc {} {


  record define Phone {
    {mobile ""}
    {landline ""}
  }

  record define Contact {
    {email_id ""}
    {website ""}
    {record Phone phone}
  }

  record define Employee {
    {id -1}
    {name ""}
    {rollno ""}
    {address_id <null>}
    {record Contact contact}
  } emp1

  emp1.contact.phone.mobile "testmobile"
  puts [record show values emp1]
  
  Employee emp2 -name "constructed name"
  puts [emp2 cget]
  
  puts [emp2.name]
  puts [emp2.contact.phone.landline]
  
  puts [record show records]
  puts [record show instances Employee]
  puts [record show instances Contact]
  puts [record show instances Phone]
  puts [record show members Employee]
  
  
  puts [Employee show]
  
  emp2 configure -name "configured name" -rollno "configured rollno"
  puts [emp2 cget]
  
  emp2 clear
  puts [emp2 cget]
  
  puts [record exists record Employee]
  puts [record exists instance emp1]
  puts [record delete instance emp1]
  puts [record exists instance emp1]
  puts [record delete record Employee]
  puts [record exists record Employee]
  
}
#-------------------------------------------------------------------------------
proc PERF_proc {} {

  catch {record delete record phones}
  record define phones {home work cell}

  catch {record delete record contact} 
  record define contact {
    first
    middle
    last
    {record phones phlist}
  }

  catch {record delete record mycontact} 
  record define mycontact {
    age
    sex
    {record contact cont}
  }

  catch {record delete record location} 
  record define location {
    street
    city
    state
    {country USA}
  } loc(1) loc(5)

  catch {
    record define circular {
      one
      {record circular cir}
    } cir(1)
  } err
  contact cont(1)

  contact \#auto
  set res [mycontact \#auto]

  lappend res [record show values $res]
  set res

  cont(1).first Brett
  cont(1).phlist.cell 425-555-1212
  mycontact0.cont.phlist.cell 206-555-1212
  cont(1) config -middle Allen -last Schwarz
  mycontact0 config -cont.phlist.cell 206-555-1212
  cont(1) cget -first -middle -last
  mycontact0 cget -cont.phlist.cell
  cont(1).first
  loc(1) cget -country
  loc(1) config -street somestreet -city somecity -state somestate -country somecountry
  cont(1) config -phlist.home 425-555-1212
  cont(1) cget -phlist.home
  loc(1) config
  loc(1) cget
  loc(1)
  cont(1).phlist.cell
  location loc(2) -street street2 -city city2 -state state2 -country country2
  loc(2).street
  contact cont(2) -first John -middle Q -last Doe -phlist [list home 425-555-1212 work 425-555-1222 cell 425-555-1111]
  eval contact cont(3) [cont(1)]
  cont(2).phlist.home
  catch {record delete record new_contact} 
  record define new_contact [record show members contact]
  record show records
  record show members phones
  record show members location
  record show members contact
  record show values loc(1)
  record show values cont(1)
  record show instance location
  record delete instance loc(2)
  record delete instance cont(2)
  record delete record location
  record exists instance loc(1)
  record exists instance cont(1)
  record exists instance junk
  record exists record contact

  namespace eval myns {
    catch {record delete record myns::phones} 
    record define phones {home work cell}
  }

  catch {record delete record ::myns::contact} 
  record define ::myns::contact {
    first
    middle
    last
    {record phones phlist}
  }

  namespace eval myns {
    catch {record delete record location} 
    record define location {
      street
      city
      state
      {country USA}
    } loc(1) loc(5)
  }

  catch {
    namespace eval myns {
      record define circular {
        one
        {record ::myns::circular cir}
      } cir(1)
    }
  } err

  set err
  namespace eval myns {
    contact cont(1)
  }

  namespace eval myns {
    contact \#auto
  }
  
  myns::cont(1).first Brett
  myns::cont(1).phlist.cell 425-555-1212
  myns::cont(1) config -middle Allen -last Schwarz
  myns::cont(1) cget -first -middle -last
  myns::loc(1) cget -country
  myns::loc(1) config -street somestreet -city somecity -state somestate -country somecountry
  myns::cont(1) config -phlist.home 425-555-1212
  myns::cont(1) cget -phlist.home
  myns::loc(1) config
  myns::loc(1) cget
  myns::loc(1)
  myns::cont(1).phlist.cell
  namespace eval myns {
    location loc(2) -street street2 -city city2 -state state2 -country country2
  }
  myns::loc(2).street
  namespace eval myns {
    contact cont(2) -first John -middle Q -last Doe -phlist [list home 425-555-1212 work 425-555-1222 cell 425-555-1111]
  }
  myns::cont(2).phlist.home
  record show records
  record show members myns::phones
  record show members myns::location
  record show members myns::contact
  record show values myns::loc(1)
  record show values myns::cont(1)
  record show instance myns::location
  record delete instance myns::loc(2)
  record delete instance myns::cont(2)
  record delete record myns::location
  record exists instance myns::loc(1)
  record exists instance myns::cont(1)
  record exists instance myns::junk
  record exists record myns::contact
  set res {}
  lappend res [contact \#auto]
  lappend res [contact \#auto]
  
  record delete instance [lindex $res end]
  
  lappend res [contact \#auto]
               
}
#-------------------------------------------------------------------------------
proc TIME_proc {} {


  puts ""
  
  #DEMO_proc
  
  #puts ""
  
  #puts [time {PERF_proc} 1000]

  set time [time {PERF_proc} 10]

  #puts "{$time}"
  puts "$time"
  
  puts ""
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#TEST_proc


# b~.tl COM0 ARR2_test 
# b~.tl COM_0 TEST_main 
# b~.tl COM_0 TEST_record_00 
# b~.tl COM_0 TEST_record_03 
# b~.tl COM_0 TEST_record_VGET 
# b~.tl MISC MFOR_test5 

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
