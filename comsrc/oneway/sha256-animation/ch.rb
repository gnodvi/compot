#!/usr/bin/env ruby
# -*-   mode: ruby  ; coding: utf-8  -*- ---------------------------------------


require_relative "sha256lib.rb"

#-------------------------------------------------------------------------------
# ------
# Choice
# ------
# Ch(x, y, z) = (x & y) ^ (~x & z)
#
# For each x bit:
#   * If x is 1 choose y
#   * If x is 0 choose z

#-------------------------------------------------------------------------------
def ch_bits (x, y, z)

  return bits( (x & y) ^ (~x & z) )
  
end
#-------------------------------------------------------------------------------
# Animation
#-------------------------------------------------------------------------------
def ch_animation (is_clear, x, y, z, sleep_time)
  
  ret = ch_bits x, y, z # сначала посчитали реузльтат

  
  32.downto(1) do |i|
    
    if is_clear
      system "clear"
    end

    puts "▼".rjust(i+3, " ")

    puts "x: #{bits(x)}" #{bits(x)[i-1]}
    puts "y: #{bits(y)} #{bits(x)[i-1] == '1' ? '◄' : ''}"
    puts "z: #{bits(z)} #{bits(x)[i-1] == '1' ? '' : '◄'}"
    puts "   #{'-'*32}"

    #puts bits( (x & y) ^ (~x & z) ) [i-1..-1].rjust(35, " ")
    puts ret [i-1..-1].rjust(35, " ") # а теперь результат анимируем

    #sleep (0.1)
    sleep (sleep_time)
  end

end
#-------------------------------------------------------------------------------
def ch_onlyprint (x, y, z)
  

  puts "x: #{bits(x)} " 
  puts "y: #{bits(y)} "
  puts "z: #{bits(z)} "
  puts "   #{'-'*32}"

  ret = ch_bits x, y, z
  
  puts "   #{ret}"


end
#-------------------------------------------------------------------------------
def test (a1="", a2="", a3="", a4="")

  puts "test ............... "
  
  puts ""

end
#-------------------------------------------------------------------------------

#puts "ARGV.size = #{ARGV.size}"

  
#   #puts ""
#   #puts "arguments: #{ARGV[0]} #{ARGV[1]} #{ARGV[2]} #{ARGV[3]} #{ARGV[4]} "
#   #puts ""
  
#   #send ARGV[0], ARGV[1], ARGV[2]


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input
# -----
# defaults

x = 0b00000000111111110000000011111111 # 0x428a2f98
y = 0b00000000000000001111111111111111 # 0x71374491
z = 0b11111111111111110000000000000000 # 0xb5c0fbcf

# arguments passed

if ARGV.size == 3
  x = ARGV[0].to_i(2) # переводим строку битовое целое
  y = ARGV[1].to_i(2)
  z = ARGV[2].to_i(2)
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

arg0 = ARGV[0]

if arg0 == "anim"
  ch_animation  true,  x, y, z, 1.0
else
  puts ""
  puts "arg0 = #{arg0}"
  puts ""
  ch_onlyprint x, y, z
  puts ""
end


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
