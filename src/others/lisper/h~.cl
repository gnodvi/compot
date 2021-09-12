; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defvar CUR_DIR "h")

;(load "../a-comm.cl")
;(load "./a-comm.cl")
;(load "../common/a-comm.cl")

;(load "EXT/LSP/src/a-comm.cl")
(load "a-comm.cl")

(load "f-func.cl")

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun BEES (argus)

  ;(my_load "a-func.cl" CUR_DIR)
  ;(my_load "n-mbee.cl" CUR_DIR)

  ;(load "./a-func.cl")
  (load "h-mbee.cl")

  (run_cdr_argus (first argus) argus "BEES ..")
)
;-------------------------------------------------------------------------------

(READ_AND_CALL_ARGUS  CUR_DIR)

;===============================================================================

;cl m-gslm.li rosenbrock pr   100  
;cl m-gslm.li parabolic  step 100 
;cl m-gslm.li parabolic  bfgs 100 
;cl m-gslm.li parabolic  pr   100  
;cl m-gslm.li rosenbrock fr   100 
;cl m-gslm.li  
;cl m-gslm.li rosenbrock bfgs 100  
;sl m-gslm.li parabolic  fr   100 

;-------------------------------------------------------------------------------

