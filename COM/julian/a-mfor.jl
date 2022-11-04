
# #-------------------------------------------------------------------------------
# #  ARR2D_    ARR2D_    
# #
# #-------------------------------------------------------------------------------
# #-------------------------------------------------------------------------------

# set ::OLD_ARR 0 ;# 1 надо бы сравнить разные методы? 


# record define ARR2D_ {
  
#   ii jj
#   array
# } 

type ARR2D_ 
  
  ii
  jj
  array

end


# # ;-------------------------------------------------------------------------------
function arr2d_make( ii, jj)  

  #   set size [expr {$ii * $jj}]
  size = ii * jj
  
  #   #set array [make_array $size "@"]
  #   #
  #   set array [make_list_ $size "@"]
  array = make_list_( size, "@")
  
  #   # "двумерный" список заменить на реально вложенный, по глобальному
  #   # имени !!
  #   # структуру заменить на DICT !!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  #   if {$::OLD_ARR} {
  
  #     set a [ARR2D_ \#auto] 
  #     $a.ii    = $ii 
  #     $a.jj    = $jj 
  #     $a.array = $array
  
  #   } else {
  
  #     set a [g_get_unicum_name] ;# получили глобальное имя (ссылку)
  #     set ${a}(ii)    $ii
  #     set ${a}(jj)    $jj
  #     set ${a}(array) $array  
  #   }

  a = ARR2D_(ii, jj, array)
  
  #   return $a
  return( a)
  
end
# # ;-------------------------------------------------------------------------------
# proc arr2d_ii {a} { 

#   if {$::OLD_ARR} {
    
#     return [$a.ii]    
#   } else {
    
#     return [set ${a}(ii)]   
#   }

# }
# # ;-------------------------------------------------------------------------------
# proc arr2d_jj {a} { 

#   if {$::OLD_ARR} {
    
#     return [$a.jj]   
#   } else {
    
#     return [set ${a}(jj)]   
#   }

# }
# # ;-------------------------------------------------------------------------------
function arr2d_get( a, i, j) 

  #   set ii    [arr2d_ii $a]
  #   set jj    [arr2d_jj $a]
  
  #   set ind  [expr {$i * $jj + $j}] ;# ???!!!! тоже дает задержку ???!!! немного
  ind = i * a.jj + j
 
  #   if {$::OLD_ARR} {
  
  #     set arr_name [$a.array] 
  #   } else {
  
  #     set arr_name [set ${a}(array)]
  #   }
  
  #   set arr [set $arr_name]  

  return( a.array[ind+1])
  #   return [lindex $arr $ind]    
end
# # ;-------------------------------------------------------------------------------
function arr2d_set( a, i, j, val)


  #   set ii    [arr2d_ii $a]
  #   set jj    [arr2d_jj $a]
  jj = a.jj
  
  #   set ind [expr {$i * $jj + $j}]
  ind = i * jj + j
  #print( "arr2d_get: i= $i j= $j jj= $jj  ind= $ind \n") 
  #print( "arr2d_set: ind= $ind \n") 
  
  #   if {$::OLD_ARR} {
  
  #     set arr_name [$a.array] 
  #   } else {
  
  #     set arr_name [set ${a}(array)]
  arr_name = a.array
  #   }
  
  #   lset $arr_name $ind $val  ;# сильный тормоз !!
  #arr_name[ind+1] = val
  a.array[ind+1] = val

end 
# # ;-------------------------------------------------------------------------------
function arr2d_print( a)  

  #   set ii    [arr2d_ii $a]
  #   set jj    [arr2d_jj $a]

  ii = a.ii
  jj = a.jj
  
  println( "ii    = $ii")
  println( "jj    = $jj")
  println( "array = ")
  
  #   for {set i 0} {$i < $ii} {incr i} {
  for i = 0 : ii-1
  
  #   puts -nonewline "      "
  print( "      ")
    
  #   for {set j 0} {$j < $jj} {incr j} {
  for j = 0 : jj-1
  
    val = arr2d_get( a,  i, j)
    #@printf( "i= %d j= %d val = %s \n", i, j, val)

    #println( "i= $i  j= $j  val= $val")

    #     puts -nonewline "$val "
    print( "$val ")
    #@printf( "%3d ", val)
    #   }
  end
  #     puts ""
  println( "")  
  #   }
    
  end
  
  #   return

end
# #-------------------------------------------------------------------------------
function ARR2_test( )  

  #   set a [arr2d_make 10 20]
  a = arr2d_make( 10, 20)
  
  #   set ii    [arr2d_ii $a]
  #   set jj    [arr2d_jj $a]
  ii = a.ii
  jj = a.jj

  #@printf( "ii = %d  jj = %d \n", ii, jj)
  
  #   for {set i 0} {$i < $ii} {incr i} {
  #   for {set j 0} {$j < $jj} {incr j} {

  for i = 0 : ii-1
  for j = 0 : jj-1

    val = "$i$j"
    
    #println( "i= $i  j= $j  val= $i$j")
    #println( "i= $i  j= $j  val= $val")

     #@printf( "i= %d j= %d \n", i, j)
    #   arr2d_set  $a $i $j "$i$j"  --  это ж не умножение !!!!!
    
    #arr2d_set( a, i, j,  i * j)     
    arr2d_set( a, i, j,  val)

    #print( a)

    #val =  arr2d_get( a,  i, j)
    #println( "i= $i  j= $j  val= $val")
    
    #   }}
  end
  end
  
  #@printf( "\n")
  println( "")
  
  #print( a)
  
  arr2d_print( a)
  
  println( "")
  
end
# # ;;;=============================================================================
# #
# # ;;;=============================================================================
# #-------------------------------------------------------------------------------
# proc ijk_array_make {num {val "@"}} {

#   set g_name [g_get_unicum_name] ;# получили глобальное имя (ссылку)

#   for {set i 0} {$i < $num} {incr i} {

#     lappend $g_name $val
#   }

#   return $g_name ;# возвращаем имя списка (глобальную ссылку)
# }
# # ;;;-----------------------------------------------------------------------------
function ijk_array_set( ijk, value)

  #   #USE_REFS
  #   #upvar $ijk_REF ijk 
  #   upvar ${&ijk} ijk 
  
  #   dotimes index [llength $ijk] {
  
  #     #     (setf (aref ijk index) value)
  #     lset ijk $index  $value
  #   }

  fill!( ijk, value)
  
end
# # ;;;-----------------------------------------------------------------------------
function ijk_array_print( name, ijk)

  #   puts -nonewline "$name  "
  print( "$name  ")
  # @printf( "nv(g) = %s \n", nv( g))

  #print( "\n\n")
  #print( "ijk ==== $ijk \n")

  #size = 3
  #size = size(ijk) # ERROR: LoadError: UndefVarError: size not defined ?????????????
  #siz = size(ijk)
  siz = size(ijk, 1)
    
  #@printf( "size = %d \n\n", size)
  #print( "size = $siz \n\n")

  #exit()
  
  #   dotimes index [llength $ijk] {
  #for index = 1:size  #ERROR: LoadError: MethodError: no method matching colon(::Int32, ::Base.#size)
  #for index = 1:3
  for index = 1:siz
    #     puts -nonewline "[lindex $ijk $index] "
    #@printf( "%d ", ijk[index] ) #ERROR: LoadError: MethodError: no method matching isfinite(::String)
    @printf( "%s ", ijk[index] ) 
    end
  #   }
  
  #   puts ""
  print( "\n")

  #exit()
  

end
# # ;;;-----------------------------------------------------------------------------
# proc ijk_array_incr {&ijk cur} {

#   #USE_REFS
#   #upvar $ijk_REF ijk 
#   upvar ${&ijk} ijk 

#   # dotimes index [llength $ijk] {  
#   #     (setf (aref ijk index) value)
#   #lset ijk $index  $value
#   #}

#   lset ijk $cur [expr {[lindex $ijk $cur] + 1}]
  
# }
# # ;;;-----------------------------------------------------------------------------
# proc ijk_get {ijk_REF i} {

#   upvar $ijk_REF ijk 

  
#   return [lindex $ijk $i]

# }
# # ;;;=============================================================================


# #record define MF {

# #}

# #     IJK
# #     dim 
# #     ijk_cur
# #     index

# package require TclOO;  

# oo::class create MF {

#   SET_GET first 1 ;# флажок для начала цикла
#   SET_GET dim_1
#   SET_GET   IJK
#   SET_GET   ijk_cur
# }

type MF

  first
#  dim_1
  dim
  
  IJK
  ijk_cur
  
end

# # ;-------------------------------------------------------------------------------
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_init_2 {mf} {
function MFOR_init( mf)


  mf.first = 1
  
  #   #$mf.index  = -1 ;# чтобы первым был нуль
  
  #   #ijk_array_set [$mf vget -ijk_cur] 0
  #   #ijk_array_set ::ijk_cur 0
  #   #$mf ijk_cur__SET 0 ;# это простой индекс !!
  
end
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_create_2 {dim ijk_cur IJK} {
function MFOR_create( dim, ijk_cur, IJK)

  #   # (let* (
  #   #   mf
  #   #   )
  
  #   #   ;; создадим новую пструктуру
  #   #   (setf mf (make-MF))
  #   #set mf [MF \#auto]

  #   #set mf [dict create]
  #   #set mf [g_get_unicum_name] ;# получили глобальное имя (ссылку)

  #   set mf [MF new]
  mf = MF( 1, 0, 0, 0)
  
  #   #   ;; занесем в нее готовые массивы

  #   #$mf.dim     =  $dim
  #   #dict set $mf "dim" $dim 
  #   #set ::dim    $dim

  #   #set ::dim_1  [expr {$dim - 1}] ;# особо не влияет такое "ускорение"
  #   #dict set $mf "dim_1" $::dim_1 
  #   #dict set $mf "dim_1" [expr {$dim - 1}] ;# интересно, что оно делает?

  #   $mf dim_1__SET [expr {$dim - 1}]
  #mf.dim_1 = dim - 1
  
  #mf.dim = dim - 1 # ??????????????????????
  mf.dim = dim

  #   #$mf.IJK     =  $IJK
  #   #set ::IJK    $IJK
  
  #   $mf IJK__SET $IJK
  mf.IJK = IJK

  #   $mf ijk_cur__SET $ijk_cur
  mf.ijk_cur = ijk_cur
  
  #   #set ::ijk_cur    $ijk_cur
  
  #   dotimes index [llength $ijk_cur] {  
  #     set ::ijk($index) [lindex $ijk_cur $index]
  #   }


  #   #   ;(MFOR_init mf)
  
  return( mf)

end
# # ;;;-----------------------------------------------------------------------------
# #proc MFOR_r {cur &ijk_cur IJK} {}
# #proc MFOR_r {cur &ijk_cur IJK} {}
# proc MFOR_r_2 {mf cur ijk_cur IJK} {

function  MFOR_r( mf, cur, ijk_cur, IJK)


  #@printf( "...... MFOR_r: cur=%s \n", cur)

  #   set IJK [$mf IJK__GET]
  
  #   #USE_REFS ;# может этот перебор переменных тормозит ?!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #   # 
  #   #upvar $ijk_cur_REF ijk_cur ;# здесь тчоно в 2.5 раза тормозит !!
  #   #upvar ${&ijk_cur} ijk_cur 
  
  #   # просто увеличиваем значение текущего индекса


  #   #lset ijk_cur $cur [expr {[lindex [set ${ijk_cur}] $cur] + 1}]
  
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  #   lset $ijk_cur $cur [expr {[lindex [set $ijk_cur] $cur] + 1}]
  ijk_cur[cur] = ijk_cur[cur] +  1
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

  #   # 
  #   #ijk_array_incr ijk_cur $cur ;# уже приилчно  увеличиваем !! 
  #   #                              может upvar долго так работает ??

  #   #incr ::ijk($cur) ;# сука ! увеличивает !


  #@printf( "ijk_cur = %s  cur= %s  ijk_cur[cur] = %s   IJK[cur] = %s  \n",
  #         ijk_cur, cur, ijk_cur[cur],  IJK[cur])
  
  #   if {! ([lindex [set $ijk_cur] $cur] == [lindex $IJK $cur])} {
  if (! (ijk_cur[cur] == IJK[cur]) )
  
  #     #if {! ([ijk_get ijk_cur $cur] == [lindex $IJK $cur])} { }  ;# тоже увеличивает!

    #     return 1 ;#       T ; просто уходим, если нет еще границы
    #@printf( ".. 01 \n")
    return true

  else 

    #@printf( ".. 02 \n")

    #     #     ;; дошли до максимума, значит надо к след. индексу переходить
  
    #     if {$cur == 0} { ;# однако, если это был последний (левый) индекс,
    #if (cur == 0)
    if (cur == 1)
      
      # return 0 ;# NIL       ; то конец
      return false
      
    else 
      #       #       (setf (aref ijk_cur cur) 0) ; обнуляем текущий индекс
      #       #lset ijk_cur $cur   0 ;# обнуляем текущий индекс

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
      #       lset $ijk_cur $cur   0 ;# обнуляем текущий индекс
      ijk_cur[cur] = 0
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
      
      #       #set ::ijk($cur) 0  - а он вообще зачем???
      
      #       #       ;; и начинаем крутить индекс левее
      #       #       ;; а что же при этом с правыми происходит?  ну мы же возвращаемся каждый раз
      
      #       return [MFOR_r_2 $mf  [expr {$cur - 1}]  $ijk_cur $IJK]
      
      return( MFOR_r( mf,  cur - 1,  ijk_cur, IJK))
    end
    
  end
  
end
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_todo_2 {mf} {
function MFOR_todo( mf)


#   #incf [$mf vget -index]  ;# просто увеличиваем порядковый индекс вызова 
  

#   if {[$mf first__GET]} { ;# самый первый этап с нулевыми значениями нужно выделить:
  if (mf.first == 1) 
  
    #println( ".. 001 ")
    #     $mf first__SET 0 ;# NIL
    #     #set ::first 0 ;# NIL
    
    #     return 1 ;#   T ; просто ничего не делая уходим 
    mf.first = 0

    return true # ??!!!

  else
    
    #println( ".. 002 ")
    #@printf( "dim= %s \n", mf.dim);
    
    #     ;; иначе
    #     ;; увеличиваем сначала правый индекс и при необходимости сдвигаемся влево
    
    #     #     (MFOR_r  (- (MF-dim mf) 1)  (MF-ijk_cur mf) (MF-IJK mf))
    
    #    # return [MFOR_r  [expr {[$mf.dim] - 1}]  [$mf vget -ijk_cur]  [$mf.IJK] ]
    #    # return [MFOR_r  [expr {[$mf.dim] - 1}]  ::ijk_cur  [$mf.IJK] ]
    
    #     #return [MFOR_r  [expr {$::dim - 1}]  ::ijk_cur  [$mf.IJK] ]
    #     #return [MFOR_r  $::dim_1  ::ijk_cur  [$mf.IJK] ]
    
    #     #set ijk
    
    #     return [MFOR_r_2 $mf  [$mf dim_1__GET]  [$mf ijk_cur__GET]  [$mf IJK__GET] ]

    #return (MFOR_r( mf,  mf.dim - 1,  mf.ijk_cur,  mf.IJK ))
    #MFOR_r( mf,  mf.dim - 1,  mf.ijk_cur,  mf.IJK )
    MFOR_r( mf,  mf.dim,  mf.ijk_cur,  mf.IJK ) # !!!!!!!!!!!!!1
    
    #     #return [MFOR_r  [dict get [set $mf] "dim_1"]  ::ijk_cur  $::IJK ]
    
  end
  #   }

end
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_get_ijk_cur_2 {mf} {


#   #set ijk_cur  $::ijk_cur
#   set ijk_cur  [$mf ijk_cur__GET]

#   return $ijk_cur
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_print_ijk_cur_2 {mf strname} {

#   set ijk_cur [MFOR_get_ijk_cur $mf]

#   #ijk_array_print $strname $::ijk_cur
#   ijk_array_print $strname [set $ijk_cur]

# }
# # ;;;=============================================================================
# # ;;;-----------------------------------------------------------------------------
function MFOR_test5( )


  #println( "\n")
  #println( "MFOR_test5  .. \n")

  #   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  mintest_flag = false # true

  #   global argc argv
  #   #puts "argc = $argc" 

  #   if {$argc == 3} {set mintest_flag 0}

  if (mintest_flag)
     dim     =   3
     ijk_max =   2
  else 
     dim     =   8
    ijk_max =   8
  end

  # #     alias MFOR_create        MFOR_create_1
  # #     alias MFOR_init          MFOR_init_1
  # #     alias MFOR_todo          MFOR_todo_1
  
  # #     alias MFOR_get_ijk_cur   MFOR_get_ijk_cur_1
  # #     alias MFOR_print_ijk_cur MFOR_print_ijk_cur_1

  #     set dim     7 ;# 7
  #     set ijk_max 7 ;# 7
  #   }

  #println( "...... 01 \n")

  #   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   #
  #   #set ijk_cur [make-array $dim] ;# UNDER CONSTRUCTION: make-array  dim1 dim2 ..

  #ijk_cur = make_list_( dim, "0")
  ijk_cur = make_list_( dim, 0)
  
  #   #set ijk_cur [make_array $dim "0"] 
  #   #set ijk_cur [ijk_array_make $dim "0"]

  IJK =  make_array( dim, "@")
  ijk_array_set( IJK, ijk_max)  # можно было раньше инициировать

  #   set mf [MFOR_create  $dim $ijk_cur $IJK]

  mf = MFOR_create( dim, ijk_cur, IJK)

  #println( "...... 03 \n")

  #   #puts stderr ""
  #   #puts stderr "mf = [set $mf]"

  #   #puts stderr "values = [dict values [set $mf] ]"
  #   #set ijk_d  [dict get [set $mf] ijk]

  #   #puts stderr "ijk_d = $ijk_d"
  #   #puts stderr "ijk_l = [dict values $ijk_d]"

  #   #dict set $mf "dim" 999
  #   #puts "mf = [set $mf]"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  MFOR_init( mf)
  
  #println( "...... 04 \n")

  println( "")

  #   ijk_array_print "ijk=" [set [$mf ijk_cur__GET]]
  ijk_array_print( "ijk_cur", mf.ijk_cur)

  ijk_array_print( "IJK=", mf.IJK)
  ijk_array_print( "IJK=",    IJK)
  #   #ijk_array_print "IJK=" $::IJK

  #   puts ""
  println( "")
  
  #   #   (loop while (MFOR_todo mf) do (progn
  #while (1 == 1) 
  while (true) 

    #println( "...... 05 \n")
    
    #     if {! [MFOR_todo $mf]} {break}

    ret =  MFOR_todo( mf)
    #print( "ret = $ret \n")
    
    if (! ret)  break   end
    
    #     #ijk_array_print "ijk_cur=" [$mf.ijk_cur]
    #     #ijk_array_print "ijk_cur=" $::ijk_cur

    if (mintest_flag)
      ijk_array_print( "ijk_cur=", mf.ijk_cur)
      end
    
    #exit();
    #     if {$mintest_flag} {
    #       MFOR_print_ijk_cur $mf "ijk_cur="
    #     }
    
  end
  
  #  # puts ""
  println( "")

end  

# # ;;;=============================================================================




#   alias MFOR_create        MFOR_create_2
#   alias MFOR_init          MFOR_init_2
#   alias MFOR_todo          MFOR_todo_2
  
#   alias MFOR_get_ijk_cur   MFOR_get_ijk_cur_2
#   alias MFOR_print_ijk_cur MFOR_print_ijk_cur_2
  



# # ;;;-----------------------------------------------------------------------------
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_init_1 {mf} {


#   #$mf first__SET 1
#   set ::first 1
#   #$mf.index  = -1 ;# чтобы первым был нуль
  
#   #ijk_array_set [$mf vget -ijk_cur] 0
#   #ijk_array_set ::ijk_cur 0
#   #$mf ijk_cur__SET 0 ;# это простой индекс !!

#   set ::cur $::dim_1
#   #set ::cur 0

# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_create_1 {dim ijk_cur IJK} {

#   # (let* (
#   #   mf
#   #   )
  
#   #   ;; создадим новую пструктуру
#   #   (setf mf (make-MF))
#   #set mf [MF \#auto]

#   #set mf [dict create]

#   set mf [g_get_unicum_name] ;# получили глобальное имя (ссылку)
#   #set mf [MF new]

  
#   #   ;; занесем в нее готовые массивы

#   #$mf.dim     =  $dim
#   #dict set $mf "dim" $dim 
#   #set ::dim    $dim

#   #dict set $mf "dim_1" $::dim_1 
#   #dict set $mf "dim_1" [expr {$dim - 1}] ;# интересно, что оно делает?

#   set ::dim_1  [expr {$dim - 1}] ;# особо не влияет такое "ускорение"
#   #$mf dim_1__SET [expr {$dim - 1}]

#   #$mf.IJK     =  $IJK
#   set ::IJK    $IJK
#   #$mf IJK__SET $IJK

#   set ::ijk_cur    $ijk_cur
#   #$mf ijk_cur__SET $ijk_cur
  
#   dotimes index [llength $ijk_cur] { 
 
#     #set ::ijk($index) [lindex $ijk_cur $index]

#   }


#   #   ;(MFOR_init mf)
  
#   return $mf
# }
# # ;;;-----------------------------------------------------------------------------
# #
# #
# #
# # ;;;-----------------------------------------------------------------------------
# #proc MFOR_r {cur &ijk_cur IJK} {}
# #proc MFOR_r {cur &ijk_cur IJK} {}
# #proc MFOR_r_1 {mf cur ijk_cur IJK} {}
# #proc MFOR_r_1 {mf cur } {}
# proc MFOR_r_1 {mf cur} {

#   #puts "cur = $::cur"
#   set ::cur $cur

#   #set cur $::cur
#   #set IJK [$mf IJK__GET]

#   #USE_REFS ;# может этот перебор переменных тормозит ?!!!!!!!!!!!!!!!!!!!!!!!!!!!
#   # 
#   #upvar $ijk_cur_REF ijk_cur ;# здесь тчоно в 2.5 раза тормозит !!
#   #upvar ${&ijk_cur} ijk_cur 

#   # просто увеличиваем значение текущего индекса

#   #lset ijk_cur $cur [expr {[lindex [set ${ijk_cur}] $cur] + 1}] 
#   #lset $ijk_cur $cur [expr {[lindex [set $ijk_cur] $cur] + 1}] 
#   #lset $::ijk_cur $cur [expr {[lindex [set $::ijk_cur] $cur] + 1}]
 
#   lset $::ijk_cur $::cur [expr {[lindex [set $::ijk_cur] $::cur] + 1}] 

#   # 
#   #ijk_array_incr ijk_cur $cur ;# уже приилчно  увеличиваем !! 
#   #                              может upvar долго так работает ??

#   #incr ::ijk($cur) ;# сука ! увеличивает !

  
#   #if {! ([lindex [set $ijk_cur] $cur] == [lindex $IJK $cur])} {}
#   if {! ([lindex [set $::ijk_cur] $::cur] == [lindex $::IJK $::cur])} { 

#     #if {! ([ijk_get ijk_cur $cur] == [lindex $IJK $cur])} { }  ;# тоже увеличивает!

#     #return 1 ;#       T ; просто уходим, если нет еще границы

#   } else {
#     #     ;; дошли до максимума, значит надо к след. индексу переходить
       
#     if {$::cur == 0} { ;# однако, если это был последний (левый) индекс,

#       return 0 ;# NIL       ; то конец

#     } else {
#       #       (setf (aref ijk_cur cur) 0) ; обнуляем текущий индекс
#       #lset ijk_cur $cur   0 ;# обнуляем текущий индекс
#       lset $::ijk_cur $::cur   0 ;# обнуляем текущий индекс

#       incr ::cur -1
#       #puts "cur = $::cur"

#       #set ::ijk($cur) 0  - а он вообще зачем???
      
#       #       ;; и начинаем крутить индекс левее
#       #       ;; а что же при этом с правыми происходит?  ну мы же возвращаемся каждый раз

#       #return [MFOR_r_1 $mf  [expr {$cur - 1}]  $ijk_cur $IJK]

#       #return [MFOR_r_1 $mf  [expr {$cur - 1}] ]
#       return [MFOR_r_1 $mf $::cur]
#     }   
#   }
  
#   return 1 ;#       T ; просто уходим, если нет еще границы
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_todo_1 {mf} {


#   #incf [$mf vget -index]  ;# просто увеличиваем порядковый индекс вызова 
  

#   #if {[$mf first__GET]} {} ;# самый первый этап с нулевыми значениями нужно выделить:
#   if {$::first} { ;# самый первый этап с нулевыми значениями нужно выделить:
   
#     #$mf first__SET 0 ;# NIL
#     set ::first 0 ;# NIL

#     return 1 ;#   T ; просто ничего не делая уходим 
    
#   } else {

#     #     ;; иначе
#     #     ;; увеличиваем сначала правый индекс и при необходимости сдвигаемся влево
    
#     #     (MFOR_r  (- (MF-dim mf) 1)  (MF-ijk_cur mf) (MF-IJK mf))

#    # return [MFOR_r  [expr {[$mf.dim] - 1}]  [$mf vget -ijk_cur]  [$mf.IJK] ]
#    # return [MFOR_r  [expr {[$mf.dim] - 1}]  ::ijk_cur  [$mf.IJK] ]

#     #return [MFOR_r  [expr {$::dim - 1}]  ::ijk_cur  [$mf.IJK] ]
#     #return [MFOR_r  $::dim_1  ::ijk_cur  [$mf.IJK] ]

#     #set ijk

#     # return [MFOR_r_1 $mf  [$mf dim_1__GET]  [$mf ijk_cur__GET]  [$mf IJK__GET] ]
#     #return [MFOR_r_1  $mf $::dim_1]

#     return [MFOR_r_1  $mf $::dim_1] ;# каждый раз начинаем просматривать справа!!!
#   }
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_get_ijk_cur_1 {mf} {


#   set ijk_cur  [set $::ijk_cur]
#   #set ijk_cur  [$mf ijk_cur__GET]

#   return $ijk_cur
# }
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_print_ijk_cur_1 {mf strname} {

#   set ijk_cur [MFOR_get_ijk_cur_1 $mf]

#   ijk_array_print $strname $ijk_cur
#   #ijk_array_print $strname [set $ijk_cur]

# }
# # ;;;=============================================================================


# # ;;;=============================================================================
# # ;
# # ;;;-----------------------------------------------------------------------------
# # (defun test4_ (argus)  (declare (ignore argus))

# # (let* (
# #   (dim     3)
# #   (ijk_cur (make-array dim))
# #   (IJK     (make-array dim))
# #   mf 
# #   )

# #   (ijk_array_set IJK     2) ; булевые переменные '(nil t) 
# #   (setf mf (MFOR_create  dim ijk_cur IJK))
# #   (MFOR_init mf)

# #   (format t "~%")

# #   (loop while (MFOR_todo mf) do (progn

# #     (format t " ~2D)    " (MF-index mf))
# #     (dotimes (i (length ijk_cur))
# #       (format t "~4S  " (nth (aref ijk_cur i) '(nil t)))
# #     )
# #     (format t "~%")
# #   )) 

# #   (format t "~%")
# # ))
# # ;;;-----------------------------------------------------------------------------
# proc MFOR_test {} {



#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   set mintest_flag 1

#   global argc argv
#   #puts "argc = $argc" 

#   if {$argc == 3} {set mintest_flag 0}

#   if {$mintest_flag} {
#     set dim     3
#     set ijk_max 2
#   } else {

#     set dim     7 ;# 7
#     set ijk_max 7 ;# 7
#   }

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   #
#   #set ijk_cur [make-array $dim] ;# UNDER CONSTRUCTION: make-array  dim1 dim2 ..

#   set ijk_cur [make_list_ $dim "0"] 
#   #set ijk_cur [make_array $dim "0"] 
#   #set ijk_cur [ijk_array_make $dim "0"]

#   set IJK     [make_array $dim "@"]
#   #   mf
 
#   ijk_array_set IJK  $ijk_max ;# можно было раньше инициировать

#   set mf [MFOR_create_1  $dim $ijk_cur $IJK]

#   #puts stderr ""
#   #puts stderr "mf = [set $mf]"

#   #puts stderr "values = [dict values [set $mf] ]"
#   #set ijk_d  [dict get [set $mf] ijk]

#   #puts stderr "ijk_d = $ijk_d"
#   #puts stderr "ijk_l = [dict values $ijk_d]"

#   #dict set $mf "dim" 999
#   #puts "mf = [set $mf]"

#   MFOR_init_1 $mf
  

#   puts ""

#   #ijk_array_print "ijk=" [set [$mf ijk_cur__GET]]
#   ijk_array_print "ijk=" [set $::ijk_cur]

#   #ijk_array_print "IJK=" [$mf IJK__GET]
#   ijk_array_print "IJK=" $::IJK

#   puts ""
  
#   #   (loop while (MFOR_todo mf) do (progn
#   while {1} {

#     if {! [MFOR_todo_1 $mf]} {break}
  
#     #ijk_array_print "ijk_cur=" [$mf.ijk_cur]
#     #ijk_array_print "ijk_cur=" $::ijk_cur

#     if {$mintest_flag} {
#       MFOR_print_ijk_cur_1  $mf "ijk_cur="
#     }
  
#   }
  
#   # можно же и наоборот сделать - постоянный цикл, а из цикла уже вызывать 
#   # обработчик вывода !
#   # 
  
#  # puts ""
# }
# # ;===============================================================================
# # 
# # ;;;-----------------------------------------------------------------------------

# # time b~.tl MISC MFOR_test5 @

# # ijk=  0 0 0 0 0 0 0 
# # IJK=  7 7 7 7 7 7 7 

# # real	0m1.962s
# # user	0m1.940s
# # sys	0m0.012s

# #-------------------------------------------------------------------------------
# #

# # b~.tl MISC MFOR_test
# # 
# # чего-то совсем запутался с алгоритмом!
# #
# # медленно, может из-за постоянного вызова итерационно функции,
# # а в Лиспе какая-то оптимизация!? а почему не арботает "безстековый" вызов?
# #
# #

# #-------------------------------------------------------------------------------
# # ;===============================================================================
