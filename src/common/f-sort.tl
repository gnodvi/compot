# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::F_SORT_TL] {
  return
} else {
  set  ::F_SORT_TL ""
}

#===============================================================================
#
# l~.tl SORT-TEST sort_main
# l~.tl SORT-TABS sort_main_03
#
#-------------------------------------------------------------------------------

# *  Имя этого файла: d_sort.c                                                 *
# *                                                                            *
#-------------------------------------------------------------------------------
                                                                             
# (defpackage "A_SORT" (:use "CL" "CL-USER" )
#                      (:export :sort_main :sort_k
#                               :ai_initialize :TO_RESET :LG_RESET 
#                               :ai_copy :ai_reverse
#                               :qsort_AF :ai_check_compare :TO_COUNT :LG_COUNT) 
#                      )

# (in-package :a_sort)

# ;#include "a_comm.h"
# ;#include "d_sort.h"

# ;=============================================================================

# ;#define AI int

# ;#define TO_RESET {take_count= 0;}
# (defmacro TO_RESET () (list 'setf 'take_count 0))

# ;#define TO(left, right) {(left) = (right); take_count++;}
# (defmacro TO (left right) (list 'progn (list 'setf left right) (list 'incf 'take_count)))

# ;#define TO_COUNT (take_count)
# ;(defmacro TO_COUNT () (list 'take_count))
# (defmacro TO_COUNT () 'take_count)

#-------------------------------------------------------------------------------
proc TO_RESET {} {

  set ::take_count 0
}
#-------------------------------------------------------------------------------
proc TO_COUNT {} {

  return $::take_count
}
#-------------------------------------------------------------------------------

# ;#define SWAP(i, j) (bsort_swap (array, (i), (j)))
# (defmacro SWAP (i j) (list 'bsort_swap 'array i j))

proc SWAP {i j} {

  upvar 1 array arr ;# Create link to variable in a different stack frame 

  set arr [bsort_swap $arr $i $j]

  return 
}
#-------------------------------------------------------------------------------

# ;#define LG_RESET {comp_count= 0;}
# (defmacro LG_RESET () (list 'setf 'comp_count 0))

# ;#define LG_COUNT (comp_count)
# ;(defmacro LG_COUNT () (list 'comp_count))
# (defmacro LG_COUNT () 'comp_count)

#-------------------------------------------------------------------------------
proc LG_RESET {} {

  set ::comp_count 0
}
#-------------------------------------------------------------------------------
proc LG_COUNT {} {

  return $::comp_count
}
#-------------------------------------------------------------------------------

# ;//-------------------------------------------
# ;typedef int (*T_SORTPROG) (int array[], int num); 


# ;===============================================================================
# ;-------------------------------------------------------------------------------

# (defvar take_count 0)
# (defvar comp_count 0)

set ::take_count 0
set ::comp_count 0

# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_setval (int *Array, int Num, int val)
# ;{
# ;  int i;

# ;  for (i = 0; i < Num; i++) 
# ;    Array[i] = val;
 
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_initialize (int *Array, int Num)
# ;-------------------------------------------------------------------------------
# (defun ai_initialize (Array Num)

# ;  int i;

# ;  for (i = 0; i < Num; i++) 
#   (dotimes (i Num)
#     (setf (nth i Array)  i)
#     )
 
# )
# ;-------------------------------------------------------------------------------
proc ai_initialize_new {Num} {

  set Array {}
  
  # ;  int i;  
  # ;  for (i = 0; i < Num; i++) 
  #   (dotimes (i Num)
  #     (setf (nth i Array)  i)
  #     )
  
  for {set i 0} {$i < $Num} {incr i} {
    lappend Array $i
    #puts "i = $i"
  }

  return $Array
}
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_copy (int *dest, int *src, int Num)
# ;-------------------------------------------------------------------------------
# (defun ai_copy (dest src Num)

# ;  int i;

# ;  for (i = 0; i < Num; i++) 
#   (dotimes (i Num)
# ;    dest[i] = src[i];
#     (setf (nth i dest) (nth i src))
#     )
    
# )
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_print (int *Array, int Num)
# ;-------------------------------------------------------------------------------
proc ai_print {Array} {

  # ;  for (i = 0; i < Num; i++) 
  # ;    printf ("%2d ", Array[i]); 
  # ;  printf ("\n");
  
  #   (format t "~s ~%" Array)
  puts "Array = $Array"

}
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_swap (int *Array, int i, int j)
# ;-------------------------------------------------------------------------------
# (defun ai_swap (Array i j)

# (let (
#   x
#   )

#   (setf x             (nth i array))
#   (setf (nth i array) (nth j array))
#   (setf (nth j array)  x)

# ;  int tmp = Array[i];
# ;  Array[i] = Array[j];
# ;  Array[j] = tmp;

# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_randomize (int *Array, int Num)
# ;-------------------------------------------------------------------------------
# (defun ai_randomize (Array Num)

# (let (
#   j 
#   )

#   (dotimes (i Num) 
#     (setf j (YRAND 0 (- Num 1)))

#     (ai_swap Array i j)
#     )
    
# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;ai_reverse (int *Array, int Num)
# ;-------------------------------------------------------------------------------
# (defun ai_reverse (Array Num)

# (declare (ignore Num))

# ;  int i;

# ;  for (i = 0; i < Num / 2; i++) { ;; ???
# ;    int  j = Num - i - 1;
    
# ;    int tmp  = Array[i];
# ;    Array[i] = Array[j];
# ;    Array[j] = tmp;
    
# ;  }

#   (setq Array (nreverse Array))
# )
# ;-------------------------------------------------------------------------------
# ;int
# ;ai_check_compare (int *Array, int *orig, int Num)
# ;-------------------------------------------------------------------------------
proc ai_check_compare {Arrey Orign Num} {

  #   (dotimes (i Num)
  # ;    if (Array[i] != orig[i]) 
  # ;      return (G_FAILURE); 
  #     ;(when (\= (nth i Arrey) (nth i Orign))
  
  #     (when (not (eq (nth i Arrey) (nth i Orign)))
  #       (return-from ai_check_compare NIL)
  #       )
  #     )
  
  for {set i 0} {$i < $Num} {incr i} {

    set a [lindex $Arrey $i]
    set o [lindex $Orign $i]

    #puts "i = $i   a = $a   o = $o"

    if {$a != $o} {
      return false
    }
  }

  # ;  return G_SUCCESS;
  #   t

  return true
}
# ;===============================================================================
# ;
# ;===============================================================================
# ;void 
# ;bsort_print (int array[], int num, int i, int j)
# ;{

# ;  if (BOTPRINT) {
# ;    printf ("I=%2d  J=%2d   ", i+1, j+1);
# ;    ai_print (array, num);
# ;  }

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------

# ;#define TO(left, right) {(left) = (right); take_count++;}

# proc TO {&left right} {

#   USE_REFS

#   set left $right

# }
# ;-------------------------------------------------------------------------------
# ;inline void 
# ;bsort_swap (int array[], int i, int j)
# ;-------------------------------------------------------------------------------
proc bsort_swap {array i j} {


  # (let (
  #   x
  #   )
  
  #   (TO x             (nth i array))
  #   (TO (nth i array) (nth j array))
  #   (TO (nth j array)  x)
    
  set x          [lindex $array $i] ; incr ::take_count
  lset array $i  [lindex $array $j] ; incr ::take_count
  lset array $j  $x                 ; incr ::take_count
  
  # ; (setf x (nth i array))               (incf take_count)
  # ; (setf (nth i array) (nth j array))   (incf take_count)
  # ; (setf (nth j array) x)               (incf take_count)
  
  return $array
}
#-------------------------------------------------------------------------------
proc LT_lsort {a b} {

  # возвращаемое значение определяет "желаемый" знак разности левого и правого 
  # 

  if {$a <  $b}  {return -1} ;# т.е МЕНЬШИЕ будут слева в списке 
  if {$a == $b}  {return  0} 
  if {$a >  $b}  {return  1} 

}
#-------------------------------------------------------------------------------
proc GT_lsort {a b} {

  # возвращаемое значение определяет "желаемый" знак разности левого и правого 
  # 

  if {$a <  $b}  {return  1} ;# т.е БОЛЬШИЕ будут слева в списке 
  if {$a == $b}  {return  0} 
  if {$a >  $b}  {return -1} 

}
#-------------------------------------------------------------------------------
proc  LT {left right} {

  incr ::comp_count
   
  # здесь возвращаемое значение определяет "правильность расположения"
  # 

  return [expr {($left < $right)}]
}                 
#-------------------------------------------------------------------------------
proc  GT {left right} {

  incr ::comp_count
   
  return [expr {($left > $right)}]
}                 
#-------------------------------------------------------------------------------

# ;-------------------------------------------------------------------------------
# ;int 
# ;qsort_func (const void *a, const void *b) 
# ;{ 
# ;  int x = *((int*) a);
# ;  int y = *((int*) b);
 
# ;  return (x - y); 
# ;} 
# ;/*--------------------*/ 
# ;int 
# ;qsort_unix (int array[], int num) 
# ;{ 

# ;  qsort ((void *) array, num, sizeof (int), qsort_func); 

# ;  return (0); 
# ;} 
# ;-------------------------------------------------------------------------------


# ;===============================================================================
# ;/*
# ; *  A library of sorting functions
# ; *  Written by:  Ariel Faigon,  1987
# ; */
# ;-------------------------------------------------------------------------------
# ;/*
# ; |  void  shellsort (array, len)
# ; |  KEY_T  array[];
# ; |  int    len;
# ; |
# ; |  Abstract:	Sort array[0..len-1] into increasing order.
# ; |  Method:	Shell sort (ala Kernighan & Ritchie)
# ; */
# ;-------------------------------------------------------------------------------
# ;int 
# ;shellsort_AF (int array[], int num)
# ;{
# ;  int	gap, i, j;

# ;  for (gap = num / 2; gap > 0; gap /= 2) {

# ;    for (i = gap; i < num; i++)
# ;      for (j = i-gap; j >= 0 && GT(array[j], array[j+gap]); j -= gap) {
# ;        SWAP (j, j + gap);   
# ;      }
# ;  }

# ;  return 0;
# ;}
#-------------------------------------------------------------------------------
# ;/*
# ; |  void  quicksort (array, lower, upper)
# ; |  KEY_T  array[];
# ; |  int    lower, upper;
# ; |
# ; |  Abstract:	Sort array[lower..upper] into increasing order.
# ; |  Method:	C. A. R. Hoare's Quick-sort (ala Jon Bentley)
# ; */
# ;-------------------------------------------------------------------------------
# ;void  
# ;quicksort (int array[], int lower, int upper)
#-------------------------------------------------------------------------------
proc quicksort {array lower upper  sort_proc} {

  #set sort_proc "LT"
  
  if {$lower < $upper} {
  
    SWAP  $lower [expr {(round (($upper + $lower) / 2.0))}] 
  
    set pivot [nth $lower $array]
    set m  $lower
    
    for {set i [expr {$lower + 1}]} {$i <= $upper} {incr i} {

      #if {[LT [lindex $array $i] $pivot]} {}
      if {[$sort_proc [lindex $array $i] $pivot]} {

        incr m
        SWAP $m $i        
      }
    }
    
    SWAP $lower $m   
    
    set array [quicksort  $array $lower           [expr {$m - 1}]   $sort_proc]
    set array [quicksort  $array [expr {$m + 1}]  $upper            $sort_proc]
  }
  
  return $array
}
#-------------------------------------------------------------------------------
proc qsort_AF {array {sort_proc "LT"}} {

  
  set lower 0
  set upper [expr {[llength $array] - 1}]

  set array [quicksort  $array $lower $upper  $sort_proc]
  
  return $array
}
# ;===============================================================================
# ;//   Сортировка по методу прямого включения                                  // 
# ;//   (с улучшенным свопингом - уменьшаем кол-во обменов)                     // 
# ;-------------------------------------------------------------------------------
# ;int 
# ;s_insertion_take (int array[], int num) 
# ;{ 
# ;  int  i, j; 
# ;  int  x; 
# ;  // array[0] - первый элемент полагаем уже в списке сортированных
 
# ;  for (i= 1; i< num; i++) { // на каждом проходе сдвигаем вправо границу
# ;    TO(x, array[i]); // это усовершенствование уже для свопинга

# ;    // будем искать место для этого элемента в "списке сортированных"
# ;    j = i; 
# ;    while (LT(x, array[j-1])  && (j> 0)) // до первого меньшего или до начала
# ;    { 
# ;      TO(array[j], array[j-1]); // попутно передвигаеи вправо бОльшие элементы
# ;      j--; 
# ;    } 

# ;    TO (array[j], x); // вставляем в это место
# ;   } 
 
# ;  return 0; 
# ;} 
# ;-------------------------------------------------------------------------------
# ;//   Сортировка по методу прямого включения (со свопингом)                   // 
# ;-------------------------------------------------------------------------------
# ;int 
# ;s_insertion_swap (int array[], int num) 
# ;{ 
# ;  int imin = 0;
# ;  int imax = num-1;
# ;  int  i, j; 
# ;  // array[0] - первый элемент полагаем уже в с"писке сортированных" 

# ;  for (i= imin+1; i<= imax; i++) { // на каждом проходе сдвигаем вправо границу

# ;    // будем искать место для этого элемента в "списке сортированных"
# ;    j = i; 
# ;    while (LT(array[j], array[j-1])  &&  (j> imin)) // если он меньше левого
# ;    { 
# ;      //bsort_swap (array, j-1, j); // меняем их местами сдвигая его влево 
# ;      SWAP(j-1, j); // меняем их местами сдвигая его влево 
# ;      j--; 
# ;    } 
# ;    // дальше двигать некуда (либо уже на месте либо j==imin)
# ;  } // обработали весь начальный список
 
# ;  return 0; 
# ;} 
# ;-------------------------------------------------------------------------------
# ;//   Сортировка простыми выбором (минимального элемента)                     // 
# ;-------------------------------------------------------------------------------
# ;int 
# ;s_selection (int array[], int num) 
# ;{ 
# ;  int imin = 0;
# ;  int imax = num-1;
# ;  int k; 
# ;  int x;  
# ;  int i, j;

# ;  // в "сортированном списке" пока ничего нет

# ;  for (i= imin; i<= imax-1; i++) // последний элемент - уже не список :-)
# ;  { 
# ;    // ищем во всем несортированном списке наименьший элемент
# ;    k= i;      // сначала полагаем, что это 1-й элемент списка
# ;    TO(x, array[i]); 

# ;    for (j= i+1; j <= imax; j++) 
# ;      if (LT(array[j], x)) { 
# ;        k= j; 
# ;        //x= array[k]; 
# ;        TO(x, array[k]); 
# ;      } 

# ;    // меняем местами найденный минимальный (k) и первый элемент (i)
# ;    //array[k]= array[i]; 
# ;    TO(array[k], array[i]);
# ;    TO(array[i], x);  
# ;  } 
 
# ;  return (0); 
# ;} 
# ;-------------------------------------------------------------------------------
# ;//   Шейкерная сортировка (улучшенный метод "пузырька").                     //
# ;//                                                                           //
# ;-------------------------------------------------------------------------------
# ;int 
# ;shakersort (int array[], int num) 
# ;{
# ;  int imin = 0;
# ;  int imax = num-1;
# ;  int j;
# ;  int l = imin+1;
# ;  int r = imax;
# ;  int k = imax;

# ;  do { // делаем один цикл встряски (влево-вправо или вверх-вниз)

# ;    for (j= r; j>= l; j--)     // идем справа налево, перетаскивая меньшие
# ;      if (GT(array[j-1], array[j])) {
# ;        SWAP (j-1, j);  // можно еще подтащить поближе к цели
# ;        k = j; // место (индекс) последнего обмена
# ;      }

# ;    l = k+1; // сдвигаем границу левой сортированной части 

# ;    for (j= l; j<= r; j++)    // идем слева направо, перетаскивая большие
# ;      if (GT(array[j-1], array[j])) {
# ;        SWAP (j-1, j);   
# ;        k = j;
# ;      }

# ;    r = k-1;// сдвигаем границу правой сортированной части 

# ;  }
# ;  //while (L > R); // здесь в тексте у Вирта тоже ошибка !
# ;  //while (L < R); // здесь в исходниках была ошибка (при  num=10) !
# ;  while (l <= r);  // а это правильно !

# ;  return (0);
# ;}
# ;-------------------------------------------------------------------------------
# ;//  Сортировка "пузырьковая"
# ;//  т.е. меньшие значения, подобно легким пузырькам поднимаются вверх..
# ;// 
# ;//  при каждом проходе, хотя бы одна величина добавляется к сорт. списку
# ;//  (поскольку идем с конца списка, "волоча" по ходу нужные элементы
# ;-------------------------------------------------------------------------------
# ;int 
# ;bubblesort (int array[], int num)
# ;{
# ;  int imin = 0;
# ;  int imax = num-1;
# ;  int i, j; 
# ;  int l = imin+1; // начало плохо сорт-ной части
# ;  int r = imax;

# ;  for (i= l; i<= r; i++) { 

# ;    for (j= r; j>= i; j--) {
# ;      if (LT(array[j], array[j-1])) 
# ;        SWAP (j-1, j);  // можно еще подтащить поближе к цели

# ;      bsort_print (array, num, i, j);
# ;    }
# ;  }

# ;  return (0);
# ;  // Можно улучшить алгоритм: 
# ;  // 1) если обмена не было за проход, то заканчивать; 
# ;  // 2) можно запоминать и место последнего обмена, как новую границу просмотра;
# ;  // 3) можно менять направление проходов;
# ;}

#-------------------------------------------------------------------------------
proc sort_main {} {

  set Orign {44 55 12 42 94 18  6 67}
  set Sorts { 6 12 18 42 44 55 67 94}
  
  puts ""

  ai_print $Orign     
  ai_print $Sorts  
   
  puts ""
  
  # функция признак-сортировки возвращает TRUE, если положение двух элементов
  # нас устраивает (сдева меньше или слева больше)

  set LT [qsort_AF $Orign "LT"] ;# меньшие налево
  ai_print $LT 
    
  set GT [qsort_AF $Orign "GT"] ;# большие налево
  ai_print $GT 
    
  puts ""

  # обратные функции драйвра сортировки
  
  set ret [lsort -command "LT_lsort" $Orign] 
  ai_print $ret 
    
  set ret [lsort -command "GT_lsort" $Orign] 
  ai_print $ret 
    

  puts ""
  
  return
}
#-------------------------------------------------------------------------------

#a~.tl SORT-TEST sort_main

#-------------------------------------------------------------------------------
proc sort_test {} {

  puts ""

  # (let (
  #   (my-list '(2 1 5 4 6))
  set my_list "2 1 5 4 6"
  #   )
  
  #   (print (sort my-list #'<))  ;(1 2 4 5 6)
  #   (print (sort my-list #'>))  ;(6 5 4 2 1)
  #   (print (k-sort my-list ))   ; 
  
  puts [lsort -increasing $my_list]  ;# (1 2 4 5 6) by default
  puts [lsort -decreasing $my_list]  ;# (6 5 4 2 1)
  
  #   (format t "~%")
  #   (format t "~%")
  
  puts ""

  return
}
#-------------------------------------------------------------------------------

# ;LISP provides two primitives for sorting: sort and stable-sort.

# ;The first argument to sort is a list; the second is a comparison
# ;function. The sort function does not guarantee stability: if there are
# ;two elements a and b such that (and (not (< a b)) (not (< b a))), sort
# ;may arrange them in either order. The stable-sort function is exactly
# ;like sort, except that it guarantees that two equivalent elements
# ;appear in the sorted list in the same order that they appeared in the
# ;original list.

# ;Be careful: sort is allowed to destroy its argument, so if the original
# ;sequence is important to you, make a copy with the copy-list or copy-seq
# ;function.
 
#-------------------------------------------------------------------------------

# KORUCHOVA - 
# сортировка найдeнная автоматичeски программой типа Пролог
# см. диссeртацию Юлии Коруховой (МГУ, ВМиК)

# (DEFUN k-sort(b) (COND ((LISTP b) (COND ((NULL b) b)
# (T (COND ((NULL (k-sort (CDR b))) b)
# (T (COND ((<= (CAR (k-sort (CDR b))) (CAR b)) (CONS (CAR
# (k-sort (CDR b))) (k-sort (CONS (CAR b) (CDR (k-sort (CDR
# b))))))) (T (COND ((NULL (CDR b)) b) (T (CONS (CAR b)
# (k-sort (CDR b))))))))))))))

#-------------------------------------------------------------------------------
proc k_sort  {b} {


(COND (
  (LISTP b) 
  (COND (
    (NULL b) b)
    (T (COND (
         (NULL (k-sort (CDR b))) b)
(T (COND ((<= (CAR (k-sort (CDR b))) (CAR b)) (CONS (CAR
(k-sort (CDR b))) (k-sort (CONS (CAR b) (CDR (k-sort (CDR
b))))))) (T (COND ((NULL (CDR b)) b) (T (CONS (CAR b)
(k-sort (CDR b)))))))))))
  )
)


}
#-------------------------------------------------------------------------------
proc k_sort_test {} {

  puts ""

  set my_list "2 1 5 4 6"
  
  puts [lsort -increasing $my_list] 
  puts [lsort -decreasing $my_list]
  
  puts ""

  #puts "[k_sort $my_list]"

  return
}
#-------------------------------------------------------------------------------

# f~.tl SORT-TEST k_sort_test

#-------------------------------------------------------------------------------

