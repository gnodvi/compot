# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/11769
# 

# RSA
# Updated 2012-09-10 23:08:27 by RLE

#-------------------------------------------------------------------------------

# Purpose: to discuss what RSA stands for, where it is documented, and its 
# implications. ---

# RSA is

#   * a public-key cryptosystem, which can also be used for digital signatures.
#   * an acronym for: Rivest Shamir Adleman, the names of the three inventors of 
#     this cryptosystem.

# Is there a web home for the topic?

#     http://en.wikipedia.org/wiki/RSA

#-------------------------------------------------------------------------------

# The underlying mechanism for this cryptosystem is a generalization of Fermat's 
# Little Theorem, which says that if p is a prime then for all integers a between 
# 0 and p-1 inclusive, it holds that

#    a^p = a  (mod p)

# (where ^ means exponentiation). For an integer N that is the product of two 
# primes, it similarly holds that there is an exponent m>1 such that

#    a^m = a  (mod N)    for all 0 <= a < N.

# However in this case (i) m is usually not a prime and (ii) it is rather hard to
# determine m from N (but rather easy to determine m from the two primes whose 
# product is N).

# As is evident from e.g. the fact that 2m-1 is an exponent returning a to itself 
# whenever m is such an exponent, there are for every N infinitely many possible 
# choices of m. Suppose m is composite (i.e., not a prime) and the product of two 
# integers k and l . Then one can use the above to encrypt a number a by computing

#    b = a^k  (mod N)

# since the decryption procedure consists of computing

#    a = b^l  (mod N)

# A very useful feature of this cryptosystem is that the information needed to 
# decrypt messages (numbers l and N) is not the same as that needed to encrypt 
# messages (numbers k and N). This means you can make one half of the key 
# public, but keep the other secret, thus allowing anyone to make encrypted 
# messages that only you can read, or conversely produce encrypted messages 
# that anyone can read but which could only have been encrypted by you. The 
# latter can be used to make digital signatures.

# The security of the cryptosystem relies on the fact that it is hard to 
# factorize the number N. Should anyone make a major improvement in integer 
# factorization techniques (e.g. so that factorization and primality checking 
# would be of comparable speed) then RSA would probably be rendered useless, 
# but for the moment it seems to be OK. A piece of warning may however be in 
# order: There are some choices of keys for RSA that are easily broken, even 
# if the number N by itself is hard to factorize. Presumably code libraries 
# that generate RSA cryptos have a lot of built-in checks to avoid outputting 
# one of these inferior sets of keys.

# 2004Sept2 PS Salvatore Sanfilippo has created a Pure-Tcl bignum package 
# (attached to http://wiki.hping.org/108 ). Using this a (naive!) implementation 
# of RSA is rather trivial to do:

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc rsa { c key pq } {

  #puts "RSA: [tostr $c] [tostr $key] [tostr $pq]"

  return [powm $c $key $pq]
}
#-------------------------------------------------------------------------------
proc encrypt {text key pq} {

  set crypted {}

  foreach char [split $text ""] {
    
    lappend crypted [tostr [rsa [fromstr [scan $char %c]] $key $pq]]
  }

  return $crypted
}
#-------------------------------------------------------------------------------
proc decrypt { crypt key pq } {

  set plain ""

  foreach cypher $crypt {

    append plain [format %c [tostr [rsa [fromstr $cypher] $key $pq]]]
  }

  return $plain
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc test_rsa {} {

  source "O/bignum.tcl"
  
  namespace import math::bignum::*

  #package require math::bignum
  #-----------------------------------------------
  
  set P  61
  set Q  53
  set PQ 3233
  set E  17
  set D  2753
  
  # Turn into bignums:
  #
  set pub [fromstr $E]
  set pri [fromstr $D]
  set pq  [fromstr $PQ]

  set text "Salvatore does amaze!"
  
  
  
  #-----------------------------------------------
  puts ""
  puts "Plain  : $text"

  set cypher [encrypt $text $pri $pq]

  puts "Encrypt: $cypher"

  puts ""
  puts "Decrypt: [decrypt $cypher $pub $pq]"  
  puts ""

}
#-------------------------------------------------------------------------------
proc check_ferma {p} {

  # for all integers a between 0 and p-1 inclusive, it holds that
  #    a^p = a  (mod p)

  for {set i 0} {$i < $p} {incr i} {

  }


}
#-------------------------------------------------------------------------------
proc test_ferma {} {

  #  The Prime Numbers less than  20 
  # 
  set primes { 
    2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 
  }

  foreach p $primes {

    set res [check_ferma $p]

    puts "p = $p"

  }

  return
}
#-------------------------------------------------------------------------------
proc MAIN {} {

  puts ""

  test_rsa 

  puts ""
  puts "--------------------------------------------------------"
  puts ""

  test_ferma 

  puts ""
  
  return
}
#-------------------------------------------------------------------------------

MAIN

#-------------------------------------------------------------------------------

# Mind you - this is not how real implementation of RSA would work... Direct 
# encryption of a plain-text with RSA <shudder>. -- Pascal.

# 20041109 Twylite - See RSA in Tcl for a more complete implementation. Tcllib 
# also has a pure Tcl math::bignum package.

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
											  
