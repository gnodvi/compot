# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;/*******************************************************************************
# ; *                                                                             *
# ; *  Имя этого файла: y_rsb1.c                                                  *
# ; *                                                                             *
# ;  ******************************************************************************
# ; */ 
                                                                            

# ;#include "a_comm.h"
# ;#include "y_rsb_.h"

# ;/******************************************************************************/

# ;/*----------------------------------------------------------------------------*/
# ;int 
# ;flip_biased_coin (double prob)
# ;-------------------------------------------------------------------------------
# ;int 
# (defun flip_biased_coin (prob)

# ;  /* flip an unfair coin (bit) with given probability of getting a 1 */

# ;  if ( (random() / maxrandom) >= prob )
# ;    return(0);
# ;  else 
# ;    return(1);

#   (if (>= (/ (Y-random) y_maxrandom) prob) (values 0)
#                                            (values 1)
#                                            )

# )
# ;-------------------------------------------------------------------------------
# ;  roshambo with given probabilities of rock, paper, or scissors 
# ;-------------------------------------------------------------------------------
# ;int 
proc biased_roshambo {prob_rock prob_paper} {

  # (let (
  # ;  double throw;
  # ;  throw = random() / maxrandom;
  set val [expr {[Y-random] / $::y_maxrandom}]
  #   )
  
  puts "prob_rock= $prob_rock   prob_paper= $prob_paper   val == $val"

  # ;   if      ( throw < prob_rock )              return (rock);
  # ;   else if ( throw < prob_rock + prob_paper ) return (paper);
  # ;   else /* throw >= prob_rock + prob_paper */ return (scissors);
  
  #  (cond
  #   ((< val    prob_rock)              rock)
  #   ((< val (+ prob_rock prob_paper))  paper)
  #   (t                                 scissors)
  #   )
  
  if     {$val < $prob_rock}                         {return $::rock}  \
  elseif {$val < [expr {$prob_rock + $prob_paper}]}  {return $::paper} \
  else                                               {return $::scissors}

}
# ;/*----------------------------------------------------------------------------*/




# ;/******************************************************************************/
# ;//==============================================================================
# ;/*  Dummy Bots  (written by Darse Billings)  */
# ;//==============================================================================


# ;===============================================================================
# ;// Random (Optimal) : generate action uniformly at random (optimal strategy)
# ;===============================================================================
# ;int 
# (defun randbot ()

# ;  return (random() % 3);
#   (mod (Y-random) 3)
# )
# ;===============================================================================
# ;// Good Ole Rock : "Good ole rock.  Nuthin' beats rock."
# ;===============================================================================
# ;int 
# (defun rockbot ()


#   rock ;  return (rock);
# )
# ;===============================================================================
# ;// R-P-S 20-20-60 :  play 20% rock, 20% paper, 60% scissors 
# ;===============================================================================
# ;int 
# (defun r226bot ()


#   (biased_roshambo 0.2 0.2)
# )
# ;===============================================================================
# ;// Rotate R-P-S : rotate choice each turn r -> p -> s
# ;===============================================================================
# ;int
proc rotatebot {} { 

  # ;  return (m_history[0] % 3);
  #   (mod (nth 0 m_history) 3)

  set ret [mod [nth 0 $::m_history] 3]

  set ret [expr {int ($ret)}]

  return $ret
}
# ;===============================================================================
# ;// Beat Last Move : do whatever would have beat the opponent last turn
# ;===============================================================================
# ;int 
# (defun copybot () 


# ;  return ((o_history[o_history[0]] + 1) % 3);
#   (mod (+ (nth (nth 0 o_history) o_history) 1) 3)
# )
#------------------------------------------

set ::t  $::TRUE

# ;===============================================================================
# ;// Always Switchin' : never repeat the previous pick
# ;===============================================================================
# ;int 
proc switchbot {} {

  # ;  if ( m_history[m_history[0]] == rock ) {
  # ;    return (biased_roshambo(0.0, 0.5) ); 
  # ;  }
  # ;  else if ( m_history[m_history[0]] == paper ) {
  # ;    return (biased_roshambo(0.5, 0.0) ); 
  # ;  }
  # ;  else 
  # ;    return (biased_roshambo(0.5, 0.5) );
  
  # (let (
  set prev_my_pick [nth [nth 0 $::m_history] $::m_history]
  #   )
  
  

#   cond  \
#     {$prev_my_pick  ==  $::rock}  {return [biased_roshambo 0.0 0.5]}  \
#     {$prev_my_pick  == $::paper}  {return [biased_roshambo 0.5 0.0]}  \
#     $::t                          {return [biased_roshambo 0.5 0.5]}  
  
    if     {$prev_my_pick ==  $::rock}  {return [biased_roshambo 0.0 0.5]}  \
    elseif {$prev_my_pick == $::paper}  {return [biased_roshambo 0.5 0.0]}  \
    else                                {return [biased_roshambo 0.5 0.5]}  
  
}
# ;===============================================================================
# ;// Beat Frequent Pick : beat the opponent's most frequent choice
# ;===============================================================================
# ;int 
# (defun freqbot () 

# (let (
# ;  int i, rcount, pcount, scount;
# ;  rcount = 0;  pcount = 0;  scount = 0;
#   (rcount  0) 
#   (pcount  0)  
#   (scount  0)
#   o_pick
#   )

# ;  for (i = 1; i <= o_history[0]; i++) {
#   (loop for i from 1 to (first o_history) do

# ;    if      (o_history[i] == rock)       rcount++;
# ;    else if (o_history[i] == paper)      pcount++;
# ;    else /* o_history[i] == scissors */  scount++;

#     (setf o_pick (nth i o_history ))

#     (cond 
#      ((= o_pick  rock)  (incf rcount))
#      ((= o_pick paper)  (incf pcount))
#      (t                 (incf scount))
#      )
#     )

# ;  if      ((rcount > pcount) && (rcount > scount) )  return(paper);
# ;  else if ( pcount > scount )                        return(scissors);
# ;  else                                               return(rock);

#     (cond 
#      ((and (> rcount pcount) (> rcount scount))  paper)
#      ((> pcount scount)                       scissors)
#      (t                                           rock)
#      )

# ))
# ;===============================================================================
# ;// Beat Frequent Pick (again) : 
# ;// maintain stats with static variables to avoid re-scanning
# ;// the history array  (based on code by Don Beal)
# ;============================================================

# (defvar rcount)
# (defvar pcount)
# (defvar scount)

# ;===============================================================================
# ;int 
# (defun freqbot2 () 

# (let (
# ;  static int rcount, pcount, scount;
#   opp_last ;  int        opp_last;
#   (num (first o_history))
#   )

# ;  if (o_history[0] == 0) { // еще не сделано ни одного хода
#   (if (= num 0) (progn 
#     (setf rcount 0)  
#     (setf pcount 0)  
#     (setf scount 0)  
#     )
# ;  else {
#     (progn

#       (setf opp_last (nth (first o_history) o_history))
# ;    opp_last = o_history[o_history[0]]; // последний ход врага

# ;    if      (opp_last == rock)       rcount++; 
# ;    else if (opp_last == paper)      pcount++; 
# ;    else  /* opp_last == scissors */ scount++; 

#       (cond 
#        ((= opp_last  rock)  (incf rcount))
#        ((= opp_last paper)  (incf pcount))
#        (t                   (incf scount))
#        )
# ;  }
#       ))

# ;  if     ((rcount > pcount) && (rcount > scount)) return (paper); 
# ;  else if (pcount > scount)                       return (scissors); 
# ;  else                                            return (rock); 

#     (cond 
#      ((and (> rcount pcount) (> rcount scount))  paper)
#      ((> pcount scount)                       scissors)
#      (t                                           rock)
#      )

# ))
# ;===============================================================================
# ;// Switch A Lot : seldom repeat the previous pick
# ;===============================================================================
# ;int 
# (defun switchalot ()

# (let (
#   (prev_pick (nth (first m_history) m_history))
#   )

# ;  if      (m_history[m_history[0]] == rock)  return (biased_roshambo (0.12, 0.44)); 
# ;  else if (m_history[m_history[0]] == paper) return (biased_roshambo (0.44, 0.12));
# ;  else                                       return (biased_roshambo (0.44, 0.44));

#   (cond
#    ((= prev_pick  rock)  (biased_roshambo 0.12 0.44))
#    ((= prev_pick paper)  (biased_roshambo 0.44 0.12))
#    (t                    (biased_roshambo 0.44 0.44))
#    )

# ))
# ;===============================================================================
# ;// Flat bot : flat distribution, 20% chance of most frequent actions 
# ;===============================================================================

# (defvar rc)
# (defvar pc)
# (defvar sc)

# ;===============================================================================
# ;int 
# (defun flatbot3 ()  

# ;(declare (special rc pc sc))

# (let (
# ;  static int rc, pc, sc;
#   mylm ;  int        mylm, choice;

#   (choice  0)
#   (num (first m_history))
#   )

# ;  if (m_history[0] == 0) {
#   (if (= num 0) (progn
#     (setf rc  0)
#     (setf pc  0)
#     (setf sc  0)
#     )

# ;  }
# ;  else {

#   (progn 
# ;    mylm = m_history[m_history[0]];
#     (setf mylm (nth num m_history))

# ;    if      (mylm == rock)        rc++;
# ;    else if (mylm == paper)       pc++;
# ;    else  /* mylm == scissors */  sc++;
#       (cond 
#        ((= mylm  rock)  (incf rc))
#        ((= mylm paper)  (incf pc))
#        (t               (incf sc))
#        )

# ;  }
#   ))

#   (when (and (< rc pc) (< rc sc))  (setf choice (biased_roshambo 0.8  0.1)))
#   (when (and (< pc rc) (< pc sc))  (setf choice (biased_roshambo 0.1  0.8)))
#   (when (and (< sc rc) (< sc pc))  (setf choice (biased_roshambo 0.1  0.1)))
#   (when (and (= rc pc) (< rc sc))  (setf choice (biased_roshambo 0.45 0.45)))
#   (when (and (= rc sc) (< rc pc))  (setf choice (biased_roshambo 0.45 0.1))) 
#   (when (and (= pc sc) (< pc rc))  (setf choice (biased_roshambo 0.1  0.45)))
#   (when (and (= rc pc) (= rc sc))  (setf choice (mod (Y-random) 3)))

# ;  /* printf("[%d %d %d: %d]", rc, pc, sc, choice); */

#   choice ;  return (choice);
# ))
# ;===============================================================================
# ;// Anti-Flat bot : maximally exploit flat distribution
# ;===============================================================================
# (locally ; что это?
# ; This macro may be used to make local pervasive declarations where desired.

# (defvar a_rc) ; модeлируeм статичнскиe пeрeмeнныe данной функции ))
# (defvar a_pc)
# (defvar a_sc)

# ; ошибка как раз и была в совмeстном использовании стат. (глоб.) пeрeмeнных,
# ; видимо два раза они измeнялись,.. т.e. надо  тогда уж чтобы "судья" это дeлал,
# ; т.e. подсчитывал статистику нeзависимо игроков..

# ;===============================================================================
# ;int 
# (defun antiflatbot ()

# ;(declare (special a_rc a_pc a_sc)) ; это тожe самоe что объявлeниe
# ;; глоб. пeрeмeнных ? и они нe уникальны внутри функции?

# (let (
# ;  static int rc, pc, sc;
# ;
# ; как промодeлировать статичeскиe пeрeмeнныe? special? т.e. лeксичeскоe связываниe?
# ; 

#   opplm ;  int opplm, choice;

#   (choice  0)
#   (num (first o_history))
#   )

# ;  if (o_history[0] == 0) {
#   (if (= num 0) (progn
#     (setf a_rc 0) 
#     (setf a_pc 0)
#     (setf a_sc 0)
#     )

# ;  }
# ;  else {

#   (progn
# ;    opplm = o_history[o_history[0]];
#     (setf opplm (nth num o_history))

# ;    if      (opplm == rock)        rc++;
# ;    else if (opplm == paper)       pc++;
# ;    else  /* opplm == scissors */  sc++;
#     (cond 
#        ((= opplm  rock)  (incf a_rc))
#        ((= opplm paper)  (incf a_pc))
#        (t                (incf a_sc))
#        )

#     ))

#   (when (and (< a_rc a_pc) (< a_rc  a_sc))   (setf choice paper))
#   (when (and (< a_pc a_rc) (< a_pc  a_sc))   (setf choice scissors)) 
#   (when (and (< a_sc a_rc) (< a_sc  a_pc))   (setf choice rock))
#   (when (and (= a_rc a_pc) (< a_rc  a_sc))   (setf choice paper))
#   (when (and (= a_rc a_sc) (< a_rc  a_pc))   (setf choice rock))
#   (when (and (= a_pc a_sc) (< a_pc  a_rc))   (setf choice scissors))
#   (when (and (= a_rc a_pc) (= a_rc  a_sc))   (setf choice (mod (Y-random) 3)))

# ;  /* printf("[%d %d %d: %d]", rc, pc, sc, choice); */

#   choice ;  return (choice);
# ))
# ) ; locally
# ;===============================================================================
# ;// Foxtrot bot : set pattern: rand prev+2 rand prev+1 rand prev+0, repeat 
# ;===============================================================================
# ;int 
# (defun foxtrotbot ()

# (let (
# ;  int turn;
# ;  turn = m_history[0] + 1;
#   (turn (1+ (first m_history)))
#   )

# ;  if  (turn % 2)  return (random() % 3); 
# ;  else            return ((m_history[turn-1] + turn) % 3); 

#   (if  (> (mod turn 2) 0)  (mod (Y-random)  3) 
#                            (mod (+ (nth (- turn 1) m_history) turn) 3)
#                            )

# ))
# ;===============================================================================
# ;// Copy-drift bot : 
# ;// bias decision by opponent's last move, but drift over time
# ;// max -EV = -0.50 ppt 
# ;===============================================================================

# ;(defpackage :driftbot_pkg
# ;  (:use :common-lisp
# ;	))
# ;(in-package :driftbot_pkg)

# ;(locally 
# (defvar gear)

# ;===============================================================================
# ;int 
# (defun driftbot ()

# ;(declare (special gear))
# ;(declare (static gear))
# ;(declare (inline gear))

# (let (
#   ;  static int gear;

#   val ;  int        mv, throw;

#   (mv (first m_history))
#   )
#   ;------------------------------------------------

#   (if (= mv 0) (progn 
#     (setf gear 0)
#     (setf val (mod (Y-random) 3)) ; throw = random() % 3; 
#     )

# ;  else {
#     (progn

# ;    if (flip_biased_coin(0.5))    throw = o_history[mv];
# ;    else                          throw = random() % 3;

#     (if (> (flip_biased_coin 0.5) 0) (setf val (nth mv o_history))
#                                      (setf val (mod (Y-random) 3))
#                                      )
# ;    if (mv % 111 == 0)
# ;      gear += 2;

#     (when (= (mod mv 111) 0)
#       (incf gear 2)
#       )

#     ))

#   (mod (+ val gear) 3) ;  return ((throw + gear) % 3);
# ))
# ;------------------------------
# ;) ; defpackage
# ;) ;locally

# ;===============================================================================
# ;// Add-drift bot : 
# ;// base on sum of previous pair (my & opp), drift over time
# ;// deterministic 50% of the time, thus max -EV = -0.500 ppt
# ;===============================================================================

# (defvar a_gear)

# ;===============================================================================
# ;int 
# (defun adddriftbot2 ()

# (let (
# ;  static int gear;
# ;  int        mv;

#   (mv (first m_history)) ;  mv = m_history[0];
#   )

# ;  if (mv == 0) {
#   (cond 
#    ((= mv 0)  (progn
#                 (setf a_gear 0)
#                 (return-from adddriftbot2 (mod (Y-random) 3)) ;    return (random() % 3);
#                 ))

#    ((= (mod mv 200) 0)  (progn 
# ;  else if (mv % 200 == 0) 
#                           (incf  a_gear 2)
#                           ))
#    )

# ;  if (flip_biased_coin (0.5)) 
# ;    return (random() % 3 ); 
# ;  else 
# ;    return ((m_history[mv] + o_history[mv] + gear) % 3);

#   (if (> (flip_biased_coin 0.5) 0)  (mod (Y-random) 3) 
#                                     (mod (+ (nth mv m_history) (nth mv o_history) a_gear) 3)
#     )
 
# ))
# ;/*============================================================================*/
# ;/*  End of Simple (rsb-99.c)  Players Algorithms  */
# ;/*============================================================================*/



# ;/*----------------------------------------------------------------------------*/
# ;/*  Entrant:  Piedra (25)   Lourdes Pena (Mex)  */
# ;/*----------------------------------------------------------------------------*/
# ;/*********** Lourdes Pena Castillo September, 1999 ***************/
# ;/*********** Piedra  program                        **************/

# ;#define LMIN1 2
# ;#define LBAD -40

# ;/*----------------------------------------------------------------------------*/
# ;int 
# ;piedra ()
# ;{
# ;  // play whatever will beat the opponent's most frequent choice
# ;  // after previous match history 

# ;  static int Count[3][3][3]; // [Idid][Itdid][Itdoes]
# ;  static int score, goingbad;

# ;  int *pCount, total;

# ;  if (m_history[0] == 0) {
# ;    memset (Count, 0, sizeof(int) * 27);
# ;    score    = 0; 
# ;    goingbad = 0; 
# ;    return (biased_roshambo (0.33, 0.33)); // Be optimal first 
# ;  }

# ;  int o_move = o_history [o_history[0]];
# ;  int m_move = m_history [m_history[0]];

# ;  if (m_history[0] < LMIN1) {
# ;    if ((o_move - m_move ==  1) || 
# ;        (o_move - m_move == -2)) {
# ;      score --;
# ;    } else if (o_move != m_move) {
# ;      score ++;
# ;    }
# ;    return (biased_roshambo (0.33, 0.33)); // Be optimal first 
# ;  } 

# ;  // Add the previous result information 
# ;  int o_move_prev = o_history [o_history[0]-1];
# ;  int m_move_prev = m_history [m_history[0]-1];

# ;  pCount = Count [m_move_prev][o_move_prev];
# ;  pCount [o_move]++; 
       

# ;  if (o_move - m_move ==  1 || 
# ;      o_move - m_move == -2) {
# ;    score --;
# ;  } else if (o_move != m_move) {
# ;    score ++;
# ;  }

# ;  if (score == LBAD ) goingbad = 1; 

# ;  if (goingbad) {                           // oh-oh! Things are going bad!
# ;    return (biased_roshambo(0.333, 0.333)); // better be optimal then 
# ;  }

# ;  // Look what the numbers say the opponent will do next 
# ;  pCount = Count [m_move][o_move];
# ;  total  = pCount[rock] + pCount[paper] + pCount[scissors];

# ;  if (total == 0 ) { // Not information, then be optimal 
# ;    return (biased_roshambo(0.33, 0.33)); 
# ;  }

# ;  if      ((pCount[rock]  > pCount[paper]) && (pCount[rock] > pCount[scissors])) 
# ;                                              return (paper); 
# ;  else if ( pCount[paper] > pCount[scissors]) return (scissors); 
# ;  else                                        return (rock); 

# ;}
# ;/*----------------------------------------------------------------------------*/


# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;/*  Entrant:  Mixed Strategy (28)   Thad Frogley (UK)

# ;   > I also welcome more feedback from the participants, both
# ;   > on your ideas and on your personal background. 

# ; Darse,
 
# ; As I said in an earlier mail I thought it was a very well run tournament,
# ; and I will be entering the second one, probably with an cleaner/faster
# ; "mixed strategy" bot, plus a new one that's been busting my brain since I
# ; read about "Iocaine Powder" (so do I play what will beat what I predict they
# ; will play, or do I play what will beat what will beat what I predict that
# ; they predict what I will play?  Ungk.  Fizzle.).
 
# ; Anywho, ask you asked, my info:
 
# ; I am:
# ; Thad (Thaddaeus Frogley) 24 years old, programmer for CLabs/CyberLife
# ; Technology Ltd, Cambridge, England
# ; No university education, self taught programmer (from ooh around the age of
# ; 7 hmmm zx81 with 16k ram pack!).
# ; Maintainer (but not very active) of the Robot Battle FAQ
# ; [http://www.robotbattle.com]
# ; Oh, and some people seem to find it interesting that I'm dyslexic.
 
# ; My bot is:
# ; Mixed Strategy, and is *not* based on the CLabs alife philosophy, it is
# ; instead based on my experiences with Robot Battle (RB) where the Muli-mode
# ; Bot / Mode Switcher / Meta Bot is a well established tactic.
 
# ; Initially I thought that simply wrapping the built in behaviours in a basic
# ; analysing mode switcher would be enough to do well in the tournament (I
# ; seriously under estimated the calibre of the participants), but then after
# ; brief correspondence with your good self I got that nagging feeling that I
# ; needed to do more.  Due to time constraints I limited my changes to the
# ; creation of two 'new' behaviours based on pair wise statistical probability
# ; predication (named watching-you and watching-you-watching-me) and stripped
# ; out the modes that I felt where redundant.  In hindsight I have realised
# ; that I could have probably removed the "Beat Frequent Pick" and "random"
# ; modes leaving the random factor to the context switching between the
# ; remaining modes.
 
# ; I have some other ideas for improving Mixed Strategy, and I have an idea for
# ; a new bot, but I'll save them for next time.
 
# ; I'll close by pointing out the following issues common to all mode based
# ; adaptive AIs.
 
# ; 1) The learning curve.  To many modes means to much time spend learning, and
# ; not enough winning.
# ; 2) Mode locking.  Without a decay function a mode that is adapted against
# ; will loose as many as it won before switching.  (Hence the decay function in
# ; my one.)
 
# ; I hope this lot adds to everybody's knowledge and enjoyment of the game!
 
# ; Thad
# ;*/
# ;-------------------------------------------------------------------------------
# ;
# ;-------------------------------------------------------------------------------
# ;int 
# (defun make_move (rcount pcount scount)

#   (cond 
#   ((and  (> rcount pcount) (> rcount scount))  paper)
#   ((> pcount scount)                           scissors)
#   (t                                           rock)
#   )

# )
# ;-------------------------------------------------------------------------------
# ;void
# ;make_calc (int omove, int *rcount, int *pcount, int *scount)
# ;{

# ;  if      (omove == rock)              (*rcount)++;
# ;  else if (omove == paper)             (*pcount)++;
# ;  else /* o_history[i] == scissors */  (*scount)++;

# ;}
# ;-------------------------------------------------------------------------------
# ;void
# (defun for_all_make_calc (
#                    min_off max_off      ; int 
#                    turn                 ; int turn,
#                    rcount pcount scount ; int *rcount, int *pcount, int *scount,
#                    history              ; int *history
#                    )

# (let (
#   (i_min  (+ 1    min_off))
#   (i_max  (+ turn max_off))

#   (new_rcount   rcount)
#   (new_pcount   pcount)
#   (new_scount   scount)
#   omove
#   )

# ;  for (i = i_min; i <= i_max; i++) {
# ;    if ((history != NULL) && (history[i-1] != history[turn])) 
# ;      continue;

# ;    make_calc (o_history[i], rcount, pcount, scount);
# ;  }

#   (loop for i from i_min to i_max do  ; к сожалeнию, цикл каждый раз по всeй истории
#                                       ; это надо бы исправить ..
#                                       ; но вeдь подсчeт идeт взависимости от
#                                       ; послeднeго хода ?!   history[turn]
#                                       ; т.e. нeльзя улучшить ?
#   (unless (and (not (eq history NIL)) (not (eq (nth (- i 1) history) (nth turn history))) ) 

# ;    make_calc (o_history[i], rcount, pcount, scount);
#     (setf omove (nth i o_history))

#     (cond 
#      ((= omove rock)     (incf new_rcount))
#      ((= omove paper)    (incf new_pcount))
#      (t                  (incf new_scount))
#      )
#     ))


  
#   (values new_rcount new_pcount new_scount)
# ))
# ;-------------------------------------------------------------------------------

# (defvar strategy_scores (make-list 4))
# (defvar last_strategy)

# ;-------------------------------------------------------------------------------
# ;int 
# (defun mixed_strategy ()

# (let (
# ;  static int strategy_scores[4];
# ;  static int last_strategy;

#   rcount pcount scount
#   m_last o_last new_move ;  int turn = o_history[0], new_move, m_last, o_last;
#   (turn (first m_history)) 

#   tt ;  double t;
#   )

#   (if (= turn 0) 

#   (progn
#     (setf (nth 0 strategy_scores) 4) ;  watching you watching me 
#     (setf (nth 1 strategy_scores) 4) ;  watching you 
#     (setf (nth 2 strategy_scores) 2) ;  freqbot 
#     (setf (nth 3 strategy_scores) 1) ;  random 
#     )

#   (progn 
#     ;;  remeber success of prev stratigies 
#     (setf m_last (nth turn m_history))
#     (setf o_last (nth turn o_history))

#     (cond 
#      ((= m_last o_last) (incf (nth last_strategy strategy_scores) 1)) ; draw 
     
#      ((or (= (- m_last o_last) 1) (= (- m_last o_last) -2))
#       (incf (nth last_strategy strategy_scores) 3 ) ; win (test from Play_Match) 
#       )
#      (t  (setf (nth last_strategy strategy_scores)
#         ; (int) - прeобразованиe к инт. 
#                (* (nth last_strategy strategy_scores) 0.8)
#                ))
#      )
#     )
#   )
#   ;;  //------------------------------------------------

#   ;;  pick based on rate of success for each strategy 

#   (setf tt (Y-random))        ;  t = random ();
#   (setf tt (/ tt y_maxrandom)) ;  t /= maxrandom;
# ;  t *= (strategy_scores[0] + strategy_scores[1] + strategy_scores[2] +
# ;        strategy_scores[3]);
#   (setf tt (* tt (+ 
#                 (nth 0 strategy_scores) 
#                 (nth 1 strategy_scores) 
#                 (nth 2 strategy_scores) 
#                 (nth 3 strategy_scores) 
#                 )))

#   (setf rcount 0)  
#   (setf pcount 0)  
#   (setf scount 0)

#   ;; play whatever will beat the opponent's most frequent ... 

#   (cond 
#   ((< tt (nth 0 strategy_scores))
#     (setf last_strategy 0)
#     ;// ... follow up to my last move */
#      (multiple-value-setq (rcount pcount scount)  (for_all_make_calc 
#                                                    1 -1 
#                                                    turn  rcount pcount scount
#                                                    m_history))
#     (setf new_move (make_move  rcount pcount scount))
#     )

#   ((< tt (+ (first strategy_scores) (second strategy_scores))) ; /* note change */
#     (setf last_strategy 1)
#     ;// ... follow up to his last move 
#     (multiple-value-setq (rcount pcount scount)  (for_all_make_calc 
#                                                   1 -1 
#                                                   turn rcount pcount scount
#                                                   o_history))
#     (setf new_move (make_move  rcount pcount scount))
#     )

#   ((< tt (+ (first strategy_scores) (second strategy_scores) (third strategy_scores)))
#     (setf last_strategy 2)
#     ;// ... choice 
#     (multiple-value-setq (rcount pcount scount)  (for_all_make_calc 
#                                                   0 0 
#                                                   turn rcount pcount scount
#                                                   NIL))
#     (setf new_move (make_move rcount pcount scount))
#     )

#   (t 
#     (setf last_strategy 3)
#     (setf new_move (mod (Y-random) 3))
#     )

#   )

#   new_move ;  return (new_move);
# ))
# ;/******************************************************************************/
# ;===============================================================================

