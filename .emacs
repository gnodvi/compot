;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

;; Problems
;; summary: cmd.exe can’t deal with cygwin ‘links’.

;; ‘shell-file-name’ defaults to cmdproxy.exe - which simply prepends “/c “ to the
;; args and sends that to cmd.exe or command.com (NT, 9x). But cmd.exe doesn’t
;; understand cygwin links, so the call to any such program fails - sometimes
;; silently. For instance: with my setup, gunzip.exe fails with Emacs reporting
;; “(Shell command succeeded with no output)”.

;; Poking around, I found Cygwin’s gunzip.exe is 19 bytes long. The contents are:
;; “!<symlink>gzip.exe” (with a trailing ^@).

;; to fix this, either copy gzip.exe to gunzip.exe, or use “bash” as your
;; ‘shell-file-name’

;;-------------------------------------------------------------------------------

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(blink-cursor-mode nil)
 '(column-number-mode t)
 '(compilation-window-height 13)
 '(display-time-mode t)
 '(fringe-mode 4 nil (fringe))
 '(inhibit-startup-screen t)
 '(safe-local-variable-values
   (quote
    ((c-file-style_OLD . "linux")
     (indent-tabs-mode_OLD . t)
     (version-control_OLD . t))))
 '(save-place t nil (saveplace))
 '(search-highlight nil)
 '(show-paren-mode t)
 '(tabbar-separator (quote (0.5))))

(setq make-pointer-invisible nil)

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(cua-mode t)

(setq cua-auto-tabify-rectangles nil) ;; Don't tabify after rectangle commands
(transient-mark-mode 1)               ;; No region when it is not highlighted
(setq cua-keep-region-after-copy t)   ;; Standard Windows behaviour

;;-------------------------------------------------------------------------------
   
;;(setq x-pointer-shape x-pointer-top-left-arrow) ;??? Symbol's value as variable is void: x-pointer-top-left-arrow
;(setq lazy-highlight-cleanup nil) ; оставляет подстветку

;;-------------------------------------------------------------------------------

(if (eq system-type 'gnu/linux)
    (progn
      (setq UEMACS    (getenv "UEMACS"))
      (add-to-list 'load-path  (concat (file-name-as-directory UEMACS) "/P"))
      (setq backup-directory-alist '(("" . (concat (file-name-as-directory UEMACS) "/T")))) 
    )
  )

(if (eq system-type 'windows-nt)

    (progn
      ;; (setq EMACS_DIR    (getenv "HOME"))
      ;; (add-to-list 'load-path  EMACS_DIR)
      (add-to-list 'load-path  "~/P")
      
      ;; backup in one place. flat, no tree structure
      ;;
      (setq backup-directory-alist '(("" . "~/T")))      
    )
  )


;;-------------------------------------------------------------------------------

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

;; Since your backups are all in their own place now, you might want more of them,
;; rather than less of them. Have a look at the Emacs documentation for these
;; variables (with C-h v).

;; (setq delete-old-versions t
;;   kept-new-versions 6
;;   kept-old-versions 2
;;   version-control t)

;; Finally, if you absolutely must have no backup files:

(setq make-backup-files nil)

;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(defun my_find_file_init_main () (interactive)

;;  (find-file "~/.emacs.d/_EMACS/.emacs")
    (find-file  (concat UEMACS "/.emacs"))
;;  (find-file  "~/.emacs")

;(message "EMACS_DIR= %s EMACS_DIR_T= %s " EMACS_DIR  EMACS_DIR_T)
       
)

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

;;==============================================================================
;;                                   COMPILE                                    
;;==============================================================================

;; (if my-is-unix 
;;   (setenv "MAKE_MODE" "UNIX")
;;   (setq-default compile-command "make")  
;; ; (setq-default compile-command "nmake -k -nologo")  
;; ; (setq-default compile-command "nmake -nologo")  
;; )
;; ;----------------------------------------

(defun my_save_buffers ()  (interactive)
       
  (save-some-buffers t)  
)  

;----------------------------------------
(defun my_compile_make ()  
  (interactive)  

  (if (file-exists-p "Make.new")
      (compile "LANG=C make -f Make.new all") 
      (compile "LANG=C make             all") 
      )
)  
;----------------------------------------
(defun my_compile_test ()  
  (interactive)  

  (if (file-exists-p "Make.new")
      (compile "LANG=C make -f Make.new test") 
      (compile "LANG=C make             test") 
      )
)  
;----------------------------------------
(defun my_compile_clean ()  
  (interactive)  

  (if (file-exists-p "Make.new")
      (compile "LANG=C make -f Make.new clean") 
      (compile "LANG=C make             clean") 
      )
)  
;; ;----------------------------------------
(defun my_save_and_build ()  
  (interactive)  
  (save-some-buffers t)  

  ;(compile "make -k all") 
  (my_compile_make)  
)  

(defun my_make_test ()  
  (interactive)  
  (save-some-buffers t)  

  (my_compile_test)  
)  

;; (defun my_save_and_build_new ()  
;;   (interactive)  
;;   (save-some-buffers t)  
;;   (compile "make -f Make.new all") 
;; )  

;; ;----------------------------------------
(defun my_clean ()
  (interactive)     
  (save-some-buffers t)
  
  ;(compile "make -k clean") 
  (my_compile_clean)  
)  

;; (defun my_clean_new ()  (interactive)      
;;   (save-some-buffers t)  
;;   (compile "make -f Make.new clean") 
;; )  

;; ;---------------------------------------------------
;; ; 2004-12-28 
;; (require 'compile) 

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(defun set_my_vbs () (interactive)

  (autoload 'visual-basic-mode "visual-basic-mode" "Visual Basic mode." t)
  (setq auto-mode-alist (append '(("\\.\\(vbs\\|bas\\|cls\\)$" .
					visual-basic-mode)) auto-mode-alist))

)

(set_my_vbs)  

;;-------------------------------------------------------------------------------
;---------------------------------------------------
; BASH bash Bash

(setq sh-basic-offset 2)

;;-------------------------------------------------------------------------------

(require 'julia-mode)

;(defcustom julia-indent-offset 2
;  "Number of spaces per indentation level."
;  :type 'integer
;  :group 'julia)

;-------------------------------------------------------------------------------

;(set-specifier scrollbar-width 50)
;
;Symbol's function definition is void: set-specifier
;(scroll-bar-width . 15) 
;(setq scroll-bar-width 65) ; ?????
; (set-face-background 'scroll-bar "red")

(setq default-frame-alist
      '(
;        (background-color . "red")
;;        (foreground-color . "white")
        (scroll-bar-foreground-color . "yellow")
        (scroll-bar-background-color . "red")
	
;;        (vertical-scroll-bars . right)
        (scroll-bar-width . 30)
;;        (top . 20)
;;        (left . 10)
;;        (width . 140)
;;        ;;			    (height . 50) ;; for laptop
;;        (mouse-color . "yellow")
;        (cursor-color . "red")
        )
)

(set-scroll-bar-mode 'right)

;(set-face-background 'scroll-bar "bisque")
(set-face-foreground 'scroll-bar "blue")
(set-face-background 'scroll-bar "darkgrey")

;Here's a recap of how to use resources to change your scrollbar colors:

;! Motif scrollbars

;Emacs*XmScrollBar.Background: skyblue
;Emacs*XmScrollBar.troughColor: lightgray

;! Athena scrollbars

;Emacs*Scrollbar.Foreground: skyblue
;Emacs*Scrollbar.Background: lightgray

;-------------------------------------------------------------------------------
;----------------------------------------
(defun my_comment ()  
 ;
 (interactive)  
 (comment-region (region-beginning) (region-end) '(0))  
)  
;----------------------------------------
(defun my_uncomment ()  
 (interactive)  
 (comment-region (region-beginning) (region-end) '(4))  
)  
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

(defun set_my_tcltk () (interactive)

  (autoload 'tcl-mode "tcl" "Tcl mode." t) ;; ??? ÎÅ ÒÁÂÏÔÁÅÔ ??
  
  (setq auto-mode-alist (append '(("\\.ns$" . tcl-mode)) auto-mode-alist))
  (setq auto-mode-alist (append '(("\\.tl$" . tcl-mode)) auto-mode-alist))
  (setq auto-mode-alist (append '(("\\.tk$" . tcl-mode)) auto-mode-alist))
  (setq auto-mode-alist (append '(("\\.ex$" . tcl-mode)) auto-mode-alist))
  
  (setq tcl-indent-level 2) 
  (setq tcl-continued-indent-level 2) 
  
)

(set_my_tcltk) 

;-------------------------------------------------------------------------------

(defun set_my_lua () (interactive)

;### MANUAL INSTALLATION
;;;;
;;  To install, you need to make sure that `lua-mode.el` is on your load-path
;;(and optionally byte-compile it) and to set up Emacs to automatically enable
;; **lua-mode** for `*.lua` files or ones that contain lua
;; hash-bang line (`#!/usr/bin/lua`). Putting this snippet to `.emacs` should be enough in most cases:
;;```lisp

  ;;;; This snippet enables lua-mode

  ;; This line is not necessary, if lua-mode.el is already on your load-path
  ;;(add-to-list 'load-path "/path/to/directory/where/lua-mode-el/resides")

  (autoload 'lua-mode "lua-mode" "Lua editing mode." t)
  (add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
  (add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

)

(set_my_lua) 

;;-------------------------------------------------------------------------------
;; https://gist.github.com/3demax/1264635
;;-------------------------------------------------------------------------------
(defun set_3demax_tabbar_tweak () (interactive)


  ;; This are setting for nice tabbar items
  ;; to have an idea of what it looks like http://imgur.com/b0SNN
  ;; inspired by Amit Patel screenshot http://www.emacswiki.org/pics/static/NyanModeWithCustomBackground.png

  ;; Tabbar
  (require 'tabbar)
       
  ;; Tabbar settings
  
(set-face-attribute
 'tabbar-default nil
 :background "gray20"
 :foreground "gray20"
 :box '(:line-width 1 :color "gray20" :style nil))

(set-face-attribute
 'tabbar-unselected nil
 :background "gray30"
 :foreground "white"
 :box '(:line-width 5 :color "gray30" :style nil))

(set-face-attribute
 'tabbar-selected nil
 :background "gray75"
 :foreground "black"
 :box '(:line-width 5 :color "gray75" :style nil))

(set-face-attribute
 'tabbar-highlight nil
 :background "white"
 :foreground "black"
 :underline nil
 :box '(:line-width 5 :color "white" :style nil))

(set-face-attribute
 'tabbar-button nil
 :box '(:line-width 1 :color "gray20" :style nil))

(set-face-attribute
 'tabbar-separator nil
 :background "gray20"
 :height 0.6)

;; Change padding of the tabs
;; we also need to set separator to avoid overlapping tabs by highlighted tabs
(custom-set-variables
 '(tabbar-separator (quote (0.5))))

;; adding spaces
(defun tabbar-buffer-tab-label (tab)
  "Return a label for TAB.
That is, a string used to represent it on the tab bar."
  (let ((label  (if tabbar--buffer-show-groups
                    (format "[%s]  " (tabbar-tab-tabset tab))
                  (format "%s  " (tabbar-tab-value tab)))))
    ;; Unless the tab bar auto scrolls to keep the selected tab
    ;; visible, shorten the tab label to keep as many tabs as possible
    ;; in the visible area of the tab bar.
    (if tabbar-auto-scroll-flag
        label
      (tabbar-shorten
       label (max 1 (/ (window-width)
                       (length (tabbar-view
                                (tabbar-current-tabset)))))))))

(tabbar-mode 1)

)
;-------------------------------------------------------------------------------

(defun set_my_tabbar () (interactive)

  ;; (require 'tabbar)
  ;; (tabbar-mode)
  
  (setq tabbar-buffer-groups-function
        (lambda ()
          (list "All Buffers")))
  
  (setq tabbar-buffer-list-function
        (lambda ()
          (remove-if
           (lambda(buffer)
             (find (aref (buffer-name buffer) 0) " *"))
           (buffer-list))))

       
  (set_3demax_tabbar_tweak)

  ;; https://www.emacswiki.org/emacs/TabBarMode
  ;; Tab navigation made easy

  ;; You can define keystrokes for navigating among the tabs of one tab group. Here
  ;; we use the meta-right-arrow and meta-left-arrow keystrokes. (These keys normally
  ;; bind to functions right-word and left-word, which are also bound to
  ;; ctrl-right-arrow and ctrl-left-arrow, so we’re not losing convenience.)

  (global-set-key [(control left)]   'tabbar-backward-tab)
  (global-set-key [(control right)]  'tabbar-forward-tab)

)
;;-------------------------------------------------------------------------------

(set_my_tabbar)


;;-------------------------------------------------------------------------------

;; (setq tab-width 2) ; or any other preferred value
;; (defvaralias 'c-basic-offset      'tab-width)
;; (defvaralias 'cperl-indent-level  'tab-width)

;(setq-default tab-width 2)

;;-------------------------------------------------------------------------------
; https://www.emacswiki.org/emacs/GnuEmacsRussification
;-------------------------------------------------------------------------------

(defun set_my_koi8 () (interactive)

  ;; set language environment
   (set-language-environment 'Cyrillic-KOI8)

   ;; set encoding by default for files, bufers and outside programms changing
       
   (setq default-buffer-file-coding-system 'koi8-r)
   (prefer-coding-system                   'koi8-r)
       
   (define-coding-system-alias             'koi8-u 'koi8-r)
   
   (set-terminal-coding-system             'koi8-r)
   (set-keyboard-coding-system             'koi8-r)
   (setq-default coding-system-for-read    'koi8-r)
   (setq-default coding-system-for-write   'koi8-r)
   (setq selection-coding-system           'koi8-r)
   ;;(setq default-process-coding-system
   ;;   (if (string> (substring emacs-version 0 2) "21") '(koi8-r . koi8-r) 'koi8-r))
       
   (put-charset-property 'cyrillic-iso8859-5 'preferred-coding-system 'koi8-r)
       
   ;; for russian coding in  MS-Windows
       
   ;;(codepage-setup 1251)  
   ;;(define-coding-system-alias 'windows-1251 'cp1251)
   ;;(define-coding-system-alias 'win-1251 'cp1251)
   ;;(set-input-mode nil nil 'We-will-use-eighth-bit-of-input-byte)      
   )

;(set_my_koi8) 

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------
;; 
;;-------------------------------------------------------------------------------

(defun my_cut_select ()  (interactive)

  (if mark-active  
      (kill-region (region-beginning) (region-end))  
      (kill-whole-line)
      )
) 

;;----------------------------------------
;; Pull from PRIMARY (same as middle mouse click)

(defun get-primary ()
  (interactive)
  (insert
   (gui-get-primary-selection)))

;;(global-set-key "\C-c\C-y" 'get-primary)

;;----------------------------------------
; Every time you select a piece of text with the mouse, the selected text
; is set as the PRIMARY selection. 

(defun my_paste_from_primary ()  (interactive)
       
 ;(mouse-yank-primary)
 (get-primary)

) 
;----------------------------------------

(defun my_delete_line ()  (interactive) 
 
 ;(beginning-of-line)  
 (move-beginning-of-line 1)
 
 ;(kill-line) 
 (kill-whole-line)
 ;(kill-entire-line) - ÎÅ ÒÁÂÏÔÁÅÔ
)  
;;-------------------------------------------------------------------------------

(defun set_my_keys () (interactive)

  (global-set-key (kbd "<f1>")    'my_find_file_init_main)  
  (global-set-key (kbd "<f2>")    'my_save_buffers) 
  (global-set-key (kbd "<f3>")    'dired); switch file
  
  (global-set-key (kbd "<f8>")    'kill-this-buffer)  
  
  (global-set-key  (kbd "<f9>")   'my_clean)
  ;; (global-set-key  (kbd "<C-f9>") 'my_clean_new)
  
  (global-set-key  (kbd "<f10>")  'previous-error)  
  (global-set-key  (kbd "<f11>")  'next-error)
  
  (global-set-key  (kbd   "<f12>")  'my_save_and_build)
  ;;(global-set-key  (kbd "<C-f12>")  'my_save_and_build_new) ; QNX projects
  (global-set-key  (kbd "<C-f12>")  'my_make_test) ; QNX projects
  
  
  (global-set-key "\M-1" 'comment-region)
  (global-set-key "\M-`" 'my_uncomment)
  (global-set-key "\M-2" 'my_uncomment); ÄÌÑ AstraLinux
  
  
  ;; Killing text
  ;;(global-set-key (kbd "C-S-k") 'kill-and-retry-line)
  ;;(global-set-key (kbd "C-w") 'kill-region-or-backward-word)
  ;;(global-set-key (kbd "C-c C-w") 'kill-to-beginning-of-line)


  ;;(global-set-key (kbd "S-<insert>") 'my_paste_from_primary)
  ;; space SpaceT 

  ;;(global-set-key "\M-b" 'my_paste_from_primary)  ; ??
  ;;(global-set-key "\S-SPC" 'my_paste_from_primary)  ; ??
  ;; No known previous replacement ???????????????????
  (global-set-key (kbd "S-SPC") 'my_paste_from_primary) ; Shift-Space !!!

  (global-set-key "\M-d" 'my_cut_select)  
  (global-set-key "\C-d" 'my_delete_line)
  
  ;;(global-set-key "\M-f" 'my_delete_line)

  ;; ;(defun duplicate-line()
  ;; ;  (interactive)
  ;; ;  (move-beginning-of-line 1)
  ;; ;  (kill-line)
  ;; ;  (yank)
  ;; ;  (open-line 1)
  ;; ;  (next-line 1)
  ;; ;  (yank)
  ;; ;)
  ;; ;(global-set-key (kbd "C-d") 'duplicate-line)

)
;;-------------------------------------------------------------------------------

(set_my_keys)

;;-------------------------------------------------------------------------------
; 
  ;; (global-set-key '(control \1) 'my_empty) 
  ;; (global-set-key '(control \`) 'my_empty) 

  ;; (global-set-key '(control s) 'my_empty) 
  ;; (define-key isearch-mode-map '(control s) 'my_empty)
  
  ;; (global-set-key '(control q) 'my_empty) 
  ;; (define-key isearch-mode-map '(control q) 'my_empty)
  
  ;; (define-key isearch-mode-map '(control w) 'my_empty)

;---------------------------------------------------
; 
(defun set_my_isearch () (interactive)

  (global-set-key              "\M-s" 'isearch-forward)
  
  (define-key isearch-mode-map "\M-w" 'isearch-yank-word)
  (define-key isearch-mode-map "\M-s" 'isearch-repeat-forward)
  (define-key isearch-mode-map "\M-q" 'isearch-repeat-backward)
  
  
  ;;(set-face-foreground 'isearch "white")
  ;;(set-face-background 'isearch "SteelBlue3")
  
  ;;       (defun isearch-highlight-phrase ()
  ;;         "Invoke `highligh-phrase' from within isearch."
  ;;         (interactive)
  ;;         (let ((case-fold-search isearch-case-fold-search))
  ;;           (highlight-phrase (if isearch-regexp
  ;;                                 isearch-string
  ;;                               (regexp-quote isearch-string)))))

  ;; (define-key isearch-mode-map (kbd "C-<tab>") 'isearch-highlight-phrase)
  
  (setq search-highlight t)  
  ;;(setq isearch-highlight-all-matches t) ; XEmacs
  
  (setq isearch-lazy-highlight nil)  ; disables highlighting other matches  
  (setq lazy-highlight-initial-delay 2)
  ;;(setq lazy-highlight-interval 3) ; Time in seconds between highlighting successive matches.

  ;; all letters must match exactly, including case.
  (setq-default case-fold-search nil) ;; set the global value of a variable
                                      ;; (not for buffer)
  
  ;; isearch-mode.el:
  ;; 
  ;; 1860 (defcustom isearch-highlight-all-matches search-highlight
  ;; 1861   "*Non-nil means highlight all visible matches."
  ;; 1862   :type 'boolean
  ;; 1863   :group 'isearch)
  
  
  ;;(setq-default case-fold-search t)
  ;;(eval-after-load "isearch"
  ;;  '(define-key isearch-mode-map (kbd "C-h") 'isearch-mode-help))
 
  (defun isearch-face-settings ()   "Face settings for `isearch'."
	 
    ;;(set-face-foreground 'isearch "red")
    (set-face-background 'isearch "blue")
    
    ;; (when (not is-before-emacs-21)
    ;;   (set-face-foreground 'lazy-highlight "black")
    ;;   (set-face-background 'lazy-highlight "white"))

    ;; это подсветка в нижней строке:
    ;; 
    ;;(custom-set-faces '(isearch-fail ((((class color)) (:background "yellow")))))
  )
  
  (eval-after-load "isearch"  `(isearch-face-settings)) 
  )

(set_my_isearch)

;;-------------------------------------------------------------------------------

(setq mouse-wheel-scroll-amount '(2 ((shift) . 6) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------
(defun set_my_cygwin_PATH () (interactive)

  ;;;; https://www.emacswiki.org/emacs/NTEmacsWithCygwin
  ;;;;
  ;;;; cygwin support
  ;;;;

  ;; Sets your shell to use cygwin's bash, if Emacs finds it's running
  ;; under Windows and c:\cygwin exists. Assumes that C:\cygwin\bin is
  ;; not already in your Windows Path (it generally should not be).
  ;;
  (let* ((cygwin-root "c:/cygwin")
         (cygwin-bin (concat cygwin-root "/bin")))
    (when (and (eq 'windows-nt system-type)
  	     (file-readable-p cygwin-root))
    
      (setq exec-path (cons cygwin-bin exec-path))
      (setenv "PATH" (concat cygwin-bin ";" (getenv "PATH")))
    
      ;; By default use the Windows HOME.
      ;; Otherwise, uncomment below to set a HOME
      ;;      (setenv "HOME" (concat cygwin-root "/home/eric"))
    
      ;; NT-emacs assumes a Windows shell. Change to bash.
      (setq shell-file-name "bash")
      (setenv "SHELL" shell-file-name) 
      (setq explicit-shell-file-name shell-file-name) 
    
      ;; This removes unsightly ^M characters that would otherwise
      ;; appear in the output of java applications.
      (add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)))
 
)
;;-------------------------------------------------------------------------------
(defun set_my_cygwin () (interactive)

  ;;;; https://www.emacswiki.org/emacs/NTEmacsWithCygwin
  ;;;;

  ;;(set_my_cygwin_PATH)
  ;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    

  (setq *win32* (eq system-type 'windows-nt) )
  ;; win32 auto configuration, assuming that cygwin is installed at "c:/cygwin"
  (if *win32*
      (progn
	(setq cygwin-mount-cygwin-bin-directory "c:/cygwin/bin")
	(require 'setup-cygwin)
	;;(setenv "HOME" "c:/cygwin/home/someuser") ;; better to set HOME env in GUI
	))
  
  ;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~    

  ;; This package lets you use cygwin-style filenames .....
  ;;(require 'cygwin-mount)
  ;;(cygwin-mount-activate)

  (require 'setup-cygwin)

  ;; при попытке открыть файл (директорию) как ссылку?
  ;; error: Cannot find program ’mount.exe’.  Check ‘cygwin-mount-cygwin-bin-directory    
)

(if (eq system-type 'windows-nt)
    (set_my_cygwin)
  )

;;-------------------------------------------------------------------------------

(setq dired-listing-switches "-aBhl  --group-directories-first")

;==============================================================================
;                                    MENU    (XEmacs)                             
;==============================================================================

(setq my-test-popup-menu
      '(
	"---------"
	
	[ "INSERT from PRIMARY"  my_paste_from_primary]
	[ "SAVE"                 my_save_buffers]
	[ "DELETE"               my_cut_select]
	"---------"
	[ "Comment"  comment-region]
	[ "UnComment"    my_uncomment]
	"---------"
	[ "BUILD" my_save_and_build]  
					;   "---------"
					;   [ "End Line" kill-line]  
					;   [ "Next Error" next-error]  
					;   [ "Prev Error" previous-error]  
	"---------"
	("Translate"
	 [ "Del Ret"  my-delret]
	 )
	("Other Tests"
	 [ "check-my-location"  check-my-location]
	 [ "Revert Buffer" revert-buffer]
	 [ "Read Only"     toggle-read-only :style toggle :selected buffer-read-only ]
	 ("Colors"
	  [ "my-sxema0"  my-color-sxema0]
	  [ "my-sxema1"  my-color-sxema1]
	  [ "my-sxema2"  my-color-sxema2]
	  [ "my-sxema3"  my-color-sxema3]
	  ) 
	 [ "my_fontify"    my_fontify]
	 [ "my_unfontify"  my_unfontify]
	 )
	"---------"
	))

;----------------------------------------
(defun my-popup-menu ()
  
  (interactive)
  (popup-menu  my-test-popup-menu)
) 
;----------------------------------------
;; (defun modeline-buffers-menu-pilot (event)
  
;;   (interactive "e")
;;   (popup-menu-and-execute-in-window
;;    '("Buffers Popup Menu"
;;      :filter buffers-menu-filter
;;      ["List All Buffers" list-buffers t]
;;      "--"
;;      )
;;    event)

;; )
;----------------------------------------


;(global-set-key 'button3  `my-popup-menu)

;;(global-set-key 'button3  `my-popup-menu)
;(global-set-key 'button3  `modeline-buffers-menu-pilot)

;(global-set-key (kbd "<mouse-3>") `modeline-buffers-menu-pilot)
(global-set-key (kbd "<mouse-3>") `my-popup-menu)

;;-------------------------------------------------------------------------------
; XEmacs
;;-------------------------------------------------------------------------------
;; (custom-set-variables
 
;;  '(buffers-menu-grouping-function nil)
;;  '(buffers-menu-sort-function (quote sort-buffers-menu-alphabetically))

;;  '(paren-mode (quote paren) nil (paren))

;; ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;; ; '(selection-sets-clipboard t t)
;; ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;; ; '(compilation-window-height 11)
;;  '(lazy-lock-mode t nil (lazy-lock))
;;  '(c-tab-always-indent t)
;;  '(signal-error-on-buffer-boundary nil)
;;  '(case-fold-search nil)
;;  '(pending-delete-mode t nil (pending-del))
;;  '(toolbar-visible-p t)
;;  '(truncate-lines nil)
;;  '(kill-whole-line t)
;;  '(isearch-highlight-all-matches nil)
;;  '(compilation-read-command nil)
;;  '(indent-tabs-mode nil)
;;  '(modeline-scrolling-method nil))

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(defun my-color-sxema0 ()
 (interactive)

 (set-face-background 'default "bisque")
 (set-face-foreground 'default "black")  

 ;(set-face-background 'highlight    "yellow") ;
 ;(set-face-background 'isearch      "yellow") ; When highlighting  while searching

 (set-face-foreground 'font-lock-comment-face       "Red")    
 (set-face-foreground 'font-lock-string-face 	    "purple") 
 (set-face-foreground 'font-lock-keyword-face 	    "dark violet")
 (set-face-foreground 'font-lock-function-name-face "Blue")  
 (set-face-foreground 'font-lock-variable-name-face "DarkBlue") 
 (set-face-foreground 'font-lock-type-face	    "DarkGreen") 
 (set-face-foreground 'font-lock-warning-face	    "Red")
 
; (set-face-foreground 'font-lock-reference-face     "tomato") 
 (set-face-foreground 'font-lock-preprocessor-face  "forest green") 
; (set-face-foreground 'font-lock-doc-string-face    "chartreuse4")  
) 
;;-------------------------------------------------------------------------------
(defun my-color-sxema1 ()
 (interactive)

 (set-face-background 'default "light green")
 (set-face-foreground 'default "black")
 
 (set-face-foreground 'font-lock-comment-face       "Red")    
 (set-face-foreground 'font-lock-variable-name-face "DarkBlue") 
 (set-face-foreground 'font-lock-string-face 	    "purple") 

) 
;;-------------------------------------------------------------------------------

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(defun color-theme-pilot ()
  
  "Example theme. Carbon copy of color-theme-gnome contributed by Jonadab."

  (interactive)

  (color-theme-install
   '(color-theme-pilot

     ((foreground-color . "black")
      (background-color . "bisque")
      (background-mode  . dark)

      (cursor-color	. "indian red")
      )
     
     (default ((t (nil))))
     
     (region ((t (:foreground "cyan" :background "dark cyan"))))
     (underline ((t (:foreground "yellow" :underline t))))
     (modeline ((t (:foreground "dark cyan" :background "wheat"))))
     (modeline-buffer-id ((t (:foreground "dark cyan" :background "wheat"))))
     (modeline-mousable ((t (:foreground "dark cyan" :background "wheat"))))
     (modeline-mousable-minor-mode ((t (:foreground "dark cyan" :background "wheat"))))

     (italic      ((t (:foreground "dark red" :italic t))))
     (bold-italic ((t (:foreground "dark red" :bold t :italic t))))
     
     (bold ((t (:bold))))
     
     (font-lock-comment-face       ((t (:foreground "red"))))
     (font-lock-variable-name-face ((t (:foreground "DarkBlue"))))
     (font-lock-function-name-face ((t (:foreground "Blue"))))
     (font-lock-string-face        ((t (:foreground "purple"))))
     (font-lock-keyword-face       ((t (:foreground "dark violet"))))

;;  (set-face-foreground 'font-lock-comment-face       "Red")    
;;  (set-face-foreground 'font-lock-string-face 	    "purple") 
;;  (set-face-foreground 'font-lock-keyword-face 	    "dark violet")
;;  (set-face-foreground 'font-lock-function-name-face "Blue")  
;;  (set-face-foreground 'font-lock-variable-name-face "DarkBlue") 
;;  (set-face-foreground 'font-lock-type-face	    "DarkGreen") 
;;  (set-face-foreground 'font-lock-warning-face	    "Red")
 
;; ; (set-face-foreground 'font-lock-reference-face     "tomato") 
;;  (set-face-foreground 'font-lock-preprocessor-face  "forest green") 
;; ; (set-face-foreground 'font-lock-doc-string-face    "chartreuse4")  

 )
  )
)

;;-------------------------------------------------------------------------------

;(require 'color-theme)

;(color-theme-initialize)

;(color-theme-robin-hood)
;(color-theme-gnome2)
;(color-theme-pilot)
;(color-theme-pilot)


;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(setq my-color-themes (list
		       'color-theme-billw
;		       'color-theme-jsc-dark 
;		       'color-theme-sitaramv-solaris
;		       'color-theme-resolve
;		       'color-theme-classic
;		       'color-theme-jonadabian-slate
;		       'color-theme-kingsajz
;		       'color-theme-shaman
;		       'color-theme-subtle-blue
;		       'color-theme-snowish
;		       'color-theme-sitaramv-nt
;		       'color-theme-wheat

;		       'color-theme-gnome2
;		       'color-theme-robin-hood


;		       'color-theme-aalto-dark 
;		       'color-theme-aalto-light 
;		       'color-theme-aliceblue 
		       'color-theme-andreas 
;		       'color-theme-arjen 
		       ;; 'color-theme-beige-diff
		       ;; 'color-theme-bharadwaj 
		       ;; 'color-theme-bharadwaj-slate 
		       ;; 'color-theme-billw 
		       ;; 'color-theme-black-on-gray 
		       ;; 'color-theme-blippblopp 
		       ;; 'color-theme-simple-1 
		       ;; 'color-theme-blue-erc 
		       ;; 'color-theme-blue-gnus 
		       ;; 'color-theme-blue-mood 
		       ;; 'color-theme-blue-sea 
		       ;; 'color-theme-calm-forest 
		       ;; 'color-theme-charcoal-black 
		       ;; 'color-theme-goldenrod 
		       ;; 'color-theme-clarity 
		       ;; 'color-theme-classic 
		       ;; 'color-theme-comidia 
		       ;; 'color-theme-jsc-dark 
		       ;; 'color-theme-jsc-light 
		       ;; 'color-theme-jsc-light2 
		       ;; 'color-theme-dark-blue 
		       ;; 'color-theme-dark-blue2 
		       ;; 'color-theme-dark-green 
		       ;; 'color-theme-dark-laptop 
		       ;; 'color-theme-deep-blue 
		       'color-theme-digital-ofs1 
		       ;; 'color-theme-euphoria 
		       ;; 'color-theme-feng-shui 
		       ;; 'color-theme-fischmeister 
		       
		       ;; 'color-theme-gnome 
		       ;; 'color-theme-gnome2 
		       'color-theme-gray1 
		       'color-theme-gray30 
		       ;; 'color-theme-kingsajz 
		       ;; 'color-theme-greiner 
		       ;; 'color-theme-gtk-ide 
		       ;; 'color-theme-high-contrast 
		       ;; 'color-theme-hober 
		       'color-theme-infodoc 
		       'color-theme-jb-simple 
		       ;; 'color-theme-jedit-grey 
		       ;; 'color-theme-jonadabian 
		       ;; 'color-theme-jonadabian-slate 
		       ;; 'color-theme-katester 
		       ;; 'color-theme-late-night 
		       ;; 'color-theme-lawrence 
		       ;; 'color-theme-lethe 
		       ;; 'color-theme-ld-dark 
		       ;; 'color-theme-marine 
		       ;; 'color-theme-matrix 
		       'color-theme-marquardt 
		       ;; 'color-theme-midnight 
		       ;; 'color-theme-mistyday 
		       ;; 'color-theme-montz 
		       ;; 'color-theme-oswald 
		       ;; 'color-theme-parus 
		       ;; 'color-theme-pierson 
		       ;; 'color-theme-ramangalahy 
		       ;; 'color-theme-raspopovic 
		       ;; 'color-theme-renegade 
		       ;; 'color-theme-resolve 
		       ;; 'color-theme-retro-green 
		       ;; 'color-theme-retro-orange 
		       ;; 'color-theme-robin-hood 
		       ;; 'color-theme-rotor 
		       ;; 'color-theme-ryerson 
		       ;; 'color-theme-salmon-diff 
		       ;; 'color-theme-salmon-font-lock 
		       ;; 'color-theme-scintilla 
		       ;; 'color-theme-shaman 
		       ;; 'color-theme-sitaramv-nt 
		       
		       ;; 'color-theme-sitaramv-solaris 
		       
		       ;; 'color-theme-snow 
		       ;; 'color-theme-snowish 
		       ;; 'color-theme-standard-ediff 
		       ;; 'color-theme-standard 
		       ;; 'color-theme-emacs-21 
		       ;; 'color-theme-emacs-nw 
		       ;; 'color-theme-xemacs 
		       ;; 'color-theme-subtle-blue 
		       ;; 'color-theme-subtle-hacker 
		       ;; 'color-theme-taming-mr-arneson 
		       ;; 'color-theme-taylor 
		       ;; 'color-theme-tty-dark 
		       ;; 'color-theme-vim-colors 
		       ;; 'color-theme-whateveryouwant 
		       ;; 'color-theme-wheat 
		       ;; 'color-theme-pok-wob 
		       ;; 'color-theme-pok-wog 
		       ;; 'color-theme-word-perfect 
		       'color-theme-xp 

		       
		       )
		       )

(setq my-color-themes 'color-themes)


(defun my-theme-set-default () ; Set the first row
  (interactive)

  (setq theme-current my-color-themes)
  (setq color-theme-is-global nil) ; Initialization

  ;(color-theme-robin-hood)
  ;;(color-theme-gnome2)
  ;;(color-theme-pilot)
  (color-theme-pilot)

  ;---------------------------------------------------------

  ;(setq theme-current my-color-themes)
  ;(funcall (car theme-current))

  )

(defun my-describe-theme () ; Show the current theme
  (interactive)
  (message "%s" (car theme-current)))

					; Set the next theme (fixed by Chris Webber - tanks)
(defun my-theme-cycle ()		
  (interactive)

  (setq theme-current (cdr theme-current))

  (if (null theme-current)
      (setq theme-current my-color-themes))

  (funcall (car theme-current))
  (message "%S" (car theme-current))
  )

;;-------------------------------------------------------------------------------


;; (setq theme-current my-color-themes)
;; (setq color-theme-is-global nil) ; Initialization

;; (my-theme-set-default)

  ;; (require 'color-theme)=
  ;; (color-theme-initialize)

;(global-set-key [f5] 'my-theme-set-default)

;(global-set-key [f6] 'my-theme-cycle)

;;-------------------------------------------------------------------------------

(require 'dired)

(defun dired-mouse-find-file (event)
  "In Dired, visit the file or directory name you click on."
  (interactive "e")
  (let (window pos file)
    (save-excursion
      (setq window (posn-window (event-end event))
            pos (posn-point (event-end event)))
      (if (not (windowp window))
          (error "No file chosen"))
      (set-buffer (window-buffer window))
      (goto-char pos)
      (setq file (dired-get-file-for-visit)))
    (if (file-directory-p file)
        (or (and (cdr dired-subdir-alist)
                 (dired-goto-subdir file))
            (progn
              (select-window window)
              (dired-other-window file)))
      (select-window window)
      (find-file (file-name-sans-versions file t)))))

;;-------------------------------------------------------------------------------

(define-key dired-mode-map [mouse-2] 'dired-mouse-find-file)

(add-hook 'c-mode-hook #'hide-ifdef-mode)

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:family "Consolas" :foundry "outline" :slant normal :weight bold :height 113 :width normal)))))

;;-------------------------------------------------------------------------------
(if (eq system-type 'gnu/linux)
    (progn
    (message "SYSTEM-TYPE = gnu/linux")

    ( my-color-sxema0 )
    ;;( my-color-sxema1 )

    )
  )


(if (eq system-type 'windows-nt)

    (progn
    (message "SYSTEM-TYPE = gnu/linux")

    (custom-set-faces
     ;; custom-set-faces was added by Custom.
     ;; If you edit it by hand, you could mess it up, so be careful.
     ;; Your init file should contain only one such instance.
     ;; If there is more than one, they won't work right.

     ;; '(default ((t (:family "Courier10 BT" :foundry "outline" :slant normal :weight bold :height 98 :width normal)))))

   '(default ((t (:family "Consolas" :foundry "outline" :slant normal :weight bold :height 113 :width normal)))))
    )
  )

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
