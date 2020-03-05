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

; фигня все это.. надо по-честному отлавливать исключительные события
; и отмечать таких особей , как не пригодных ..
; 
; ну а пока это не сделал, надо отлаживаться на булевских функциях - у них
; не бывает переполнений!
;-------------------------------------------------------------------------------

(defvar *flag_error*  :unbound) ; это как раз чтоб отлавливать ошибку...


;-------------------------------------------------------------------------------
(defun % (numerator denominator)

  ;(values 
  (if (= 0 denominator) 
      (progn
        ;(format t ".............. = 0 denominator .............  ~%")        
        ;(setf *flag_error* t)
        ;100000000000000000000000000000

        1 ; почему так ??  
        ;; тем более, что и при малых значених тоже будет переполнение!

        ;; надо здесь еще подумать: либо ставить число ближе к реальному
        ;; либо формировать исключение и потом его обрабатывать
        ;; хотя тут вообще ДВА оператора! numerator denominator
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
      1.0 ;; вернуть какое-нибудь число, чтоб остальная цепочка вычисления
          ;; могла закончиться
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
; Eсли понадобиться работа с дeрeвьями (напримeр в пeрeборном Прологe)
; то вынeсти эту часть в отдeльный файл обратно.
;
;;;=============================================================================
;;;=============================================================================
;;;


(defvar *fmin* -5.0)
(defvar *fmax* +5.0)
;
;-------------------------------------------------------------------------------
; случайный выбор терминала из терминального набора;
; если выбранный терминал - особое эфимерное значение, то для них соответственно:
;
; если :Floating-Point-Random-Constant то
;   создается вещественная единичной точности случайная константа [-5.0 , 5.0]
;
; если :Integer-Random-Constant то
;   создается целая случайная константа в диапазоне [-10 , +10]
;-------------------------------------------------------------------------------
(defun choose-from-terminal-set (terminal-set)

(let* ( ; локальные переменные
  (choice_int (random-integer (length terminal-set)))
  (choice     (nth choice_int terminal-set))

  ;(choice (nth (random-integer (length terminal-set)) terminal-set))
  )

  (case choice

    (:floating-point-random-constant
     ;; двойная точность более "дорогая", но если она действительно нужна
     ;; достаточно просто упростить клозу, убрав "coerce";
     ;; также здесь можно изменить диапазон, если нужен не [-5.0 , +5.0]
     ;(coerce (- (random-floating-point-number 10.0) 5.0)
     (coerce (- (random-floating-point-number (- *fmax* *fmin*)) (- 0.0 *fmin*))
             'single-float))

    (:integer-random-constant 
     (- (random-integer 21) 10)) ; получаем диапазон [-10 , +10]

    (otherwise choice)) ; обычно просто возвращаем выбранный терминал
  
))
;-------------------------------------------------------------------------------
; создать список аргументов для узла в дереве;
;-------------------------------------------------------------------------------
(defun create-arguments-for-function (
            number-of-arguments ; сколько еще остается создать аргументов
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
;   Создаем программу рекурсивно, используя заданные функции и терминалы.  
;-------------------------------------------------------------------------------
(defun create-individual-subtree (
  _list ; fset amap tset
  allowable-depth ; допустимая глубина создаваемого субдерева,
                  ; если 0, то будут выбраны только терминалы;

  top-node-p      ; истина, только когда вызов был от верхнего узла в дереве;
                  ; это позволяет быть уверенным, что мы всегда кладем функцию на верх
                  ; дерева;
  full-p          ; показывает максимально ли эта особь лохмата (пушиста);
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
   ((<= allowable-depth 0) ; уже достигли "maxdepth", поэтому просто упакуем terminal
    (choose-from-terminal-set tset))
   ;; ----------------------------

   ;; ----------------------------
   ((or full-p top-node-p) ; полное или дерево верхний узел, поэтому выбираем только функцию
    ;(let* (
          ;(l (length fset))
          ;(choice  (random-integer l))
          ;choice
    ;      )

      ;(setf choice (random-integer l)) ; почeму всeгда пeрвыe 2 и 3 из чeтырeх???
      ;(if *debug_print* (format t "l= ~A   choice= ~A ~%" l choice))
      (cons_func_args (random-integer (length fset)) ;choice 
                      fset amap tset 
                      allowable-depth full-p)
    ;)
    )
   ;; ----------------------------
   
   ;; ----------------------------
   (:otherwise  ; выбираем из сумки функций и терминалов
    (let (
         (choice (random-integer        ; получаeтся - дeлаeм выбор пропорционально
                  (+ (length tset)      ; длинe списков ?? а надо бы контролировать !!
                     (length fset))))
         )

      (if (< choice (length fset))
          ;; мы выбрали функцию, поэтому вытаскиваем ее и начинаем
          ;; создание дерева вниз отсюда
          (cons_func_args choice 
                          fset amap tset 
                          allowable-depth full-p)

          ;; мы выбрали атом, поэтому вытаскиваем его
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
       maxd ; допустимая глубина субдерева, если 0, то будут выбраны только терминалы 
       t    ; истина, только когда вызов был от верхнего узла в дереве;
            ; это позволяет быть уверенным, что мы всегда кладем функцию на верх дерева
       t    ; показывает максимально ли эта особь "лохмата" (от корнeй до листов)
       )
   )

  (format t "~%")
  (format t "~S ~%" branch)

  (format t "~%")
))
;-------------------------------------------------------------------------------

