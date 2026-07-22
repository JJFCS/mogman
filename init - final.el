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
;; @topic PERFORMANCE
;; ==============================================================================================================
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
    "moves cursor to first non-whitespace char or beg of line - alternates"
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
(defun onncera-set-up-whitespace-handling ()
    (interactive)
    (whitespace-mode)
        (setq-local delete-trailing-lines nil)  ;; stops emacs from deleting empty lines at the bottom of file
        (add-hook 'before-save-hook 'delete-trailing-whitespace nil t)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun onncera-helm-imenu-right ()
    "run helm-imenu with the Helm window on the right"
    (interactive)
    (let ((helm-split-window-default-side 'right))
    (helm-imenu)
    )
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
    "Launch 'ansi-term' instantly using 'onncera-term-shell' without prompting"
    (interactive)
    (ansi-term onncera-term-shell)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic THEMES / FONTS / APPEARANCES
;; ==============================================================================================================
(use-package pixel-themes :defer t :vc (:url "https://github.com/lucasobx/pixel-themes"))

;; @check TODO - done by AI
;; TODO - make comments and doc strings use 'Iosevka' font?
(defun onemacs-apply-fonts ()
    "apply personal font configuration"
    (set-face-attribute 'default nil        :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
    (set-face-attribute 'fixed-pitch nil    :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
    (set-face-attribute 'variable-pitch nil :family "Merriweather" :height 140)
    (set-face-attribute 'completions-annotations nil :slant 'normal)
    (set-face-attribute 'completions-common-part nil :slant 'normal)
)

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

    (mapc 'disable-theme custom-enabled-themes)
    (load-theme themes t)
    (onemacs-apply-fonts)
)

;; @check TODO - done by AI (TOP PRIORITY)
;; plug into claude and check if anything can be improved and work on whitespace colors (errors)
(use-package vscode-dark-plus-theme
    :ensure t
    :config
    (onemacs-load-theme 'vscode-dark-plus)  ;; Load theme & reapply fonts in one shot

    ;; configuring subtle vs error whitespace faces
    (let* ((bg (face-attribute 'default :background))
              (subtle (color-lighten-name bg 40)))  ;; higher number == more visible - vice versa

        ;; Normal visible whitespace (subtle)
        (dolist (face '(
                           whitespace-space
                           whitespace-hspace
                           whitespace-newline
                           whitespace-tab))
            (set-face-attribute face nil
                :foreground subtle
                :background 'unspecified
                :weight     'normal))

        ;; WHITESPACE ERRORS
        (dolist (face '(
                           whitespace-trailing
                           whitespace-indentation
                           whitespace-space-before-tab
                           whitespace-space-after-tab
                           whitespace-empty))
            (set-face-attribute face nil
                :background "#C0392B"
                :foreground "#C0392B"
                :weight 'bold
                :extend t))))


;; ==============================================================================================================
;; @topic COMPLETIONS / MINIBUFFER
;; ==============================================================================================================

;; @subtopic-1 HELM
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; - NOTE: C-o does the toggling in helm-mode
;; - TODO: INCLUDE THE FOLLOWING MODULES === HELM-PROJECTILE, HELM-SWOOP, helm-M-x-show-short-doc
(use-package helm-describe-modes :ensure t :defer t)
(use-package helm
    :ensure t
    :commands (helm-imenu)
    :config
    (require 'helm-buffers)
    (require 'helm-imenu)
    (setq helm-imenu-delimiter " = ")
    :bind (:map helm-map
        ("TAB" . helm-execute-persistent-action)
        ("C-j" . helm-select-action)
    )
)
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
    :vc (:url "https://github.com/kn66/nucleo-completion.el")
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
;; TODO - may be some of these can defer
(use-package avy              :ensure t)
(use-package casual           :ensure t)
(use-package expand-region    :ensure t)
(use-package goto-last-change :ensure t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 HARPOON
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package javelin
    :ensure t
    :config (global-javelin-minor-mode) (setq javelin-minor-mode-map
                                            (make-sparse-keymap))  ;; remove all default keybindings
    )
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 MULTIPLE CURSORS
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package multiple-cursors :ensure t :defer t
    :init (setq mc/list-file "~/.emacs.d/onemacs-cache/mc-lists.el"))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 MOVE TEXT
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO - may be can defer
(use-package move-text
    :ensure t
    :config
    ;; Function advice to have Emacs re-indent the text in-and-around a text move
    (defun onncera-move-text-indent-region-advice (&rest _ignored)
        (let ((deactivate deactivate-mark))
            (if (region-active-p)
                (indent-region (region-beginning) (region-end))
                (indent-region (line-beginning-position) (line-end-position)))
            (setq deactivate-mark deactivate)))
    (advice-add 'move-text-up   :after #'onncera-move-text-indent-region-advice)
    (advice-add 'move-text-down :after #'onncera-move-text-indent-region-advice)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 UNDO / REDO
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 SET & FORGET
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - you can exclude certain modes by using "setq inhibit-mouse-excluded-modes"
(use-package inhibit-mouse :ensure t :config (inhibit-mouse-mode))
(use-package colorful-mode :ensure t :hook (prog-mode . colorful-mode))

(use-package exec-path-from-shell
    :ensure t
    :if (and (display-graphic-p) (eq system-type 'darwin))
    :config (exec-path-from-shell-initialize))

(use-package keycast
    :ensure t
    :config
    (keycast-tab-bar-mode)
    (setq keycast-window-predicate 'always)
    (setq keycast-substitute-alist '()))

(use-package which-key
    :config
    (setq which-key-show-early-on-C-h t)
    (setq which-key-idle-delay 1e6)
    (setq which-key-idle-secondary-delay 0.05)
    (which-key-mode))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic FUNCTIONS / VARIABLES - PART 2
;; ==============================================================================================================
;; NOTE - Functions / Variables that need to be defined at a later stage

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
































































