; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

(defvar *gameptr* :unbound)

(defclass GAME () (
   (param1 :accessor GAME-param1)
   (param2 :accessor GAME-param2)

   (game_print :accessor GAME-print) ; ��������� ������ 
   (fitfull    :accessor GAME-fitfull)    ; ������������ FIT
   (fit        :accessor GAME-fit)        ; ������
   (fitness    :accessor GAME-fitness)    ; ��������� (���������� ������� �� FIT)
))

;-------------------------------------------------------------------------------
(defun game_print ()

  (funcall (GAME-print *gameptr*) *gameptr*)

)
;-------------------------------------------------------------------------------
