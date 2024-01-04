#!/usr/bin/env ruby
# coding: utf-8

require_relative "sha256lib.rb"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# -----
# Σ0(x)
# -----
# Σ0(x) = ROTR(2, x) ^ ROTR(13, x) ^ ROTR(22, x)

#-------------------------------------------------------------------------------
def is_CLEAR (is_clear)

  if is_clear then system "clear" else puts "";  puts "" end

end
#-------------------------------------------------------------------------------
def usigma0_animation (is_clear, x, sleep_time)
  
  # ---------
  # Animation
  # ---------
  is_CLEAR is_clear

  puts "x:       #{bits(x)}"
  puts "         #{'-'*32}"
  puts "ROTR 2:  #{bits(x)}"
  puts "ROTR 13: #{bits(x)}"
  puts "ROTR 22: #{bits(x)}"
  puts "         #{'-'*32}"
  puts "Σ0(x):"

  sleep (sleep_time)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROTR(2, x)
  (2+1).times do |i|
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 2:  #{bits(rotr(i, x))}"
    puts "ROTR 13: #{bits(x)}"
    puts "ROTR 22: #{bits(x)}"
    puts "         #{'-'*32}"
    puts "Σ0(x):"
    
    sleep (sleep_time)
  end

  sleep (sleep_time)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROTR(13, x)
  (13+1).times do |i|
    
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 2:  #{bits(rotr(2, x))}"
    puts "ROTR 13: #{bits(rotr(i, x))}"
    puts "ROTR 22: #{bits(x)}"
    puts "         #{'-'*32}"
    puts "Σ0(x):"
    sleep (sleep_time)
  end
  
  sleep (sleep_time)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROTR(22, x)
  
  (22+1).times do |i|
    
    is_CLEAR is_clear
  
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 2:  #{bits(rotr(2, x))}"
    puts "ROTR 13: #{bits(rotr(13, x))}"
    puts "ROTR 22: #{bits(rotr(i, x))}"
    puts "         #{'-'*32}"
    puts "Σ0(x):"
    sleep (sleep_time)
  end
  
  sleep (sleep_time)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # ROTR(2, x) ^ ROTR(13, x) ^ ROTR(22, x)
  32.downto(1) do |i|
    
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 2:  #{bits(rotr(2, x))}"
    puts "ROTR 13: #{bits(rotr(13, x))} XOR"
    puts "ROTR 22: #{bits(rotr(22, x))} XOR"
    puts "         #{'-'*32}"
    puts "Σ0(x):   #{bits(rotr(2, x) ^ rotr(13, x) ^ rotr(22, x))[i-1..-1].rjust(32, " ")}"
    sleep (sleep_time)

  end
  sleep (sleep_time)

end
#-------------------------------------------------------------------------------

# -----
# Input
# -----
# default
x = 0b00000000000000000011111111111111 # 0b11101001101101011101101110100101

# # argument passed
# x = ARGV[0].to_i(2) if ARGV[0] # binary
# # check arguments
# if ARGV[0] && ARGV[0].size > 32
# 	puts "We only operate on 32-bit words in SHA-256. Your x is #{ARGV[0].size} bits."; exit
# end


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

arg0 = ARGV[0]


if arg0 == "anim"
  usigma0_animation  true, x, 0.2
else
  puts ""
  puts "arg0 = #{arg0}"
  puts ""
  usigma0_animation  false, x, 0.0
  puts ""
end


puts ""

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
