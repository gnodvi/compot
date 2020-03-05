; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defmacro GAME-ifs (gptr) `(GAME-param1 ,gptr))
(defmacro GAME-mvs (gptr) `(GAME-param2 ,gptr))

;-------------------------------------------------------------------------------
(defun array_to_list (a)

(let* (
  (len (length a))
  (l   (make-list len))
  )

  (dotimes (index len)
    (setf (nth index l) (aref a index))
    )

  l
))
;-------------------------------------------------------------------------------
(defun genomo_perebor (gameptr num_states
                               main_proc_init main_proc) 

(let* (
  (num_ifedges (list-length (GAME-ifs gameptr)))
  (num_ifmoves (list-length (GAME-mvs gameptr)))

  (dim1   (* num_ifedges num_states)) ; по 2 пeрeхода из каждого состояния
  (set1   num_states)  ; интервал изменения индексов

  (dim2   dim1)
  (set2   num_ifmoves) ; LEFT RIGHT MOVE

  genomo fit genomo_best fitness
  (fit_best  0) ; ищем максимальное значение

  (ijk_cur1 (make-array dim1))
  (IJK1     (make-array dim1)) states li1

  (ijk_cur2 (make-array dim2)) 
  (IJK2     (make-array dim2))   acts li2 am
  )
  ;;----------------------------------------------

  (format t "---------------------------------------------- ~%")

  (ijk_array_set IJK1 set1) ; интeрвал измeнeния индeксов
  (setf states (MFOR_create  dim1 ijk_cur1 IJK1))

  (ijk_array_set IJK2 set2) ; LEFT, RIGHT, MOVE
  (setf acts (MFOR_create  dim2 ijk_cur2 IJK2))

  ;;----------------------------------------------

  (MFOR_init states)
  (loop while (MFOR_todo states) do (progn

    (MFOR_init acts)
    (loop while (MFOR_todo acts) do (progn

    (setf li1 (array_to_list (MF-ijk_cur  states)))
    (setf li2 (array_to_list (MF-ijk_cur  acts)))

    (setf genomo (list li1 li2))  
    (funcall main_proc_init gameptr) ; преддействие

    ; главное действие
    (setf am (amat_from_genomo  gameptr genomo))  
    (multiple-value-setq (fitness fit) (funcall main_proc gameptr am))


    (when (> fit fit_best) ; ищем макс. значение ?!
      (setf fit_best fit)
      (setf genomo_best genomo)
      )

    ;; последействие
    (format t "genomo= ~s  FIT= ~S ~%" genomo fit)
    )) 
  )) 
  
  (format t "~%")
  (format t "genomo_best= ~S  FIT_best= ~S ~%" genomo_best fit_best)
  (format t "~%")

  genomo_best
))
;-------------------------------------------------------------------------------
(defun genomo_perebor_and_calc_best (gameptr num_states
                                             main_proc_init main_proc)

(let* (
  genomo_best am
  )

  (setf genomo_best (genomo_perebor gameptr num_states
                                    main_proc_init main_proc))

  ;; показательный тест для лучшей хромосомы 
  (funcall main_proc_init gameptr)

  (setf am (amat_from_genomo gameptr genomo_best))
  (funcall  main_proc gameptr am)
  
  (game_print)

))
;-------------------------------------------------------------------------------
(defun genotempsym_from_genom-int (gameptr genom-int)

(let* (
  (chromo_stat (first  genom-int))
  (chromo_doit (second genom-int))

  (num_edges (list-length chromo_stat))
  (gts       (make-list  (* 2 num_edges))) ; genotempsym
  )

  (dotimes (i num_edges)
    (setf (nth      (* 2 i)  gts)  (nth i chromo_stat))
    (setf (nth (+ 1 (* 2 i)) gts)  (nth (nth i chromo_doit) (GAME-mvs gameptr)))
    )

  gts ; genotempsym

))
;-------------------------------------------------------------------------------
(defun num_states_from_num_edges (num_edges)

(let (
  (num_states  (/ num_edges 2))
  )

  num_states
))
;-------------------------------------------------------------------------------
(defun get_num_states_from_genomo (genomo)
  
  (/ (list-length (first genomo)) 2)

)
;-------------------------------------------------------------------------------
(defun num_states_from_pre_am (pre_am)

(let* (
  (num_states (/ (list-length pre_am) 4))
  )

  num_states
))
;-------------------------------------------------------------------------------
(defun amat_from_genotempsym (gameptr pre_am)

(let* (
  (w  1.0)
  (num_states  (num_states_from_pre_am  pre_am))
  (if1  (nth 0 (GAME-ifs gameptr)))
  (if2  (nth 1 (GAME-ifs gameptr)))

  g next1 doit1 next2 doit2 e1 e2

  (am  (anet_create))
  (nn     num_states) ; ??
  )

  (if *debug_print* (format t "pre_am= ~s ~%" pre_am))

  (dotimes (u nn)
    (setf g (* 4 u)) ; указатель на квартет

    ; если в текущем состоянии ВЫПОЛНЯЕТСЯ условие
    (setf next1 (nth (+ g 0) pre_am)) ; перейти в указанное состояние
    (setf doit1 (nth (+ g 1) pre_am)) ; сделав это 

    ; если в текущем состоянии YT ВЫПОЛНЯЕТСЯ условие
    (setf next2 (nth (+ g 2) pre_am)) ; перейти в указанное состояние
    (setf doit2 (nth (+ g 3) pre_am)) ; сделав это 

    (setf e1 (make_ifdo_bloc if1 doit1))
    (setf e2 (make_ifdo_bloc if2 doit2))

    (anet_add_gene  am u next1 w e1)
    (anet_add_gene  am u next2 w e2)
    )

  am
))
;-------------------------------------------------------------------------------
(defun get_next_from_genotype (genotype start_position num_states)

(let* (
  l1 next
  (num_state_bits  *num_state_bits*)
  )

  (setf l1 (make-list  num_state_bits))
  
  (dotimes (j num_state_bits)
    (setf (nth j l1) (nth (+ start_position j) genotype))
    )
  
  ;; теперь номер этого следующего состояния в виде целого

  (setf next (int_from_bin  l1 num_state_bits))

  ;; оно может заходить за допустимую границу 
  (when (>= next num_states) (setf next (1- num_states))) ; !!?

  next
))
;-------------------------------------------------------------------------------
(defun get_doit_from_genotype (genotype start_position 
                                        num_bits_for_doit)

(let* (
  l2 doit
  )
  
  (setf l2 (make-list  num_bits_for_doit))

  (dotimes (j num_bits_for_doit) ; 2 ???
    (setf (nth j l2) (nth (+ start_position j) genotype))
    )

  (setf doit (doit_bin_to_sym  l2))

  doit
))
;-------------------------------------------------------------------------------
(defun pre_am_from_one_list (genotype)

(let* (
  (num_bits_for_state  *num_state_bits*)
  (num_bits_for_doit   *num_bits_for_doit*)

  (num_edge_bits  (+ num_bits_for_state num_bits_for_doit))
  (num_edges  (/ (list-length genotype) num_edge_bits ))

  (l_all  (make-list (* 2 num_edges)))
  (num_states (num_states_from_num_edges num_edges))

  p next doit
  )

  ;; берем нужные биты для каждого ребра и переформируем

  (dotimes (i num_edges)
    (setf p (* num_edge_bits i))

    ;; в какое состояние переходим по этому ребру
    (setf next (get_next_from_genotype  genotype p num_states))

    ;; теперь разберемся с действием
    (setf doit (get_doit_from_genotype genotype 
                                       (+ p num_bits_for_state)
                                       num_bits_for_doit))

    (setf (nth      (* 2 i)  l_all) next) ; окончательно запишем след. состояние
    (setf (nth (+ 1 (* 2 i)) l_all) doit)
    )

  l_all
))
;-------------------------------------------------------------------------------
(defun amat_from_bins (gameptr bins)

(let (
  (pre_am (pre_am_from_one_list  bins))
  )

  ;; из спец. хромосомы сделать нормальный автомат
  (amat_from_genotempsym gameptr pre_am)

))
;-------------------------------------------------------------------------------
(defun amat_from_genomo (gameptr genomo)

(let* (
  am pre_am
  )

  (setf pre_am (genotempsym_from_genom-int gameptr genomo))
  (setf     am (amat_from_genotempsym      gameptr pre_am))

  am
))
;-------------------------------------------------------------------------------
(defun get_num_bits_for_integer (value)

(let (
  (n  1)
  (max_val 1)
  )

  (loop 
    (setf max_val (* max_val 2))
    (when (< value max_val) (return))

    (incf n)
    )

  n
))
;-------------------------------------------------------------------------------
(defun set_amat_num_bits (states)

(let (
  (state_bits  (get_num_bits_for_integer(1- states)))
  )

  (setf *num_state_bits* state_bits)
  (setf *num_edge_bits* (+ 2 state_bits)) ; ?? 

))
;-------------------------------------------------------------------------------
(defun doit_translate (val num_val num_ret)

(let( 
  (ret  NIL)
  )

  (dolist (l *doit_tabl*)
    (when (equal val (nth num_val l)) (setf ret (nth num_ret l))
          ))

  (when (eq ret NIL) (error "Not find val in TABL ! ~%"))

  ret
))
;-------------------------------------------------------------------------------
(defun doit_sym_to_bin (sym)

  (doit_translate sym 1 0)

)
;-------------------------------------------------------------------------------
(defun doit_bin_to_sym (bin)

  (doit_translate bin 0 1)

)
;-------------------------------------------------------------------------------
(defun fint_do_step_s (am num)

  ;; начальная установуа вынесена уже в начало

  (dotimes (i num)
    (fint_do_step am))
  
  (GAME-fit *gameptr*)
)
;-------------------------------------------------------------------------------
(defun game_for_bot (am num_steps)

  (if (<= num_steps 0)

  (progn
    (setf *debug_print* t)
    (format t "~%")

    (loop 
      (format t "Press Any Key: ~%")
      (read-char)
      (fint_do_step am)
      (game_print)
      )
    )

  (progn
    (fint_do_step_s  am num_steps)
    (format t "~%")
    (game_print)
    )

  )
)
;-------------------------------------------------------------------------------
;(defun game_for_genomo (gameptr genomo num_states)
(defun game_for_genomo (gameptr genomo num_steps) ;??

(let* (
  (am  (amat_from_genomo  gameptr genomo))
  )

  (anet_print am)

  (game_for_bot  am num_steps)

  (format t "~%")

))
;-------------------------------------------------------------------------------
(defun calc_fitness_proc_genotype_amat (genotype data)

(let* (
  (test_init_proc    (nth 0 data))
  (calc_fitness_amat (nth 1 data))
  (gameptr           (nth 2 data))

  (am  (amat_from_bins  gameptr genotype))
  )

  (funcall test_init_proc    gameptr)
  (funcall calc_fitness_amat gameptr am)
))
;-------------------------------------------------------------------------------
(defun get_best_of_run_genotype ()

  (ORGANISM-genotype *best-of-run*)

)
;-------------------------------------------------------------------------------
(defun amat_ga_test_for_best (gameptr data test_init)

(let* (
  (best_genotype  (get_best_of_run_genotype))
  (am_best        (amat_from_bins  gameptr best_genotype))
  )

  (funcall test_init gameptr)

  (format t "~%")
  (anet_print  am_best)
  (format t "~%")

  (calc_fitness_proc_genotype_amat best_genotype data)
  (game_print)

))
;-------------------------------------------------------------------------------
(defun amat_ga_run_test (gameptr num_states
                                 size-of-population maximum-generation
                                 test_init  test_calc_fitness_amat
                                 crossover-fraction  reproduction-fraction)

(let* (
  (data  (list test_init
               test_calc_fitness_amat
               gameptr))

  n ; размерность генотипа в байтах ??
  (tset '(0 1))
  num_edge_bits
  )

  (set_amat_num_bits  num_states)
  
  (setf num_edge_bits (+ *num_state_bits* *num_bits_for_doit*))
  (setf n (* num_states (* num_edge_bits 2 ))) ; из каждого состояния по 2 выхода

  (pops_kernel_init) ; почему это здесь?

  (lis_run_test  n tset
                 size-of-population  maximum-generation
                 'calc_fitness_proc_genotype_amat  data
                 NIL
                 crossover-fraction  reproduction-fraction)

  ;; показательный тест для лучшего автомата
  (amat_ga_test_for_best  gameptr data test_init)

  (ORGANISM-hits *best-of-run*)
))
;-------------------------------------------------------------------------------
(defun main_amat_test_ga (gameptr argus
                                  test_init test_calc_fitness_amat)
(let* (
  (num_states  (parse-integer     (nth 0 argus)))
  (random_flag (read-from-string (nth 1 argus)))

  (size        (parse-integer     (nth 2 argus))) ; размер популяции
  (maxi        (parse-integer     (nth 3 argus))) ; сколько поколений считать
  )

  (if (eq random_flag '!)
    (seed_set_random)
    (seed_set    1.0)
    )

  (amat_ga_run_test  gameptr num_states
                     size ; size-of-population
                     maxi ; maximum-generation
                     test_init  test_calc_fitness_amat
                     0.4  0.1 ; cros_frac  repr_frac
                     )
))
;-------------------------------------------------------------------------------
;
;===============================================================================

