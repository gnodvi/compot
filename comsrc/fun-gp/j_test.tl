# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc simple {} {




}
#-------------------------------------------------------------------------------
proc run_joy_file_v1 {fname} {


  # не будем включать include на стадии препроцессинга
  # 
  set r_text_all [read_file_to_rtext   $fname]
  
  set ndict [joy-compile_to_namecodedict \
                $r_text_all \
                "joy_functext_to_v1_code"]

  puts "ndict:  $ndict"
  puts ""


  v1_init_all       ;# разные ништяки

  set v1_src [dict get $ndict {}]

  run_v1_src  $v1_src 

  return
}
#-------------------------------------------------------------------------------
proc runfiles_v1 {} {


  puts ""

  run_joy_file_v1 "OLDJOY/F/j__00.joy"

  puts ""
  puts "----------------------------------------------"
  puts ""

  run_joy_file_v1 "OLDJOY/F/j__01.joy"

#   puts ""
#   puts "----------------------------------------------"
#   puts ""

#   run_joy_file_v1 "F/j__02.joy"

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc newstest {} {

  puts ""
  puts "TEST_test_NEW ..."
  puts ""
  
  v1_init_all  


  #r c  .s 
  r c  1 2   ~+ i    .s 
  r c  1 2 9 ~+ dip  .s 

# pop2     == pop pop;
# popd     == [pop ] dip;
# rollup   == swap [swap] dip;
# rolldown == [swap] dip swap;
# rotate   == swap [swap] dip swap;

  r c  6 2  dup2 - ~+ dip  .s ;# все верно -> 8 4, сначала дублируем пару, выполняем
  #                             операцию - и затем + с двумя элементами ниже

  puts ""

  r c    A B  dupd  .s ;# -> A A B
  r           dup   .s ;# -> A A B B
  r           swapd .s ;# -> A B A B - дублируем сразу пару
  
  puts ""

  r c  6 2  dup2 - ~+ dip  .s 
  r    cons {2 /} map .s 

  puts ""

  r c   10.2 {2 1 * /} map .s ;# можно мапировать и одиночный итем

  puts ""


  v0_: solveq_NEW   =c =b =a    \
    @b  neg                     \
    @b @b  * 4 @a @c * * - sqrt \
    dup2 - ~+ dip               \
    cons                        \
    {2 @a * /} map 
  
  r c  2 -16 30 solveq_NEW  .s   ;# 2x^2 -16x + 30 = 0 ; D=4, x= (16 +- 4)/4. x1= 5, x2= 3
  r c  1   0 -4 solveq_NEW  .s   ;# x^2   +0x -  4 = 0                        x1=+2, x2=-2

  puts ""
  puts "-----------------------------------"
  puts ""

  #  The following binary operators are defined on all stacks containing at least two 
  #   elements:

  #         swap    popd    popop    dupd
  
  #  The swap operator interchanges the top two elements. The popd operator removes 
  #  the second element. The popop operator removes the first and the second element. 
  #  The dupd operator duplicates the second element.
  
  #  The following ternary operators are defined for all stacks containing at least 
  #  three elements:
  
  #         swapd    rollup    rolldown
  
  #  The swapd operator interchanges the second and third elements but leaves the 
  #  first element in place. The rollup operator moves the third and second element 
  #  into second and third position and moves the first element into third position. 
  #  The rolldown operator moves the second and first element into third and second 
  #  position and moves the third element into first position.
  

  v0_: while  {

    set do_part    [pop ]
    set while_part [pop ]

    #puts "stack = $::joy_ST"

    while {1} {
    
      eval r  $do_part
      #puts "stack = $::joy_ST"

      eval r  dup  ;# продублировали верхний элемент, чтобы использовать его в сравнении

      eval r  $while_part
      #puts "stack = $::joy_ST"
 
      set ret [pop]  ;# забрали результат сравнения
      #puts "ret = $ret, stack = $::joy_ST"

      if {$ret == 0} {
        break
      } 
    }
    
  }  tcl  

  #v0_: while  =D =B  @B @D @B @D ~while cons cons concat [] ifte


  #r c  10 {> 0} {1 - } while  .s  
  r c  10 {0 > } {1 - } while  .s  

  #  в оригинальном файле numlib.joy tcnm jghtltktybt 
  #
  #  gcd == [0 >] [dup rollup rem] while pop;

  #  The next program computes the greatest common divisor of two numbers, using 
  #  Euclid's algorithm. The algorithm uses two numbers and repeatedly takes the 
  #  remainder after dividing one by the other. The remainder obtained is then used 
  #  to replace the dividend. The process is repeated as long as the potential 
  #  divisor is positive. So, unlike the previous programs, we cannot use the times
  #   combinator. Instead a combinator called while is used which resembles 
  #  while-loops in imperative languages. It takes two parameters: the while-part 
  #  is a quoted program which must return a truth value, and the do-part is a 
  #  quoted program which can compute anything. The while-part in the following gcd 
  #  program is of course very similar to a corresponding part in the fib program.
  
  v0_:   gcd   {0 >} {dup ~rem dip swap} while pop

  # понять что за алгоритм
  # 

  puts ""

  r c  12 8  gcd  .s  ;# это верно ! !

  puts ""
  puts "-----------------------------------"
  puts ""

  r c  4  null . 


  v0_: pairlist   {} cons cons

  r c  asas DEBUG sdds DEBUG pairlist .

  puts ""
  puts "-----------------------------------"
  puts ""

  #-------------------------------------------------------------
  # i_main i__01.joy


  #  4  [null] [succ] [dup pred] [*] linrec  . 
  #
  #  (* вычислим факториал для каждого элемента списка [1 2 3 4] *)
  #  [1 2 3 4]  [ [null]  [succ]  [dup pred]  [*]  linrec ]   map .

  #------------------------------------

  # Joy has a useful device, the linrec combinator, which allows computation 
  # of anonymous functions that might have been defined recursively using 
  # a linear recursive pattern. 

  # Whereas the ifte combinator requires three 
  # quoted parameters, the linrec combinator requires four: 
  # an if-part, 
  # a then-part, a rec1-part and a rec2-part. Recursion occurs between 
  # the two rec-parts. For example, the factorial function could be 
  # computed by 
  # 	succ == 1 +;
  # 	pred == 1 -;
  
  # Здесь простая линейная рекурсия:
  # if 0 then 1 else [дублируем и уменьшаем на 1, затем умножаем *]
  
  #------------------------------------
  # так в оригинале:
 

  #   if (result)                   // если условие [1] выполняется, то
  #     exeterm (SAVED3->u.lis);    // выполнить [2] и все!
  #   else                          // иначе :
  #   
  #     exeterm (SAVED2->u.lis);    // выполняем [3]
  #     linrecaux ();               // вызываемся рекурсивно
  #     exeterm (SAVED1->u.lis);    // выполняем [4]

  #------------------------------------
  # а это вариант в версии 3:


  # 	linrec == (P T R1 R2)
  # 	    $P $T
  # 		    $R1
  # 		    $P $T $R1 $R2 [] cons cons cons cons
  # 		    [linrec] $R2 concat concat concat
  # 		    ifte;
  
  # попробуем без особой надежды?


  v0_: linrec_3   =R2 =R1 =T =P   DEBUG \
    @P DEBUG @T DEBUG     \
    @R1 DEBUG      \
    \
    @P @T @R1 @R2 DEBUG {} cons DEBUG cons cons cons  DEBUG \
    ~linrec DEBUG @R2 DEBUG concat DEBUG concat DEBUG concat DEBUG    \
    ifte 

  r c  1  ~null ~succ {dup pred} ~* DEBUG linrec_3  . 

  puts ""
  puts "-----------------------------------"
  puts ""

}  
#-------------------------------------------------------------------------------
proc minimum {} {

  puts ""
  puts "TEST_test_MIN ..."
  puts ""
  
  v1_init_all  


  r c  1 2 9 ~+  DEBUG dip  .s 

  r c  1 2 9 {~ +} dip  .s 

 puts ""

  # так в оригинале:
 

  #   if (result)                   // если условие [1] выполняется, то
  #     exeterm (SAVED3->u.lis);    // выполнить [2] и все!
  #   else                          // иначе :
  #   
  #     exeterm (SAVED2->u.lis);    // выполняем [3]
  #     linrecaux ();               // вызываемся рекурсивно
  #     exeterm (SAVED1->u.lis);    // выполняем [4]

  r c  5  {~ null} {~ succ} {dup pred} {~ *} linrec  . 

}
#-------------------------------------------------------------------------------

# f~.tl 1111 TEST_file_v1

# f~.tl TEST newstest
# f~.tl TEST minimum

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
