# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;/*******************************************************************************
# ; *                                                                             *
# ; *  Имя этого файла: k_rsb_.h                                                  *
# ; *                                                                             *
# ; *******************************************************************************
# ; */  


# ;/******************************************************************************/

# (defconstant  RSB_SO  "T/v-rsb-.so")

# ;/******************************************************************************/
# (format *error-output* "30 ... ~%")

# #+SBCL (load-shared-object RSB_SO) ; почему-то SBCL не хочет загружать
# ; собранную в CYGWIN бииблиотеку "v-rsb-.so"

# (format *error-output*  "31 ... ~%")

# ;/******************************************************************************/
# #-SBCL
# (FFI:default-foreign-language :stdc)


# #-SBCL
# (FFI:DEF-CALL-OUT   c_set_history_for_player_1
#                     (:library RSB_SO)
#                     (:name "c_set_history_for_player_1")                     
#                     (:return-type NIL)
#                     )

# #-SBCL
# (FFI:DEF-CALL-OUT   c_set_history_for_player_2
#                     (:library RSB_SO)
#                     (:name "c_set_history_for_player_2")                     
#                     (:return-type NIL)
#                     )

# #-SBCL
# (FFI:DEF-CALL-OUT   c_history_create_init
#                     (:library RSB_SO)
#                     (:name "c_history_create_init")                     
#                     (:return-type NIL)
#                     )

# #-SBCL
# (FFI:DEF-CALL-OUT   c_set_last_history
#                     (:library RSB_SO)
#                     (:name "c_set_last_history")                     
#                     (:return-type NIL)
#                     (:arguments   
#                      (p1  FFI:int) 
#                      (p12 FFI:int) 
#                      )
#                     )

# ;-------------------------------------------------------------------------------
# (defmacro history_create_init ()
proc history_create_init {} {

  # #+SBCL `(alien-funcall (extern-alien "c_history_create_init" (function void)))
  # #-SBCL `(c_history_create_init)

}
# ;-------------------------------------------------------------------------------
# (defmacro set_history_for_player_1 ()
proc set_history_for_player_1 {} {

  # #+SBCL `(alien-funcall (extern-alien "c_set_history_for_player_1" (function void)))
  # #-SBCL `(c_set_history_for_player_1)

}
# ;-------------------------------------------------------------------------------
# (defmacro set_history_for_player_2 ()
proc set_history_for_player_2 {} {

  # #+SBCL `(alien-funcall (extern-alien "c_set_history_for_player_2" (function void)))
  # #-SBCL `(c_set_history_for_player_2)

}
# ;-------------------------------------------------------------------------------
# (defmacro set_last_history (p1 p2)
proc set_last_history {p1 p2} {

  # #+SBCL `(alien-funcall (extern-alien "c_set_last_history" (function void int int)) ,p1 ,p2)
  # #-SBCL `(c_set_last_history ,p1 ,p2)

}
# ;-------------------------------------------------------------------------------
# ;
# ; ИМПОРТНЫE БОТЫ ИЗ СПИСА "МИНИМУМ" (дополнитeльно к Лисп-вариантам)
# ;
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT  c_rotatebot (:library RSB_SO) (:name "rotatebot")                     
# ;                   (:return-type FFI:int)
# ;                   )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_rotatebot ()

# ;#+SBCL (alien-funcall (extern-alien "rotatebot"       (function int)))
# ;#-SBCL (c_rotatebot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT  c_switchbot (:library RSB_SO) (:name "switchbot")                     
# ;                   (:return-type FFI:int)
# ;                   )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_switchbot ()

# ;#+SBCL (alien-funcall (extern-alien "switchbot"       (function int)))
# ;#-SBCL (c_switchbot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;(defun foreign_pibot ()

# ;#+SBCL (alien-funcall (extern-alien "pibot"           (function int)))
# ;#-SBCL (c_pibot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;(defun foreign_debruijn81 ()

# ;#+SBCL (alien-funcall (extern-alien "debruijn81"      (function int)))
# ;#-SBCL (c_debruijn81) 
# ;)
# ;-------------------------------------------------------------------------------
# ;(defun foreign_textbot ()

# ;#+SBCL (alien-funcall (extern-alien "textbot"         (function int)))
# ;#-SBCL (c_textbot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;(defun foreign_antirotnbot ()

# ;#+SBCL (alien-funcall (extern-alien "antirotnbot"     (function int)))
# ;#-SBCL (c_antirotnbot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;(defun foreign_addshiftbot3 ()

# ;#+SBCL (alien-funcall (extern-alien "addshiftbot3"    (function int)))
# ;#-SBCL (c_addshiftbot3) 
# ;)
# ;-------------------------------------------------------------------------------



# ;-------------------------------------------------------------------------------
# ;
# ; ИМПОРТНЫE БОТЫ ИЗ СПИСА "МАКСИМУМ"
# ;
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# #+CLISP
# (FFI:DEF-CALL-OUT   c_iocainebot
#                     (:library RSB_SO)
#                     (:name "iocainebot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_iocainebot ()

# #+SBCL (alien-funcall (extern-alien "iocainebot"      (function int)))
# #-SBCL (c_iocainebot) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_russrocker4
#                     (:library RSB_SO)
#                     (:name "russrocker4")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_russrocker4 ()

# #+SBCL (alien-funcall (extern-alien "russrocker4"     (function int)))
# #-SBCL (c_russrocker4)
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_halbot
#                     (:library RSB_SO)
#                     (:name "halbot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_halbot ()

# #+SBCL (alien-funcall (extern-alien "halbot"          (function int)))
# #-SBCL (c_halbot) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_mod1bot
#                     (:library RSB_SO)
#                     (:name "mod1bot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_mod1bot ()

# #+SBCL (alien-funcall (extern-alien "mod1bot"         (function int)))
# #-SBCL (c_mod1bot) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_shofar
#                     (:library RSB_SO)
#                     (:name "shofar")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_shofar ()

# #+SBCL (alien-funcall (extern-alien "shofar"          (function int)))
# #-SBCL (c_shofar) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_biopic
#                     (:library RSB_SO)
#                     (:name "biopic")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_biopic ()

# #+SBCL (alien-funcall (extern-alien "biopic"          (function int)))
# #-SBCL (c_biopic) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_actr_lag2_decay
#                     (:library RSB_SO)
#                     (:name "actr_lag2_decay")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_actr_lag2_decay ()

# #+SBCL (alien-funcall (extern-alien "actr_lag2_decay" (function int)))
# #-SBCL (c_actr_lag2_decay) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_sunNervebot
#                     (:library RSB_SO)
#                     (:name "sunNervebot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_sunNervebot ()

# #+SBCL (alien-funcall (extern-alien "sunNervebot"     (function int)))
# #-SBCL (c_sunNervebot) 
# )
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_markov5
# ;                    (:library RSB_SO)
# ;                    (:name "markov5")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_markov5 ()

# ;#+SBCL (alien-funcall (extern-alien "markov5"         (function int)))
# ;#-SBCL (c_markov5) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_markovbails
# ;                    (:library RSB_SO)
# ;                    (:name "markovbails")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_markovbails ()

# ;#+SBCL (alien-funcall (extern-alien "markovbails"     (function int)))
# ;#-SBCL (c_markovbails) 
# ;)
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_predbot
#                     (:library RSB_SO)
#                     (:name "predbot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_predbot ()

# #+SBCL (alien-funcall (extern-alien "predbot"         (function int)))
# #-SBCL (c_predbot) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_robertot
#                     (:library RSB_SO)
#                     (:name "robertot")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_robertot ()

# #+SBCL (alien-funcall (extern-alien "robertot"        (function int)))
# #-SBCL (c_robertot) 
# )
# ;-------------------------------------------------------------------------------
# #-SBCL
# (FFI:DEF-CALL-OUT   c_boom
#                     (:library RSB_SO)
#                     (:name "boom")                     
#                     (:return-type FFI:int)
#                     )
# ;-------------------------------------------------------------------------------
# (defun foreign_boom ()

# #+SBCL (alien-funcall (extern-alien "boom"            (function int)))
# #-SBCL (c_boom) 
# )
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_granite
# ;                    (:library RSB_SO)
# ;                    (:name "granite")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_granite ()

# ;#+SBCL (alien-funcall (extern-alien "granite"         (function int)))
# ;#-SBCL (c_granite) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_marble
# ;                    (:library RSB_SO)
# ;                    (:name "marble")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_marble ()

# ;#+SBCL (alien-funcall (extern-alien "marble"          (function int)))
# ;#-SBCL (c_marble) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_zq_move
# ;                    (:library RSB_SO)
# ;                    (:name "zq_move")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_zq_move ()

# ;#+SBCL (alien-funcall (extern-alien "zq_move"         (function int)))
# ;#-SBCL (c_zq_move) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_sweetrock
# ;                    (:library RSB_SO)
# ;                    (:name "sweetrock")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_sweetrock ()

# ;#+SBCL (alien-funcall (extern-alien "sweetrock"       (function int)))
# ;#-SBCL (c_sweetrock) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_piedra
# ;                    (:library RSB_SO)
# ;                    (:name "piedra")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_piedra ()

# ;#+SBCL (alien-funcall (extern-alien "piedra"          (function int)))
# ;#-SBCL (c_piedra) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_mixed_strategy
# ;                    (:library RSB_SO)
# ;                    (:name "mixed_strategy")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_mixed_strategy ()

# ;#+SBCL (alien-funcall (extern-alien "mixed_strategy"  (function int)))
# ;#-SBCL (c_mixed_strategy) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_multibot
# ;                    (:library RSB_SO)
# ;                    (:name "multibot")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_multibot ()

# ;#+SBCL (alien-funcall (extern-alien "multibot"        (function int)))
# ;#-SBCL (c_multibot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_inocencio
# ;                    (:library RSB_SO)
# ;                    (:name "inocencio")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_inocencio ()

# ;#+SBCL (alien-funcall (extern-alien "inocencio"       (function int)))
# ;#-SBCL (c_inocencio) 
# ;)
# ;-------------------------------------------------------------------------------
# ;#-SBCL
# ;(FFI:DEF-CALL-OUT   c_peterbot
# ;                    (:library RSB_SO)
# ;                    (:name "peterbot")                     
# ;                    (:return-type FFI:int)
# ;                    )
# ;-------------------------------------------------------------------------------
# ;(defun foreign_peterbot ()

# ;#+SBCL (alien-funcall (extern-alien "peterbot"        (function int)))
# ;#-SBCL (c_peterbot) 
# ;)
# ;-------------------------------------------------------------------------------
# ;
# ;
# ;-------------------------------------------------------------------------------


# ;/****************************************************************************/        
# ;#ifdef __cplusplus                                                                
# ;extern "C" {                                                                     
# ;#endif                                                                          
# ;/****************************************************************************/   
# ;/*----------------------------------------------------------------------------*/
# ;//  First RoShamBo Tournament Test Suite   Darse Billings,  Oct 1999 
# ;//                                                 revised July 2000  
# ;//                                                                  
# ;// Эта программа может свободно использоваться и модифицироваться, 
# ;// до тех пор пока действует первоначальное авторское разрешение.
# ;// 
# ;// Не дается никагого рода гарантий.
# ;// 
# ;// Алгоритмы RoShamBo игроков, содержащиеся в этом тестовом наборе,
# ;// были щедро подарены их авторами. Участники будущих соревнований могут 
# ;// основываться на этих идеях, но необходимо давать ссылки (credit) на 
# ;// первоначальных авторов. Любой участник, слишком похожий на не указанную
# ;// существующую программу, будет исключен без дальнейших рассмотрений.
# ;// 
# ;//        http://www.cs.ualberta.ca/~darse/rsbpc.html                
# ;/*----------------------------------------------------------------------------*/

# ;/*----------------------------------------------------------------------------*/

# ;/*  Index of RoShamBo Player Algorithms:

# ; Rank  Dummy Bot         Open BoB  Leng      -max  level history use

# ;  27 * Random (Optimal)   32  19     1       [-0]    L0  h0
# ;   - * Good Ole Rock       -   -     1       [-1000] L0  h0
# ;   - * R-P-S 20-20-60      -   -     1       [-1000] L0  h0
# ;   - * Rotate R-P-S        -   -     1       [-1000] L0  h0
# ;   - * Beat Last Move      -   -     1       [-1000] L1 oh1
# ;   - * Always Switchin'    -   -     3       [-500]  L0 mh1
# ;   - * Beat Frequent Pick  -   -    11       [-1000] L1 oh1
    
# ;  21 * Pi                 31   9     5       [-1000] L0  h0
# ;  49 * Switch A Lot       45  49     3       [-320]  L0 mh1
# ;  40 * Flat               40  44    16       [-420]  L0 mh1
# ;   - * Anti-Flat           -   -    16       [-1000] L1 oh1
# ;  32 * Foxtrot            36  22     4       [-500]  L0 mh1
# ;  16 * De Bruijn          28   3     5       [-500]  L0  h0
# ;  46 * Text               41  52     5       [-ukn]  L0  h0
# ;  29 * Anti-rotn          22  32    40       [-40]   L1 oh2 +fail-safe
# ;  45 * Copy-drift         39  50     9       [-500]  L0 oh1
# ;  48 * Add-react          43  51     9       [-800]  L0 bh1 +gear-shifting
# ;  42 * Add-drift          38  47     9       [-500]  L0 bh1

# ; Rank Entrant           Open BoB  Leng Nat  Author

# ;   1  Iocaine Powder      1   1   134  USA  Dan Egnor
# ;   2  Phasenbott          2   2    99  USA  Jakob Mandelson
# ;   3  MegaHAL             3   7   149  Aus  Jason Hutchens
# ;   4  RussRocker4         4   8   120  USA  Russ Williams
# ;   5  Biopic              6   6    80  Can  Jonathan Schaeffer
# ;   7  Simple Modeller     7  13   135   UK  Don Beal
# ;  14  Simple Predictor    9  21    63   UK  Don Beal
# ;   8  Robertot            8  12    53  Ger  Andreas Junghanns
# ;  10  Boom               10  18   208  Net  Jack van Rijswijk
# ;  11  Shofar             17  11    98  USA  Rudi Cilibrasi
# ;  13  ACT-R Lag2         15  14    20  USA  Dan Bothell, C Lebiere, R West
# ;  15  Majikthise         25   5    62  Can  Markian Hlynka
# ;  18  Vroomfondel        24  10    62  Can  Markian Hlynka
# ;  17  Granite            11  23    97  Can  Aaron Davidson
# ;  19  Marble             12  24    95  Can  Aaron Davidson
# ;  22  ZQ Bot             16  26    99  Can  Neil Burch
# ;  24  Sweet Rocky        18  30    36  Mex  Lourdes Pena
# ;  25  Piedra             19  31    23  Mex  Lourdes Pena
# ;  28  Mixed Strategy     23  29    53   UK  Thad Frogley
# ;  38  Multi-strategy     42  38    86  Can  Mark James
# ;  44  Inocencio          48  37    95   UK  Rafael Morales
# ;  50  Peterbot           53  42    43  USA  Peter Baylie
# ;  12  Bugbrain           14  15    51  Can  Sunir Shah
# ;  52  Knucklehead        49  48    30  Can  Sunir Shah

# ;  --  Psychic Friends Network      47  USA  Michael Schatz, F Hill, TJ Walls
# ;      (Unofficial Super-Modified Class, i.e. it cheats)
# ;*/
# ;/*----------------------------------------------------------------------------*/

# ;//==============================================================================
# ;// Результаты оригинального турнира RSB-99 (с конкретным набором srandom(0))
# ;//
# ;// [учитывая ничьи с самим собой (очков на 1 больше получается)] 
# ;// ============================================================ 
# ;//  Match Results (draw <= 50): 

# ;//     Player Name           total  W  L  D 

# ;//   1 * Anti-rotn             27  10  1  7 
# ;//   2 * De Bruijn             19   2  1 15 
# ;//   3 * Copy-drift            19   1  0 17 
# ;//   4 * Add-react             19   1  0 17 
# ;//   5 Beat The Last Move      18   5  5  8 
# ;//   6 Always Switchin'        18   2  2 14 
# ;//   7 Beat Frequent Pick      18   4  4 10 
# ;//   8 * Switch A Lot          18   1  1 16 
# ;//   9 * Flat                  18   2  2 14 
# ;//  10 Good Ole Rock           18   3  3 12 
# ;//  11 * Add-drift             18   0  0 18 
# ;//  12 * Foxtrot               17   0  1 17 
# ;//  13 * Pi                    17   0  1 17 
# ;//  14 * Text                  17   3  4 11 
# ;//  15 Random (Optimal)        16   0  2 16 
# ;//  16 R-P-S 20-20-60          16   2  4 12 
# ;//  17 Rotate R-P-S            16   1  3 14 
# ;//  18 * Anti-Flat             15   3  6  9 
# ;// ============================================================ 


# ;//==============================================================================
# ;// Результаты оригинального турнира RSB-00 (с конкретным набором srandom(0))
# ;// 
# ;//==============================================================================
# ;//  Final results (draw value = 50):
# ;// 
# ;//  Match results (draw <= 50): 
# ;// 
# ;//     Player Name           total  W  L  D 
# ;// 
# ;//   1 Iocaine Powder          69  28  0 13 
# ;//   2 Phasenbott              65  25  1 15 
# ;//   3 Simple Modeller         65  25  1 15 
# ;//   4 MegaHAL                 63  24  2 15 
# ;//   5 RussRocker4             63  24  2 15 
# ;//   6 Biopic                  62  21  0 20 
# ;//   7 Shofar                  60  20  1 20 
# ;//   8 Robertot                59  22  4 15 
# ;//   9 Boom                    58  18  1 22 
# ;//  10 ACT-R Lag2              57  19  3 19 
# ;//  11 Bugbrain                57  18  2 21 
# ;//  12 Majikthise              56  16  1 24 
# ;//  13 Vroomfondel             54  13  0 28 
# ;//  14 Simple Predictor        53  19  7 15 
# ;//  15 Sweet Rocky             49  15  7 19 
# ;//  16 Piedra                  49  16  8 17 
# ;//  17 * Anti-rotn             48  13  6 22 
# ;//  18 Marble                  46  16 11 14 
# ;//  19 Inocencio               46  16 11 14 
# ;//  20 * De Bruijn             45   5  1 35 
# ;//  21 Mixed Strategy          45  12  8 21 
# ;//  22 Granite                 44  17 14 10 
# ;//  23 ZQ Bot                  44  15 12 14 
# ;//  24 * Pi                    42   2  1 38 
# ;//  25 Random (Optimal)        39   0  2 39 
# ;//  26 * Foxtrot               36   2  7 32 
# ;//  27 Multi-strategy          32  13 22  6 
# ;//  28 * Add-drift             30   1 12 28 
# ;//  29 Peterbot                30   9 20 12 
# ;//  30 * Copy-drift            28   0 13 28 
# ;//  31 * Add-react             25   1 17 23 
# ;//  32 Knucklehead             23   5 23 13 
# ;//  33 * Text                  21   2 22 17 
# ;//  34 * Switch A Lot          20   1 22 18 
# ;//  35 * Flat                  20   2 23 16 
# ;//  36 Beat The Last Move      20   5 26 10 
# ;//  37 Always Switchin'        18   1 24 16 
# ;//  38 Rotate R-P-S            17   1 25 15 
# ;//  39 Beat Frequent Pick      17   4 28  9 
# ;//  40 Good Ole Rock           17   3 27 11 
# ;//  41 * Anti-Flat             15   3 29  9 
# ;//  42 R-P-S 20-20-60          15   1 27 13 

# ;/******************************************************************************/
# ;/******************************************************************************/           
# ;#ifdef __cplusplus                                                                
# ;extern "C" {                                                                     
# ;#endif                                                                                     
# ;/******************************************************************************/   

# ;// по возрастанию силы, т.е.  "0 < 1 < 2"  и дальше по кругу

set ::rock      0 ;#define rock      0
set ::paper     1 ;#define paper     1
set ::scissors  2 ;#define scissors  2

# ;#define TRIALS    1000      // кол-во ходов (испытаний) в матче
set ::TRIALS   1000

# ;#define maxrandom 2147483648.0 /* 2^31, ratio range is 0 <= r < 1 */
set ::y_maxrandom 2147483648.0

# ;/******************************************************************************/   

# ;  //extern int trials;   // кол-во ходов (испытаний) в матче
# ;  //#define TRIALS    1000      // кол-во ходов (испытаний) в матче

# ;  //extern int my_history [TRIALS+1];
# ;  //extern int opp_history[TRIALS+1];

# ;extern int *m_history, *o_history;

# ;/******************************************************************************/   

# ;/******************************************************************************/   

# ;int  flip_biased_coin (double prob);
# ;int  biased_roshambo (double prob_rock, double prob_paper);

# ;/******************************************************************************/   

# ;#define T_RSB_RETURN int

# ;/*============================================================================*/
# ;// Random (Optimal) : generate action uniformly at random (optimal strategy)
# ;/*============================================================================*/

# ;T_RSB_RETURN  randbot ();
# ;T_RSB_RETURN  rockbot ();
# ;T_RSB_RETURN  r226bot ();
# ;T_RSB_RETURN  rotatebot (); 
# ;T_RSB_RETURN  copybot (); 
# ;T_RSB_RETURN  switchbot ();
# ;T_RSB_RETURN  freqbot (); 
# ;T_RSB_RETURN  freqbot2 (); 
# ;T_RSB_RETURN  pibot ();  
# ;T_RSB_RETURN  switchalot ();
# ;T_RSB_RETURN  flatbot3 ();  
# ;T_RSB_RETURN  antiflatbot ();
# ;T_RSB_RETURN  foxtrotbot ();
# ;T_RSB_RETURN  debruijn81 ();
# ;T_RSB_RETURN  textbot ();
# ;T_RSB_RETURN  antirotnbot (); 
# ;T_RSB_RETURN  driftbot ();
# ;T_RSB_RETURN  addshiftbot3 ();
# ;T_RSB_RETURN  adddriftbot2 ();

# ;/*============================================================================*/
# ;// End of Simple  Players Algorithms  
# ;/*============================================================================*/

# ;T_RSB_RETURN  predbot (void);
# ;T_RSB_RETURN  robertot (void);
# ;T_RSB_RETURN  boom (void); 
# ;T_RSB_RETURN  naivete (void);
# ;T_RSB_RETURN  markov5 ();
# ;T_RSB_RETURN  markovbails ();
# ;T_RSB_RETURN  granite(); 
# ;T_RSB_RETURN  marble (); 
# ;T_RSB_RETURN  zq_move ();
# ;T_RSB_RETURN  sweetrock ();
# ;T_RSB_RETURN  piedra ();
# ;T_RSB_RETURN  mixed_strategy ();
# ;T_RSB_RETURN  multibot ();
# ;T_RSB_RETURN  inocencio () ;
# ;T_RSB_RETURN  peterbot ();

# ;/******************************************************************************/   

# ;T_RSB_RETURN  iocainebot (void);
# ;T_RSB_RETURN  phasenbott ();
# ;T_RSB_RETURN  russrocker4 ();
# ;T_RSB_RETURN  halbot (void);
# ;T_RSB_RETURN  mod1bot ();  /* Don Beal (UK) simple model builder */
# ;T_RSB_RETURN  shofar (void);
# ;T_RSB_RETURN  biopic ();
# ;T_RSB_RETURN  actr_lag2_decay (void);
# ;T_RSB_RETURN  sunNervebot ();
# ;T_RSB_RETURN  sunCrazybot ();

# ;/******************************************************************************/   

# ;T_RSB_RETURN my_super_bot ();

# ;void rsb_bigtest (int tourneys, int seed); 
# ;void rsb_mintest (int tourneys, int seed); 

# ;void rsb_newtest (int tourneys, int seed); 


# ;/****************************************************************************/   
# ;#ifdef __cplusplus                                                               
# ;}                                                                                
# ;#endif                                                                           
# ;/****************************************************************************/   



# ;/*******************************************************************************
# ; *                                                                             *
# ; *  Имя этого файла: y_rsb_.c                                                  *
# ; *                                                                             *
# ;  ******************************************************************************
# ; */ 
                                                                                            
# ;#include "a_comm.h"

# ;#include "e_tabs.h"
# ;#include "e_tour.h"

# ;#include "y_rsb_.h"

# ;/******************************************************************************/   

# ;int *m_history, *o_history; // тeкущиe указатeли (т.e. зависит от игрока)

# (defvar m_history)           
# (defvar o_history)

# (defvar    p1hist)  ;// а здeсь рeальныe массивы историй
# (defvar    p2hist)

# ;  int p1hist[TRIALS+1], p2hist[TRIALS+1]; // реальные списки ходов 

# ;/******************************************************************************/


# ;-------------------------------------------------------------------------------
# ;void
proc l_history_create_init {} {

  # ;  /* Full History Structure
  # ;    element 0 - число уже сыгранных попыток к текущему времени (т.е. размер массива)
  # ;    element i - действие, бывшее на i-ом ходе  (1 <= i <= trials) 
  # ;  */
  
  set ::p1hist [list_make [1+ $::TRIALS]] 
  set ::p2hist [list_make [1+ $::TRIALS]] 
  
  #set ::p1hist [make-list [expr 1 + $::TRIALS]] 
  #set ::p2hist [make-list [expr 1 + $::TRIALS]] 
  
  # ;  // обнуляем массивы историй
  for {set i 0} {$i <= $::TRIALS} {incr i} {

    setf_nth $i ::p1hist  0 ;# p1hist[i] = 0; 
    setf_nth $i ::p2hist  0 ;# p2hist[i] = 0;
  }
  
  #   ;; вообщe-то нужно только eсли eсть хоть один имортный бот, но пока так!
  history_create_init
  
}
# ;-------------------------------------------------------------------------------
# ;// Играем матч между двумя игроками RoShamBo 
# ;-------------------------------------------------------------------------------
# ;void
proc l_set_history_for_player_1 {} {

  set ::m_history $::p1hist
  set ::o_history $::p2hist
  
  #   ;; импортная
  set_history_for_player_1
}
# ;-------------------------------------------------------------------------------
# ;void
proc l_set_history_for_player_2 {} {

  set ::m_history $::p2hist
  set ::o_history $::p1hist
  
  #   ;; импортная
  set_history_for_player_2
}
# ;-------------------------------------------------------------------------------
# ;int 
proc do_player_1 {bot1} {

  # ;  YT_SIMP prog1 = ((YT_SIMP) bot1);
  # ;  int  p1;
  
  #   ;(format t ".. 21 ~%")
  l_set_history_for_player_1
  #   ;(format t ".. 22 ~%")
  
  # ;  p1  = prog1 ();  
  
  #   (funcall bot1) ; импотрный бот тожe сработаeт чeрeз обeртку
  $bot1

  # ;  return (p1);
}
# ;-------------------------------------------------------------------------------
# ;int 
proc do_player_2 {bot2} {

  # ;  YT_SIMP prog2 = ((YT_SIMP) bot2);
  # ;  int  p2;
  
  l_set_history_for_player_2
  
  # ;  p2  = prog2 ();  
  
  $bot2

  # ;  return (p2);
}
# ;-------------------------------------------------------------------------------
# ;void
proc l_set_last_history {num p1 p2} {

  setf_nth 0    ::p1hist  $num  ;# p1hist[0]++;            // номер последнего хода 
  setf_nth $num ::p1hist  $p1   ;# p1hist[p1hist[0]] = p1; // и история 1-го игрока
  
  setf_nth 0    ::p2hist $num  ;# p2hist[0]++;            // номер последнего хода   
  setf_nth $num ::p2hist  $p2  ;# p2hist[p2hist[0]] = p2; // и история 2-го игрока
  
  puts stderr "p1hist = $::p1hist"
  puts stderr "p2hist = $::p2hist"

  # ;; импортная
  # 
  set_last_history  $p1 $p2 ;# это для си-ботов ?

}
# ;-------------------------------------------------------------------------------
# ;int 
# ;rsb_play_match (void *bot1, void *bot2)
# ;-------------------------------------------------------------------------------
proc rsb_play_match {bot1 bot2} {

  # (let (
  #   ;(dp t) ; debug print
  
  #puts "rsb_play_match:  bot1 = $bot1   bot2 = $bot2"
  
  # ;  int  drawn = 0.05 * TRIALS; // т.е. ничья фиксируется в пределах 5% ;  
  set drawn  [expr {0.05 * $::TRIALS}] 
  #   result      ;  int  result;
  #   p1_p2_score ;  int  p1_p2_score;
  
  #   p1 p2 ;  int  i, p1, p2, 
  
  set num 0 ;# счeтчик ходов (здeсь для удобства, в си нe было!)
  
  #   ;p1hist p2hist
  
  set p1total  0  ;#// сколько выиграет 1-й игрок
  set p2total  0  ;#// сколько выиграет 2-й игрок 
  set ties     0  ;#// сколько ничьих
  #   )
  
  puts [format "\nrsb_play_match .. bot1= %s  bot2= %s \n" $bot1 $bot2]
  # ;  //--------------------------------------------------------------------
  # ;  // 
  # ;  int p1hist[TRIALS+1], p2hist[TRIALS+1]; // реальные списки ходов 

  l_history_create_init
  
  
  # ;  // серия испытаний --------------------------------------------------
  for {set i 1}  {$i <= $::TRIALS} {incr i} {
  
    #  1-й игрок делает ход
    set p1 [do_player_1  $bot1]
    
    if {($p1 < 0) || ($p1 > 2)} {
      #  printf ("Error: return value out of range.\n");
      error "Error: return value out of range"
      #       ;; exit (0);
    }
    
    #      ;; 2-й игрок делает ход
    set p2 [do_player_2  $bot2]
    
    if  {($p2 < 0) || ($p2 > 2)} {
      error "Error: return value out of range"
    }
    
    incf num
    
    puts "p1 = $p1  p2 = $p2 "

    l_set_last_history  $num $p1 $p2
    
    #     (cond 
    #      ((= p1 p2)                             (incf ties))    ; одинаково сходили т.е. ничья       
    #      ((or (= (- p2 p1) 1) (= (- p2 p1) -2)) (incf p2total)) ; победа 2-го игрока          
    #      (t                                     (incf p1total)) ; победа 1-го игрока 
    #      )    
    
    if       {$p1 == $p2}                                 {incf    ties
    } elseif {(($p2 - $p1) == 1) || (($p2 - $p1) == -2)}  {incf p2total
    } else                                                {incf p1total}   
    
  }
  # ;  // серия испытаний закончена (т.е. матч) --------------------
  
  set p1_p2_score [expr {$p1total - $p2total}]
  
  #   ;; если побед (поражений) статистически достаточно, то записываем общую 
  #   ;; победу (поражение) в матче;   
  #   ;; иначе признается ничья в матче;      
  
  if       {$p1_p2_score  >   $drawn}  {set result "GAME_WIN"
  } elseif {$p1_p2_score  < - $drawn}  {set result "GAME_LOS"
  } else                               {set result "GAME_DRA"}   
  
  return $result
}
# ;===============================================================================

# ;//typedef int (*T_RSBPROG) (); 

# ;//#define BOT_MAKE(prog) (bot_make (prog, 0,0,0,0))
# ;//#define BOT_MAKE(prog) (prog)

# ;/*----------------------------------------------------------------------------*/
# ;///////////////////////////////////////////////////////////////////////////////
# ;/*----------------------------------------------------------------------------*/
# ;void 
# (defun rsb_mintest_add_bots (
#        tur ; YT_TURNIR *tur
#        )

# ;  //bottop_add_bot (top, "bubblesort"       , sbot, 0,0,  (long) bubblesort,       0);
#   (turnir_add_player  tur  "Random (Optimal)"    'randbot)

#   (turnir_add_player  tur  "Good Ole Rock"       'rockbot)
#   (turnir_add_player  tur  "R-P-S 20-20-60"      'r226bot)
#   (turnir_add_player  tur  "Rotate R-P-S"        'rotatebot)
#   (turnir_add_player  tur  "Beat The Last Move"  'copybot)
#   (turnir_add_player  tur  "Always Switchin'"    'switchbot)
#   (turnir_add_player  tur  "Beat Frequent Pick"  'freqbot2)
#   ; (turnir_add_player  tur  "* Pi"                'foreign_pibot) - удалили

#   (turnir_add_player  tur  "* Switch A Lot"      'switchalot)
#   (turnir_add_player  tur  "* Flat"              'flatbot3)

#   ;//turnir_add_bot (tur,   "* Anti-Flat"       ,  antiflatbot  );
#   (turnir_add_player  tur  "* Foxtrot"           'foxtrotbot)
#   ;(turnir_add_player  tur  "* De Bruijn"         'foreign_debruijn81)  - удалили
#   ;(turnir_add_player  tur  "* Text"              'foreign_textbot)     - удалили
#   ;(turnir_add_player  tur  "* Anti-rotn"         'foreign_antirotnbot) - удалили
#   (turnir_add_player  tur  "* Copy-drift"        'driftbot)
#   ;(turnir_add_player  tur  "* Add-react"         'foreign_addshiftbot3) - удалили
#   (turnir_add_player  tur  "* Add-drift"         'adddriftbot2)

# )
# ;/******************************************************************************/
# ;/*----------------------------------------------------------------------------*/
# ;void 
# (defun rsb_bigtest_add_bots (
#        tur; YT_TURNIR *tur
#        )

# ;  //
# ;  (rsb_mintest_add_bots  tur)
# ;  //
# ;  // выход полного тeста с мин-набором: (пока отключим до полного пeрeноса в Лисп!)
# ;  //
# ;/* []$ v_test rsb_big 2010 1 */

# ;/* -------------------------------------------------------------------  */

# ;/*   1 Random (Optimal)   ========+=================-============ */
# ;/*   2 Good Ole Rock      ==+=-=-=====+-===---------------------- */
# ;/*   3 R-P-S 20-20-60     =-=+-=-======-==+---------------------- */
# ;/*   4 Rotate R-P-S       =============-=-=---------------------- */
# ;/*   5 Beat The Last Move =++==-+=--==+-===------=-=+------------ */
# ;/*   6 Always Switchin'   ====+========-=+=------------------=--- */
# ;/*   7 Beat Frequent Pick =++=---==-=-+-===---------------------- */
# ;/*   8 * Pi               ============-+====================+==== */
# ;/*   9 * Switch A Lot     ====+========-====-----------------=--- */
# ;/*  10 * Flat             ====+=+======-===-------==--=------=--- */
# ;/*  11 * Foxtrot          =========++======---==-+=============-= */
# ;/*  12 * De Bruijn        ======+====================+=-+======== */
# ;/*  13 * Text             =-==-=-+=====-===--------==-----------= */
# ;/*  14 * Anti-rotn        =++++++=++==+==+=--==-==-==-=+-=-===+++ */
# ;/*  15 * Copy-drift       =================------==+=---==--==--- */
# ;/*  16 * Add-react        ===+=====+=======--------==-=---------= */
# ;/*  17 * Add-drift        =================----===-==-=-==-==-=== */
# ;/*  18 Iocaine Powder     =++++++==++=+=+++=+++==+===+==+++===+++ */
# ;/*  19 RussRocker4        +++++++=+++-=++++-=-=====+=+==++++==+++ */
# ;/*  20 MegaHAL            =++++++=++=-+++++-+=-=========+++==++++ */
# ;/*  21 Simple Modeller    =++++++=++==+++++-======+==+==+++=+++++ */
# ;/*  22 Shofar             =++++++=++==+=+======+=-=======+++=++++ */
# ;/*  23 Biopic             =++++++=+++=+++==-=========+==+++==++++ */
# ;/*  24 ACT-R Lag2         =++++++=++==+======+=======+==+++++++++ */
# ;/*  25 Bugbrain           =++++++=++====+++===-=========+++=+++=+ */
# ;/*  26 Majikthise         =+++=++=++=====+===============+=+==++= */
# ;/*  27 Vroomfondel        =+++=++=+====-=+============+===+=+++== */
# ;/*  28 Simple Predictor   =++++++=+==-+=+++--=-======--===+=+++++ */
# ;/*  29 Robertot           =++++++-++==++++===-============+=+=+++ */
# ;/*  30 Boom               =++++++=++==++=+=====-=========+++==+=+ */
# ;/*  31 Granite            =++++++=++==+++++--------===--====+=+++ */
# ;/*  32 Marble             -++++++=+++-+=++=---==---=-==-======+++ */
# ;/*  33 ZQ Bot             =++++++=++==++=++--------==--=====+=+++ */
# ;/*  34 Sweet Rocky        =++++++=++==+==++-===--==-====-=====+++ */
# ;/*  35 Piedra             =++++++=++==+==+===-=-==-====-==-===+-+ */
# ;/*  36 Mixed Strategy     =++++++=+===+==+===-===--===---===-++++ */
# ;/*  37 Multi-strategy     =++++++=++==+-+==-------------------=-+ */
# ;/*  38 Inocencio          =++++++=+++=+-+++----=--=---==----=-+=+ */
# ;/*  39 Peterbot           =++++++=++===-===---------=-----------= */


# ;/* FINAL SORTETED RESULTS:   */

# ;/* -------------------------------------------------------------------  */
# ;/*       Player Name           total    +   =   -  */

# ;/*   1)  Iocaine Powder         126     48  30   0  */
# ;/*   2)  Simple Modeller        119     43  33   2  */
# ;/*   3)  RussRocker4            117     44  29   5  */
# ;/*   4)  MegaHAL                117     44  29   5  */
# ;/*   5)  Biopic                 116     39  38   1  */
# ;/*   6)  Shofar                 113     37  39   2  */
# ;/*   7)  ACT-R Lag2             113     37  39   2  */
# ;/*   8)  Bugbrain               112     36  40   2  */
# ;/*   9)  Boom                   111     35  41   2  */
# ;/*  10)  Robertot               107     32  43   3  */
# ;/*  11)  Simple Predictor       101     35  31  12  */

# ;/*  12)  Vroomfondel             99     23  53   2  */
# ;/*  13)  Majikthise              98     22  54   2  */
# ;/*  14)  Sweet Rocky             96     28  40  10  */
# ;/*  15)  Granite                 93     33  27  18  */
# ;/*  16)  ZQ Bot                  89     33  23  22  */
# ;/*  17)  * Anti-rotn             89     27  35  16  */
# ;/*  18)  Piedra                  88     25  38  15  */
# ;/*  19)  Marble                  86     28  30  20  */
# ;/*  20)  Mixed Strategy          86     24  38  16  */
# ;/*  21)  * De Bruijn             85      8  69   1  */
# ;/*  22)  * Pi                    79      3  73   2  */
# ;/*  23)  Random (Optimal)        78      2  74   2  */
# ;/*  24)  Inocencio               77     30  17  31  */
# ;/*  25)  * Foxtrot               70      3  64  11  */
# ;/*  26)  Multi-strategy          59     23  13  42  */
# ;/*  27)  * Add-drift             58      0  58  20  */
# ;/*  28)  Peterbot                54     17  20  41  */
# ;/*  29)  * Copy-drift            52      1  50  27  */
# ;/*  30)  * Add-react             44      3  38  37  */
# ;/*  31)  * Flat                  41      4  33  41  */
# ;/*  32)  Beat The Last Move      40      9  22  47  */
# ;/*  33)  Always Switchin'        37      4  29  45  */
# ;/*  34)  * Text                  36      2  32  44  */
# ;/*  35)  * Switch A Lot          36      2  32  44  */
# ;/*  36)  Good Ole Rock           32      4  24  50  */
# ;/*  37)  Beat Frequent Pick      31      7  17  54  */
# ;/*  38)  Rotate R-P-S            29      0  29  49  */
# ;/*  39)  R-P-S 20-20-60          28      2  24  52  */

# ;/* -------------------------------------------------------------------  */


# ;  //-----------------------------------------------------
#   (turnir_add_player  tur "Iocaine Powder"     'foreign_iocainebot)
# ;  //
# ;  //turnir_add_bot (tur,  "Phasenbott"        ,  phasenbott      );
# ;  // почему-то этот бот дает случайные флуктуации !!!!!!!!!!!!!!!
# ;  // пока временно отключим его....
# ;  //-----------------------------------------------------

#   (turnir_add_player  tur  "RussRocker4"        'foreign_russrocker4)
#   (turnir_add_player  tur  "MegaHAL"            'foreign_halbot)
#   (turnir_add_player  tur  "Simple Modeller"    'foreign_mod1bot)
#   (turnir_add_player  tur  "Shofar"             'foreign_shofar)
#   (turnir_add_player  tur  "Biopic"             'foreign_biopic)
#   (turnir_add_player  tur  "ACT-R Lag2"         'foreign_actr_lag2_decay)
#   (turnir_add_player  tur  "Bugbrain"           'foreign_sunNervebot)

# ;  //turnir_add_bot (tur,  "Knucklehead"       ,  sunCrazybot     );
# ;  //-----------------------------------------------------
 
#   ;(turnir_add_player  tur  "Majikthise"         'foreign_markov5)     - удалили 
#   ;(turnir_add_player  tur  "Vroomfondel"        'foreign_markovbails) - удалили 

#   ;(turnir_add_player  tur  "Simple Predictor"   'foreign_predbot)
#   ; arithmetic error FLOATING-POINT-INVALID-OPERATION signalled - исправлeно !
#   ;; хотя eн увeрeн !

#   (turnir_add_player  tur  "Robertot"           'foreign_robertot)
#   ;(turnir_add_player  tur  "Boom"               'foreign_boom) ; похожe с дeлeниeм на нуль!

#   ;(turnir_add_player  tur  "Granite"            'foreign_granite) - удалили 
#   ;(turnir_add_player  tur  "Marble"             'foreign_marble) - удалили 
#   ;(turnir_add_player  tur  "ZQ Bot"             'foreign_zq_move) - удалили 
#   ;(turnir_add_player  tur  "Sweet Rocky"        'foreign_sweetrock) - удалили 

#   ;(turnir_add_player  tur  "Piedra"             'foreign_piedra) - удалили 
#   ;(turnir_add_player  tur  "Mixed Strategy"     'foreign_mixed_strategy)- удалили 
#   ;; ---- даeт ошибку в foreign_boom (бeз foreign_predbot)!

# ;  (turnir_add_player  tur  "Multi-strategy"     'foreign_multibot) - удалили 
# ;  arithmetic error DIVISION-BY-ZERO signalled - само исправилось !!!

# ;  (turnir_add_player  tur  "Inocencio"          'foreign_inocencio)- удалили 
# ;  (turnir_add_player  tur  "Peterbot"           'foreign_peterbot) - удалили 

# ;  // ошибка в работе бота..
# ;  // turnir_add_bot (tur,  "Psychic Friends N", RST_ULTIMATE_ANALYZER_FUNCTION);

# )
# ;/*============================================================================*/

# ;#define PRINT_LONGLINE printf ("------------------------------------------------------------------- \n");
  
proc PRINT_LONGLINE {} { 

  puts "------------------------------------------------------------------- "
}
  
# ;/*============================================================================*/
# ;void 
proc rsb_mintest {tur_nums seed} {

  # (let (
  
  # ;  YT_TURNIR *tur = turnir_create (60, rsb_play_match, TRUE);
  set tur  [turnir_create  60 "rsb_play_match" $::TRUE]
  #   )
  
  # ;  //
  #   ;(format t "1 ... ~%")
  rsb_mintest_add_bots  $tur
  #   ;(format t "2 ... ~%")
  # ;  //
  
  # ;  PRINT_LONGLINE;
  # ;  printf ("\n");

  PRINT_LONGLINE
  puts ""
  
  # ;  turnir_calc (tur, tur_nums, seed);

  turnir_calc  $tur $tur_nums $seed
  
}
# ;-------------------------------------------------------------------------------
proc  rsb_run_turnir {tur_nums seed list_bots} {

  # (let (

  # ;  YT_TURNIR *tur = turnir_create (60, rsb_play_match, TRUE);

  set tur  [turnir_create  60 "rsb_play_match" $::TRUE]
  #   )
  
  #   ;(format t "rsb_run_turnir ... 1 ~%")
  
  # ;  (turnir_add_player  tur  "Random (Optimal)"   'randbot)
  # ;  (turnir_add_player  tur  "Good Ole Rock"      'rockbot)
  # ;  (turnir_add_player  tur  "R-P-S 20-20-60"     'r226bot)
  
  foreach i $list_bots {

    set name [first  $i]
    set prog [second $i]
    #puts "name = $name  prog = $prog  .................."

    turnir_add_player  $tur $name $prog
  }
  
  PRINT_LONGLINE
  puts ""
  
  #   ;(format t "rsb_run_turnir: tur=~s tur_nums=~s seed=~s ~%")
  turnir_calc  $tur $tur_nums $seed
  
  puts ""

}
# ;-------------------------------------------------------------------------------
# (defun rsb_newtest (tur_nums seed  )

# (let (
#   (list_bots (list 
#              '("Random (Optimal)"    randbot)
#              '("Good Ole Rock"       rockbot)
#              '("R-P-S 20-20-60"      r226bot)

#              '("Rotate R-P-S"        rotatebot)
#              '("Beat The Last Move"  copybot)
#              '("Always Switchin'"    switchbot)

# ;             '("Beat Frequent Pick"  freqbot2)
# ;             '("* Switch A Lot"      switchalot)
# ;             '("* Flat"              flatbot3)
# ;             '("* Anti-Flat"         antiflatbot) ; // закоммeнтировано почeму?
# ;             '("* Foxtrot"           foxtrotbot)

# ;             '("* Copy-drift"        driftbot)
# ;             '("* Add-drift"         adddriftbot2)

# ;---------------------------------------------------------------
# ;             '("Mixed Strategy"     mixed_strategy)
# ; пeрeбираeт всю историю, поэтому слишком мeдлeнно, оставим только
# ; рeзультаты тeста:

# ;  1 Random (Optimal)   ====
# ;  2 Good Ole Rock      ==+-
# ;  3 R-P-S 20-20-60     =-=-
# ;  4 Mixed Strategy     =++=

# ;  1)  Mixed Strategy          12    4   4   0   
# ;  2)  Good Ole Rock            8    2   4   2   
# ;  3)  Random (Optimal)         8    0   8   0   
# ;  4)  R-P-S 20-20-60           4    0   4   4   
# ;---------------------------------------------------------------

# ;  turnir_add_player (tur, "Piedra"            , piedra); ; а этот eщe нe сдeлан

#              ))
#   )
# ;---------------------------------------------------------------
# ;---------------------------------------------------------------
#   ;(format t "rsb_newtest... 1 ~%")

#   (rsb_run_turnir  tur_nums seed list_bots)
# ))
# ;-------------------------------------------------------------------------------
# ;ERORR:


# ;------------------------------------------------------------------- 
# ;[]$ sl v~.cl TEST rsb_new_main

# ;  1 Beat Frequent Pick --+-=
# ;  2 * Flat             +=-==
# ;  3 * Anti-Flat        -+===
# ;  4 * Foxtrot          =====
# ;  5 * Copy-drift       =====


# ;FINAL SORTETED RESULTS:  

# ;      Player Name          total    +   =   - 

# ;  1)  * Foxtrot               11    1   9   0   
# ;  2)  * Flat                  10    2   6   2   
# ;  3)  * Anti-Flat             10    2   6   2   
# ;  4)  * Copy-drift            10    0   10  0   
# ;  5)  Beat Frequent Pick       9    3   3   4   
# ;------------------------------------------------------------------- 



# ;------------------------------------------------------------------- 
# ;[]$ y~test rsb_new 2010 1

# ;  1 Beat Frequent Pick --+-=
# ;  2 * Flat             +=-==
# ;  3 * Anti-Flat        -+===
# ;  4 * Foxtrot          ===+=
# ;  5 * Copy-drift       =====


# ;FINAL SORTETED RESULTS:  

# ;      Player Name           total    +   =   - 

# ;  1)  * Foxtrot               11      2   7   1 
# ;  2)  * Flat                  10      2   6   2 
# ;  3)  * Anti-Flat             10      2   6   2 
# ;  4)  * Copy-drift            10      0  10   0 
# ;  5)  Beat Frequent Pick       9      3   3   4 

# ;------------------------------------------------------------------- 


# ;-------------------------------------------------------------------------------
# ;void 
# (defun rsb_bigtest (
#        tur_nums ; int tur_nums, 
#        seed     ; int seed
#        )

# (let (
#   (tur  (turnir_create  60 'rsb_play_match t)) 
#   )

# ;  //
#   (rsb_bigtest_add_bots  tur)
# ;  //

# ;  PRINT_LONGLINE;
# ;  printf ("\n");
#   (PRINT_LONGLINE)
#   (format t "~%")

#   (turnir_calc  tur tur_nums seed)
# ))
# ;-------------------------------------------------------------------------------
# (defun simple_test ()

# (let (
#   p1 p2
#   )

#   (history_create_init)

#   (set_history_for_player_1)
#   (setf p1 (foreign_russrocker4))

#   (set_history_for_player_2)
#   (setf p2 (foreign_russrocker4))

#   ;(format t "p1= ~s  p2= ~s  ~%" p1 p2)
#   (set_last_history  p1 p2)

# ))
# ;-------------------------------------------------------------------------------

# ;(simple_test)

# ;-------------------------------------------------------------------------------
