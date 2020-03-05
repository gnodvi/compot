; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
; *                                                                            *
; *  ��� ����� �����: gr_tao.c                                                 *
; *                                                                            *
;===============================================================================
                                                                                              
;#include "a_comm.h"
;#include "a_plot.h"

;#include "g_libs.h"

;(load "h-graf.cl")

; ��� (�������) �e�e�e���� ��e e��� � "a_comp.cl"
;(defvar MAX_OUT_ 50)

;===============================================================================



;===============================================================================

;-------------------------------------------------------------------------------
(defun tao_test (argus) (declare (ignore argus))

  (format t "~%")

  (format t "o= ~a ~%" (char "+o*.#" 0))
  (format t "o= ~a ~%" (char "+o*.#" 1))
  (format t "o= ~a ~%" (char "+o*.#" 2))
  (format t "o= ~a ~%" (char "+o*.#" 3))
  (format t "o= ~a ~%" (char "+o*.#" 4))

  (format t "~%")  

  ;; o= +        ???????????????/ ��� ��� ?
  ;; o= o 
  ;; o= * 
  ;; o= . 
  ;; o= # 
  
)
;===============================================================================
;===============================================================================


;typedef struct {
;  int      numw;   // ����� ������ ��� ������ �������
;  char    *legend; // ��� �������
;  BOOL     val;    // ������ �������
;  double  *f;      // ��� ������������ ������
;} ZT_OUT;

(defmacro ZT_OUT_NUMW   (p) (list 'nth 0 p))
(defmacro ZT_OUT_LEGEND (p) (list 'nth 1 p))
(defmacro ZT_OUT_VAL    (p) (list 'nth 2 p))
(defmacro ZT_OUT_F      (p) (list 'nth 3 p))


;===============================================================================
;
;-------------------------------------------------------------------------------
;ZT_OUT *
;Out (ZT_OUT *p_out, const char *legend)
;-------------------------------------------------------------------------------
(defun Out (p_out legend)

  (dolist (p p_out)
    (when (equal (ZT_OUT_LEGEND p) legend)
    ;; ����� ������ �� �� �����

    (when (ZT_OUT_VAL p) ; e�e ����e��� ����� ������ ���
      ;(format t "Out: ~s ~s  ~%" (ZT_OUT_LEGEND p) (ZT_OUT_VAL p))
      (return-from Out p)
    ))
  )

  NIL
)
;-------------------------------------------------------------------------------
;int
;Get_N_Plot (ZT_OUT *p_out, int *p_num_fi)
;-------------------------------------------------------------------------------
(defun Get_N_Plot (p_out)

;  ZT_OUT *p;
;  int max_numw = -10; // ��� �������� ����� ������� 
;  int num_fi = 0;     // ��� �������� ����� ��������

;  for (p = p_out; p->numw != 0; p++) {
;    if (!(p->val)) continue; // ���������� - ���������� ������

;    max_numw = YMAX (max_numw, p->numw);
;    num_fi++;
;  }

;  if (p_num_fi)  *p_num_fi = num_fi;
;  return (max_numw); // ����� ������� (��������� � �������) - ���� ��� ����������� ?!

  (list-length p_out) ; ���� ����� ������� �������
)
;-------------------------------------------------------------------------------

; �������� ������e���� �e�e�e���� � ����e���e:

(defvar s_plot :unbound)  ;  static YT_PLOT *plot;
(defvar s_step :unbound)  ;  static int      step;

;# --------------------------------------------------------------------------------
(defun Outs_To_Plot (p_out) 

(let (
      F
      )
  
  (format *error-output* "~%")
  (format *error-output* "Outs_To_Plot .......................... ~%")
  (format *error-output* "~%")

;  puts "p_out = $p_out"
;  puts ""
  (format *error-output* "p_out = ~s ~%" p_out)
  (format *error-output* "~%")

;  set ti 0 ;# ::l_step ??

;  set fi 0 ;# ����� �������-������� 


;  foreach  p $p_out {

;    if {[ZT_OUT_VAL_get $p] == "NIL"} {continue}

;    set F [ZT_OUT_F_get $p]

;    puts "F = $F"

;    lset [PP_STEP_F $::s_plot $ti]  $fi $F

;    incr fi
;  }
    

  (dolist (p p_out)
  (unless (eq (ZT_OUT_VAL p) NIL)


    (setf F (ZT_OUT_F p))

    (format *error-output* "F = ~s ~%" F)
    
    ))
))
;-------------------------------------------------------------------------------
(defun run_ploter_sh (progname)

(let (

  ;(progname "ploter.sh")
  ;(progname "t_plot.sh")
  )

#+:CLISP 
      (EXT:run-shell-command  progname)
      ;;      (uiop:run-program cmd :output CALC_FILE) 
#+SBCL 
      (sb-ext:run-program     progname  nil)

))
;-------------------------------------------------------------------------------
;void
;Do_Open_Close (ZT_OUT *p_out, int mod, int xnum, BOOL is_gnu)
;-------------------------------------------------------------------------------
(defun Do_Open_Close (p_out mod xnum is_gnu)

(let (

  ;(progname "ploter.sh")

  (progname "t_plot.sh") ;; COM/src/b-plot.cl :    PLT !!

  ;(progname "../ext/ploter/ploter DAT") 
  ;;  Couldn't execute "../ext/ploter/ploter DAT": No such file or directory
  )

  ;(declare (ignore is_gnu))

;  static YT_PLOT *plot;
;  static int      step;
  
  (when (= mod 1) 
  (let (
;    ZT_OUT *p; // ��������� ���������
    wi ;    int wi/* , max_numw */;
    num_fi fi
    li ;    int n_line[MAX_OUT], li;
    (n_line (make-list MAX_OUT))
    )

;    /* max_numw =  */Get_N_Plot (p_out, &num_fi); // ����� ������� ��� ������ ��������
    (setf num_fi (Get_N_Plot p_out))
    ;(format t "num_fi= ~s ~%" num_fi)

    (setf s_plot (plot_create num_fi xnum 1))

    (setf (PP_STEP_NAME s_plot 0) "Test for GRAF")

    (setf s_step 0)
;    n_line[0] = n_line[1] = n_line[2] = n_line[3] = n_line[4] = 0;
    (setf (nth 0 n_line) 0) 
    (setf (nth 1 n_line) 0) 
    (setf (nth 2 n_line) 0) 
    (setf (nth 3 n_line) 0) 
    (setf (nth 4 n_line) 0) 

    ;; ���� ������ �� ���� ������� : 

    (setf fi 0) ; ����� �������-������� ��� ����� ���������

    ;; ��������� ��������� (���������) ������ �������:
    (plot_frames_init0  s_plot)

;    for (p=p_out; p->numw != 0; p++) {
    (dolist (p p_out)
    ;(unless (eq (nth 2 p) NIL)
    (unless (eq (ZT_OUT_VAL p) NIL)
;      if (!(p->val)) continue;

;      p->f = (double*) malloc (xnum * sizeof(double)); // ������ ��� ������
      ;(setf (ZT_OUT_F p) (make-array xnum))
      (setf (ZT_OUT_F p) (make-list xnum))

;      wi = p->numw - 1; // �������� (������� � ����) ������ ������ ��� ����� �������
      (setf wi (- (ZT_OUT_NUMW p) 1))
;      li = n_line[wi];   // ����� ���������� ������� ��� ����� ������
      (setf li (nth wi n_line))

;      plot->fr[wi][li] = /* p->f */fi;
      (setf (aref (FR s_plot) wi li) fi)       
;      n_line[wi]++;
      (incf (nth wi n_line))

;      P_LINE (plot, fi, /*ti*/0) = p->f;
      (setf (PP_STEP_F s_plot 0 fi) (ZT_OUT_F p))

;      P_NAME (plot, fi) = p->legend;
      (setf (PP_NAME s_plot fi) (ZT_OUT_LEGEND p))

;      fi++;
      (incf fi)
;    }
     ))
  ))

;  //-------------------------

  (when (= mod 2) 
;    plot->x[step] = step;
    (setf (nth s_step (X s_plot)) s_step)
;    step++;
    (incf s_step)
  )
;  //-------------------------

  (when (= mod 3) 
;    plot->xnum = step;
    (setf (L_XNUM s_plot) s_step)

;    //if (is_gnu)  plot_print     (plot, TRUE/* is_win */, is_gnu);
;    //if (is_gnu)  plotbig_print     (plot, 0,0,0,0);
;    if (is_gnu)  plot_print     (plot);
;    //else         plot_print_one (plot, TRUE/* is_win */, /* is_gnu */FALSE, 0);
;    else         plot_print_one (plot, 0);


    ;# � ����� ���� ������� ������ (������ ������), � ����� ���� ���� ��������!
    ;#
    ;(Outs_To_Plot p_out)


    ;(plot_print_info s_plot)
    (plot_print_one   s_plot 0)
    ;   )

    ;(plot_print_info s_plot)
    ;(format t "IS_GNU = ~s ~%" is_gnu)
    (format t "~%" )

    (when (= is_gnu 1)  ; ������ ������ ������ (when is_gnu ????

      ;; C:
      ;; gnuplot_resetplot(gp); //??
      ;; gnuplot_cmd (gp, "set multiplot"); // ������ � ��������������          
      ;; plot_gnu (title, ti, plot, gp);


      ;(format t ".........111 ~%")
      ;(plot_print_one_gui s_plot 0)

      (plot_save  s_plot) ; ��������� � ����� (��� ���� ������ ���� � ������� !!)

      (run_ploter_sh  progname)
      ))

))
;-------------------------------------------------------------------------------
(defun  OUTINT (pout val step)

  ;((pout)->f)[(step)]=(val)

  ;(format *error-output* "~%")
  ;(format *error-output*  "OUTINT: pout= ~s ~%" pout)

  (setf (nth step (ZT_OUT_F pout))  val)

  ;(format *error-output*  "OUTINT: pout= ~s ~%" pout)
  ;(format *error-output*  "OUTINT: step= ~s ~%" step)
  ;(format *error-output*  "OUTINT: val = ~s ~%"  val)


  (format t "~3d " val)

)
;-------------------------------------------------------------------------------
(defun  OUTDBL (pout val step)

  ;((pout)->f)[(step)]=(val)

  (setf (nth step (ZT_OUT_F pout))  val)

  (format t "~f " val)

)
;-------------------------------------------------------------------------------
(defun  OUT_ (v)

;#define OUT(v) ((v) && (v)->val)
;; !!!!!!!!!!!!! �e�� ��� �e���������� ����e���..

 (ZT_OUT_VAL  v)
)
;-------------------------------------------------------------------------------
;    ������ � ����� �� ������ ���� ��������� ������������� �����              */
;-------------------------------------------------------------------------------
;void
;graf_calc_out (int mod, GRAF *gr, ZT_OUT *p_out, int xnum, 
;             BOOL  is_gnu)
;-------------------------------------------------------------------------------

(defvar l_step :unbound)  ;  static int step;

;-------------------------------------------------------------------------------
(defun graf_calc_out (mod gr p_out xnum is_gnu)

(let (
;  //BOOL  is_gnu  = TRUE;
  (to_term  t)

;  static int step;
  ;;(step (- mod 1)) ; ��� ������ ��� ���������� �� ����e (?), ������� ���

  num_nodes  

  out1 out2 out3  pout 
  out_nminus out_nplus out_nnull out_rmin out_rmax out_numr out_numd
  out_r out_d 
  out_sum out_metr

;#define OUTPLOT(p,val,step) ((p)->f)[(step)]=(val);

;#define OUTINT(p,val,step) {OUTPLOT(p,val,step); if (to_term) printf ("%3d  ", (val));}
;#define OUTDBL(p,val,step) {OUTPLOT(p,val,step); if (to_term) printf ("%.2f  ", (val));}
;#define OUT(v) ((v) && (v)->val)

  rmin rmax sum           ;  double  rmin, rmax, sum;
  nplus nminus nnull metr ;  int     metr, nnull, nplus, nminus;
  value                   ;  double  value;
  )

;  /* --------------- ���������� � ������ */
  (when (= mod 1) 
    (setf l_step 0)
    (Do_Open_Close  p_out mod xnum is_gnu)

    (return-from graf_calc_out)
  )

;  /* --------------- ���������� ������ --*/
  (when (= mod 3)
    ;
    (Do_Open_Close  p_out mod xnum is_gnu)
    (return-from graf_calc_out)
  )
;  /*------------------------------------*/


  (when to_term (format t "~3d)  " l_step))
;  //step++;
  (Do_Open_Close  p_out mod xnum is_gnu)

;  /*------- ���������� ����� � ����� ----*/

;  pout = Out (p_out, "Nodes");
  (setf pout (Out p_out "Nodes"))
  ;;(format t "pout= ~s ~%" pout)

;  if (pout && pout->val) {
  (when (OUT_ pout)
    (setf num_nodes (graf_get_num_nodes gr))
    (OUTINT pout num_nodes l_step)
    (format t " - ")
    )
;  }
;  /*------ ���������� ����� � ����� -----*/

  (setf out1 (Out p_out "OneEdges"))
  (setf out2 (Out p_out "TwoEdges"))
  (setf out3 (Out p_out "AllEdges"))

;  if ((out1 && out1->val) || (out2 && out2->val) || (out3 && out3->val)) {
  (when (or (OUT_ out1) (OUT_ out2) )

;    graf_get_num_edges (gr, &num_one_edges, &num_two_edges, &num_all_edges);
     (multiple-value-bind (num_one_edges num_two_edges num_all_edges)
         (graf_get_num_edges  gr)

      ; (format t "~2d ~2d " num_one_edges num_two_edges)
     (when (OUT_ out1) (OUTINT out1 num_one_edges l_step))
     (when (OUT_ out2) (OUTINT out2 num_two_edges l_step))
     (when (OUT_ out3) (OUTINT out3 num_all_edges l_step))

;    if (out1 && out1->val)  OUTINT (out1, num_one_edges, step);
;    if (out2 && out2->val)  OUTINT (out2, num_two_edges, step);
;    if (out3 && out3->val)  OUTINT (out3, num_all_edges, step);
;  }
     )
     )


  ;(format *error-output*  "~%")
  ;(format *error-output*  "~%")
  ;(format *error-output*  "p_out ===== ~s ~%" p_out)


;  /*------------------------------------*/
  (setf out_rmin   (Out p_out "Rmin"))
  (setf out_rmax   (Out p_out "Rmax"))

  (setf out_nminus (Out p_out "Nminus"))
  (setf out_nplus  (Out p_out "Nplus" ))
  (setf out_nnull  (Out p_out "Nnull" ))

  (setf out_sum    (Out p_out "Sum"))
  (setf out_metr   (Out p_out "Metr"))

  (setf out_r      (Out p_out "R"))
  (setf out_d      (Out p_out "D"))

  (setf out_numr   (Out p_out "NumR"))
  (setf out_numd   (Out p_out "NumD"))

  (setf nminus 0)
  (setf nplus  0)
  (setf nnull  0)

  (setf rmin   1000000)
  (setf rmax  -1000000)
  (setf sum    0)

;  /*   graf_get_edges (gr, &value, NULL, NULL); */
;  /*   while (graf_get_edges (NULL, NULL, NULL, NULL)) { */

  (dotimes (u (NN gr))
  (dotimes (v (NN gr))
;    //if (u == v) continue;
;    if (EDGE(gr, u, v)==NOT) continue;
  (unless (eql (EDGE gr u v) NOS)

    (setf value (EDGE gr u v))

    ;(when (eql (EDGE gr u v) YES) ; ��e�� ����e �e��� �����e ���e� � ������ ??
    ;  (format t "!!!!!!!!!!!!!!!!!!!!!!!!!!! ~%") ; ��� � � �� ��� ������ ?!
    ;  )

    (setf rmin (MIN rmin value))
    (setf rmax (MAX rmax value))

    ;(format t "~2d ~2d -> ~s ~%" u v value)

    (when (< value 0)  (incf nminus))
    (when (> value 0)  (incf nplus))
    (when (= value 0)  (incf nnull))

    (incf sum value)
;  }
    )))


  (when (OUT_  out_rmin)   (OUTDBL  out_rmin rmin l_step))
  (when (OUT_  out_rmax)   (OUTDBL  out_rmax rmax l_step))

  (when (OUT_  out_nminus) (OUTINT  out_nminus nminus l_step))
  (when (OUT_  out_nplus)  (OUTINT  out_nplus   nplus l_step))
  (when (OUT_  out_nnull)  (OUTINT  out_nnull   nnull l_step))

  ;(format t "1 ........... ~%")
  (when (OUT_  out_sum)  
    ;(format t "........... ~%")
    (OUTDBL out_sum  sum  l_step)
    )
  (when (OUT_  out_metr)   (OUTINT out_metr metr l_step))

  (multiple-value-bind (r d num_r num_d)
      (graf_metrica gr)

    (when (OUT_ out_r)      (OUTDBL out_r r l_step))
    (when (OUT_ out_d)      (OUTDBL out_d d l_step))

    (when (OUT_ out_numr)   (OUTINT out_numr num_r l_step))
    (when (OUT_ out_numd)   (OUTINT out_numd num_d l_step))

    (when (OUT_ out_metr) 
      (setf metr 0)

      ;(format t "2..... ~%")
;  // ������ ��� ��������� ������������ ???

;    for (i=0;   i <= gr->nn-3; i++)	/*??? */
;    for (j=i+1; j <= gr->nn-2; j++)
;    for (k=j+1; k <= gr->nn-1; k++) {
;      i_j = EDGE (gr, i, j);
;      j_k = EDGE (gr, j, k);
;      k_i = EDGE (gr, k, i);

;      if ((i_j <= k_i + j_k) && (j_k <= i_j + k_i) && (k_i <= j_k + i_j))
;        metr++;
;    }
      )

  )
;  /*--------------------------------------*/

  (when to_term (format t "~%"))

;  step++;
  (incf l_step)
))
;===============================================================================
;
;===============================================================================
;-------------------------------------------------------------------------------
;int
;tao_find_new_node (GRAF *gr, int cur_node)
;{
;  int u;

;  for (u = 0; u < gr->nn; u++) {
;    if (EDGE (gr, cur_node, u) == NOT) continue;
;    if (RandYes(80.0)) continue;

;    //new_node = u;
;    break;
;  }
;  //new_node = YRAND (0, gr->nn-1);

;  return (u);
;}
;-------------------------------------------------------------------------------
;void
;tao_edges_mutaciq (GRAF *gr, int u, double mutaciq)
;-------------------------------------------------------------------------------
(defun tao_edges_mutaciq (gr u mutaciq)

(let (
;  int v;
  edge ;  double edge;
  )

  (dotimes (v (NN gr))
    (setf edge (EDGE gr u v))

    (when (and (RandYes mutaciq) (eql edge YES))
      ;(format t "Mutaciq: ~2d ~2d ~%" u v)
      (setf edge NOS)
      )

    (setf (EDGE gr u v) edge)
    )

))
;-------------------------------------------------------------------------------
;void
;tao_addnode_copys (GRAF *gr, GRAF *gr_new, int cur_node)
;-------------------------------------------------------------------------------
(defun tao_addnode_copys (gr gr_new cur_node)

(let (
  (new_node (graf_add_node  gr_new YES))
  )

  (graf_edges_copy  gr cur_node  gr_new new_node)

  (tao_edges_mutaciq  gr_new new_node 10.0)
				
  (when (RandYes 30) 
    ;(format t "RandYes: ~2d ~2d ~%" cur_node new_node)
    (setf (EDGE gr_new cur_node new_node) YES))

  (when (RandYes 30)  
    ;(format t "RandYeS: ~2d ~2d ~%" new_node cur_node)
    (setf (EDGE gr_new new_node cur_node) YES))

))
;-------------------------------------------------------------------------------
;void
;tao_addnode_clone (GRAF *gr, int node)
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
(defun tao_addnode_clone (gr node)

(let (
  index    ; int u, /* v, */  i, j, index;
  new_node  
  (s (make-list 100)) ;  int s[1000];
  )

  ;(format t "tao_addnode_clone ........ ~%")
  ;(format t "nn = ~2d ~%" (NN gr))

  ;; ������������� ������
  (setf index 0)

  ;;  ��������� �����-������ � ���������� �� ������
  ;;  for (u=0; u < gr->nn; u++) {
  (dotimes (u (NN gr)) ; ��� ����� �������e��� ���� ��� �e�e� ������ ??
                       ; � � �� ��� �e ��� !!

;    //if (u == node) continue;
;    if (EDGE (gr, u, node) == NOT) continue;
;    if (EDGE (gr, node, u) == NOT) continue;
    (unless (eql (EDGE gr u node) NOS)
    (unless (eql (EDGE gr node u) NOS)

      ;; graf_add_node (gr, &new_node, YES); // ������������ � �����������
      (setf new_node (graf_add_node gr YES))
      ;; ��e�� ������e��� �e ������� ���e�e�e��, ��������� ����e� ����� 
      ;; ���e� ��e����������!
      ;; 
      ;; �������e��������� �e���� � "graf_re_max"

     ;(format t "u = ~2d   new_node = ~2d ~%" u new_node)

     (setf (EDGE gr new_node u)  (EDGE gr node u))
     (setf (EDGE gr u new_node)  (EDGE gr u node))

;    s[index++] = new_node; // ������� � ������ ����� ������ ����
     (setf (nth index s) new_node)
     (incf index)
    )))

  (setf (nth index s) -1) ; // ��������� "�����������" ������

  ; ����e������ ������
;  (format t "s= (")
;  (loop for i from 0 until (\= (nth i s) -1) do
;    (format t "~2d " (nth i s))
;    )
;  (format t ") ~%")

;  //  ��������� ������ ����� � ������ (���������� �������)
;  for (i=0; s[i] != -1; i++) 
;  for (j=0; s[j] != -1; j++) {
  (loop for i from 0 until (\= (nth i s) -1) do
  (loop for j from 0 until (\= (nth j s) -1) do
;      EDGE (gr, s[i], s[j]) = EDGE (gr, s[j], s[i]) = YES;
      (setf (EDGE gr (nth i s) (nth j s))  YES)
      (setf (EDGE gr (nth j s) (nth i s))  YES)
      ;(format t "~2d - ~2d ~%" (nth i s) (nth j s))

    ))
;    }

;  // ������� ��������� ����� ; � ���e� ����� �����������?
  (graf_del_node  gr node)

  ;(format t "tao_addnode_clone ........END ~%")
))
;-------------------------------------------------------------------------------
;void
;tao_addnode (GRAF *gr, GRAF *gr_new, int node)
;-------------------------------------------------------------------------------
(defun tao_addnode (addnode_type gr_old gr_new node)
;(declare (ignore gr node))

  (cond 

   ;; ������� ����������� � ��������
   ((= addnode_type 1)  (tao_addnode_copys  gr_old gr_new node))

   ;;����������-������������
   ((= addnode_type 2)  (tao_addnode_clone         gr_new node))

   ;; ��� ���������� �e���
   ((= addnode_type 3)  (graf_add_node             gr_new  YES))
    )

)
;-------------------------------------------------------------------------------
;void
;tao_delnode (GRAF *gr, int node)
;-------------------------------------------------------------------------------
(defun tao_delnode (delnode_type gr node)
;(declare (ignore  delnode_type gr node))

  ;(format t "tao_delnode ........ ~%")

  (cond 
   ;; ������� �������� (������ �� �������)
   ((= delnode_type 1)  
    (graf_del_node gr node)
    )

   ;; ������� ��������� � ������� �������� 
   ((= delnode_type 2)  
    (graf_sub_node  gr node)
    (graf_del_node  gr node)
    )

   ;; �������� �� ����������� � ���� ���� (�� ����� �� ���������?)
   ((= delnode_type 3)  
    (graf_all_to_node gr node)
    )

   ) ; cond.............................

)
;-------------------------------------------------------------------------------
;int
;tao_what_do (GRAF *gr_new, int cur_node)
;-------------------------------------------------------------------------------
(defun tao_what_do (gr_new cur_node)
(declare (ignore gr_new cur_node))

(let* (
;  double do_add, do_not, do_del;
	
  (do_add  50)
  (do_del  40)

  ;;(do_not  (- 100 (+ do_add do_del)))
  (do_not  NIL) ; �� ������������ !!

  (ret (Rand123  do_add do_not do_del)) ; [ .. 50 .. NIL .. 40 ]  ??
  )

  ;(format *error-output*  "tao_what_do ..  do_add=~s  do_not=~s  do_del=~s   : ret= ~d ~%" 
  ;        do_add do_not do_del   ret)

  ret
))
;-------------------------------------------------------------------------------
(defun tao_bestday (gr)

(let (
;  int node;
;  graf_add_node (gr, &node, YES);
  (node (graf_add_node gr YES))
  )

;  EDGE (gr, node, node) = YES; //!!!!!!!!!!!!
  (setf (EDGE gr node node) YES)

))
;-------------------------------------------------------------------------------
;(defun argus_parser1_print (
;                         nums   test  seed 
;                         par1  par2 
;                         out_mode out_is_gnu 
;                         ) 


;  (format  *error-output*  "~%")
;  (format  *error-output*  "---------------argus_parser1-------------------~%")
;  (format  *error-output*  "~%")

;  (format  *error-output*  "nums       = ~s ~%" nums)
;  (format  *error-output*  "test       = ~s ~%" test)
;  (format  *error-output*  "seed       = ~s ~%" seed)

;  (format  *error-output*  "~%")

;  (format  *error-output*  "par1       = ~a ~%" par1)
;  (format  *error-output*  "par2       = ~a ~%" par2)

;  (format  *error-output*  "~%")

;  (format  *error-output*  "out_mode   = ~s ~%" out_mode)
;  (format  *error-output*  "out_is_gnu = ~s ~%" out_is_gnu)

;  (format  *error-output*  "~%")
;  (format  *error-output*  "-----------------------------------------------~%")
;  (format  *error-output*  "~%")
  
;)
;-------------------------------------------------------------------------------
(defun argus_parser1  (argus 
                         r_nums   r_test  r_seed 
                         r_par1  r_par2 
                         r_out_mode r_out_is_gnu 
                         ) 

  ;;(setf nums (symbol-value  r_nums))


  (set r_nums      (parse-integer (nth 0 argus))) ; int nums =  /* 10000 */ 500;
  (set r_test      (parse-integer (nth 1 argus)))
  (set r_seed      (parse-integer (nth 2 argus)))


  (set r_par1   (nth 3 argus)) 
  (set r_par2   (nth 4 argus)) 

  (set r_out_mode     (parse-integer (nth 5 argus)))
  (set r_out_is_gnu   (parse-integer (nth 6 argus)))

)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun tao_graf_edgerecalc (gr point new_point  test p_isplus)

(let (
 
  edge      ; static double edge;
  sum       ; double sum;
  rab_point ; int    new_point, rab_point;

  isplus
  )

  ; ����� �� ������������, ��� ��� ����� [point new_point] ����������
  ; ������� �� ������ ����� ���������:
  ; 
  ; 
  (when (eql  (EDGE gr point new_point) NOS)
    (error "tao_graf_edgerecalc")
    )

  (cond 

    ((= 1 test) ; ------------------------------------ /*Simple */

     (setf isplus (symbol-value  p_isplus))

      (if  isplus
        (incf (EDGE gr point new_point))
        (decf (EDGE gr point new_point))
        )

      (set p_isplus (not isplus))
    )

    ((= 2 test) ; ------------------------------------ /*Triang */

      (setf rab_point (YRAND 0 (- (NN gr) 1)))
      (unless (or (= rab_point point) (= rab_point new_point))

      (when (>= (EDGE gr point new_point) 
          (+ (EDGE gr     point rab_point) 
             (EDGE gr rab_point new_point)))

        (decf (EDGE gr point new_point))
        (incf (EDGE gr point rab_point))
      )
     ))

    ((= 3 test) ; ------------------------------------ /*All-Plus */

      (incf (EDGE gr point new_point))			
     )

    ((= 4 test) ; ------------------------------------ /*Median */

     ;;  �������� �� ��������� ����� ��������� � �������� 
     ;;  �� ���� ������ �� ������� �����

      (setf sum 0)

      ;// ���� ����������� �� ������e...
      (dotimes (u (NN gr))
      (dotimes (v (NN gr))

        (setf edge (EDGE gr u v))
        (incf sum edge) 
        ))

      (setf sum (/ sum (- (* (NN gr) (NN gr)) (NN gr)) 2))

      (if (>  (EDGE gr point new_point) sum)
        (decf (EDGE gr point new_point))
        (incf (EDGE gr point new_point))
        )
      )
    )
		

))
;-------------------------------------------------------------------------------
;void
;gr_tao_loop0 (int seed, BOOL is_gnu)
;-------------------------------------------------------------------------------
(defun tao_loop0_main (gr 
                       nums  test
                       point 
                       p_out  
                       out_is_gnu) 
(let* (

  new_point
  
  (isplus FALSE) ;  static BOOL isplus = FALSE;
  )

  (declare (special isplus))

  (format  *error-output*  "~%")
  
  ;; -----------------------------------------------

  (graf_calc_out 1 NIL p_out nums out_is_gnu)

  (dotimes (i nums)

    ;;    if (!(i%nums_out)) graf_calc_out (2, gr, p_out, nums, is_gnu);

    (graf_calc_out  2 gr p_out nums out_is_gnu)

    (setf new_point (YRAND 0 (- (NN gr) 1))) ; ������������ � ����� ����?
                                             ; �����������, ��� ���� ���� �����?

    ;(format *error-output* "new_point = ~s ~%" new_point)

    (tao_graf_edgerecalc gr  
                         point new_point  test 'isplus) ; ������� ��� �����

    (setf point new_point)
    )

  ;; -----------------------------------------------

  (format  *error-output*  "~%")

  (graf_calc_out  3 NIL p_out nums out_is_gnu) ; ������ !!
	
  ;; -----------------------------------------------

))
;-------------------------------------------------------------------------------
(defun get_p_out_by_mode (out_mode) 

(let (

  (p_out_min (list 

    '(1 "Nodes"   TRUE  NIL) ; �������, ��� ������ ������� !?

    '(2 "Rmax"    TRUE  NIL)
    '(2 "Rmin"    TRUE  NIL)

;    '(2  "D"      TRUE  NIL)
;    '(2  "R"      TRUE  NIL)

  ))

  (p_out_add (list 

    '(3 "NumD"    TRUE  NIL)
    '(3 "NumR"    TRUE  NIL)

    '(4 "Nminus"  TRUE  NIL)
    '(4 "Nplus"   TRUE  NIL)
    '(4 "Nnull"   TRUE  NIL)

    ;//----------------------------
    ;'(2 "Sum"    NIL  NIL) ; !!! �e ������e� ������ !! �� ���e� �� �����e ���e�..
    ;'(2 "Sum"    FALSE  NIL) ; !!! �e ������e� ������ !!

    '(2 "Sum"    TRUE  NIL)
    ;'(1 "Metr"   TRUE  NIL)
  ))

  
  p_out
)


  (setf p_out (if (= out_mode 4)  
               (append p_out_min   p_out_add) ; ������� ��� ��������
                p_out_min           ; ����������� ����� ������������
                )
        )
  
  p_out ; ������ ������ �������� �������

))
;-------------------------------------------------------------------------------
(defun argus_parser1_print (nums  test seed out_is_gnu) 


  (format  *error-output*  "~%")
  (format  *error-output*  "~%")
  (format  *error-output*  "---------------argus_parser1-------------------~%")
  (format  *error-output*  "~%")
  (format  *error-output*  "nums       = ~s ~%" nums)
  (format  *error-output*  "test       = ~s ~%" test)
  (format  *error-output*  "seed       = ~s ~%" seed)
  (format  *error-output*  "out_is_gnu = ~s ~%" out_is_gnu)
  (format  *error-output*  "~%")
  (format  *error-output*  "-----------------------------------------------~%")
  (format  *error-output*  "~%")

)
;-------------------------------------------------------------------------------
(defun tao_loop0 (argus) 

(let* (

  ;isplus ; (isplus FALSE) ;  static BOOL isplus = FALSE;

  (nn   10) ; ���������� ����� � �����
  p_out point gr
  )

  ;; -----------------------------------------------

  (declare (special    nums test seed  par1 par2  out_is_gnu out_mode))

  (argus_parser1   argus 
                   'nums 'test 'seed  

                   'par1 'par2 

                   'out_mode 'out_is_gnu 
                   )

  (setf p_out (get_p_out_by_mode   out_mode)) 

  (setf point  0)

  ;; -----------------------------------------------

  (setf gr (Graf_Create nn))

  (setf *simp_random* T)  ;# ��� ������� ��������� � TCL

  (srandom_set seed)

  (Graf_Init  gr GR_RAND 0.0 0.0  GR_RAND 0.0 0.0)

  ;(Graf_Print gr)
  ;(format  *error-output*  "~%")

  ;; -----------------------------------------------

  (tao_loop0_main  gr nums   test 
                   point 
                   p_out 
                   out_is_gnu) 

  (argus_parser1_print  nums test seed out_is_gnu) 

  (format  *error-output*  "~%")
  (format  *error-output*  "p_out = ~s ~%" p_out)
  (format  *error-output*  "~%")

))
;-------------------------------------------------------------------------------
; 
; 
; 
; 
;-------------------------------------------------------------------------------
(defun tao_graf_reform  (gr_old  addnode_type delnode_type)

(let (
 
  cur_node  what_do 
  gr_new
  )

  ;; ����������� ����� ���� �� ��������
  
  (setf gr_new (Graf_Create (NN gr_old)))
  (graf_copy  gr_old gr_new)

		
  ;;  ���� ������ ���, �� ����� ��������
  (when (= (graf_get_num_nodes gr_old) 0) 
    
    (tao_bestday gr_new)
    )
  
  ;; ������� ���� �� ���� ����� ����� ~BEG~~~~~~~~~~~~~~~~~
  
  (dotimes (u (NN gr_old))
    
    (unless (eq (NODE gr_old u) NOS)
      
      (setf cur_node u)
      (setf what_do (tao_what_do  gr_new cur_node))
      
      (format  *error-output* "cur_node= ~d  what_do= ~d ~%" cur_node what_do)
      ;;(format  *error-output*  "~%")
      ;;(quit)

      (cond
       ((= what_do 1) (tao_addnode  addnode_type  gr_old gr_new  cur_node)) 
       ((= what_do 3) (tao_delnode  delnode_type         gr_new  cur_node))
       )

      ))

    ;; ������� ���� �� ���� ����� ����� ~END~~~~~~~~~~~~~~~~~
		
    ;; (graf_print gr_old)
    ;; (graf_print gr_new)
    ;; (quit)

    ;; �������� ������������ ����� � ������ 
    ;; (when (= addnode_type 2) ; ������ ��� �e������� ������

    (graf_check gr_new)

    gr_new
))
;-------------------------------------------------------------------------------
(defun loop1_main_print (nums   
                   test  addnode_type delnode_type
                   is_gnu
                   ) 


  (format  *error-output*  "~%")
  (format  *error-output*  "---------------tao_loop1_main------------------~%")
  (format  *error-output*  "~%")

  (format  *error-output*  "nums       = ~s ~%" nums)
  (format  *error-output*  "test       = ~s ~%" test)
  ;(format  *error-output*  "seed       = ~s ~%" seed)

  (format  *error-output*  "~%")

  (format  *error-output*  "par1       = ~a ~%" addnode_type)
  (format  *error-output*  "par2       = ~a ~%" delnode_type)

  (format  *error-output*  "~%")

  ;(format  *error-output*  "out_mode   = ~s ~%" out_mode)
  (format  *error-output*  "out_is_gnu = ~s ~%" is_gnu)

  (format  *error-output*  "~%")
  (format  *error-output*  "-----------------------------------------------~%")
  (format  *error-output*  "~%")


)
;-------------------------------------------------------------------------------
(defun tao_loop1_main (gr_old  nums   
                   test  addnode_type delnode_type
                   p_out 
                   is_gnu
                   ) 

(let* (
  )

  (graf_calc_out  1 NIL p_out nums is_gnu)

  ; �������� �������� �������������� -------
  
  (dotimes (i nums)

    (graf_calc_out  2 gr_old p_out nums is_gnu)	
    (setf gr_old (tao_graf_reform  gr_old  addnode_type delnode_type))		
  )

  (format t "------------------------------- ~%")

  (graf_calc_out 3 NIL p_out nums is_gnu)


  (loop1_main_print  nums  test addnode_type delnode_type is_gnu) 

))
;-------------------------------------------------------------------------------
(defun tao_loop1 (argus) 

  ;;  //int  seed = -1 /* ������������ �� ������� */;

  (format *error-output* "~%")
  (format *error-output* "tao_loop1 ............ argus = ~s ~%" argus)
  (format *error-output* "~%")

  ;; -----------------------------------------------

(let* (

  (p_out (list 

    '(1 "Nodes"     TRUE  NIL)
    '(2 "OneEdges"  TRUE  NIL) ; ���� �����e��� !
    '(2 "TwoEdges"  TRUE  NIL)
  ))

  (nn         10)

  addnode_type delnode_type 
  gr_old
  )

  ;; -----------------------------------------------

  (declare (special  nums test  par1 par2  seed is_gnu out_mode))

  (argus_parser1    argus 
                    'nums 'test 'seed  
                    'par1 'par2 
                    'out_mode 'is_gnu ) 

  (setf addnode_type   (parse-integer par1)) ; 1, 2, 3
  (setf delnode_type   (parse-integer par2)) ; 1, 2, 3
	
  (format  *error-output*  "addnode_type = ~s ~%" addnode_type)
  (format  *error-output*  "delnode_type = ~s ~%" delnode_type)
  (format  *error-output*  "~%")

  ;; -----------------------------------------------
	
  (srandom_set seed)
  
  (setf *simp_random* T)  ;# ��� ������� ��������� � TCL ??

  ;;
  ;; ���� ��� ���� �������� ��������� random (rand) ??
  ;;
  ;;(setf *read-default-float-format* 'single-float) ; �� ������ �����!!
  ;;
  ;; ��� ����� �����-�� ����� � �������� ��� ���������� RAND
  ;; ���� ������������� ��������� rand/random

	
  (setf gr_old (Graf_Create nn))

  ;(Graf_Init  gr_old GR_RAND 0.0 0.0  GR_RAND 0.0 0.0)
  ;(setf point  0)

  ;; -----------------------------------------------

  (tao_loop1_main  gr_old  nums   
                   test  addnode_type  delnode_type
                   p_out 
                   is_gnu) 

))
;===============================================================================

; TODO:
;
; 1) ������� ���������� ����������� �����, � �� �������� ??
; 
; 
;                    nums test seed  par1 par2  out_mode out_is_gnu 

;sl t~.cl META tao_loop0 500 1 1706  @ @  2 0 
;sl t~.cl META tao_loop1 200 1 1706  2 3  2 0 

;                                    addnode_type delnode_type

;===============================================================================
; 
;===============================================================================


