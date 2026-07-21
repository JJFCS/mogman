;; -*- lexical-binding: t; -*-

;; garbage collection
(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;; save default handlers and clear the list for fast loading
(defvar onncera-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; emacs recomputes font caches far more than it needs to
;; this helps a lot with nerd font or ligature-heavy configurations
(setq inhibit-compacting-font-caches t)

;; disable UI elements before UI initialization
(setq menu-bar-mode nil)  ;; disable the menu bar
(setq tool-bar-mode nil)  ;; disable the tool bar
(push '(vertical-scroll-bars) default-frame-alist)  ;; disable the scroll bar

;; this changes where emacs stores native compilation (.eln) files
(when (boundp 'native-comp-eln-load-path)
(setcar native-comp-eln-load-path
(expand-file-name "onemacs-cache/eln-cache/" user-emacs-directory)
                )
        )

(add-to-list 'default-frame-alist
             '(font . "Iosevka Nerd Font Mono-14"))  ;; first frame opens with the correct font

