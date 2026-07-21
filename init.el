;; -*- lexical-binding: t; -*-

;; mogman's minimal emacs - mme

;; TODO - sub topics for imenu (e.g. use for areas like ";;;; HELM")
;; e.g. @subtopic-1
;; e.g. @subtopic-2
;; e.g. etc

;; ==============================================================================================================
;; @topic CUSTOM FILE
;; ==============================================================================================================
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)


;; ==============================================================================================================
;; @topic PACKAGE MANAGEMENT
;; ==============================================================================================================
(require 'package)
(setq package-archives '(
    ("melpa" . "https://melpa.org/packages/") ("elpa" . "https://elpa.gnu.org/packages/")
        )
)

;; we make use of melpa the most so we priortise that first
(setq package-archive-priorities '(("melpa" . 10) ("elpa" . 5)))

(unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))
(require 'use-package)


;; ==============================================================================================================
;; @topic GENERAL SETTINGS
;; ==============================================================================================================
(add-to-list 'exec-path "/opt/homebrew/bin")

;; NOTE - for variables we use 't' or 'nil'
;; NOTE - for functions we use numbers (1 == enabled , 0 == disabled , no number means toggle)
(setq inhibit-splash-screen t)
(setq insert-directory-program "gls")
(setq enable-recursive-minibuffers t)
(setq lossage-size 1000)
(setq locate-command "mdfind")
(setq kill-do-not-save-duplicates t)
(setq global-auto-revert-non-file-buffers t)    ;; auto revert non-file buffers (e.g. dired)
(setq display-line-numbers-type 'relative)
(setq redisplay-skip-fontification-on-input t)  ;; skip fontification during input (from doom emacs)
(setq set-mark-command-repeat-pop t)            ;; after C-u C-SPC , keep popping the mark ring with just C-SPC instead of having to repeat the C-u prefix each time
(setq savehist-additional-variables '(search-ring regexp-search-ring kill-ring))

(setq-default truncate-lines t)

;; bidi (bidirectional text) reordering checks are expensive and
;; do not need them for programming buffers
(setq-default bidi-display-reordering 'left-to-right)
(setq bidi-inhibit-bpa t)

(put 'upcase-region 'disabled nil) (put 'downcase-region 'disabled nil)

(blink-cursor-mode 0)
(delete-selection-mode 1)
(electric-pair-mode 1)
(fringe-mode 0)

(setq recentf-save-file "~/.emacs.d/onemacs-cache/recentf")  ;; NOTE - hardcoding the path
(setq savehist-file     "~/.emacs.d/onemacs-cache/history")  ;; NOTE - hardcoding the path
(recentf-mode 1) (savehist-mode 1)  ;; NOTE - to del M-x history go to onemacs-cache & delete the "history" file

(global-auto-revert-mode)           ;; auto refresh file buffers when the file on disk changes outside of emacs
(global-visual-wrap-prefix-mode)    ;; wrapped lines respect the indentation of the original file
(global-display-line-numbers-mode)  ;; TODO - may want to use a hook to enable in certain modes only - helps with performance
(global-hl-line-mode)

;; @check TODO - done by AI
;; creating the necessary directories
(defconst my-cache-dir (expand-file-name "onemacs-cache/" user-emacs-directory))
(dolist (dir '("backups" "autosave" "auto-save-list")) (make-directory (expand-file-name dir my-cache-dir) t))

;; for backups/autosave/etc
(setq backup-directory-alist `(("." . ,(expand-file-name "onemacs-cache/backups/" user-emacs-directory))))

;; for when emacs crashes
;; these are not backups , it is a crash recovery file
;; these are created while you are editing
(setq auto-save-file-name-transforms `((".*" ,(expand-file-name "onemacs-cache/autosave/" user-emacs-directory) t)))

;; emacs maintains a list of active auto-save files
;; exist so emacs can find recovery files
(setq auto-save-list-file-prefix
    (expand-file-name "onemacs-cache/auto-save-list/.saves-"
            user-emacs-directory))


;; ==============================================================================================================
;; @topic FUNCTIONS / VARIABLES - PART 1
;; ==============================================================================================================
;; NOTE - Functions / Variables that need to be defined asap

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; @check TODO - done by AI
(defun onncera-highlight-todo ()
    "Highlight important annotation keywords"
    (font-lock-add-keywords nil `((,(concat "\\<" (regexp-opt '("TODO" "FIXME" "BUG" "NOTE")) "\\>")
        0
        '(:foreground "red" :weight bold)
        t
            )
        )
    )
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; @check TODO - done by AI
(defun onncera-smart-beginning-of-line ()
    "moves cursor to first non-whitespace char or beg of line. alternates if called repeatedly"
    (interactive)
    (let ((old-point (point)))
        (back-to-indentation)
        (when (= old-point (point))
            (beginning-of-line)
        )
    )
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; @check TODO - done by AI
(defun onncera-set-up-whitespace-handling ()
    "whitespace mode with trailing line protection"
    (interactive)
    (whitespace-mode)
        (setq-local delete-trailing-lines nil)  ;; stops emacs from deleting empty lines at the bottom of file
        (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; https://www.youtube.com/watch?v=M7-dJb2GTN4 (sacha chua & omar antolin camarena)
;; block-undo (undo keyboard macros in a single step)
(defun block-undo (fn &rest args)
    "Apply FN to ARGS in such a way that it can be undone in a single step"
    (undo-boundary)
    (with-undo-amalgamate
        (apply fn args)
    )
)

(dolist (fn '(
                kmacro-call-macro
                kmacro-exec-ring-item
                apply-macro-to-region-lines
            )
        )
    (advice-add fn :around 'block-undo)
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; @check TODO - done by AI
(defun onncera-set-hl-line-color ()
    "select a color and set it as the hl-line background"
    (interactive)
    (require 'facemenu)
    (let ((color (completing-read
            "HL-line color: "
            (defined-colors)
        )
        )
        )
    (set-face-attribute 'hl-line nil :background color)
    (message "hl-line background set to: %s" color)
    )
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;; @check TODO - done by AI
(defvar onncera-term-shell "/bin/bash" "The default shell path used for custom terminal commands")
(defun onncera-ansi-term ()
    "Launch `ansi-term` instantly using `onncera-term-shell` without prompting"
    (interactive)
    (ansi-term onncera-term-shell)
)
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~






