;; -*- lexical-binding: t; -*-

;; flow:
;; X - CUSTOM FILE
;; XX - PACKAGE MANAGEMENT
;; XXX - GENERAL SETTINGS
;; XXXX - FUNCTIONS - PART 1
;; XXXXX - THEMES / FONTS / APPEARANCES
;; XXXXXX - COMPLETIONS / MINIBUFFER
;; XXXXXXX - PROGRAMMING
;; XXXXXXXX - CONVENIENCE
;; XXXXXXXXX - FUNCTIONS - PART 2
;; XXXXXXXXXX - HOOKS
;; XXXXXXXXXXX - KEYBINDINGS
;; XXXXXXXXXXXX - TESTING PLAYGROUND

;; TODO - sub topics for imenu
;; e.g. @ subtopic 1
;; e.g. @ subtopic 2
;; e.g. etc

;; ================================================================================
;; @topic CUSTOM FILE
;; ================================================================================
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file t)


;; ================================================================================
;; @topic PACKAGE MANAGEMENT
;; ================================================================================
(require 'package)
(setq package-archives '(
    ("melpa" . "https://melpa.org/packages/") ("elpa" . "https://elpa.gnu.org/packages/")
            )
)

(unless (package-installed-p 'use-package) (package-refresh-contents) (package-install 'use-package))
(require 'use-package)


;; ================================================================================
;; @topic GENERAL SETTINGS
;; ================================================================================
(add-to-list 'exec-path "/opt/homebrew/bin")
(setenv "PATH" (concat "/opt/homebrew/bin:" (getenv "PATH")))  ;; @check TODO - recommended by AI (remove?)

;; NOTE - for variables we use 't' or 'nil'
;; NOTE - for functions we use numbers (1 == enabled , 0 == disabled , no number means toggle)
(setq inhibit-splash-screen t)
(setq insert-directory-program "gls")
(setq enable-recursive-minibuffers t)
(setq lossage-size 1000)
(setq locate-command "mdfind")
(setq display-line-numbers-type 'relative)

(setq-default truncate-lines t)
(setq-default tab-width 4)
(setq-default indent-tabs-mode nil)

(put 'upcase-region 'disabled nil) (put 'downcase-region 'disabled nil)

(blink-cursor-mode 0)
(delete-selection-mode 1)
(electric-pair-mode 1)
(fringe-mode 0)

(recentf-mode 1) (savehist-mode 1)  ;; NOTE - to del M-x history go to onemacs-cache & delete the "history" file
(setq recentf-save-file "~/.emacs.d/onemacs-cache/recentf")  ;; NOTE - hardcoding the path
(setq savehist-file     "~/.emacs.d/onemacs-cache/history")  ;; NOTE - hardcoding the path

(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)

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


;; ================================================================================
;; @topic FUNCTIONS - PART 1
;; ================================================================================
;; NOTE - part one because some functions need to be defined earlier than others

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun onncera-standard-tab ()
    "tabs dwim - literally insert 4 spaces - not indentation"
    (interactive) (insert "    ")
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun onncera-set-up-whitespace-handling ()
    "whitespace mode with trailing line protection"
    (interactive)
    (whitespace-mode)
        (setq-local delete-trailing-lines nil)  ;; stops emacs from deleting empty lines at the bottom of file
        (add-hook 'before-save-hook #'delete-trailing-whitespace nil t)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic THEMES / FONTS / APPEARANCES
;; ================================================================================
(use-package ef-themes       :ensure t :defer t) (use-package modus-themes :ensure t :defer t)
(use-package standard-themes :ensure t :defer t) (use-package doric-themes :ensure t :defer t)
(use-package doom-themes     :ensure t :defer t)

(use-package gruber-darker-theme     :ensure t :defer t)
(use-package jetbrains-darcula-theme :ensure t :defer t)

;; NOTE - these packages tend to break more often (beware)
(use-package pixel-themes  :vc (:url "https://github.com/lucasobx/pixel-themes"      :rev :newest))
(use-package nerv-theme    :vc (:url "https://github.com/Senka07/nerv_theme.el"      :rev :newest))
(use-package turbo-c-theme :vc (:url "https://github.com/Senka07/turboc-emacs-theme" :rev :newest))

;; NOTE - breaks my emacs (weird)
;; (use-package nvim-dark-theme
;;     :vc (:url "https://github.com/mang-jin/emacs-theme-nvim-dark"
;;     :rev :newest)
;;     )

;; @check TODO - done by AI
(defun onemacs-load-theme (themes)
    "disable current themes and load THEME cleanly"
    (interactive
    (list (intern (completing-read
        "Theme: "
        (custom-available-themes)
    )
    )
    )
    )

    (mapc #'disable-theme custom-enabled-themes)  ;; disable all active themes
    (load-theme themes t)  ;; load the requested theme
    (onemacs-apply-fonts)  ;; reapply personal faces (fonts)
)

(defun onemacs-apply-fonts ()
    "apply personal font configuration"
    (set-face-attribute 'default nil        :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
    (set-face-attribute 'fixed-pitch nil    :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
    (set-face-attribute 'variable-pitch nil :family "Merriweather" :height 140)
    (set-face-attribute 'completions-annotations nil :slant 'normal)
    (set-face-attribute 'completions-common-part nil :slant 'normal)
)

(add-to-list 'custom-theme-load-path
        (expand-file-name "onemacs-theme" user-emacs-directory)
    )
(onemacs-load-theme 'gruber-darker)  ;; here is where you declare what theme to use

;; @check TODO - done by AI
;; NOTE - not sure if I still want to include this
;; (defun onncera/theme-settings-veto-general ()
;; "remove italics , disable bold , set highlight line color"
;; (dolist (face (face-list)) (when (face-attribute face :slant nil 'default) (set-face-attribute face nil :slant 'normal)))
;;     ;; disable italics
;;     (set-face-attribute 'font-lock-comment-face nil
;;         :slant 'normal)
;;     (set-face-attribute 'font-lock-doc-face nil
;;         :slant 'normal)
;;     (set-face-attribute 'italic nil
;;         :slant 'normal)
;;     ;; disable bold
;;     (set-face-attribute 'bold nil
;;         :weight 'normal)
;;     ;; hl-line
;;     (when (facep 'hl-line) (set-face-attribute 'hl-line nil :background "midnight blue"))
;; )

;; (defun onncera/theme-settings (&rest _) "run theme overrides safely after theme changes"
;;     (run-at-time 0 nil (lambda () (onncera/theme-settings-veto-general)  ;; Implement for every single theme
;;         )
;;     )
;; )

;; (advice-add 'load-theme   :after #'onncera/theme-settings)
;; (advice-add 'enable-theme :after #'onncera/theme-settings)


;; ================================================================================
;; @topic COMPLETIONS / MINIBUFFER
;; ================================================================================
;; - NOTE : dependencies
;; > grep
;; > ripgrep

;;;; HELM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - NOTE: C-o does the toggling in helm-mode
;; - NOTE: currently using which-key.. to use helm-descbinds, uncomment use-package block below

;; - NOTE: the reason we do not turn on "helm-mode" is because we only want to use helm for certain things
;; - NOTE: this prevents it from interfering with other completion systems

;; - TODO: INCLUDE THE FOLLOWING MODULES === HELM-PROJECTILE, HELM-SWOOP, helm-M-x-show-short-doc
(use-package helm-describe-modes :ensure t)
(use-package helm
    :ensure t
    :config
    (require 'helm-buffers)
    (require 'helm-imenu)
    :bind (:map helm-map
        ("TAB" . helm-execute-persistent-action)
        ("C-j" . helm-select-action)
    )
)

;; (use-package helm-descbinds
;;     :ensure t
;;     :init (helm-descbinds-mode) (setq prefix-help-command #'helm-descbinds)
;; )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; VOMECCC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package marginalia :ensure t :config (setq marginalia-align 'right) (marginalia-mode))
(use-package orderless  :ensure t
    :config
    (setq completion-styles '(orderless basic)
            )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package vertico :ensure t
    :config
    (require 'vertico-multiform)
    (vertico-mode)
    (vertico-multiform-mode)
    (setq vertico-multiform-categories '((file (vertico-sort-function . onncera-vertico-find-file))))
    (setq vertico-multiform-commands '(
        (consult-find buffer)
        (consult-grep buffer)
        (consult-line buffer)
        (imenu buffer)
        )
    )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - If you want to replace helm-descbinds:
;; "setq prefix-help-command #'embark-prefix-help-command"
(use-package embark-consult :ensure t)
(use-package embark         :ensure t)

;; TODO - move to the keybinding section or put it under the embark use-package
(use-package emacs
    :bind (("C-," . embark-act) ("C-." . embark-dwim))
                                )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - Typical workflow:
;; - consult-ripgrep : "what you are looking for". Transient. once you select a line, other matches gone
;; - deadgrep		 : creates a dedicated persistent buffer for your search results using ripgrep
;; - wgrep			 : allows you to make a search result buffer editable
(use-package consult        :ensure t)
(use-package deadgrep       :ensure t)
(use-package wgrep          :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package corfu
    :ensure t
    :config
    (setq corfu-auto t)                ;; disable automatic popup (toggles between t & nil)
    (setq corfu-auto-delay 0.1)
    (setq corfu-auto-prefix 2)
    (setq corfu-cycle t)
    (setq corfu-quit-at-boundary nil)  ;; never quit at completion boundary
    (setq corfu-quit-no-match t)       ;; Quit if no match
    (corfu-popupinfo-mode)             ;; popup information (like company-box)
    (global-corfu-mode)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package cape
    :ensure t
    :config
    (defun onncera/cape-capf-setup ()
    (setq-local completion-at-point-functions
    (list
    (cape-capf-super
        ;; #'eglot-completion-at-point  ;; uncomment if you want to use LSP
        #'cape-file
        #'cape-dabbrev)
        #'cape-keyword
    )
    )
    )
    :hook (eglot-managed-mode . onncera/cape-capf-setup) (prog-mode . onncera/cape-capf-setup)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic PROGRAMMING
;; ================================================================================
;; - NOTE : dependencies
;; > brew install basedpyright
;; > brew install llvm

;;;; TREESITTER
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - we are using TS so take note of how we modify certain modes
;; NOTE - once grammars installed, move ---> "~/.emacs.d/onemacs-cache/onemacs-language-grammars"
(setq treesit-extra-load-path '("~/.emacs.d/onemacs-cache/onemacs-language-grammars"))
(use-package treesit-auto
    :ensure t
    :config
    (setq treesit-auto-install 'prompt)
    (treesit-auto-add-to-auto-mode-alist 'all)
    (global-treesit-auto-mode)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; TABS / INDENTS / SPACES / WHITESPACES / ETC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq whitespace-style
    '(face indentation newline tabs tab-mark trailing
        spaces
        space-before-tab
        space-after-tab
        space-mark
    )
)

(setq-default c-basic-offset 4)
(setq-default c-ts-mode-indent-offset 4)
(setq-default python-indent-offset 4)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; PYTHON
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package pyvenv :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; GIT / VC / MAGIT / ETC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package git-gutter :ensure t :hook (prog-mode . git-gutter-mode))
(use-package magit      :ensure t :defer t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; EGLOT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package eglot
    :hook
    (
        (python-ts-mode . eglot-ensure)
        (c-ts-mode      . eglot-ensure)
    )

    :config
    (setq eglot-ignored-server-capabilities '(:inlayHintProvider))

    (add-to-list 'eglot-server-programs
                 '(python-ts-mode . ("basedpyright-langserver" "--stdio")
    )
    )

    (add-to-list 'eglot-server-programs
                 '(c-ts-mode      . ("clangd")
    )
    )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; DOCUMENTATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package devdocs    :ensure t
    :config
    (setq devdocs-browser-function #'eww)  ;; force eww renderer (this is to help with font display)
    ;; make html inherit emacs faces
    (setq shr-use-fonts  nil)
    (setq shr-use-colors nil)
    (setq devdocs-data-dir (expand-file-name "onemacs-cache/devdocs" user-emacs-directory)
)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; PROJECTILE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package projectile :ensure t
    :config
    (setq projectile-known-projects-file "~/.emacs.d/onemacs-cache/projectile-bookmarks.eld")  ;; TODO - is this right?
    (projectile-mode)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic CONVENIENCE
;; ================================================================================
;; - NOTE : dependencies
;; > brew install pkg-config poppler autoconf automake

;;;; AVY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package avy :ensure t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; DISABLE MOUSE (INHIBIT)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package inhibit-mouse
    :ensure t
    :config
    (setq inhibit-mouse-excluded-modes '(pdf-view-mode devdocs-mode))  ;; can use mouse in these modes
    (inhibit-mouse-mode 1)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; KEYCAST
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package keycast :ensure t
    :config
    (keycast-tab-bar-mode)
    (setq keycast-window-predicate #'always)
    (setq keycast-substitute-alist '())
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; WHICH-KEY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package which-key
    :config
    (setq which-key-show-early-on-C-h t)
    (setq which-key-idle-delay 1e6)
    (setq which-key-idle-secondary-delay 0.05)
    (which-key-mode)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; ENVIRONMENT VARIABLES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package exec-path-from-shell
    :ensure t
    :if (and (display-graphic-p)
        (eq system-type 'darwin))
    :demand t
    :config
    (setq exec-path-from-shell-variables '("PATH"))
    (exec-path-from-shell-initialize)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; MULTIPLE CURSORS (MC)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package multiple-cursors :ensure t :defer t
    :init (setq mc/list-file "~/.emacs.d/onemacs-cache/mc-lists.el")
    :bind (
    ("M-p" . mc/mark-previous-like-this   )
    ("M-n" . mc/mark-next-like-this       )
    ("C-<" . mc/skip-to-previous-like-this)
    ("C->" . mc/skip-to-next-like-this    )
    )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; MOVE TEXT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package move-text
    :ensure t
    :bind (
        ("M-<down>" . move-text-down)
        ("M-<up>"   . move-text-up)
    )
    :config
    ;; Function advice to have Emacs re-indent the text in-and-around a text move
    (defun my/move-text-indent-region-advice (&rest _ignored)
        (let ((deactivate deactivate-mark))
            (if (region-active-p)
                (indent-region (region-beginning) (region-end))
                (indent-region (line-beginning-position) (line-end-position)))
            (setq deactivate-mark deactivate)))
    (advice-add 'move-text-up   :after #'my/move-text-indent-region-advice)
    (advice-add 'move-text-down :after #'my/move-text-indent-region-advice)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; UNDO / REDO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic FUNCTIONS - PART 2
;; ================================================================================
;; NOTE - part two because some functions should only be defined at later stages

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun onncera-vertico-find-file (candidates)
"Sort CANDIDATES by dotfiles first, then dot-dirs, then files, then dirs (all in alphabetical order)"
    ;; speed up file operations during sorting.. emacs has a ton of background checks. Turn them off
    (let ((file-name-handler-alist nil))
        (sort candidates
        (lambda (a b)
        (let* (
            (a-dot (string-prefix-p "." a))  ;; checks if file "a" starts with a dot. If it does, true
            (b-dot (string-prefix-p "." b))  ;; do the same for the below
            (a-dir (string-suffix-p "/" a))  ;; so for any two items, emacs knows is it a dotfile or a dir
            (b-dir (string-suffix-p "/" b))
        )

        (cond  ;; now we have our sorting rules
        ;; rule 1 : place "." and ".." always stay at the very top
        ((string-match-p "\\`\\.\\.?/\\'" a) t)
        ((string-match-p "\\`\\.\\.?/\\'" b) nil)

        ;; rule 2 : priortise dotfiles over regular files
        ((and a-dot (not b-dot)) t)
        ((and (not a-dot) b-dot) nil)


        ;; rule 3 : Within dotfiles, prefer files over directories
        ((and a-dot b-dot)
            (if (and (not a-dir) b-dir) t
                (if (and a-dir (not b-dir)) nil
                    (string< a b))))

        ;; rule 4 : Within regular files, prefer files over directories
        (t
            (if (and (not a-dir) b-dir) t
                (if (and a-dir (not b-dir)) nil
                    (string< a b))))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic HOOKS
;; ================================================================================
(add-hook 'emacs-startup-hook #'split-window-horizontally)
(add-hook 'emacs-startup-hook #'toggle-frame-fullscreen t)
(add-hook 'prog-mode-hook #'onncera-highlight-todo)
(add-hook 'prog-mode-hook #'onncera-set-up-whitespace-handling)

(add-hook 'emacs-lisp-mode-hook
    (lambda ()
        (setq-local imenu-generic-expression '(
            ("topics" "^;; @topic[[:space:]]+\\(.+\\)$"    1)
            ("functions" "^(defun[[:space:]]+\\([^ ]+\\)"  1)
            ("variables" "^(defvar[[:space:]]+\\([^ ]+\\)" 1)
            ("custom" "^(defcustom[[:space:]]+\\([^ ]+\\)" 1)
        )
        )
    )
)


;; ================================================================================
;; @topic KEYBINDINGS
;; ================================================================================
;; NOTE - builtin commands are bound directly
;; NOTE - package-specific commands are wrapped in (with-eval-after-load 'package-feature ...)
;;        to stay safe regardless of load order / deferred loading

;; super cool and important commands/keybindings:
;; > view-lossage            (C-h l)
;; > view-echo-area-messages (C-h e)

;;;; a-map
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defvar onncera/a-map (make-sparse-keymap) "onncera C-c a prefix")
(global-set-key (kbd "C-c a") onncera/a-map)
(define-key onncera/a-map (kbd "a") #'avy-goto-char)
(define-key onncera/a-map (kbd "c") #'completion-at-point)  ;; corfu provides the UI, command is builtin
(define-key onncera/a-map (kbd "h") #'view-lossage)
(define-key onncera/a-map (kbd "q") #'onncera-standard-tab)
(define-key onncera/a-map (kbd "s") #'avy-goto-line)
(define-key onncera/a-map (kbd "t") #'ansi-term)

;; example for non builtin commands
;; b - (reserved, example only, uncomment + fill in when needed)
;; (with-eval-after-load 'magit
;;   (define-key onncera/a-map (kbd "b") #'magit-status))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; remaps
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [remap move-beginning-of-line] 'onncera-smart-beginning-of-line)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ================================================================================
;; @topic TESTING PLAYGROUND
;; ================================================================================

;; NOTE - packages to explore more:
;; > nucleo (https://github.com/kn66/nucleo-completion.el)
;; > yuta   (https://github.com/zenitsu7772000/yuta.el)

;;;; RANDOM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package weyland-yutani-theme :ensure t :defer t)
(use-package naysayer-theme       :ensure t :defer t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; COLORFUL MODE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package colorful-mode :ensure t
    :hook
    (prog-mode . colorful-mode)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; ISEARCH
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; taken from prot (https://protesilaos.com/codelog/2026-04-30-emacs-decent-default-sacha-chua/)
(use-package isearch
    :config
    (setq search-whitespace-regexp ".*?")
    (setq isearch-lax-whitespace t)
    (setq isearch-regexp-lax-whitespace nil)
    (setq isearch-lazy-count t)
    (setq lazy-count-prefix-format "(%s/%s) ")
    (setq lazy-count-suffix-format nil)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; DIRED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; taken from prot (https://protesilaos.com/codelog/2026-04-30-emacs-decent-default-sacha-chua/)
(use-package dired
    :config
    (setq delete-by-moving-to-trash t)
    (setq dired-create-destination-dirs 'ask)
    (setq dired-create-destination-dirs-on-trailing-dirsep t)  ;; emacs 29
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;; EDIFF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; taken from prot (https://protesilaos.com/codelog/2026-04-30-emacs-decent-default-sacha-chua/)
(use-package ediff
    :config
    (setq ediff-split-window-function 'split-window-horizontally)
    (setq ediff-window-setup-function 'ediff-setup-windows-plain)
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

