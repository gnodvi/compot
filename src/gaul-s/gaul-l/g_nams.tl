# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

#-------------------------------------------------------------------------------

source "./a-comm.tl"

source "g_0000.tl"

# загружаем библиотеку и вызываем инициализирующую процедуру
# 
load T/tclgaul.so gaul

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc generation {name gen} {
    puts "\nGeneration $gen\n"
    puts [$name list]
}

proc evaluate {name entity} {

    puts "Evaluate: $entity"
    return $entity
}

proc seed {name entity} {
    global a
    incr a
    puts "Seed: $a"
    return $a
}

proc mutate {name entity} {
    puts "Mutate: $entity"
    return $entity
}

proc crossover {name entity1 entity2} {
    puts "Crossover: $entity1 & $entity2"
    return [list $entity1 $entity2]
}

proc destroy {name entity} {
    puts "Destroy: $entity"
}
#-------------------------------------------------------------------------------

set srand_init [seedrand_from_argv] 

set a 0

gaul create pop 10 \
    -generation_hook generation \
    -evaluate evaluate \
    -seed seed \
    -mutate mutate \
    -crossover crossover \
    -select_one RANDOM \
    -select_two AGGRESSIVE \
    -destroy destroy 

# 
# 
gaulgena  -seedrand $srand_init ;# переустановим random_seed


pop params -scheme darwin -elitism parents \
           -crossover 0.900000 -mutation 0.100000 -migration 0.100000

pop seed
pop evolve 10

puts ""
puts "---------------------------------------------------------"
puts ""
puts "Params: [pop params]"
puts ""
puts [pop rank]
puts ""
puts "---------------------------------------------------------"
puts ""

pop destroy

#-------------------------------------------------------------------------------
