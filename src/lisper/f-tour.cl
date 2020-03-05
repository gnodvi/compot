; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
; *                                                                            *
; *  Имя этого файла: e_tour.c                                                 *
; *                                                                            *
;===============================================================================
                                                                            
;#include "a_comm.h"

;#include "e_tabs.h"
;#include "e_tour.h"

;===============================================================================

(defconstant  fw 4) ;#define fw         4       /* field width for printed numbers */

;typedef int (*YT_GAME_FUNC) (/* YT_PROG prog1, YT_PROG prog2, */ void *bot1, void *bot2);

(defclass YT_TURNIR () (
;  Y_BOTTOP   *bottop;
  (bottop :accessor BOTTOP)

;  YT_GAME_FUNC play_game;
;  YT_BOOL is_double_play;
  (play_game      :accessor PLAY_GAME)
  (is_double_play :accessor IS_DOUBLE_PLAY)

))

(defconstant GAME_WIN  102)
(defconstant GAME_DRA  101)
(defconstant GAME_LOS  100)

;// -----------------------------------

;typedef struct {
;  char *name;
;  int   place;
;  int   d[10];
;} YT_RESULTS;

;===============================================================================

;-------------------------------------------------------------------------------
;YT_TURNIR* 
;turnir_create (int max_players, YT_GAME_FUNC play_game, YT_BOOL is_double_play)
;-------------------------------------------------------------------------------
(defun turnir_create (max_players play_game is_double_play)

(let (
;  YT_TURNIR *tur = (YT_TURNIR*) malloc (sizeof (YT_TURNIR));
  (tur (make-instance 'YT_TURNIR))
  )
  
;  tur->bottop = bottop_create (max_players);
  (setf (BOTTOP tur)  (bottop_create max_players))

;  tur->play_game = play_game;
;  tur->is_double_play = is_double_play;
  (setf (PLAY_GAME tur)      play_game)
  (setf (IS_DOUBLE_PLAY tur) is_double_play)

  tur
))
;-------------------------------------------------------------------------------
;void 
;turnir_add_player (YT_TURNIR *tur, char *name, void *bot)
;-------------------------------------------------------------------------------
(defun turnir_add_player (tur name bot)

  (bottop_add_player (BOTTOP tur) name bot)

)
;-------------------------------------------------------------------------------
;void 
;turnir_init (YT_TURNIR *tur, int seed)
;-------------------------------------------------------------------------------
(defun turnir_init (tur seed)


  (bottop_init (BOTTOP tur) seed NUL NUL
               NUL NUL NUL  NUL NUL NUL  NUL)

)
;-------------------------------------------------------------------------------
;void 
;turnir_draw_line (YT_PLAYER *table, int i)
;-------------------------------------------------------------------------------
(defun turnir_draw_line (table i)

(let (
  tabl
  )

  (if (= i 0) 
      (progn 
        (format t "   total    +   =   - ")
        (format t "~%")
      )
      (progn 
        (setf tabl (nth i table))

;    printf (" %*d ", fw+2, (int)(table[i].sum));
;    printf ("   %3d %3d %3d ", table[i].int1, table[i].int2, table[i].int3);
        ;(format t "          ~s " (SUM tabl))
        (format t " ~6d " (SUM tabl))
        (format t "   ~3s ~3s ~3s " (INT1 tabl) (INT2 tabl) (INT3 tabl))

        (format t "~%")
        )
      )

))
;-------------------------------------------------------------------------------
;void 
;turnir_play (YT_TURNIR *tur, YT_BOOL is_double_play)
;-------------------------------------------------------------------------------
(defun turnir_play (tur is_double_play)

(let* (
  (top (BOTTOP tur))          ;  Y_BOTTOP *top = tur->bottop;
  (players (NUM_PLAYERS top)) ;  int players = top->num_players;
  signum                      ;  char signum;

  j0 result                   ;  int  i, j, j0, result;
  p_i  p_j                      ;  YT_PLAYER  *pi, *pj;
  bi  bj                      ;  YT_BOT     *bi,  *bj; //!!!! новое 
  )

  ;; надо прeдваритeльно занулить суммы
  (loop for i from 1 to players do
    (setf p_i (nth i (TT top)))
    (setf (SUM p_i) 0) 
    )
    
  ;; а тeпeрь ужe рeальный пeрeбор .........
  (loop for i from 1 to players do

    (setf p_i (nth i (TT top))) ; pi = &((top->t)[i]);
    (setf bi (BOT p_i))         ; bi = (YT_BOT *)(pi->bot);

    ;(when (eq is_double_play t) (setf j0  1)
    (if is_double_play (setf j0  1)
                       (setf j0  (+ i 1))
                       )

;    printf (" %2d %-*s ", i, NAMELENG, pi->name);
;    (format t " ~2d ~s " i (NAME p_i))
    (format t " ~2d ~18a " i (PLAYER_NAME p_i))

    ;;  // ------------------------------
    (loop for j from j0 to players do 

      (setf p_j (nth j (TT top)))  ;  pj = &((top->t)[j]);
      (setf bj (BOT p_j))          ;  bj = (YT_BOT *)(pj->bot);

;    // вызываем на матч две программы, по их процедурным именам
;    // а надо бы всего бота вызывать !!!!
;    result = tur->play_game (/* bi->prog, bj->prog, */ bi, bj);
      (setf result (funcall (PLAY_GAME tur) bi bj))

;    // 2 очка за победу, 1 за ничью (как раньше в футболе)

      (cond 
       ((= result GAME_WIN)   ;{ // игрок "i" победил "j"
        (incf (INT1 p_i))  (incf (SUM p_i) 2) ; (pi->int1)++;   pi->sum += 2;  
        (incf (INT3 p_j))  (incf (SUM p_j) 0) ; (pj->int3)++;   pj->sum += 0; 
        (setf signum '+)                      ; signum = '+';
        )
       
       ((= result GAME_DRA)   ; if (result == GAME_DRA )   { 
        (incf (INT2 p_i))  (incf (SUM p_i) 1) ; (pi->int2)++;   pi->sum += 1; /* 0 */;  
        (incf (INT2 p_j))  (incf (SUM p_j) 1) ; (pj->int2)++;   pj->sum += 1; /* 0 */;
        (setf signum '=)                      ; signum = '=';
        )
       
       ((= result GAME_LOS)   ; if (result == GAME_LOS )   { 
        (incf (INT3 p_i))  (incf (SUM p_i) 0) ; (pi->int3)++;   pi->sum += 0;  
        (incf (INT1 p_j))  (incf (SUM p_j) 2) ; (pj->int1)++;   pj->sum += 2;
        (setf signum '-)                      ; signum = '-';
        )
       )

      (format t "~s" signum)  ; printf ("%c", signum);
      )

    ;;  // ------------------------------
    (format t "~%")

    )

))
;===============================================================================
;int d_min = -7, d_max = 7;

(defconstant d_min -7)
(defconstant d_max +7)

;-------------------------------------------------------------------------------
;//T_BOT_RETURN
;int
;bot1 (/* BOT_VAR */)
;-------------------------------------------------------------------------------
(defun bot1 ()

(let (
  (d  (YRAND d_min d_max))
  )

  (+ 10 d)
))
;-------------------------------------------------------------------------------
(defun bot2 ()

(let (
  (d  (YRAND d_min d_max))
  )

  (+ 20 d)
))
;-------------------------------------------------------------------------------
(defun bot3 ()

(let (
  (d  (YRAND d_min d_max))
  )

  (+ 30 d)
))
;-------------------------------------------------------------------------------
(defun bot4 ()

(let (
  (d  (YRAND d_min d_max))
  )

  (+ 40 d)
))
;-------------------------------------------------------------------------------
(defun bot5 ()

(let (
  (d  (YRAND d_min d_max))
  )

  (+ 50 d)
))
;-------------------------------------------------------------------------------
;// Играем матч между двумя ТЕСТОВЫМИ игроками 
;-------------------------------------------------------------------------------
;int 
;test_turnir_play (void *b1, void *b2)
;-------------------------------------------------------------------------------
(defun test_turnir_play (b1 b2)

(let* (
;  //YT_PROG prog1 = ((YT_BOT*) b1)->prog;
;  //YT_PROG prog2 = ((YT_BOT*) b2)->prog;
;/*   YT_PROG prog1 = (YT_PROG) b1; */
;/*   YT_PROG prog2 = (YT_PROG) b2; */

;  YT_SIMP prog1 = (YT_SIMP) b1;
;  YT_SIMP prog2 = (YT_SIMP) b2;

  result ;  int  result, p1, p2; 

  (p1  (funcall b1)) ;  p1  = prog1 (/* 0, NULL, 0, 0 */);   
  (p2  (funcall b2)) ;  p2  = prog2 (/* 0, NULL, 0, 0 */);
  )   

  (cond 
   ((>  p1 p2 ) (setf result GAME_WIN))      
   ((<  p1 p2 ) (setf result GAME_LOS))       
   (t           (setf result GAME_DRA))
   )    
  
  ;(format t "~% p1= ~2s  p2= ~2s  result= ~s ~%" p1 p2 result) 
  
  result
))
;-------------------------------------------------------------------------------
;void 
;turnir_calc (YT_TURNIR *tur, int tur_nums, int seed)
;-------------------------------------------------------------------------------
(defun turnir_calc (tur tur_nums seed)

  (turnir_init  tur seed)

  (dotimes (n  tur_nums)
    (turnir_play  tur (IS_DOUBLE_PLAY tur))
    (format t "~%")
    )

  (format t "~%")

  (bottop_sort_results_old (BOTTOP tur)  SORT_MAX_MIN SORT_0)
  (bottop_print_results    (BOTTOP tur) 'turnir_draw_line) 

)
;-------------------------------------------------------------------------------
;void 
;test_turnir (int tur_nums, int seed)
;-------------------------------------------------------------------------------
(defun test_turnir (tur_nums seed)

(let (
;  YT_TURNIR *tur = turnir_create (50, test_turnir_play, TRUE);
;  (tur  (turnir_create  50 'test_turnir_play TRUE))
  (tur  (turnir_create  50 'test_turnir_play t)) ;;??
  )

  (turnir_add_player  tur "bot1" 'bot1)
  (turnir_add_player  tur "bot2" 'bot2)

  (turnir_add_player  tur "bot3" 'bot3)
  (turnir_add_player  tur "bot4" 'bot4)
  (turnir_add_player  tur "bot5" 'bot5)

  (turnir_calc  tur tur_nums seed)

))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;void
;turnir_parse_cmdline (int argc, char** argv, int j, 
;                      int *p_seed, int *p_nums)
;{
;  if (argc == j) {
;    printf ("Need argument(s): \n");
;    printf ("<seed> <tur_nums> \n");
;    return;
;  }

;  *p_seed = atoi (argv[j]); 
;  j++;
;  *p_nums = atoi (argv[j]); 

;  return;
;}
;-------------------------------------------------------------------------------
;void
;tour_main (int argc, char** argv, int j)
;-------------------------------------------------------------------------------
(defun tour_main (argus)  (declare (ignore argus))

;  int seed;
;  int tur_nums; 

;  turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums);
;  test_turnir (tur_nums, seed);

  (test_turnir 1 2010)
)
;===============================================================================


