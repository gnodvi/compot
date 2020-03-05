; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defvar  *doit_tabl* :undefined)

;-------------------------------------------------------------------------------
(defun get_mvs_from_doittabl (tabl)

(let* (
  (len (list-length tabl))
  (mvs (make-list    len))
  )

  (dotimes (i len)
    (setf (nth i mvs) (nth 1 (nth i tabl)))
    )

  mvs
))
;-------------------------------------------------------------------------------

(defvar *num_state_bits* :*num_state_bits*)
(defvar *num_edge_bits*  :*num_edge_bits*)
(defvar *num_bits_for_doit* :*num_bits_for_doit*)

;-------------------------------------------------------------------------------
;  СЕТИ   СЕТИ   СЕТИ   СЕТИ   СЕТИ   СЕТИ     АВТОМАТЫ   АВТОМАТЫ  
;-------------------------------------------------------------------------------

(defclass NODE () (
   (name  :accessor NODE-name)
   (sum   :accessor NODE-sum)
   (out   :accessor NODE-out)
))

(defclass IFDO () (
   (if_proc :accessor IFDO-if_proc)
   (do_proc :accessor IFDO-do_proc)
))

(defclass GENE () (
   (from :accessor GENE-from)
   (to   :accessor GENE-to)
   (ifdo :accessor GENE-ifdo)
   (w    :accessor GENE-w)
))

(defclass ANET () (
   (node_s :accessor ANET-ns) ; список из узлов
   (gene-s :accessor ANET-gs) ; список из генов (ребра переходов-действий)
   (active :accessor ACTIVE)  ; номер активного состояния
))

;-------------------------------------------------------------------------------
(defun anet_create ()

(let (
  am
  )

  (setf am (make-instance 'ANET))

  (setf (ANET-ns am) (make-list 0)) ; для узлов 
  (setf (ANET-gs am) (make-list 0)) ; для генов

  (amat_set_active  am 0)

  am
))
;-------------------------------------------------------------------------------
(defun amat_set_active (am index)

  (setf (ACTIVE am) index)

)
;-------------------------------------------------------------------------------
(defun anet_find_node (an name)

(let (
  (n_ret  NIL)
  )

  (dolist (n (ANET-ns an))
    (when (eq (NODE-name n) name)
      (setf n_ret n)
      (return)
      ))

  n_ret
))
;-------------------------------------------------------------------------------
(defun anet_set_node_out (an name val)

(let (
  (n  (anet_find_node an name))
  )

  (setf (NODE-out n) val)

))
;-------------------------------------------------------------------------------
(defun is_node_exist (an node)

(let (
  (is_exist NIL)
  node_name
  )

  (dolist (n (ANET-ns an))
    (setf node_name (NODE-name n))

    (when (eq node_name node)
      (setf is_exist T)
      (return)
      ))

  is_exist
))
;-------------------------------------------------------------------------------
(defun anet_node_make_and_add (an name)

(let (
  (n (make-instance 'NODE))
  )

  (setf (NODE-name n)  name)
  (setf (NODE-sum  n)   0.0)
  (setf (NODE-out  n)   0.0)

  (setf (ANET-ns an) (append (ANET-ns an) (list n)))

))
;-------------------------------------------------------------------------------
(defun anet_add_node (an name)

  (unless (is_node_exist  an name)
    (anet_node_make_and_add an name)
    )

)
;-------------------------------------------------------------------------------
(defun anet_add_gene (an from to w ifdo)

(let* (
  (g  (make-instance 'GENE))
  )

  (setf (GENE-from  g)  from)
  (setf (GENE-to    g)    to)
  (setf (GENE-ifdo  g)  ifdo)
  (setf (GENE-w     g)     w)

  (setf (ANET-gs an) (append (ANET-gs an) (list g)))

  ; создать узлы U и V , если они еще не существуют
  (anet_add_node  an from)
  (anet_add_node  an   to)

))
;-------------------------------------------------------------------------------
(defun ifdo_print (e)

  (format t "[")

  (unless (eq e NIL)
  (format t "~s ~s" (IFDO-if_proc e) (IFDO-do_proc e)))

  (format t"] ")

)
;-------------------------------------------------------------------------------
(defun node_print (n)

(let (
  )

  (format t "~s : sum= ~f out= ~f " (NODE-name n)
          (NODE-sum n) (NODE-out n))

  (format t "~%")

))
;-------------------------------------------------------------------------------
(defun gene_print (g)

(let (
  (ifdo (GENE-ifdo g))
  )

  (format t "~s -> ~s : ~f " (GENE-from g) (GENE-to g) (GENE-w g))
  (ifdo_print ifdo)
  (format t "~%")

))
;-------------------------------------------------------------------------------
(defun anet_print (am)

  (format t "-----------------------------------------------------------~%")

  (dolist (n (ANET-ns am))
    (node_print n)
    )

  (format t "~%")

  (dolist (g (ANET-gs am))
    (gene_print g)
    )

  (format t "~%")
  (format t "ACTIVE= ~s ~% " (ACTIVE am))

  (format t "-----------------------------------------------------------~%")

)
;-------------------------------------------------------------------------------
(defun anet_find_gene_by_from (an name_from)

(let (
  (g_ret  NIL)
  )

  (dolist (g (ANET-gs an))
    (when (eq (GENE-from g) name_from)
      (setf g_ret g)
      (return)
    ))

  g_ret
))
;-------------------------------------------------------------------------------
(defun do_out_to_sum (an node_from)

(let* (
  (name_from (NODE-name node_from))
  (g         (anet_find_gene_by_from an name_from))
  name_to
  node_to
  )

  (unless (eq g NIL) ; если есть еще куда двигаться по сети
    (setf name_to (GENE-to g))
    (setf node_to (anet_find_node an name_to))
    
    (format t "do_out_to_sum: ~s --> ~s ~%" name_from name_to)

    (incf (NODE-sum node_to) (* (NODE-out node_from) (GENE-w g)))
    (setf (NODE-out node_from) 0) ; обнуляем выход
    )

  g
))
;-------------------------------------------------------------------------------
(defun funact_simple (sum tetha)

  (if (< sum tetha) 0
                    1)

)
;-------------------------------------------------------------------------------
(defun do_sum_to_out (n)

(let* (
  (f_activate 'funact_simple)
  (tetha       1.5)
  (name        (NODE-name n))
  (sum         (NODE-sum  n))
  )

  (format t "do_sum_to_out: ~s --> ~s ~%" name name)

  (setf (NODE-out n) (funcall f_activate sum tetha))
  (setf (NODE-sum n) 0) ; обнуляем приход

))
;-------------------------------------------------------------------------------
(defun do_out_to_sum_all (an)

(let* (
  (ret  NIL)
  )

  (dolist (n (ANEt-ns an))
    (when (> (NODE-out n) 0) (setf ret (do_out_to_sum an n))
          ))
  
  ret
))
;-------------------------------------------------------------------------------
(defun do_sum_to_out_all (an)

  (dolist (n (ANET-ns an))
    (when (> (NODE-sum n) 0) (do_sum_to_out n))
    )

)
;-------------------------------------------------------------------------------
(defun anet_activate_loop (an)

(let (
  (is_print T) ; NIL
  ret
  )

  (loop
    (when is_print
    (format t "~%") (anet_print an) (format t "~%"))

    (setf ret
    (do_out_to_sum_all an))

    (when (eq ret NIL) (return)) ; если уже нет движения, то выходим из цикла!

    (when is_print
    (format t "~%") (anet_print an) (format t "~%"))

    (do_sum_to_out_all an)
    )

))
;-------------------------------------------------------------------------------
(defun anet_01 (argus) (declare (ignore argus))

(let* (
  (an  (anet_create))
  )

  (anet_add_gene  an 0 2 0.6 NIL)
  (anet_add_gene  an 1 2 1.0 NIL)

  (anet_set_node_out  an 0 1.0)
  (anet_set_node_out  an 1 1.0)

  (format t "~%")
  (anet_activate_loop an)
  (format t "~%")

))
;-------------------------------------------------------------------------------
(defun make_ifdo_bloc (if_proc do_proc)

(let (
  (e  (make-instance 'IFDO))
  )

  ;(format t "2............ ~%")

  (setf (IFDO-if_proc e) if_proc)
  (setf (IFDO-do_proc e) do_proc)

  ;(format t "3............ ~%")
  e
))
;-------------------------------------------------------------------------------
(defun get_from_ifdo (e)

(let (
  if_proc do_proc
  )

  (setf if_proc (IFDO-if_proc e))
  (setf do_proc (IFDO-do_proc e))
  
  (values if_proc do_proc)
))
;-------------------------------------------------------------------------------
(defun make_am_from_l_init (am l_init)

(let (
  (w  1.0) 
  u v if_proc do_proc
  )

  (dolist (l l_init)
    (setf       u (nth 0 l)) ; откуда
    (setf       v (nth 1 l)) ; куда
    (setf if_proc (nth 2 l)) ; 
    (setf do_proc (nth 3 l)) ;

    (anet_add_gene  am u v w (make_ifdo_bloc if_proc do_proc))
    )

))    
;-------------------------------------------------------------------------------
(defun fint_do_step (am)

(let (
  (gene_s (ANET-gs am))
  u v ifdo if_proc do_proc
  )

  (dolist (g gene_s) ; идем циклом по всем генам-клеткам
    (setf     u (GENE-from g))
    (setf     v (GENE-to   g))
    (setf  ifdo (GENE-ifdo g))

    (setf if_proc (IFDO-if_proc ifdo))
    (setf do_proc (IFDO-do_proc ifdo))

    (when (and 
           (= (ACTIVE am) u) ; запись соответствует текущему состоянию
           (eq (eval if_proc) T))

      (eval do_proc) ; выполняем действие на переходе (глоб. параметр)

      (setf (ACTIVE am) v)
      (return) ; заканчиваем, уже перешли
      ))

))
;-------------------------------------------------------------------------------
(defun amat_04 (argus) (declare (ignore argus))

(let* (
  (w  1.0)
  (am  (anet_create))
  )

  (anet_add_gene  am 0 1 w (make_ifdo_bloc '(= 10 10) 
                                           '(format t "DO STEP: 0 -> 1 ~%")))

  (anet_add_gene  am 1 0 w (make_ifdo_bloc '(= 11 11) 
                                           '(format t "DO STEP: 1 -> 0 ~%")))

  (anet_print   am)  (format t "~%")
  (fint_do_step am)
  (anet_print   am)  (format t "~%")
  (fint_do_step am)
  (anet_print   am)  (format t "~%")
                     (format t "~%")

))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

;===============================================================================

