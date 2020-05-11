;-------------------------------------------------------------------------------
;;; Shor algorithm
;;; F. Saporito

;-------------------------------------------------------------------------------

(load "t-qlib.cl")

(format t "~%")
(format t "3 ................. ~%")
(format t "~%")

;(exit)
;-------------------------------------------------------------------------------
(defun shor (n)

"Calculate the SHOR algorithm"

(let (

  (width  0)
  (swidth 0)
  (x 0)
  (c 0)
  (q 0)
  (a 0)
  (b 0)

  (factor 0)
  (qr (make-quantum-reg))
  )
  ;-------------------------------------------------------------------

  (if (< n 15)
      (return-from shor (format t "ERROR. N must be > 15")))

  (setq width (quantum-getwidth (* n n)))
  (setq swidth (quantum-getwidth n))

  (format t "N = ~d, ~d qubits required~%" n (+ width (* swidth 3) 2))

  (loop do
    (setq x (rem (random 32767) n))
    while (or (> (quantum-gcd n x) 1) (< x 2)))

  (format t "Random seed: ~d~%" x)
  
  (setq qr (quantum-new-qureg 0 width))
  
  (quantum-print-qureg qr)
  (break)
  
  (loop for i from 0 below width do
    (quantum-hadamard i qr))
  
  (quantum-print-qureg qr)
  (break)
  
  (quantum-addscratch (+ 2 (* 3 swidth)) qr)
  (quantum-print-qureg qr)
  (break)
  
  (quantum-exp-mod-n n x width swidth qr)
  (quantum-print-qureg qr)
  (break)
  
  (loop for i from 0 below (+ 2 (* 3 swidth)) do
    (quantum-bmeasure 0 qr))

  (format t "prima di qft~%")

  (quantum-print-qureg qr)
  (quantum-qft width qr)
  (format t "dopo qft~%")

  (quantum-print-qureg qr)

  (format t "fine dump registro~%")

  ;-------------------------------------------------------------------

  (loop for i from 0 below (/ width 2) do
    (quantum-cnot i (- width i 1) qr)
    (quantum-cnot (- width i 1) i qr)
    (quantum-cnot i (- width i 1) qr))

  (setq c (quantum-measure qr))

  (if (= c (- 1))
      (progn
        (format t "Impossible measurement!~%")
        (return-from shor 1)))
  (if (= c 0)
      (progn
        (format t "Measured zero, try again.~%")
        (return-from shor 2)))
  (setq q (ash 1 width))
  (format t "Measured ~d (~d), " c (/ c q))
  
  (quantum-frac-approx c q width)

  (format t "fractional approximation is ~d/~d.~%" c q)
  
  (if (and (= (rem q 2) 1) (< (* 2 q) (ash 1 width)))
      (progn
        (format t "Odd denominator, trying to expand by 2.~%")
        (setq q (* q 2))))

  (if (= (rem q 2) 1)
      (progn
        (format t "Odd period, try again.~%")
        (return-from shor 2)))

  (format t "Possible period is ~d.~%" q)


))
;-------------------------------------------------------------------------------

(shor 16) 

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
