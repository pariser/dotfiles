;; -*- mode: Emacs-Lisp; -*-

; stop the startup messages!
(setq inhibit-startup-echo-area-message t)
(setq inhibit-startup-message t)

(defun home-path (subpath)
  (concat (getenv "HOME") "/"
          (replace-regexp-in-string "^/" "" subpath)))

(setq custom-file (home-path ".emacs-custom.el"))
(load custom-file)

;;************************************************************
;; add local plugins to load-path
;;************************************************************

(add-to-list 'load-path (home-path ".emacs.d/site-lisp"))

;;************************************************************
;; Emacs as server
;;************************************************************

(server-start)
(remove-hook 'kill-buffer-query-functions 'server-kill-buffer-query-function)

;;************************************************************
;; Package archives
;;************************************************************

(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))

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
;; What mode is current buffer running?
;;************************************************************

(defun buffer-mode (buffer-or-string)
  "Returns the major mode associated with a buffer."
  (interactive
   (cond
    ((equal current-prefix-arg nil)
     (list (current-buffer)))
    ((equal current-prefix-arg '(4))
     (list (read-string "Buffer" nil nil nil)))))
  (with-current-buffer buffer-or-string
     (message "%s" major-mode)))

;;************************************************************
;; Use revbufs.el
;;************************************************************

(require 'revbufs)

;;************************************************************
;; Load auto-complete
;;************************************************************

;; TO INSTALL:
;; M-x load-file /path/to/auto-complete/etc/install.el

(add-to-list 'load-path (home-path ".emacs.d/site-lisp/auto-complete"))

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/site-lisp/auto-complete/ac-dict")
(ac-config-default)

;;************************************************************
;; Load yasnippets for text expansion
;;************************************************************

(add-to-list 'load-path (home-path ".emacs.d/site-lisp/yasnippet"))

(require 'yasnippet)
(yas-global-mode 1)
(setq yas-snippet-dirs (quote ("~/.emacs.d/snippets")))

;; (yas/initialize)
;; (yas/load-directory "~/.emacs.d/site-lisp/yasnippet/snippets")

;;************************************************************
;; Load ack-and-a-half
;;************************************************************

(require 'ack-and-a-half)
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)

;;************************************************************
;; Rails!
;; Use haml-mode.el, sass-mode.el, scss-mode.el, yaml-mode.el
;; Start ruby-mode when opening .rake files
;;************************************************************

(require 'haml-mode)
;; (require 'sass-mode)
(require 'scss-mode)
(require 'yaml-mode)

(setq rspec-snippets-dir (home-path ".emacs.d/snippets"))
(require 'rspec-mode)

;; (add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
;; (setq auto-mode-alist (cons '("\\.rake\\'" . ruby-mode) auto-mode-alist))

(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-hook
 'yaml-mode-hook
 '(lambda ()
    (define-key yaml-mode-map "\C-m" 'newline-and-indent)))


;;************************************************************
;; Use js-beautify.el
;;************************************************************

(require 'js-beautify)
(custom-set-variables
 '(js-beautify-path "/usr/local/bin/js-beautify")
 '(js-beautify-args "--indent-size=2 --jslint-happy --brace-style=end-expand --keep-array-indentation"))
(global-set-key "\C-\M-T" 'js-beautify)

;;************************************************************
;; Use flymake mode in javascript
;;************************************************************

;; commented for now -- because of the rails asset pipeline and
;; rails "require" statements, none of the js files pass jslint
;; because they reference variables in other files

;; (when (load "flymake" t)
;;   (defun flymake-jslint-init ()
;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                        'flymake-create-temp-inplace))
;;            (local-file (file-relative-name
;;                         temp-file
;;                         (file-name-directory buffer-file-name))))
;;       (list "jslint" (list "--terse" local-file))))

;;   (setq flymake-err-line-patterns
;;         (cons '("^\\(.*\\)(\\([[:digit:]]+\\)):\\(.*\\)$"
;;                 1 2 nil 3)
;;               flymake-err-line-patterns))

;;   (add-to-list 'flymake-allowed-file-name-masks
;;                '("\\.js\\'" flymake-jslint-init)))

;; (add-hook 'js2-mode-hook
;;           (lambda ()
;;             (flymake-mode t)
;;             (define-key js2-mode-map "\C-c\C-n" 'flymake-goto-next-error)))

;; (add-hook 'javascript-mode-hook
;;           (lambda ()
;;             (flymake-mode t)
;;             (define-key javascript-mode-map "\C-c\C-n" 'flymake-goto-next-error)))

;;************************************************************
;; Use Emacs Got Git (egg)
;;************************************************************

;; (add-to-list 'load-path (home-path ".emacs.d/site-lisp/egg"))

;; (require 'egg)

;;************************************************************
;; Ensure that buffers have unique names
;;************************************************************

(require 'uniquify)
(setq uniquify-buffer-name-style (quote forward))

;;************************************************************
;; Get some Textmate features in emacs!
;;************************************************************

;; Add node_modules to excluded files
(defvar *textmate-gf-exclude*
  "(/|^)(\\.+[^/]+|vendor|fixtures|tmp|log|classes|build|node_modules)($|/)|(\\.xcodeproj|\\.nib|\\.framework|\\.app|\\.pbproj|\\.pbxproj|\\.xcode|\\.xcodeproj|\\.bundle|\\.pyc)(/|$)"
  "Regexp of files to exclude from `textmate-goto-file'.")

(add-to-list 'load-path (home-path ".emacs.d/site-lisp/textmate"))

(require 'textmate)
(textmate-mode)

;;************************************************************
;; Get multiple-major-mode working
;;************************************************************

;; (add-to-list 'load-path (home-path ".emacs.d/site-lisp/mmm-mode"))

;; (require 'mmm-auto)
;; (setq mmm-global-mode 'maybe)

;;************************************************************
;; Remove tabs/trailing whitespace from buffer on save
;;************************************************************

(defun untabify-buffer ()
  "Untabify current buffer"
  (interactive)
  (message "untabify-buffer")
  (untabify (point-min) (point-max)))

(defun delete-trailing-whitespace-except-current-line ()
  (interactive)
  (message "delete-trailing-whitespace-except-current-line")
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

(add-hook 'php-mode-hook      'progmodes-hooks)
(add-hook 'python-mode-hook   'progmodes-hooks)
(add-hook 'js-mode-hook       'progmodes-hooks)
(add-hook 'nxhtml-mode-hook   'progmodes-hooks)
(add-hook 'haml-mode-hook     'progmodes-hooks)
(add-hook 'ruby-mode-hook     'progmodes-hooks)
(add-hook 'enh-ruby-mode-hook 'progmodes-hooks)

;;************************************************************
;; desktop - to save emacs sessions
;;************************************************************

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
;; move buffers with keystrokes (instead of M-x o, C-x b, etc.)

(require 'buffer-move)

(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

;;************************************************************
;; configure Python editing via Pymacs and pycomplete
;;************************************************************

; pymacs: execute python in emacs

(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

; pycomplete: python tag completion from open buffers

;; (add-to-list 'load-path (home-path ".emacs.d/site-lisp/pycomplete"))

;; ;; fix for pycomplete, now that python2 and python3 have their own mode maps
;; (defvaralias 'python-mode-map 'python2-mode-map)

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
;; configure simplistic code folding via 'yafolding
;;************************************************************

(require 'yafolding)

; fold-at-point with C-'
(define-key global-map (kbd "C-'") 'yafolding)

; fold-all-at-level with C-c C-'
(define-key global-map (kbd "C-c C-'") 'yafolding-toggle-all-by-current-level)

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
;; configure mumamomo mode
;;************************************************************

;; (load "~/.emacs.d/site-lisp/mmm-mako.elc")
;; (add-to-list 'auto-mode-alist '("\\.mako\\'" . nxhtml-mumamo-mode))
;; (mmm-add-mode-ext-class 'nxhtml-mumamo-mode "\\.mako\\'" 'mako)

;;************************************************************
;; configure HTML5-EL
;;************************************************************

(add-to-list 'load-path (home-path ".emacs.d/site-lisp/html5-el"))

(eval-after-load "rng-loc"
  '(add-to-list 'rng-schema-locating-files (home-path ".emacs.d/site-lisp/html5-el/schemas.xml")))

(require 'whattf-dt)

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

(defun ap-haml-reindent-region-by (n)
  "Add N spaces to the beginning of each line in the region.
If N is negative, will remove the spaces instead.  Assumes all
lines in the region have indentation >= that of the first line."
  (interactive*)
  (let* ((ci (current-indentation))
         (indent-rx
          (concat "^"
                  (if indent-tabs-mode
                      (concat (make-string (/ ci tab-width) ?\t)
                              (make-string (mod ci tab-width) ?\t))
                    (make-string ci ?\s)))))
    (save-excursion
      (while (re-search-forward indent-rx (mark) t)
        (let ((ci (current-indentation)))
          (delete-horizontal-space)
          (beginning-of-line)
          (indent-to (max 0 (+ ci n))))))))

(defun increment-number-at-point (&optional arg)
  "Increment the number at point by 'arg'."
  (interactive "p*")
  (save-excursion
    (save-match-data
      (let (inc-by field-width answer)
        (setq inc-by (if arg arg 1))
        (skip-chars-backward "0123456789")
        (when (re-search-forward "[0-9]+" nil t)
          (setq field-width (- (match-end 0) (match-beginning 0)))
          (setq answer (+ (string-to-number (match-string 0) 10) inc-by))
          (when (< answer 0)
            (setq answer (+ (expt 10 field-width) answer)))
          (replace-match (format (concat "%0" (int-to-string field-width) "d")
                                 answer)))))))

(defun decrement-number-at-point (&optional arg)
  "Decrement the number at point by 'arg'."
  (interactive "p*")
  (increment-number-at-point (if arg (- arg) -1)))

(global-set-key (kbd "C-c +") 'increment-number-at-point)
(global-set-key (kbd "C-c -") 'decrement-number-at-point)

;;************************************************************
;; midnight mode -- clear stale buffers
;;************************************************************

; cf: http://www.emacswiki.org/emacs/KillingBuffers#toc12

(require 'midnight)

; clear "disabled" (read-only) buffers every 15 minutes
(setq clean-buffer-list-delay-special 900)

; clean buffer list, timer, regular expression
(defvar clean-buffer-list-timer nil
  "Stores clean-buffer-list timer if there is one. You can disable clean-buffer-list by (cancel-timer clean-buffer-list-timer).")
(setq clean-buffer-list-timer (run-at-time t 7200 'clean-buffer-list))
(setq clean-buffer-list-kill-regexps '("^.*$"))

; buffers not to kill
(defvar clean-buffer-list-kill-never-buffer-names-init
  clean-buffer-list-kill-never-buffer-names
  "Init value for clean-buffer-list-kill-never-buffer-names")
(setq clean-buffer-list-kill-never-buffer-names
      (append
       '("*Messages*" "*cmd*" "*scratch*" "*w3m*" "*w3m-cache*" "*Inferior Octave*")
       clean-buffer-list-kill-never-buffer-names-init))
(defvar clean-buffer-list-kill-never-regexps-init
  clean-buffer-list-kill-never-regexps
  "Init value for clean-buffer-list-kill-never-regexps")
(setq clean-buffer-list-kill-never-regexps
      (append '("^\\*EMMS Playlist\\*.*$")
              clean-buffer-list-kill-never-regexps-init))

;;************************************************************
;; toggle camelcase/underscore of word at point
;;************************************************************

(defun split-name (s)
  (split-string
   (let ((case-fold-search nil))
     (downcase
      (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2" s)))
   "[^A-Za-z0-9]+"))

(defun camelcase  (s) (mapconcat 'capitalize (split-name s) ""))
(defun underscore (s) (mapconcat 'downcase   (split-name s) "_"))

(defun camelscore (s)
  (if (string-match-p "\\(?:[a-z]+_\\)+[a-z]+" s)
      (camelcase s)
      (underscore s)))

(defun camelscore-word-at-point ()
  (interactive)
  (let* ((case-fold-search nil)
         (beg (and (skip-chars-backward "[:alnum:]_") (point)))
         (end (and (skip-chars-forward  "[:alnum:]_") (point)))
         (txt (buffer-substring beg end))
         (cml (camelscore txt)) )
    (if cml (progn (delete-region beg end) (insert cml))) ))

(global-set-key "\M-`" 'camelscore-word-at-point)

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
(setq-default scss-sass-command (home-path ".rvm/gems/ruby-1.9.3-p545@LearnUp/bin/sass"))
(setq-default scss-sass-options '("--cache-location" "/tmp/.sass-cache"))
(setq-default scss-compile-at-save nil)

; tab indent level set to 2 spaces for javascript / css (scss)
(setq-default js-indent-level 2)
(setq-default css-indent-offset 2)

; turn off the toolbar
(tool-bar-mode 0)

; no seriously, I really want haml to load instead of nxhtml mode
(setq auto-mode-alist
 (cons '("\\.haml$" . haml-mode) auto-mode-alist))

; force emacs to split to side-by-side instead of top-and-bottom windows
(setq split-height-threshold nil)
(setq split-width-threshold 0)

; always enable "winner-mode", which allows me to toggle through window
; configurations with `C-c left` and `C-c right`. In this way, if a command
; opens up a window, say, as a result of "ack", when I'm done with that
; window I can reset to the previous window configuration
(when (fboundp 'winner-mode)
  (winner-mode 1))

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
