; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

; p_real.cl 
;===============================================================================

; For example, the ordinary LISP division function / should not be 
; in the function set of this symbolic regression problem because
; of the possibility of a division by zero. One way to protect against division 
; by zero is to include the protected division function % in the
; function set, instead of the ordinary LISP division function /.

; Alternatively, we could have achieved closure by defining the division function 
; so as to return the symbolic value :undefined and then rewriting each of the 
; ordinary arithmetic functions so as to return the symbolic value :undefined 
; whenever they encounter :undefined as one of their arguments.

; If the square root function can encounter a negative argument or if the 
; logarithm function can encounter a nonpositive argument in a problem where the 
; complex number that ordinarily would be returned is unacceptable, we can 
; guarantee closure by using a protected function. For example, the protected 
; square root function SRT takes one argument and returns the square root of 
; the absolute value of its argument. It might be programmed as
;-------------------------------------------------------------------------------

; ����� ��� ���.. ���� ��-�������� ����������� �������������� �������
; � �������� ����� ������ , ��� �� ��������� ..
; 
; �� � ���� ��� �� ������, ���� ������������ �� ��������� �������� - � ���
; �� ������ ������������!
;-------------------------------------------------------------------------------

(defvar *flag_error*  :unbound) ; ��� ��� ��� ���� ����������� ������...


;-------------------------------------------------------------------------------
(defun % (numerator denominator)

  ;(values 
  (if (= 0 denominator) 
      (progn
        ;(format t ".............. = 0 denominator .............  ~%")        
        ;(setf *flag_error* t)
        ;100000000000000000000000000000

        1 ; ������ ��� ??  
        ;; ��� �����, ��� � ��� ����� �������� ���� ����� ������������!

        ;; ���� ����� ��� ��������: ���� ������� ����� ����� � ���������
        ;; ���� ����������� ���������� � ����� ��� ������������
        ;; ���� ��� ������ ��� ���������! numerator denominator
      )
      (/ numerator denominator)
  )
  ;)
)
;-------------------------------------------------------------------------------
; The Protected Square Root Function
;-------------------------------------------------------------------------------
(defun rSQRT (argument)

  (sqrt (abs argument))

)
;-------------------------------------------------------------------------------
; The Protected Natural Logarithm Function
;-------------------------------------------------------------------------------
(defun rLOG (argument)

  (if (= 0 argument) 
      0 
      (log (abs argument))
      )

)
;-------------------------------------------------------------------------------
(defun rEXP (x)

  (if (or (< x -80) (> x 80)) 
    
    (progn
      (setf *flag_error* t)
      1.0 ;; ������� �����-������ �����, ���� ��������� ������� ����������
          ;; ����� �����������
    )

    (exp  x)
    )
)
;-------------------------------------------------------------------------------
(defun test3 (argus)  (declare (ignore argus))

(let (
   (x -0.052631557)
   y y1 y2 y3
   )

  (format t "~%")
  (format t "x= ~A ~%" x)

  (setf y1 (% X (rEXP 0.46651602)))
  (setf y2 (% (% -1.3165262 X) y1))

  (format t "y1= ~A ~%" y1)
  (format t "y2= ~A ~%" y2) ; -757.7787

  (setf y3 (rEXP y2))
  (format t "y3= ~A ~%" y3)

  (setf y 
        (rEXP y3)
        )

  (format t "y= ~A ~%" y)
  (format t "~%")
))
;;;=============================================================================
; (load "a_tree.cl")
;
; E��� ������������ ������ � �e�e����� (������e� � �e�e������ ������e)
; �� ���e��� ��� ����� � ���e����� ���� �������.
;
;;;=============================================================================
;;;=============================================================================
;;;


(defvar *fmin* -5.0)
(defvar *fmax* +5.0)
;
;-------------------------------------------------------------------------------
; ��������� ����� ��������� �� ������������� ������;
; ���� ��������� �������� - ������ ��������� ��������, �� ��� ��� ��������������:
;
; ���� :Floating-Point-Random-Constant ��
;   ��������� ������������ ��������� �������� ��������� ��������� [-5.0 , 5.0]
;
; ���� :Integer-Random-Constant ��
;   ��������� ����� ��������� ��������� � ��������� [-10 , +10]
;-------------------------------------------------------------------------------
(defun choose-from-terminal-set (terminal-set)

(let* ( ; ��������� ����������
  (choice_int (random-integer (length terminal-set)))
  (choice     (nth choice_int terminal-set))

  ;(choice (nth (random-integer (length terminal-set)) terminal-set))
  )

  (case choice

    (:floating-point-random-constant
     ;; ������� �������� ����� "�������", �� ���� ��� ������������� �����
     ;; ���������� ������ ��������� �����, ����� "coerce";
     ;; ����� ����� ����� �������� ��������, ���� ����� �� [-5.0 , +5.0]
     ;(coerce (- (random-floating-point-number 10.0) 5.0)
     (coerce (- (random-floating-point-number (- *fmax* *fmin*)) (- 0.0 *fmin*))
             'single-float))

    (:integer-random-constant 
     (- (random-integer 21) 10)) ; �������� �������� [-10 , +10]

    (otherwise choice)) ; ������ ������ ���������� ��������� ��������
  
))
;-------------------------------------------------------------------------------
; ������� ������ ���������� ��� ���� � ������;
;-------------------------------------------------------------------------------
(defun create-arguments-for-function (
            number-of-arguments ; ������� ��� �������� ������� ����������
            function-set argument-map terminal-set 
            allowable-depth
            full-p)

(let (
   (_list  (list function-set argument-map terminal-set)) 
)

  (if (= number-of-arguments 0)
      nil
      (cons (create-individual-subtree   
                    _list ; function-set argument-map terminal-set
                    allowable-depth nil full-p)
            (create-arguments-for-function 
                    (- number-of-arguments 1) 
                    function-set argument-map terminal-set
                    allowable-depth full-p))
  )

))
;-------------------------------------------------------------------------------
(defun cons_func_args (
       choice 
       function-set argument-map terminal-set 
       allowable-depth full-p) 

(let (
  (function            (nth choice function-set))
  (number-of-arguments (nth choice argument-map))
  )

  (cons function
        (create-arguments-for-function 
                number-of-arguments 
                function-set argument-map terminal-set
                (- allowable-depth 1) full-p))
))
;-------------------------------------------------------------------------------
;   ������� ��������� ����������, ��������� �������� ������� � ���������.  
;-------------------------------------------------------------------------------
(defun create-individual-subtree (
  _list ; fset amap tset
  allowable-depth ; ���������� ������� ������������ ���������,
                  ; ���� 0, �� ����� ������� ������ ���������;

  top-node-p      ; ������, ������ ����� ����� ��� �� �������� ���� � ������;
                  ; ��� ��������� ���� ���������, ��� �� ������ ������ ������� �� ����
                  ; ������;
  full-p          ; ���������� ����������� �� ��� ����� ������� (�������);
  )
  ;; ------------------------------
  (let (

  (fset (first  _list))
  (amap (second _list))
  (tset (third  _list))
  )   


  (when  NIL
  (format *error-output* "create-individual-subtree .. ~%")
  (format *error-output* "_list = ~s ~%" _list)
  (format *error-output* "allowable-depth = ~s ~%" allowable-depth)
  (format *error-output* "top-node-p      = ~s ~%" top-node-p)
  (format *error-output* "full-p          = ~s ~%" full-p)
  (format *error-output* "~%")
  )


  (cond 

   ;; ----------------------------
   ((<= allowable-depth 0) ; ��� �������� "maxdepth", ������� ������ ������� terminal
    (choose-from-terminal-set tset))
   ;; ----------------------------

   ;; ----------------------------
   ((or full-p top-node-p) ; ������ ��� ������ ������� ����, ������� �������� ������ �������
    ;(let* (
          ;(l (length fset))
          ;(choice  (random-integer l))
          ;choice
    ;      )

      ;(setf choice (random-integer l)) ; ���e�� ��e��� �e���e 2 � 3 �� �e���e�???
      ;(if *debug_print* (format t "l= ~A   choice= ~A ~%" l choice))
      (cons_func_args (random-integer (length fset)) ;choice 
                      fset amap tset 
                      allowable-depth full-p)
    ;)
    )
   ;; ----------------------------
   
   ;; ----------------------------
   (:otherwise  ; �������� �� ����� ������� � ����������
    (let (
         (choice (random-integer        ; ������e��� - �e��e� ����� ���������������
                  (+ (length tset)      ; ����e ������� ?? � ���� �� �������������� !!
                     (length fset))))
         )

      (if (< choice (length fset))
          ;; �� ������� �������, ������� ����������� �� � ��������
          ;; �������� ������ ���� ������
          (cons_func_args choice 
                          fset amap tset 
                          allowable-depth full-p)

          ;; �� ������� ����, ������� ����������� ���
          (choose-from-terminal-set tset))
      ))
   ;; ----------------------------
   )

))
;;;=============================================================================
;
;-------------------------------------------------------------------------------
(defun test (argus) ;(declare (ignore argus))

(let (
  (num   (parse-integer (nth 0 argus)))
  (maxd  2)

  branch _list
  )

  ;(setf *debug_print* t)  
  (seed_set_random)

  (when (= num 0) 
  (setf _list  (list  '(+ - * %)  '(2 2 2 2)  '(:floating-point-random-constant)))
  )

  (when (= num 1) 
  (setf _list (list '(IF-FOOD-AHEAD PROGN PROGN GENA) '(2 2 3 0) '((LEFT) (RIGHT) (MOVE))))
  )


  (setf branch (create-individual-subtree   
       _list 
       maxd ; ���������� ������� ���������, ���� 0, �� ����� ������� ������ ��������� 
       t    ; ������, ������ ����� ����� ��� �� �������� ���� � ������;
            ; ��� ��������� ���� ���������, ��� �� ������ ������ ������� �� ���� ������
       t    ; ���������� ����������� �� ��� ����� "�������" (�� ����e� �� ������)
       )
   )

  (format t "~%")
  (format t "~S ~%" branch)

  (format t "~%")
))
;-------------------------------------------------------------------------------

