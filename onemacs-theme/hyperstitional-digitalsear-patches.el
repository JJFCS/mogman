
;; hyperstitional-digitalsear-patches.el --- personal overrides for digitalsear -*- lexical-binding: t; -*-

;; personal changes layered on top of the 'hyperstitional-themes-digitalsear' theme
;; - glyphs (whitespace-mode) blend into the background (more subtle)
;; - oblique/italics disabled
;; - comment faces keep their colors but lose their background
;; - ansi-term/term-mode colors are remapped to the theme's own palette
;;
;; Usage (in init.el), in this order, before your first `load-theme' call:
;;   (add-to-list 'load-path "/path/to/this/file/")
;;   (require 'hyperstitional-digitalsear-patches)
;;   (load-theme 'hyperstitional-themes-digitalsear t)  ; or any other theme
;;
;; the require MUST come before any load-theme call so
;; the hook is registered before the first theme-enable fires it

(require 'color)

(defvar my/hyperstitional-digitalsear--active nil
    "Non-nil while the digitalsear-specific overrides are applied.
Tracked so switching to a different theme knows whether there is
anything to revert.")

(defun my/hyperstitional-digitalsear-patch ()
    "Apply personal face overrides on top of the digitalsear theme."

  ;; ---------------------------------------------------------------
  ;; 1. to make whitespace-mode barely visible
  ;; ---------------------------------------------------------------
  (let* ((bg (face-attribute 'default :background))
         (subtle (color-lighten-name bg 6)))
    (dolist (face '(whitespace-space
                    whitespace-hspace
                    whitespace-newline
                    whitespace-trailing
                    whitespace-line
                    whitespace-indentation
                    whitespace-empty
                    whitespace-space-before-tab
                    whitespace-space-after-tab))
      (set-face-attribute face nil
                           :foreground subtle
                           :background 'unspecified
                           :weight 'normal))
    (set-face-attribute 'whitespace-tab nil :foreground subtle))

  ;; ---------------------------------------------------------------
  ;; 2. remove italics
  ;; ---------------------------------------------------------------
  ;; Sweep every face the theme touched and flatten any italic/oblique
  ;; slant to normal, rather than hunting each one down by hand.
  (mapc (lambda (f)
          (when (memq (face-attribute f :slant nil t) '(italic oblique))
            (set-face-attribute f nil :slant 'normal)))
        (face-list))

  ;; ---------------------------------------------------------------
  ;; 3. Comments: color only, no background wash
  ;; ---------------------------------------------------------------
  (dolist (face '(font-lock-comment-face
                  font-lock-comment-delimiter-face))
    (set-face-attribute face nil :background 'unspecified))

  ;; ---------------------------------------------------------------
  ;; 4. ansi-term / term-mode colors, pulled from the loaded theme
  ;; ---------------------------------------------------------------
  ;; term-mode has its own dedicated face set (term-color-*) that the
  ;; theme never touches, so it falls back to Emacs' stock ANSI colors.
  ;; Remap each to a face the theme already defined with good contrast.
  (let ((bg (face-attribute 'default :background))
        (fg (face-attribute 'default :foreground)))
    (set-face-attribute 'term nil :foreground fg :background bg)
    (set-face-attribute 'term-color-black   nil :foreground (face-attribute 'shadow :foreground))
    (set-face-attribute 'term-color-red     nil :foreground (face-attribute 'font-lock-keyword-face :foreground))
    (set-face-attribute 'term-color-green   nil :foreground (face-attribute 'font-lock-string-face :foreground))
    (set-face-attribute 'term-color-yellow  nil :foreground (face-attribute 'warning :foreground))
    (set-face-attribute 'term-color-blue    nil :foreground (face-attribute 'font-lock-function-name-face :foreground))
    (set-face-attribute 'term-color-magenta nil :foreground (face-attribute 'font-lock-type-face :foreground))
    (set-face-attribute 'term-color-cyan    nil :foreground (face-attribute 'font-lock-constant-face :foreground))
    (set-face-attribute 'term-color-white   nil :foreground fg))

  (setq my/hyperstitional-digitalsear--active t))

(defun my/hyperstitional-digitalsear-unpatch ()
  "Undo the overrides from `my/hyperstitional-digitalsear-patch'.
Clears each attribute back to `unspecified' so whatever theme is
enabled now (or Emacs' base default, if that theme doesn't touch a
given face) shows through cleanly, instead of digitalsear's colors
lingering on top of it."
  (dolist (face '(whitespace-space
                  whitespace-hspace
                  whitespace-newline
                  whitespace-trailing
                  whitespace-line
                  whitespace-indentation
                  whitespace-empty
                  whitespace-space-before-tab
                  whitespace-space-after-tab
                  whitespace-tab))
    (set-face-attribute face nil
                         :foreground 'unspecified
                         :background 'unspecified
                         :weight 'unspecified))

  (dolist (face '(font-lock-comment-face
                  font-lock-comment-delimiter-face))
    (set-face-attribute face nil :background 'unspecified))

  (dolist (face '(term
                  term-color-black term-color-red term-color-green
                  term-color-yellow term-color-blue term-color-magenta
                  term-color-cyan term-color-white))
    (set-face-attribute face nil
                         :foreground 'unspecified
                         :background 'unspecified))

  ;; Clear the forced :slant normal from every face -- safe even for
  ;; faces we never touched, since unspecifying a slant we didn't set
  ;; is a no-op; it only matters for the ones we did.
  (mapc (lambda (f) (set-face-attribute f nil :slant 'unspecified))
        (face-list))

  (setq my/hyperstitional-digitalsear--active nil))

(defun my/hyperstitional-digitalsear-patch-maybe (theme &rest _)
  "Apply or revert the digitalsear patch depending on THEME.
If THEME is our target theme, apply the overrides. If it's anything
else and the overrides are currently active, revert them first so they
don't bleed into the newly enabled theme. Argument signature matches
what `enable-theme-functions' and the `load-theme' advice fallback
both pass (a theme symbol, plus ignored extra args from the advice
case)."
  (cond
   ((eq theme 'hyperstitional-themes-digitalsear)
    (my/hyperstitional-digitalsear-patch))
   (my/hyperstitional-digitalsear--active
    (my/hyperstitional-digitalsear-unpatch))))

(if (boundp 'enable-theme-functions)
    ;; Emacs 29+: fires every time any theme is (re)enabled -- at
    ;; startup, on reload, or after `disable-theme' + `load-theme'
    ;; later in the session -- so this stays correct through any number
    ;; of theme switches without needing to be re-run by hand.
    (add-hook 'enable-theme-functions #'my/hyperstitional-digitalsear-patch-maybe)
  ;; Fallback for Emacs < 29, which has no enable-theme-functions hook:
  ;; advise load-theme directly instead.
  (advice-add 'load-theme :after #'my/hyperstitional-digitalsear-patch-maybe))

(provide 'hyperstitional-digitalsear-patches)
;;; hyperstitional-digitalsear-patches.el ends here







