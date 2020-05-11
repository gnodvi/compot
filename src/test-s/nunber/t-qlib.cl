;-------------------------------------------------------------------------------
;;; Libquantum porting
;;; F. Saporito
;;; 25 sept 2014

;-------------------------------------------------------------------------------

(defconstant +epsilon+ 0.000001)
(defconstant +num-regs+ 4)
(defconstant +MAX-UNSIGNED+ 32)
(defconstant +OBJCODE-PAGE+ 65536)
(defconstant +OBJBUF-SIZE+ 80)

;;; objcode elements

(defconstant +INIT+ #x00)
(defconstant +CNOT+ #x01)
(defconstant +TOFFOLI+ #x02)
(defconstant +SIGMA-X+ #x03)
(defconstant +SIGMA-Y+ #x04)
(defconstant +SIGMA-Z+ #x05)
(defconstant +HADAMARD+ #x06)
(defconstant +ROT-X+ #x07)
(defconstant +ROT-Y+ #x08)
(defconstant +ROT-Z+ #x09)
(defconstant +PHASE-KICK+ #x0A)
(defconstant +PHASE-SCALE+ #x0B)
(defconstant +COND-PHASE+ #x0C)
(defconstant +CPHASE-KICK+ #x0D)
(defconstant +SWAPLEADS+ #x0E)
;;;
;;;
(defconstant +MEASURE+ #x80)
(defconstant +BMEASURE+ #x81)
(defconstant +BMEASURE_P+ #x82)
(defconstant +NOP+ #xFF)
;;;

;-------------------------------------------------------------------------------
(defun copy-array (array &key
                         (element-type (array-element-type array))
                         (fill-pointer (and (array-has-fill-pointer-p array)
                                            (fill-pointer array)))
                         (adjustable (adjustable-array-p array)))

"Returns an undisplaced copy of ARRAY, with same fill-pointer and
adjustability (if any) as the original, unless overridden by the keyword
arguments."

(let* (
  (dimensions (array-dimensions array))
  (new-array (make-array dimensions
                         :element-type element-type
                         :adjustable adjustable
                         :fill-pointer fill-pointer))
  )

  (dotimes (i (array-total-size array))
    (setf (row-major-aref new-array i)
          (row-major-aref array i))
    )

  new-array

))
;-------------------------------------------------------------------------------
;;;

(defstruct quantum-reg

  (width 0 :type integer)
  (size  0 :type integer)
  (hashw 0 :type integer)
  (amplitude (make-array 1 
                         :element-type 'complex
                         :adjustable 't
                         :initial-element #c(0.0 0.0)))
  (state (make-array 1 
                     :element-type 'integer
                     :adjustable 't
                     :initial-element 0))
  (hash (make-array 1
                    :element-type 'integer
                    :adjustable 't
                    :initial-element 0)) 
  )

(defstruct quantum-matrix

  (cols 0)
  (rows 0)
  (t1 (make-array 1 :element-type 'complex))
  )

;-------------------------------------------------------------------------------

(defmacro M (m x y)

  `(aref (quantum-matrix-t1 ,m) (+ ,x (* ,y (quantum-matrix-cols ,m))))

)
;-------------------------------------------------------------------------------

(defparameter opstatus 0)

;;; Type of QEC. Currently implemented versions are:
;;; 0 : no QEC (default)
;;; 1 : Steane's 3-bit code

(defparameter qec-type 0)
(defparameter qec-width 0) ; How many qubits are protected

;;; Status of the decoherence simulation. Non-zero means enabled and
;;; decoherence effects will be simulated.

(defparameter decoherence-quantum-status 0)

;;; Decoherence parameter. The higher the value, the greater the
;;; decoherence impact.

(defparameter decoherence-quantum-lambda 0.0)

(defparameter objcode (make-array 255 
                               :element-type 'integer
                               :adjustable 't
                               :initial-element #xFF))
(defparameter posit 0)
(defparameter allocated 0)
(defparameter globalfile (make-array 255
                                  :element-type 'integer
                                  :adjustable 't
                                  :initial-element #xFF))

(defparameter global-gate-counter 0)

;-------------------------------------------------------------------------------

;;; end of objcode 

;;; QEC section 

;-------------------------------------------------------------------------------
(defun quantum-qec-set-status (stype swidth)

  "Change the status of the QEC."

  (setq qec-type stype)
  (setq qec-width swidth)

)
;-------------------------------------------------------------------------------
(defun quantum-qec-get-status (ptype &optional pwidth)

  "Get the current QEC status"

  (setq ptype qec-type)
  (setq pwidth qec-width)

)
;-------------------------------------------------------------------------------
(defun quantum-qec-encode (type width reg)

(let (
  (lambda 0.0)
  )

  (setq lambda (quantum-get-decoherence))
  (quantum-set-decoherence 0)

  (loop for i from 0 below width do

    (if (= i (1- (quantum-reg-width reg)))
        (quantum-set-decoherence lambda))
    (if (< i width)
        (progn
          (quantum-hadamard (+ (quantum-reg-width reg) i) reg)
          (quantum-hadamard (+ (* 2 (quantum-reg-width reg)) i) reg)
          (quantum-cnot (+ (quantum-reg-width reg) i) i reg)
          (quantum-cnot (+ (* 2 (quantum-reg-width reg)) i) i reg))
      (progn
        (quantum-cnot i (+ (quantum-reg-width reg) i) reg)
        (quantum-cnot i (+ (* 2 (quantum-reg-width reg)) i) reg)))
    )


  (quantum-qec-set-status 1 (quantum-reg-width reg))
  (setf (quantum-reg-width reg) (* (quantum-reg-width reg) 3))

))
;-------------------------------------------------------------------------------
(defun quantum-qec-decode (type width reg)

"Decode a quantum register and perform Quantum Error Correction on it"

(let (
  (swidth 0)
  (lambda 0.0)
  (a 0)
  (b 0)
  )

  (setq lambda (quantum-get-decoherence))
  (quantum-set-decoherence 0)
  (setq swidth (/ (quantum-reg-width reg) 3))
  (quantum-qec-set-status 0 0)

  (loop for i downfrom (/ (quantum-reg-width reg) 3) to 0 do
    (if (= i 0)
        (quantum-set-decoherence lambda))
    (if (< i width)
        (progn
          (quantum-cnot (+ (* 2 swidth) i) i reg)
          (quantum-cnot (+ i swidth) i reg)
          (quantum-hadamard (+ (* 2 swidth) i) reg)
          (quantum-hadamard (+ i swidth) reg))
      (progn
        (quantum-cnot i (+ (* 2 swidth) i) reg)
        (quantum-cnot i (+ i swidth) reg)))
    )

  (loop for i from 1 to swidth do
    (setq a (quantum-bmeasure swidth reg))
    (setq b (quantum-bmeasure (- (* 2 swidth) i) reg))
    (if (and (and (= a 1) (= b 1)) (< (1- i) width))
        (quantum-sigma-z (1- i) reg))
    )

))
;-------------------------------------------------------------------------------
(defun quantum-sigma-x-ft (target reg)

"Fault-tolerant version of NOT gate"

(let (

  (tmp 0)
  (lambda 0.0)
  )

  (setq tmp qec-type)
  (setq qec-type 0)
  (setq lambda (quantum-get-decoherence))

  (quantum-set-decoherence 0)

  (quantum-sigma-x target reg)
  (quantum-sigma-x (+ target qec-width) reg)

  (quantum-set-decoherence lambda)
  (quantum-qec-counter 1 0 reg)

  (setq qec-type tmp)

))
;-------------------------------------------------------------------------------
(defun quantum-cnot-ft (control target reg)

"Fault-tolerant version of Controlled NOT gate"

(let (
  (tmp 0)
  (lambda 0.0)
  )

  (setq tmp qec-type)
  (setq qec-type 0)
  (setq lambda (quantum-get-decoherence))

  (quantum-set-decoherence 0)
  (quantum-cnot control target reg)
  (quantum-cnot (+ control qec-width) (+ target qec-width) reg)
  (quantum-set-decoherence lambda)
  (quantum-cnot (+ control (* 2 qec-width)) (+ target (* 2 qec-width)) reg)
  (quantum-qec-counter  1 0 reg)

  (setq qec-type tmp)
  
))
;-------------------------------------------------------------------------------
(defun quantum-toffoli-ft (control1 control2 target reg)

"Fault-tolerant version of the Toffoli gate"

(let (
  (c1 0)
  (c2 0)
  (mask 0)
  )

  (setq mask (+ (ash 1 target) (ash 1 (+ target qec-width)) 
		  (ash 1 (+ target (* 2 qec-width)))))

  (loop for i from 0 below (quantum-reg-size reg) do
    
    (setq c1 0)
    (setq c2 0)
    
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control1)) 0)
        (setq c1 1))
    (if (/= (logand (aref (quantum-reg-state reg) i) 
                    (ash 1 (+ qec-width control1))) 0)
        (setq c1 (logxor c1 1)))
    (if (/= (logand (aref (quantum-reg-state reg) i) 
                    (ash 1 (+ control1 (* 2 qec-width)))) 0)
        (setq c1 (logxor c1 1)))
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control2)) 0)
        (setq c2 1))
    (if (/= (logand (aref (quantum-reg-state reg) i) 
                    (ash 1 (+ control2 qec-width))) 0)
        (setq c2 (logxor c2 1)))
    (if (/= (logand (aref (quantum-reg-state reg) i) 
                    (ash 1 (+ control2 (* 2 qec-width)))) 0)
        (setq c2 (logxor c2 1)))
    (if (and (= c1 1) (= c2 1))
        (setf (aref (quantum-reg-state reg) i) 
              (logxor (aref (quantum-reg-state reg) i) mask)))
    )
  
  (quantum-decohere reg)
  (quantum-qec-counter 1 0 reg)
  
))
;-------------------------------------------------------------------------------
(defun quantum-qec-counter (inc frequency reg)

"Counter which can be used to apply QEC periodically"

(let (
  (counter 0)
  (freq (ash 1 30))
  )

  (if (> inc 0)
      (incf counter inc)
    (if (< inc 0)
        (setq counter 0)))

  (if (> frequency 0)
      (setq freq frequency))

  (if (>= counter freq)
      (progn
        (setq counter 0)
        (quantum-qec-decode qec-type qec-width reg)
        (quantum-qec-encode qec-type qec-width reg)))
  
  counter

))
;-------------------------------------------------------------------------------

;;; end of QEC section

;;; MEASURE

;-------------------------------------------------------------------------------
(defun quantum-measure (reg)

"Measure the contents of a quantum register"

(let (
  (r 0.0)
  )
  
  (if (quantum-objcode-put +MEASURE+)
      (return-from quantum-measure 0))

  (setq r (random 1.0))
  (quantum-print-qureg reg)

  (loop for i from 0 below (quantum-reg-size reg) do

    (format t "measurement: ~d factor: ~d~%" i r)
    (decf r (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)))

    (format t "measurement: ~d factor: ~d~%" i r)
    (format t "state: ~a~%" (aref (quantum-reg-state reg) i))

    (if (<= r 0)
        (return-from quantum-measure (aref (quantum-reg-state reg) i)))
    )

  (return-from quantum-measure (- 1))

))
;-------------------------------------------------------------------------------
(defun quantum-bmeasure (pos reg)

"Measure a single bit of a quantum register. The bit measured is
   indicated by its position POS, starting with 0 as the least
   significant bit. The new state of the quantum register depends on
   the result of the measurement."

(let (
  (result 0)
  (pa 0.0)
  (r 0.0)
  (pos2 0)
  (out (make-quantum-reg))
  )

  (if (quantum-objcode-put +BMEASURE+ pos)
      (return-from quantum-bmeasure 0))
  (setq pos2 (ash 1 pos))

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (= (logand (aref (quantum-reg-state reg) i) pos2) 0)
        (incf pa (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)))))

  (setq r (random 1.0))

  (if (> r pa)
      (setq result 1))

  (setq out (quantum-state-collapse pos result reg))
  (quantum-delete-qureg-hashpreserve reg)

  (setf (quantum-reg-state reg) 
        (adjust-array (quantum-reg-state reg) (length (quantum-reg-state out))))

  (setf (quantum-reg-amplitude reg) 
        (adjust-array (quantum-reg-amplitude reg) (length (quantum-reg-amplitude out))))
  
  (setf (quantum-reg-state reg) (copy-array (quantum-reg-state out)))
  (setf (quantum-reg-amplitude reg) (copy-array (quantum-reg-amplitude out)))

  ;;    (quantum-copy-qureg reg out)
  result

))
;-------------------------------------------------------------------------------

;;; end of MEASURE

;;; Decoherence
          
;-------------------------------------------------------------------------------
(defun quantum-get-decoherence ()

  decoherence-quantum-status

)
;-------------------------------------------------------------------------------
(defun quantum-set-decoherence (l)

  (if (/= l 0)
      
      (progn
        (setq decoherence-quantum-status 1)
        (setq decoherence-quantum-lambda l))

    (setq decoherence-quantum-status 0)
    )
)
;-------------------------------------------------------------------------------
(defun quantum-decohere (reg)

"Perform the actual decoherence of a quantum register for a single step 
of time. This is done by applying a phase shift by a normal distributed 
angle with the variance LAMBDA."

(let (
  (v 0) 
  (s 0)
  (u 0) (x 0)
  (nrands (make-array 1 :element-type 'integer :adjustable 't))
  (angle 0)
  )

  (quantum-gate-counter 1)

  (if (/= decoherence-quantum-status 0)
      
      (progn
        (setq nrands (adjust-array nrands (quantum-reg-width reg)))
        (loop for i from 0 below (quantum-reg-width reg) do
          (loop do (progn
                     (setq u (1- (* 2.0 (random 1.0))))
                     (setq v (1- (* 2.0 (random 1.0))))
                     (setq s (+ (expt u 2) (expt v 2))))
            while (>= s 1.0))
          (setq x (* u (sqrt (* (- 2) (/ (log s) s)))))
          (setq x (* x (sqrt (* 2.0 decoherence-quantum-lambda))))
          (setf (aref nrands i) (/ x 2.0)))
        (loop for i from 0 below (quantum-reg-size reg) do
          (setq angle 0)
          (loop for j from 0 below (quantum-reg-width reg) do
            (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 j)) 0)
                (incf angle (aref nrands j))
              (decf angle (aref nrands j))))
          (setf (aref (quantum-reg-amplitude reg) i) 
                (* (aref (quantum-reg-amplitude reg) i) 
                   (quantum-cexp angle))))
        ))

))
;-------------------------------------------------------------------------------

;;; end of decoherence
;-------------------------------------------------------------------------------        
(defun quantum-n2char (mu buf)

"Convert a big integer to a byte array"

(let (
  (size +MAX-UNSIGNED+)
  )
  
  (loop for i from 0 below size do

    (setf (aref buf i) (/ mu (ash 1 (* 8 (1- (- size i))))))
    (setq mu (rem mu (ash 1 (* 8 (1- (- size i)))))))

))
;-------------------------------------------------------------------------------
(defun quantum-objcode-start ()

  (setq opstatus 1)
  (setq allocated 1)

  (setq objcode (make-array +OBJCODE-PAGE+
                            :element-type 'integer
                            :adjustable 't
                            :initial-element #xFF))

)
;-------------------------------------------------------------------------------
(defun quantum-objcode-stop ()

  (setq opstatus 0)
  (setq allocated 0)

  (setq objcode (make-array 1
                            :element-type 'integer
                            :adjustable 't
                            :initial-element #xFF))

)
;-------------------------------------------------------------------------------
(defun quantum-objcode-put (operation &rest vals)

"Store an operation with its arguments in the object code data"

(let (
  (size +MAX-UNSIGNED+)
  (buf (make-array 80 :element-type 'integer :initial-element #xFF))
  )

  (if (= opstatus 0)
      (return-from quantum-objcode-put)) ; perform the gate operations

  (setf (aref buf 0) operation)

  (case operation

    (+INIT+ (quantum-n2char (car vals) (aref buf 1)))
    ((+CNOT+ +COND-PHASE+) (progn
                             (quantum-n2char (car vals) (aref buf 1))
                             (quantum-n2char (cadr vals) (aref buf 2))))
    (+TOFFOLI+ (progn
                 (quantum-n2char (car vals) (aref buf 1))
                 (quantum-n2char (cadr vals) (aref buf 2))
                 (quantum-n2char (caddr vals) (aref buf 3))))
    ((+SIGMA-X+ +SIGMA-Y+ +SIGMA-Z+
                +HADAMARD+ +BMEASURE+
                +BMEASURE-P+ +SWAPLEADS+) (quantum-n2char (car vals) 
                                                          (aref buf 1)))
    ((+ROT-X+ +ROT-Y+
              +ROT-Z+ +PHASE-KICK+
              +PHASE-SCALE+) (progn
                               (quantum-n2char (car vals) (aref buf 1))
                               (quantum-n2char (cadr vals) (aref buf 2))))
    (+CPHASE-KICK+ (progn
                     (quantum-n2char (car vals) (aref buf 1))
                     (quantum-n2char (cadr vals) (aref buf 2))
                     (quantum-n2char (caddr vals) (aref buf 3))))
    ((+MEASURE+ +NOP+))

    (otherwise (format t "INVALID QUANTUM OPCODE~%")))


  (if (> (/ (+ posit size) +OBJCODE-PAGE+) (/ posit +OBJCODE-PAGE+))
      (progn
        (incf allocated)
        (setf objcode (adjust-array objcode (* allocated +OBJCODE-PAGE+)))))

  (loop for i from 0 below size do
    (progn
      (setf (aref objcode posit) (aref buf i))
      (incf posit)))

  (return-from quantum-objcode-put t) ; do not perform gate operation, 
                                      ; stores only!
))
;-------------------------------------------------------------------------------
(defun quantum-objcode-write (file)

"Save the recorded object code data to a file"

  (with-open-file (stream-1 file :direction :output
                            :if-exists :supersede
                            :if-does-not-exist :create)
    (loop for i from 0 below (array-dimension objcode 0) do
      (format stream-1 "~a~%" (aref objcode i))
      ))

)
;-------------------------------------------------------------------------------
(defun bit-vector->integer (bit-vector)

  "Create a positive integer from a bit-vector."

  (reduce #'(lambda (first-bit second-bit)
             (+ (* first-bit 2) second-bit))
          bit-vector)

)
;-------------------------------------------------------------------------------
(defun integer->bit-vector (integer)

"Create a bit-vector from a positive integer."

(labels (
  (integer->bit-list (int &optional accum)
     (cond (
        (> int 0)
        (multiple-value-bind (i r) (truncate int 2)
          (integer->bit-list i (push r accum))))

           ((null accum) (push 0 accum))
           (t accum))
     ))
  
  (coerce (integer->bit-list integer) 'bit-vector)
  )
  
)
;-------------------------------------------------------------------------------
(defun ul-mult (a b)

"Perform an unsigned-long multiplication (32-bit)."

(let (

  (b64 #*)
  (l-b64 0)
  (j 31)
  (cc 0)
  (b32 (integer->bit-vector #xFFFFFFFF))
  (k64 0))

  (setq k64 (* a b))
  (setq b64 (integer->bit-vector k64))
  (setq l-b64 (1- (length b64)))

  (if (> l-b64 31)
      (progn
        (setq cc (- l-b64 31))
        (loop for i downfrom l-b64 to cc do
          (setf (bit b32 j) (bit b64 i))
          (decf j)))
    (setq b32 b64))

  (bit-vector->integer b32)

))
;-------------------------------------------------------------------------------
(defun quantum-frac-approx (a b width)

"Fractional approximation of a decimal value"

(let (  

  (f (coerce (/ a b) 'float))
  (g (coerce (/ a b) 'float))

  (t1 0.0)
  (num2 0)

  (i 0)
  (den2 1)
  (num1 1)
  (den1 0)
  (num  1)
  (den  1) )

  (loop do
    (progn
      (setq i (floor (+ g 0.000005)))
      (setq t1 (- i 0.000005))
      (setq g (- g t1))
      (setq g (/ 1.0 g))
      (if (> (+ (* i den1) den2) (ash 1 width)) (return))
      (setq num (+ (* i num1) num2))
      (setq den (+ (* i den1) den2))
      (setq num2 num1)
      (setq den2 den1)
      (setq num1 num)
      (setq den1 den)
      ) 
    while (> (abs (- (coerce (/ num den) 'float) f)) 
             (/ 1.0 (* 2 (ash 1 width))))
    )

  (setq a num)
  (setq b den)

))
;-------------------------------------------------------------------------------
(defun quantum-getwidth (n)

  "Calculates the number of qubits required to store N"

  (loop for i from 1 sum (+ i 1)

      while (< (ash 1 i) n)
      finally (return i))

)
;-------------------------------------------------------------------------------
(defun quantum-inverse-mod (n c)

"Calculate the inverse modulus of N and C"

(loop for i from 1 sum (+ i 1)
      while (/= (rem (* i c) n) 1)
      finally (return i))

)
;-------------------------------------------------------------------------------
(defmacro quantum-gcd (u v)

  `(gcd ,u ,v) 

)
;-------------------------------------------------------------------------------
(defun quantum-prob-inline (z)

  (expt (abs z) 2)

)
;-------------------------------------------------------------------------------
(defun quantum-ipow (a b)

  (progn

    (coerce a 'integer)
    (coerce b 'integer)
    (expt a b)
    )

)
;-------------------------------------------------------------------------------
(defmacro quantum-prob (a)

  `(quantum-prob-inline ,a) 

)
;-------------------------------------------------------------------------------
(defun quantum-cexp (phi)

  (complex (cos phi) (sin phi)) 

)
;-------------------------------------------------------------------------------
(defmacro quantum-new-matrix (cols rows)

  `(make-quantum-matrix 
    :rows ,rows
    :cols ,cols
    :t1 (make-array (* ,rows ,cols) 
                    :element-type 'complex
                    :initial-element #c(0.0 0.0)))
)
;-------------------------------------------------------------------------------
(defun quantum-print-matrix (m)

(let ( 
  (rows (quantum-matrix-rows m))
  (cols (quantum-matrix-cols m))
  )

  (loop for i from 0 below rows do
  (loop for j from 0 below cols do
      
    (format t "~D " (M m j i))
    )
  (format t "~%")
  )
  
))
;-------------------------------------------------------------------------------
(defun quantum-mmult (a b)

(let* (

  (b-cols (quantum-matrix-cols b))
  (b-rows (quantum-matrix-rows b))
  (a-rows (quantum-matrix-rows a))
  (c (quantum-new-matrix b-cols a-rows))
  )

  (loop for i from 0 below b-cols do
  (loop for j from 0 below a-rows do
  (loop for k from 0 below b-rows do

    (setf (M c i j) (+ (M c i j) (* (M a k j) (M b i k)))))))

  c

))
;-------------------------------------------------------------------------------
(defun quantum-adjoint (m)

(let (

  (cols (quantum-matrix-cols m))
  (tmp #c(0.0 0.0))
  )

  (loop for i from 0 below cols do
  (loop for j from 0 below    i do
      (setq tmp (M m i j))
      (setf (M m i j) (conjugate (M m j i)))
      (setf (M m j i) (conjugate tmp))))

))
;-------------------------------------------------------------------------------
(defun quantum-matrix-to-qureg (m wid)

"Convert a vector to a quantum register"

(let* (

  (rows (quantum-matrix-rows m))
  (l-s 0)
  (l-size (loop for i from 0 below rows sum (1+ l-s)
            while (/= (aref (quantum-matrix-t1 m) i) #c(0.0 0.0))))

  (reg (make-quantum-reg
        :hash (make-array (ash 1 (+ wid 2))
                          :adjustable 't
                          :element-type 'integer)
        :state (make-array l-size
                           :adjustable 't
                           :element-type 'integer)
        :amplitude (make-array l-size 
                               :element-type 'complex
                               :adjustable 't
                               :initial-element #c(0.0 0.0))))
  (l-j 0)
  )

  (setf (quantum-reg-width reg) wid)
  (setf (quantum-reg-size reg) l-size)
  (setf (quantum-reg-hashw reg) (+ wid 2))

  (loop for i from 0 below rows do
    (if (/= (aref (quantum-matrix-t1 m) i) #c(0.0 0.0))
        (progn
          (setf (aref (quantum-reg-state reg) l-j) i)
          (setf (aref (quantum-reg-amplitude reg) l-j) 
                (aref (quantum-matrix-t1 m) i))
          (setf l-j (1+ l-j)) )))

  reg

))
;-------------------------------------------------------------------------------
(defun quantum-new-qureg (initval wid)

  "Create a new quantum register from scratch.
  Allocate memory for 1 base state"

  (make-quantum-reg
   :width wid
   :size 1
   :hashw (+ wid 2)
   :hash (make-array (ash 1 (+ wid 2))
                     :adjustable 't
                     :element-type 'integer
                     :initial-element 0)
   :state (make-array 1 
                      :element-type 'integer
                      :adjustable 't
                      :initial-element initval)
   :amplitude (make-array 1 
                          :element-type 'complex
                          :adjustable 't
                          :initial-element #c(1.0 0.0)))

)
;-------------------------------------------------------------------------------
(defun quantum-new-qureg-size (n wid)

  (make-quantum-reg

   :width wid
   :size n
   :hashw 0
   :hash (make-array 1
                     :adjustable 't
                     :element-type 'integer)
   :state (make-array 1 
                      :element-type 'integer 
                      :initial-element 0)
   :amplitude (make-array n 
                          :element-type 'complex 
                          :initial-element #c(0.0 0.0)))

)
;-------------------------------------------------------------------------------
(defun quantum-new-qureg-sparse (n wid)

  (make-quantum-reg

   :width wid
   :size n
   :hashw 0
   :hash (make-array 1
                     :adjustable 't
                     :element-type 'integer)
   :state (make-array n 
                      :element-type 'integer
                      :adjustable 't
                      :initial-element 0)
   :amplitude (make-array n 
                          :element-type 'complex
                          :adjustable 't
                          :initial-element #c(0.0 0.0)))

)
;-------------------------------------------------------------------------------
(defun quantum-qureg-to-matrix (reg)

"Convert a quantum register to a column vector"

(let (
  (m (quantum-new-matrix 1 (ash 1 (quantum-reg-width reg))))
  )
  
  (loop for i from 0 below (quantum-reg-size reg) do
    (setf (aref (quantum-matrix-t1 m) (aref (quantum-reg-state reg) i)) 
          (aref (quantum-reg-amplitude reg) i)))

  m
))
;-------------------------------------------------------------------------------
(defun quantum-copy-qureg (src dst)

  (setq dst (make-quantum-reg
             :width (quantum-reg-width src)
             :size (quantum-reg-size src)
             :hashw (quantum-reg-hashw src)
             :state (quantum-reg-state src)
             :amplitude (quantum-reg-amplitude src)
             :hash (quantum-reg-hash src))
        )
)
;-------------------------------------------------------------------------------
(defun quantum-print-qureg (reg)

"Print the contents of a quantum register to stdout"

(loop for i from 0 below (quantum-reg-size reg) do

  (format t "~D|~D> (~D) (|" (aref (quantum-reg-amplitude reg) i)
          (aref (quantum-reg-state reg) i)
          (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)))

  (loop for j from (1- (quantum-reg-width reg)) downto 0 do
    (if (= (rem j 4) 3) (format t " "))
    (format t "~D" (cond 
                    ((> (logand (ash 1 j) 
                                (aref (quantum-reg-state reg) i)) 0) 1)
                    (t 0)) ))
  (format t ">)~%")
  )
(
format t "~%")

)
;-------------------------------------------------------------------------------
(defun quantum-print-expn (reg)


  "Print the output of the modular exponentation algorithm"

  (loop for i from 0 below (quantum-reg-size reg) do
    (format t "~D: ~D~%" i (- (aref (quantum-reg-state reg) i)
                              (* i (ash 1 (/ (quantum-reg-width reg) 2)))))
    )
)
;-------------------------------------------------------------------------------
(defun quantum-print-hash (reg)

  "Print the hash table of qureg to check if it's corrupted"

  (loop for i from 0 below (ash 1 (quantum-reg-hashw reg)) do
    (if (/= i 0)
        (format t "~D: ~D ~D~%" i (1- (aref (quantum-reg-hash reg) i))
                (aref (quantum-reg-state reg) 
                      (if (< (1- (aref (quantum-reg-hash reg) i)) 0) 0 1)
                      ))))
  )
;-------------------------------------------------------------------------------
(defun quantum-add-hash (a pos reg)

(let (
  (mark 0)
  (i (quantum-hash64 a (quantum-reg-hashw reg)))
  )

  (loop while (/= (aref (quantum-reg-hash reg) i) 0) do

    (incf i)
    (if (= i (ash 1 (quantum-reg-hashw reg)))
        (if (= mark 0)
            (progn
              (setq i 0)
              (setq mark 1))
          (format t "ERROR : HASH FULL~%"))))

  (setf (aref (quantum-reg-hash reg) i) (1+ pos))

))
;-------------------------------------------------------------------------------
(defun quantum-reconstruct-hash (reg)

(block hashing-rec

  (if (= (quantum-reg-hashw reg) 0)
      (return-from hashing-rec))

  (loop for i from 0 below (ash 1 (quantum-reg-hashw reg)) do
        (setf (aref (quantum-reg-hash reg) i) 0))

  (loop for i from 0 below (quantum-reg-size reg) do
        (quantum-add-hash (aref (quantum-reg-state reg) i) i reg))

))
;-------------------------------------------------------------------------------
(defun quantum-addscratch (bits reg)

"Add additional space to a qureg. It is initialized to zero and can be used as 
scratch space. Note that the space gets added at the LSB"

(let (
  (l 0)
  )

  (setf (quantum-reg-width reg) (+ (quantum-reg-width reg) bits))

  (loop for i from 0 below (quantum-reg-size reg) do
        (setq l (ash (aref (quantum-reg-state reg) i) bits))
        (setf (aref (quantum-reg-state reg) i) l))

))
;-------------------------------------------------------------------------------
(defun quantum-kronecker (reg1 reg2)

"Compute the Kronecker product of two quantum registers"

(let* (
  (reg-width (+ (quantum-reg-width reg1) (quantum-reg-width reg2)))
  (reg-size (* (quantum-reg-size reg1) (quantum-reg-size reg2)))
  (reg-hashw (+ 2 reg-width))
  (l1 0)
  (reg (make-quantum-reg
        :width reg-width
        :size reg-size
        :hashw reg-hashw
        :state (make-array reg-size :element-type 'integer :adjustable 't)
        :amplitude (make-array reg-size 
                               :element-type 'complex
                               :adjustable 't
                               :initial-element #c(0.0 0.0))
        :hash (make-array (ash 1 reg-hashw)
                          :adjustable 't
                          :element-type 'integer)))
  )

  (loop for i from 0 below (quantum-reg-size reg1) do
  (loop for j from 0 below (quantum-reg-size reg2) do

    (setq l1 (+ j (* i (quantum-reg-size reg2))))

    (setf (aref (quantum-reg-state reg) l1)
          (logior (ash (aref (quantum-reg-state reg1) i) (quantum-reg-width reg2))
                  (aref (quantum-reg-state reg2) j)))

    (setf (aref (quantum-reg-amplitude reg) l1)
          (* (aref (quantum-reg-amplitude reg1) i) 
             (aref (quantum-reg-amplitude reg2) j)))))

  reg

))
;-------------------------------------------------------------------------------
(defun quantum-state-collapse (pos value reg)

"Reduce the state vector after measurement or partial trace"
(let* (

  (l-siz 0)
  (d 0.0)
  (lpat 0)
  (rpat 0)
  (j 0)
  (out (make-quantum-reg))
  (pos2 (ash 1 pos))
  )

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (/= (logior (logand (logand (aref (quantum-reg-state reg) i) pos2)
                            value)
                    (logand (lognand (aref (quantum-reg-state reg) i) pos2)
                            (lognot value))) 0)
        (progn
          (incf d (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)))
          (incf l-siz))))

  (format t "d: ~d, l-siz: ~d, pos: ~d, value: ~d~%" d l-siz pos value)

  (setq out (make-quantum-reg
             :size l-siz
             :width (1- (quantum-reg-width reg))
             :hashw (quantum-reg-hashw reg)
             :hash (quantum-reg-hash reg)
             :state (make-array l-siz :element-type 'integer :adjustable 't)
             :amplitude (make-array l-siz 
                                    :element-type 'complex
                                    :adjustable 't
                                    :initial-element #c(0.0 0.0))))

  (setq j 0)

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (/= (logior (logand (logand (aref (quantum-reg-state reg) i) pos2)
                            value)
                    (logand (lognand (aref (quantum-reg-state reg) i) pos2)
                            (lognot value))) 0)
        (progn
          (setq rpat 0)
          (setq rpat (loop for k from 0 below pos sum (+ rpat (ash 1 k))))
          
          (setq rpat (logand rpat (aref (quantum-reg-state reg) i)))
          (setq lpat 0)
          (setq lpat (loop for k downfrom (1- (* 8 +MAX-UNSIGNED+)) to 
                       (1+ pos) sum (+ lpat (ash 1 k))))
          (setq lpat (logand lpat (aref (quantum-reg-state reg) i)))
          
          (setf (aref (quantum-reg-state out) j) (logior 
                                                  (ash lpat (- 1)) rpat))
          
          (setf (aref (quantum-reg-amplitude out) j) 
                (* (aref (quantum-reg-amplitude reg) i) (/ 1.0 (sqrt d))))
          (incf j))))
  out

))
;-------------------------------------------------------------------------------
(defun quantum-hash64 (key width)

"Our 64-bit multiplicative hash function"

(let (
  (k32 0)
  )

  (setq k32 (logxor (logand key #xFFFFFFFF) (ash key -32)))
  (setq k32 (ul-mult k32 #x9e370001))
  (setq k32 (ash k32 (- width 32)))

  k32

))
;-------------------------------------------------------------------------------
(defun quantum-destroy-hash (reg)

  "Destroy the entire hash table of a quantum register"

  (setf (quantum-reg-hash reg) (make-array 1
                                           :element-type 'integer
                                           :adjustable 't
                                           :initial-element 0))
)
;-------------------------------------------------------------------------------
(defun quantum-delete-qureg (reg)

  "Delete a quantum register"
  
  (if (/= (quantum-reg-hashw reg) 0)
      (quantum-destroy-hash reg))
  (setf (quantum-reg-amplitude reg) (make-array 1
                                                :element-type 'complex
                                                :adjustable 't
                                                :initial-element #c(0.0 0.0)))
  (setf (quantum-reg-state reg) (make-array 1
                                            :element-type 'integer
                                            :adjustable 't
                                            :initial-element 0))
)
;-------------------------------------------------------------------------------
(defun quantum-delete-qureg-hashpreserve (reg)

  "Delete a quantum register but leave the hash table alive"

  (setf (quantum-reg-amplitude reg) (make-array (length (quantum-reg-amplitude reg))
                                                :element-type 'complex
                                                :adjustable 't
                                                :initial-element #c(0.0 0.0)))

  (setf (quantum-reg-state reg) (make-array (length (quantum-reg-state reg))
                                            :element-type 'integer
                                            :adjustable 't
                                            :initial-element 0))
)
;-------------------------------------------------------------------------------
(defun quantum-bitmask (a width bits)

"Return the reduced bitmask of a basis state"

(let (
  (mask 0)
  )

  (loop for i from 0 below width do
    (if (/= (logand a (ash 1 (aref bits i))) 0)
        (incf mask (ash 1 i))))

  mask

))
;-------------------------------------------------------------------------------
(defun quantum-get-state (a reg)

"Get the position of a given base state via the hash table"

(let (
  (i (quantum-hash64 a (quantum-reg-hashw reg)))
  )
  ;;  (break)

  (block hashing-0

    (if (= (quantum-reg-hashw reg) 0)
        (return-from hashing-0 a))

    (loop while (/= (aref (quantum-reg-hash reg) i) 0) do
      (if (= (aref (quantum-reg-state reg) (1- (aref (quantum-reg-hash reg) i))) a)
          (return-from hashing-0 (1- (aref (quantum-reg-hash reg) i))))
      (setq i (1+ i))
      (if (= i (ash 1 (quantum-reg-hashw reg)))
          (setq i 0)))
    
    (return-from hashing-0 -1))

))
;-------------------------------------------------------------------------------
(defun quantum-dot-product (reg1 reg2)

"Compute the dot product of two quantum registers"
(let (
  (f #c(0.0 0.0))
  (j 0)
  )

  (if (/= (quantum-reg-hashw reg2) 0)
      (quantum-reconstruct-hash reg2))
  
  (if (/= (aref (quantum-reg-state reg1) 0))
      (loop for i from 0 below (quantum-reg-size reg1) do
        (progn
          (setq j (quantum-get-state (aref (quantum-reg-state reg1) i) reg2))
          (if (> j (- 1))
              (setf f (+ f (conjugate (* (aref (quantum-reg-amplitude reg1) i)
                                         (aref (quantum-reg-amplitude reg2) i))))))))
    (loop for i from 0 below (quantum-reg-size reg1) do
      (progn
        (setq j (quantum-get-state i reg2))
        (if (> j (- 1))
            (setf f (+ f (conjugate (* (aref (quantum-reg-amplitude reg1) i)
                                       (aref (quantum-reg-amplitude reg2) i))))))))
    )

  f
))
;-------------------------------------------------------------------------------
(defun quantum-dot-product-noconj (reg1 reg2)

"Compute the dot product of two quantum registers without complex conjugation."

(let (
  (j 0)
  (f #c(0.0 0.0))
  )

  (if (/= (quantum-reg-hashw reg2) 0)
      (quantum-reconstruct-hash reg2))
  (if (= (quantum-reg-state reg2) 0)
      (setq f (loop for i from 0 below (quantum-reg-size reg1) sum 
                (* (aref (quantum-reg-amplitude reg1) i) 
                   (aref (quantum-reg-amplitude reg2) 
                         (aref (quantum-reg-state reg1) i)))))
    (loop for i from 0 below (quantum-reg-size reg1) do
      (setq j (quantum-get-state (aref (quantum-reg-state reg1) i) reg2))
      (if (> j (- 1))
          (setq f (* (aref (quantum-reg-amplitude reg1) i) 
                     (aref (quantum-reg-amplitude reg2) j))))))

  f
))
;-------------------------------------------------------------------------------
(defun quantum-scalar-qureg (r reg)

"Scalar multiplication of a quantum register. This is a purely mathematical 
operation without any physical meaning, so only use it if you know what you 
are doing."

(loop for i from 0 below (quantum-reg-size reg) do
      (setf (aref (quantum-reg-amplitude reg) i) 
	    (* (aref (quantum-reg-amplitude reg) i) r)))

)
;-------------------------------------------------------------------------------
(defun quantum-normalize (reg)

"Normalize a quantum register"

(let (
  (r 0.0)
  )

  (setq r (loop for i from 0 below (quantum-reg-size reg) 
            sum (+ r (quantum-prob (aref (quantum-reg-amplitude reg) i)))))

  (quantum-scalar-qureg (/ 1.0 (sqrt r)) reg)

))
;-------------------------------------------------------------------------------
;;; modular arithmetic

;-------------------------------------------------------------------------------
(defun emul (a l width reg)

  (loop for i downfrom (1- width) to 0 do
    (if (/= (logand (ash a (- i)) 1) 0)
        (quantum-toffoli (+ 2 (* 2 width)) l (+ i width) reg))
    )

)
;-------------------------------------------------------------------------------
(defun muln (n a ctl width reg)

;;; ctl tells, which bit is the external enable bit

(let (
  (l (1+ (* 2 width)))
  )

  (quantum-toffoli ctl (+ 2 (* 2 width)) l reg)
  (emul (rem a n) l width reg)
  (quantum-toffoli ctl (+ 2 (* 2 width)) l reg)

  (loop for i from 1 below width do
    (quantum-toffoli ctl (+ 2 i (* 2 width)) l reg)
    (add-mod-n n (rem (* (ash 1 i) a) n) width reg)
    (quantum-toffoli ctl (+ 2 i (* 2 width)) l reg)
    )

))
;-------------------------------------------------------------------------------
(defun muln-inv (n a ctl width reg)

(let (
  (l (1+ (* 2 width)))
  )

  (setq a (quantum-inverse-mod n a))

  (loop for i downfrom (1- width) to 1 do
    (quantum-toffoli ctl (+ 2 i (* 2 width)) l reg)
    (add-mod-n n (rem (- n (* (ash 1 i) a)) n) width reg)
    (quantum-toffoli ctl (+ 2 i (* 2 width)) l reg)
    )

  (quantum-toffoli ctl (+ 2 (* 2 width)) l reg)
  (emul (rem a n) l width reg)
  (quantum-toffoli ctl (+ 2 (* 2 width)) l reg)
  
))
;-------------------------------------------------------------------------------
(defun mul-mod-n (n a ctl width reg)

  (muln n a ctl width reg)
  (quantum-swaptheleads-omuln-controlled ctl width reg)
  (muln-inv n a ctl width reg)

)
;-------------------------------------------------------------------------------
(defun muxha (a b-in c-in xlt-l l total reg)

"This is a semi-quantum halfadder. It adds to b_in a c-number. 
Carry-in bit is c_in and carry_out is not necessary. 
xlt-l and L are enablebits. See documentation for further information"

  (cond
    ((= a 0) (quantum-cnot b-in c-in reg))
    ((= a 3) (progn
	       (quantum-cnot l c-in reg)
	       (quantum-cnot b-in c-in reg)))
    ((= a 1) (progn
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-cnot b-in c-in reg)))
    ((= a 2) (progn
	       (quantum-sigma-x xlt-l reg)
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-cnot b-in c-in reg)
	       (quantum-sigma-x xlt-l reg)))
    (t nil)
    )

)
;-------------------------------------------------------------------------------
(defun muxfa (a b-in c-in c-out xlt-l l total reg)

  "This is a semi-quantum fulladder. It adds to b_in a c-number. 
Carry-in bit is c_in and carry_out is c_out. xlt-l and L are enablebits. 
See documentation for further information"

  (cond
    ((= a 0) (progn
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-cnot b-in c-in reg)))
    ((= a 3) (progn
	       (quantum-toffoli l c-in c-out reg)
	       (quantum-cnot l c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-cnot b-in c-in reg)))
    ((= a 1) (progn
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-cnot b-in c-in reg)))
    ((= a 2) (progn
	       (quantum-sigma-x xlt-l reg)
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-cnot b-in c-in reg)
	       (quantum-sigma-x xlt-l reg)))
    (t nil)
    )

)
;-------------------------------------------------------------------------------
(defun muxfa-inv (a b-in c-in c-out xlt-l l total reg)

  (cond
    ((= a 0) (progn
	       (quantum-cnot b-in c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)))
    ((= a 3) (progn
	       (quantum-cnot b-in c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-cnot l c-in reg)
	       (quantum-toffoli l c-in c-out reg)))
    ((= a 1) (progn
	       (quantum-cnot b-in c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l b-in reg)))
    ((= a 2) (progn
	       (quantum-sigma-x xlt-l reg)
	       (quantum-cnot b-in c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l c-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-toffoli b-in c-in c-out reg)
	       (quantum-toffoli l xlt-l b-in reg)
	       (quantum-sigma-x xlt-l reg)))
    (t nil)
    )

)
;-------------------------------------------------------------------------------
(defun muxha-inv (a b-in c-in xlt-l l total reg)

  "the inverse of semi quantum-halfadder"
  
  (cond

   ((= a 0) (quantum-cnot b-in c-in reg))
   ((= a 3) (progn
              (quantum-cnot b-in c-in reg)
              (quantum-cnot l c-in reg)))
   ((= a 1) (progn
              (quantum-cnot b-in c-in reg)
              (quantum-toffoli l xlt-l c-in reg)))
   ((= a 2) (progn
              (quantum-sigma-x xlt-l reg)
              (quantum-cnot b-in c-in reg)
              (quantum-toffoli l xlt-l c-in reg)
              (quantum-sigma-x xlt-l reg)))
   (t nil)
   
))
;-------------------------------------------------------------------------------
(defun madd (a a-inv width reg)

(let (

  (total (+ 2 (* +num-regs+ width)))
  (j 0)
  )

  (loop for i from 0 below (1- width) do
    (if (/= (logand (ash 1 i) a) 0)
        (setq j (ash 1 1))
      (setq j 0))
    (if (/= (logand (ash 1 i) a-inv) 0)
        (muxfa j (+ i width) i (1+ i) (* 2 width) (1+ (* 2 width))
               total reg)))
  (setq j 0)

  (if (/= (logand (ash 1 (1- width)) a) 0)
	(setq j 2))
  (if (/= (logand (ash 1 (1- width)) a-inv) 0)
      (incf j))

  (muxha j (1- (* 2 width)) (1- width) (* 2 width) (1+ (* 2 width))
         total reg)

))
;-------------------------------------------------------------------------------
(defun madd-inv (a a-inv width reg)

(let (
  (total (+ 2 (* +num-regs+ width)))
  (j 0)
  )

  (setq j 0)

  (if (/= (logand (ash 1 (1- width)) a) 0)
      (setq j 2))
  (if (/= (logand (ash 1 (1- width)) a) 0)
      (incf j))

  (muxha-inv j (1- width) (1- (* 2 width)) (* 2 width) (1+ (* 2 width))
             total reg)

  (loop for i downfrom (- width 2) to 0 do
    (if (/= (logand (ash 1 i) a) 0)
        (setq j (ash 1 1))
      (setq j 0))
    (if (/= (logand (ash 1 i) a-inv) 0)
        (incf j))
    (muxfa-inv j i (+ i width) (+ i 1 width) (* 2 width) (1+ (* 2 width))
               total reg))

))
;-------------------------------------------------------------------------------
(defun addn (n a width reg)

  "Add a to register (reg) mod n"

  (test-sum (- n a) width reg)
  (madd (- (+ (ash 1 width) a) n) a width reg)

)
;-------------------------------------------------------------------------------
(defun addn-inv (n a width reg)

  (quantum-cnot (1+ (* 2 width)) (* 2 width) reg)
  (madd-inv (- (ash 1 width) a) (- n a) width reg)
  (quantum-swaptheleads width reg)

  (test-sum a width reg)
)
;-------------------------------------------------------------------------------
(defun add-mod-n (n a width reg)

  "add a to register reg (mod N) and clear the scratch bits"

  (addn n a width reg)
  (addn-inv n a width reg)

)
;-------------------------------------------------------------------------------
(defun test-sum (compare width reg)

  "if bit +compare+ - the global enable bit - is set, test_sums
   checks, if the sum of the c-number and the q-number in register
   add_sum is greater than n and sets the next lower bit to +compare+"

  (if (/= (logand compare (ash 1 (1- width))) 0)
      (progn
	(quantum-cnot (1- (* 2 width)) (1- width) reg)
	(quantum-sigma-x (1- (* 2 width)) reg)
	(quantum-cnot (1- (* 2 width)) 0 reg))
    (progn
      (quantum-sigma-x (1- (* 2 width)) reg)
      (quantum-cnot (1- (* 2 width)) (1- width) reg)))

  (loop for i downfrom (- width 2) to 1 do
    (if (/= (logand compare (ash 1 i)) 0)
        (progn
          (quantum-toffoli (1+ i) (+ i width) i reg)
          (quantum-sigma-x (+ i width) reg)
          (quantum-toffoli (1+ i) (+ i width) 0 reg))
      (progn
        (quantum-sigma-x (+ i width) reg)
        (quantum-toffoli (1+ i) (+ i width) i reg))))

  (if (/= (logand compare 1) 0)
      (progn
	(quantum-sigma-x width reg)
	(quantum-toffoli width 1 0 reg)))

  (quantum-toffoli (1+ (* 2 width)) 0 (* 2 width) reg)

  (if (/= (logand compare 1) 0)
      (progn
	(quantum-toffoli width 1 0 reg)
	(quantum-sigma-x width reg)))

  (loop for i from 1 to (- width 2) do
    (if (/= (logand compare (ash 1 i)) 0)
        (progn
          (quantum-toffoli (1+ i) (+ i width) 0 reg)
          (quantum-sigma-x (+ width i) reg)
          (quantum-toffoli (1+ i) (+ i width) i reg))
      (progn
        (quantum-toffoli (1+ i) (+ i width) i reg)
        (quantum-sigma-x (+ i width) reg))))

  (if (/= (logand compare (ash 1 (1- width))) 0)
      (progn
	(quantum-cnot (1- (* 2 width)) 0 reg)
	(quantum-sigma-x (1- (* 2 width)) reg)
	(quantum-cnot (1- (* 2 width)) (1- width) reg))
    (progn
      (quantum-cnot (1- (* 2 width)) (1- width) reg)
      (quantum-sigma-x (1- (* 2 width)) reg)))

  )
;-------------------------------------------------------------------------------
(defun quantum-exp-mod-n (n x width_input width reg)

(let (
  (f 0.0)
  )

  (quantum-sigma-x (+ 2 (* 2 width)) reg)

  (loop for i from 1 to width_input do
    (setq f (rem x n))

    (loop for j from 1 below i do
      (setq f (* f f))
      (setq f (rem f n)))
    (mul-mod-n n f (+ 1 i (* 3 width)) width reg)
    )

))
;-------------------------------------------------------------------------------

;;; end of modular arithmetic

;;; QUANTUM GATES

;-------------------------------------------------------------------------------
(defun quantum-gate1 (target m reg)

"Apply the 2x2 matrix M to the target bit. M should be unitary."

(let (

  (iset 0)
  (addsize 0)
  (decsize 0)
  (k 0)
  (j 0)
  (t2 #c(0.0 0.0))
  (tnot #c(0.0 0.0))
  (limit 0.0)
  (done (make-array 1 :element-type 'integer))
  )

  (if (/= (quantum-reg-hashw reg) 0)
      (progn
        (quantum-reconstruct-hash reg)

        (loop for i from 0 below (quantum-reg-size reg) do
          (if (= (quantum-get-state 
                  (logxor (aref (quantum-reg-state reg) i) (ash 1 target)) reg) 
                 (- 1))
              (setf addsize (1+ addsize))))

        (setf (quantum-reg-state     reg) 
              (adjust-array (quantum-reg-state reg) 
                            (+ (quantum-reg-size reg) addsize)))
        (setf (quantum-reg-amplitude reg) 
              (adjust-array (quantum-reg-amplitude reg) 
                            (+ (quantum-reg-size reg) addsize)))
        (loop for i from 0 below addsize do
          (setf (aref (quantum-reg-state     reg) (+ i (quantum-reg-size reg))) 0)
          (setf (aref (quantum-reg-amplitude reg) (+ i (quantum-reg-size reg))) 
                #c(0.0 0.0))))
    )


  (setq done (make-array (+ addsize (quantum-reg-size reg))
                         :element-type 'integer
                         :initial-element 0))
  (setq k (quantum-reg-size reg))
  (setq limit (* +epsilon+ (/ 1.0 (ash 1 (quantum-reg-width reg)))))

  (loop for i from 0 below (quantum-reg-size reg) do

    (block l1
      (if (= (aref done i) 0)
          (progn
            (setq iset (logand (aref (quantum-reg-state reg) i) (ash 1 target)))
            (setq tnot #c(0.0 0.0))
            (setq j (quantum-get-state 
                     (logxor (aref (quantum-reg-state reg) i) (ash 1 target)) reg))
            (if (>= j 0)
                (setf tnot (aref (quantum-reg-amplitude reg) j)))
            (setq t2 (aref (quantum-reg-amplitude reg) i))
            (if (/= iset 0)
                (setf (aref (quantum-reg-amplitude reg) i) 
                      (+ (* (aref (quantum-matrix-t1 m) 2) tnot)
                         (* (aref (quantum-matrix-t1 m) 3) t2)))
              (setf (aref (quantum-reg-amplitude reg) i)
                    (+ (* (aref (quantum-matrix-t1 m) 0) t2)
                       (* (aref (quantum-matrix-t1 m) 1) tnot))))
            (if (>= j 0)
                (progn
                  (if (/= iset 0)
                      (setf (aref (quantum-reg-amplitude reg) j)
                            (+ (* (aref (quantum-matrix-t1 m) 0) tnot)
                               (* (aref (quantum-matrix-t1 m) 1) t2)))
                    (setf (aref (quantum-reg-amplitude reg) j)
                          (+ (* (aref (quantum-matrix-t1 m) 2) t2)
                             (* (aref (quantum-matrix-t1 m) 3) tnot)))))
              (progn
                (if (and (= (aref (quantum-matrix-t1 m) 1) 0) 
                         (if (/= iset 0) 't 'nil)) ; && (iset)
                    (return-from l1))
                (if (and (= (aref (quantum-matrix-t1 m) 2) 0) 
                         (if (/= iset 0) 'nil 't)) ; && !(iset) 
                    (return-from l1))
                (setf (aref (quantum-reg-state reg) k) 
                      (logxor (aref (quantum-reg-state reg) i) (ash 1 target)))
                (if (/= iset 0)
                    (setf (aref (quantum-reg-amplitude reg) k) 
                          (* t2 (aref (quantum-matrix-t1 m) 1)))
                  (setf (aref (quantum-reg-amplitude reg) k) 
                        (* t2 (aref (quantum-matrix-t1 m) 2))))
                (setq k (1+ k))))
            (if (>= j 0)
                (setf (aref done j) 1))))))

  (setf (quantum-reg-size reg) (+ (quantum-reg-size reg) addsize))

  (if (/= (quantum-reg-hashw reg) 0)
      (progn
        (setq j 0)
        (loop for i from 0 below (quantum-reg-size reg) do
          ;;             (format t "giro HD: ~d, size reg: ~d~%" i (quantum-reg-size reg)) 
          (if (< (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)) limit)
              (progn
                (setq j (1+ j))
                (setq decsize (1+ decsize)))
            (if (/= j 0)
                (progn
                  (setf (aref (quantum-reg-state     reg) (- i j)) 
                        (aref (quantum-reg-state reg) i))
                  (setf (aref (quantum-reg-amplitude reg) (- i j)) 
                        (aref (quantum-reg-amplitude reg) i))))
            ))

        (if (/= decsize 0)
            (progn
              (setf (quantum-reg-size      reg) (- (quantum-reg-size reg) decsize))
              (setf (quantum-reg-amplitude reg) 
                    (adjust-array (quantum-reg-amplitude reg) (quantum-reg-size reg)))
              (setf (quantum-reg-state reg) 
                    (adjust-array (quantum-reg-state reg) (quantum-reg-size reg)))))
        )
    )

  (if (> (quantum-reg-size reg) (ash 1 (1- (quantum-reg-hashw reg))))
      (format t "Warning: inefficient hash table (size ~D vs hash ~D)~%"
              (quantum-reg-size reg) (ash 1 (quantum-reg-hashw reg))))

  (quantum-decohere reg)

))
;-------------------------------------------------------------------------------
(defun quantum-gate2 (target1 target2 m reg)

"Apply 4x4 matrix M to the bits TARGET1 TARGET2. M should be unitary. 
Warning: code mostly untested."

(let (
  (j 0)
  (l 0)
  (addsize 0)
  (decsize 0)

  (psi_sub (make-array 4 :element-type 'complex
                       :initial-element #c(0.0 0.0)))
  (base (make-array 4 :element-type 'integer
                    :initial-element 0))
  (limit 0.0)

  (bits (make-array 2 :element-type 'integer
                    :initial-element 0))
  (done (make-array * :element-type 'integer))
  )


  (loop for i from 0 below (ash 1 (quantum-reg-hashw reg)) do
    (setf (aref (quantum-reg-hash reg) i) 0))
  
  (loop for i from 0 below (quantum-reg-size reg) do
    (quantum-add-hash (aref (quantum-reg-state reg) i) i reg))
  
  (loop for i from 0 below (quantum-reg-size reg) do
    (if (= (quantum-get-state (logxor (aref (quantum-reg-state reg) i) 
                                      (ash 1 target1)) reg) (- 1))
        (incf addsize))
    (if (= (quantum-get-state (logxor (aref (quantum-reg-state reg) i) 
                                      (ash 1 target2)) reg) (- 1))
        (incf addsize)))

  (setf (quantum-reg-state reg)     (adjust-array (quantum-reg-state reg) 
                                                  (+ (quantum-reg-size reg) addsize)))
  (setf (quantum-reg-amplitude reg) (adjust-array (quantum-reg-amplitude reg) 
                                                  (+ (quantum-reg-size reg) addsize)))

  (loop for i from 0 below addsize do
    (setf (aref (quantum-reg-state     reg) (+ i (quantum-reg-size reg))) 0)
    (setf (aref (quantum-reg-amplitude reg) (+ i (quantum-reg-size reg))) 
          #c(0.0 0.0)))

  (setq done (make-array (+ addsize (quantum-reg-size reg))
                         :element-type 'integer
                         :initial-element 0))
  (setq l (quantum-reg-size reg))
  (setq limit (/ (/ 1.0 (ash 1 (quantum-reg-width reg))) 1000000))
  (setf (aref bits 0) target1)
  (setf (aref bits 1) target2)

  (loop for i from 0 below (quantum-reg-size reg) do

    (if (= (aref done i) 0)
        (progn
          (setq j (quantum-bitmask (aref (quantum-reg-state reg) i) 2 bits))
          (setf (aref base j) i)
          (setf (aref base (logxor j 1)) 
                (quantum-get-state (logxor (aref (quantum-reg-state reg) i) 
                                           (ash 1 target2)) reg))
          (setf (aref base (logxor j 2)) 
                (quantum-get-state (logxor (aref (quantum-reg-state reg) i) 
                                           (ash 1 target1)) reg))
          (setf (aref base (logxor j 3)) 
                (quantum-get-state (logxor (logxor (aref (quantum-reg-state reg) i)
                                                   (ash 1 target1))
                                           (ash 1 target2)) reg))
          
          (loop for j from 0 below 4 do
            (if (= (aref base j) -1)
                (progn
                  (setf (aref base j) l)
                  (incf l)))
            (setf (aref psi_sub j) (aref (quantum-reg-amplitude reg) (aref base j))))
          
          (loop for j from 0 below 4 do
            (setf (aref (quantum-reg-amplitude reg) (aref base j)) #c(0.0 0.0))
            (loop for k from 0 below 4 do
              (setf (aref (quantum-reg-amplitude reg) (aref base j)) 
                    (+ (aref (quantum-reg-amplitude reg) (aref base j))
                       (* (M m k j) (aref psi_sub k)))))
            (setf (aref done (aref base j)) 1))
          )))

  (incf (quantum-reg-size reg) addsize)
  
  (setq j 0)

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (< (quantum-prob-inline (aref (quantum-reg-amplitude reg) i)) limit)
        (progn
          (incf j)
          (incf decsize))
      (if (/= j 0)
          (progn
            (setf (aref (quantum-reg-state     reg) (- i j)) 
                  (aref (quantum-reg-state     reg) i))
            (setf (aref (quantum-reg-amplitude reg) (- i j)) 
                  (aref (quantum-reg-amplitude reg) i)))))
    )

  (if (/= decsize 0)
      (progn
        (decf (quantum-reg-size reg) decsize)
        (setf (quantum-reg-amplitude reg) 
              (adjust-array (quantum-reg-amplitude reg) (quantum-reg-size reg)))
        (setf (quantum-reg-state reg) 
              (adjust-array (quantum-reg-state reg) (quantum-reg-size reg)))))

  (quantum-decohere reg)

))
;-------------------------------------------------------------------------------
(defun quantum-gate-counter (inc)

"Increase the gate counter by INC steps or reset it if INC < 0. 
The current value is returned"

  (if (>= inc 0)
      (incf global-gate-counter inc)
      (setq global-gate-counter 0))

  global-gate-counter

)
;-------------------------------------------------------------------------------
(defun quantum-cnot (control target reg)

"Apply a controlled-not gate"

(let (
  (qec 0)
  )

  (quantum-qec-get-status qec)

  (if (/= qec 0)
      (quantum-cnot-ft control target reg)
    (progn
      (if (quantum-objcode-put +CNOT+ control target)
          (return-from quantum-cnot))
      (loop for i from 0 below (quantum-reg-size reg) do
        (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control)) 0)
            (setf (aref (quantum-reg-state reg) i) 
                  (logxor (aref (quantum-reg-state reg) i) (ash 1 target)))))
      (quantum-decohere reg)))

))
;-------------------------------------------------------------------------------
(defun quantum-toffoli (control1 control2 target reg)

"Apply a toffoli (controlled-controlled-cnot) gate"

(let (
  (qec 0)
  )

  (quantum-qec-get-status qec)

  (if (/= qec 0)
      (quantum-toffoli-ft control1 control2 target reg)

    (progn
      (if (quantum-objcode-put +TOFFOLI+ control1 control2 target)
          (return-from quantum-toffoli))

      (loop for i from 0 below (quantum-reg-size reg) do
        (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control1)) 0)
        (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control2)) 0)
            (setf (aref (quantum-reg-state reg) i) 
                  (logxor (aref (quantum-reg-state reg) i) (ash 1 target))))))

      (quantum-decohere reg))
    )

))
;-------------------------------------------------------------------------------
(defun quantum-sigma-x (target reg)

"Apply a sigma-x (or not) gate"
(let (
  (qec 0)
  )

  (quantum-qec-get-status qec)
  
  (if (/= qec 0)
      (quantum-sigma-x-ft target reg)
    
    (progn
      (if (quantum-objcode-put +SIGMA-X+ target)
          (return-from quantum-sigma-x))
      
      (loop for i from 0 below (quantum-reg-size reg) do
        (setf (aref (quantum-reg-state reg) i) 
              (logxor (aref (quantum-reg-state reg) i) (ash 1 target))))
      
      (quantum-decohere reg))
    )

))
;-------------------------------------------------------------------------------
(defun quantum-sigma-y (target reg)

  "Apply a sigma-y gate"

  (if (quantum-objcode-put +SIGMA-Y+ target)
      (return-from quantum-sigma-y))

  (loop for i from 0 below (quantum-reg-size reg) do
    (setf (aref (quantum-reg-state reg) i) 
          (logxor (aref (quantum-reg-state reg) i) (ash 1 target)))
    
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 target)) 
            0)

        (setf (aref (quantum-reg-amplitude reg) i) 
              (* (aref (quantum-reg-amplitude reg) i)    #c(0.0 1.0)))
        (setf (aref (quantum-reg-amplitude reg) i) 
              (* (aref (quantum-reg-amplitude reg) i) (- #c(0.0 1.0))))
        ))
  
  (quantum-decohere reg)

  )
;-------------------------------------------------------------------------------
(defun quantum-sigma-z (target reg)

  "Apply a sigma-z gate"

  (if (quantum-objcode-put +SIGMA-Z+ target)
      (return-from quantum-sigma-z))

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 target)) 
            0)
        (setf (aref (quantum-reg-amplitude reg) i) 
              (* (aref (quantum-reg-amplitude reg) i) (- 1)))))

  (quantum-decohere reg)

)
;-------------------------------------------------------------------------------
(defun quantum-swaptheleads (width reg)

"Swap the first WIDTH bits of the quantum register. This is done
 classically by renaming the bits, unless QEC is enabled."

(let (
  (qec 0)
  (pat1 0)
  (pat2 0)
  (l 0)
  )

  (quantum-qec-get-status qec)

  (if (/= qec 0)
      (loop for i from 0 below width do
        (quantum-cnot i (+ width i) reg)
        (quantum-cnot (+ width i) i reg)
        (quantum-cnot i (+ width i) reg))

    (loop for i from 0 below (quantum-reg-size reg) do
      (if (quantum-objcode-put +SWAPLEADS+ width)
          (return-from quantum-swaptheleads))
      (setq pat1 (rem (aref (quantum-reg-state reg) i) (ash 1 width)))
      (setq pat2 0)
      (loop for j from 0 below width do
        (incf pat2 (logand (aref (quantum-reg-state reg) i) (ash 1 (+ width j)))))
      (setq l (- (aref (quantum-reg-state reg) i) (+ pat1 pat2)))
      (incf l (ash pat1 width))
      (incf l (ash pat2 (- width)))
      (setf (aref (quantum-reg-state reg) i) l))
    )

))
;-------------------------------------------------------------------------------
(defun quantum-swaptheleads-omuln-controlled (control width reg)

  "Swap WIDTH bits starting at WIDTH and 2*WIDTH+2 controlled by
   CONTROL"

  (loop for i from 0 below width do
    (quantum-toffoli control (+ width i) (+ (* 2 width) i 2) reg)
    (quantum-toffoli control (+ (* 2 width) i 2) (+ i width) reg)
    (quantum-toffoli control (+ i width) (+ (* 2 width) i 2) reg))

)
;-------------------------------------------------------------------------------
(defun quantum-hadamard (target reg)

  "Apply a hadamard gate"

  (let ((m (quantum-new-matrix 2 2)))
    (if (quantum-objcode-put +HADAMARD+ target)
        (return-from quantum-hadamard))
    (setf (aref (quantum-matrix-t1 m) 0) (sqrt (/ 1.0 2.0)))
    (setf (aref (quantum-matrix-t1 m) 1) (sqrt (/ 1.0 2.0)))
    (setf (aref (quantum-matrix-t1 m) 2) (sqrt (/ 1.0 2.0)))
    (setf (aref (quantum-matrix-t1 m) 3) (- (sqrt (/ 1.0 2.0))))
    (quantum-gate1 target m reg)
    )

)
;-------------------------------------------------------------------------------
(defun quantum-walsh (width reg)

  "Apply a walsh-hadamard transform"

  (loop for i from 0 below width do
    (quantum-hadamard i reg))

)
;-------------------------------------------------------------------------------
(defun quantum-r-x (target gamma reg)

"Apply a rotation about the x-axis by the angle GAMMA"

(let (
  (m (quantum-new-matrix 2 2))
  )

  (if (quantum-objcode-put +ROT-X+ target gamma)
      (return-from quantum-r-x))

  (setf (aref (quantum-matrix-t1 m) 0) (complex (cos (/ gamma 2)) 0.0))
  (setf (aref (quantum-matrix-t1 m) 1) (complex 0.0 (- (sin (/ gamma 2)))))
  (setf (aref (quantum-matrix-t1 m) 2) (complex 0.0 (- (sin (/ gamma 2)))))
  (setf (aref (quantum-matrix-t1 m) 3) (complex (cos (/ gamma 2)) 0.0))

  (quantum-gate1 target m reg)

))
;-------------------------------------------------------------------------------
(defun quantum-r-y (target gamma reg)

"Apply a rotation about the y-axis by the angle GAMMA"

(let (
  (m (quantum-new-matrix 2 2))
  )

  (if (quantum-objcode-put +ROT-Y+ target gamma)
      (return-from quantum-r-y))

  (setf (aref (quantum-matrix-t1 m) 0) (complex (cos (/ gamma 2)) 0.0))
  (setf (aref (quantum-matrix-t1 m) 1) (complex (- (sin (/ gamma 2))) 0.0))
  (setf (aref (quantum-matrix-t1 m) 2) (complex (sin (/ gamma 2)) 0.0))
  (setf (aref (quantum-matrix-t1 m) 3) (complex (cos (/ gamma 2)) 0.0))

  (quantum-gate1 target m reg)

))
;-------------------------------------------------------------------------------
(defun quantum-r-z (target gamma reg)

"Apply a rotation about the z-axis by the angle GAMMA"

(let (
  (z #c(0.0 0.0))
  )

  (if (quantum-objcode-put +ROT-Z+ target gamma)
      (return-from quantum-r-z))

  (setq z (quantum-cexp (/ gamma 2)))

  (loop for i from 0 below (quantum-reg-size reg) do
    (progn

      (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 target)) 
              0)
          (setf (aref (quantum-reg-amplitude reg) i) 
                (* (aref (quantum-reg-amplitude reg) i) z))
          (setf (aref (quantum-reg-amplitude reg) i) 
                (/ (aref (quantum-reg-amplitude reg) i) z)))
      ))
  
  (quantum-decohere reg)

))
;-------------------------------------------------------------------------------
(defun quantum-phase-scale (target gamma reg)

"Scale the phase of qubit"

(let (
  (z #c(0.0 0.0))
  )

  (if (quantum-objcode-put +PHASE-SCALE+ target gamma)
      (return-from quantum-phase-scale))

  (setq z (quantum-cexp gamma))

  (loop for i from 0 below (quantum-reg-size reg) do
    (setf (aref (quantum-reg-amplitude reg) i) 
          (* (aref (quantum-reg-amplitude reg) i) z)))

  (quantum-decohere reg)
))
;-------------------------------------------------------------------------------
(defun quantum-phase-kick (target gamma reg)

"Apply a phase kick by the angle GAMMA"

(let (
  (z #c(0.0 0.0))
  )

  (if (quantum-objcode-put +PHASE-KICK+ target gamma)
      (return-from quantum-phase-kick))

  (setq z (quantum-cexp gamma))

  (loop for i from 0 below (quantum-reg-size reg) do
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 target)) 
            0)
        (setf (aref (quantum-reg-amplitude reg) i) 
              (* (aref (quantum-reg-amplitude reg) i) z))))

  (quantum-decohere reg)

))
;-------------------------------------------------------------------------------
(defun quantum-cond-phase (control target reg)

"Apply a conditional phase shift by PI / 2^(CONTROL - TARGET)"

(let (
  (z #c(0.0 0.0))
  )

  (if (quantum-objcode-put +COND-PHASE+ control target)
      (return-from quantum-cond-phase))

  (setq z (quantum-cexp (/ pi (ash 1 (- control target)))))

  (loop for i from 0 below (quantum-reg-size reg) do

    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control)) 0)
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1  target)) 0)
        (setf (aref (quantum-reg-amplitude reg) i) 
              (* (aref (quantum-reg-amplitude reg) i) z))
      )))

  (quantum-decohere reg)

))
;-------------------------------------------------------------------------------
(defun quantum-cond-phase-inv (control target reg)

(let (
  (z #c(0.0 0.0))
  )

  (setq z (quantum-cexp (/ (- pi) (ash 1 (- control target)))))

  (loop for i from 0 below (quantum-reg-size reg) do

    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control)) 0)
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1  target)) 0)
            (setf (aref (quantum-reg-amplitude reg) i) 
                  (* (aref (quantum-reg-amplitude reg) i) z)))))

  (quantum-decohere reg)
))
;-------------------------------------------------------------------------------
(defun quantum-cond-phase-kick (control target gamma reg)

"Apply a conditional phase shift by PI / 2^(CONTROL - TARGET)"

(let (
  (z #c(0.0 0.0))
  )

  (if (quantum-objcode-put +CPHASE-KICK+ control target)
      (return-from quantum-cond-phase-kick))

  (setq z (quantum-cexp gamma))

  (loop for i from 0 below (quantum-reg-size reg) do

    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1 control)) 0)
    (if (/= (logand (aref (quantum-reg-state reg) i) (ash 1  target)) 0)
            (setf (aref (quantum-reg-amplitude reg) i) 
                  (* (aref (quantum-reg-amplitude reg) i) z)))))
  
  (quantum-decohere reg)
))
;-------------------------------------------------------------------------------

;;; end of quantum gates
;-------------------------------------------------------------------------------
(defun quantum-qft (width reg)

  "Perform a QFT on a quantum register. This is done by application of
   conditional phase shifts and hadamard gates. At the end, the
   position of the bits is reversed."

  (quantum-print-qureg reg)

  (format t "reg letto da qft~%")

  (loop for i downfrom (1- width) to      0 do
  (loop for j downfrom (1- width) to (1+ i) do

    ;;          (quantum-print-qureg reg)
    (format t "loop j: ~d in i:~d~%" j i)
    (quantum-cond-phase j i reg))
  
    (quantum-hadamard i reg)
    )
)
;-------------------------------------------------------------------------------
(defun quantum-qft-inv (width reg)

  "Perform an inverse QFT"

  (loop for i from 0 below width do

    (quantum-hadamard i reg)

    (loop for j from (1+ i) below width do
      (quantum-cond-phase j i reg))
    )

)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
