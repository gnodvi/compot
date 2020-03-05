// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*----------------------------------------------------------------------------*/
/* file: main.c */
/*----------------------------------------------------------------------------*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <setjmp.h>
#include <time.h>

#include <unistd.h>


#define ALLOC
/* #define DEBUG */

/*----------------------------------------------------------------------------*/

#include "j-comm_.h"
#include "j-glob_.h"

/*----------------------------------------------------------------------------*/
void 
enterglobal ()
{

  location = symtabindex++;
  D (printf ("getsym, new: '%s'\n", id));

  location->name = (char *) malloc(strlen(id) + 1);
  strcpy (location->name,id);

  location->u.body = NULL; /* may be assigned in definition */
  location->next = hashentry[hashvalue];

  D (printf ("entered %s at %ld\n", id, LOC2INT(location)));
  hashentry[hashvalue] = location;

  return;
}
/*----------------------------------------------------------------------------*/
void 
lookup (void)
{
  int i;
  D (printf ("%s  hashes to %d\n", id, hashvalue));

  for (i = display_lookup; i > 0; --i) { 
    location = display[i];

    while (location != NULL && strcmp(id,location->name) != 0)
      location = location->next;
    if (location != NULL) /* found in local table */
      return; 
  }

  location = hashentry[hashvalue];

  while (location != symtab && strcmp(id,location->name) != 0)
    location = location->next;

  if (location == symtab) /* not found, enter in global */
    enterglobal();

  return;
}
/*----------------------------------------------------------------------------*/
void 
enteratom ()
{

  if (display_enter > 0) { 

    location = symtabindex++;

    D (printf ("hidden definition '%s' at %ld \n", id, LOC2INT(location)));

    location->name = (char *) malloc (strlen(id) + 1);
    strcpy (location->name, id);
    location->u.body = NULL; /* may be assigned later */
    location->next   = display[display_enter];
    display[display_enter] = location; 
  }
  else 
    lookup();

  return;
}
/*----------------------------------------------------------------------------*/

void defsequence();		/* forward */
void compound_def();		/* forward */

/*----------------------------------------------------------------------------*/
void 
definition ()
{

  Entry *here = NULL;

  if (sym == LIBRA || sym == JPRIVATE || sym == HIDE || sym == MODULE) { 
    compound_def ();
    if (sym == END || sym == PERIOD) getsym ();
    else error (" END or period '.' expected in compound definition");
    return; 
  }

  if (sym != ATOM)
    /*   NOW ALLOW EMPTY DEFINITION:
      { error("atom expected at start of definition");
      abortexecution_(); }
      */
    return;

  /* sym == ATOM : */
  enteratom ();
  if (location < firstlibra) { 
    printf ("warning: overwriting inbuilt '%s'\n", location->name);
    enterglobal (); 
  }

  here = location;  getsym ();
  if (sym == EQDEF) getsym ();
  else 
    error (" == expected in definition");

  readterm ();

  D (printf("assigned this body: "));
  D (writeterm(stk->u.lis, stdout));
  D (printf("\n"));

  if (here != NULL) { 
    here->u.body = stk->u.lis; here->is_module = 0; 
  }

  stk = stk->next;

  return;
}
/*----------------------------------------------------------------------------*/
void 
defsequence ()
{
  definition ();

  while (sym == SEMICOL) { 
    getsym (); 
    definition (); 
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
compound_def ()
{

  switch (sym) { 

  case MODULE :
  { 
    Entry *here = NULL;
    getsym();

    if (sym != ATOM) { 
      error ("atom expected as name of module");
      abortexecution_(); 
    }

    enteratom (); 
    here = location; getsym();

    ++display_enter; ++display_lookup;

    display[display_enter] = NULL;
    compound_def ();
    here->is_module = 1;
    here->u.module_fields = display[display_enter];

    --display_enter; --display_lookup;
    break; 
  }

  case JPRIVATE : 
  case HIDE :
  { 
    getsym ();
    if (display_lookup > display_enter) {
      /* already inside module or hide */
      Entry *oldplace = display[display_lookup];
      /*
        printf("lookup = %d\n",LOC2INT(display[display_lookup]));
        printf("enter = %d\n",LOC2INT(display[display_enter]));
        */
      ++display_enter;
      defsequence ();
      --display_enter;
      /*
        printf("lookup = %d\n",LOC2INT(display[display_lookup]));
        printf("enter = %d\n",LOC2INT(display[display_enter]));
        */
      compound_def ();
      display[display_lookup] = oldplace;
    }
    else { 
      ++display_enter; ++display_lookup;
      display[display_enter] = NULL;
      defsequence ();
      --display_enter;
      compound_def ();
      --display_lookup; 
    }
    break; 
  }

  case JPUBLIC : 
  case LIBRA : 
  case IN : { 
    getsym ();
    defsequence ();
    break; 
  }

  default :
    printf ("warning: empty compound definition\n"); 
  }

  return;
}
/*----------------------------------------------------------------------------*/

jmp_buf begin;
//jmp_buf fail;

/*----------------------------------------------------------------------------*/
void 
abortexecution_ (void)
{

  conts = dump = dump1 = dump2 = dump3 = dump4 = dump5 = NULL;

  printf ("!!................ abortexecution_ ............... \n");

  longjmp (begin, 0); // переходим куда? в начало главного цикла?

  return;
}
/*----------------------------------------------------------------------------*/
// void 
// fail_ (void)
// {
//   longjmp (fail, 1);

//   return;
// }
/*----------------------------------------------------------------------------*/
void 
execerror (char *message, char *op)
{

  printf ("run time error: %s needed for %s\n", message, op);

  abortexecution_ ();

  return;
}
/*----------------------------------------------------------------------------*/

static int quit_quiet = 1;
/* was = 0;  but anything with "clock" needs revision */

/*----------------------------------------------------------------------------*/
void 
quit_ (void)
{
  long totaltime;

  if (quit_quiet) 
    exit (0);

  totaltime = clock () - startclock;

#ifdef GC_BDW
  printf ("Time:  %ld CPU\n", totaltime);
#else
  printf ("time:  %ld CPU,  %d gc (= %ld%%)\n",
          totaltime, gc_clock,
          totaltime ? (1004*gc_clock)/(10*totaltime) : 0);
#endif

  exit (0);
}
/*----------------------------------------------------------------------------*/
//static int mustinclude = 1;

#define CHECK(D, NAME)						\
    if (D)							\
      { printf("->  %s is not empty:\n",NAME);			\
	writeterm(D, stdout); printf("\n"); }

/*----------------------------------------------------------------------------*/
FILE * 
joy_get_srcfile (int argc, char **argv)
{

  FILE *srcfile;

  g_argc = argc; // это чего такое? глабальные переменные?
  g_argv = argv;

  /*--------------------------------*/
  if (argc > 1) {

    g_argc--; 
    g_argv++;

    char *fname = argv[1]; 

    // если вторым параметром указана рабочая папка, то перейдем туда
    if (argc == 3) {

      char *work_dir = argv[2]; 
      chdir (work_dir); // а еслb такой нет? просто не отработает?!
    }

    srcfile = fopen (fname, "r");
    if (!srcfile) { 

      // сделаем еще попытку найти файл:
      // вообще-то это так просто не поможет, поскольку include-JOY-файлы
      // все равно не находятся...
      // 
      //char buffer[200];
      //strcpy (buffer, "./L/");
      //strcat (buffer, fname);
      ////printf ("FNAME = %s \n", buffer);
      //fname = buffer;

      //srcfile = fopen (fname, "r");
      //if (!srcfile) { 

      printf ("failed to open the file '%s'.\n", fname);
      exit (1);
      //}
    }

  /*--------------------------------*/
  } else {

    /* если не указан входной файл (srcfile) , то  читать из входного потока ?? */
    srcfile = stdin; 

#ifdef GC_BDW
    printf ("JOY  -  compiled at %s on %s (BDW)\n",   __TIME__ , __DATE__);
#else
    printf ("JOY  -  compiled at %s on %s (NOBDW)\n", __TIME__ , __DATE__);
#endif
    printf ("Copyright 2001 by Manfred von Thun\n"); 
  }


  return (srcfile);
}
/*----------------------------------------------------------------------------*/
int
joy_init ()
{

  int ch;

  startclock = clock ();
  gc_clock   = 0;

  echoflag   = INIECHOFLAG;
  tracegc    = INITRACEGC;
  autoput    = INIAUTOPUT;

  ch = ' ';

  //inilinebuffer  (); // здесь запоминаем srcfile !!!
  inisymboltable ();

  display[0] = NULL;

  inimem1 (); 
  inimem2 ();


  return (ch);
}
/*----------------------------------------------------------------------------*/
CLASS Node *
check_autoput (CLASS Node *stk)
{

  if      (autoput == 2 && stk != NULL) {
 
    //fprintf (stderr, "autoput == 2 \n");
    writeterm (stk, stdout); //  печатаем одни "символ"?
    printf("\n"); 

  } 
  else if (autoput == 1 && stk != NULL) {
 
    //fprintf (stderr, "autoput == 1 \n");
    writefactor (stk, stdout); 
    printf("\n"); 
    stk = stk->next; // передвинули указатель, т.е. "убрали" верхний?

  } 

  return (stk);
}
/*----------------------------------------------------------------------------*/
void 
print_sym ()
{

  char *name = "NOT FOUND";

  // #define ILLEGAL_	           0
  // #define COPIED_		   1
  // #define USR_		   2
  // #define ANON_FUNCT_ 	   3
  // #define BOOLEAN_	           4
  // #define CHAR_	           5
  // #define INTEGER_	           6
  // #define SET_	           7
  // #define STRING_	           8
  // #define LIST_	           9
  // #define FLOAT_	          10
  // #define FILE_	          11
  
  // #define LBRACK		 900
  // #define LBRACE		 901
  // #define LPAREN		 902
  // #define ATOM	 	 999	/* last legal factor begin */
  
  // #define RBRACK		1001
  // #define RPAREN		1003
  // #define RBRACE		1005
  // #define PERIOD		1006
  // #define SEMICOL		1007
  // #define LIBRA		1100
  // #define EQDEF		1101
  // #define HIDE		1102
  // #define IN		1103
  // #define END		1104
  // #define MODULE		1105
  // #define JPRIVATE	1106
  // #define JPUBLIC		1107
  

  switch (sym) { // глобальная переменная ((
    
  case INTEGER_: name = "INTEGER_";  break;
  case     ATOM: name = "ATOM";  break;

    //default:
    //  printf ("sym (not found) = %d \n \n ", sym);
    //  return;
  }

  printf ("sym = %s (%d) \n\n", name, sym);


  return;
}
/*----------------------------------------------------------------------------*/
void 
main_run (FILE *srcfile)
{

  inilinebuffer (srcfile); // здесь запоминаем srcfile !!!


  //  set r_text_all [read_file_to_rtext             $fname]
  //  # здесь уже есть полностью готовый текст программы в одной строке

  //if (mustinclude) { 
  //  mustinclude = 0; // только в самом начале?  

  if (fopen ("usrlib.joy", "r"))  doinclude ("usrlib.joy"); 
  //}
   

  D_ (printf ("\n"); printf ("starting main loop ------ \n \n"));

  /* --------------------------------------- */
  // setjmp,  sigsetjmp  -  save stack context for non-local goto
  // longjmp, siglongjmp -  non-local jump to a saved stack context

  setjmp (begin); // возвращаемое значение не важно 
  //setjmp (fail);

  // сюда возвращаемся после longjmp (begin, 0) !! а зачем ?
  // видимо в попытке продолжить выполнение, пропустив уже проблемную
  // команду ? т.е. указатель на след. команду сохраняется?
  // 
  /* --------------------------------------- */


  while (1) { 

    D_ (printf ("......................... \n");)

    //---------------------------------------------------
    getsym (); // читаем из входного потока "атомы" ->
               // ch, sym, num, dbl, id[], hashvalue

    //D_ (printf ("SYM = %d \n", sym))
    D_ (print_sym ();)

    //---------------------------------------------------

    if (sym == LIBRA || sym == HIDE || sym == MODULE ) { 

      inimem1 ();
      compound_def ();
      inimem2 (); 

    } else {
 
    //---------------------------------------------------

      readterm ();

      D_ (printf ("program is: "); writeterm (stk->u.lis, stdout); printf ("\n"));


      prog  = stk->u.lis;
      stk   = stk->next;
      conts = NULL;

      exeterm (prog);


      if (conts || dump || dump1 || dump2 || dump3 || dump4 || dump5) { 

        printf ("the dumps are not empty\n");
        CHECK (conts, "conts");
        CHECK (dump,   "dump"); CHECK (dump1, "dump1");
        CHECK (dump2, "dump2"); CHECK (dump3, "dump3");
        CHECK (dump4, "dump4"); CHECK (dump5, "dump5"); 
      }

      stk = check_autoput (stk);

    }
    //---------------------------------------------------


    if (sym != END && sym != PERIOD)
      error (" END or period '.' expected"); 

  } /* while (1) */



  D_ (printf ("\n")); // не доходит сюда..
  //
  printf ("!! ................. END ..................... \n");

  return;
}
/*----------------------------------------------------------------------------*/

int is_print = 0;

int is_from_stream = 1;

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
void 
read_file_i__00 ()
{

  srcfile = fopen ("j__00.joy", "r");

  if (!srcfile) {
 
    printf ("failed to open SRCFILE \n");
    return;
  }
  
  main_run (srcfile);
 
  return;
}
/*----------------------------------------------------------------------------*/
void 
r (char *p)
{

  gena_make_test_linbuf (p);
   
  getsym (); // т.е. сначала первый "символ" читаем
  
  //print_sym ();
  
  readterm (); // а потом остальные в строке ?
  
  //printf ("program is: ");  writeterm (stk->u.lis, stdout);   printf ("\n");
  //printf ("\n");
  

  prog  = stk->u.lis;
  stk   = stk->next;
  conts = NULL;
  
  exeterm (prog);
    
  // обрабатываем последнюю точку в предложении
  // 
  //fprintf (stderr, "!!!!!!!!!!!!!!!! \n"); 

  stk = check_autoput (stk); // почему не печатает "точка" ?

  //fprintf (stderr, "???????????????? \n"); 

  return;
}
// #-------------------------------------------------------------------------------
// #
// #-------------------------------------------------------------------------------
// proc p_init_all_operators {} {


//   proc 2op op {
    
//     set t [pop]  
//     push [expr {[pop]} $op {$t}]
//   }

//   # functionality is exposed for binary operators and one-arg functions:
//   #
//   foreach op {+ - * / > >= != <= <} {

//     : $op [list 2op $op] tcl
//   }
  
//   # здесь не создаются "реальные" процедуры TCL, а пока только заготовки,
//   # которые в дальнейшем будут интерпретироваться!

//   : =  {2op ==} tcl
  
//   #--------------------------------------------------------------
  
//   proc 1f  f {push [expr $f ([pop])]}
  
//   foreach f {abs double exp int sqrt sin cos acos tan} {: $f [list 1f $f] tcl}
  
//   #--------------------------------------------------------------
//   # The "dictionary" has all one-liners:
  
//   : .       {pn "[pop] "}                        tcl
//   : .s      {puts $::ST}                         tcl
  
//   : '       {push [scan [pop] %c]}               tcl  ;# char -> int
//   : `       {push [format %c [pop]]}             tcl  ;# int -> char
//   : and     {2op &&}                             tcl
//   : at      1 - swap {push [lindex [pop] [pop]]} tcl

//   : c       {set ::ST {}}                  tcl ;# clear stack
//   : choice  {choice [pop] [pop] [pop]}     tcl
//   : cleave  {cleave [pop] [pop] [pop]}     tcl
//   : cons    {push [linsert [pop] 0 [pop]]} tcl
//   : dup     {push [set x [pop]] $x}        tcl
//   : dupd    {push [lindex $::ST end-1]}    tcl
//   : emit    {pn [format %c [pop]]}         tcl
//   : explode {push [split [pop] ""]}        tcl  ;# string -> char list
//   : first   {push [lindex [pop] 0]}        tcl
//   : fold    {rfold [pop] [pop] [pop]}      tcl
//   : i       {eval r [pop]}                 tcl
//   : ifte    {rifte [pop] [pop] [pop]}      tcl
//   : implode {push [join [pop] ""]}         tcl ;# char list -> string
//   : in      {push [lsearch [pop] [pop]]}   tcl 0 >=
//   : map     {rmap [pop] [pop]}             tcl
//   : max     {push [max [pop] [pop]]}       tcl
//   : min     {push [min [pop] [pop]]}       tcl
//   : not     {1f !}                         tcl
//   : or      {2op ||}                       tcl
//   : pop     (pop)                          tcl
//   : primrec {primrec [pop] [pop] [pop]}    tcl
//   : qsort   (lsort)                        tcl
//   : qsort1  {lsort -index 0}               tcl
//   : rem     {2op %}                        tcl
//   : rest    {push [lrange [pop] 1 end]}    tcl
//   : set     {set ::[pop] [pop]}            tcl
//   : $       {push [set ::[pop]]}           tcl
//   : size    {push [llength [pop]]}         tcl
//   : split   {rsplit [pop] [pop]}           tcl
//   : step    {step [pop] [pop]}             tcl
//   : swap    {push [pop] [pop]}             tcl

//   #--------------------------------------------------------------
  
//   : gcd     swap {0 >} {swap dupd rem swap gcd} (pop) ifte
//   : even    odd not
//   : fact  1 (*) primrec
//   : filter  split swap pop
//   : has  swap in
//   : newstack  c
//   : odd  2 rem
//   : of  swap at
//   : pred 1 -
//   : product 1 (*) fold
//   : reverse {} swap (swons) step
//   : sign  {0 >}  {0 <} cleave -
//   : succ  1 +
//   : sum   0 (+) fold
//   : swons  swap cons
//   : xor  !=

//   #--------------------------------------------------------------
  
//   # TODO: выделить самые простые операции, через которые можно 
//   # определить остальные!


//   #--------------------------------------------------------------

//   return
// }
//#-------------------------------------------------------------------------------
//proc p_init {} {

//  #set ::stack {} 
//  p_init_all_operators ;# инициализируем основные процедуры (команды)

 
//  set ::ST {}  ;# зануляем стек 

//  set ::BEG "BEG"
//  set ::END "END"

//  : ^     {puts "    = [pop]"} tcl ;# надо ли здесь так хитро?
//  : nop   ;# пустышка
  
//  : joy_concat {push [concat [pop] [pop]]} tcl
  

//}
//#-------------------------------------------------------------------------------
void
TEST_list () {

  
  fprintf (stderr, "\n");
  fprintf (stderr, "........ TEST_list .. \n");
  fprintf (stderr, "\n");
  
  is_from_stream = 0; // у нас нет входного потока !!

  //  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  p_init ;# newstack
  
  //  r c {1 2}     .s 
  r ("[ 1 2 ] .");
  
  //  r c  {1 2} .s  i  .s
  //  r c  (3)   .s  i  .s
  
   //  p_init ;# newstack - нужна очистка и печать всего стека !

  r ("[ 1 2 ] i .");


  //  r c {1 2 +} i .s  ;# правильно раскрывает скобки и выполняет  
  
  //  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  puts ""
  //  p_init    
  
  //  set prg_1 {   {1 {2 3}}  dup }
  //  run_prg   $prg_1 
  //  r  .s 
  r (" [1 [2 3]] dup . . ."); // - нет функции dup ?
  
  //  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  //  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //  #puts ""

  printf ("\n");

  return;
}
/*----------------------------------------------------------------------------*/
void 
TEST_simp (/* int argc, char **argv */)
{

  //fprintf (stderr, "\n");
  //fprintf (stderr, "........ TEST_simp ... \n");
  fprintf (stderr, "\n");
  
  is_from_stream = 0; // у нас нет входного потока !!
  //is_print = 0;
  

  // p_init    ;# newstack
  
  r ("1 2 + .");
  r ("2 3 + .");
  r ("2 3 * .");
  
  printf ("\n");


  r ("3 2 1   .");
  r (        ".");
  r (        ".");

  r (        "."); // уже нет там ничего


  printf ("\n");

  r (" [1 2]   . ");
  r (" [1 2] i . "); 
  r ("         . "); // хорошо бы  сразу весь стек печатать !!

  printf ("\n");

  r ("  [3]    . "); // .s  ;# ?? т.е. в стеке уже не квотированный? разве это правильно?
  r ("  [3]  i . ");

  printf ("\n");


  r ("[ 2 3 + ] i .");

  //r ("nop 1 2 + ."); // - сработало? nop - ?


  //puts "" ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //r c BEG 1 2 END  ^
  //r c BEG 1 2 END      .s 
  //r c BEG 1 2 END  dup .s 

  //puts ""
  //printf ("\n");

  //r c {   1 2   }      .s 
  //r c {   1 2   }  dup .s 


  //r ("99   dup  . . ");       // - нет функции dup ?
  // r ("[ 1 2 ]  dup .");

  printf ("\n");

  return;
}
//#-------------------------------------------------------------------------------
//#
//*----------------------------------------------------------------------------*/
int 
main (int argc, char **argv)
{

  FILE *srcfile;

  //ch = 
  joy_init ();


  //int test_num   = 0;

  char buf[80];
  strcpy (buf, "");

  get_options_NVU (argc, argv,  
                   buf,        // -b
                   /* &test_num */NULL,  // -t
                   NULL, NULL);


  if      (! strcmp (buf, "TEST_list"))   TEST_list ();
  else if (! strcmp (buf, "TEST_simp"))   TEST_simp ();
  //else if (! strcmp (buf, "TEST_00"))     TEST_00 ();
  else if (! strcmp (buf, "TEST_file"))   read_file_i__00 ();

  else {
  
    srcfile = joy_get_srcfile (argc, argv); // читаем (папку) имя файла
    main_run (srcfile);
  }
  
  
  
  
  return (0); // Tcl's exec treats any non-zero exit status as an exceptional 
  // situation. 
}
/*----------------------------------------------------------------------------*/

// i_main -b TEST_00

/*----------------------------------------------------------------------------*/
