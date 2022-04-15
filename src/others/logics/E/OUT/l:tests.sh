
---------------- MMVERIFY.PY --------------

[<_io.TextIOWrapper name='<stdin>' mode='r' encoding='UTF-8'>]
_______$( demo0.mm  1-Jan-04 $)
_______
_______$(
_______                           ~~ PUBLIC DOMAIN ~~
_______This work is waived of all rights, including copyright, according to the CC0
_______Public Domain Dedication.  http://creativecommons.org/publicdomain/zero/1.0/
_______
_______Norman Megill - email: nm at alum.mit.edu
_______
_______$)
_______
_______
_______$( This file is the introductory formal system example described
_______   in Chapter 2 of the Meamath book. $)
_______
_______$( Declare the constant symbols we will use $)
_______    $c 0 + = -> ( ) term wff |- $.
_______$( Declare the metavariables we will use $)
_______    $v t r s P Q $.
_______$( Specify properties of the metavariables $)
_______    tt $f term t $.
_______    tr $f term r $.
_______    ts $f term s $.
_______    wp $f wff P $.
_______    wq $f wff Q $.
_______$( Define "term" (part 1) $)
_______    tze $a term 0 $.
_______$( Define "term" (part 2) $)
_______    tpl $a term ( t + r ) $.
_______$( Define "wff" (part 1) $)
_______    weq $a wff t = r $.
_______$( Define "wff" (part 2) $)
_______    wim $a wff ( P -> Q ) $.
_______$( State axiom a1 $)
_______    a1 $a |- ( t = r -> ( t = s -> r = s ) ) $.
_______$( State axiom a2 $)
_______    a2 $a |- ( t + 0 ) = t $.
_______    ${
_______       min $e |- P $.
_______       maj $e |- ( P -> Q ) $.
_______$( Define the modus ponens inference rule $)
_______       mp  $a |- Q $.
_______    $}
_______$( Prove a theorem $)
_______    th1 $p |- t = t $=
_______  $( Here is its proof: $)
_______       tt tze tpl tt weq tt tt weq tt a2 tt tze tpl
_______       tt weq tt tze tpl tt weq tt tt weq wim tt a2
_______       tt tze tpl tt tt a1 mp mp
_______     $.
verify ...................... 
verify:  stat_label =  th1
verify:  stat  =  ['|-', 't', '=', 't']
verify:  proof =  ['tt', 'tze', 'tpl', 'tt', 'weq', 'tt', 'tt', 'weq', 'tt', 'a2', 'tt', 'tze', 'tpl', 'tt', 'weq', 'tt', 'tze', 'tpl', 'tt', 'weq', 'tt', 'tt', 'weq', 'wim', 'tt', 'a2', 'tt', 'tze', 'tpl', 'tt', 'tt', 'a1', 'mp', 'mp']
_______
_______

---------------- METAMATH -----------------

Metamath - Version 0.196 31-Dec-2020          Type HELP for help, EXIT to exit.
MM> read min.mm
Reading source file "min.mm"... 1364 bytes
1364 bytes were read into the source buffer.
The source has 19 statements; 7 are $a and 1 are $p.
No errors were found.  However, proofs were not checked.  Type VERIFY PROOF *
if you want to check them.
MM> verify proof *
0 10%  20%  30%  40%  50%  60%  70%  80%  90% 100%
..................................................
All proofs in the database were verified in 0.00 s.
MM> exit

