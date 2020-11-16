# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;=============================================================================
# f_sort.tl 
# ;=============================================================================

# ;void sort_main_44 ();
# ;void sort_main_55 ();
# ;void sort_main_03 (int argc, char** argv, int j);

# ;=============================================================================

# (defclass T_SORTING (Bdata) (

# ;  Bdata  parent;

# ;  int  Num;
# ;  int *Array, *Sorts, *Orign;

#   (Num   :accessor NUM)
#   (Arrey :accessor ARREY)
#   (Sorts :accessor SORTS)
#   (Orign :accessor ORIGN)

# ;  int num_randoms, sorted, reversed;

#   (num_randoms :accessor NUM_RANDOMS)
#   (sorted      :accessor SORTED)
#   (reversed    :accessor REVERSED)

# ))

record define T_SORTING {

  NUM
  ARREY
  SORTS
  ORIGN  
  
  NUM_RANDOMS
  SORTED
  REVERSED  
}

# ;=============================================================================

# ;-----------------------------------------------------------------------------
# ;/* void */
# ;/* sorting_begin (void *s, long long1, long long2)  */
# ;/* { */
# ;/*   T_SORTING *sorting = (T_SORTING *) s; */

# ;/*   ai_initialize (sorting->Sorts, sorting->Num); */

# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;void 
# ;sort_check (int *Orign, int *Array, int *Sorts, int Num, 
# ;            char *message)
# ;-------------------------------------------------------------------------------
proc sort_check {Orign Arrey Sorts Num message} {

  #ai_print $Orign    
  #ai_print $Arrey     
  #ai_print $Sorts     

  # (let (
  # ;  // если хотя бы одни элемент массива не совпал, то G_FAILURE=-1
  set status  [ai_check_compare  $Arrey $Sorts $Num]
  #   )
  
  # ;  if (status == G_SUCCESS)  printf ("PASS: ");
  # ;  else                      printf ("FAIL: "); 
   
  if {$status == true}  {puts -nonewline  "PASS: "} \
  else                  {puts -nonewline  "FAIL: "}
  
  # ;  //printf ("%-*s  \n", NAMELENG, p_i->name);
  #   (format t "~s  ~%" message)
  #puts [format "%s  \n" $message]
  puts "$message"
  
  if {$status == false} {
    ai_print $Orign    
    ai_print $Arrey     
    ai_print $Sorts     
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_check_print (void *s, char *message)
# ;-------------------------------------------------------------------------------
proc sorting_check_print {s message} {

  # (let* (
  # ;  T_SORTING *sorting = (T_SORTING *) s; // делаем реальный указатель
  
  # ;  int    Num = sorting->Num;
  
  # ;  int *Array = sorting->Array; 
  # ;  int *Sorts = sorting->Sorts; 
  # ;  int *Orign = sorting->Orign; 
  #   )
  
  # ;  sort_check (Orign, Array, Sorts, Num, message);

  sort_check  [$s.ORIGN] [$s.ARREY] [$s.SORTS] [$s.NUM] $message
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_init (T_SORTING *sorting, char *name, int Num,
# ;              int num_randoms, int sorted, int reversed)
# ;-------------------------------------------------------------------------------
proc sorting_init {sorting name Num num_randoms sorted reversed} {


  # (declare (ignore name))
  # ;  //Bdata *bd = (Bdata*)sorting;
  
  # ;  //b_data_init (bd, name, midata_begin, midata_print_name, midata_check_print);
  # ;  //---------------------------------
  
  # ;  sorting->Num = Num;
  $sorting.NUM = $Num
  
  # ;  sorting->Array = (int *) malloc (Num * sizeof (int));
  # ;  sorting->Sorts = (int *) malloc (Num * sizeof (int));
  # ;  sorting->Orign = (int *) malloc (Num * sizeof (int));
  
  $sorting.ARREY = {} ;# (make-list Num))
  $sorting.SORTS = {} ;# (make-list Num))
  $sorting.ORIGN = {} ;# (make-list Num))
  
  # ;  sorting->num_randoms = num_randoms;
  # ;  sorting->sorted      = sorted;
  # ;  sorting->reversed    = reversed;
  
  $sorting.NUM_RANDOMS = $num_randoms
  $sorting.SORTED      = $sorted
  $sorting.REVERSED    = $reversed
  
}
# ;-------------------------------------------------------------------------------
# ;void *
# ;sorting_create (char *name, int Num,
# ;                int num_randoms, int sorted, int reversed) 
# ;-------------------------------------------------------------------------------
proc sorting_create {name Num num_randoms sorted reversed} {

  set s [T_SORTING #auto]
  
  sorting_init  $s $name $Num  $num_randoms $sorted $reversed
  
  # ;  return ((void*) s);
  return $s
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_end (/* T_SORTING *sorting */void *s) 
# ;{
# ;  T_SORTING *sorting = (T_SORTING *) s; // делаем реальный указатель

# ;  free (sorting->Sorts);
# ;  free (sorting->Orign);
# ;  free (sorting->Array);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------


# ;#define BOT_VAR   int message, void *m, long long1, long long2, long long3, double d1
# ;#define BOT_RETURN return (1)

# ;-------------------------------------------------------------------------------
# ;///////////////////////////////////////////////////////////////////////////////
# ;-------------------------------------------------------------------------------
# ;T_BOT_RETURN
# ;sortbot_common (/* int message, void *m, long long1, long long2 */BOT_VAR)
# ;-------------------------------------------------------------------------------
proc sortbot_common {message m long1 long2 long3 d1} {

  #puts "message = $message"
  #set ret {}

  # (declare (ignore long2 long3 d1))
  
  # (let (
  # ;  T_SORTPROG sortprog = (T_SORTPROG) m;
  
  # ;  int  *Array = (int*) long1;
  # ;  int   Num = long2;
  #   )
  
  # ;  switch (message) {
  # ;  case Y_BEG:
  # ;    break;
  # ;  case YTODO:
  # ;  sortprog (Array, Num); 
  
  #   (unless (= message Y_BEG)
  #     (funcall m long1) ;  
  #     )

  if {$message != "Y_BEG"} {
    set ret [$m $long1]
    #puts "sortbot_common: m = $m  logn1 = $long1  ret = $ret"
    return $ret
  }

  # ; *** - APPLY: too many arguments given to #<COMPILED-FUNCTION QSORT_AF>

  # ;    break;
  # ;  default:
  # ;    ;;;
  # ;  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sort_by_one_bot (YT_BOT *bot, T_SORTING *s, char *message)
# ;-------------------------------------------------------------------------------
proc sort_by_one_bot {bot s message} {
  
  #puts "sort_by_one_bot ..."

  # ;  ai_copy (s->Array, s->Orign, s->Num);     
  #   (ai_copy (ARREY s) (ORIGN s) (NUM s))
  $s.ARREY = [$s.ORIGN]
  
  # ;  YT_PROG lbot = (YT_PROG) bot->long3;
  
  # ;  bot->prog (YTODO, lbot, (long)(s->Array), s->Num, 0,0);

  #   (funcall (YPROG bot) YTODO (LONG3 bot) (ARREY s) (NUM s) 0 0)
  
  set ret [[$bot.YPROG] YTODO [$bot.LONG3] [$s.ARREY] [$s.NUM] 0 0]
  
  $s.ARREY = $ret

  sorting_check_print $s $message
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_set_result (YT_PLAYER *player, double t) 
# ;-------------------------------------------------------------------------------
proc sorting_set_result {player tval} { 

  #   ;(format t "1--- ~%")
  #   (setf (SUM player) tval) ;  player->sum  = tval; 

  $player.SUM = $tval
  
  #   (setf (INT1 player) (TO_COUNT))
  #   (setf (INT2 player) (LG_COUNT))
  #   (setf (INT3 player) (+ (TO_COUNT) (LG_COUNT)))
  
  $player.INT1 = [TO_COUNT]
  $player.INT2 = [LG_COUNT]
  $player.INT3 = [expr {[TO_COUNT] + [LG_COUNT]}]
  
  #   ;(format t "2--- ~%")
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_draw_line (YT_PLAYER *table, int i)
# ;-------------------------------------------------------------------------------
proc sorting_draw_line {players i} {

  # (let (
  #   tabl
  #   )
  
  #puts "sorting_draw_line: players = $players"

  #if {$i == 0} {}
  if {$players == "NUL"} {
    puts -nonewline " "
    puts -nonewline "   TO+LG   "
    puts -nonewline "    Time  "
    puts -nonewline "      TO  "
    puts -nonewline "      LG  "
    puts ""

  } else {

    # ;    printf (" %8d  " , table[i].int3); // TO+LG
    # ;    printf (" {%8.6f} ", table[i].sum);
    # ;    printf (" %8d "  , table[i].int1); // TO
    # ;    printf (" %8d "  , table[i].int2); // LG

    set pl [lindex $players $i]
    #puts "i= $i tabl= $tabl"
    
    #     (format t " ~7d  "    (INT3 tabl)) ; // TO+LG
    #     (format t " {~7,5f} " (SUM  tabl))
    #     (format t " ~7d "     (INT1 tabl)); // TO
    #     (format t " ~7d "     (INT2 tabl)); // LG

    puts -nonewline [format " %7d  "    [$pl.INT3]]  ;# // TO+LG
    puts -nonewline [format " {%7.5f} " [$pl.SUM]]
    puts -nonewline [format " %7d "     [$pl.INT1]]  ;# // TO
    puts -nonewline [format " %7d "     [$pl.INT2]]  ;# // LG

    puts ""
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_print_sort_results (Y_BOTTOP *top)
# ;-------------------------------------------------------------------------------
proc sorting_print_sort_results {top} {

  # ;  bottop_print_sort_results (top, SORT_MIN_MAX, /* SORT_0 */ SORT_3, sorting_draw_line);
  #   (bottop_print_sort_results  top  SORT_MIN_MAX  SORT_3  'sorting_draw_line)

  bottop_print_sort_results  $top  SORT_MIN_MAX  SORT_3  "sorting_draw_line"

}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_calc_data (void *t, /* YT_BOT* bot */void *p) 
# ;-------------------------------------------------------------------------------
# ;(defun sorting_calc_data (tval  p) 
proc sorting_calc_data {top  bot} { 

  # (let* (
  #   ;(top tval) ;  Y_BOTTOP *top = (Y_BOTTOP *) t;
  #   ;(bot p)    ;  YT_BOT* bot = (YT_BOT *) p;
  
  # ;  T_SORTING *sorting = (T_SORTING *) top->dat; // делаем реальный указатель
  #   (sorting (DAT top))
  set sorting [$top.DAT]
  
  #   Num Sorts Orign num_randoms sorted reversed 
  #   )
  
  #   ;(format t "..... ~s ~%" (YPROG bot))
  # ;  bot->prog (Y_BEG, sorting, bot->long1, bot->long2, 0,0);
  #   (funcall (YPROG bot) Y_BEG sorting (LONG1 bot) (LONG2 bot) 0 0) 

  [$bot.YPROG] Y_BEG $sorting [$bot.LONG1] [$bot.LONG2] 0 0
  
  # ;  //sorting_begin (sorting, 0,0);
  #ai_initialize [$sorting.SORTS] [$sorting.NUM]

  set Num [$sorting.NUM]
  $sorting.SORTS = [ai_initialize_new $Num]
  
  #puts "sorting.SORTS = [$sorting.SORTS]"
  #exit
  # ;  //------------------------------ 
  
  #   (setf Num (Num sorting))
  # ;  //int *Array = sorting->Array; 

  #   (setf Sorts (SORTS sorting)) 
  #   (setf Orign (ORIGN sorting)) 
  
  #set Sorts [$sorting.SORTS]
  #set Orign [$sorting.ORIGN]

  # ;  //int num_randoms = data_bot->long2;

  set num_randoms [$sorting.NUM_RANDOMS]
  set sorted      [$sorting.SORTED]
  set reversed    [$sorting.REVERSED]
  
  #puts "num_randoms = $num_randoms"
  #puts "sorted      = $sorted"
  #puts "reversed    = $reversed"

  TO_RESET
  LG_RESET
  
  # ;  // будем сортировать случайные наборы
  #   (when  (> num_randoms 0) 
  
  #dotimes {$n $num_randoms} {}
  for {set n 0} {$n < $num_randoms} {incr n} {
    puts "n = $n"
    #       (ai_copy Orign Sorts Num)
    #set Orign $Sorts
    #       (ai_randomize Orign Num)   ;    /* Perform some shuffling */  
    #       (sort_by_one_bot bot sorting "....")
    #       )
  }
  
  # ;  // будем сортировать уже отсортированные
  #   (when (> sorted 0) 
  #     (ai_copy  Orign Sorts Num)       
  #     (sort_by_one_bot  bot sorting "--->")
  #     )
  
  # ;  // теперь попробуем уже отсортированные в обратном порядке
  if  {$reversed >  0} {
    #     (ai_copy  Orign Sorts Num)       
    #set Orign $Sorts
    #     (ai_reverse Orign Num)  
    #set Orign [ai_reverse_new $Orign]
    #set Orign [lreverse $Orign]

    $sorting.ORIGN = [lreverse [$sorting.SORTS]]

    #ai_print $Orign     
    #ai_print $Sorts  
   
    sort_by_one_bot  $bot $sorting "<---"
  }
  
  # ;  //----------------------------
  # ;  //sorting_end (s); 
  
}
# ;-------------------------------------------------------------------------------
# ;/* void  */
# ;/* sortbot_print_name (void *s) */
# ;/* { */
# ;/*   YT_BOT *bot = (YT_BOT *) s; */

# ;/*   printf ("%s ", b_prog_get_name ((Bprog *) bot));  */

# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;/* Y_BOTTOP * */
# ;/* sort_bottop_create_old ()  */
# ;/* { */

# ;/*   Y_BOTTOP *top = bottop_create (20); */

# ;/*   YT_PROG sbot = sortbot_common; */

# ;/*   bottop_add_bot (top, "bubblesort"       , sbot, 0,0,  (long) bubblesort,       0); */
# ;/*   bottop_add_bot (top, "shakersort"       , sbot, 0,0,  (long) shakersort,       0); */
# ;/*   bottop_add_bot (top, "s_insertion_swap" , sbot, 0,0,  (long) s_insertion_swap, 0); */
# ;/*   bottop_add_bot (top, "s_insertion_take" , sbot, 0,0,  (long) s_insertion_take, 0); */
# ;/*   bottop_add_bot (top, "s_selection"      , sbot, 0,0,  (long) s_selection,      0); */
# ;/*   bottop_add_bot (top, "shellsort_AF"     , sbot, 0,0,  (long) shellsort_AF,     0); */
# ;/*   bottop_add_bot (top, "qsort_AF"         , sbot, 0,0,  (long) qsort_AF,         0); */
  

# ;/*   return (top); */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;Y_BOTTOP *
# ;sort_bottop_create () 
# ;-------------------------------------------------------------------------------
proc sort_bottop_create {} { 

  # (let (
  # ;  Y_BOTTOP *top = bottop_create (20);
  set top [bottop_create 20]
  
  # ;  YT_PROG sbot = sortbot_common;
  set sbot "sortbot_common"
  #   )
  
  
  # ;  bottop_add_player (top, "bubblesort", bot_make (sbot, 0,0, (long) bubblesort,  0));
  # ;  bottop_add_player (top, "shakersort", bot_make (sbot, 0,0, (long) shakersort,  0));
  
  # ;  bottop_add_player (top, "s_insertion_swap" ,
  # ;                     bot_make (sbot, 0,0,  (long) s_insertion_swap, 0));
  # ;  bottop_add_player (top, "s_insertion_take" ,
  # ;                  bot_make (sbot, 0,0,  (long) s_insertion_take, 0));
  # ;  bottop_add_player (top, "s_selection"      ,
  # ;                  bot_make (sbot, 0,0,  (long) s_selection,      0));
  # ;  bottop_add_player (top, "shellsort_AF"     ,
  # ;                  bot_make (sbot, 0,0,  (long) shellsort_AF,     0));
  
  # ;  bottop_add_player (top, "qsort_AF"         ,
  # ;                  bot_make (sbot, 0,0,  (long) qsort_AF,         0));
  
  bottop_add_player  $top "qsort_AF" [bot_make $sbot 0 0 "qsort_AF" 0]
  
  # ;  //bottop_add_bot (top, "heapsort_gsl", heapsort_gsl);
  # ;  //bottop_add_bot (top, "qsort_unix" , qsort_unix);
  
  return $top
}
# ;-------------------------------------------------------------------------------
# (defun sort_main_44 (argus)  (declare (ignore argus))

# (let* (
# ;  Y_BOTTOP *top = sort_bottop_create (); 
#   (top (sort_bottop_create))

#   (Orign '(44 55 12 42 94 18  6 67))
#   (Sorts '( 6 12 18 42 44 55 67 94))

# ;  int Num = sizeof (Orign)/sizeof (Orign[0]);
#   (Num (list-length Orign))
# ;  int  i;

# ;  T_SORTING *s = sorting_create ("", Num, 0,0,0);
#   (s  (sorting_create "" Num 0 0 0))
#   )

#   (setf (ORIGN s) Orign) ;  s->Orign = Orign;
#   (setf (SORTS s) Sorts) ;  s->Sorts = Sorts;
#   (setf (DAT top) s) ;  top->dat = s;

# ;  for (i = 1; i <= top->num_players; i++) {
#   (loop for i from 1 to (NUM_PLAYERS top) do
# ;    sort_by_one_bot (IGROK(i)->bot, s, "");
#     (sort_by_one_bot (BOT (IGROK i)) s "")
#     )

#   (format t "~%")

# ))
# ;===============================================================================
# ;void 
# ;sort_bottop_init_03 (Y_BOTTOP *top, int argc, char** argv,  int j)
# ;-------------------------------------------------------------------------------
proc sort_bottop_init_03 {top} {

  # ;e~test sort 100 - 2 1 1
  
  # (let* (
  #   sorting
  # ;  int  Num, num_randoms, sorted, reversed;
  
  set Num  10 ;#  Num  = atoi (argv[j++]); // 100
  #   ;(flag '-)  ;  char *flag = argv[j++];  // - 
  
  # ;  if (!strcmp (flag, "+")) BOTPRINT = TRUE;
  # ;  else                     BOTPRINT = FALSE;
  
  set num_randoms 0 ;#  num_randoms = atoi (argv[j++]); // 2
  set sorted      0 ;#  sorted      = atoi (argv[j++]); // 1
  set reversed    1 ;#  reversed    = atoi (argv[j++]); // 1
  #   )
  
  #   (bottop_init  top 0 ;/* SRAND_TIME */
  #                'sorting_set_result 'sorting_print_sort_results

  #                NUL NUL NUL 
  #                NUL NUL NUL
  
  #                'sorting_calc_data 
  #                )
  
  bottop_init  $top 0 \
                  "sorting_set_result" "sorting_print_sort_results" \
                  \
                  NUL NUL NUL \
                  NUL NUL NUL \
                  \
                  "sorting_calc_data" 
                  
  
  # ;  T_SORTING *sorting = sorting_create ("MIXEDSORT", Num, 
  # ;                                       num_randoms,sorted,reversed);
  # ;  top->dat = sorting;
  
  set sorting [sorting_create "MIXEDSORT" $Num \
                 $num_randoms $sorted $reversed]

  #   (setf (DAT top) sorting)
  $top.DAT = $sorting
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sort_main_03 (int argc, char** argv, int j)
# ;-------------------------------------------------------------------------------
proc sort_main_03 {} {

  # (let (
  # ;  Y_BOTTOP *top = sort_bottop_create (); 
  #   (top  (sort_bottop_create))
  #   )
  
  set top [sort_bottop_create] 

  # ;  sort_bottop_init_03 (top, argc, argv,  j);
  #   (sort_bottop_init_03  top)
  
  sort_bottop_init_03  $top
  
  bottop_prog_data  $top
  
}
# ;===============================================================================

