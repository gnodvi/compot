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
def ch_print_i (i,  x, y, z)
  
  ret = ch_bits x, y, z # сначала посчитали реузльтат ? сразу
  # а где же работа со списком?

  
  puts "▼".rjust(i+3, " ")
  
  puts "x: #{bits(x)}" 
  puts "y: #{bits(y)} #{bits(x)[i-1] == '1' ? '◄' : ''}"
  puts "z: #{bits(z)} #{bits(x)[i-1] == '1' ? '' : '◄'}"
  puts "   #{'-'*32}"
  
  puts ret [i-1..-1].rjust(35, " ") # а теперь результат анимируем
  

end
#-------------------------------------------------------------------------------
def ch_animation (is_clear, x, y, z, sleep_time)
  
  ret = ch_bits x, y, z # сначала посчитали реузльтат

  
  32.downto(1) do |i|
    
    if is_clear
      system "clear"
    end

    ch_print_i  i,  x, y, z

    sleep (sleep_time)
  end

end
#-------------------------------------------------------------------------------
def ch_onlyprint (x, y, z)
  

  ch_print_i  1,  x, y, z

end
#-------------------------------------------------------------------------------
def test (a1="", a2="", a3="", a4="")

  puts "test ............... "
  
  puts ""

end
#-------------------------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Input (32 bits ??)
# -----
# defaults

# arguments passed

x = dict_parse ARGV, "-x",  "00000000111111110000000011111111"
y = dict_parse ARGV, "-y",  "00000000000000001111111111111111"
z = dict_parse ARGV, "-z",  "11111111111111110000000000000000"

puts ""
puts "x = #{x}"
puts "y = #{y}"
puts "z = #{z}"

x = x.to_i(2)  # переводим строку битовое целое
y = y.to_i(2)
z = z.to_i(2)

puts ""
puts "x = #{x}"
puts "y = #{y}"
puts "z = #{z}"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

main = dict_parse ARGV, "-main",  "only"
time = dict_parse ARGV, "-time",  "1.0"
flag = dict_parse ARGV, "-flag",  "true"

flag = if flag == "true" then true else false end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if main == "anim"
  ch_animation  flag,  x, y, z, time.to_f
else
  puts ""
  ch_onlyprint x, y, z
end

puts ""

#-------------------------------------------------------------------------------
# ch.rb -main anim -flag false -time 0.1

#-------------------------------------------------------------------------------
