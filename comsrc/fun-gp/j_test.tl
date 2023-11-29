# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
proc load_inilib_joy {} {


set text_joy {
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



"inilib  is loaded\n" putchars .

(* "inilib  is loaded" . *)


(* END   inilib.joy *)
#------------------------------------------------
} ;# text_joy


  run_joy_as_v1  $text_joy

}
#-------------------------------------------------------------------------------
proc load_numlib_joy {} {


set text_joy {
#------------------------------------------------

(* FILE:   numlib.joy *)

LIBRA

    _numlib == true;

(* predicates *)

    positive == 0 >;
    negative == 0 <;
    even == 2 rem null;
    odd == even not;
    prime ==
	2
	[ [dup * >] nullary  [rem 0 >] dip  and ]
	[ succ ]
	while
	dup * < ;

(* functions *)

    fact == [1 1] dip [dup [*] dip succ] times pop;
    fib == [1 0] dip [swap [+] unary] times popd;
(*
    nfib == [1 1] dip [dup [+ succ] dip swap] times pop;
*)
    gcd == [0 >] [dup rollup rem] while pop;

    fahrenheit == 9 * 5 / 32 + ;
    celsius == 32 - 5 * 9 / ;

    pi == 3.14159265;
    e == 1.0 exp;
    radians == pi * 180 / ;
    sindeg == radians sin;
    cosdeg == radians cos;
    tandeg == radians tan;

    (* find roots of the quadratic equation with coefficients a b c :
				  a * X^2  +  b * X   +  c  =  0	*)
    qroots ==					(*  a  b  c		*)
	[	pop pop null ]			(* a = 0 ?		*)
						(* degenerate cases:	*)
	[	[   pop null ]			(* b = 0 ?		*)
		[   [ null   ]			(* c = 0 ?		*)
		    [ [_INF] ]			(* =>  [_INF]		*)
		    [ [] ]			(* =>  []		*)
		    ifte
		    [ pop pop pop ] dip ]
		[   0 swap - swap 1.0 * /	(* float divisor	*)
		    [] cons popd ]		(* =>  [ -c/b ]		*)
		ifte ]
						(* standard cases:	*)
	[	[   [ dup * swap ] dip
		      4 * * - ] unary		(* b^2 - 4ac		*)
		[   0 < ]			(* b^2 - 4ac negative ?	*)
		[   pop pop pop [_COMPLEX] ]	(* =>  [_COMPLEX]	*)
		[   [ 0 swap - 1.0 *		(* -b  (floated)	*)
		      swap 2 * ] dip		(* 2a			*)
		    [ 0 = ]			(* b^2 - 4ac zero ?	*)
		    [ pop / [] cons ]		(* =>  [-b / 2a]	*)
		    [ sqrt swapd dup2 - [+] dip	(*   -b+s      -b-s     *)
			[] cons cons 		(* [ -b+s      -b-s    ]*)
		      swap [/] cons map ]   (* =>  [(-b+s)/2a (-b-s)/2a]*)
		    ifte ]
		ifte ]
	ifte;

(* combinators *)

    deriv == [unary2 swap - 0.001 /] cons  [dup 0.001 +] swoncat;

(*  Newton's method for finding roots of equations in one variable,
    for example to find the temperature at which Fahrenheit = Celsius:
    using 5 as a guess, find the X for which X = fahrenheit(X)
					   or X - fahrenheit(X) = 0
    in Joy:    5 [dup fahrenheit -] newton     =>  -40
        or  -100 [dup celsius    -] newton     =>  -40
    So -40 is the fixpoint for the two conversion functions.
*)

    newton ==		(*  Usage: guess [F] newton		*)
	dup deriv		(* guess [F] [D]		*)
	[ pop i abs 0.0001 > ]	(* too big ?			*)
	[ [dupd] dip      	(* guess guess [F] [D]		*)
	  dup2			(* guess guess [F] [D] [F] [D]	*)
	  [[cleave / - ] dip]
	  dip  ]		(* newguess [F] [D]		*)
	while
	pop pop;
    use-newton == [[-] cons] dip  swoncat  1 swap newton;
    cube-root == [dup dup * *] use-newton;

    NUMLIB == "numlib.joy - numerical library\n".
						(* end LIBRA *)

"numlib  is loaded\n" putchars.

(* END   numlib.joy *)

#------------------------------------------------
} ;# text_joy


  run_joy_as_v1  $text_joy

}
#-------------------------------------------------------------------------------
proc load_mthlib_joy {} {


set text_joy {
#------------------------------------------------

(* FILE:   mthlib.joy *)

    basic-libload.

LIBRA

    _mthlib == true;

(* REMOVE THIS, PUT IN OBJ LIBRARY *)
(* "object oriented" lists:
	constructor kons,
	selectors kar,kdr (messages) *)
    kons == [] cons cons [of] cons;
    kar == 0 swap i;
    kdr == 1 swap i;

(* NOTE : This file defines just two programs:
	1. Numerical Calculator		-  calc
	2. Symbolic Differentiation 	-  diff
   All two programs expect input in Lisp notation			*)

(* - - -          N U M E R I C A L   C A L C U L A T O R         - - - *)

(*	e.g.   [* 10 [+ 2.2 3.3]]  calc.   *)

    calc == 
	[ numerical ]
	[ ]
	[ unswons
	  [ dup [+ - * /] in ]
	  [ [ [calc] map uncons first ] dip
	    call ]
	  [ "bad operator\n" put ]
	  ifte ]
	ifte ;

(* - - -      S Y M B O L I C   D I F F E R E N T I A T I O N     - - - *)

(* REFS: SICP p 106, Henderson p 39 *)

(* HIDE  *)

    _msum == pairlist [+] swoncat;
    (* optimised for addition of 0 :					*)
    _makesum ==						(*  e1  e2	*)
	[ [ [ [numerical] unary2 and ]			(*  n1  n2  ?	*)
	    + ]
	  [ [ numerical ]				(*  e1  n2  ?	*)
	    [0 =] [pop] [_msum] ifte ]
	  [ [ pop numerical ]				(*  n1  e2  ?	*)
	    [pop 0 =] [popd] [_msum] ifte ]
	  [ _msum] ]					(*  e1  e2  !	*)
	cond;

    _mprod == pairlist [*] swoncat;
    (* optimised for multiplication by 0 and 1 :			*)
    _makeproduct ==					(*  e1  e2	*)
	[ [ [ [numerical] unary2 and ]			(*  n1  n2  ?	*)
	    * ]
	  [ [ numerical ]				(*  e1  n2  ?	*)
	    [ [ [0 =] popd ]				(*      0   ?	*)
	      [ [1 =] pop ]				(*      1   ?	*)
	      [ _mprod ] ]				(*  e1  n2  !	*)
	    cond ]
	  [ [ pop numerical ]				(*  n1  e2  ?	*)
	    [ [ [pop 0 =] pop ]				(*  0       ?	*)
	      [ [pop 1 =] popd ]			(*  1       ?	*)
	      [ _mprod ] ]				(*  n1  e2  !	*)
	    cond ]
	  [ _mprod ] ]					(*  e1  e2  !	*)
	cond

; (* IN  *)

(*  [var]  exp  diff  =>   the derivative of exp w.r.t. var		*)
    diff ==					(*  [v]  e		*)
	[ [ [numerical]			
	    pop pop 0 ]				(*  => 0		*)
	  [ [leaf] 
	    [[first] dip = ]			(*   v  e  = ?		*)
	    [pop pop 1]				(*  => 1		*)
	    [pop pop 0]				(*  => 0		*)
	    ifte ]
	  [ [list]
	    unswons
	    [ [ +
		pop unpair			(*  [v]  e1 e2		*)
		[diff] unary2			(*  [v]  d1 d2		*)
		_makesum popd ]			(*  =>     s		*)
	      [ *
		pop unpair			(*  [v]  e1 e2		*)
		dup2				(*  [v]  e1 e2  e1 e2	*)
		[[diff] unary2] dip2		(*  [v]  d1 d2  e1 e2	*)
		rollup				(*  [v]  d1 e2  d2 e1	*)
		_makeproduct [_makeproduct] dip	(*  [v]    p1     p2	*)
		_makesum popd ]			(*  =>         s	*)
	      [] ]
	    opcase i ]
	  [] ]
	cond

; (* END;  *)

    MTHLIB == "mthlib.joy - symbolic mathematics library\n".

						(* end LIBRA *)

"mthlib  is loaded\n" putchars.

(* END   mthlib.joy *)

#------------------------------------------------
} ;# text_joy


  run_joy_as_v1  $text_joy

}
#-------------------------------------------------------------------------------
proc load_seqlib_joy {} {


set text_joy {
#------------------------------------------------

(* FILE:   seqlib.joy *)

"agglib" libload.

LIBRA

    _seqlib == true;

    putlist ==
	"[ " putchars
	[ null ]
	[ pop ]
	[ unswons
	  put
	  [ "\n  " putchars put ] step ]
	ifte
	"]\n" putchars;
    reverse == [[]] [""] iflist swap shunt;
    reverselist == [] swap shunt;
    reversestring == "" swap shunt;
    flatten == [null] [] [uncons] [concat] linrec;
    restlist == [null] [[] cons] [dup rest] [cons] linrec;
    product == 1 [*] fold;
(* this does short circuiting
    product ==
	1 swap
	[ null not ]
	[ [first null]
	  [[pop 0] dip pop []]
	  [uncons [*] dip]
	  ifte ]
	while
	pop;
*)
    scalarproduct == [0] dip2
	[null2] [pop2] [uncons2 [* +] dip2] tailrec;
    frontlist1 == (* Thompson p 247 *)
	[null] [[] cons]
	[uncons]
	[ [cons] map popd [] swons ]
	linrec;
    frontlist == (* also works for sets and strings *)
	[null] [[] cons]
	[uncons]
	[ [cons] map popd dup first rest swons ]
	linrec;
    subseqlist == (* Thompson p 247 *)
	[null] 
	[[] cons]
	[ uncons dup
	  [frontlist [cons] map popd] dip ]
        [concat]
	linrec;
    powerlist1 ==
	[null] [[] cons] [uncons]
	[dup swapd [cons] map popd concat] linrec;
    powerlist2 ==
	[null] [[] cons] [uncons]
	[dup swapd [cons] map popd swoncat] linrec;
    insertlist ==	(*   Sequence  Item   ->   List(Sequence) *)
	swons
	[ small ]
	[ unitlist ]
	[ dup				(* keep original *)
	  unswons unconsd swons ]	(* take out second *)
	[ swap [swons] cons map		(* swons in second *)
	  cons ]			(* cons in original *)
	linrec;
    permlist ==
	[ small ]
	[ unitlist ]
	[ uncons ]
	[ swap [insertlist] cons map
	  flatten ]
	linrec;
    qsort ==
	[small] [] [uncons [>] split] [swapd cons concat] binrec;
    qsort1-1 ==
	[small]
	[]
	[uncons unswonsd [first >] split [swons] dip2]
	[swapd cons concat]
	binrec;
    qsort1 ==
	[small] [] [uncons [[first] unary2 >] split] [swapd cons concat] binrec;
    mk_qsort ==
	[ [small] [] ] dip
	[ unary2 >] cons [split] cons [uncons] swoncat
	[ swapd cons concat ]
	binrec;
    merge ==
	[ [ [null] [pop] ]
	  [ [pop null] [popd] ]
	  [ [unswons2 <] [unconsd] [cons] ]
	  [ [unswons2 >] [uncons swapd] [cons] ]
	  [ [uncons2] [cons cons] ] ]
	condlinrec;
    merge1 ==
	[ [ [null] [pop] ]
	  [ [pop null] [popd] ]
	  [ [unswons2 [first] unary2 <] [unconsd] [cons] ]
	  [ [unswons2 [first] unary2 >] [uncons swapd] [cons] ]
	  [ [uncons2] [cons cons] ] ]
	condlinrec;
    insert ==
	[pop null] [firstd >=] disjoin
	[ swons ]
	[ unconsd]
	[ cons ]
	linrec;
    insert-old ==
	[ [ [pop null] [swons] ]
	  [ [firstd >= ] [swons] ]
	  [ [unconsd] [cons] ] ]
	condlinrec;
    delete ==
	[ [ [pop null] [pop] ]
	  [ [firstd >] [pop] ]
	  [ [firstd =] [pop rest] ]
	  [ [unconsd] [cons] ] ]
	condlinrec;
    transpose == (* READE p 133 *)
	[ [null] [true] [[null] some] ifte ]
	[ pop [] ]
	[ [[first] map] [[rest] map] cleave ]
	[ cons ]
	linrec;
    cartproduct == [[]] dip2 [pairlist swap [swons] dip] pairstep;
    orlist == [list] swap disjoin;
    orlistfilter == orlist [filter] cons;
    treeshunt == [swons] treestep;
    treeflatten == [] swap treeshunt reverse;
    treereverse == [] [reverse] [map] treegenrec;
    treestrip == [list] treefilter;
(*
    treemap == [map] treerec;
*)
    treemap == [] [map] treegenrec;
    treefilter == [] swap orlistfilter [map] treegenrec;
    treesample == [ [1 2 [3 4] 5 [[[6]]] 7 ] 8 ];

    SEQLIB == "seqlib.joy - sequence library, assumes agglib.joy\n".
							(* end LIBRA *)

"seqlib  is loaded\n" putchars.

(* END   seqlib.joy *)

#------------------------------------------------
} ;# text_joy


  run_joy_as_v1  $text_joy

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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

  # ----------------------------------------------------------------------------
  #                      Synopsis of the language Joy                           
  # ----------------------------------------------------------------------------

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
  
  # (===================================================================
  
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
  
  # ====================================================================

  puts ""
  
  r c  {2 5 3}  0        ~+   fold .
  r c  {2 5 3}  0      {~ +}  fold .
  r c  {2 5 3}  0  {dup * +}  fold .  
  
  
  # ===================================================================
  
  # Joy has a useful device, the linrec combinator, which allows computation 
  # of anonymous functions that might have been defined recursively using 
  # a linear recursive pattern. Whereas the ifte combinator requires three 
  # quoted parameters, the linrec combinator requires four: an if-part, 
  # a then-part, a rec1-part and a rec2-part. Recursion occurs between 
  # the two rec-parts. For example, the factorial function could be 
  # computed by 
  # 	succ == 1 +;
  # 	pred == 1 -;
  
  # Здесь простая линейная рекурсия:
  # if 0 then 1 else [дублируем и уменьшаем на 1, затем умножаем *]
  
  #  ===================================================================
  
  puts ""

  r c  4  {~ null} {~ succ} {dup pred} {~ *} linrec  .


  # вычислим факториал для каждого элемента списка [1 2 3 4] 

  r c  {1 2 3 4}  { {~ null} {~ succ}  {dup pred}  {~ *}  linrec }  map .


  # (* ===================================================================
  # quit. 
  #  ====================================================================*)
  

}
#-------------------------------------------------------------------------------
proc libs_test_02 {} {

  puts ""
  puts "libs_test_02 ... "
  puts ""

  v1_init_all  

  # (*-------------------------------------------------------------*)
  # (* Overview of the language JOY : это мои первые тесты         *)
  # (*-------------------------------------------------------------*)
  
  # "./J/inilib.joy" include.
  # "./J/numlib.joy" include.
  # "./J/mthlib.joy" include.
    
  v0_: "newline"  { puts -nonewline "\n" } tcl
  v0_: "putchars" { puts "[pop]" }         tcl

  load_inilib_joy


  r c  newline .

  r c  2 3  + .
  r c  2 3  +  dup  * .
  
  r c  {1 2 3}    {4 5 6 7}  concat .
  r c  {1 2 3 4}  {dup *}  map .

  v0_: square     dup * 
  r c  {1 2 3 4}  ~square  map .

  r c  5  {~ 1}  {~ *}  primrec .


  if {0} {

newline 
(*  ------- test.joy -------- *)

1001.1  cube-root.
argc.
argv.

(*  ------- -------- -------- *)
newline .

(*-------------------------------------------------------------*)
[* 10 [+ 2.2 3.3]]  calc.

(* ============================================================

1 -2 1 qroots . . 
1 0 -1 qroots . . 
-100 [dup celsius    -] newton .

 =============================================================*)

weekdays .

(*  [var]  exp  diff  =>   the derivative of exp w.r.t. var     *)

newline .
quit.

}

}
#-------------------------------------------------------------------------------
proc libs_test_03 {} {

  puts ""
  puts "libs_test_03 ... "
  puts ""

  v1_init_all  

  # (*-------------------------------------------------------------*)
  # (* Overview of the language JOY : это мои первые тесты         *)
  # (*-------------------------------------------------------------*)
  
  # "./J/inilib.joy" include.
  # "./J/numlib.joy" include.
  # "./J/mthlib.joy" include.
  
  # "./J/seqlib.joy" include.
  
  load_inilib_joy
  load_numlib_joy
  load_mthlib_joy

  load_seqlib_joy

  # (* ----------- можно определять в библиотеке ------------------*)
  # LIBRA
  
  # mylist == [5 6 0 1]
  v0_: mylist {5 6 0 1}

  # END. 
  # (* ----------- end HIDE and LIBRA -----------------------------*)
  # newline .
  # (*-------------------------------------------------------------*)
  
  
  r c  mylist putlist

  # newline .
  # mylist qsort  putlist 
  # newline .
  

if {0} {

argc .
argv .

newline .

1001.1  cube-root.

newline .

(* ============================================================

mylist frontlist putlist 

quit.


[5 2 3 4] qsort putlist
mylist putlist

 =============================================================*)
}

}
#-------------------------------------------------------------------------------

# f~.tl TEST libs_test_00
# f~.tl TEST libs_test_01
# f~.tl TEST libs_test_02
# f~.tl TEST libs_test_03

#-------------------------------------------------------------------------------
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
