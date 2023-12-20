#!/usr/bin/env ruby

#-------------------------------------------------------------------------------
# Shift Right
#-------------------------------------------------------------------------------
def rotr (n, x)
  
  mask  = 2**32 - 1
  
  right = (x >> n) & mask
  left  = (x << 32-n) & mask
  
  result = right | left
  
  return result
end

#-------------------------------------------------------------------------------
# Animation
#-------------------------------------------------------------------------------
def rotr_animation (x, n)
  
  s = n.to_s.ljust(2, " ")

  n.times do |i|
    system "clear"
    i += 1

    puts "      x: #{"%032b" % x}"
    puts "ROTR #{s}: #{"%032b" % rotr(i, x)}"

    sleep 0.10
  end

end

#-------------------------------------------------------------------------------
def rotr_onlyprint (x, n)
  
  s = n.to_s.ljust(2, " ")

  #n.times do |i|
  #  system "clear"
  #  i += 1

  i = n

  puts "      x: #{"%032b" % x}"
  puts "ROTR #{s}: #{"%032b" % rotr(i, x)}"

  #  sleep 0.10
  #end

end

#-------------------------------------------------------------------------------

# Input
# defaults
x = 0b11111111000000001111111100000000 #0b11101001101101011101101110100101
n = 32

if ARGV.size == 2
  # arguments passed
  
  x = ARGV[0].to_i(2) if ARGV[0] # binary
  n = ARGV[1].to_i    if ARGV[1] # integer

  # check arguments
  if ARGV[0] && ARGV[0].size > 32
    puts "We only operate on 32-bit words in SHA-256. Your x is #{ARGV[0].size} bits."; exit
  end
  
end


if ARGV[0] == "anim"
  rotr_animation  x, n
else
  puts ""
  rotr_onlyprint  x, n
  puts ""
end



#rotr_animation x, n

#sleep 0.5

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

