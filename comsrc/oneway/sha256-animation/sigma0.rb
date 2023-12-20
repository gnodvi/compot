#!/usr/bin/env ruby
# coding: utf-8

require_relative "sha256lib.rb"

#-------------------------------------------------------------------------------
# -----
# σ0(x)
# -----
# σ0(x) = ROTR(7, x) ^ ROTR(18, x) ^ SHR(3, x)

#-------------------------------------------------------------------------------
# ---------
# Animation
# ---------
#-------------------------------------------------------------------------------
def step1 (x)
  
  system "clear"
  
  puts "x:       #{bits(x)}"
  puts "         #{'-'*32}"
  puts "ROTR 7:  #{bits(x)}"
  puts "ROTR 18: #{bits(x)}"
  puts " SHR 3:  #{bits(x)}"
  puts "         #{'-'*32}"
  puts "σ0(x):"

end

#-------------------------------------------------------------------------------
# ROTR(7, x)
#-------------------------------------------------------------------------------
def step2 (x)
  

  (7+1).times do |i|
    
    system "clear"
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 7:  #{bits(rotr(i, x))}"
    puts "ROTR 18: #{bits(x)}"
    puts " SHR 3:  #{bits(x)}"
    puts "         #{'-'*32}"
    puts "σ0(x):"
    sleep(0.1)
  end

end

#-------------------------------------------------------------------------------
# ROTR(18, x)
#-------------------------------------------------------------------------------
def step3 (x)
  
  (18+1).times do |i|
    
    system "clear"
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 7:  #{bits(rotr(7, x))}"
    puts "ROTR 18: #{bits(rotr(i, x))}"
    puts " SHR 3:  #{bits(x)}"
    puts "         #{'-'*32}"
    puts "σ0(x):"
    sleep(0.1)
  end
  
end

#-------------------------------------------------------------------------------
# SHR(3, x)
#-------------------------------------------------------------------------------

def step4 (x)
  
  (3+1).times do |i|
    
    system "clear"
    puts "x:       #{bits(x)}"
    puts "         #{'-'*32}"
    puts "ROTR 7:  #{bits(rotr(7, x))}"
    puts "ROTR 18: #{bits(rotr(18, x))}"
    puts " SHR 3:  #{bits(shr(i, x))}"
    puts "         #{'-'*32}"
    puts "σ0(x):"
    sleep(0.1)
  end

end

#-------------------------------------------------------------------------------
# ROTR(7, x) ^ ROTR(18, x) ^ SHR(3, x)
#-------------------------------------------------------------------------------
def step5_i_print (x, i)
  
  #  32.downto(1) do |i|
  #system "clear"
  
  puts "x:       #{bits(x)}"
  puts "         #{'-'*32}"
  puts "ROTR 7:  #{bits(rotr(7, x))}"
  puts "ROTR 18: #{bits(rotr(18, x))} XOR"
  puts " SHR 3:  #{bits(shr(3, x))} XOR"
  puts "         #{'-'*32}"
  puts "σ0(x):   #{bits(rotr(7, x) ^ rotr(18, x) ^ shr(3, x))[i-1..-1].rjust(32, " ")}"

  #  sleep(0.1)
  #  end

end

#-------------------------------------------------------------------------------
def step5 (x)
  
  32.downto(1) do |i|
    
    system "clear"
    
    step5_i_print  x, i

    # puts "x:       #{bits(x)}"
    #   puts "         #{'-'*32}"
    #   puts "ROTR 7:  #{bits(rotr(7, x))}"
    #   puts "ROTR 18: #{bits(rotr(18, x))} XOR"
    #   puts " SHR 3:  #{bits(shr(3, x))} XOR"
    #   puts "         #{'-'*32}"
    #   puts "σ0(x):   #{bits(rotr(7, x) ^ rotr(18, x) ^ shr(3, x))[i-1..-1].rjust(32, " ")}"

    sleep(0.1)
  end

end

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

def animation (x)

  step1 x
  sleep(0.1)
  step2 x
  sleep(0.1)
  step3 x
  sleep(0.1)
  step4 x
  sleep(0.1)
  step5 x
  sleep(1)

end

#-------------------------------------------------------------------------------
# -----
# Input
# -----

# default
x = 0b00000000000000000011111111111111 # 0b11101001101101011101101110100101

# if ARGV.size == 1
#   # argument passed

#   x = ARGV[0].to_i(2) if ARGV[0] # binary
#   # check arguments
#   if ARGV[0] && ARGV[0].size > 32
#     puts "We only operate on 32-bit words in SHA-256. Your x is #{ARGV[0].size} bits."; exit
#   end

# end


if ARGV[0] == "anim"
  animation  x
else
  puts ""
  #step5 x  
  step5_i_print  x, 1
  puts ""
end



#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
