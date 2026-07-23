;; -*- lexical-binding: t; -*-

(defvar onemacs-profile 'minimum "choose one to load: 'minimum or 'maximum")
(load (expand-file-name (symbol-name onemacs-profile) user-emacs-directory))

