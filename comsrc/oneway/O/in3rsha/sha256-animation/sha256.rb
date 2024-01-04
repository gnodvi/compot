#!/usr/bin/env ruby

require_relative "sha256lib.rb"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#-------------------------------------------------------------------------------
def prepare_default ()
  

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

end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#
#-------------------------------------------------------------------------------
def is_CLEAR (is_clear)

  if is_clear then system "clear" else puts "";  puts "" end

end
#-------------------------------------------------------------------------------
def run_message (is_clear)
  
  # 1. Message
  #load "message.rb"

  # puts string.bytes.inspect                     # [97, 98, 99]
  # puts string.bytes.map{|x| x.to_s(16)}.inspect # ["61", "62", "63"]
  # puts string.bytes.map{|x| x.to_s(2)}.inspect  # ["1100001", "1100010", "1100011"]
  # puts string.unpack("B*")                      # 011000010110001001100011

  # ---------
  # Animation
  # ---------
  #system "clear"
  is_CLEAR is_clear
  
  puts "-------"
  puts "message:"
  puts "-------"

  delay (:fast)

  #system "clear"
  is_CLEAR is_clear
  
  puts "-------"
  puts "message:"
  puts "-------"
  puts "input:   #{$input} (#{$type})"

  delay (:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts "-------"
  puts "message:"
  puts "-------"
  puts "input:   #{$input} (#{$type})"
  puts "bytes:   #{$bytes.inspect}" if defined? $bytes

  delay (:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts "-------"
  puts "message:"
  puts "-------"
  puts "input:   #{$input} (#{$type})"
  puts "bytes:   #{$bytes.inspect}" if defined? $bytes
  puts "message: #{$message}"

  delay (:end)

  # Save Final State
  $state = <<-FRAME
-------
message:
-------
input:   #{$input} (#{$type})
bytes:   #{$bytes.inspect}
message: #{$message}
FRAME

end

#-------------------------------------------------------------------------------
def run_padding (is_clear)
  
  # 2. Padding
  # load "padding.rb"

  # -------
  # Padding
  # -------

  # pad the message so that it's a multiple of 512 bits
  $l = $message.size      # length of message
  $k = (448 - $l - 1) % 512 # pad with zeros up to 448 bits (64 short of 512 bits)

  #        message                  padding            size M
  # -------------------------------------------------------------
  # |         M         |1|...00000000000000000000|...0000001100|
  # -------------------------------------------------------------
  #  <----------------- 448 bits ----------------> <- 64 bits ->

  $padded = $message + "1" + ("0" * $k) + $l.to_s(2).rjust(64, "0")

  # ---------
  # Animation
  # ---------
  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding:"
  puts "-------"
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{$message.size} bits)"
  puts "-------"
  puts "message: #{$message}"
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size} bits)"
  puts "-------"
  puts "message: #{$message}1"
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size} bits -> #{($message + "1").size + $k} bits)"
  puts "-------"
  print "message: #{$message}1"
  
  if $delay == "enter" || $delay == "nodelay" # show all padded zeros in one go if we're stepping through with keyboard
    puts "0" * $k
  else
    $k.times do |i|
      print "0"
      sleep 0.005
    end
  end
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size + $k} bits)"
  puts "-------"
  print "message: #{$message}1#{"0" * $k}"
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{$padded.size} bits)"
  puts "-------"
  puts "message: #{$padded}"
  
  delay(:end)

  # Save Final State
  $state = <<-FRAME
#{$state}
-------
padding: (#{$padded.size} bits)
-------
message: #{$padded}
FRAME

end

#-------------------------------------------------------------------------------
def run_blocks (is_clear)
  
  # 3. Message Blocks
  #load "blocks.rb"

  # -------
  # Default
  # -------
  if !defined? $input
    # default
    $input = "abc"
    $message = $input.unpack("B*")[0]
    # argument passed
    $message = ARGV[0] if ARGV[0] # accept binary message string
    
    # calculate padded message
    $padded = padding($message)
  end

  # --------------
  # Message Blocks
  # --------------
  $blocks = split($padded, 512)

  # ---------
  # Animation
  # ---------
  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "--------------"
  puts "message blocks:"
  puts "--------------"
  delay(:normal)

  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "--------------"
  puts "message blocks:"
  puts "--------------"
  
  $blocks.each.with_index do |block, i|
    puts "#{i}: #{block}"
    delay(:normal)
  end
  delay(:slow)

  # Save Final State
  contents = "" # contruct string with each block so we can use it inside the final frame
  $blocks.each.with_index do |block, i|
    contents << "#{i}: #{block}"
    contents << "\n" if i < $blocks.size - 1 # do not add extra new line after last block
  end

  $state = <<-FRAME
#{$state}
--------------
message blocks:
--------------
#{contents}
FRAME

end
#-------------------------------------------------------------------------------
def run_final (is_clear)

  puts "run_final ....................... 01 "
  
  # 6. Final Hash
  #load "final.rb"

  # -------
  # Default
  # -------
  if !defined? $input

    puts "run_final ....................... 02 "

    # default
    $input = "abc"
    
    # argument passed
    #$input = ARGV[0] if ARGV[0] # only accept strings for now
    
    $message = $input.unpack("B*")[0] # 011000010110001001100011
    $padded = padding($message)
    $blocks = split($padded, 512)
    
    # Set initial hash state using initial hash values
    $hash = IV

    # For each message block
    $blocks.each do |block|
      # Prepare 64 word message schedule
      schedule = calculate_schedule(block)

      # Remember starting hash values
      initial = $hash.clone

      # Apply compression function to update hash values
      $hash = compression(initial, schedule, constants = K)
    end
  end

  puts "run_final ....................... 03 "

  # Start
  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "----------------"
  puts "final hash value: (H#{$blocks.size})"
  puts "----------------"
  registers = ("a".."h").to_a
  8.times do |i|
    puts "#{registers[i]} = #{bits($hash[i])}"
  end
  delay(:slowest)

  # Frame - Hexadecimal
  #system "clear"
  is_CLEAR is_clear
  
  puts $state + "\n" if defined? $state
  puts "----------------"
  puts "final hash value: (H#{$blocks.size})"
  puts "----------------"
  8.times do |i|
    puts "#{registers[i]} = #{bits($hash[i])} = #{hex($hash[i])}"
  end
  
  delay (:slowest)

  # Frame - Concatenate
  $digest = ""
  
  8.times do |i|
    $digest << hex($hash[i])
    
    #system "clear"
    is_CLEAR is_clear
    
    puts $state + "\n" if defined? $state
    puts "----------------"
    puts "final hash value: (H#{$blocks.size})"
    puts "----------------"
    
    8.times do |j|
      puts "#{registers[j]} = #{bits($hash[j])} = #{hex($hash[j])}"
    end
    
    puts
    puts "#{$digest}"
    delay (:fastest)
  end

  delay (:end)
  delay (:end) # extra delay for the absolute final frame

end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
def calc_sha256 (is_clear)
  

  prepare_default
  

  run_message is_clear

  run_padding is_clear

  run_blocks  is_clear


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # For each block

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

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  run_final is_clear

end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

arg0 = ARGV[0]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if arg0 == "anim"
  #usigma0_animation  true, x, 0.2
  calc_sha256 true

elsif arg0 == "final"
  run_final true

elsif arg0 == "test01"

  puts ""
  puts sha256 ("abc")
  #  Digest::SHA256.hexdigest("abc")
  puts ""

  for
    i in 0..1400 do
      str = "abc" + "#{i}"
      #puts "#{str} : #{sha256 (str)}"
      sha = sha256 (str)
      if sha[0..1] == "00" then
        printf("%7s : %s \n",  str, sha)
      end
  end
  
else
  puts ""
  puts "arg0 = #{arg0}"
  puts ""
  #usigma0_animation  false, x, 0.0
  calc_sha256 false

end


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

