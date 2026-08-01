;; -*- lexical-binding: t; -*-

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)

(require 'package)
(setq package-archives '(
    ("melpa" . "https://melpa.org/packages/") ("elpa" . "https://elpa.gnu.org/packages/")
        )
)

;; we make use of melpa the most so we priortise that first
(setq package-archive-priorities '(("melpa" . 10) ("elpa" . 5)))

(unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))
(require 'use-package)

(defvar onncera-gc-cons-threshold (* 32 1024 1024))
(defvar onncera-gc-cons-percentage 0.1)

;; restore GC limits after startup completes
(add-hook 'emacs-startup-hook
    (lambda ()
        (setq gc-cons-threshold       onncera-gc-cons-threshold)
        (setq gc-cons-percentage      onncera-gc-cons-percentage)
        (setq file-name-handler-alist onncera-file-name-handler-alist)))

;; disable GC completely while typing in M-x or minibuffer prompts
(add-hook 'minibuffer-setup-hook (lambda () (setq gc-cons-threshold most-positive-fixnum)))
(add-hook 'minibuffer-exit-hook  (lambda () (setq gc-cons-threshold onncera-gc-cons-threshold)))

(add-to-list 'exec-path "/opt/homebrew/bin")
(add-to-list 'default-frame-alist '(fullscreen . fullboth))

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
(setq completions-detailed t)                   ;; annotations (marginalia replacement)
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

(defun onncera-highlight-todo ()
    (font-lock-add-keywords nil `((,(concat "\\<" (regexp-opt '("TODO" "FIXME" "BUG" "NOTE")) "\\>")
        0
        '(:foreground "red" :weight bold)
        t
            )
        )
    )
)

(defun onncera-smart-beginning-of-line ()
    "moves cursor to first non-whitespace char or beg of line - alternates"
    (interactive)
    (let ((old-point (point)))
        (back-to-indentation)
        (when (= old-point (point))
            (beginning-of-line)
        )
    )
)

(defun onncera-create-ansi-term () "Launch 'ansi-term' instantly using bash as the default shell"
    (interactive)
    (ansi-term "/bin/bash"))

(set-face-attribute 'default nil        :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
(set-face-attribute 'fixed-pitch nil    :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
(set-face-attribute 'variable-pitch nil :family "Merriweather" :height 140)

(load-theme 'modus-operandi-tinted t)



(use-package orderless
    :ensure t
    :config
    (setq completion-styles '(orderless basic)
            )
)



(setq whitespace-style
    '(face indentation newline tabs tab-mark trailing
        spaces
        space-before-tab
        space-after-tab
        space-mark
    )
)

;; reads a .editorconfig file from project root to apply formatting preferences
;; such as spaces vs tabs, indentation width, whitespace rules, etc.
;; It does not control emacs indentation behavior or TAB/RET key actions
(editorconfig-mode 1)
(electric-indent-mode 0)

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(use-package git-gutter :ensure t :hook (prog-mode . git-gutter-mode))
(use-package magit      :ensure t :defer t)

;; NOTE - give packages their own section if they require configuration
(use-package avy           :ensure t :defer t)  ;; TODO - swap out for flash?
(use-package casual        :ensure t :defer t)  ;; TODO - do up a maximalist setup
(use-package expand-region :ensure t :defer t)

(use-package javelin :ensure t
    :config (setcdr javelin-minor-mode-map nil) (global-javelin-minor-mode))

(use-package imenu
    :config (setq imenu-auto-rescan t) (setq imenu-level-separator "/") (setq imenu-max-item-no-type 0))

(use-package multiple-cursors :ensure t :defer t
    :init (setq mc/list-file "~/.emacs.d/onemacs-cache/mc-lists.el"))

(use-package vundo   :ensure t :defer t)
(use-package undo-fu :ensure t
    :bind (
    ("C-/" . undo-fu-only-undo)
    ("C-?" . undo-fu-only-redo)
    )
)


(use-package undo-fu-session
    :ensure t
    :init
    (setq undo-fu-session-directory
        (expand-file-name "onemacs-cache/undo-fu-session/" user-emacs-directory))
    (setq undo-fu-session-incompatible-files '
        ("/COMMIT_EDITMSG\\'" "/git-rebase-todo\\'"))

    :config
    (undo-fu-session-global-mode)
    )

(add-hook 'prog-mode-hook 'onncera-highlight-todo)
(add-hook 'prog-mode-hook 'whitespace-mode)

(use-package keycast
    :ensure t
    :config
    (keycast-tab-bar-mode) (setq keycast-window-predicate 'always) (setq keycast-substitute-alist '()))  ;; TODO replace with view lossage emacs 31

(use-package which-key
    :config
    (setq which-key-show-early-on-C-h t)
    (setq which-key-idle-delay 1e6)
    (setq which-key-idle-secondary-delay 0.05)
    (which-key-mode))

(defvar onncera-a-map (make-sparse-keymap) "onncera C-c a prefix")
(global-set-key (kbd "C-c a") onncera-a-map)
(define-key onncera-a-map (kbd "i") #'imenu)
(define-key onncera-a-map (kbd "t") #'onncera-toggle-ansi-term)
(define-key onncera-a-map (kbd "T") #'onncera-create-ansi-term)

(global-set-key (kbd "M-o") 'other-window)

(global-set-key [remap move-beginning-of-line] 'onncera-smart-beginning-of-line)

(dotimes (i 10)
    (dolist (prefix '("C-" "M-" "C-M-"))
        (global-unset-key (kbd (format "%s%d" prefix i)))))

(global-unset-key (kbd "<end>"   ))      ;; this is the 'end'       key on my logitech keyboard
(global-unset-key (kbd "<prior>" ))      ;; this is the 'page up'   key on my logitech keyboard
(global-unset-key (kbd "<help>"  ))      ;; this is the 'insert'    key on my logitech keyboard
(global-unset-key (kbd "<home>"  ))      ;; this is the 'home'      key on my logitech keyboard
(global-unset-key (kbd "<next>"  ))      ;; this is the 'page down' key on my logitech keyboard
(global-unset-key (kbd "<deletechar>"))  ;; this is the 'delete'    key on my logitech keyboard

(dolist (key '("<end>" "<prior>" "<help>" "<home>" "<next>" "<delete>" "<deletechar>"))
    (dolist (prefix '("" "C-" "M-" "C-M-"))
        (global-unset-key (kbd (format "%s%s" prefix key)))))

(dotimes (i 7)
    (let ((f-key (format "<f%d>" (+ i 9))))
        (dolist (prefix '("" "C-" "M-" "S-" "C-M-"))
            (global-unset-key (kbd (format "%s%s" prefix f-key))))))

;; TODO - place this in bashrc (alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs") - beware renamed applicaton
;; so that when we want to have a look at what vanilla
;; emacs original keybindings are , you can just run "emacs -Q" in the terminal

;; ORDER
;; - expand-region
;; - avy
;; - Jumping by function
;; - sexp - balanced expression
;; - xref
;; - multiple-cursors
;; - version control - programming navigation workflow

(pcase-dolist (`(,key . ,cmd)
                  '(
                       ("<prior>"      . move-text-up)              ;; 'page up'
                       ("<next>"       . move-text-down)            ;; 'page down'
                       ("<home>"       . er/expand-region)          ;; 'home'
                       ("<end>"        . er/contract-region)        ;; 'end'
                       ("<help>"       . git-gutter:previous-hunk)  ;; 'insert'
                       ("<deletechar>" . git-gutter:next-hunk)      ;; 'delete'

                       ;; Future Modified Keys (just uncomment and fill in as you go!)
                       ;; ("C-<home>"  . onncera-custom-command-one)  ;; CTRL + 'home'
                       ;; ("M-<next>"  . onncera-custom-command-two)  ;; ALT  + 'page down'

                       ))
    (global-set-key (kbd key) cmd))

(setq avy-timeout-seconds 1.0)
(pcase-dolist (`(,key . ,cmd)
                  '(
                       ("C-0"   . avy-goto-char-timer)  ;; input an arbitrary amount of consecutive chars
                       ("M-0"   . avy-goto-char)        ;; input one  char  , jump to it with a tree
                       ("C-M-0" . avy-goto-line)        ;; input zero chars , jump to a line start with a tree

                       ("C-1"   . end-of-defun)
                       ("C-2"   . beginning-of-defun)
                       ("C-3"   . mark-defun)

                       ("C-4"   . backward-sexp)
                       ("C-5"   . forward-sexp)
                       ("C-6"   . mark-sexp)

                       ("C-7"   . xref-go-back)
                       ("C-8"   . xref-find-definitions)
                       ("C-9"   . xref-find-references)

                       ))
    (global-set-key (kbd key) cmd))

(pcase-dolist (`(,key . ,cmd)
                  '(
                       ;; Javelin
                       ("<f9>"   . javelin-go-or-assign-to-1)
                       ("<f10>"  . javelin-go-or-assign-to-2)
                       ("<f11>"  . javelin-go-or-assign-to-3)
                       ("<f12>"  . javelin-go-or-assign-to-4)
                       ("<f13>"  . javelin-delete)                 ;; delete a specific position for the current project/branch
                       ("<f14>"  . javelin-clear)                  ;; delete all positions for current project/branch
                       ("<f15>"  . javelin-toggle-quick-menu)

                       ;; Multiple Cursors
                       ("C-<f9>"  . mc/mark-previous-like-this)    ;; NOTE - need to select a region
                       ("C-<f10>" . mc/mark-next-like-this)        ;; NOTE - need to select a region
                       ("C-<f11>" . mc/skip-to-previous-like-this)
                       ("C-<f12>" . mc/skip-to-next-like-this)
                       ("C-<f13>" . mc/mark-all-symbols-like-this-in-defun)
                       ("C-<f14>" . mc/vertical-align-with-space)  ;; NOTE - select a region & add MCs with 'edit-lines' , then move to the end of the line and run this command
                       ("C-<f15>" . mc/edit-lines)

                       ;; Magit
                       ("M-<f9>"  . magit-log-buffer-file)

                       ))
    (global-set-key (kbd key) cmd))

;; > flex  (https://github.com/kn66/flex-x)
;; > flash (https://github.com/Prgebish/flash)
;; > yuta  (https://github.com/zenitsu7772000/yuta.el)

(use-package dired
    :config (setq delete-by-moving-to-trash t))
(use-package ediff
    :config
    (setq ediff-split-window-function 'split-window-horizontally)
    (setq ediff-window-setup-function 'ediff-setup-windows-plain)
        )
(use-package isearch
    :config
    (setq isearch-lazy-count t)
    (setq lazy-count-prefix-format "(%s/%s) "))

(set-face-attribute 'italic nil :slant 'normal)
