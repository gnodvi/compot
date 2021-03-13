# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/11768
# 
# RSA in tcl
# Updated 2013-02-21 06:53:46 by pooryorick²
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
proc TEST_1 {} {
#-------------------------------------------------------------------------------

# CMcC 2004-06-08: This is the RSA crypto algorithm in pure Tcl, requiring the
# bignum package.

#package require bignum
package require math::bignum


# Key is an array with at least the following
# n - public modulus
# e - public exponent
# d - exponent
# and optionally these elements
# p - prime p.
# q - prime q.
# u - inverse of p mod q.


namespace eval rsa {

  #namespace import ::bigint::*


  proc rsa_encrypt {input skey} {
    upvar $skey key
    
    if {[bitsize $key(n)] < [bitsize $input]} {
      error "keysize [bitsize $key(n)] must be greater than text [bitsize $input]/$input"
    }
    return [powm $input $key(e) $key(n)]
  }
  
  # fast RSA decryption
  # translated from gnupg
  #
  #   ptext = ctext^d mod n
  #
  # Or faster:
  #
  #      m1 = ctext ^ (d mod (p-1)) mod p 
  #      m2 = ctext ^ (d mod (q-1)) mod q 
  #      h = u * (m2 - m1) mod q 
  #      ptext = m1 + h * p
  #
  # Where m is OUTPUT, c is INPUT and d,n,p,q,u are elements of SKEY.

  proc rsa_decrypt {input skey} {
    upvar $skey key
    
    if {[bitsize $key(n)] < [bitsize $input]} {
      error "keysize [bitsize $key(n)] must be greater than text [bitsize $input]/$input"
    }
    
    if {![info exists key(p)]} {
      return [rsa_slow_decrypt $input key]
    }
    
    # m1 = c ^ (d mod (p-1)) mod p
    set m1 [powm $input [fdiv_r $key(d) [sub_ui $key(p) 1]] $key(p)]
    
    # m2 = c ^ (d mod (q-1)) mod q
    set m2 [powm $input [fdiv_r $key(d) [sub_ui $key(q) 1]] $key(q)]
    
    # h = u * ( m2 - m1 ) mod q
    set h [sub $m2 $m1]
    if {[cmp_si $h 0] < 0} {
      set h [add $h $key(q)]
    }
    set h [fdiv_r [mul $key(u) $h] $key(q)]
    
    # m = m2 + h * p
    set m [add $m1 [mul $h $key(p)]]
    
    return $m
  }
  
  # Public key operation. decrypt INPUT with PKEY and put result into OUTPUT.
  #
  #   c = m^d mod n
  #
  # Where c is OUTPUT, m is INPUT and e,n are elements of PKEY.
  proc rsa_slow_decrypt {input pkey} {
    upvar $pkey key
    
    if {[bitsize $key(n)] < [bitsize $input]} {
      error "keysize [bitsize $key(n)] must be greater than text [bitsize $input]/$input"
    }
    if {[catch {set ptext [powm $input $key(d) $key(n)]}]} {
      puts "rsa_slow_decrypt: $input [hex $key(d)] [hex $key(n)]"
      error "powm error"
    }
    return $ptext
  }
  
  proc pack_text {ptext keylen} {
    # pack ptext with md5
    while {[string length $ptext] < ($keylen - 16)} {
      append ptext [binary format H* [::md5::md5 $ptext]]
    }
    
    if {[string length $ptext] < $keylen} {
      set md5 [binary format H* [::md5::md5 $ptext]]
      append ptext [string range $md5 0 [expr $keylen - [string length $ptext] - 1]]
    }
    
    # convert the string to a hex number
    binary scan $ptext H* hex
    return [convert 0x$hex]
  }
  
  # encrypt a string - pad it out to full string size
  proc encrypt {ptext pkey} {
    upvar $pkey key
    
    set keylen [bytesize $key(n)]
    
    set en [pack_text $ptext $keylen]
    set en [rsa_encrypt $en key]
    append ctext [hex $en]
    
    set ctext [binary format H* $ctext]
    return $ctext
  }
  
  # encrypt a packet
  # packet format: [md5][length][payload][padding]
  proc encrypt_packet {ptext pkey} {
    upvar $pkey key
    
    set plen [binary format I [string length $ptext]]
    set md5 [binary format H32 [::md5::md5 $ptext]]
    
    set ptext ${md5}${plen}$ptext
    
    return [encrypt $ptext key]
  }
  
  proc decrypt {ctext pkey} {
    upvar $pkey key
    
    set keylen [bytesize $key(n)]
    
    binary scan $ctext H* block
    append ptext [hex [rsa_decrypt 0x$block key]]
    
    return [binary format H* $ptext]
  }
  
  # decrypt a packet
  # packet format: [md5][length][payload][padding]
  proc decrypt_packet {ctext pkey} {
    upvar $pkey key
    
    set ptext [decrypt $ctext key]
    binary scan $ptext a16I md5 plen
    set ptext [string range $ptext 20 end]
    set ptext [string range $ptext 0 [expr $plen - 1]]
    
    set md5calc [binary format H* [::md5::md5 $ptext]]
    
    if {$md5calc != $md5} {
      error "packet checksum failed $md5calc != $md5: $plen / $ptext"
    }
    return $ptext
  }
  
  namespace export encrypt* decrypt*
}
# gpg --gen-key --debug=4

#-------------------------------------------------------------------------------
# Here is a test of the rsa package:
#-------------------------------------------------------------------------------

array set key {
  name sample5
  e 0x010001
  d 0x036C3A32890E163000E25FAC522E1B3BAB6086837E6EF01CADCB4AA6DBDF0267D695FABA49ABB04B359E051DCE72FC377FE5C999D79D543861938233481E0D49D1
  n 0x057CA8F6CA506C64FC8BB83482F6EDD6C9AF6EF2EB235217680F7B76072CE320196355C89C0670B37D6F294FA4817EE1E7022566F17C8FB24C8B5ADA1A9BA115A7
}


proc do_key {} {
  global key
  foreach {var val} [array get key] {
    if {$var != "name"} {
      set key($var) [convert $val]
    }
  }
}

do_key
#mod_tsts

set t "now is the winter of our discontent"
set ct [rsa::encrypt $t key]
set pt [rsa::decrypt $ct key]

puts $pt

#-------------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------

#TEST_1

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# SSCH - What/Where is the "convert" command?

# NEM - What/where are the "do_key" and "mod_tsts" commands?

# CMcC - The original test code was 200 lines, do_key converts the key components
# to binary (added) mod_tsts compares the result of several different decrypt
# techniques.

# Zarutian - Is there any implemention of the RSA crypto without using a extension?

# CMcC - nope. It involves arithmetic operation over thousand-bit integers,
# which would be fairly slow.

# Zarutian - I am mainly asking because of portability issues. See wish nr #70
# on the Tcl 9.0 WishList.

# LV If someone could point us to the original algorithm, the missing function
# might be able to be written.

#-------------------------------------------------------------------------------
proc TEST_2 {} {
#-------------------------------------------------------------------------------


# load ~/Tcl/mpexpr10.dll

package require Mpexpr

proc powm5 { x n m } {

  set result 1
  while { [mpexpr { $n != 0 }] } {
    if { [mpexpr { $n % 2 } == 1] } {
      set result [mpexpr { ( $result * $x ) % $m }]
    }
    set x [mpexpr { ($x * $x) % $m }]
    set n [mpexpr { $n >> 1 }]
  }

  return $result
}

array set key {

  name sample5
  e 0x010001
  d 0x036C3A32890E163000E25FAC522E1B3BAB6086837E6EF01CADCB4AA6DBDF0267D695FABA49ABB04B359E051DCE72FC377FE5C999D79D543861938233481E0D49D1
  n 0x057CA8F6CA506C64FC8BB83482F6EDD6C9AF6EF2EB235217680F7B76072CE320196355C89C0670B37D6F294FA4817EE1E7022566F17C8FB24C8B5ADA1A9BA115A7

}

binary scan "now is the winter of our discontent" h* t

set plaintext 0x$t
set plaintext [mpexpr $plaintext]

puts $plaintext

set cypher [powm5 $plaintext $key(e) $key(n)]

puts $cypher
set plain2 [powm5 $cypher $key(d) $key(n)]

puts $plain2

puts "encrypt: [time {powm5 $plaintext $key(e) $key(n)} 10]"
puts "decrypt: [time {powm5 $plaintext $key(d) $key(n)} 10]"

#-------------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------

#TEST_2

#-------------------------------------------------------------------------------

# Zarutian 4.august 2004: maybe a little slower than the orginal implemention and
# it is a little more portable

# 20041109 Twylite - You could also look at bignum in pure Tcl, and Tcllib now
# has a pure Tcl math::bignum package (I don't know if these two are related).

# 1-26-2005 mdd: How do you generate the keys? Do GPG keys work?

# 2006-05-10: What is [convert 0x$hex] and [convert $val] ? I can't find a
# convert procedure anywhere.

# 2007-02-25: JET: Where is the convert function? It does not seem to have ever
# been provided.. Even just a description of what it is supposed to do would be
# vrey helpful.

# 2007-07-09: Sarnold: 'convert' seems to convert an hex integer into a binary
# string (an array of byte). [convert 0x20] should give a space ' '. It seems
# that the binary command should be able to provide the same functionality.

#-------------------------------------------------------------------------------
if {0} {

  # 2007-07-10: Googie: And what about bytesize and bitsize? I've defined them as
  # following:
  
  proc bytesize {arg} {
    set v [math::bignum::fromstr [string tolower $arg]]
    return [string bytelength [math::bignum::tostr $v]]
  }
  
  proc bitsize {arg} {
    set v [expr {[bytesize $arg]*8}]
    return $v
  }
  
  # but it doesn't work correctly :/ What should their bodies be like?

}
#-------------------------------------------------------------------------------
if {0} {

  # 2007-07-11 CMcC
  # The bignum package contains the necessary routines.
  
  critcl::cproc convert {Tcl_Interp* interp Tcl_Obj* obj} ok {
    
    if (doSetMPZ(obj)) {
      
      Tcl_SetObjResult(interp, obj);
      return TCL_OK;
    }
    return TCL_ERROR;
  }
  
  # and
  
  proc bytesize {x} {
    return [expr [sizeinbase $x 16] /2 ]
  }
  
  proc bitsize {x} {
    return [expr [sizeinbase $x 16] * 4]
  }
  
}
#-------------------------------------------------------------------------------

# Googie 2008-01-02: Since Tcl 8.5 supports big integers I guess it's pretty easy
# to write pure-Tcl RSA extension which would fit into Tcllib perfectly, isn't it?

#-------------------------------------------------------------------------------
proc TEST_3 {} {

  # Twylite 2008-09-22: Indeed it does; here is a expr extension for bignum modular
  # exponentiation:
  
  #** ::tcl::mathfunc::modexp b e n
  
  # Adds a modexp() function to expr.  Modular exponentiation (modexp) raises
  # the base b to a power e modulo n.  This function supports bignums.
  # Returns the result ((b ** e) % n)
  #
  
  # Use 'format %llX $bignum' to display a bignum as a hex string
  
  proc ::tcl::mathfunc::modexp {b e n} {
    
    # This is a straight-forward square-and-multiply implementation that relies
    # on Tcl's bignum support (based on LibTomMath) for speed.  
    set r 1
    while { 1 } {
      if { $e & 1 } {
        set r [::tcl::mathop::% [::tcl::mathop::* $r $b] $n]
      }
      set e [::tcl::mathop::>> $e 1]
      if { $e == 0 } break
      set b [::tcl::mathop::% [::tcl::mathop::** $b 2] $n]
    }
    return $r 
  }
  
  #----------------------------------------
  # And here's how you use it:
  
  set d 0x1FEFB2B8F2F18AE7B7AC4036A363FA074DA7C53B9CE4E6223243BC917A2EE0E8E0D0E20D9780EB048B9C5F8BCB963BF643ACDA5D5A1E2E2DB3C7EAF47195DC13
  
  set e 0x3
  
  set n 0xBF9E3055B1A9416E4E098147D457DC2BD1EE9F65AD5D64CD2D966B68DD1945770371F7E1881F8178E1A53E109272E0953660A74008684964FA23E2988F6402CB
  
  set base 0x55555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555
  
  set expected 0x3901C53B355237DE90BE1DC8F6043A62BF5179234D164E1DAF3DBCEB0CAEF9E2435773344444E20E5B5B186542BCBF2B2C07A568F9A77EB1EFAC932272288428
  
  set sign   0x[format %llx [tcl::mathfunc::modexp $base $e $n]]
  set unsign 0x[format %llx [expr { modexp( $expected, $d, $n ) }]]
  
  # In performance comparisons against a C program performing the same calculations
  # using libTomCrypt's mp_exptmod this function achieved 50% - 85% of the speed of C.
  
  puts ""
  puts "d = $d"
  puts "e = $e"
  puts "n = $n"
  puts "base = $base"
  puts ""
  puts "expected = $expected"
  puts ""
  puts "sign = $sign"
  puts "unsign = $unsign"
  puts ""

}

TEST_3

#-------------------------------------------------------------------------------
# Tcllib has a PKI module which includes RSA support.
#-------------------------------------------------------------------------------

# DKF: A somewhat faster version (about 20% faster in my simple tests with data
# of the sorts of sizes seen in RSA) is this:

proc tcl::mathfunc::modexp {a b n} {
    for {set c 1} {$b} {set a [expr {$a*$a%$n}]} {
        if {$b & 1} {
            set c [expr {$c*$a%$n}]
        }
        set b [expr {$b >> 1}]
    }
    return $c 
}

#-------------------------------------------------------------------------------

# The difference in speed seems to be mainly due to avoiding the use of the **
# operator.


# Key generation will require generation of prime numbers. In addition, the
# primeCheckLucas implements a Lucas prime check as per fips186-3 (rwm)


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
											  
