;; -*- lexical-binding: t; -*-

;; mogman's minimal emacs - mme

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

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
(defun onncera-set-up-whitespace-handling ()
    "whitespace mode with trailing line protection"
    (interactive)
    (whitespace-mode)
        (setq-local delete-trailing-lines nil)  ;; stops emacs from deleting empty lines at the bottom of file
        (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
(defvar onncera-term-shell "/bin/bash" "The default shell path used for custom terminal commands")
(defun onncera-ansi-term ()
    "Launch `ansi-term` instantly using `onncera-term-shell` without prompting"
    (interactive)
    (ansi-term onncera-term-shell)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic THEMES / FONTS / APPEARANCES
;; ==============================================================================================================

;; themes that are cool - perhaps in the future
;; - "https://github.com/precompute/hyperstitional-themes"
;; - "https://github.com/precompute/sculpture-themes"
;; - "https://github.com/shaneikennedy/pierre-themes.el"
;; - "https://github.com/Senka07/turboc-emacs-theme"

(use-package ef-themes       :ensure t :defer t) (use-package modus-themes :ensure t :defer t)
(use-package standard-themes :ensure t :defer t) (use-package doric-themes :ensure t :defer t)
(use-package doom-themes     :ensure t :defer t)

(use-package gruber-darker-theme     :ensure t :defer t)
(use-package vscode-dark-plus-theme  :ensure t :defer t)
(use-package pixel-themes                      :defer t :vc (:url "https://github.com/lucasobx/pixel-themes"))

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

    (mapc 'disable-theme custom-enabled-themes)  ;; disable all active themes
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
(onemacs-load-theme 'pixel-themes-alia16)  ;; here is where you declare what theme to use


;; ==============================================================================================================
;; @topic COMPLETIONS / MINIBUFFER
;; ==============================================================================================================

;; @subtopic-1 HELM
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - perhaps we can include helm back in the future (can refer to deprecated)
(use-package helm-describe-modes :ensure t :defer t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 VOMECCC
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package marginalia :ensure t :config (setq marginalia-align 'right) (marginalia-mode))
(use-package orderless  :ensure t
    :config
    (setq completion-styles '(orderless basic)
            )
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
        )
    )
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package embark         :ensure t :defer t)
(use-package embark-consult :ensure t :after (embark consult))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - Typical workflow:
;; - consult-ripgrep : "what you are looking for". Transient. once you select a line, other matches gone
;; - deadgrep        : creates a dedicated persistent buffer for your search results using ripgrep
;; - wgrep           : allows you to make a search result buffer editable
(use-package consult  :ensure t :defer t)
(use-package deadgrep :ensure t :defer t)
(use-package wgrep    :ensure t :defer t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package corfu
    :ensure t
    :config
    (setq corfu-auto t)                     ;; automatic popup (toggles between t & nil)
    (setq corfu-auto-delay 0.1)
    (setq corfu-auto-prefix 2)
    (setq corfu-cycle t)
    (setq corfu-quit-at-boundary nil)       ;; never quit at completion boundary
    (setq corfu-quit-no-match t)
    (setq corfu-sort-override-function nil) ;; let nucleo's score order stand
    (corfu-popupinfo-mode)                  ;; popup information (like company-box)
    (corfu-history-mode)                    ;; needed for sort-ties-by-history (nucleo)
    (global-corfu-mode)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
;; TODO - not happy with LSP setup - do asap!
(use-package cape

    :ensure t
    :config

    (defun onncera-cape-capf-setup-prog ()
        "fallback capf stack for prog-mode buffers before/without an LSP server"
        (setq-local completion-at-point-functions
            (list (cape-capf-super #'cape-file #'cape-dabbrev)
                #'cape-keyword)))

    (defun onncera-cape-capf-setup-lsps ()
        "capf stack once eglot is managing the buffer - LSP first, cape as fallback"
        (setq-local completion-at-point-functions
            (list (cape-capf-super #'eglot-completion-at-point #'cape-keyword)  ;; comment out "#'eglot-completion-at-point" if you do not want LSP
                #'cape-file
                #'cape-dabbrev)))

    (defun onncera-cape-capf-setup-text ()
        "capf stack for prose - text-mode"
        (setq-local completion-at-point-functions
            (list (cape-capf-super #'cape-dabbrev #'cape-dict)
                #'cape-file)))

    :hook
    (prog-mode          . onncera-cape-capf-setup-prog)
    (eglot-managed-mode . onncera-cape-capf-setup-lsps)
    (text-mode          . onncera-cape-capf-setup-text)

)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 NUCLEO
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - NOTE : nucleo is a completion STYLE (like orderless). this overrides the completion-styles set by orderless above
;; - NOTE : orderless is left configured above if you want it back per-category
;;          (e.g. `(setq completion-category-overrides '((consult-grep (styles orderless))))`)
;; - NOTE : this shit HEAVY
(use-package nucleo-completion
    :ensure t
    :vc (:url "https://github.com/kn66/nucleo-completion.el" :rev :newest)
    :demand t
    :init
    (setq nucleo-completion-module-directory
        (expand-file-name "nucleo-completion/" "~/.emacs.d/onemacs-cache/"))
    :config
    (nucleo-completion-ensure-module)  ;; downloads the rust scoring module
    (setq completion-styles '(nucleo basic))  ;; NOTE - may want to include orderless
    (setq completion-category-overrides
        '(
             (eglot      (styles nucleo basic))
             (eglot-capf (styles nucleo basic))
             (file       (styles nucleo basic partial-completion))
         )
    )
    (setq nucleo-completion-sort-ties-by-history     t)
    (setq nucleo-completion-sort-ties-by-length      t)
    (setq nucleo-completion-sort-ties-alphabetically t)
    (setq nucleo-completion-highlight-score-bands    t)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic PROGRAMMING
;; ==============================================================================================================

;; @subtopic-1 TABS / INDENTS / SPACES / WHITESPACES / ETC
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

(setq-default c-basic-offset 4)
(setq-default c-ts-mode-indent-offset 4)
(setq-default python-indent-offset 4)
(setq python-indent-guess-indent-offset nil)  ;; because we are using editorconfig-mode
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 GIT / VC / MAGIT / ETC
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package git-gutter :ensure t :hook (prog-mode . git-gutter-mode))
(use-package magit      :ensure t :defer t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 EGLOT
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
;; TODO - not happy with LSP setup - do asap!
(setq read-process-output-max
    (* 1024 1024))
(setq process-adaptive-read-buffering nil)

(use-package eglot
    :hook
    (
        (python-mode . eglot-ensure)
        (c-mode      . eglot-ensure)
    )

    :config
    (setq eglot-ignored-server-capabilities '(:inlayHintProvider))
    (setq eglot-autoshutdown t)        ;; close the server when the last buffer closes
    (setq eglot-events-buffer-size 0)  ;; don't keep an ever-growing log of every LSP message
    (setq eglot-sync-connect nil)      ;; don't block Emacs while the LSP server starts up

    (add-to-list 'eglot-server-programs
                 '(python-mode . ("basedpyright-langserver" "--stdio")
    )
    )

    (add-to-list 'eglot-server-programs
                 '(c-mode      . ("clangd")
    )
    )
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic CONVENIENCE
;; ==============================================================================================================



;; @subtopic-1 AMALGAMATION
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - give packages their own section if they require configuration
(use-package avy              :ensure t :defer t)
(use-package casual           :ensure t :defer t)
(use-package expand-region    :ensure t :defer t)
(use-package goto-last-change :ensure t :defer t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 JAVELIN
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package javelin
    :ensure t
    :config
    (global-javelin-minor-mode 1)
    (setq javelin-minor-mode-map (make-sparse-keymap))  ;; wipe all default bindings
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 DISABLE MOUSE (INHIBIT)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package inhibit-mouse
    :ensure t
    :config
    (setq inhibit-mouse-excluded-modes '(pdf-view-mode devdocs-mode))  ;; can use mouse in these modes
    (inhibit-mouse-mode 1)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 KEYCAST
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package keycast :ensure t
    :config
    (keycast-tab-bar-mode)
    (setq keycast-window-predicate #'always)
    (setq keycast-substitute-alist '())
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 WHICH-KEY
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package which-key
    :config
    (setq which-key-show-early-on-C-h t)
    (setq which-key-idle-delay 1e6)
    (setq which-key-idle-secondary-delay 0.05)
    (which-key-mode)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;























