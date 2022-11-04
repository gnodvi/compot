; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;;; e_pops.cl
;;;=============================================================================


(defstruct ORGANISM  
  genotype  ; project program 

  (standardized-fitness 0)
  (adjusted-fitness     0)
  (normalized-fitness   0)
  (hits                 0)
)

;;;=============================================================================

(defvar *check_already_created* t)

(defvar *program* :unbound)

;(defvar *get_starter*    #'(lambda (program) program))
(defvar *genotype_print* #'(lambda (genotype) (format t "~S ~%" genotype)))

(defvar *size-of-population* :unbound)
(defvar *best-of-population* :unbound) 

;; метод селекции особей в популяции; это
;; или :fitness-proportionate, :tournament
;; или :fitness-proportionate-with-over-selection
(defvar *method-of-selection*                         :unbound)

(defvar *tournament-size* :unbound
  "The group size to use when doing tournament selection.")

;; хэш-таблица..
;; используется, чтобы гарантировать, что все особи 0-го поколения - уникальны.
;;
(defvar *generation-0-uniquifier-table* (make-hash-table :test #'equal))

;;;=============================================================================

;-------------------------------------------------------------------------------
(defun check-already-created (
       new-genotype 
       population 
 
       ;; меняю значения используя "ссылки"
       r_ind_index r_attempts-at-this-individual 
       do_attempts
       )

(let (
  ;; Turn the defstruct representation of the 'genotype' into a list so that 
  ;; it can be compared using an EQUAL hash table.
  ;; defstruct instances have to be compared with EQUALP
  (program-as-list new-genotype)

  (ind_index                   (symbol-value r_ind_index))
  (attempts-at-this-individual (symbol-value r_attempts-at-this-individual))
  )

  ;;--------------------
  (cond 
   
   ;;-----------------------
   ((not (gethash program-as-list *generation-0-uniquifier-table*))

    ; просто записываем ее в массив
    (setf (aref population ind_index) (make-ORGANISM :genotype new-genotype))
    (incf ind_index)

    (setf (gethash program-as-list *generation-0-uniquifier-table*) t) ;??
    (setf attempts-at-this-individual 0)                               ;??
    )

   ;;-----------------------
   ((> attempts-at-this-individual 20) ;; если попыток создать уже слишком много

    (funcall do_attempts)
    )

   ;;-----------------------
   (:otherwise
    (incf attempts-at-this-individual))
   )  
  ;;--------------------

  (set r_ind_index                    ind_index)
  (set r_attempts-at-this-individual  attempts-at-this-individual)
)) 
;-------------------------------------------------------------------------------
(defun population_set_seeded (pop seeded-genotypes)

(let (
  (num_seeded (length seeded-genotypes))
  new-genotype 
  )

  (do 
      ((i 0))              ; переменная цикла
      ((= i num_seeded)) ; условие окончания
   
    ;; Pick a seeded individual
    (setf new-genotype (nth i seeded-genotypes)) 

    ;; просто записываем ее в массив
    (setf (aref pop i) (make-ORGANISM :genotype new-genotype))
    (incf i)    
  )
  
  ;; Return the population that we've just created.
  pop
))
;-------------------------------------------------------------------------------
(defun population_create_seeded (seeded-genotypes)

(let (
  (num_seeded (length seeded-genotypes))
  pop_min 
  )

  (setf pop_min   (make-array num_seeded))
  (population_set_seeded  pop_min seeded-genotypes)

  (setf *size-of-population*  num_seeded)   

  pop_min
))
;-------------------------------------------------------------------------------
;  создаем популяцию; это - массив размером "size-of-population", который
;  предназначается для хранения индивидуальных записей;

;  слот "program" каждой записи (особи) инициализируется соответствующей
;  случайной программой, за исключением первых N программ, где
;  N = (length seeded-programs); для этих первых N записей определяются
;  конкретно заданные программы; это очень удобно для отладки;
;-------------------------------------------------------------------------------
(defun population_create_news (population i_min i_max
                                create_genotype do_attempts
                                )

(let (
  (attempts-at-this-individual 0)
  new-genotype 
  )
  (declare (special attempts-at-this-individual 
                    ))

  (do 
      ((i    i_min)) ; переменная цикла
      ((>= i i_max)) ; условие окончания
    (declare (special i))    ; чтобы менять эту переменную динамически
   
    ;; Создаeм новый гeнотип (проeкт)
    (setf new-genotype (funcall create_genotype i)) 

    ;; для отладки сдeлаeм два варианта
    (if *check_already_created*
        ;; Check if we have already created this program.
        ;; If not then store it and move on. If we have then try again.
        (check-already-created  new-genotype 
                                population  
                                
                                ;; меняем эти индексы
                                'i  
                                'attempts-at-this-individual do_attempts)       
        (progn
          ;; просто записываем в массив
          (setf (aref population i) (make-ORGANISM :genotype new-genotype))
          (incf i)
          )
    )
    
  )

  ;; Return the population that we've just created.
  population
))
;-------------------------------------------------------------------------------
(defun population_copy_to_from (pop_to pop_from)
(let (
  (pop_from_size (array-dimension pop_from 0))
  )

  (do 
      ((i 0))     ; переменная цикла
      ((= i pop_from_size)) ; условие окончания
   
    ;; просто записываем ее в массив
    (setf (aref pop_to i) (aref pop_from i))
    (incf i)    
  )
  
))
;-------------------------------------------------------------------------------
(defun population_expand (population_min 
                           size_max
                           create_genotype do_attempts
                           )
(let (
  (size_min       *size-of-population*)
  (population_max (make-array size_max))
  )

  (population_copy_to_from  population_max population_min)

  (population_create_news  population_max size_min size_max 
                 create_genotype do_attempts)
  
  ;; Flush out uniquifier table to that no pointers
  ;; are kept to generation 0 individuals.
  (clrhash *generation-0-uniquifier-table*)

  (setf *size-of-population*  size_max) 
  
  ;; Return the population that we've just created.
  population_max
))
;-------------------------------------------------------------------------------
(defun population_create ( 
                           size-of-population
                           seeded-genotypes 
                           create_genotype do_attempts
                           )
(let* (
  (population_min (population_create_seeded  seeded-genotypes))
  )

  (population_expand   population_min
                       size-of-population
                       create_genotype do_attempts
                       )

))
;-------------------------------------------------------------------------------
; печать всей популяции (для отладки)
;-------------------------------------------------------------------------------
(defun population_print (pop &optional (line_print 'format_line75))  

(let (
  (*print-pretty* t) 
  )

  (format_line75) 
  (format t "PRINT-POULATION ~%")
  (format_line75) 
 
  (dotimes (index (length pop))
  (let ( 
     (individual (aref pop index))
     )

    (unless (= index 0) 
      (funcall line_print)
      ) 

    (format t "~2D]   ~5S    ~S ~%"
            index
            (ORGANISM-standardized-fitness individual)
            (ORGANISM-genotype              individual)
            )
  ))

  (format_line75)
))
;-------------------------------------------------------------------------------
; очистить статистику в каждой особи популяции; это не является строго необходимым,
; но позволит избежать некоторых конфузий (например в отладчике..)
;-------------------------------------------------------------------------------
(defun population_zeroize_fitness (pop)

  (dotimes (index (length pop))
    (let ((individual (aref pop index)))

      (setf (ORGANISM-standardized-fitness individual)  0.0)
      (setf (ORGANISM-adjusted-fitness     individual)  0.0)
      (setf (ORGANISM-normalized-fitness   individual)  0.0)
      (setf (ORGANISM-hits                 individual)    0)
    )
  )
)
;-------------------------------------------------------------------------------
(defun population_evaluate_fitness (pop
                                    fitness-function fitness-cases)
(let (
  )

  (dotimes (index (length pop))
    (let* (
         (individual (aref pop index))
         (genotype  (ORGANISM-genotype individual))  
         )

      ;(format t "pop71.. ~%")
      ;; ------------------------------------------
      (setf *program* genotype) ;  r_bool.li: ADF0  ADF1
      ;; ------------------------------------------

      ;(format t "fitness-function= ~S  ~%" fitness-function)
      ;(format t "genotype= ~S  ~%"         genotype)
      ;(format t "*get_starter*= ~S  ~%"    *get_starter*)

      (multiple-value-bind (standardized-fitness hits)
          (funcall fitness-function
                   ;genotype ;
                   genotype ;(funcall *get_starter* genotype) ;starter
                   fitness-cases)

        ;(format t "pop72.. ~%")
        ;; Record fitness and hits for this individual.
        (setf (ORGANISM-standardized-fitness individual) standardized-fitness)
        (setf (ORGANISM-hits                 individual) hits)
      )
      (if *debug_print* (format t "pop73.. ~%"))

    )
  )
))
;-------------------------------------------------------------------------------
; вычислить нормализованный и отрегулированный фитнесс для каждой особи популяции
;-------------------------------------------------------------------------------
(defun population_normalize_fitness (pop)

(let (
  (sum-of-adjusted-fitnesses 0.0)
  )

  (dotimes (index (length pop))
    (let ((individual (aref pop index)))

      ;; Set the adjusted fitness.
      (setf (ORGANISM-adjusted-fitness individual)
            (/ 1.0 (+ 1.0 (ORGANISM-standardized-fitness individual))))

      ;; Add up the adjusted fitnesses so that we can normalize them.
      (incf sum-of-adjusted-fitnesses (ORGANISM-adjusted-fitness individual))
    )
  )

  ;; Loop through population normalizing the adjusted fitness.
  (dotimes (index (length pop))
    (let ((individual (aref pop index)))

      (setf (ORGANISM-normalized-fitness individual)
            (/ (ORGANISM-adjusted-fitness individual)
               sum-of-adjusted-fitnesses))
  ))

))
;-------------------------------------------------------------------------------
; сортируем популяцию по нормализованному фитнесу;
; массив популяции деструктивно модифицируется
;-------------------------------------------------------------------------------
(defun sort-population-by-fitness_0 (population)

  ;; стандартная функция сортировки - может быть быстрее, но по разному
  ;; сделана на разных Лисп-реализациях

  (sort population #'> :key #'ORGANISM-normalized-fitness)

)
;-------------------------------------------------------------------------------
; простой алгорим быстрой сортирвки (надеемся работает одинаково на разных лиспах)
; - сортирует популяцию деструктивно по убыванию фитнесса
;-------------------------------------------------------------------------------
(defun sort-population-by-fitness_1
    (population &optional (low 0) (high (length population)))


  (sort_1 population low high 
          #'ORGANISM-normalized-fitness)

)
;-------------------------------------------------------------------------------
(defun sort_1 (population low high key_func)


(unless (>= (+ low 1) high)
;(when (>= (+ low 1) high) (error "(>= (+ low 1) high)"))

(let* (
  (pivot (funcall key_func (aref population low)))
  (index1 (+ low  1))
  (index2 (- high 1))
  )
  
  (loop 
    (do () ((or (>= index1 high)
                ;(<= (ORGANISM-normalized-fitness (aref population index1)) pivot)))
                (<= (funcall key_func (aref population index1)) pivot)))
      (incf index1))
    
    (do () ((or (>= low index2)
                ;(>= (ORGANISM-normalized-fitness (aref population index2)) pivot)))
                (>= (funcall key_func (aref population index2)) pivot)))
      (decf index2))
    
    (when (>= index1 index2) (return nil))
    (rotatef (aref population index1) (aref population index2))
    (decf index2)
    )
  
  (rotatef (aref population low) (aref population (- index1 1)))

  (sort-population-by-fitness_1 population low index1)
  (sort-population-by-fitness_1 population index1 high)
)

)
  population
)
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; распечатать лучшую особь в конце каждого поколения
;-------------------------------------------------------------------------------
(defun population_report (pop report_name)
  
(let (
  (best-individual    (aref pop 0))
  (size-of-population (length pop))
  (sum                0.0) ; для накопления суммы фитнесов
  (*print-pretty*       t)
  )
  
  ;; вычисляем сумму "standardized fitnesses"
  (dotimes (index size-of-population)
    (incf sum (ORGANISM-standardized-fitness (aref pop index)))
    )
  
  (format_line75)
  (format t "~A ~%" report_name)

  (format t "Average standardized fitness = ~S ~%" (/ sum (length pop)))
  (format t "Best    standardized fitness = ~D and ~D hit~P. ~%"            
          (ORGANISM-standardized-fitness best-individual)
          (ORGANISM-hits                 best-individual)
          (ORGANISM-hits                 best-individual) ; мн. окончание "s"
          )
  (format t "It was: ~%")            

  (funcall *genotype_print* (ORGANISM-genotype best-individual))

  (format_line75)
  (format t "~%")
  
))
;-------------------------------------------------------------------------------
(defun population_utils (pop 
                            fitness-function fitness-cases 
                            sort-population 
                            )

  ;; подчистить фитнесс-измерения
  ;(format t "pop6.. ~%")
  (population_zeroize_fitness  pop)
  
  ;; вычислить фитнесс каждой особи; полученные значения
  ;; сохраняются в самих особях;
  ;(format t "pop7.. ~%")
  (population_evaluate_fitness  pop fitness-function fitness-cases )
  
  ;; нормализовать фитнесс (подготавливая кроссовер и т.д.)
  ;(format t "pop8.. ~%")
  (population_normalize_fitness  pop)
  
  ;(format t "pop9.. ~%")
  ;; отсортировать популяцию для более легкого использования "рулетки";
  (funcall sort-population pop)
  
  (if *debug_print* (format t "pop10.. ~%"))
  (setf *best-of-population* (aref pop 0)) ;; ссылка на лучшую (пeрвую) особь 
                                           ;; в популяции
  
  pop
)
;===============================================================================

;-------------------------------------------------------------------------------
; выцепляем (piks) две случайных особи из популяции и возвращаем одну лучшую
;-------------------------------------------------------------------------------
(defun find-tournament-selection_0 (population)

(let (
  (individual-a (aref population (random-integer (length population))))
  (individual-b (aref population (random-integer (length population))))
  )

  (if (< (ORGANISM-standardized-fitness individual-a)
         (ORGANISM-standardized-fitness individual-b))

      (ORGANISM-genotype individual-a)
      (ORGANISM-genotype individual-b)
    )

))
;-------------------------------------------------------------------------------
;   Picks *tournament-size* individuals from the population at random and
;   returns the best one.
;-------------------------------------------------------------------------------
(defun find-tournament-selection (population)

(let (
  (numbers (pick-k-random-individual-indices *tournament-size* (length population)))
  )

  (loop 
    with best         = (aref population (first numbers))
    with best-fitness = (ORGANISM-standardized-fitness best)

    for number in (rest numbers)
    for individual = (aref population number)
    for this-fitness = (ORGANISM-standardized-fitness individual)

    when (< this-fitness best-fitness)
    do (setf best individual)

    (setf best-fitness this-fitness)

    ;finally (return (ORGANISM-genotype best))
    finally (return best)
    )

))
;-------------------------------------------------------------------------------
; ищем особь в популяции, чей нормализованный фитнесс - больше, чем
; заданное значение;
;
; все что нам нужно, это посчитать по популяции, начиная с начала
; и добавляя (суммируя) фитнесс, пока мы не перейдем заданный предел (?это как?)
;-------------------------------------------------------------------------------
(defun find-fitness-proportionate (
            after-this-fitness ; не должно быть 0 !
            population
            )

;(format *error-output* "----------- ~%")
;(format *error-output* "after-this-fitness = ~s ~%" after-this-fitness)
;(break)

(let* ( ; локальные переменные
  (sum-of-fitness  -0.0)
  (population-size (length population))

  index-of-selected-individual ; была отдельная let, а теперь все внутри let*
  )

  ;----------------------------------------------------
  (SETF index-of-selected-individual 

   (do ((index 0 (+ index 1)))
       ;; условие выхода из цикла
       ((or (>= index population-size)

;-----------------------------------------------------
; какой занк правильнеее?
            (> sum-of-fitness after-this-fitness)  
;            (>= sum-of-fitness after-this-fitness) ; 0 >= 0 
;-----------------------------------------------------
            ) 

        ;; возвращаемое значение
        (if (>= index population-size)
            ;(- (length population) 1)
            (- population-size 1)
            (- index 1)) ; если сразу сработало условие выхода, то зедсь будет -1 !
        )

     ;(format *error-output* "index = ~s ~%" index)

     ;; тело цикла:  суммируем значения фитнесс
     (incf sum-of-fitness
           (ORGANISM-normalized-fitness (aref population index)))
     )
  )
  ;----------------------------------------------------
  ;)
  
;  (format *error-output* 
;          "sum-of-fitness              = ~s ~%" sum-of-fitness)
;  (format *error-output* 
;          "after-this-fitness          = ~s ~%" after-this-fitness)
;  (format *error-output* 
;          "population-size             = ~s ~%" population-size)
;  (format *error-output* 
;          "index-of-selected-individual= ~s ~%" index-of-selected-individual)
;  (format *error-output* "----------- ~%")
;  (exit)

  ;; возвращаeм ссылку на ГEНОТИП особи
  ;(ORGANISM-genotype
  ; (aref population index-of-selected-individual))

  (aref population index-of-selected-individual)

))
;-------------------------------------------------------------------------------
;   Picks a random number between 0.0 and 1.0 biased using the
;   over-selection method.
;-------------------------------------------------------------------------------
(defun random-floating-point-number-with-over-selection 
  (population)

(let (
  (pop-size (length population))
  )

  (when (< pop-size 1000)
    (error "A population size of ~D is too small for over-selection." pop-size))

  (let ((boundary (/ 320.0 pop-size)))
    ;; The boundary between the over and under selected parts.

    (if (< (random-floating-point-number 1.0) 0.8) ; 80% are in the over-selected part

      (random-floating-point-number boundary)

      (+ boundary
         (random-floating-point-number (- 1.0 boundary))))
  )
  
))
;-------------------------------------------------------------------------------
;   Ищем особь в популяции в соответствии с заданным методом селекции
;   
;-------------------------------------------------------------------------------
(defun find_organism (population)

  (ecase *method-of-selection*

    (:tournament (find-tournament-selection
                  population))

    (:fitness-proportionate-with-over-selection
          (find-fitness-proportionate
                 (random-floating-point-number-with-over-selection population)
                 population))

    (:fitness-proportionate   ; ---->
          (find-fitness-proportionate
                 (random-floating-point-number 1.0) ; далo 0!
                 population))
  )
)
;-------------------------------------------------------------------------------
(defun find_genotype (population)
(let (
  organism
  )

  (setf organism (find_organism population))

  (ORGANISM-genotype organism)
))
;;;=============================================================================
;;;
;===============================================================================
;-------------------------------------------------------------------------------
(defun pops_0_eval	             
  (program fitness-cases)	                                     

(declare (ignore  program fitness-cases))	                     

(let (fitn hits
   ) 
  
  (setf fitn (random-floating-point-number 1.0))

  (setf hits (random-integer 5))

  (values fitn hits )
))	                                                             
;-------------------------------------------------------------------------------
(defun pops_0 (argus)  

(declare (ignore argus))

(let (
  (pop (population_create_seeded (list 
                           '(1 2 3 4 5) 
                           '(6 7 8 9 0)
                           '(0.1  0.2  0.3  0.4  0.5) 
                           )
                          ))
  )

  (population_print pop)
  ;(setf *debug_print* t)

  (population_utils pop 
                    'pops_0_eval  NIL ; fitness-cases 
                    ;'evaluate-sfitness-test1 NIL ; fitness-cases 
                    'sort-population-by-fitness_0 
                    )

  (population_print pop)
  (population_report pop "REPORT:")

  (format t "~%")
))
;===============================================================================
;-------------------------------------------------------------------------------
(defun pops_kernel_init ()

  ;(setf *get_starter*  #'(lambda (program) (nth *l-1* program)))
  ;(setf *genotype_print* (lambda (genotype) (genotype_print_adf genotype)))
  ;(setf  *get_starter*    #'(lambda (program) program))
  (setf  *genotype_print* #'(lambda (genotype) (format t "~S ~%" genotype)))

)
;-------------------------------------------------------------------------------

(pops_kernel_init)

; eсли нe выполнить инит, то ошибка:
;*** - NTH: :UNBOUND is not a non-negative integer

;===============================================================================





;;;=============================================================================
;;; e_gena.cl
;;;=============================================================================

;;;=============================================================================

;; доля популяции к которой в каждом поколении будет приеменяться
;; фитнесс-пропорциональная репродукция (с реселекцией) 
(defvar *reproduction-fraction* :unbound)

(defvar *crossover-fraction*        :unbound)
(defvar *mutate*     :unbound)
(defvar *crossover*  :unbound)

;; может быть одним из  :grow, :full, :ramped-half-and-half
(defvar *method-of-generation*                        :unbound)

(defvar *best_fitness* 0.0)

;; лучшая особь найденная за этот запуск
(defvar *best-of-run*                      :unbound)

;; поколение в котром была найдена эта "best-of-run" 
(defvar *generation-of-best-of-run*        :unbound)

(defvar *is_print_run_info*  t)

;===============================================================================
;
;-------------------------------------------------------------------------------
(defun define_termination_criterion_FITN (
        curr                                
        maxi	                                     
        best-fitness	                             
        best-hits)

  (declare (ignore curr maxi best-hits))	                     

  (format t "define_termination_criterion_FITN: best-fitness= ~S ~%" best-fitness)

  (<= best-fitness *best_fitness*) 
)	                                                             
;===============================================================================

;-------------------------------------------------------------------------------
(defun ga_print_parameters (maximum-generations)
  
  (format t "~%")
  (format t "Parameters used for this run: ~%")
  (format_line75)

  (format t "Maximum number of Generations:            ~D ~%" maximum-generations)
  (format t "Size of Population:                       ~D ~%" *size-of-population*)

  (format t "Reproduction fraction:                    ~D ~%" *reproduction-fraction*)

  (format t "Selection method:                         ~A ~%" *method-of-selection*)
  (format t "Generation method:                        ~A ~%" *method-of-generation*)
  ;(format t "Randomizer seed:                          ~D ~%" *seed*)

  (format t "Tournament group size: ~41T ~A ~%"  *tournament-size*)
  (format_line75)
)
;-------------------------------------------------------------------------------
; идем циклом по популяции выполняя каждую операцию (т.е, кроссовер, 
; фитнесс-пропорциональную репродукцию, мутацию) пока это соответствуем заданной 
; доле (specified fraction); 
 
; новые созданные программы накапливаются в "new-programs"
; пока вся популяция полностью не используется, а затем новые особи копируются
; на место старых, что уменьшает накладные расходы (consing новых групп особей);
;-------------------------------------------------------------------------------
(defun breed-new-population (population ;new-programs 
                                        )  
(let* (
  (population-size (length population))
  (new-genotypes (make-array *size-of-population*))
  
  ;(fraction_step (/ 1.0 population-size)) 
  ;(fraction     0)
  )

  ;;  переменная  нач.знач.   правило изменения в цикле
  (do ((index        0)
       (fraction     0        (/ index population-size))
       )
      ;; условие окончания цикла [и возвращаемое значение - здесь нет]
      ((>= index population-size)) ;;???
    ;;---------------------------------------------------------

    ;(setf fraction (+ fraction (* index fraction_step)))
    ;(setf fraction (+ fraction (/ index population-size)))

    ;; далее - тело цикла DO:
    (let (
       (genotype_1 (find_genotype population)) ;;  выбрали 1-ю особь
        genotype_2                             ;; (ссылку на гeнотип)   
       )

    (cond 
   
     (;-----------------------------------------------------
      (and (< index (- population-size 1)) 
           (< fraction *crossover-fraction*)
           )
      
      (if *debug_print* (format t "..CROSSOVER ~%"))
      (setf genotype_2 (find_genotype population))

      (multiple-value-bind (new-male new-female)
          (funcall *crossover* genotype_1 genotype_2 fraction)

        (setf (aref new-genotypes      index )  new-male  )
        (setf (aref new-genotypes (+ 1 index))  new-female)
        )
      
      (incf index 2)
      );-----------------------------------------------------
     
     (;-----------------------------------------------------
      (< fraction
         (+ *crossover-fraction* *reproduction-fraction*)
         )
      
      (if *debug_print* (format t "..REPRODUCTION ~%"))
      (setf (aref new-genotypes index) genotype_1)
      (incf index 1)
      );-----------------------------------------------------
     
     (:otherwise                     
      (if *debug_print* (format t "..MUTATE ~%"))
      ;;------------------------------ 
      (setf (aref new-genotypes index) 
            (funcall *mutate* genotype_1)
            )
      ;;------------------------------ 
      (incf index 1) 
     );-----------------------------------------------------
     );-----------------------------------------------------
    

    ;(setf fraction (+ fraction (/ index population-size)))
    )) 
  ;; конец цикла DO;
  ;;---------------------------------------------------------
  
  ;; новые гeнотипы особeй перекопируются на место старых
  (dotimes (index population-size)
    (setf (ORGANISM-genotype (aref population index))
          (aref new-genotypes index))
    )

))
;-------------------------------------------------------------------------------
;  циклить пока не сработает пользовательское условие останова
;-------------------------------------------------------------------------------
(defun execute-generations (population 
                            fitness-cases maximum-generations
                            fitness-function termination-predicate  
                            sort-population is_print)

  ;; инициализируем переменные для записей  "best-of-run"
  (setf *generation-of-best-of-run*   0)
  (setf *best-of-run*               nil)

(let (
  ;; new-programs используется для размножения новой популяции,
  ;; создаем этот массив здесь, чтобы уменьшить "consing"
  ;(new-programs (make-array *size-of-population*))
  )
  
  (dotimes (current-generation maximum-generations) 

    ;; породить новую популяцию на основе текущей (исключая поколение 0)
    (when (> current-generation 0)
      (breed-new-population  population ;new-programs
                             )
      )


    ;(format *error-output* "current-generation ~s ~n" current-generftion)
    ;; теперь "причесывание" уже готовой новой популяции (фитнeс, сортировка и пeчать)
    ;; в том числe - установка ссылки *best-of-population*
    (population_utils population 
                      fitness-function fitness-cases 
                      sort-population 
                      )
          
    (if *debug_print* (population_print population))

    ;; распечатать результаты этой генерации (поколения)
    (if is_print (population_report population
                                    (format nil "Generation ~D:" current-generation)
                                    ))

    ;; отслеживаем особь "best-of-run";
    (when (or (not *best-of-run*)
              (> (ORGANISM-standardized-fitness  *best-of-run*)
                 (ORGANISM-standardized-fitness  *best-of-population*)))
      
      (setf  *best-of-run*  (copy-ORGANISM *best-of-population*)) ; копируeм?!
      (setf  *generation-of-best-of-run*      current-generation)
      )

    (if (not (eq termination-predicate NIL))
    (when (funcall termination-predicate 
                 current-generation
                 maximum-generations ;; надо ли тут пeрeдовать это?
                 (ORGANISM-standardized-fitness *best-of-population*) 
                 (ORGANISM-hits                 *best-of-population*) 
                 )
        ;; заканчиваeм поиск успeшно, провeрив условиe 
        (return-from execute-generations T)) 
    )
    
  )  

  ;(if *debug_print* (format t "DEBUG !!!!!!!!!!! ~%"))

  NIL 
))
;-------------------------------------------------------------------------------
; распечатать особь "best-of-run"
;-------------------------------------------------------------------------------
(defun report-on-run ()

(let ( ; локальные переменные
  (*print-pretty* t) ; здесь глобальная, меняется локально для этой функции
  )

  (format t "~%")
  (format_bord75)
  (format t "THE BEST: ~%")
  (format t "~%")
  (format t "Generation ~D, standardized fitness = ~D and ~D hit~P.  ~%"
          *generation-of-best-of-run*
          (ORGANISM-standardized-fitness *best-of-run*)
          (ORGANISM-hits                 *best-of-run*)
          (ORGANISM-hits                 *best-of-run*)
          )
  
  (format t "It was: ~%")            
  (funcall *genotype_print* (ORGANISM-genotype *best-of-run*))
  (format t "~%")

))
;-------------------------------------------------------------------------------
(defun execute_generations_ (population 
                            maximum-generations 
                            sort_population

                            method-of-selection 
                            fitness-function fitness_cases
                            termination_criterion 
                            crossover_fraction reproduction_fraction
                            _crossover _mutate
                            print_parameters is_print
                            )
(let (
  ret
  )

  (setf *method-of-selection*    method-of-selection)

  (setf *crossover-fraction*     crossover_fraction)
  (setf *reproduction-fraction*  reproduction_fraction) 
  ;; а остальноe - МУТАЦИЯ

  (setf *crossover* _crossover)
  (setf *mutate*    _mutate)

  ;; печатаем таблицу параметров
  (if *is_print_run_info* 
      (funcall print_parameters  maximum-generations) 
  )

  ;(format t "debug_1 ~%")

  (setf ret (execute-generations  population 
                        fitness_cases 
                        maximum-generations fitness-function termination_criterion 
                        sort_population 
                        is_print
                        )
        )

  ;(format t "debug_2 ~%")

  ;(format t "ret= ~S ~%" ret)
  
  ;; в финале печатаем отчет
  (report-on-run)    ; общий 

  ;(format t "ret= ~S ~%" ret)
  ret
))
;;;=============================================================================
;===============================================================================
