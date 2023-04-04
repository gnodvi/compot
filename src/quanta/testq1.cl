;-------------------------------------------------------------------------------

(load "t-qlib.cl")

(format t "~%")
(format t "1 ................. ~%")
(format t "~%")

;(exit)
;-------------------------------------------------------------------------------
;;; test file
;-------------------------------------------------------------------------------
;(defun TEST1 ()

  (setq m1 (quantum-new-matrix 2 2))
  (setq m2 (quantum-new-matrix 2 2))
  
  (setf (M m1 0 0) #c (2.0  3.0))
  (setf (M m1 1 0) #c( 2.0 -4.0))
  (setf (M m1 0 1) #c( 5.0  7.0))
  (setf (M m1 1 1) #c( 8.0  4.0))
  (setf (M m2 0 0) #c(-2.0  2.0))
  (setf (M m2 1 0) #c( 2.0 -1.0))
  (setf (M m2 0 1) #c( 6.0  7.0))
  (setf (M m2 1 1) #c( 3.0  4.0))
  
  (quantum-print-matrix m1)
  (quantum-adjoint      m1)
  (quantum-print-matrix m1)
  
  (format t "Creating qubit~%")
  
  (setq r1 (quantum-new-qureg 0 1))
  
  ;;-------------------------------------------------
  ;; Create a registry with 2qubit in |0> state
  
  (setq r2 (quantum-new-qureg 0 2))

  (quantum-print-qureg r1)
  (quantum-print-qureg r2)
  
  (quantum-hadamard 0 r1)
  
  (format t "Quantum RNG : ~d~%" (quantum-bmeasure 0 r1))
  
  (quantum-hadamard 0 r2)
  (quantum-cnot   0 1 r2)
  (quantum-print-qureg r2)
  
  (setq r3 (quantum-new-qureg 0 6))
  (quantum-qft 6 r3)
  (quantum-print-qureg r3)
  
;)
;-------------------------------------------------------------------------------

;(TEST1)

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------