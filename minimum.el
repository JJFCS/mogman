;; -*- lexical-binding: t; -*-

;; mogman's minimum emacs - mme

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
(set-face-attribute 'default nil        :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
(set-face-attribute 'fixed-pitch nil    :family "MartianMono Nerd Font Mono" :height 140 :width 'condensed :weight 'regular :slant 'normal)
(set-face-attribute 'variable-pitch nil :family "Merriweather" :height 140)

;; @check TODO - done by AI
(use-package vscode-dark-plus-theme
    :ensure t
    :config
    (require 'color)
    (require 'whitespace)

    (defun onncera-vscode-dark-plus-whitespace-faces (theme)
        "apply subtle/error whitespace faces but only for vscode-dark-plus"
        (when (eq theme 'vscode-dark-plus)
            (let* ((bg (face-attribute 'default :background))
                      (subtle (color-lighten-name bg 40))  ;; higher number == more visible - vice versa
                      (warn-color (face-attribute 'error :foreground)))

                ;; normal visible whitespace (subtle)
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
                        :background warn-color
                        :foreground warn-color
                        :weight 'bold
                        :extend t)))))

    (add-hook 'enable-theme-functions 'onncera-vscode-dark-plus-whitespace-faces)
    (load-theme 'vscode-dark-plus t))


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
    (setq helm-split-window-default-side 'right)
    (setq helm-split-window-inside-p t)  ;; split inside the active window rather than the entire frame
    :bind (:map helm-map
        ("TAB" . helm-execute-persistent-action)
        ("C-j" . helm-select-action)
    )
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 VOMCC
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
(use-package corfu :ensure t :config (setq corfu-auto t) (global-corfu-mode))
(use-package cape  :ensure t :config

    (defun onncera-cape-capf-setup-prog ()
        (setq-local completion-at-point-functions
            (list (cape-capf-super #'cape-dabbrev #'cape-file)
                #'cape-keyword)))

    (defun onncera-cape-capf-setup-text ()
        (setq-local completion-at-point-functions
            (list (cape-capf-super #'cape-dabbrev #'cape-dict)
                #'cape-file)))

    :hook
    (prog-mode . onncera-cape-capf-setup-prog)
    (text-mode . onncera-cape-capf-setup-text)

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


;; ==============================================================================================================
;; @topic CONVENIENCE
;; ==============================================================================================================

;; @subtopic-1 AMALGAMATION
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; NOTE - give packages their own section if they require configuration
;; TODO - may be some of these can defer
(use-package avy              :ensure t :defer t)
(use-package casual           :ensure t :defer t)
(use-package expand-region    :ensure t :defer t)
(use-package goto-last-change :ensure t :defer t)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 HARPOON
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package javelin
    :ensure t
    :config
    (setcdr javelin-minor-mode-map nil)  ;; remove all default keybindings
    (global-javelin-minor-mode))
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


;; ==============================================================================================================
;; @topic HOOKS
;; ==============================================================================================================
(add-hook 'prog-mode-hook 'onncera-highlight-todo)
(add-hook 'prog-mode-hook 'whitespace-mode)

;; @subtopic-1 imenu
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
(add-hook
    'emacs-lisp-mode-hook
    (lambda ()
        ;; Save the original index function installed by emacs-lisp-mode.
        (setq-local onncera-original-imenu-create-index-function
                    imenu-create-index-function)

        ;; Replace it with our wrapper.
        (setq-local imenu-create-index-function
                    #'onncera-elisp-imenu-create-index)
    )
)

(defun onncera-elisp-imenu-create-index ()
    "extend the builtin emacs lisp imenu index with custom entries"
    (let ((index (funcall onncera-original-imenu-create-index-function)))
    (append index
        (imenu--generic-function '(
            ("checks"     "^[^\n]*\\(?:@check\\|TODO\\)[[:space:]]+\\(.+\\)$" 1)
            ("topics"     "^[^\n]*@topic[[:space:]]+\\(.+\\)$" 1)
            ("subtopic 1" "^[^\n]*@subtopic-1[[:space:]]+\\(.+\\)$" 1)
        )
        )
    )
    )
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic KEYBINDINGS
;; ==============================================================================================================
;; super cool and important commands/keybindings:
;; > view-lossage            (C-h l)
;; > view-echo-area-messages (C-h e)

;; @subtopic-1 a-map
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; @check TODO - done by AI
(defvar onncera-a-map (make-sparse-keymap) "onncera C-c a prefix")
(global-set-key (kbd "C-c a") onncera-a-map)
(define-key onncera-a-map (kbd "t") #'onncera-ansi-term)

;; example for non builtin commands
;; b - (reserved, example only, uncomment + fill in when needed)
;; (with-eval-after-load 'magit
;;   (define-key onncera-a-map (kbd "b") #'magit-status))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 remaps
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key [remap move-beginning-of-line] #'onncera-smart-beginning-of-line)
(global-set-key [remap imenu] #'onncera-helm-imenu-right)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 reclaiming keys (unset)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; separated into blocks so we can visualise better

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unbind default digit shortcuts (C-0..9, M-0..9, C-M-0..9)
(dotimes (i 10)
    (dolist (prefix '("C-" "M-" "C-M-"))
        (global-unset-key (kbd (format "%s%d" prefix i)))))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-unset-key (kbd "<end>"   ))      ;; this is the 'end'       key on my logitech keyboard
(global-unset-key (kbd "<prior>" ))      ;; this is the 'page up'   key on my logitech keyboard
(global-unset-key (kbd "<help>"  ))      ;; this is the 'insert'    key on my logitech keyboard
(global-unset-key (kbd "<home>"  ))      ;; this is the 'home'      key on my logitech keyboard
(global-unset-key (kbd "<next>"  ))      ;; this is the 'page down' key on my logitech keyboard
(global-unset-key (kbd "<deletechar>"))  ;; this is the 'delete'    key on my logitech keyboard

;; unbind navigation and editing keys across all modifier combinations
(dolist (key '("<end>" "<prior>" "<help>" "<home>" "<next>" "<delete>" "<deletechar>"))
    (dolist (prefix '("" "C-" "M-" "C-M-"))
        (global-unset-key (kbd (format "%s%s" prefix key)))))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; unbind F9-F15 across all modifier combinations (base, C-, M-, S-, C-M-)
(dotimes (i 7)
    (let ((f-key (format "<f%d>" (+ i 9))))
        (dolist (prefix '("" "C-" "M-" "S-" "C-M-"))
            (global-unset-key (kbd (format "%s%s" prefix f-key))))))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; separated into blocks so we can visualise better
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 navigation
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TODO - place this in bashrc (alias emacs="/Applications/Emacs.app/Contents/MacOS/Emacs")
;; so that when we want to have a look at what vanilla
;; emacs original keybindings are , you can just run "emacs -Q" in the terminal

;; ORDER
;; - move-text
;; - expand-region
;; - edited last & mark ring navigation
;; - avy
;; - Jumping by function
;; - sexp - balanced expression
;; - xref
;; - multiple-cursors
;; - version control - programming navigation workflow
;; - embark

;; separated into blocks so we can visualise better
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(pcase-dolist (`(,key . ,cmd)
                  '(
                       ("<prior>"      . move-text-up)         ;; 'page up'
                       ("<next>"       . move-text-down)       ;; 'page down'
                       ("<home>"       . er/expand-region)     ;; 'home'
                       ("<end>"        . er/contract-region)   ;; 'end'
                       ("<help>"       . goto-last-change)     ;; 'insert'
                       ("<deletechar>" . pop-to-mark-command)  ;; 'delete'

                       ;; Future Modified Keys (just uncomment and fill in as you go!)
                       ;; ("C-<home>"  . onncera-custom-command-one)  ;; CTRL + 'home'
                       ;; ("M-<next>"  . onncera-custom-command-two)  ;; ALT  + 'page down'

                       ))
    (global-set-key (kbd key) cmd))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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

                       ;; version control
                       ("M-<f9>"  . git-gutter:previous-hunk)
                       ("M-<f10>" . git-gutter:next-hunk)
                       ("M-<f11>" . git-gutter:popup-hunk)
                       ("M-<f12>" . magit-log-buffer-file)

                       ))
    (global-set-key (kbd key) cmd))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(global-set-key (kbd "C-,") 'embark-act)
(global-set-key (kbd "C-.") 'embark-dwim)
(global-set-key (kbd "M-o") 'other-window)

;; TODO - seems cool..
;; (global-set-key (kbd "M-p") (lambda () (interactive) (previous-logical-line) (recenter)))
;; (global-set-key (kbd "M-n") (lambda () (interactive) (next-logical-line)     (recenter)))
;; (global-set-key (kbd "M-[") (lambda () (interactive) (backward-paragraph)    (recenter)))
;; (global-set-key (kbd "M-]") (lambda () (interactive) (forward-paragraph)     (recenter)))
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; separated into blocks so we can visualise better
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; ==============================================================================================================
;; @topic TESTING PLAYGROUND
;; ==============================================================================================================

;; @subtopic-1 DIRED
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; taken from prot (https://protesilaos.com/codelog/2026-04-30-emacs-decent-default-sacha-chua/)
(use-package dired
    :config
    (setq delete-by-moving-to-trash t)
    (setq dired-create-destination-dirs 'ask)
    (setq dired-create-destination-dirs-on-trailing-dirsep t)  ;; emacs 29
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; @subtopic-1 EDIFF
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; taken from prot (https://protesilaos.com/codelog/2026-04-30-emacs-decent-default-sacha-chua/)
(use-package ediff
    :config
    (setq ediff-split-window-function 'split-window-horizontally)
    (setq ediff-window-setup-function 'ediff-setup-windows-plain)
)
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

