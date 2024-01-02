#!/usr/bin/env ruby

require_relative "sha256lib.rb"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Default
# -------
if !defined? $input
  
  # Command Line Arguments
  $input = ARGV[0] || "abc"    # "string"|"0xaabbcc"|"0b10110100"
  $delay = ARGV[1] || "normal" # [enter|normal|fast|nodelay]

  # Detect input type (binary, hex, or string)
  $type = input_type($input)

  # Read file if file is given
  if $type == "file"
    $input = File.read($input)
  end

  # Convert input to bytes (if possible)
  $bytes = bytes($input, $type)


  # Set message (binary representation of data)
  if $type == "string" || $type == "file" || $type == "hex"
    $message = $bytes.map { |x| x.to_s(2).rjust(8, "0") }.join # convert bytes to binary string
  end
  if $type == "binary"
    $message = $input[2..-1] # input is already in binary, so just trim the leading 0b from the input
  end
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Note about hitting enter to step
  if $delay == "enter"
    puts "Hit enter to step through."
    STDIN.gets
  end

  # Catch Ctrl-C to prevent unsightly errors when terminating early
  Signal.trap("SIGINT") do
    exit
  end
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1. Message
#load "message.rb"

# puts string.bytes.inspect                     # [97, 98, 99]
# puts string.bytes.map{|x| x.to_s(16)}.inspect # ["61", "62", "63"]
# puts string.bytes.map{|x| x.to_s(2)}.inspect  # ["1100001", "1100010", "1100011"]
# puts string.unpack("B*")                      # 011000010110001001100011

# ---------
# Animation
# ---------
system "clear"
puts "-------"
puts "message:"
puts "-------"
delay(:fast)

system "clear"
puts "-------"
puts "message:"
puts "-------"
puts "input:   #{$input} (#{$type})"
delay(:normal)

system "clear"
puts "-------"
puts "message:"
puts "-------"
puts "input:   #{$input} (#{$type})"
puts "bytes:   #{$bytes.inspect}" if defined? $bytes
delay(:normal)

system "clear"
puts "-------"
puts "message:"
puts "-------"
puts "input:   #{$input} (#{$type})"
puts "bytes:   #{$bytes.inspect}" if defined? $bytes
puts "message: #{$message}"
delay(:end)

# Save Final State
$state = <<-FRAME
-------
message:
-------
input:   #{$input} (#{$type})
bytes:   #{$bytes.inspect}
message: #{$message}
FRAME


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 2. Padding
load "padding.rb"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 3. Message Blocks
load "blocks.rb"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# For each block
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

$blocks.each.with_index do |block, i|
  # make variables global so scripts can access them
  $block = block
  $block_number = i

  # 4. Message Schedule
  load "schedule.rb"

  # 5. Compression (Initial Hash Values)
  load "initial.rb" if $block_number == 0 # Only set initial hash values on first run

  # 5. Compression
  load "compression.rb" # Use hash values from previous compression otherwise
end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 6. Final Hash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

load "final.rb"

puts ""
puts ""

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#input:   abc (string)
#bytes:   #<Enumerator: "abc":bytes>
#message: 011000010110001001100011

# ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad


#SHA-256 : ./sha256.rb  'Hello, World'  fast
#03675ac53ff9cd1535ccc7dfcdfa2c458c5218371f418dc136f2d19ac1fbe8a5

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

