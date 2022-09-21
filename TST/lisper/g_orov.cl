; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------

; задача определения координат (1D, 2D) точек по их расстояниям
; 
; MDS - Multidimension Scaling

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

; TODO:

; -) координаты фиксированных точек тоже надо вводить с погрешностями
; -) расстояния тоже могут быть не точны? как быть? варьировать по очереди?
; -) для представления точек и узлов использовать библиотеку графов

; -) cl v_pnts.cl  20   100   30 ; make_test_orovo
; -) cl v_pnts.cl  22   200  200 ; make_real_orovo

;#-------------------------------------------------------------------------------

;(load  "EXT/LSP/src/c-comm.cl")
;(load  "EXT/LSP/src/c-rand.cl")

(load  "a-comm.cl") ; ??? вроде ж уже загрузил?
(load  "a-rand.cl")

;#-------------------------------------------

;(defpackage "OROVOS"
;   (:nicknames    "MYPKG" "MY-PKG")
;   (:use          "COMMON-LISP")
;   (:shadow       "CAR" "CDR" "NULL")

;   ;;   (:shadowing-import-from "VENDOR-COMMON-LISP"  "CONS")
;   ;;   (:import-from  "VENDOR-COMMON-LISP"  "GC")
;   ;;   (:export       "EQ" "CONS" "FROBOLA")
;   )

;(in-package "OROVOS")

;(defvar       NULL NIL)

;#+CLISP (defvar       NULL NIL)
;#+SBCL  (defparameter NULL NIL)

;#-------------------------------------------

;#source "./f-rand.tl"
;#source "./f-comm.tl"

;(load  "EXT/OPT/src/f-sort.cl")
;(load  "EXT/OPT/src/h-core.cl")
;(load  "EXT/OPT/src/h-diff.cl")


(load  "f-sort.cl")

(load  "g-core.cl")
(load  "g-diff.cl")


;# /*****************************************************************************
;; 
;; stefil/duplicates.lisp
;; 
;#-------------------------------------------------------------------------------


(defmacro enable-sharp-boolean-syntax ()
  "Copies *readtable* and enables #t and #f readers for t and nil in the copy."
  '(eval-when (:compile-toplevel :execute)
    (setf *readtable* (copy-readtable *readtable*))
    (%enable-sharp-boolean-syntax)))


(defun %enable-sharp-boolean-syntax ()
  (set-dispatch-macro-character
   #\# #\t
   (lambda (s c n)
     (declare (ignore s c n))
     t))
  (set-dispatch-macro-character
   #\# #\f
   (lambda (s c n)
     (declare (ignore s c n))
     nil)))


(enable-sharp-boolean-syntax)


;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------

; параметры задачи:
; 

;(defvar _new          #f)
;(defvar _new          #t)

;(defvar *seed_points* NIL)
;(defvar *seed_points_index* 0)

(defvar *max_val_arr* NIL)

(defvar *dim*     NIL)
(defvar *n_ext*   NIL)  
(defvar *n_fix*   NIL)


(defvar *max_len_defnode* 5) ; формат записи


(defvar *work_fix_points* NIL) ; для удобства: начальные фиксированные точки
(defvar *work_point*      NIL) ; для удобства: рабочая точка

(defvar *nodes*      NIL)
(defvar *edges*      NIL)


;# /*******************************************************************************
;#-------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
(defun point_from_chromosome (chromosome i)

  ; здесь надо учитывать размерность точек !!
  ;
  ; cначала выпишем координаты в глобальную рабочую точку

  ; (setf (elt point 0) (elt chromosome i))

  (loop :for d :from 0 :below *dim* :do

    (setf (elt *work_point* d) (elt chromosome (+ (* i *dim*) d)))
    )

  (copy-seq *work_point*)
)
;# //------------------------------------------------------------------------------
(defun point_print (point)


  (format t "[") 

  (loop :for d :from 0 :below *dim* :do

    (format t "~9,6F " (elt point d))
    )

  (format t "] " )

)
;# //------------------------------------------------------------------------------
(defun name_by_ind (ind)

(let (
  (name `NAME)
  )

  ;;(loop for n :across *nodes* :do
  ;;
  ;; )

  (setf name (aref *nodes* ind))

  name
))
;# //------------------------------------------------------------------------------
(defun ext_point_print (point ext_ind)

(let* (
  (all_ind  (+ *n_fix* ext_ind))
  (name  (name_by_ind all_ind))
  )


  ;(format t "p~d (~s) = "  all_ind name) 

  ;(format t "p~s = "  name) 

  (format t "~4s = "  name) 

  (point_print point)

))
;# //------------------------------------------------------------------------------
;# //  synopsis:	Generation callback
;# //------------------------------------------------------------------------------
;# static boolean 
;# test_generation_callback (int generation, population *pop)
;# //------------------------------------------------------------------------------
(defun test_generation_callback (generation pop)


  ;(format t "test_generation_callback: generation = ~s ~%" generation)

  ;;  if {[expr {$generation % 10}] == 0} {
  (when (= (mod  generation 10) 0)
  (let* (
    (best (pop_get_entity_  pop  0)) 
     
    ;(format t "pop_get_entity_: r = ~s   ~%" r)

    (best_chromo    (ent_get_chromosome_  best))
    (best_fit       (ENT_FITNESS          best)) ;; [$best cget -fitness] 
    p
    )


    (format t "~3S  : "  generation)

    (when __is_print
      (loop :for i :from 0 :below *n_ext* :do

        (setf p (point_from_chromosome  best_chromo i))
        ;(ext_point_print  point i)
        (ext_point_print  p i)
        )
      )

    (format t "(fitness = ~9,6F) ~%"  best_fit)

    ))
  
  ;;  return true
  true

)
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;(defun find_len_true (edges ind_A ind_B)

;(let* (
;  )

;  (loop for e in edges do 
    
;    (when (and (= (nth 0 e) ind_A) (= (nth 1 e) ind_B))
;      (return-from find_len_true (nth 2 e))
;      )
;    )

;  (die "find_len_true")

;))
;#-------------------------------------------------------------------------------
;(defun calc_err_main (ind_A ind_B  points edges)

;(let* (
;  (A (elt points ind_A))
;  (B (elt points ind_B))

;  (len_true (find_len_true edges  ind_A ind_B))
;  )

;  (calc_err  A B len_true)

;))

;#-------------------------------------------------------------------------------
(defun calc_len (A B)

(let* (
  A_xyz B_xyz
        
  ;len 
  val 
  (sum 0)
  )

  ;(setf a (first A)) ; здесь д.б. сама точка 

  (loop :for d :from 0 :below *dim* :do

    (setf A_xyz (elt A d))
    (setf B_xyz (elt B d)) ; соотв. координаты концов отрезка
    
    ;;(setf len (abs (- A_xyz B_xyz))) 
    
    (setf val (- A_xyz B_xyz)) 

    (incf sum (* val val))
    )

  ;(sqrt len) 

  (sqrt sum) 

))
;#-------------------------------------------------------------------------------
(defun calc_err (A B len_true)

(let* (

  (len (calc_len A B))   
  )


  (abs (- len len_true))

))
;#-------------------------------------------------------------------------------
(defun calc_err_for_one_edge (e points)

(let (
  err
  ;(full_err 0)
  ;(summ_err 0)

  A B ;fitness
  A_ind B_ind  
  L_true
  )


   (setf A_ind  (nth 0 e))
   (setf B_ind  (nth 1 e))
   (setf L_true (nth 2 e))

   (setf A (elt points A_ind)) ; это многомерные точки !! с радиусами ??
   (setf B (elt points B_ind))

   (setf err (calc_err  A B  L_true))

   err
))
;#-------------------------------------------------------------------------------
(defun calc_fitness_from_points (points edges)

(let (
  err
  (summ_err 0)
  ;(mult_err 0)

  fitness
  )

  ;(format t "calc_fitness_from_points: points = ~s ~%" points)

 (loop :for e :in edges :do 
    
   (setf err (calc_err_for_one_edge  e points))

   (incf summ_err        err)  ; простая сумма? 
   ;(incf mult_err (* err err)) ; квадратичная, с послед. корнем?
   )

 ;;-----------------------------------------------------

  (setf fitness (- summ_err))
  ;;
  ;(setf fitness (- (sqrt mult_err))) ;- какая лучше, вроде особо нет разницы


  fitness
  
))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# //  synopsis:	Fitness function.

;# /* static */ boolean 
;# _test_score (population *pop, entity *this_entity)
;#-------------------------------------------------------------------------------
(defun _test_score (pop this_entity)

(declare (ignore pop))

(let (

  fitness

  ;;  # нулевая точка должна быть фиксированна !
  points 


  ;;   0        1        2       3       4

  ;;   O ------ A ------ B ----- C ----- D
  ;;  
  ;;            1        0       1       4   cl orovos.cl 50 50 

  ;;  |AB| = 1
  ;;  |BC| = 1
  ;;  |AD| = 3
  ;; 

;  (edges '(
;          (0 1  1.0)

;          (1 2  1.0)
;          (2 3  1.0)
;          (1 4  3.0) ; cl orovos.cl  69 10
;          ;(3 4  1.0)
;          ))

;  (n     4)
;  (*n_fix* 1)

  ;(x0  0) ;  эта точка участвует в расчетах фитнеса, но ен участвует в геноме
  ; можно считать их в общей схеме полагаю фложок - фикс,
  ; а можно - как дополнительное условие, алгоритм расчета фитнеса.

  (chromosome (ent_get_chromosome_  this_entity))
  )

  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;; сформируем из хромосомы массив точек, а потом уже будем его обрабатывать
  ;;
  (setf points (make-array (+ *n_fix* *n_ext* )))


  ;; запишем сначала фиксированные точки в этот рабочий массив
  ;; 
  (loop :for i :from 0 :below *n_fix*  :do 

    (setf (elt points i)  (elt *work_fix_points* i))
    )


  ;(format t "_test_score: chromosome = ~s ~%" chromosome)

  ;; теперь запишем точки из генома
  ;; 
  (loop :for i :from 0 :below *n_ext*  :do 
    
    (setf (elt points (+ i *n_fix*))  
          (point_from_chromosome  chromosome  i))
    )

  ;(print points)
  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ;; и теперь по этому 
  ;; 

  (setf fitness (calc_fitness_from_points  points *edges*))


  (ga_entity_set_fitness  this_entity  fitness) 
  
  true
))
;#-------------------------------------------------------------------------------
;# Seed genetic data.

;# /* static */ boolean 
;# _test_seed (population *pop, entity *adam)
;#-------------------------------------------------------------------------------
(defun  point_init_by_random (point) 

  ; надо бы поточнее тут? по размерностям
  ; 

  (loop for d :from 0 :below *dim* :do

    (setf (aref point d)  (random_double  (aref *max_val_arr* d)))
    )

)
;#-------------------------------------------------------------------------------
(defun  point_to_entity (point ent i) 


  (loop for d :from 0 :below *dim* :do

    (ent_set_chromo_gen_  ent (+ (* *dim* i) d)  (elt point d))
    )

)
;#-------------------------------------------------------------------------------
(defun  _test_seed (pop adam)  ; task - описание заадчи


  ;; TODO: здесь нужно бы иметь индекс, т.е. связь с начальными значениями ??
  ;; 
  ;; нет, нужен механизм подключения "начальных точек"


  (declare (ignore pop))

  ;;  #   ((double *) adam->chromosome[0]) [0] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [1] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [2] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [3] = random_double (2.0);
  
  ;;  # пока будем делать с ОДНОЙ хромосомой 
  ;;  #
  ;;  # а надо ли несколько хромосом? т.е. например многомерная точка?
  ;;  # или адаптироваться должны процедуры скрещивания и т.д?
  
  (let (
  )
  
  (loop for i :from 0 :below *n_ext* :do

    (point_init_by_random   *work_point*) ; рабочая глобальная точка
    (point_to_entity        *work_point* adam i) 
    )


  true

))
;# //------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
(defun draw_entity (pop id name)


(let* (

  (entity  (pop_get_entity_      pop id))
  (chromo  (ent_get_chromosome_  entity))
  p
  )  

  (format t "~%")  
  (format t "~A : fitness = ~,6F ~%"  name (pop_get_entity_fitness_  pop id))
  (format t "~%")
  
  (loop :for i :from 0 :below *n_ext* :do

    (setf p (point_from_chromosome chromo i))

    (format t "   ")
    (ext_point_print  p i)
    (format t "~%")

    )
   
  ;;  puts ""
  (format t "~%")
  
))
;#-------------------------------------------------------------------------------
(defun draw_results (pop)


  (draw_entity   pop 0 "FINAL 0")
  
  (draw_entity   pop 1 "FINAL 1")
  
  ;(draw_entity   pop 2 "FINAL 2")
  
)
;#-------------------------------------------------------------------------------
(defun pntssolver_do (population_size max_generations

                                             &optional
                                             (strategy      "GA_DE_STRATEGY_BEST"     )
                                             (crossover     "GA_DE_CROSSOVER_BINOMIAL")
                                             (num_perturbed 1)
                                             )
(let* (

  (crossover_factor    0.8 )
  (weighting_factor    0.5 )
  (weighting_factor2   0.5 )

  pop 
  gen_hook_proc evaluate_proc initseed_proc 
  )


  ;(random_seed 23091975)
  

  (setf  gen_hook_proc  'test_generation_callback)
  (setf  evaluate_proc  '_test_score)
  (setf  initseed_proc  '_test_seed)
  
  (setf pop (ga_genesis_double         
             population_size              ; const int              population_size     
             1                            ; const int              num_chromo         
             (* *n_ext* *dim*) ; 4                ; const int              len_chromo        
             gen_hook_proc     ; GAgeneration_hook      generation_hook    
             NUL                          ; GAiteration_hook       iteration_hook 
             NUL                          ; GAdata_destructor      data_destructor 
             NUL                          ; GAdata_ref_incrementor data_ref_incrementor
             evaluate_proc     ; GAevaluate             evaluate  
             initseed_proc     ; GAseed                 seed 
             NUL                          ; GAadapt                adapt 
             NUL                          ; GAselect_one           select_one 
             NUL                          ; GAselect_two           select_two 
             NUL                          ; GAmutate               mutate           
             NUL                          ; GAcrossover            crossover 
             NUL                          ; GAreplace              replace 
             NUL                          ; vpointer               User data
             ))
  

  ;;    # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  ;;    #
  (ga_population_seed  pop)
  
  (when __is_print
    (pop_print pop)
    )
  
  (ga_population_set_differentialevolution_parameters    
      pop 
      strategy crossover 
      num_perturbed weighting_factor weighting_factor2 
      crossover_factor)
  
  (format t "~%")  
  
  ;;    # выполняем основной расчет (поиск минимума)
  ;;    #
  (ga_differentialevolution  pop max_generations)			
  
  
  (when __is_print
    (format t "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE ~%")
    )

  (format t "~%")  
  (pop_print pop)
  (format t "~%")
  

  (draw_results  pop)
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
(defun  add_to_end_of_list  (l x)

  (reverse (cons x (reverse l)))

)
;#-------------------------------------------------------------------------------
(defun find_index_by_name  (name nodes_)

;; здесь nodes_ - простой массив индексов !?

(let (
  (ind  -1)
  (len  (length nodes_))
  e
  )

  (loop :for i :from 0 :below len :do
    
    (setf e (elt nodes_ i))

    ;(format t "find_index_by_name: name= ~s  e= ~s ~%" name e)

    (when (eql e name) 

      (setf ind i)
      (return)
      )
    )

  (when (= ind -1) 
    (format t "~%")
    (format t "ERROR !!  find_index_by_name:  name = ~s ~%" name)
    (format t "~%")
    (exit)
    )

 ind
))
;#-------------------------------------------------------------------------------
(defun find_radius_by_name (name nodes)

;(declare (ignore  name nodes))


(let (
  (obxvat 0.0)
  )

  ;(format t "find_radius_by_name: name = ~s  ind = ~s ~%" name ind)

  (loop :for n :across nodes :do

    (when (eql (aref n 0)  name) 

      (setf obxvat (aref n 1))
      (return)
      )
    )

  (/ obxvat 6.28)
  ;0.5

  ;(aref (aref nodes ind) 1)
))
;#-------------------------------------------------------------------------------
(defun edges_correct (nodes  name_edges)


(let (

  (size (length  name_edges))

  e  
  A_name   B_name
  A_radius B_radius
  L_true    L_true_correct
  )

  (loop :for i :from 0 :below size :do

    (setf e (elt name_edges i))

    (setf A_name  (elt  e 0))  
    (setf B_name  (elt  e 1)) 

    (format t "edges_correct: A_name = ~s  B_name = ~s ~%"  A_name B_name)

    (setf A_radius  (find_radius_by_name  A_name nodes)) 
    (setf B_radius  (find_radius_by_name  B_name nodes)) 

    ;(exit)
    (setf L_TRUE  (aref e 2))

    ;;-------------------------------------------

    (setf L_TRUE_correct (+ L_TRUE A_radius B_radius))

    (setf (aref e 2) L_TRUE_correct)

    (setf (elt name_edges i) e) ; запишем обратно
    )

))
;#-------------------------------------------------------------------------------
(defun  make_edges_from_namededges  (namededges nodes)


(declare (special nodes))

(let (

  (edges  NIL)

  ie
  A_name B_name L_true A_indx B_indx
  )


  (loop :for ne :across namededges :do

    (setf A_name  (aref ne 0))   
    (setf B_name  (aref ne 1))     
    (setf L_true  (aref ne 2)) ; здесь уже расстояние между центрами, корректное?
    
    (setf A_indx  (find_index_by_name  A_name nodes))
    (setf B_indx  (find_index_by_name  B_name nodes))

    (setf ie (list  A_indx B_indx L_true)) ; ребро (индекс индекс длина)
    ;(setf ie  (A_indx B_indx L_true)) ; ребро (индекс индекс длина)
    
    (format t "ne = ~s  ie = ~s  ~%" ne ie)
    
    (setf edges (add_to_end_of_list edges ie))
    )

  (format t "~%")
  (format t "make_edges_from_namededges ............................ ~%")
  (format t "~%")
  (format t "names = ~s ~%" namededges)
  (format t "nodes = ~s ~%" nodes)
  (format t "edges = ~s ~%" edges)
  (format t ".......................................................~%")
  (format t "~%")


  edges

))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
(defun loop_for_fix_nodes (defnodes nodes_)

(let (
  (n 0)
  is_fix_flag
  )

  (loop :for p :across defnodes :do   

    (setf is_fix_flag (aref p 3))

    (when is_fix_flag
      
      (vector-push-extend  (aref p 0)            nodes_) ; только имя туда
      (vector-push-extend  (aref p 4) *work_fix_points*) ; сами коориднаты точки

      (incf n)
      )

    )

  n ; return 
))
;#-------------------------------------------------------------------------------
(defun loop_for_ext_nodes (defnodes  nodes_)

(let (
  (n 0)
  is_fix_flag
  )


  (loop :for p :across defnodes :do

    (setf is_fix_flag (aref p 3))

    (when (not is_fix_flag) ; не фиксированные точки

      (vector-push-extend  (aref p 0) nodes_)

      ;(when _new
      ;  (point_init_by_random  *work_point*) 
      ;  (vector-push-extend    (copy-seq  *work_point*)  *seed_points*)
      ;  )

      (incf n)
      )
    )

  n ; return 
))
;#-------------------------------------------------------------------------------
(defun loop_for_all_nodes_simple (defnodes  nodes_)

(let (
  (n_fix  0)
  (n_ext  0)

  )
  ; тут же надо именно последовательно формировать !!!
  ; т.е. на выходе сначала фиксированные точки, а не смешивать!!

  (setf n_fix  (loop_for_fix_nodes  defnodes nodes_)) ; -> *nodes*
  (setf n_ext  (loop_for_ext_nodes  defnodes nodes_)) ; -> *nodes*


  (values n_fix n_ext) 
))
;#-------------------------------------------------------------------------------
(defun pntssolver_init_task (
                             defnodes  namededges  
                                             dim 
                                             max_val_arr 
                                             )

(setf *dim*  dim) ; это уже глобальная переменная

(let (

  ;(nodes_  (make-array 0 :adjustable t :fill-pointer 0))
  ;p
  ;(n 0)
  )

  (setf *max_val_arr*  max_val_arr) 

  ;; делаем массивы и заносим туда поэлементно

  (setf *nodes*           (make-array     0 :adjustable t :fill-pointer 0))
  (setf *work_fix_points* (make-array     0 :adjustable t :fill-pointer 0)) ; для удобства

  ;(setf *seed_points*     (make-array     0 :adjustable t :fill-pointer 0))

  (setf *work_point*      (make-array *dim* 
                                      :initial-element 0)) ; глобальная , рабочая точка

  ; создаем по заданным шаблонам уже мат. узлы:
  ;
  ; чтобы вернуть несколько значений (если переменные уже есть):
  ; 
  (multiple-value-setq (*n_fix* *n_ext*) (loop_for_all_nodes_simple  defnodes *nodes*)
    ;;
    ) 


  ;(format t "pntssolver_init_task: fix_nodes_ = ~S ~%" *nodes*)
  ;(format t "~%" )
  
  ; создаем ребра:

  (setf *edges* (make_edges_from_namededges  
                      namededges *nodes*)) 


))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
(defun make_test_1 (dim)


(let* (

  ;;  эти точки участвуют в расчетах фитнеса, но не в геноме
  ;; 

  (defnodes #( 
                #( x0   0.0 " x0" #t (0  0)) ;; полагаем, что это точки с "обхватом"
                                              ;; имя / охват / фикс.координаты?
                #( p10  0.0 "p10" #f ) 
                #( p20  0.0 "p20" #f )
                #( p30  0.0 "p30" #f )
                #( p40  0.0 "p40" #f )
                ))


  (namededges #( 

                #( x0  p10  1.0) 
                #( p10 p20  1.0)
                #( p20 p30  1.0)

                #( p10 p40  3.0)

;                (3 4  1.0) ;  чем больше связей, тем точне, особенно в 2D
;                (0 4  4.0)
;                (0 3  3.0)
                ))

  ;; ----------------------------
  )
  ;; ----------------------------

  ;; сначала надо скорерктировать, если нужно (!), расстояния между 
  ;; центрами толстых точек:

;  (print name_edges)
;  (format t "~%")

;  (edges_correct   defnodes  namededges) 
;  (print name_edges)
;  (format t "~%")
  
;  (exit)
  ;---------------------------------------------------------------------

  ;(setf max_val_arr (make-array dim :initial-element 5.0))
  ;(pntssolver_init_task    all_points_local name_edges  dim 5.0)

  (pntssolver_init_task    defnodes namededges dim  
                           
                           (make-array ; массив максимальных значений
                                       dim :initial-element 5.0))



))
;#-------------------------------------------------------------------------------
(defun make_real_orovo ()

;(setf *dim*   2) ; это уже глобальная переменная

(let* (

  ;;  эти точки участвуют в расчетах фитнеса, но не в геноме
  ;; 


  (defnodes #( 

                #( pL   0.00    ""  #t ( 0  0) )
                #( pR   0.00    ""  #t (30  0) )

                #( pX   0.00    ""  #t (13.50  44.78)) ;; посчитал через уравнения
                #( pY   0.00    ""  #t (30 40  ))

                #( pZ   0.00    ""  #t (30 30.7)) ;  #( pZ pY 9.3)

                #( p4_  0.00    ""  #t (30 21.3)) ;  #( pZ  p4_  9.4)
                #( pP   0.00    ""  #t (30 20.3)) ;  prirezka (20.3 by doc)

                ;; --------------------------------------------------

                #( p1   1.50    ""  #t (16.4  37) )
                #( p2   0.98   "B"  #t (16.35 23.65) )
                #( p2_  0.95   "B"  #t (16.35 23.35) )
                #( p3   0.98   "B"  #t (22.4  22.1) )
                #( p4   1.20   "B"  #t (28.6  21.8) )
                #( p5   0.60   "B"  #t (27.3  31.1) )
                #( p6   0.60   "S"  #t (31    32.3) )
                #( p7   0.33   "B"  #t (30    35.7) )
                #( p8   0.52   "B"  #t (24.45 29.2) )
                #( p9   0.44   "S"  #t (21.3  27.15) )
                #( p10  0.49   "S"  #t (19.2  27.4) )
                #( p11  0.47   "B"  #t (13.3  29.3) )
                #( p12  0.45   "B"  #t (10    32.15) )
                #( p13  0.52   "S"  #t (14.6  34.3) )
                #( p14  0.62   "B"  #t (12    11.9) )
                #( p15  0.85   "B"  #t (13.25 11.9) )
                #( p16  0.47   "S"  #t (20.2  14.55) )
                #( p17  1.19   "B"  #t (27.1  13.3) )
                #( p18  0.58   "O"  #t (8.7    9.3) )
                #( p19  0.33   "O"  #t (8.6   15.6) )
                #( p20  0.48   "S"  #t (6.25  10.4) )

                ;; --------------------------------------------------

                #( p21  0.45   "S"  #f )
                #( p22  0.17   "S"  #t (6.1  5.6 ))
                #( p23  0.45   "O"  #t (7    4.6 ))
                #( p24  0.26   "S"  #t (2    0.45))
                #( p25  0.41   "S"  #t (4.4  1.3 ))

                #( p26  0.73   "B"  #t (6    0.2 ))
                #( p26_ 0.19   "O"  #f )

                #( p27  0.29   "B"  #f )
                #( p28  0.31   "B"  #f )
                #( p29  0.49   "B"  #f )
                #( p30  0.63   "B"  #f )
                #( p31  0.69   "B"  #t (11.4   3 ) )
                #( p32  0.40   "B"  #f )
                #( p33  0.35   "B"  #f )
                #( p34  0.35   "B"  #f )
                #( p35  0.59   "B"  #t (15.7  3.5) )
                #( p36  0.17   "O"  #f )
                #( p37  0.76   "O"  #f )
                #( p38  0.40   "B"  #t (19.75 3.35) )
                #( p39  0.46   "B"  #t (20.1  4.2 ) )
                #( p40  0.37   "O"  #f )
                #( p41  0.33   "O"  #f )
                #( p42  0.53   "O"  #t (22    5.2 ) )
                #( p43  0.47   "O"  #t (21.75 7   ) )
                #( p45  0.23   "O"  #f )
                #( p46  0.20   "O"  #f )
                #( p47  0.20   "O"  #t (24.2  5.5) )
                #( p48  0.25   "O"  #t (25.25 2.5) )
                #( p49  0.15   "O"  #f )


                #( pA   0.00    ""  #t (14.05 13.75) ) 
                #( pB   0.00    ""  #f ) 
                ;#( pB_  0.00    ""  #f ) 
                #( pC   0.00    ""  #t (19.4  12.1) ) 
                ;#( pC_  0.00    ""  #f ) 
                #( pD   0.00    ""  #t (14.35 11.3) ) 

                ))





  (namededges #(

  ;; ---------------------------------------------


                #( p1  p2  13.4) 
                #( p1  pX   9.0) 
                #( p1  pY  13.8) 

                #( p2  p2_  0.3)               
                #( p2  p10  4.3)               
                #( p2  p11  6.0)
                #( p2  p12 10.3)
                #( p2  p13 10.4)

                #( p3  p2   6.0)
                #( p3  p4   6.1)
                #( p3  p8   7.0) 
                #( p3  p9   5.0) 
                #( p3  p16  7.8) 

                #( p4  p5   9.0)
                #( p4  p8   8.1)
                #( p4  p4_  1.3)

                #( p5  p1  12.62)
                #( p5  p6   3.1)
                #( p5  p7   5.4)
                #( p5  p8   3.9)
                #( p5  pZ   2.1)

                #( p6  p7   4.0)
                #( p7  pY   4.3)
                #( p8  p9   3.5)
                #( p9  p13  9.5)

                #( p10 p9   2.1)
                #( p10 p11  5.76)

                #( p11 p12  4.38)
                #( p11 p13  5.0)

                #( p12 p13  5.15)
                #( p13 p1   3.45)

  ;; ---------------------------------------------

                #( p14 p15  0.87) 
                #( p14 p16  7.13) 
                #( p14 p18  4.14) 

                #( p16 pB   4.14) 

                #( pA  p2_  9.15) 
                #( pA  p14  2.55) 
                #( pA  p15  1.7) 

                #( pA  pB   5.0) 
                #( pC  pD   5.0) 
                #( pA  pD   2.5) 
                #( pB  pC   2.5) 

                #( pA  p18  6.93) 
                #( pA  p19  5.86) 

                #( pB  p2_  8.7) 
                #( pB  p3   7.9) 
                #( pC  p16  2.5) 
                #( pC  p17  7.87) 
                #( pD  p15  1.3) 
                ;#( pC_ p17  2.8) 
                ;#( pP  pB_  4.5) 

                #( p18 pD   5.98) 
                #( p18 p19  6.27) 
                #( p18 p20  2.60) 

                #( p19 p14  5.00) 
                #( p19 p16 11.58) 
                #( p19 pB  10.47) 
                #( p19 p20  5.37) 

  ;; ---------------------------------------------

                #( pR  p48  5.43) 
                #( pR  p40  8.53) 
                #( pR  p41  8.00) 
                #( pR  p37 11.01) 
                #( pR  p38 10.98) 
                #( pR  p39 10.76) 
                #( pR  p42  9.52) 
                #( pR  p43 10.90) 
                #( pR  p47  8.05) 
                #( pR  p45  7.15) 
                #( pR  p38 10.96) 
                #( pR  p35 14.65) 
                #( pR  p31 18.66) 
                #( pR  p49 13.78) 

                #( p40 p48  3.90) 
                #( p40 p46  4.00) 
                #( p40 p45  3.44) 
                #( p40 p41  1.42) 
                #( p40 p42  4.05) 
                #( p40 p43  5.80) 
                #( p40 p39  3.28) 
                #( p40 p38  2.97) 
                #( p40 p35  6.14) 
                #( p40 p36  4.08) 
                #( p40 p37  2.62) 
                #( p40 p31 10.05) 
                #( p40 p33  8.95) 
                #( p40 p34  9.8) 
                #( p40 pC  11.2) 
                #( p40 pD  12.5) 
                #( p40 p23 15.0) 


                #( p35 p14  9.48) 
                #( p35 p15  9.1) 
                #( p35 pC   9.37) 
                #( p35 pD   8.12) 
                #( p35 p18  9.3) 
                #( p35 p21 11.86) 
                #( p35 p34  3.6) 
                #( p35 p31  4.00) 
                #( p35 p33  3.28) 
                #( p35 p32  4.18) 
                #( p35 p27  6.45) 
                #( p35 p26  9.9) 
                #( p35 p29  5.11) 
                #( p35 p28  6.24) 
                #( p35 p43  6.8) 
                #( p35 p42  6.4) 
                #( p35 p39  4.26) 
                #( p35 p38  3.67) 
                #( p35 p41  6.6) 
                #( p35 p37  4.3) 
                #( p35 p36  3.08) 
                #( p35 p19 14.39) 


                #( p23 p22  1.17) 
                #( p23 p25  3.95) 
                #( p23 p26  4.33) 
                #( p23 p24  6.24) 
                #( p23 p30  4.07) 
                #( p23 p31  4.83) 
                #( p23 p34  5.20) 
                #( p23 p35  9.05) 
                #( p23 pL   8.18) 
                #( p23 p18  4.74) 
                #( p23 p21  4.86) 
                #( p23 p20  5.86) 
                #( p23 p14  8.73) 
                #( p23 p15  9.41) 
                #( p23 pD   9.84) 


                #( pL  p24  2.03) 
                #( pL  p25  4.50) 
                #( pL  p26  5.98) 
                #( pL  p26_ 6.86) 



   ;; ---------------------------------------------

               ))

  ;; ----------------------------
  )
  ;; ----------------------------


  (edges_correct          defnodes namededges) 

  (pntssolver_init_task   defnodes namededges  2  #(30 40))

))
;# //------------------------------------------------------------------------------
(defun calc_len_points  (p1 p2)
  
(let* (

  (x1 (aref p1 0))    
  (y1 (aref p1 1))    
  (x2 (aref p2 0))    
  (y2 (aref p2 1)) 

  (lx (- x2 x1)) 
  (ly (- y2 y1)) 
  )


  (sqrt (+ (* lx lx) (* ly ly)))

))
;# //------------------------------------------------------------------------------
(defun  new_prirezka_test ()
  
(let* (

  (p1   #(94 58))    ; #(97594 132058)
  (p2   #(70 80))    ; #(97570 132080)
  (p3   #(86 54))    ; #(97586 132054)
  (p4   #(92 57))    ; #(97592 132057)

  (n1   #(83 68))    ; #(97583 132068)
  (n2   #(79 90))    ; #(97579 132090)
  (n3   #(60 88))    ; #(97560 132088)
  (n4   #(47 80))    ; #(97547 132080)
  (n5   #(53 70))    ; #(97553 132070)

  (a  (calc_len_points  p3 n1))
  (b  (calc_len_points  n1 p2))
  (c  (calc_len_points  p2 p3))

  (x  (/ (+ (- (* a a) (* b b)) (* c c)) (* 2 c)))
  (y  (sqrt (- (* a a) (* x x))))
  )

  (declare (ignore p1 p4 n2 n3 n4))

  (format t "~%")
  (format t "p2 __ p3 =  ~s ~%" (calc_len_points  p2 p3))  ; 30.528675f0 
  (format t "p2 __ n5 =  ~s ~%" (calc_len_points  p2 n5))  
  (format t "~%")
  (format t "a= ~s b= ~s c= ~s ~%" a b c)  
  (format t "x= ~s ~%" x)  
  (format t "y= ~s ~%" y)  
  (format t "~%")

))
;#-------------------------------------------------------------------------------
;proc parse_opts {&population_size &max_generations  \
;                def_population_size def_max_generations} {

;#-------------------------------------------------------------------------------
(defun parse_opts_int_int_int (index  int1 int2 int3)

(let* (
  ;(index  0)

  (argus  (get_argus))
  (argc   (list-length argus))
  )

  ;(format t "argc = ~s ~%" argc)
  (setf __is_print false)
  
  (set int1   (parse-integer (nth index argus))) (incf index)

  ;(unless  (= argc 0) ;; если есть параметры
  (set int2 (parse-integer (nth index argus))) (incf index) ; пишем в "символ"
  (set int3 (parse-integer (nth index argus))) (incf index)
  ;)
  

  ;(when (= argc 3)
  ;    (set r_dim             (parse-integer (nth 2 argus))) 
  ;  )

  (when (= argc (+ index 1))   ; cl v_pnts.cl  01  4 1  @
    (setf __is_print true)
    )

))
;#-------------------------------------------------------------------------------
(defun parse_opts_int_int (index  int1 int2)

(let* (

  (argus  (get_argus))
  (argc   (list-length argus))
  )

  (setf __is_print false)
  
  (set int1 (parse-integer (nth index argus))) (incf index)
  (set int2 (parse-integer (nth index argus))) (incf index) ; пишем в "символ"
  

  (when (= argc (+ index 1))   ; ...... @
    (setf __is_print true)
    )

))
;# //------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
(defun make_test_orovo ()

; MDS - Multidimension Scaling

(let* (
  (defnodes    (make-array  0 :adjustable t :fill-pointer 0))
  (namededges  (make-array  0 :adjustable t :fill-pointer 0))
  )

  ;; ----------------------------
  ;; TODO: задавать функциями с формированием имен и координат узлов!

  (vector-push-extend  #( p_00_00    0.0    ""  #t ( 0  0))  defnodes)
  (vector-push-extend  #( p_30_00    0.0    ""  #t (30  0))  defnodes)
  (vector-push-extend  #( p_00_40    0.0    ""  #t ( 0 40))  defnodes)
  (vector-push-extend  #( p_30_40    0.0    ""  #t (30 40))  defnodes)

  (vector-push-extend  #( p_15_00    0.0    ""  #f)          defnodes)
  (vector-push-extend  #( p_15_40    0.0    ""  #f)          defnodes)

  ;; ----------------------------
  ;; TODO: задавать функциями с формированием имен и длин ребер!

  (vector-push-extend  #( p_00_00  p_15_00  15) namededges)
  (vector-push-extend  #( p_15_00  p_30_00  15) namededges)
  (vector-push-extend  #( p_00_40  p_15_40  15) namededges)
  (vector-push-extend  #( p_15_40  p_30_40  15) namededges)

  ;; TODO: сделать отдельную функцию, по индексам координат формировать
  ;;       имена и расстояния;
  ;; 

  ;; ----------------------------


  (pntssolver_init_task  defnodes  namededges  2  #(30 40))

))
;# //------------------------------------------------------------------------------
(defun  main ()
  
(let* (

  (num_test          1)
  (population_size  40) 
  (max_generations  50)

  (argus  (get_argus))
  )

  (declare (special 
                population_size  max_generations num_test
                ))
 
  ;;--------------------------------------------------
  (if (= (length argus) 0) 
      (progn
        (format t "argus = 0 !!!!!!!!!! ~%")
        (setf num_test 1)
        ;(exit)
        )
    (setf  num_test   (parse-integer (nth 0 argus)))
    )

  (format t "~%")
  (format t "num_test        = ~s ~%" num_test)
  (format t "~%")

  (case num_test ; отдельные теcты без решателя точек

    ((23)  (progn
             (new_prirezka_test)
             (exit) 
             )) 
  )

  ;;--------------------------------------------------

  (if (= (length argus) 0) 
      (progn
        ;(format t "argus = 0 !!!!!!!!!! ~%")
        (setf  population_size  4)
        (setf  max_generations  1)
        ;(exit)
        )
    (parse_opts_int_int  
     1 'population_size 'max_generations)
    )

  ;(parse_opts_int_int  
  ; 1 'population_size 'max_generations)

  (format t "population_size = ~s ~%" population_size)
  (format t "max_generations = ~s ~%" max_generations)
  (format t "~%")

  (random_seed 23091975) ; сюда вынес, чтобы отдельно формировать случайные точки
  

  ;;--------------------------------------------------
  (case num_test

    ( (1)  (make_test_1  1))
    ( (2)  (make_test_1  2))

    ((20)  (make_test_orovo))
 
    ;;------------------------------------------------

    ((22)  (progn 

       (make_real_orovo)
      
       (pntssolver_do  population_size max_generations

              ;; необязательные параметры
              ;;
              ;"GA_DE_STRATEGY_BEST"     
              ;;"GA_DE_STRATEGY_RAND"     
              "GA_DE_STRATEGY_RANDTOBEST"

              "GA_DE_CROSSOVER_BINOMIAL"   
              ;;"GA_DE_CROSSOVER_EXPONENTIAL" ; FUNCALL: undefined function DE_RANDTOBEST_1_EX
              
              1)  ; num_perturbed
              ;;2)  ;   FUNCALL: undefined function DE_RANDTOBEST_2_BIN 
                     
       (exit))
     ) 

    )
  ;;--------------------------------------------------


  (pntssolver_do   population_size max_generations)
  
))
;-------------------------------------------------------------------------------

(main)

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
