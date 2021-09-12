; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;Installing:


  ;; all scripts in common/co-com/ext/basg-gena  must be in $PATH

  ;; ~/common-lisp -> L/common-lisp (for L-library)

;-------------------------------------------------------------------------------


(defpackage :co-com-asd
  (:use :cl :asdf))

(in-package :co-com-asd)

;-------------------------------------------------------------------------------
;WARNING: Your ASDF component is using encoding :KOI8-R but it isn't recognized. Your
;         system should :defsystem-depends-on (:asdf-encodings).
;         Continue using :external-format :default

;(defsystem "co-com"
(defsystem "pkgcocom"
  :default-component-class cl-source-file.cl 
  :defsystem-depends-on    (:asdf-encodings)

  :name     "CO-COM"
  :version  "0.0.1"
  :author   "Gennady Mordvinov"
  :licence  "LGPL"

  :description      "CO-COM"
  :long-description "Misc Lisp functions and utilitys"

  ;;:encoding :koi8-r  ;;  ??? 

  ;;*** - Error while trying to load definition for system gm-com from pathname
  ;;      /home/pilot/.MGENA/s/step_4/compot/gm-com/src/gm-com.asd:
  ;;      SYSTEM::LINE-COMMENT-READER: Invalid byte sequence #xC1 #xD7 in
  ;;      CHARSET:UTF-8 conversion
  
  :components (
               ;;(:encoding :koi8-r)

               (:file "a-comm")
               (:file "a-comp")

               (:file "a-plot") ; for VISG

;               (:static-file "a-comm.cl")
;               (:static-file "a-comp.cl")
               )
  )

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
