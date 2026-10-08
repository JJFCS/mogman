;; -*- lexical-binding: t; -*-

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
