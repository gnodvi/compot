#!/usr/bin/env ruby
# coding: utf-8

require_relative "sha256lib.rb"

load "schedule.rb"



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#-------------------------------------------------------------------------------
def p_default ()
  

  # Default
  # -------
  if !defined? $input
    
    # Command Line Arguments
    
    #$input = ARGV[0] || "abc"    # "string"|"0xaabbcc"|"0b10110100"
    #$delay = ARGV[1] || "normal" # [enter|normal|fast|nodelay]
    
    $input = dict_parse ARGV, "-input",  "abc"
    $delay = dict_parse ARGV, "-delay",  "nodelay" #"fast" ##"normal"


    # Detect input type (binary, hex, or string)
    $type = input_type ($input)

    # Read file if file is given
    if $type == "file"
      $input = File.read ($input)
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
      puts ""
      puts "Hit enter to step through."
      STDIN.gets
    end

    # Catch Ctrl-C to prevent unsightly errors when terminating early
    Signal.trap("SIGINT") do
      exit
    end
  end

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  puts ""
  puts "~~~~~~~~~~~~~ p_default ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
  puts "delay   = #{$delay}"
  #puts "input   = #{$input}"
  #puts "type    = #{$type}"
  puts "input   = #{$input} (#{$type})"
  #puts "bytes   = #{$bytes}"
  puts "bytes   = #{$bytes.inspect}" if defined? $bytes
  puts "message = #{$message}"
  #puts ""


end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#
#-------------------------------------------------------------------------------
def is_CLEAR (is_clear)

  if is_clear then system "clear" else puts "";  puts "" end

end
#-------------------------------------------------------------------------------
#def r_message (is_clear)
def r_message ()
  
  # 1. Message
  #load "message.rb"

  # puts string.bytes.inspect                     # [97, 98, 99]
  # puts string.bytes.map{|x| x.to_s(16)}.inspect # ["61", "62", "63"]
  # puts string.bytes.map{|x| x.to_s(2)}.inspect  # ["1100001", "1100010", "1100011"]
  # puts string.unpack("B*")                      # 011000010110001001100011

  if !defined? $input
    p_default 
    flag     = dict_parse ARGV, "-flag",  "true"
    is_clear = if flag == "true" then true else false end

  end
  
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
def r_padding ()
  
  # 2. Padding
  # load "padding.rb"

  if !defined? $input
    p_default
    
    #flag     = dict_parse ARGV, "-flag",  "true"
    #$is_clear = if flag == "true" then true else false end
  end

  if !defined? $is_clear
    flag     = dict_parse ARGV, "-flag",  "true"
    $is_clear = if flag == "true" then true else false end
  end
  
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
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding:"
  puts "-------"
  delay(:normal)

  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{$message.size} bits)"
  puts "-------"
  puts "message: #{$message}"
  delay(:normal)

  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size} bits)"
  puts "-------"
  puts "message: #{$message}1"
  delay(:normal)

  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size} bits -> #{($message + "1").size + $k} bits)"
  puts "-------"
  print "message: #{$message}1"
  
  if $delay == "enter" || $delay == "nodelay"
    # show all padded zeros in one go if we're stepping through with keyboard
    puts "0" * $k
  else
    $k.times do |i|
      print "0"
      sleep 0.005
    end
  end
  delay(:normal)

  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "-------"
  puts "padding: (#{($message + "1").size + $k} bits)"
  puts "-------"
  print "message: #{$message}1#{"0" * $k}"
  delay(:normal)


  
  #system "clear"
  is_CLEAR $is_clear
  
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
def r_blocks ()
  
  # 3. Message Blocks
  #load "blocks.rb"


  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Default
  # -------
  if !defined? $input
    # default
    $input = "abc"
    $message = $input.unpack("B*")[0]
    
    ### argument passed
    ##$message = ARGV[0] if ARGV[0] # accept binary message string
    
    # calculate padded message
    $padded = padding($message)
  end

  if !defined? $is_clear
    flag     = dict_parse ARGV, "-flag",  "true"
    $is_clear = if flag == "true" then true else false end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  # --------------
  # Message Blocks
  # --------------
  $blocks = split( $padded, 512)

  # ---------
  # Animation
  # ---------
  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "--------------"
  puts "message blocks:"
  puts "--------------"
  delay(:normal)

  #system "clear"
  is_CLEAR $is_clear
  
  puts $state + "\n" if defined? $state
  puts "--------------"
  puts "message blocks:"
  puts "--------------"


  
  $blocks.each.with_index do |block, i|
    
    puts "#{i}: #{block}"
    delay (:normal)
  end
  
  delay(:slow)

  
  # Save Final State - TODO - почему в предыдущем цикле было бы это не сделать?
  # 
  contents = "" # contruct string with each block so we can use it inside the final frame
  
  $blocks.each.with_index do |block, i|
    
    contents << "#{i}: #{block}"
    contents << "\n" if i < $blocks.size - 1 # do not add extra new line after last block
  end

  # а зачем нам этот финальный фрейм сохранять?
  # 
  
  $state = <<-FRAME
#{$state}
--------------
message blocks:
--------------
#{contents}
FRAME

  puts $state

end
#-------------------------------------------------------------------------------
#def run_final (is_clear, *args)
def r_final ()

  
  flag     = dict_parse ARGV, "-flag",  "true"
  flag     = if flag == "true" then true else false end
  is_clear = flag

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
def find_00 ()

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

  
end
#-------------------------------------------------------------------------------
def sha_256 ()
  

  #main = dict_parse ARGV, "-main",  "final"
  #time = dict_parse ARGV, "-time",  "1.0"
  flag = dict_parse ARGV, "-flag",  "true"

  $is_clear = if flag == "true" then true else false end


  p_default
  

  #r_message ##is_clear

  r_padding   ##$is_clear

  r_blocks  ##$is_clear


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # For each block
  
  $blocks.each.with_index do |block, i|
    
    # make variables global so scripts can access them
    $block = block
    $block_number = i

    # 4. Message Schedule
    #load "schedule.rb"
    r_schedule 

    # 5. Compression (Initial Hash Values)
    load "initial.rb" if $block_number == 0 # Only set initial hash values on first run

    # 5. Compression
    load "compression.rb" # Use hash values from previous compression otherwise
  end

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  r_final ##is_clear

end
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#main = ARGV[0]

# time = dict_parse ARGV, "-time",  "1.0"
# flag = dict_parse ARGV, "-flag",  "true"

# flag = if flag == "true" then true else false end

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

main = dict_parse ARGV, "-main",  "sha_256"

send main

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# if    main == "sha_256"  then   send main  #calc_sha256 #true
# elsif main == "r_final"  then   send main  ##run_final   ##*ARGV #"-test" "test"
# elsif main == "find_00"  then   send main  #find_00 

# else
#   puts ""
#   #puts "arg0 = #{arg0}"
#   puts "????????????????"
#   #puts ""
#   #calc_sha256 false

# end


puts ""
#puts ""

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

