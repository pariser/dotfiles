;;************************************************************
;; add local plugins to load-path
;;************************************************************

(add-to-list 'load-path "/Users/pariser/.emacs.d/site-lisp")

;; (progn (cd "/Users/pariser/.emacs.d/site-lisp")
;;        (normal-top-level-add-subdirs-to-load-path))

(add-to-list 'load-path "/users/pariser/.emacs.d/site-lisp/mmm-mode")
(add-to-list 'load-path "/users/pariser/.emacs.d/site-lisp/git")
(add-to-list 'load-path "/users/pariser/.emacs.d/site-lisp/autocomplete")
(add-to-list 'load-path "/users/pariser/.emacs.d/site-lisp/yasnippet")

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
;; Allow downcase-region but disable its keyboard shortcut
;;************************************************************

(put 'downcase-region 'disabled nil)
(global-unset-key "\C-x\C-l")

;;************************************************************
;; Use revbufs.el
;;************************************************************

(require 'revbufs)

;;************************************************************
;; Use git.el
;;************************************************************

(require 'git)

;;************************************************************
;; Ensure that buffers have unique names
;;************************************************************

(require 'uniquify)

;;************************************************************
;; Remove tabs/trailing whitespace from buffer on save
;;************************************************************

(defun untabify-buffer ()
  "Untabify current buffer"
  (interactive)
  (untabify (point-min) (point-max)))

(defun progmodes-hooks ()
  "Hooks for programming modes"
  (add-hook 'before-save-hook 'progmodes-write-hooks))

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

(add-hook 'php-mode-hook    'progmodes-hooks)
(add-hook 'python-mode-hook 'progmodes-hooks)
(add-hook 'js-mode-hook     'progmodes-hooks)
(add-hook 'nxhtml-mode-hook 'progmodes-hooks)

;;************************************************************
;; to save emacs sessions
;;************************************************************

; for saving emacs sessions
(require 'desktop)
(desktop-save-mode 1)
(add-hook 'auto-save-hook (lambda () (desktop-save-in-desktop-dir)))

(setq desktop-buffers-not-to-save
      (concat "\\("
              "^nn\\.a[0-9]+\\|\\.log\\|(ftp)\\|^tags\\|^TAGS"
              "\\|\\.emacs.*\\|\\.diary\\|\\.newsrc-dribble\\|\\.bbdb"
              "\\)$"))
(add-to-list 'desktop-modes-not-to-save 'dired-mode)
(add-to-list 'desktop-modes-not-to-save 'Info-mode)
(add-to-list 'desktop-modes-not-to-save 'info-lookup-mode)
(add-to-list 'desktop-modes-not-to-save 'fundamental-mode)

;;************************************************************
;; to move buffer locations
;;************************************************************

; allows me to swap buffers with keystrokes (instead of M-x o, C-x b, etc.)
(require 'buffer-move)

(global-set-key (kbd "<C-S-up>")     'buf-move-up)
(global-set-key (kbd "<C-S-down>")   'buf-move-down)
(global-set-key (kbd "<C-S-left>")   'buf-move-left)
(global-set-key (kbd "<C-S-right>")  'buf-move-right)

;;************************************************************
;; Load auto-complete, yasnippet, pymacs
;;************************************************************

(require 'auto-complete-config)
(add-to-list 'ac-dictionary-directories "~/.emacs.d/site-lisp/autocomplete/ac-dict")
(ac-config-default)

; (require 'auto-complete)

(require 'yasnippet)

;;************************************************************
;; configure Python editing
;;************************************************************

;; Initialize Pymacs

(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)

;; (autoload 'python-mode "python-mode" "Python Mode." t)
;; (add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
;; (add-to-list 'interpreter-mode-alist '("python" . python-mode))

;;************************************************************
;; python auto-completion
;;************************************************************

(require 'pycomplete)

;; Initialize Rope

;; (pymacs-load "ropemacs" "rope-")
;; (setq ropemacs-enable-autoimport t)

;; ;; Initialize Yasnippet
;; ;Don't map TAB to yasnippet
;; ;In fact, set it to something we'll never use because
;; ;we'll only ever trigger it indirectly.

;; (setq yas/trigger-key (kbd "C-c <kp-multiply>"))
;; (yas/initialize)
;; (yas/load-directory "~/.emacs.d/snippets")

;; ;;************************************************************
;; ;; Code lifted from
;; ;; http://www.enigmacurry.com/2009/01/21/autocompleteel-python-code-completion-in-emacs/
;; ;; xxxSTART-AutoComplete

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; Auto-completion
;; ;;;  Integrates:
;; ;;;   1) Rope
;; ;;;   2) Yasnippet
;; ;;;   all with AutoComplete.el
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; (defun prefix-list-elements (list prefix)
;;   (let (value)
;;     (nreverse
;;      (dolist (element list value)
;;       (setq value (cons (format "%s%s" prefix element) value))))))
;; (defvar ac-source-rope
;;   '((candidates
;;      . (lambda ()
;;          (prefix-list-elements (rope-completions) ac-target))))
;;   "Source for Rope")
;; (defun ac-python-find ()
;;   "Python `ac-find-function'."
;;   (require 'thingatpt)
;;   (let ((symbol (car-safe (bounds-of-thing-at-point 'symbol))))
;;     (if (null symbol)
;;         (if (string= "." (buffer-substring (- (point) 1) (point)))
;;             (point)
;;           nil)
;;       symbol)))
;; (defun ac-python-candidate ()
;;   "Python `ac-candidates-function'"
;;   (let (candidates)
;;     (dolist (source ac-sources)
;;       (if (symbolp source)
;;           (setq source (symbol-value source)))
;;       (let* ((ac-limit (or (cdr-safe (assq 'limit source)) ac-limit))
;;              (requires (cdr-safe (assq 'requires source)))
;;              cand)
;;         (if (or (null requires)
;;                 (>= (length ac-target) requires))
;;             (setq cand
;;                   (delq nil
;;                         (mapcar (lambda (candidate)
;;                                   (propertize candidate 'source source))
;;                                 (funcall (cdr (assq 'candidates source)))))))
;;         (if (and (> ac-limit 1)
;;                  (> (length cand) ac-limit))
;;             (setcdr (nthcdr (1- ac-limit) cand) nil))
;;         (setq candidates (append candidates cand))))
;;     (delete-dups candidates)))
;; (add-hook 'python-mode-hook
;;           (lambda ()
;;                  (auto-complete-mode 1)
;;                  (set (make-local-variable 'ac-sources)
;;                       (append ac-sources '(ac-source-rope) '(ac-source-yasnippet)))
;;                  (set (make-local-variable 'ac-find-function) 'ac-python-find)
;;                  (set (make-local-variable 'ac-candidate-function) 'ac-python-candidate)
;;                  (set (make-local-variable 'ac-auto-start) nil)))

;; ;;Ryan's python specific tab completion
;; (defun ryan-python-tab ()
;;   ; Try the following:
;;   ; 1) Do a yasnippet expansion
;;   ; 2) Do a Rope code completion
;;   ; 3) Do an indent
;;   (interactive)
;;   (if (eql (ac-start) 0)
;;       (indent-for-tab-command)))

;; (defadvice ac-start (before advice-turn-on-auto-start activate)
;;   (set (make-local-variable 'ac-auto-start) t))
;; (defadvice ac-cleanup (after advice-turn-off-auto-start activate)
;;   (set (make-local-variable 'ac-auto-start) nil))

;; (define-key python-mode-map "\t" 'ryan-python-tab)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; ;;; End Auto Completion
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;; xxxFINISH-AutoComplete
;; ;;************************************************************

;;************************************************************
;; configure HTML editing
;;************************************************************

(load "~/.emacs.d/site-lisp/nxhtml/autostart.el")

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

;;************************************************************
;; helper functions
;;************************************************************

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

;;************************************************************
;; variable customizations
;;************************************************************

(setq-default fill-column 90)

