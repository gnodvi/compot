; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------


(defpackage #:bnets-asd

  (:use :cl :asdf))

(in-package :bnets-asd)

;-------------------------------------------------------------------------------
;WARNING: Your ASDF component is using encoding :KOI8-R but it isn't recognized. Your
;         system should :defsystem-depends-on (:asdf-encodings).
;         Continue using :external-format :default

(defsystem bnets
  :default-component-class cl-source-file.cl 
  :defsystem-depends-on    (:asdf-encodings)

  :name     "ORIG1"
  :version  "0.0.1"
  :author   "Gennady Mordvinov"
  :licence  "LGPL"

  ;; :depends-on ("command-line-arguments")
  ;; :depends-on ("unix-opts")

  :description      "ORIG1"
  :long-description "Misc Lisp functions and utilitys"

  ;;:encoding :koi8-r  ;;  ??? 

  ;;*** - Error while trying to load definition for system gm-com from pathname
  ;;      /home/pilot/.MGENA/s/step_4/compot/gm-com/src/gm-com.asd:
  ;;      SYSTEM::LINE-COMMENT-READER: Invalid byte sequence #xC1 #xD7 in
  ;;      CHARSET:UTF-8 conversion
  
  :components (
               ;;(:encoding :koi8-r)

               (:file "b-graf")
               (:file "b-nets")

;               (:file "t_meta")

;               (:file "b-plot") ; for VISG
;               (:static-file "a-comm.cl")
;               (:static-file "a-comp.cl")
               )
  )

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
