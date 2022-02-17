# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
proc load_inilib_joy {} {

if {0} {
#------------------------------------------------
(* FILE:   inilib.joy *)

LIBRA

    _inilib == true;


(* - - - - -  I N P U T   O U T P U T  - - - - *)

    newline == '\n putch;
    space == '\032 putch;
    bell == '\007 putch;

    putln == put newline;

(* this is now a primitive in raw Joy:
    putchars == [putch] step;
*)
    putstrings == [putchars] step;

    ask == "Please " putchars putchars newline get;

(* - - - - -   O P E R A T O R S   - - - - - *)

    dup2 ==  dupd dup swapd;
    pop2 == pop pop;
    newstack == [] unstack;
    truth == true;
    falsity == false;
    to-upper == ['a >=] [32 -] [] ifte;
    to-lower == ['a < ] [32 +] [] ifte;
    boolean == [logical] [set] sequor;
    numerical == [integer] [float] sequor;
    swoncat == swap concat;

(* date and time *)

    weekdays ==
	[ "Monday" "Tuesday" "Wednesday" "Thursday" "Friday"
          "Saturday" "Sunday" ];
    months ==
	[ "JAN" "FEB" "MAR" "APR" "MAY" "JUN"
	  "JUL" "AUG" "SEP" "OCT" "NOV" "DEC" ];
    localtime-strings ==
	time localtime
	[ [ 0 at 'd 4 4 format			]
	  [ 1 at pred months of			]
	  [ 2 at 'd 2 2 format			]
	  [ 3 at 'd 2 2 format			]
	  [ 4 at 'd 2 2 format			]
	  [ 5 at 'd 2 2 format			]
	  [ 6 at [] ["true"] ["false"] ifte	]
	  [ 7 at 'd 5 5 format			]
	  [ 8 at pred weekdays of		] ]
	[i] map
	popd;
    today ==
	localtime-strings
	[ [8 at] [" "] [2 at] ["-"] [1 at] ["-"] [0 at rest rest] ]
	[i] map
	popd
	"" [concat] fold;
    now ==
	localtime-strings
	3 drop
	[ [0 at] [":"] [1 at] [":"] [2 at] ]
	[i] map
	popd
	"" [concat] fold;
    show-todaynow ==
	today putchars space now putchars newline;

(* program operators *)

    conjoin == [[false] ifte] cons cons;
    disjoin == [ifte] cons [true] swons cons;
    negate == [[false] [true] ifte] cons;

(* - - - - -  C O M B I N A T O R S  - - - - - *)

    sequor == [pop true] swap ifte;
    sequand == [pop false] ifte;
    dipd == [dip] cons dip;
    dip2 == [dip] cons dip;
    dip3 == [dip2] cons dip;
    call == [] cons i;
    i2 == [dip] dip i;
    nullary2 == [nullary] cons dup i2 swapd;
(* this is now a primitive in raw Joy:
    unary2 == [unary  ] cons dup i2;
*)
    repeat == dupd swap [i] dip2 while;
    forever == maxint swap times;

(* library inclusion *)

    verbose == false;
    libload ==
	[ '_ swons intern body null ]
	[ ".joy" concat include ]
	[ [ verbose ]
	  [ putchars "  is already loaded\n" putchars ]
	  [ pop ]
	  ifte ]
	ifte;
    basic-libload ==
	"agglib" libload
	"seqlib" libload
	"numlib" libload;
    special-libload ==
	"mtrlib" libload
	"tutlib" libload
	"lazlib" libload
	"lsplib" libload
	"symlib" libload;

    all-libload == basic-libload special-libload;

    INILIB == "inilib.joy - the initial library, assumed everywhere\n".
							(* end LIBRA *)



"inilib  is loaded\n" putchars.

(* "inilib  is loaded" . *)


(* END   inilib.joy *)
#-------------------------------------------------------------------------------
}
}
#-------------------------------------------------------------------------------
proc libs_test_00 {} {

  puts ""
  puts "libs_test_00 ... "
  puts ""

  v1_init_all  

  r c  1 2 + .

  r c  5  {7 <}  {10 +}  {10 -}  ifte .

}
#-------------------------------------------------------------------------------
proc libs_test_01 {} {

  puts ""
  puts "libs_test_01 ... "
  puts ""

  v1_init_all  

#(*----------------------------------------------------------------------------*)
#(*                     Synopsis of the language Joy                           *)
#(*----------------------------------------------------------------------------*)

  r c  2 3 + .

  # складываем два числа, потом дублируем его в стеке и перемножаем их 
  r c  2 3 + dup * .

  #(* склеиваем две строки *)
  r c  {1 2 3}  {4 5 6 7}  concat .

  # применяем некую функцию к массиву, здесь возведение в квадрат 
  r c  {1 2 3 4}  {dup *}  map .

  # ===================================================================
  
  # Finally, take a look at the combinators "i" and "dip":
  
  #       [A] i   == A
  #   [B] [A] dip == A [B] 
  
  # These combinators are special in that they dequote stack items, 
  # removing their wrapping; in other words, these combinators execute 
  # programs on the stack. The "i" combinator simply executes the top 
  # item on the stack. 
  # The "dip" combinator executes the top item "A", 
  # but first it gets rid of the second item, which is restored after 
  # the execution of "A" is complete. The "dip" combinator will prove 
  # to be very versatile and 
  # also quite fundamental. 
  
  #  ====================================================================
  
  # i - выполняет верхний итем на стеке: результатом будут в стеке "100 6" 

  r c  2 3  { + 20 * 10 4 - }  i . .


  if {0} {
    
  (* ===================================================================
   
   Another combinator that expects an aggregate is the filter combinator. 
   The quoted program has to yield a truth value. The result is a new 
   aggregate of the same type containing those elements of the original 
   for which the quoted program yields true. For example, the quoted 
   program ['Z >] will yield truth for characters whose numeric values 
   is greater than that of Z. Hence it can be used to remove upper case 
   letters and blanks from a string.
   
   ====================================================================*)
  
  (* применяем фильтр к строке: убираем заглавные буквы и пробелы ? *)
  
  "John Smith"  ['Z >]  filter .
  
  }
  
  # (* ===================================================================
  
  # Sometimes it is necessary to add or multiply or otherwise combine all 
  # elements of an aggregate value. The fold combinator can do just that. 
  # It requires three parameters: the aggregate to be folded, the quoted 
  # value to be returned when the aggregate is empty, and the quoted 
  # binary operation to be used to combine the elements. In some languages 
  # the combinator is called reduce (because it turns the aggregate into 
  # a single value), or insert (because it looks as though the binary 
  # operation has been inserted between any two members). The following 
  # two programs compute the sum of the members of a list and the sum of 
  # the squares of the members of a list. They evaluate to 10 and 38, 
  # respectively. 
  
  #  ====================================================================*)

  puts ""
  
  r c  {2 5 3}  0        ~+   fold .
  r c  {2 5 3}  0      {~ +}  fold .
  r c  {2 5 3}  0  {dup * +}  fold .  
  
  
if {0} {
    

(* ===================================================================

Joy has a useful device, the linrec combinator, which allows computation 
of anonymous functions that might have been defined recursively using 
a linear recursive pattern. Whereas the ifte combinator requires three 
quoted parameters, the linrec combinator requires four: an if-part, 
a then-part, a rec1-part and a rec2-part. Recursion occurs between 
the two rec-parts. For example, the factorial function could be 
computed by 
	succ == 1 +;
	pred == 1 -;

Здесь простая линейная рекурсия:
if 0 then 1 else [дублируем и уменьшаем на 1, затем умножаем *]

 ====================================================================*)

4  [null] [succ] [dup pred] [*] linrec  .

(* вычислим факториал для каждого элемента списка [1 2 3 4] *)
[1 2 3 4]  [ [null]  [succ]  [dup pred]  [*]  linrec ]   map .


(* ===================================================================

quit.

 ====================================================================*)
}


}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
