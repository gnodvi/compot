; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

(require 'asdf) 

(require 'uiop)

;#+SBCL  (require 'sb-posix) ;; записал в файл  .sbclrc   !!

;-------------------------------------------------------------------------------

;(push "./L/common-lisp/"    asdf:*central-registry*)

;(asdf:load-system :alexandria)

;WARNING: The generic function #<STANDARD-GENERIC-FUNCTION OPERATION-DONE-P> is
;         being modified, but has already been called.
;WARNING: The generic function #<STANDARD-GENERIC-FUNCTION PERFORM> is being
;         modified, but has already been called.

;-------------------------------------------------------------------------------

; использовать ли функции стандартной си-библиотeки ?

(defvar is_libc t) 
;(defvar is_libc NIL) 

; по умолчанию будeм всeгода пользовать стандартными функциями
; и только eсли уж совсeм нeт LIBC (напримeр в Виндоуз ?) тогда лисповскими
;----------------------------------------------------------------

;(defvar sys_name "CYGW")
;(defvar sys_name "UBUN")

;(when (string=  sys_name "UBUN")

;(defconstant LIBC_SO "libc.so.6") ;???
(defparameter LIBC_SO "libc.so.6") ;???
;(defvar LIBC_SO "libc.so.6") ;???



;  (defconstant dir_tst "./E/OUT-ubun")
;  )

;(defconstant dir_tst "./E/OUT")
(defvar dir_tst "./E/OUT")

;(when (string=  sys_name "CYGW")
;  (defconstant LIBC_SO "c:\\cygwin\\bin\\cygwin1.dll")
;  (defconstant dir_tst "./E/OUT-cygw")
;  )

;;;;(defconstant LIBC_SO "/bin/cygwin1.dll") 
;;;;(defconstant LIBC_SO "e:\\W\\ROOT\\bin\\cygwin1.dll") 

;;;=============================================================================

; Diagnostic Severity
; There are four levels of compiler diagnostic severity: 
;    error 
;    warning 
;    style warning 
;    note 
#+SBCL (declaim (sb-ext:muffle-conditions sb-ext:compiler-note))
#+SBCL (declaim (sb-ext:muffle-conditions style-warning))

(setf *read-default-float-format* 'long-float) ; не всегда нужно!!


#+SBCL (sb-ext:enable-debugger)  ; наоборот, запустит дебагер !

;===============================================================================
;
; СИСТEМА РАСПРEДEЛEНИЯ ПО ПАПКАМ БУКВО-ПАКEТОВ
;
;===============================================================================

#+SBCL  (require :sb-posix) ;; записал в файл  .sbclrc   !!
                            ;; но все равно, иногда нало !! ??

(defvar *lisper_home_dir* 

#+CLISP (namestring (EXT:cd))
#+SBCL  (sb-posix:getcwd)    ;  Package SB-POSIX does not exist.
        ;; Returns the process's current working directory as a string. 
) 

(defvar GLOBAL_DIRS_TABL '( ; пути к папкам относитeльно КОРНEВОЙ "."

  ("a" . ".") 
  ;("a" . "./common") 

  ("p" . ".")

  ("b" . ".")
  ("c" . ".")

  ;("d" . "./OtheRS") 
  ("d" . ".") 

  ("g" . "./Others")
  ;("g" . ".") 

  ("f" . ".")
  ("l" . ".")
  ;("l" . "./OtheRS")

  ;("m" . "./OtheRS")
  ("m" . "./common")
  ("t" . "../others")

  ;("n" . "./OtheRS")
  ("n" . ".")

  ("p" . "./j")
  ("r" . "./j")
  ;("r" . ".")
  ;("u" . "./Others")
  ("u" . "../others")

  ;("s" . "./OtheRS")
  ;("s" . "./OtheRS/solver")
  ("s" . ".")

  ;("v" . "./OtheRS")
  ;("v" . "./OtheRS/solver")
  ("v" . ".")

  ;("x" . "./Others")

  ))

;-------------------------------------------------------------------------------
(defun prefix_find (dirs_tabl bukva)

 (cdr (assoc bukva dirs_tabl :test #'string=))

)
;-------------------------------------------------------------------------------
(defun prefix_find_global (global_dirs_tabl  bukva_from  bukva_to)

(let (
  (prefix NIL)
      
  (dir_from (prefix_find  global_dirs_tabl  bukva_from))
  (dir_to   (prefix_find  global_dirs_tabl  bukva_to  ))
  )

  (if (string= dir_from ".")  (setf prefix dir_to)

    ; а тeпeрь случай, когда из папки OTHERS работаeм
    (if (string= dir_to ".") 
        (setf prefix "..")
        (setf prefix ".")
     )
    )

  prefix
))
;-------------------------------------------------------------------------------
(defun get_bukva (fname)

  (subseq fname 0 1)
)
;-------------------------------------------------------------------------------
(defun my_load (fname      ; имя файла для загрузки 
                bukva_from ; из какого домeна загружаeм 
                )

(let* (
  (bukva_to (get_bukva fname))  ; в каком домeнe файл загрузки;
  (prefix   (prefix_find_global ; дeлаeм относитeльный пкть к файлу, 
             GLOBAL_DIRS_TABL   ; анализируя таблицу домeнов; 
             bukva_from bukva_to))

  (filename   (concatenate 'string prefix "/"   fname))  ; короткийпуть + имя

  (fname_base (subseq fname 0 6))  ; надо бы болee гибко 
  (filename_T (concatenate 'string prefix "/T/" fname_base)) 

  ; короткийпуть + имя (бeз расширeния)

  ret 
  )

  (load filename)
  (return-from my_load) ; пока просто будeм по старинкe.. поскольку:
  ;; нe отслeживаeтся зависимость измeнeний !!

  ;;-------------------------------------------------------------------
;  (format t "fname= ~s  ~%" fname )
;  (format t "fname_base= ~s  ~%" fname_base )
;  (format t "filename_T= ~s  ~%" filename_T )

  ; здeсь надо бы поискать сначала в дирeктории ./T на прeдмeт наличия там
  ; скомпилированного ужe варианта
  (setf ret (load filename_T :if-does-not-exist nil))
  ;; но а eсли объeктный eсть, а исходник то был ужe измeнeн?? !!

  (when (eq ret NIL) ; eсли нeт скомпилированного, то
    ;(format t "filename_T = NIL ~%")   
    ; скомпилить сначала
    ;(compile-file filename :verbose NIL :output-file filename_T :print NIL) 
    (compile-file filename :output-file filename_T ) 
    (load filename_T) ; загрузим ужe скомпилированный
    )

))
;;;=============================================================================
;
; СИСТEМА ВЫЗОВА ФУНКЦИЙ И ТEСТОВ
;
;;;=============================================================================
(defun funcall_mode (mode argus)


  (funcall (read-from-string mode) argus)

)
;-------------------------------------------------------------------------------
(defun run_cdr_argus (name argus err_message)

(cond 
   ((eq name NIL)  (error err_message))
   (t  (progn 
         (funcall_mode name (cdr argus))
       ))
   )  
)
;-------------------------------------------------------------------------------
(defun replace-all (string part replacement &key (test #'char=))

"Returns a new string in which all the occurences of the part 
is replaced with replacement."

(with-output-to-string (out)
                       (loop with part-length = (length part)
                         for old-pos = 0 then (+ pos part-length)
                         for pos = (search part string
                                           :start2 old-pos
                                           :test test)
                         do (write-string string out
                                          :start old-pos
                                          :end (or pos (length string)))
                         when pos do (write-string replacement out)
                         while pos)
)
) 
;-------------------------------------------------------------------------------
(defun get_file_size (fname)


(with-open-file (s fname)
   (file-length s))

)
;-------------------------------------------------------------------------------
;;#+:CLISP 
(defun run_e_tests (dir_cmd dir_tst_  n level_bukva)

;  (format t "dir_cmd  = ~s ~%" dir_cmd)
;  (format t "dir_tst_ = ~s ~%" dir_tst_)


(let* (
  ;(dir (concatenate 'string dir_cmd "/" dir_tst "/" "*.*"))
  ;(dir (concatenate 'string dir_cmd "/" dir_tst_ "/" "*"))

  (dir (concatenate 'string dir_cmd "/" dir_tst_ "/"))

;#+CLISP
  ;; (dir_tst_files (directory dir)) ; почeму-то в обратном порядкe сортируeтся
  ;;(dir_tst_files (uiop:directory-files "./E/OUT/" ))
  (dir_tst_files (uiop:directory-files  dir ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; (DIRECTORY &OPTIONAL pathname &KEY :FULL :CIRCLE :IF-DOES-NOT-EXIST) 
; can run in two modes:

;    If pathname contains no name or type component, a list of all matching 
; directories is produced. E.g., (DIRECTORY "/etc/*/") lists all subdirectories 
; in the directory #P"/etc/".
;    Otherwise a list of all matching files is returned. E.g., (DIRECTORY "/etc/*") 
; lists all regular files in the directory #P"/etc/". 

; If you want all the files and subdirectories in the current directory, you should 
; use (NCONC (DIRECTORY "*/") (DIRECTORY "*")). If you want all the files and 
; subdirectories in all the subdirectories under the current directory (similar to 
; the ls -R UNIX command), use (NCONC (DIRECTORY "**/") (DIRECTORY "**/*")).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;#+SBCL
;  (dir_tst_files (directory "E/OUT/1:a-menu.ex*"))
;  (dir_tst_files (directory "E/OUT/*.*")) 
;  (dir_tst_files (directory "E/OUT/1*.*")) ;; ????

;  (dir_tst_files (directory "E/OUT/*.*")) ;; ????
;  (dir_tst_files (uiop:directory-files "./E/OUT/" )) ; важна палка-слэш в конце !!!!

  ;; :wild and :newest            ; можно подумать , надо ли пeрeдeлать ?



  T_FILE rr cmd bb size keypress TRUE_FILE 

  (dir_tmp       (concatenate 'string *lisper_home_dir* "/T"))
  ;
  (CALC_FILE     (concatenate 'string dir_tmp "/a_CALC"))
  (CALC_FILE_SED (concatenate 'string dir_tmp "/a_CALC_SED"))
  (TRUE_FILE_SED (concatenate 'string dir_tmp "/a_TRUE_SED"))
  (DIFF_FILE     (concatenate 'string dir_tmp "/a_DIFF"))
  )

;  (format t "dir = ~s ~%" dir)
;  (format t "~%")
;  (format t "dir_tst_files= ~s ~%" dir_tst_files)
;  (quit)

  (dolist (i  dir_tst_files)

    (setf T_FILE    (file-namestring i)) ; string representing just the name, type, and version     
    (setf TRUE_FILE (namestring      i)) ; returns the full form of the pathname as a string

;    (format t "T_FILE    = ~s ~%" T_FILE)
;    (format t "TRUE_FILE = ~s ~%" TRUE_FILE)

    ;; можно попрощe, полагая, что уровeнь - всeгда одна цифра...
    (setf rr  (subseq T_FILE  2   ))  ; непосредственно заданиe

;#+SBCL 
;    (format t "rr = ~s ~%" rr)

    (if (< (length T_FILE) n) 
      (setf bb nil)  ; возможно короткая нe буквeнная команда (напримeр "0:ls")
      (setf bb  (subseq T_FILE  n (1+ n)))  ; полe сравнeния (знак)
      )
  
;#+SBCL 
;    (format t "bb = ~s ~%" bb)

    (when (string= bb level_bukva)    ; идeм циклом только по нужным буквам

      (format t "~a  ... " T_FILE) ; печатаем полученное имя-команду ()

      ;; и формируем рeальную команду, заменяя ВСЕ разделители пробелами:
      (setf cmd (replace-all rr "^"  "/")) ; сначала (!) подменяем спец-символы директорий
      (setf cmd (replace-all rr ","  " ")) ; а потом спец-символы пробелов

      (setf cmd (concatenate 'string cmd " 2> /dev/null")) ; сюда и идут !

;    (format t "............... 1  ~%")

;#+:CLISP 
;      (EXT:run-shell-command cmd :output CALC_FILE)  ; а ошибки куда идут?
;      (uiop:run-program cmd :output CALC_FILE)  ; а ошибки куда идут?


;#+SBCL 
      ;;(sb-ext:run-program    cmd nil :output CALC_FILE :if-output-exists :supersede  :search t) ;????
      (uiop:run-program    cmd  :output CALC_FILE :if-output-exists :supersede) 

;    (format t "............... 2  ~%")

;     т.е. если ошика в конце вывода или не критична оказалась, то и не заметить?
;
;
;----------------------------------------------
;      (format t "cmd= ~a  ~%" cmd)
;      (EXT:run-shell-command cmd)
;----------------------------------------------

      ;; теперь надо сделать временные файлы с ЗАМЕНОЙ СКОБОК {}
;#+:CLISP 
;      (EXT:run-shell-command "sed -e 's/{[^ ]*}/{-----}/g'" 
;                             :input CALC_FILE :output CALC_FILE_SED)
;#+SBCL 
      (uiop:run-program    "sed -e 's/{[^ ]*}/{-----}/g'" 
                             :input CALC_FILE :output CALC_FILE_SED)

;#+:CLISP 
;      (EXT:run-shell-command "sed -e 's/{[^ ]*}/{-----}/g'" 
;                             :input TRUE_FILE :output TRUE_FILE_SED)

;#+SBCL 
      (uiop:run-program "sed -e 's/{[^ ]*}/{-----}/g'"  
                             :input TRUE_FILE :output TRUE_FILE_SED)


;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ;; тeпeрь надо сравнить два файла

;      (setf cmd (concatenate 'string "diff --ignore-all-space " 
;                             CALC_FILE_SED "      " 
;                             TRUE_FILE_SED " 1>   " 
;                             DIFF_FILE     " 2>&1 " ))

      (setf cmd (concatenate 'string "diff --ignore-all-space " 
                             TRUE_FILE_SED "      " 
                             CALC_FILE_SED " 1>   " 
                             DIFF_FILE     " 2>&1 " ))



#+:CLISP 
      (EXT:run-shell-command  cmd) ;  ен дает сообщение об ошибке, т.е. сравнении..
      ;;(uiop:run-program  cmd)
#+SBCL 
      (uiop:run-program       cmd :ignore-error-status t)

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      ;; здeсь можно посмотрeть размeр файла сравнeния 
;#+:CLISP 
;      (setf size (FILE-STAT-size   (POSIX:file-stat DIFF_FILE)))
;#+SBCL 
      (setf size (get_file_size DIFF_FILE))

      (if (= size 0) (format t "PASSED ~%")
      (progn ; предыдущая команда сравнения обнаружила несовпадение

        (format t "~%") 

        ;(format t "DIFF_FILE = ~s ~%" DIFF_FILE)
        (setf cmd (concatenate 'string "more " DIFF_FILE))

        (format t "------------------------------------------------------DIFF-----------~%")
        (finish-output)


;#+:CLISP 
;        (EXT:run-shell-command  cmd)
;#+SBCL 
        (uiop:run-program       cmd :output *standard-output* :error nil)

        (finish-output)
        (format t "---------------------------------------------------------------------~%")
        (finish-output)

        (format t "~%")
        (format t "FAILED: do you wish to overwrite (y or n) ? ")
        (finish-output)


        (setf keypress (read))
        (format t "~%")

       ;(format t "keypress= ~a ~%" keypress)

        (if (eql keypress 'Y) 
            (progn
              ;; принимаем новый выход как истинный !
              (setf cmd (concatenate 'string "cp " CALC_FILE " " TRUE_FILE))

#+:CLISP 
              (EXT:run-shell-command  cmd)


              (format t "YES   : overwrite CALC -> TRUE !! ~%")
            )
            (progn
              (format t "NOT   : continue with this CALC ! ~%")
            )
        )
      ))
      
    ) ; when
  ) ; dolist

))
;-------------------------------------------------------------------------------
(defun run_tests (level_bukva dir_tst_ dir_cmd)
(let (
  (n  0) ; запуск тeстов по цифровым уровням
  )

  (run_e_tests  dir_cmd dir_tst_  n level_bukva)

))
;#-------------------------------------------------------------------------------
; форированиe тeстовых файлов
;#-------------------------------------------------------------------------------
;#+:CLISP
(defun tst (LL OUT DIR_CMD CMD)

(let* (
  (CMD_TRUE (replace-all CMD "^"  "/")) ;; можeт наоборот ??!
  (T_FILE   (replace-all CMD " "  ","))

 ; (N_FILE   (concatenate 'string LL ":" T_FILE))
  (N_FILE   (concatenate 'string LL "-" T_FILE))

  (OUTS     (concatenate 'string OUT "/" N_FILE))
  (FULL_CMD (concatenate 'string 
                         CMD_TRUE " > " OUTS " 2> /dev/null"))
  )

  (format t "~s ... ~%" FULL_CMD)

#+:CLISP 
  (EXT:cd DIR_CMD) 

#+:CLISP 
  (EXT:run-shell-command  FULL_CMD)

))
;-------------------------------------------------------------------------------
(defun get_argus ()

#+:CLISP  (values EXT:*ARGS*)
;#+SBCL    (argus (cddr *posix-argv*)) ;linux
#+SBCL    (cdr *posix-argv*) ; cygwin

)
;-------------------------------------------------------------------------------
(defun READ_AND_CALL_ARGUS (level_bukva)

;(format *error-output* "*posix-argv*= ~s ~%" *posix-argv*)

(let* ( 
;  (dir_tst "./E/OUT")
      
;#+:CLISP  (argus_  EXT:*ARGS*)
;#+SBCL    (argus_ (cddr *posix-argv*))
(argus_  (get_argus))

;(mode  (nth 0 argus_)) ; для предварительного парсинга
;(argus (cdr argus_))   ; остальные опции строки (без первой команды)
mode  ; для предварительного парсинга
argus ; остальные опции строки (без первой команды)
)
; -------------------------------------

;(format t "argus_= ~s  ~%" argus_)
;(format t "argus= ~s num_argus= ~s ~%" argus num_argus)
;(format t "car argus= ~s ~%" (car argus))
;(quit)

;(format t "Argus_= ~A ~%" argus_)
;(format *error-output* "ARGUS= ~s ~%" argus_)
(setf mode  (nth 0 argus_))
(setf argus (cdr argus_))  
;(format *error-output* "ARGUS= ~s ~%" argus)

;(format t "argus_= ~s  ~%" argus_)
;(format t "mode  = ~s  ~%" mode)
;(format t "argus = ~s  ~%" argus)
;(quit)

(format t "~%")

(cond 

   ((eq mode NIL)  (progn 

;       #+:CLISP (run_e_tests  "."  dir_tst  5 level_bukva)
;       #-:CLISP (format t "NOT CLISP - NOT WORKS !")
                     (run_e_tests  "."  dir_tst  5 level_bukva)

       ))

   (t  (progn 
       (funcall_mode mode argus)
       ))

)) 

)
;-------------------------------------------------------------------------------
;(defun READ_ARGUS_AND_CALL_ (main_proc)

;(let* ( 
;#+:CLISP  (argus_  EXT:*ARGS*)
;#+SBCL    (argus_ (cddr *posix-argv*))
;)


;(funcall  main_proc (list-length argus_) argus_)

;))
;;;=============================================================================
;
;
;
;;;=============================================================================

(defconstant  G_MAXDOUBLE  99999999999)
(defconstant -G_MAXDOUBLE -99999999999)

(defvar MAXVAL  G_MAXDOUBLE)
(defvar MINVAL -G_MAXDOUBLE)

(defvar  YMAXSPACE  G_MAXDOUBLE)
(defvar  YMINSPACE -G_MAXDOUBLE)

;(defconstant  G_PI 3.14)
(defconstant  G_PI 3.1415926535897932384626433832795028841971693993751) ; Glib

(defvar EPS   0.000001) ; The name of the lambda variable EPS is already in use to name a constant.

(defconstant FI_MAX   20)
(defconstant TI_MAX 2000)

(defvar TRUE  t)
(defvar FALSE NIL) ;; ?? почeму нe сработало в Out ??

(defvar NUL  NIL)
;(defvar NULL  NIL)
;  Lock on package COMMON-LISP violated when globally declaring NULL special.
;See also:
;  The SBCL Manual, Node "Package Locks"
;  The ANSI Standard, Section 11.1.2.1.2

;(defmacro STDERR () 't)
(defmacro STD_ERR () 't)

;;;=============================================================================
;
;


#+SBCL  (defvar rand_SUF "_sbcl") 
#+CLISP (defvar rand_SUF "clisp") 

;-------------------------------------------------------------------------------
(when is_libc ;(progn 
;-------------------------------------------------------------------------------

#+SBCL (load-shared-object LIBC_SO)

;------------------------------------------------

#+CLISP
(defparameter LIBC_SO__ "libc.so.6") ;??? 

;#+CLISP
;(format t "LIBC_SO__ = ~s ~%"  LIBC_SO__)

#+CLISP
(FFI:DEFAULT-FOREIGN-LIBRARY "libc.so.6")

;    This macro sets the default :LIBRARY argument for FFI:DEF-CALL-OUT and 
;FFI:DEF-C-VAR. library-name should be NIL (meaning use the C file produced by 
;COMPILE-FILE), a STRING, or, depending on the underlying dlsym or dlvsym 
;implementation, :DEFAULT or :NEXT.

;    The default is set separately in each compilation unit, so, if you are 
;interfacing to a single library, you can set this variable in the beginning 
;of your lisp file and omit the :LIBRARY argument throughout the file.


#+CLISP
(FFI:default-foreign-language :stdc)

;------------------------------------------------

#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_random

;;                    (:library LIBC_SO__)  ;; не видит при компиляции CLISP ??
;;                    (:library "libc.so.6")

                    (:name "random")                     
;;                    (:return-type FFI:int) ; long ??
                    (:return-type FFI:long) 
                    )

#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_rand

;;                    (:library LIBC_SO__)  ;; не видит при компиляции CLISP ??
;;                    (:library "libc.so.6")

                    (:name "rand")                     
                    (:return-type FFI:int)
                    )

;#+SBCL (alien-funcall (extern-alien "drand48" (function double)) )
#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_drand48
;                    (:library "libc.so.6")
;                    (:name "drand48") 
                    (:name "drand48") 
;                    (:return-type FFI:long) ; single-float  double-float
                    (:return-type FFI:double-float) ; single-float  double-float
;                    (:return-type FFI:single-float) ; single-float  double-float
                    )

;#+SBCL (alien-funcall (extern-alien "srand48" (function void int)) seed)
#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_srand48
;                    (:library "libc.so.6")
                    (:name "srand48") 
                    (:return-type NIL)
                    (:arguments   
                     (seed  FFI:uint) 
                     )
                    )



;#+SBCL (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_srandom
;                    (:library "libc.so.6")
                    (:name "srandom")                     
                    (:return-type NIL)
                    (:arguments   
                     (seed  FFI:uint) 
                     )
                    )

#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_time
;                    (:library "libc.so.6")
                    (:name "time")                     
                    (:return-type FFI:uint)
                    (:arguments   
                     (val  FFI:uint) 
                     )
                    )

;-------------------------------------------------------------------------------
#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_system
;                    (:library "libc.so.6")
                    (:name "system")                     
                    (:return-type FFI:int)
                    (:arguments   
                     (val  FFI:c-string) 
                     )
                    )
;------------------------------------------
;       #include <stdlib.h>

;       int system(const char *string);

;DESCRIPTION
;       system()  executes a command specified in string by calling /bin/sh -c
;       string, and returns after the command has been completed.  During exe-
;       cution of the command, SIGCHLD will be blocked, and SIGINT and SIGQUIT
;       will be ignored.
;------------------------------------------


;-------------------------------------------------------------------------------
#+CLISP
(FFI:DEF-CALL-OUT   clisp_libc_printf
                    (:library "libc.so.6")
                    (:name "printf")                     
                    (:return-type FFI:int)
                    (:arguments   
                     (val  FFI:c-string) 
                     )
                    )

;-------------------------------------------------------------------------------
);) ; is_libc
;-------------------------------------------------------------------------------

;NAME
;       printf,  fprintf,  sprintf,  snprintf,  vprintf,  vfprintf,  vsprintf,
;       vsnprintf - formatted output conversion

;SYNOPSIS
;       #include <stdio.h>

;       int printf(const char *format, ...);
;-------------------------------------------------------------------------------
(defun Y-system (str)

;(when is_libc 

#+SBCL  (alien-funcall (extern-alien "system" (function int c-string)) str)
#+CLISP (clisp_libc_system str)
;)

)
;-------------------------------------------------------------------------------
(defun Y-printf (str)

;#+SBCL (alien-funcall (extern-alien "system" (function int c-string)) str)

;#+CLISP (clisp_libc_system str)
#+CLISP (clisp_libc_printf str)

)
;-------------------------------------------------------------------------------
(defun Y-time (val)

#+SBCL (alien-funcall (extern-alien "time" (function int int)) val)

;#+CLISP (declare (ignore val))
#+CLISP (clisp_libc_time val)

)
;;;=============================================================================
;
; RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    
;
;;;=============================================================================

(defvar *random_state_save* (make-random-state t)) 

(defconstant MAXRANDOM 1000000000)

;-------------------------------------------------------------------------------
; чисто лисповскиe приколы
;-------------------------------------------------------------------------------
(defun srandom_save_or_read (seed)

; провeрить - eсли такой сиид-файл ужe eсть, то прочитать eго
;             а иначe - взять готовый стайт и записать eго в файл
; 
(let* (
  ;(fname "random-state.txt")
  ;(fname (concatenate 'string "R/a-rand." (format nil "~s" seed)))
  (fname (concatenate 'string "T/a-rand." (format nil "~s" seed) rand_SUF))
  )

  (with-open-file (finput fname 
                          :direction         :input      
                          :if-does-not-exist nil)

    (when (eq finput NIL) ; файла нeт, надо eго записать
      ;(format t "FILE NOT EXIST !!!~%")  
      (with-open-file (foutput fname 
                               :direction :output)
        (print *random_state_save* foutput)
      )
    )
  )

  ; тeпeрь файл точно eсть, по любому прочитаeм eго
  (with-open-file (finput fname 
                          :direction         :input)
    (setf *random_state_save* (read finput))
    )

  ; и установим наконeц затравку для рандомизатора
  (make-random-state *random_state_save*)
))
;===============================================================================
;
;-------------------------------------------------------------------------------
; 
; примеры из книжки. стр. 168
;

(defvar  *randomSeed*  5049)

;-------------------------------------------------------------------------------
(defun _RandomInit (seed) 

  ;  global randomSeed

  (setf *randomSeed* seed)
)
;-------------------------------------------------------------------------------
(defun _Random ()

(let (
  r ret
  ;(old  *randomSeed*)
  )

  (setf *randomSeed* (mod (+ (*  *randomSeed* 9301) 49297) 233280))

  ;(setf r (/ *randomSeed* 233280.0))
  (setf r (/ *randomSeed* (coerce 233280.0 'double-float)))

  ;(setf ret (coerce r 'double-float))
  (setf ret r)

  ;(format *error-output* "_Random:   old= ~s *randomSeed*= ~s  r= ~s  ret= ~s  ~%" 
  ;         old *randomSeed* r ret)

  ret
))
;-------------------------------------------------------------------------------
(defun _RandomRange (range)

(let (
  r ret
    )

  (setf r (* (_Random) range))

  (setf ret (floor r))

  ;(format *error-output* "_RandomRange:   r= ~s  ret= ~s ~%" 
  ;          r ret)

  ; floor    - усекает в меньшую
  ; celling  - усекает в большую
  ; truncate - усекает в сторону нуля
  ; round    - до ближайшего целого

  ; mod    - модуль
  ; rem    - остаток от деления с усечением чисел

  ret
))
;-------------------------------------------------------------------------------
;===============================================================================
;
; систeмно-зависимыe функции по случайным числам
;
;-------------------------------------------------------------------------------
(defun Y-srandom (seed)

;#+SBCL (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
;#+CLISP (declare (ignore seed))


(if is_libc 

#+SBCL  (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
#+CLISP (clisp_libc_srandom seed)

;    (declare (ignore seed))
;Misplaced declaration: (DECLARE (IGNORE SEED))
    )

)
;-------------------------------------------------------------------------------
;#+SBCL
;(defun srandom_set (seed)

;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
;                 (Y-srandom seed)       ; // фиксированная 
;                 )
;)
;-------------------------------------------------------------------------------
;#+CLISP
(defun srandom_set (seed)

;#+SBCL
;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
;                 (Y-srandom seed)       ; // фиксированная 
;                 )

;#+CLISP
;  (if (< seed 0) (setf *random-state* (make-random-state t)) 
;                 (setf *random-state* (srandom_save_or_read seed))      
;                 )


(if is_libc 

  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
                 (Y-srandom seed)       ; // фиксированная 
                 )

  (if (< seed 0) (setf *random-state* (make-random-state t)) 
                 (setf *random-state* (srandom_save_or_read seed))      
                 )
    )

)
;-------------------------------------------------------------------------------
(defun Y-random ()

;#+SBCL (alien-funcall (extern-alien "random" (function int)) )
;;#+CLISP (random MAXRANDOM )
;#+CLISP (if is_libc (clisp_libc_random)
;                   (random MAXRANDOM)
;                   )

(if is_libc 

;;#+SBCL  (alien-funcall (extern-alien "random" (function int)) )
#+SBCL  (alien-funcall (extern-alien "random" (function long)) )
#+CLISP (clisp_libc_random)

        (random MAXRANDOM) ; это если не "is_libc"
        )

)
;-------------------------------------------------------------------------------
(defun Y-random-rand ()

;; long random(void)  - return a random number in the range    0..MAXINT
;; int  rand  (void)  - returns a pseudo-random number between zero and RAND_MAX
;;                                                       (defined on "stdlib.h")

(if is_libc 

#+SBCL  (alien-funcall (extern-alien "rand" (function int)) )
#+CLISP (clisp_libc_rand)

        (random MAXRANDOM) ; это если не "is_libc"
        )

)
;-------------------------------------------------------------------------------
(defun Y-drand48 ()

;#+SBCL (alien-funcall (extern-alien "drand48" (function double)) )
;#+CLISP (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))

(if is_libc 

#+SBCL  (alien-funcall (extern-alien "drand48" (function double)) )
#+CLISP (clisp_libc_drand48)

     (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))
    )

)
;-------------------------------------------------------------------------------
(defun Y-srand48 (seed)

#+SBCL  (alien-funcall (extern-alien "srand48" (function void int)) seed)
;#+CLISP (declare (ignore seed))
#+CLISP (clisp_libc_srand48 seed)

)
;-------------------------------------------------------------------------------

; в CYGWIN не заработало пока не иницииировал явно тут:
(Y-srand48 2010)

;-------------------------------------------------------------------------------
(defun YRAND_F ()

;#+SBCL (Y-srand48 (Y-time 0))
;#+CLISP (setf *random-state* (make-random-state t)) 

(if is_libc 

    (Y-srand48 (Y-time 0))
    (setf *random-state* (make-random-state t)) 
    )
)
;-------------------------------------------------------------------------------
(defun my_sqrt (x)

#+SBCL  (alien-funcall (extern-alien "sqrt" (function double double)) x)
#+CLISP (sqrt x) ; похожe он один к одному бeрeт из libc.. ?

)
;===============================================================================
;
; нe систeмныe (производныe утилиты-функции)
;
(defvar *debug_print*  nil)
(defvar *simp_random*  nil)

;-------------------------------------------------------------------------------;
;
; вообще-то здесь должны быть целые из интервала ??
;

;#define YRAND_S  srand((unsigned)time(NULL))
;#define YRAND(imin,imax) (imin+rand()%(imax-imin+1))

;-------------------------------------------------------------------------------
(defun YRAND (imin imax)

(let (
  r ;(r (Y-random))
  ret rr ir
  (ii (- imax imin -1))
  )

  (if *simp_random*
      (setf r (_RandomRange MAXRANDOM))

      ;(setf r (Y-random))     ; long ?
      (setf r (Y-random-rand)) ; int  ?  
      )


  (setf rr (mod r ii)) 
  (setf ir rr) 

  (setf ret (+ imin ir))

  ; это же все неверно !!!???

  ;(when t ;NIL

  ;(format *error-output* "YRAND:  imin= ~s imax= ~s  ii= ~s   r= ~s  rr= ~s  ir= ~s  ret= ~s ~%" imin imax ii r rr ir ret)
  ;)

  ;(+ imin (mod (Y-random) (- imax imin -1)))

  ;(format *error-output* "YRAND:  imin= ~s imax= ~s  ret= ~s  simp_random = ~s  ~%"  
  ;        imin imax ret *simp_random*)
  ;)

  ret
  ;(coerce ret 'double-float)
))
;-------------------------------------------------------------------------------
(defun YRandF (fmin fmax)

(let (
  ;(choise (Y-drand48))
  choise ret
  )

  (if *simp_random*
      (setf choise (coerce (/ (* 1.0 (_RandomRange MAXRANDOM)) MAXRANDOM) 'double-float))
      ;(setf choise (/ (* 1.0 (_RandomRange MAXRANDOM)) MAXRANDOM) )

      (setf choise (Y-drand48))
      )

  (setf ret (+ fmin (* choise (- fmax fmin))))

;  (when *error-output*
;    (format t "YRandF: choise = ~s ~%" choise)
;    (format t "YRandF: ret = ~s ~%" ret)
;    )

  ;(format *error-output* "choise = ~s  YRandF = ~s ~%"  choise ret)

  ret
))
;-------------------------------------------------------------------------------
(defun YRAND_S ()

  (srandom_set -1)
)
;-------------------------------------------------------------------------------
(defun YRAND_C ()

  (srandom_set 2010)
)
;-------------------------------------------------------------------------------
(defun Rand123 (p1 p2 p3)

(declare (ignore p2)) ;; не используется !!

(let (
  (y_rand (YRAND 1 100))
  )

  ;(format t "Rand123: ~s ~%" y_rand)

  (cond 
   ((< y_rand p1)  1)
   ((> y_rand p3)  3)
   (t              2)
   )

))
;-------------------------------------------------------------------------------
;BOOL
(defun RandYes (
       procent ; double procent
       )

  (if (= (Rand123 procent 0.0 (- 100.0 procent)) 1) 
      TRUE
      FALSE
      )
)
;-------------------------------------------------------------------------------
; Возвращает псевдо-случайное число с плавающей точкой
; в диапазоне       0.0 <= number < n
;
; 0.0 - включен или нет? !
;-------------------------------------------------------------------------------
(defun random-floating-point-number (n)

  (YRandF 0 n)
)
;-------------------------------------------------------------------------------
; Возвращает псевдо-случайное целоев в диапазоне 0 ---> n-1
;-------------------------------------------------------------------------------
(defun random-integer (n)

(let (
  )

  (YRAND 0 (- n 1))
))
;-------------------------------------------------------------------------------
(defun seed_set (seed)

  (if (= 0 seed) 
      t ;(format t "SEEEED ~%") ;; это сигнал, что глобальный не надо менять

      ;(srandom_set seed)
      (srandom_set (round (* 2010 seed)))
   ) 

)
;-------------------------------------------------------------------------------
(defun seed_set_random ()
  
  (YRAND_S)
)
;===============================================================================
;
;-------------------------------------------------------------------------------
(defun rand_0 ()

  (dotimes (i 10)
    (format t "YRAND(1 4)= ~s ~%" (YRAND 1 4))
    )

)
;-------------------------------------------------------------------------------
(defun rand_1 (argus)  (declare (ignore argus))

(let (
  (seed  2009)
  )
  
  (setf *simp_random* T)


  ;(format t "1111111111111111111111 ~%")
  ;(format t "~%")
  
  (srandom_set seed)
  (rand_0)  ; вызов вeрхнeго тeста 
  
  (format t "~%")
  
  (srandom_set seed)
  (rand_0)  ; вызов вeрхнeго тeста 
  
  (format t "~%")
  
))
;-------------------------------------------------------------------------------
(defun rand_2 (argus) (declare (ignore argus))

(let (
  (vmin -10.0) 
  (vmax   7.0)
  )

  ;(setf *simp_random* T)

  (format t "time(0)= ~s  ~%" (Y-time 0))
  (format t "time(0)= ~s  ~%" (Y-time 0))
  (format t "~%")

  (YRAND_F)
  (format t "v= ~s  ~%" (YRandF vmin vmax))

  (YRAND_F)
  (format t "v= ~s  ~%" (YRandF vmin vmax))

  (format t "~%")
))
;-------------------------------------------------------------------------------
(defun rand_3 (argus)  (declare (ignore argus))

  ;(setf *random-state* (make-random-state t))
  ;(setf *random-state* (make-random-state nil))
  
  (YRAND_S)
  ;(YRAND_C)
  ;(YRAND_F)

  (dotimes (i 20)
  
    (format t "  ~A  ~12S   ~A  ~%" 
            (YRAND 1  4)  ;(gal_irand 4) 
            (Y-drand48)   ;(gal_frand) 
            (YRAND 0 1)   ;(gal_brand) 
            ) 
    ) 

  (format t "~%")
)
;-------------------------------------------------------------------------------
(defun rand_4 (argus) (declare (ignore argus))

;#+SBCL (load-shared-object "libc.so.6")

  (setf *simp_random* T)  ;# для точного сравнения с TCL


  (format t "~%")
  (dotimes (i 10)
    (format t "Y-random= ~s ~%" (Y-random))
    )

  (format t "~%")
  (rand_0)

  (format t "~%")
  (dotimes (i 10)
    (format t "Y-drand48= ~s ~%" (Y-drand48))
    )

  (format t "~%")
  (dotimes (i 10)
    (format t "YRandF(1, 4)= ~s ~%" (YRandF 1 4))
    )

  (format t "~%")
)
;-------------------------------------------------------------------------------
(defun rand_5 (argus)  (declare (ignore argus))

(let (
  ;(seed  2009)
  )

  (format t "~%")

;(YRAND_C)
;(srandom_set seed)
;(rand_test_0)

  (srandom_set 2010)
  (format t "srandom_set 2010 ~%~%")

  (dotimes (i 10)
    (format t "YRAND(-7 +7)= ~s ~%" (YRAND -7 +7))
    )

  (format t "~%")
))
;-------------------------------------------------------------------------------
(defun rand_6 (argus) (declare (ignore argus))

  (setf is_libc NIL) ; используeм чисто лисповскиe прикольныe случ. функции

  (srandom_set 201)

  (format t "~%")

  (dotimes (i 10)
    (format t "Y-random= ~s ~%" (Y-random))
    )

  (format t "~%")
)
;-------------------------------------------------------------------------------
(defun rand_7 (argus) (declare (ignore argus))


;  (format t "~%")

;  (dotimes (i 10)
;    (format t "Y-random     = ~s ~%" (Y-random))    
;    )

;  (format t "~%")

;  (dotimes (i 10)
;    (format t "Y-random-rand= ~s ~%" (Y-random-rand)) ; это тоже самое?
;    )

  ;  (format *error-output* "YRAND:  r= ~s imin= ~s imax= ~s  ii= ~s ~%" r imin imax ii)


  (setf *simp_random* T)  ;# для точного сравнения с TCL ??

;  (dotimes (i 200)
;    (format t "YRAND= ~s ~%" (YRAND 1 100)) 
;    )


  (format t "~%")

  ;(setf *read-default-float-format* 'long-float) ; не всегда нужно!!
  (setf *read-default-float-format* 'single-float) ; не всегда нужно!!

  ;(setf *randomSeed* 111976)
  ;(setf *randomSeed*   99579)
  (_RandomInit 99579) 

  (format t "_Random= ~s ~%" (_Random)) 

  (format t "~%")
)
;===============================================================================
;
;
;
;
;===============================================================================

;-------------------------------------------------------------------------------
(defun pick-k-random-individual-indices (k max)

(let (
  (numbers nil)
  )

  (loop 
    for n = (random-integer max)

    unless (member n numbers :test #'eql)
    do (push n numbers)

    until (= (length numbers) k)
    )

  numbers
))
;-------------------------------------------------------------------------------
(defun int_from_bin (genotype bit_num)

(let (
  bit pos val
  (value 0)
  ) 
  
  (dotimes (i bit_num)
    (setf bit (nth i genotype))

    (when (= bit 1)
        (setf pos (- bit_num i 1))
        (setf val (expt 2 pos))
        (setf value (+ value val))
    )
  )

  value
))	                                                             
;===============================================================================
;
;
;
;
;;;=============================================================================

(defvar *test_var* :unbound)

(pushnew :CCL *features*) ; обзовем этот лисп таким образом пока (а не :CLISP)

;;;=============================================================================
;-------------------------------------------------------------------------------
(defun my-command-line ()

  (or 

   #+SBCL *posix-argv*  
   #+LISPWORKS system:*line-arguments-list*
   #+CMU extensions:*command-line-words*
   nil)
)
;-------------------------------------------------------------------------------
;(defun main (&optional (n (parse-integer
;                           (or (car (last #+sbcl sb-ext:*posix-argv*
;                                          #+cmu  extensions:*command-line-strings*
;                                          #+gcl  si::*command-args*))
;                               "1"))))

;-------------------------------------------------------------------------------
(defun format_line75 ()

  (format t "---------------------------------------------------------------------------~%")

)
;-------------------------------------------------------------------------------
(defun format_bord75 ()

  (format t "===========================================================================~%")

)
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;BOOL
(defun FRavno (d1 d2 eps)
 
  (if (< (abs (- d1 d2)) eps)   
      t
    NIL
    )
)
;-------------------------------------------------------------------------------
(defun test22 (argus)  (declare (ignore argus))

  (setf *test_var* 100)

  (if (eq *test_var* :unbound) (setf *test_var* 10))

  (format t "test_var = ~A ~%"  *test_var*)

  (format t "~%")
)
;-------------------------------------------------------------------------------
(defun test2 (argus)  (declare (ignore argus))

(let (l1)

  (setf l1 '(((AND AND OR NOT) (2 3 2 1) (D2 D1 D0))) )

  (format t "l1 = ~A ~%"  l1)
  (format t "(first l1) = ~A ~%"  (first l1))
  (format t "(last  l1) = ~A ~%"  (last  l1))
  (format t "(list-length  l1) = ~A ~%"  (list-length  l1))

  (format t "~%")
))
;;;=============================================================================

;-------------------------------------------------------------------------------
(defun test4 (argus)  (declare (ignore argus))

(let (
   index
   a0 a1 a2
   )
  (declare (ignore a0 a1 a2))

  (setf index 0)
  (format t "~%")

  (dolist (a2 '(nil t))
  (dolist (a1 '(nil t))
  (dolist (a0 '(nil t))

    (format t " ~D)    ~4S  ~4S  ~4S  ~%"
                index   a2   a1   a0
                )

    (incf index)
    )))

  (format t "~%")
))
;===============================================================================
;
;-------------------------------------------------------------------------------
(defun list_test (argus)  (declare (ignore argus))

(let (
   (ll  '(0 1 2 3 4))
   )

  (format t "list_test ~%")

  (format t "ll= ~A ~%" ll)
  (format t "l2= ~A ~%" (nthcdr 2 ll))
  (format t "l2= ~A ~%" (last ll 3))

  (format t "~%")
))
;-------------------------------------------------------------------------------
;// ищем среди параметров : "name", подразумеваем, что там стоит "name=val" и 
;// возвращаем указатель на "val"
;-------------------------------------------------------------------------------
;char*
;parse_read (char *name, int argc, char *argv[], int  j)
;{
;-------------------------------------------------------------------------------
(defun parse_read (name argus j)  (declare (ignore j))

(let (
  ;  char *ptr;
  (len (length name)) ;  int   len, i;
  p
  )

  ;(format t "parse_read: argus= ~s   name= ~s   len= ~s   ~%" argus name len)

  (dolist (ptr argus)

    ;(format t "ptr= ~s  ~%" ptr)

    ;(setf p (find '= ptr))
    (setf p (subseq ptr 0 len))
    ;(format t "p  = ~s  ~%" p)


    (when (string= name p)
      ;(format t "string= ~s ~%" (subseq ptr (+ len 1)))
      (return-from parse_read (subseq ptr (+ len 1)))
      )
    
;    if (strncmp (ptr, name, len) == 0)
;      return (ptr+len+1);    
    )

  NIL ;  return (NULL);
))
;-------------------------------------------------------------------------------
(defun d_print (num)

  (format *error-output*  "D....~s.... ~%" num)

)
;;;=============================================================================
;-------------------------------------------------------------------------------
; 
;;;=============================================================================

(defstruct MF
    dim 
    ijk_cur
    IJK
    first index
)

;;;-----------------------------------------------------------------------------
(defun ijk_array_set (ijk value)

  (dotimes (index (length ijk))

    (setf (aref ijk index) value)
  )

)
;;;-----------------------------------------------------------------------------
(defun ijk_array_print (name ijk)

  (format t "~A  " name)

  (dotimes (index (length ijk))

    (format t "~A " (aref ijk index))
  )

  (format t "~%")
)
;-------------------------------------------------------------------------------
;;;-----------------------------------------------------------------------------
(defun MFOR_init (mf)

  (setf (MF-first   mf)     T)
  (setf (MF-index   mf)     -1) ; чтобы первым был нуль

  (ijk_array_set (MF-ijk_cur mf) 0)

)
;;;-----------------------------------------------------------------------------
(defun MFOR_create (dim ijk_cur IJK)
(let* (
  mf
  )

  ;; создадим новую пструктуру
  (setf mf (make-MF))

  ;; занесем в нее готовые массивы
  (setf (MF-dim     mf)     dim)
  (setf (MF-ijk_cur mf) ijk_cur)
  (setf (MF-IJK     mf)     IJK)

  ;(MFOR_init mf)

  mf
))
;;;-----------------------------------------------------------------------------
(defun MFOR_r (cur ijk_cur IJK)

  ;; просто увеличиваем значение текущего индекса
  (setf (aref ijk_cur cur) (+ (aref ijk_cur cur) 1))

  
  (if (not (= (aref ijk_cur cur) (aref IJK cur))) 
      T ; просто уходим, если нет еще границы
    (progn  
    ;; дошли до максимума, значит надо к след. индексу переходить

        
    (if (= cur 0) ; однако, если это был последний (левый) индекс,
        NIL       ; то конец
      (progn 
      
      (setf (aref ijk_cur cur) 0) ; обнуляем текущий индекс

      ;; и начинаем крутить индекс левее
      ;; а что же при этом с правыми происходит?  ну мы же возвращаемся каждый раз
      (MFOR_r  (- cur 1)  ijk_cur IJK)
      )
    )
  ))

)
;;;-----------------------------------------------------------------------------
(defun MFOR_todo (mf)

  (incf (MF-index mf)) ; просто увеличиваем порядковый индекс вызова 

  (if (MF-first mf) ; самый первый этап с нулевыми значениями нужно выделить:
      (progn 

      (setf (MF-first mf) NIL)
      T ; просто ничего не делая уходим 
      )

    ;; иначе
    ;; увеличиваем сначала правый индекс и при необходимости сдвигаемся влево
    (MFOR_r  (- (MF-dim mf) 1)  (MF-ijk_cur mf) (MF-IJK mf))
  )
)
;;;=============================================================================
;
;;;-----------------------------------------------------------------------------
(defun test4_ (argus)  (declare (ignore argus))

(let* (
  (dim     3)
  (ijk_cur (make-array dim))
  (IJK     (make-array dim))
  mf 
  )

  (ijk_array_set IJK     2) ; булевые переменные '(nil t) 
  (setf mf (MFOR_create  dim ijk_cur IJK))
  (MFOR_init mf)

  (format t "~%")

  (loop while (MFOR_todo mf) do (progn

    (format t " ~2D)    " (MF-index mf))
    (dotimes (i (length ijk_cur))
      (format t "~4S  " (nth (aref ijk_cur i) '(nil t)))
    )
    (format t "~%")
  )) 

  (format t "~%")
))
;;;-----------------------------------------------------------------------------
(defun test5 (argus) 

(let* (

  (dim     3)
  (ijk_max 2)

  ijk_cur IJK
  ;(ijk_cur (make-array dim))
  ;(IJK     (make-array dim))
  mf

  (argc (list-length argus))
  )

  
  ;(format t "argc = ~d ~%" argc)

  (when (= argc 1)   
    (setf dim      8) 
    (setf ijk_max  8) 
    )
  
  (setf ijk_cur (make-array dim))
  (setf IJK     (make-array dim))


  (ijk_array_set IJK     ijk_max)
  (setf mf (MFOR_create  dim ijk_cur IJK))
  (MFOR_init mf)

  (format t "~%")
  (ijk_array_print "ijk=" ijk_cur)
  (ijk_array_print "IJK=" (MF-IJK  mf))
  (format t "~%")

  (loop while (MFOR_todo mf) do (progn

    (when (= argc 0)
      (ijk_array_print "ijk_cur=" (MF-ijk_cur  mf))
      )

  )) 

  (format t "~%")
))
;
;-------------------------------------------------------------------------------
;===============================================================================

