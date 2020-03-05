; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;;==============================================================================

(defconstant GR_CONST 0)
(defconstant GR_RAND  1)

;;;=============================================================================

(defclass METKA () (  
;  BOOL    fix;
;  double  l;
;  int     prev;
  (fix  :accessor FIX)
  (l    :accessor L)
  (prev :accessor PREV)
))

(defclass WORKS () (  
;  int     s, t;
  (s    :accessor S)
  (tar  :accessor TAR)
;  METKA  *met;
;  int    *puti;
;  double  smin;
  (met  :accessor  MET)
  (puti :accessor  PUTI)
  (smin :accessor  SMIN)
))

;//--------------------------

(defclass GRAF () (  
  (nn    :accessor NN)
  (nodes :accessor NODES) ; список значений в узлах
  (edges :accessor EDGES) ; матрица смежности (веса соответствующих дуг)

;  WORKS  *wk;    // надо бы выделять эту память отдельно перед расчетом..
  (wk    :accessor WK)
))

;//--------------------------
;(defvar YES  -1001.0)
(defvar YES  0.0) ; странно, но и с этим значeниeм спокойно отработало

;(defvar YES  'YES) ; такая запись как раз прeимущeство Лиспа
                    ; и сразу выявило ошибку в логикe тeстовых задач..!

(defvar NOS  'NOT)
;(defvar NOS  -1000.0)

;;;=============================================================================
;
;-------------------------------------------------------------------------------
(defmacro EDGE (gr u v)  

  ;(aref (EDGES gr) u v)
  ;(list 'aref (list 'EDGES gr) u v)

  `(aref (EDGES ,gr) ,u ,v)
)
;-------------------------------------------------------------------------------
(defmacro NODE (gr u)  

  ;(aref (NODES gr) u)
  (list 'aref (list 'NODES gr) u)

)
;;;=============================================================================
;
;
;
;;

;-------------------------------------------------------------------------------
(defun Graf_Init (gr type_nodes nod1 nod2
                     type_edges edg1 edg2)

  (declare (ignore type_nodes type_edges))

  ;(YRAND_S)

  (dotimes (u (NN gr))


    (setf (NODE gr u) (YRandF nod1 nod2))

    ;; for (v = 0; v < gr->nn; v++) {
    (dotimes (v (NN gr))

      (if (eql edg1 NOS)  ;; а если они NOS ??
          (setf (EDGE gr u v)  NOS) 
          (setf (EDGE gr u v) (YRandF edg1 edg2))
      )
      )
    )

)
;-------------------------------------------------------------------------------
(defun Graf_Init1 (gr r_edge_all r_edge_two)

;  //YRAND_S;

  (dotimes (u (NN gr))
    (setf (NODE gr u)   YES)
    (setf (EDGE gr u u) YES)
    )

;  for (u = 0; u < gr->nn; u++)
;  for (v=u+1; v < gr->nn; v++) {
  (dotimes (u (NN gr))
  (loop for v from (+ u 1) to (- (NN gr) 1) do

;    if ((NODE (gr, u)==NOS) || (NODE (gr, u)==NOS))
;      continue;
    (unless (eql (NODE gr u) NOS)

;    if (!(RandYes (r_edge_all))) {
;      EDGE (gr, u, v) = EDGE (gr, v, u) = NOS;
;      continue;
;    }
    (if (RandYes r_edge_all)

        (progn
        ;(format *error-output* "1 ... ~%")

        (if (RandYes r_edge_two) (progn   ; ребро будет двухнаправленным
            (setf (EDGE gr u v) YES)
            (setf (EDGE gr v u) YES)
            ) (progn
            (if (RandYes 50.0) (progn     ; ребро будет в одну сторону
                (setf (EDGE gr u v) NOS)
                (setf (EDGE gr v u) YES)
                ) (progn                  ; ребро будет в другую сторону
                (setf (EDGE gr u v) YES)
                (setf (EDGE gr v u) NOS)
                ))
            ))
        )

      (progn 
        ;(format *error-output* "2 ... ~%")

        (setf (EDGE gr u v) NOS)
        (setf (EDGE gr v u) NOS)
        )
      )
    )

  ))

)
;-------------------------------------------------------------------------------
(defun Graf_Init_Main (gr nn)  

  (setf (NN gr) nn)

  (setf (EDGES gr) (make-array (list nn nn)))
  (setf (NODES gr) (make-array nn))

  (setf (WK gr) (graf_work_create gr))

  (dotimes (u nn) 
    (setf (aref (NODES gr) u) NOS)
    )

  (dotimes (u nn) 
  (dotimes (v nn) 
    ; здесь надо вставить создание списка ребер

    (setf (EDGE gr u v) NOS)
    ))

)
;-------------------------------------------------------------------------------
(defun Graf_Create (nn)  

(let (
   gr 
  )

  (setf gr (make-instance 'GRAF))

  (Graf_Init_Main gr nn)  ; пустые рабочие массивы

  gr
))
;-------------------------------------------------------------------------------
(defun Graf_To_Dot (gr out)  

(let (
  edge
  )

  (format out "~%") 
  (format out "digraph abstract { ~%") 

  (dotimes (u (NN gr))
  (dotimes (v (NN gr))
    (setf edge (EDGE gr u v))

    ;(when (not (eq (EDGE gr u v) NOS))
    (when (not (eq edge NOS))
      (format out "  ~2D -> ~2D ~%" u v)
      ;(format   t "  ~2D -> ~2D : ~s ~%" u v edge)
      )
    ))

  (format out " } ~%") 
))
;-------------------------------------------------------------------------------
(defun Graf_Print_Edges (gr)  

(let (
  edge
  )

  (format t "~%") 
  (format t "GRAF EDGES: ~%") 

  (dotimes (u (NN gr))
  (dotimes (v (NN gr))
    (setf edge (EDGE gr u v))

    ;(when (not (eq (EDGE gr u v) NOS))
    (when (not (eq edge NOS))
      ;(format out "  ~2D -> ~2D ~%" u v)
      (format   t "  ~2D -> ~2D   = ~s ~%" u v edge)
      )
    ))

  (format t "~%") 
))
;-------------------------------------------------------------------------------
(defun Graf_To_Dotfile (gr name)  

  (with-open-file (ofile name 
                 :direction :output
                 :if-exists :supersede
                 ) 

    (Graf_To_Dot gr ofile)  
    )
)
;-------------------------------------------------------------------------------
;double *
;graf_edge (GRAF *gr, int u, int v)
;{
;  /* int rab; */

;  if ((u<0) || (u>= gr->nn)) YERROR ("graf_edge");
;  if ((v<0) || (v>= gr->nn)) YERROR ("graf_edge");

;	// оптимизация для только ненаправленных графов
;/*   if (u > v) {  */
;/*     rab = v; */
;/*     v = u; */
;/*     u = rab; */
;/*   } */

;  return ((gr->edges) + u*(gr->nn) + v);
;}
;-------------------------------------------------------------------------------
(defun Graf_Print (gr)  

(let (
  val 
  (nn (NN gr)) 
  )

  ;; нужно более аккуратно печатать по размерам + значения в узлах
  ;; 
  ;; 
  ;; 

  (format t "--------- GRAF_PRINT ---------------------- ~%")
  (format t "~%")

  (format *error-output* "NN    = ~s ~%" nn)
  (format *error-output* "NODES = ~s ~%" (NODES gr))
  ;(format *error-output* "EDGES = ~s ~%" (EDGES gr))
  ;
  ;(Graf_Print_Edges  gr)  
  (format t "~%")

  ;; печетаем заголовок ........................

  (format t "   | ");
  (dotimes (u nn) 
    (format t "  ~2D " u)
    )
  (format t "~%")
  (format t "------------------------------------------- ~%")

  ;; печетаем матрицу смежности  ...............

  (dotimes (u nn) 
    (format t "~2D | " u)
    (dotimes (v nn) 

      ;(setf val (aref (EDGES gr) u v))
      (setf val (EDGE gr u v))
      (cond 
          ((eq val NOS) (format t "  o  ")) ;; разноe для SBCL, CLISP
          ;((= val NOS) (format t "  o  ")) ;; ?? вродe работаeт ??

          ((eq val YES) (format t "  *  "))
          ((eq val NIL) (format t "  N  "))
          ((eq val T)   (format t "  T  "))
          ((consp val)  (format t "  .  "))
          (t            (format t " ~4,1F " val))
        )
      )
    (format t "~%")
    )

  (format t "------------------------------------------- ~%")

  ;(Graf_To_Dotfile gr "c-gra.dot")  
  ;(Graf_To_Dotfile gr ".DOT")  
  (Graf_To_Dotfile gr "b-gra.dot")  

))
;-------------------------------------------------------------------------------
;BOOL
;graf_get_sosed (GRAF *gr, int uzel, int *sosed)
;{
;  static GRAF *g;
;  static int uz;
;  static int i;

;  if (gr != NULL) {
;    g = gr;
;    uz = uzel;
;    i = -1;
;    return (TRUE);
;  }

;  while (TRUE) {
;    i++;
;    if (i == g->nn)
;      return (FALSE);
;    if (EDGE (g, uz, i) == NOT)
;      continue;
;    *sosed = i;
;    return (TRUE);
;  }

;}
;-------------------------------------------------------------------------------
;double
;graf_get_sum (GRAF *pg, int u)
;{
;  double  sum;
;  int     sosed, num_sosed;

;  sum = num_sosed = 0;

;  graf_get_sosed (pg, u, &sosed);

;  while (graf_get_sosed (NULL, 0, &sosed)) {
;    sum += (EDGE(pg, u, sosed) * NODE(pg, sosed));
;    num_sosed++;
;  }
;  sum = sum/num_sosed;

;  return (sum);
;}
;-------------------------------------------------------------------------------
;WORKS *
;Graf_Work_Create (GRAF *pg)
;-------------------------------------------------------------------------------
(defun Graf_Work_Create (pg)

(let (
;  WORKS *wk;
;  int nn = pg->nn;
  (wk (make-instance 'WORKS))
  (nn (NN pg))
  )
;  if (!(wk = (WORKS *) malloc (sizeof (WORKS))))      YERROR ("GrafWork");

;  wk->puti = (int *) malloc (sizeof(int) * nn * nn);
  (setf (PUTI wk) (make-list (* nn nn)))

;  wk->met  = (METKA *) malloc (sizeof(METKA) * nn);
  (setf (MET wk) (make-list nn))
  (dotimes (i nn)
    (setf (nth i (MET wk)) (make-instance 'METKA))
    )

  wk
))
;-------------------------------------------------------------------------------
;BOOL
;graf_smin (GRAF *gr, int s, int t, double *smin)
;-------------------------------------------------------------------------------
(defun GRAF_SMIN (gr s tar smin)

(let (
;  int j, v, v_min, p;
;  static WORKS *wk = NULL;
;  static GRAF *pg = NULL;

  wk pg met p sum v_min l_min j
;  METKA *met;
;  double sum, l_min;
  )

;/*   if (pg != gr) { */
;/*     pg = gr; */
;/*     graf_work_delete (wk); */
;/*     wk = Graf_Work_Create (pg); */
;/*   } */

  (setf pg  gr)
  (setf wk  (WK pg))

  (setf met (MET wk))

  (setf (S   wk) s)
  (setf (TAR wk) tar)

  (when (= s tar) 
    (setf        (SMIN wk)   0)
    (setf (nth 0 (PUTI wk)) -1)
    (return-from graf_smin FALSE)
    )

;  for (v = 0; v < pg->nn; v++) {
  (dotimes (v (NN pg))
    (setf (FIX  (nth v met)) FALSE)
    (setf (L    (nth v met)) YMAXSPACE)
    (setf (PREV (nth v met)) -1)
    )
  (setf (FIX    (nth s met)) TRUE)
  (setf (L      (nth s met)) 0)

  (setf p s)

  (loop 
    (dotimes (v (NN pg))
;      if (EDGE (pg, p, v) == NOT)
;				continue;
;      if (met[v].fix)
;				continue;
      (unless (or (eql (EDGE pg p v) NOS) (FIX (nth v met)))

      (setf sum (+ (L (nth p met)) (EDGE pg p v)))

      (when (> (L (nth v met)) sum) 
        (setf (L    (nth v met)) sum)
        (setf (PREV (nth v met)) p)
        )
    ))

    (setf l_min YMAXSPACE)

    (dotimes (v (NN pg))
;      if (met[v].fix)
;				continue;
      (unless (FIX (nth v met))

;      if (met[v].l < l_min) {
      (when (< (L (nth v met)) l_min) 
        (setf l_min (L (nth v met)))
        (setf v_min v)
        )
    ))

;    met[v_min].fix = TRUE;
    (setf (FIX (nth v_min met)) TRUE)

    (setf p v_min)
    (when (= p tar)
      (return)
      )
  )

  (setf p tar)
  (setf j 0)


  (loop 
;    wk->puti[j++] = p;
    (setf (nth j (PUTI wk)) p)
    (incf j)

    (when (= p s) (return))
    (setf p (PREV (nth p met)))
    )


  (setf (nth j (PUTI wk)) -1)

  (setf (SMIN wk) (L (nth tar met)))

  (if (eq smin NUL)  (graf_work_print wk)
;  else               *smin = wk->smin;
    )

;  return (TRUE);
))
;-------------------------------------------------------------------------------
;BOOL
;graf_all_smin (GRAF *gr, int s, double *all)
;-------------------------------------------------------------------------------
(defun graf_all_smin (gr s all)


(let* (
;  BOOL *list;
;  int num, u, v, nn = gr->nn;
  (nn (NN gr))
;  double mini, val_uv;
  (u 0) ; ?? этого нe было 
  mini val_uv

  (num  nn)
;  /* YMALLOC (list, BOOL, nn); */
;  if (!(list = (BOOL*)malloc (sizeof(BOOL) * nn))) YERROR ("GrafAllSmin");
  (lis (make-list nn))
  )

;  for (v = 0; v < nn; v++)  list[v] = TRUE;
  (dotimes (v nn) 
    (setf (nth v lis) TRUE)
    )

  (dotimes (v nn)
    (setf (nth v all) (EDGE gr s v))
    ;(when (= all[v] NOT)  (setf (nth v all) MAXVAL))
    (when (eql (nth v all) NOS)  (setf (nth v all) MAXVAL))
    )

  (setf (nth s all) 0)
  (setf (nth s lis) FALSE)
  (decf num)

  ;(format t "num= ~d ~%" num)

;  while (num != 0) {
;  (loop until (/= num 0) do
  (loop while (/= num 0) do  ; !!!!! вот гдe была ошибка !!!!

    ;(format t "uu............1 ~%")

    (setf mini MAXVAL)
    (dotimes (v nn)
    (unless (eq (nth v lis) FALSE) ; continue
        
      (when (< (nth v all) mini) 
        (setf mini (nth v all))
        (setf u    v)
        )
      ))
    
    (setf (nth u lis) FALSE)
    (decf num)
    
    ;(format t "uu............2 ~%")

    (dotimes (v nn)
    (unless (eq (nth v lis) FALSE) ; continue
      (setf val_uv (EDGE gr u v))
      
      (when (eql val_uv NOS)  (setf val_uv MAXVAL))
      (setf (nth v all) (min  (nth v all) (+ (nth u all) val_uv)))
      ))
    
  )

;  (print_all_smin gr s all)
;  free (list);
;  return (TRUE);
))
;-------------------------------------------------------------------------------
;BOOL
;graf_new_node (GRAF *gr, int *pu)
;-------------------------------------------------------------------------------
(defun graf_new_node (gr)

(let (
  u_find
  )

  (dotimes (u (NN gr)) ; ищeм нeзанятый узeл в структурe графа
    ;(format t "u= ~S ~%" u)
    (when (eql (NODE gr u) NOS) 
      (setf u_find u)
      (return)
      )
    )

  u_find ; eсли нe найдeн, то вeрнтся NIL

;  if (u == gr->nn) {
;    return (FALSE);
;  }

;  if (pu) *pu = u;
;  return (TRUE);
))
;-------------------------------------------------------------------------------
(defun graf_work_print (wk)

(let (
  num
  )

  (format (STD_ERR) "--------------------------~%")
  (format (STD_ERR) "S = ~d ~%" (S   wk))
  (format (STD_ERR) "T = ~d ~%" (TAR wk))
  (format (STD_ERR) "L_min = ~s ~%" (SMIN wk))

;  for (v = 0; wk->puti[v] != -1; v++) ;;;
  (loop for v from 0 while (/= (nth v (PUTI wk)) -1) 
    finally (setf num v)
    )
  ;(setf num v)

  (loop for v from (- num 1) downto 0 do
    (format (STD_ERR) "~d" (nth v (PUTI wk)))
    (when (/= v 0)
      (format (STD_ERR) "_")
      )
    )

  (format (STD_ERR)  "~%------------------------~%")

))
;-------------------------------------------------------------------------------
(defun graf_re_max (old)

(let* (
  (new_nn (floor (* (NN old) 1.25)))
  (new_gr (Graf_Create new_nn))
  )

  ;(format t "graf_re_max: new_nn=~d ~%" new_nn)

  (dotimes (u (NN old))
    (setf (NODE new_gr u) (NODE old u))
    )

  (dotimes (u (NN old))
  (dotimes (v (NN old))
    (setf (EDGE new_gr u v) (EDGE old u v))
    ))

  (setf (NODES old) (NODES new_gr))
  (setf (EDGES old) (EDGES new_gr))
  (setf    (NN old)   (NN new_gr))

))
;-------------------------------------------------------------------------------
;BOOL
;graf_del_node (GRAF *gr, int u)
;-------------------------------------------------------------------------------
(defun graf_del_node (gr u)

;  if (u < 0 || u >= gr->nn)  return (FALSE);
;  if (NODE (gr, u) == NOS)   return (FALSE);

  (setf (NODE gr u) NOS)

  (dotimes (v (NN gr))
    (setf (EDGE gr u v) NOS)
    )

;  return (TRUE);
)
;-------------------------------------------------------------------------------
;void
;graf_sub_node (GRAF *gr, int u)
;{
;-------------------------------------------------------------------------------
(defun graf_sub_node (gr u)

; для каждой пары "входноe рeбро - выходноe рeбро" соeдинить их концы новым рeбром

;  int v1, v2;

;  for (v1 = 0; v1 < gr->nn; v1++) {
;    if (u == v1) continue;
;    if (EDGE (gr, v1, u) == NOT) continue;
  (dotimes (v1 (NN gr))
  (unless (= u v1)
  (unless (eql (EDGE gr v1 u) 'NOT)

;    // найден вход

;    for (v2 = 0; v2 < gr->nn; v2++) {
;      if (u == v2) continue;
;      if (EDGE (gr, u, v2) == NOT) continue;
    (dotimes (v2 (NN gr))
    (unless (= u v2)
    (unless (eql (EDGE gr v2 u) 'NOT)

;      // найден выход
      (setf (EDGE gr v1 v2) YES)
;    }
      ))))))

)
;-------------------------------------------------------------------------------
;void
;graf_edges_copy (GRAF *gr_from, int u_from, GRAF *gr_to, int u_to)
;-------------------------------------------------------------------------------
(defun graf_edges_copy (gr_from u_from  gr_to u_to)

;  int v;
;  //double edge;

;  //for (v=0; v < gr_from->nn; v++) { // только односторонние?
;  //  EDGE (gr_to, u_to, v) = EDGE (gr_from, u_from, v);
;  //}

;  for (v=0; v < gr_from->nn; v++) { 
;    if (u_from == v) continue;

;    if (EDGE(gr_from,u_from,v)==YES) EDGE(gr_to,u_to,v) = EDGE(gr_from,u_from,v);
;    if (EDGE(gr_from,v,u_from)==YES) EDGE(gr_to,v,u_to) = EDGE(gr_from,v,u_from);
;  }

  (dotimes (v (NN gr_from))
  (unless  (= u_from v) 

      (when (eql (EDGE gr_from u_from v) YES) 
        (setf (EDGE gr_to u_to v) (EDGE gr_from u_from v)))

      (when (eql (EDGE gr_from v u_from) YES) 
        (setf (EDGE gr_to v u_to) (EDGE gr_from v u_from)))
    ))

)
;-------------------------------------------------------------------------------
;void
;graf_all_to_node (GRAF *gr, int node)
;-------------------------------------------------------------------------------
(defun graf_all_to_node (gr node)

(let (
;  int new_node, u;
;  // 
;  graf_add_node (gr, &new_node, YES);
  (new_node (graf_add_node gr YES))
  )

 ;   (format t "22 ........ ~%")

  (dotimes (u (NN gr))
  (unless (eql node u)

;    if ((EDGE(gr, node,u)==NOT) && (EDGE(gr, u,node)==NOT)) continue;
;    // нашли непустой узел - соседа "u"
    (unless (and (eql (EDGE gr node u) NOS) (eql (EDGE gr u node) NOS))
		
    (graf_edges_copy  gr u gr new_node) ; // скопировать-добавить
    (graf_del_node    gr u)             ; // удалили за ненадобностью
;  }
    )))

  (graf_del_node gr node) ; // теперь удалили и сам исходный узел

))
;-------------------------------------------------------------------------------
;void
;graf_copy (GRAF *gr, GRAF *gr_new)
;-------------------------------------------------------------------------------
(defun graf_copy (gr gr_new)

  (dotimes (u (NN gr))
;    NODE (gr_new, u) = NODE (gr, u);
    (setf (NODE gr_new u) (NODE gr u))

    (dotimes (v (NN gr))
;      EDGE (gr_new, u, v) = EDGE (gr, u, v);
      (setf (EDGE gr_new u v) (EDGE gr u v))
      )
  )

)
;-------------------------------------------------------------------------------
;int
;graf_get_num (GRAF *gr, double node)
;{
;  int num_nodes, u;

;  num_nodes=0;

;  for (u = 0; u < gr->nn; u++) {
;    if (NODE (gr, u) == /* YES */node)
;      num_nodes++;
;  }

;  return (num_nodes);
;}
;-------------------------------------------------------------------------------
;int
;graf_get_num_nodes (GRAF *gr)
;-------------------------------------------------------------------------------
(defun graf_get_num_nodes (gr)

(let (
;  int num_nodes, u;
  (num_nodes 0)
  )

;  for (u = 0; u < gr->nn; u++) {
  (dotimes (u (NN gr))
;    if (NODE (gr, u) == NOT) continue;
  (unless (eql (NODE gr u) NOS)
;      num_nodes++;
    (incf num_nodes)
    ))

  num_nodes
))
;-------------------------------------------------------------------------------
(defun graf_edges_fill (gr u edge)

  (dotimes (v (NN gr))
    (setf (EDGE gr u v) edge)
    )

)
;-------------------------------------------------------------------------------
;void
;graf_add_node (GRAF *gr, int *pu, double node)
;-------------------------------------------------------------------------------
(defun graf_add_node (gr node)

(let (
  u
  )

  (setf u (graf_new_node gr))

;  if (!graf_new_node (gr, &u)) {
  (when (eq u NIL)
    (setf u (NN gr))
    (graf_re_max gr)
    )

  (setf (NODE gr u) node)

;  if (pu) *pu = u;
  u
))
;-------------------------------------------------------------------------------
;BOOL
;graf_get_edges (GRAF *pgr, double *pedge, int *pu, int *pv)
;{
;  static int    u, v, nn;
;  static GRAF   *pg;
;  static double *pedge_mem;
;  static int    *pu_mem, *pv_mem;

;  double edge;

;  if (pgr != NULL) {
;    pg = pgr;
;    pedge_mem = pedge;
;    pu_mem = pu;
;    pv_mem = pv;

;    u = 0;
;    v = 1;
;    nn = pg->nn;

;    return (TRUE);
;  }
;	//-----------------

;  while (TRUE) {
;    if (v >= nn) {
;      u++;
;      v = u + 1;
;    }
;    if (u >= nn - 1)
;      return (FALSE);

;    edge = EDGE (pg, u, v);
;    v++;
;    if (edge != NOT)
;      break;
;  }

;	//printf ("edge = %f \n", edge);

;  if (pedge == NULL)  pedge = pedge_mem;
;  if (pu == NULL)     pu = pu_mem;
;  if (pv == NULL)     pv = pv_mem;

;  if (pedge != NULL)  *pedge = edge;
;  if (pu != NULL)     *pu = u;
;  if (pv != NULL)     *pv = v - 1;

;  return (TRUE);
;}
;-------------------------------------------------------------------------------
;void
;graf_get_num_edges (GRAF *gr, int *one_edges, int *two_edges, int *all_edges)
;-------------------------------------------------------------------------------
(defun graf_get_num_edges (gr)

(let (
;  int num_one_edges, num_two_edges, num_all_edges;
;  int u, v;
   num_all_edges
  (num_one_edges 0)
  (num_two_edges 0)
  )

;  for (u = 0; u < gr->nn; u++)
;  for (v=u+1; v < gr->nn; v++) {

  (dotimes (u (NN gr))
  (loop for v from (+ u 1) to (- (NN gr) 1) do

;    if ((EDGE(gr, u, v)==NOT) && (EDGE(gr, v, u)==NOT))
;      continue;
    (unless (and (eql (EDGE gr u v) NOS) (eql (EDGE gr v u) NOS)) ; continue

    ;(if (and (\= (EDGE gr u v) NOS) (\= (EDGE gr v u) NOS))
    (if (and (not (eql (EDGE gr u v) NOS)) (not (eql (EDGE gr v u) NOS)))
        (progn 
          ;(format t "two_edges: ~2d ~2d [~s ~s] ~%" u v (EDGE gr u v) (EDGE gr v u))
          (incf num_two_edges)
          )
        (progn 
          ;(format t "one_edges: ~2d ~2d [~s ~s] ~%" u v (EDGE gr u v) (EDGE gr v u))
          (incf num_one_edges)
          )
        )

    )
    ))

  (setf num_all_edges (+ num_one_edges num_two_edges))

  (values  num_one_edges num_two_edges num_all_edges)
))
;-------------------------------------------------------------------------------
(defun print_all_smin (pg i all)


  (format t "ALL(~d) =  " i)

  (dotimes (j (NN pg))
    (if (eql (nth j all) MAXVAL)  
        (format t "MAXVAL ")
        (format t "~,5f " (nth j all))      
    )
    )

  (format t "~%")

)
;-------------------------------------------------------------------------------
;void
;graf_metrica (GRAF *pg, double *rr, double *dd, int *num_rr, int *num_dd)
;-------------------------------------------------------------------------------
(defun graf_metrica (pg)

(let (
;  int      i, j;
;  double   all[10000];
;  double   r, d, e;
;  int      num_r, num_d;
  e
;  //YMALLOC (all, double, pg->nn);
  (all (make-list 10000))

  (r     MAXVAL) ; радиус
  (d     MINVAL) ; окраина
  (num_r 0)      ; количество узлов в центре
  (num_d 0)      ; количество узлов на окраине
  )

  (dotimes (i (NN pg))
    (graf_all_smin pg i all) ; кратчайшие расстояния от этой вершины до остальных

    ;; ищем эксцентриситет этой вершины
    (setf e MINVAL)

;    // напeчатаeм список кратчайших расстояний
;    (print_all_smin pg i all)

    (dotimes (j (NN pg))
    (unless (= i j)                ; continue 
    (unless (eql (nth j all) MAXVAL) ; continue 

      (setf e (max e (nth j all)))
      )))

    ;(format t "i=~d  e=~,5f ~%" i e)

    (cond
    ((< e r) (setf r e) (setf num_r 1)) ; ищем радиус 
    ((= e r) (incf num_r))       ; и считаем кол-во таких центральных точек 
    )

    (cond
    ((> e d) (setf d e) (setf num_d 1)) ; ищем диаметр 
    ((= e d) (incf num_d))          ; и считаем кол-во таких окраиных точек 
    )

    )

;  (format t "~%")

;  *rr = r;  *num_rr = num_r;
;  *dd = d;  *num_dd = num_d;
  (values  r d num_r num_d)
))
;-------------------------------------------------------------------------------
(defun graf_check (gr)


(let (
   exist_edges ;  BOOL
   (is_print  NIL) ;T)
   )


  (when is_print (format *error-output* "graf_check.............. BEG ~%"))
  ;(Graf_Print gr)

  ; идeм циклом по всeм рeбрам --------------------------------------

  (dotimes (u (NN gr))
  (dotimes (v (NN gr))
  (unless (eql (EDGE gr u v) NOS)

    (when is_print 
      (format *error-output*  "~2d -> ~2d  (~s) ~%" u v (EDGE gr u v)))

    (when (or (eql (NODE gr u) NOS) (eql (NODE gr v) NOS))
      ;; нет конца(ов) у существующего ребра, значит "удалить" ребро:

      (when is_print 
        (format *error-output* "not nodes for this edge: ~2d - ~2d  [~s ~s] ~%" 
                u v (NODE gr u) (NODE gr v)))

      (setf (EDGE gr u v) NOS)
      )
    )))


  ; идeм циклом по всeм дeйствующим узлам --------------------------

  (dotimes (u (NN gr))
  (unless (eql (NODE gr u) NOS)

    (setf exist_edges FALSE)

    ; провeряeм всe рeбра для этого узла
    (dotimes (v (NN gr))
      (when (not (eql (EDGE gr u v) NOS))
        (setf exist_edges TRUE)
      ))

    ;; для существующего узла нет ни одного ребра, значит "удалить" узел:
    (when (not exist_edges) 
      ;(warn "not edges for this node")
      (setf (NODE gr u) NOS))
    ))

    (when is_print 
      (format *error-output*  "graf_check.............. END  ~%"))

))
;===============================================================================
;
;
;
;
;===============================================================================
;-------------------------------------------------------------------------------
(defun test_00 (argus) (declare (ignore argus))

(let (
  (nn 4)
  gr u
  )

  (setf *simp_random* T)  ;# для точного сравнения с TCL

  (setf gr (Graf_Create nn))

  (Graf_Init1  gr 50.0 50.0)
  (Graf_Print gr)

  (graf_check gr)
  (Graf_Print gr)

  (setf u (graf_add_node gr YES))
  (graf_edges_fill gr u YES)

  (Graf_Print gr)

  (graf_check gr)
  (Graf_Print gr)

  ;(quit)

  (graf_del_node gr u)
  (Graf_Print gr)

))
;-------------------------------------------------------------------------------
(defun test_02 (argus)  

(declare (ignore argus))

(let (
  (gr (Graf_Create 3)) 
  )

  (setf (EDGE gr 0 1) 1)
  (setf (EDGE gr 1 2) 1)
  (setf (EDGE gr 2 0) 1)

  (Graf_Print gr)

  (Graf_To_Dot gr t)

  ;(Graf_To_Dotfile gr "a_gra.dot")  

))
;-------------------------------------------------------------------------------
(defun test_05 (argus) (declare (ignore argus))

(let (
  gr ;u
  )

  (setf *simp_random* T)  ;# для точного сравнения с TCL

  (setf gr (Graf_Create 4))

  (Graf_Init1  gr 50.0 50.0)

  (Graf_Print gr)

  (format t "~%")
))
;-------------------------------------------------------------------------------
(defun test_11 (argus)  

(declare (ignore argus))

(let (
  ;(flag  (not T))
  gr ;s tar
  nn
  )

  ;(YRAND_C)
  ;(srandom_set 2011)
  (YRAND_S)

  ;(YRAND_F) ; а почему не сработало (Y-srand48 2010) из a-comm.cl ?
  (Y-srand48 2010)

  (setf nn 6)
  (setf gr (Graf_Create nn))
  
  (Graf_Init gr GR_RAND 0.0 5.0 GR_RAND 0.0 5.0)
    
  ;(setf s   (YRAND 0 (- nn 1)))
  ;(setf tar (YRAND 0 (- nn 1)))
  
  (Graf_Print gr)
  (format t "~%")

  (multiple-value-bind (r d num_r num_d)
      (graf_metrica gr)
    
    (format t "r = ~5f  num_r = ~s ~%" r num_r)
    (format t "d = ~5f  num_d = ~s ~%" d num_d)
    )
  
  (format t "~%")
))
;-------------------------------------------------------------------------------
(defun test_99 (argus)  (declare (ignore argus))

(let (
  gr 
  (all (make-list 10000))
  )

  (YRAND_C)

  (setf gr (Graf_Create 4))
  ;(Graf_Init  gr GR_RAND 0.0 0.0  GR_RAND NOS NOS)

  (setf (EDGE gr 0 1) 1)
  (setf (EDGE gr 1 0) 1)

  (setf (EDGE gr 1 2) 1)
  (setf (EDGE gr 2 1) 1)

  (setf (EDGE gr 2 3) 1)
  (setf (EDGE gr 3 2) 1)

  (setf (EDGE gr 0 3) 1) 
  (setf (EDGE gr 3 0) 1) 

  (Graf_Print gr)
  (format t "~%")

;  (graf_smin  gr 0 1 NIL)
;  (graf_smin  gr 0 2 NIL)
;  (graf_smin  gr 0 3 NIL)

  ;(graf_all_smin  gr 0 all) ; кратчайшие расстояния от этой вершины до остальных
  ;(print_all_smin gr 0 all)

  (dotimes (i (NN gr))
    (graf_all_smin  gr i all) ; кратчайшие расстояния от этой вершины до остальных
    (print_all_smin gr i all)
    )

  (format t "~%")
))
;===============================================================================
; 
;
;===============================================================================
;
;-------------------------------------------------------------------------------
;(defun test-bipartite (graph)

;(let ((map (make-hash-table))
;      (visited '()))

;  (labels ((con1 (v)
;                 "vertices immediatelly connected to V"
;                 (tail (assoc v graph)))
;           (paint (v level)
;                  "paint the graph from vertix v, return all
;                   visited so far (in subsequent calls of  PAINT) vertices"
;                  (pushnew v visited)
;                  (setf (gethash v map) level)
;                  (maps (lambda (v) (paint v (1+ level)))
;                        (remove-if (lambda (v) (member v visited))
;                                   (con1 v)))
;                  visited ))
;    ;; 
;    (unless (set-exclusive-or (paint 1 0)
;                              (mapcar #'first graph))
;      (every (lambda (entry)
;               (every (lambda (v)
;                        (oddp (+ (gethash (first entry) map)
;                                 (gethash v map))))
;                      (tail entry)))
;             graph))
;    )

;  )
;;) ??

;)
;-------------------------------------------------------------------------------
;(defun main_1 ()

;(let (
;  (gr1 '( ; bipartite one
;        (0 . (1))      (1 . (0 2 8))
;        (2 . (1 3))    (3 . (2 6))
;        (4 . (5 7))    (5 . (4))
;        (6 . (3))      (7 . (4 8))
;        (8 . (1 7))
;        ))

;  (gr1 '( ; not bipartite one
;        (0 . (1 2))    (1 . (0 2 8))
;        (2 . (1 3))    (3 . (2 6))
;        (4 . (5 7))    (5 . (4))
;        (6 . (3))      (7 . (4 8))
;        (8 . (1 7))
;        ))

;  (gr1 '( ; not connected one
;        (0 . (1 2))    (1 . (0 2 8))
;        (2 . (1 3))    (3 . (2 6))
;        (4 . (5 7))    (5 . (4))
;        (6 . (3))      (7 . (4 8))
;        (8 . (1 7))    (9 . ())
;        ))
;  )

;  (format t "~s ~%" (test-bipartite gr1))

;))
;===============================================================================

;(main_1)

;-------------------------------------------------------------------------------
(defun test_01 (argus)  (declare (ignore argus))

(let (
  ;(flag  (not T))
  gr s tar
  ;nn
  )


  (YRAND_C)
  ;(srandom_set 2011)

  (setf gr (Graf_Create 4))

  ;(Graf_Init  gr GR_RAND 0.0 0.0  GR_RAND NOS NOS)

  (setf (EDGE gr 0 1) 1)
  (setf (EDGE gr 1 2) 1)
  (setf (EDGE gr 2 3) 1)
  (setf (EDGE gr 0 3) 3.1) ;3.1 2.9

  (setf (NODE gr 0) 2.2)

  (setf s   0)
  (setf tar 3)
  ;(setf s   (YRAND 0 (- nn 1)))
  ;(setf tar (YRAND 0 (- nn 1)))
  

  ;(format t "-------------------------------~%")
  ;(format t "nn= ~S  node0= ~S ~%" (NN gr) (NODE gr 0))
  (format t "~%")

  (Graf_Print gr)
  ;(format t "-------------------------------~%")

  (graf_smin  gr s tar NIL)
  (format t "~%")


  (multiple-value-bind (r d num_r num_d)
      (graf_metrica gr)
    
    (format t "r = ~5f  num_r = ~s ~%" r num_r)
    (format t "d = ~5f  num_d = ~s ~%" d num_d)
    )
  
  (format t "~%")

))
;===============================================================================
;===============================================================================

