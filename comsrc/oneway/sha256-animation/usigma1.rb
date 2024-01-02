#!/usr/bin/env ruby
# coding: utf-8

require_relative "sha256lib.rb"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# -----
# Σ1(x)
# -----
# Σ1(x) = ROTR(6, x) ^ ROTR(11, x) ^ ROTR(25, x)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
def is_CLEAR (is_clear)

  if is_clear then system "clear" else puts "";  puts "" end

end
#-------------------------------------------------------------------------------
def usigma1_animation (is_clear, x, sleep_time)
  
  # ---------
  # Animation
  # ---------
  
  #system "clear"
  is_CLEAR is_clear
  
  puts "x:       #{bits(x)}"
  puts "         #{'-'*32}"
  puts "ROTR 6:  #{bits(x)}"
  puts "ROTR 11: #{bits(x)}"
  puts "ROTR 25: #{bits(x)}"
  puts "         #{'-'*32}"
  puts "Σ1(x):"
  
  sleep (sleep_time)

  # ROTR(6, x)
  (6+1).times do |i|
    
    #system "clear"
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 6:  #{bits(rotr(i, x))}"
    puts "ROTR 11: #{bits(x)}"
    puts "ROTR 25: #{bits(x)}"
    puts "         #{'-'*32}"
    puts "Σ1(x):"
    
    sleep (sleep_time)
  end
  
  sleep (sleep_time)

  # ROTR(11, x)
  (11+1).times do |i|
    
    #system "clear"
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 6:  #{bits(rotr(6, x))}"
    puts "ROTR 11: #{bits(rotr(i, x))}"
    puts "ROTR 25: #{bits(x)}"
    puts "         #{'-'*32}"
    puts "Σ1(x):"
    
    sleep (sleep_time)
  end
  
  sleep (sleep_time)

  # ROTR(25, x)
  (25+1).times do |i|
    
    #system "clear"
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 6:  #{bits(rotr(6, x))}"
    puts "ROTR 11: #{bits(rotr(11, x))}"
    puts "ROTR 25: #{bits(rotr(i, x))}"
    puts "         #{'-'*32}"
    puts "Σ1(x):"
    
    sleep (sleep_time)
  end
  
  sleep (sleep_time)

  # ROTR(6, x) ^ ROTR(11, x) ^ ROTR(25, x)
  32.downto(1) do |i|
    
    #system "clear"
    is_CLEAR is_clear
    
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 6:  #{bits(rotr(6, x))}"
    puts "ROTR 11: #{bits(rotr(11, x))} XOR"
    puts "ROTR 25: #{bits(rotr(25, x))} XOR"
    puts "         #{'-'*32}"
    puts "Σ1(x):   #{bits(rotr(6, x) ^ rotr(11, x) ^ rotr(25, x))[i-1..-1].rjust(32, " ")}"
    
    sleep (sleep_time)
  end
  
  sleep (sleep_time)


end
#-------------------------------------------------------------------------------

# -----
# Input
# -----
# default
x = 0b00000000000000000011111111111111 # 0b01010001000011100101001001111111



# # argument passed
# x = ARGV[0].to_i(2) if ARGV[0] # binary
# # check arguments
# if ARGV[0] && ARGV[0].size > 32
# 	puts "We only operate on 32-bit words in SHA-256. Your x is #{ARGV[0].size} bits."; exit
# end


#  usigma1_animation  true, x, 0.2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

arg0 = ARGV[0]


if arg0 == "anim"
  usigma1_animation  true, x, 0.2
else
  puts ""
  puts "arg0 = #{arg0}"
  puts ""
  usigma1_animation  false, x, 0.0
  puts ""
end


puts ""

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
