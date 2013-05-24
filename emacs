;; -*- mode: Emacs-Lisp; -*-

; stop the startup messages!
(setq inhibit-startup-echo-area-message t)
(setq inhibit-startup-message t)

(setq custom-file "/Users/pariser/.emacs-custom.el")
(load custom-file)

;;************************************************************
;; add local plugins to load-path
;;************************************************************

(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp")

(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/mmm-mode")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/egg")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/auto-complete")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/yasnippet")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/pycomplete")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/textmate")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/rinari")
(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp/html5-el")

;;************************************************************
;; Emacs as server
;;************************************************************

(server-start)
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

;;************************************************************
;; Easy way to switch to minibuffer
;;************************************************************

(defun switch-to-minibuffer-window ()
  "switch to minibuffer window (if active)"
  (interactive)
  (when (active-minibuffer-window)
    (select-window (active-minibuffer-window))))

(global-set-key "\C-xp" 'switch-to-minibuffer-window)

;;************************************************************
;; Use revbufs.el
;;************************************************************

(require 'revbufs)

;;************************************************************
;; Rails!
;; Use haml-mode.el, sass-mode.el, scss-mode.el, yaml-mode.el
;; Start ruby-mode when opening .rake files
;;************************************************************

(require 'haml-mode)
;; (require 'sass-mode)
(require 'scss-mode)
(require 'yaml-mode)

(setq auto-mode-alist (cons '("\\.rake\\'" . ruby-mode) auto-mode-alist))

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook
 'yaml-mode-hook
 '(lambda ()
    (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;;************************************************************
;; Use js-beautify.el
;;************************************************************

;; (require 'js-beautify)
;; (custom-set-variables
;;  '(js-beautify-path "~/dev/dotfiles/dependencies/js-beautify/python/js-beautify"))
;; (global-set-key "\C-\M-T" 'js-beautify)

;;************************************************************
;; Use Emacs Got Git (egg)
;;************************************************************

;; (require 'egg)

;;************************************************************
;; Ensure that buffers have unique names
;;************************************************************

;; (require 'uniquify)
;; (setq uniquify-buffer-name-style (quote forward))

;;************************************************************
;; Get some Textmate features in emacs!
;;************************************************************

(require 'textmate)
(textmate-mode)

;;************************************************************
;; Get multiple-major-mode working
;;************************************************************

;; (require 'mmm-auto)
;; (setq mmm-global-mode 'maybe)

;;************************************************************
;; Remove tabs/trailing whitespace from buffer on save
;;************************************************************

(defun untabify-buffer ()
  "Untabify current buffer"
  (interactive)
  (untabify (point-min) (point-max)))

(defun delete-trailing-whitespace-except-current-line ()
  (interactive)
  (let ((begin (line-beginning-position))
        (end (line-end-position)))
    (save-excursion
      (when (< (point-min) begin)
        (save-restriction
          (narrow-to-region (point-min) (1- begin))
          (delete-trailing-whitespace)))
      (when (> (point-max) end)
        (save-restriction
          (narrow-to-region (1+ end) (point-max))
          (delete-trailing-whitespace))))))

(defun progmodes-write-hooks ()
  "Hooks which run on file write for programming modes"
  (prog1 nil
    (set-buffer-file-coding-system 'utf-8-unix)
    (untabify-buffer)
    (delete-trailing-whitespace-except-current-line)))

(defun progmodes-hooks ()
  "Hooks for programming modes"
  (add-hook 'before-save-hook 'progmodes-write-hooks))

(add-hook 'php-mode-hook    'progmodes-hooks)
(add-hook 'python-mode-hook 'progmodes-hooks)
(add-hook 'js-mode-hook     'progmodes-hooks)
(add-hook 'nxhtml-mode-hook 'progmodes-hooks)
(add-hook 'haml-mode-hook   'progmodes-hooks)
(add-hook 'ruby-mode-hook   'progmodes-hooks)

;;************************************************************
;; to save emacs sessions
;;************************************************************

;; ; for saving emacs sessions
;; (require 'desktop)
;; (desktop-save-mode 1)
;; (add-hook 'auto-save-hook (lambda () (desktop-save-in-desktop-dir)))

;; (setq desktop-buffers-not-to-save
;;       (concat "\\("
;;               "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
;;               "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
;;               "\\)$"))
;; (add-to-list 'desktop-modes-not-to-save 'dired-mode)
;; (add-to-list 'desktop-modes-not-to-save 'Info-mode)
;; (add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
;; (add-to-list 'desktop-modes-not-to-save 'fundamental-mode)

;;************************************************************
;; to move buffer locations
;;************************************************************

; move buffers with keystrokes (instead of M-x o, C-x b, etc.)
(require 'buffer-move)

(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

;;************************************************************
;; Load auto-complete
;;************************************************************

;; TO INSTALL:
;; M-x load-file /path/to/auto-complete/etc/install.el

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/site-lisp/auto-complete/ac-dict")
(ac-config-default)

;;************************************************************
;; Load yasnippets for text expansion
;;************************************************************

(require 'yasnippet)
(yas-global-mode 1)

;; (yas/initialize)
;; (yas/load-directory "~/.emacs.d/site-lisp/yasnippet/snippets")

;;************************************************************
;; configure Python editing via Pymacs and pycomplete
;;************************************************************

; fix for pycomplete, now that python2 and python3 have their own mode maps
(defvaralias 'python-mode-map 'python2-mode-map)

; initialize Pymacs
(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

; python tag completion from open buffers
;; (require 'pycomplete)

;;************************************************************
;; python flymake syntax checking
;;************************************************************
;; Courtesy http://www.plope.com/Members/chrism/flymake-mode

(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "pyflakes" (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))

(add-hook 'find-file-hook 'flymake-find-file-hook)

;; don't run flymake for html documents
(delete '("\\.html?\\'" flymake-xml-init) flymake-allowed-file-name-masks)

;;************************************************************
;; ruby flymake syntax checking
;;************************************************************

;; ;; Invoke ruby with '-c' to get syntax checking
;; (defun flymake-ruby-init ()
;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;          (local-file  (file-relative-name
;;                        temp-file
;;                        (file-name-directory buffer-file-name))))
;;     (list "ruby" (list "-c" local-file))))

;; (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
;; (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)

;; (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)

;; (add-hook 'ruby-mode-hook
;;           '(lambda ()
;;              ;; Don't want flymake mode for ruby regions in rhtml files and also on read only files
;;              (if (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
;;                  (flymake-mode))
;;              ))

;;************************************************************
;; configure HTML editing
;;************************************************************

(load "~/.emacs.d/site-lisp/nxhtml/autostart.el")
(add-to-list 'auto-mode-alist '("\\.html$'" . nxhtml-mumamo-mode))
(add-to-list 'magic-mode-alist '("\\(?:<\\?xml\\s +[^>]*>\\)?\\s *<\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\(?:!DOCTYPE\\s +[^>]*>\\s *<\\s *\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\)?[Hh][Tt][Mm][Ll]" . nxhtml-mumamo-mode))

(delete '("\\.html\\'" . html-mumamo-mode) auto-mode-alist)
(delete '("\\.html\\'" . nxhtml-mumamo-mode) auto-mode-alist)
(delete '("\\.htm\\'" . nxhtml-mumamo-mode) auto-mode-alist)
(delete '("\\.shtml$" . html-helper-mode) auto-mode-alist)
(delete '("\\.html$" . html-helper-mode) auto-mode-alist)
(delete '("\\.s?html?\\(\\.[a-zA-Z_]+\\)?\\'" . nxhtml-mumamo-mode) auto-mode-alist)
(delete '("\\.s?html?\\(\\.[a-zA-Z_]+\\)?\\'" . html-mumamo-mode) auto-mode-alist)
(delete '("\\(?:<\\?xml\\s +[^>]*>\\)?\\s *<\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\(?:!DOCTYPE\\s +[^>]*>\\s *<\\s *\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\)?[Hh][Tt][Mm][Ll]" . nxhtml-mumamo-mode) magic-mode-alist)
(delete '("\\(?:<\\?xml\\s +[^>]*>\\)?\\s *<\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\(?:!DOCTYPE\\s +[^>]*>\\s *<\\s *\\(?:!--\\(?:[^-]\\|-[^-]\\)*-->\\s *<\\)*\\)?[Hh][Tt][Mm][Ll]" . html-helper-mode) magic-mode-alist)

;; Mumamo is making emacs 23.3 freak out:
(when (and (equal emacs-major-version 23)
           (equal emacs-minor-version 3))
  (eval-after-load "bytecomp"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function))
  ;; tramp-compat.el clobbers this variable!
  (eval-after-load "tramp-compat"
    '(add-to-list 'byte-compile-not-obsolete-vars
                  'font-lock-beginning-of-syntax-function)))

;;************************************************************
;; configure MMM mode
;;************************************************************

;; (load "~/.emacs.d/site-lisp/mmm-mako.elc")
;; (add-to-list 'auto-mode-alist '("\\.mako\\'" . nxhtml-mumamo-mode))
;; (mmm-add-mode-ext-class 'nxhtml-mumamo-mode "\\.mako\\'" 'mako)

;;************************************************************
;; configure HTML5-EL
;;************************************************************

(eval-after-load "rng-loc"
  '(add-to-list 'rng-schema-locating-files "/Users/pariser/.emacs.d/site-lisp/html5-el/schemas.xml"))

(require 'whattf-dt)

;; (load "~/.emacs.d/site-lisp/mmm-mako.elc")
;; (add-to-list 'auto-mode-alist '("\\.mako\\'" . nxhtml-mumamo-mode))
;; (mmm-add-mode-ext-class 'nxhtml-mumamo-mode "\\.mako\\'" 'mako)

;;************************************************************
;; helper functions
;;************************************************************

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (save-excursion
     (set-buffer buffer-or-string)
     major-mode))

(defun ap-pretty-print-xml-region (begin end)
  "Pretty format XML markup in region. You need to have nxml-mode
http://www.emacswiki.org/cgi-bin/wiki/NxmlMode installed to do
this.  The function inserts linebreaks to separate tags that have
nothing but whitespace between them.  It then indents the markup
by using nxml's indentation rules."
  (interactive "r")
  (save-excursion
      (nxml-mode)
      (goto-char begin)
      (while (search-forward-regexp "\>[ \\t]*\<" nil t)
        (backward-char) (insert "\n"))
      (indent-region begin end))
    (message "Ah, much better!"))

(defun ap-toggle-identifier-naming-style ()
  "Toggles the symbol at point between C-style naming,
    e.g. `hello_world_string', and camel case,
    e.g. `HelloWorldString'."
  (interactive)
  (let* ((symbol-pos (bounds-of-thing-at-point 'symbol))
         case-fold-search symbol-at-point cstyle regexp func)
    (unless symbol-pos
      (error "No symbol at point"))
    (save-excursion
      (narrow-to-region (car symbol-pos) (cdr symbol-pos))
      (setq cstyle (string-match-p "_" (buffer-string))
            regexp (if cstyle "\\(?:\\_<\\|_\\)\\(\\w\\)" "\\([A-Z]\\)")
            func (if cstyle
                     'capitalize
                   (lambda (s)
                     (concat (if (= (match-beginning 1)
                                    (car symbol-pos))
                                 ""
                               "_")
                             (downcase s)))))
      (goto-char (point-min))
      (while (re-search-forward regexp nil t)
        (replace-match (funcall func (match-string 1))
                       t nil))
      (widen))))

(defun what-face (pos)
  (interactive "d")
  (let ((face (or (get-char-property (point) 'read-face-name)
                  (get-char-property (point) 'face))))
    (if face (message "Face: %s" face) (message "No face at %d" pos))))

;;************************************************************
;; variable customizations
;;************************************************************

; Allow downcase-region but disable its keyboard shortcut
(put 'downcase-region 'disabled nil)
(global-unset-key "\C-x\C-l")

; fill-column width set to 90 characters
(setq-default fill-column 90)

; never use tabs
(setq-default indent-tabs-mode nil)

; tab indent level set to 4 spaces
(setq-default py-indent-offset 4)
(setq-default python-indent 4)

; don't compile scss at save
(setq-default scss-sass-command "/Users/pariser/.rvm/gems/ruby-1.9.3-p392/bin/sass")
(setq-default scss-sass-options '("--cache-location" "/tmp/.sass-cache"))
(setq-default scss-compile-at-save nil)
(setq-default scss-sass-command "/usr/bin/sass")

; tab indent level set to 2 spaces for javascript
(setq-default js-indent-level 2)

; turn off the toolbar
(tool-bar-mode 0)

; no seriously, I really want haml to load instead of nxhtml mode
(setq auto-mode-alist
 (cons '("\\.haml$" . haml-mode) auto-mode-alist))

;; (require 'ido)
;; (ido-mode t)

;; (add-to-list 'load-path "/users/pariser/.emacs.d/site-lisp/rinari")
;; (require 'rinari)

;; (add-to-list 'load-path "~/path/to/your/elisp/nxml-directory/util")

;; (add-to-list 'load-path "~/.emacs.d/site-lisp/nxhtml/util")
;; (require 'mumamo-fun)
;; (setq mumamo-chunk-coloring 'submode-colored)
;; (add-to-list 'auto-mode-alist '("\\.rhtml\\'" . eruby-html-mumamo))
;; (add-to-list 'auto-mode-alist '("\\.html\\.erb\\'" . eruby-html-mumamo))
