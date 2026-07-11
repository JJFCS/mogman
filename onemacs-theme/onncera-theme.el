;; onncera-theme.el --- onncera's personal theme -*- lexical-binding: t -*-

(deftheme onncera "onncera's personal theme")

(let
    (

    (class                   '((class color) (min-colors 89)))

    ;; MAIN COLORS
    (onncera-bg              "#0A0B0C")
    (onncera-bg-whitespace   "#101214")
    (onncera-amber-1         "#E8551F")
    (onncera-amber-2         "#D98E2B")
    (onncera-green-1         "#5E8759")
    (onncera-white-1         "#CCCCCC")
    (onncera-white-2         "#E4E4EF")
    (onncera-white-3         "#EDEADE")
    (onncera-red-1           "#C0392B")
    (onncera-red-2           "#8A4235")
    (onncera-purple-1        "#9676AC")
    (onncera-yellow-1        "#FFDD33")

    ;; TAB BAR COLORS
    (onncera-tab-bg          "#15171A")
    (onncera-tab-bg-elev     "#1E2125")
    (onncera-tab-line        "#2E3338")
    (onncera-tab-gray        "#4A4F54")
    (onncera-tab-fg-bright   "#E8E6E1")
    (onncera-tab-amber       "#E8551F")

    )

    (custom-theme-set-faces 'onncera

    ;; example:
        ;; def (gruber darker yellow) --- get_all_genres(): (source code - white)
        ;; """returns all the genres available with their specific URL navigation""" (nerv green)
        ;; url (nerv orange) = "https://books.toscrape.com/index.html" (nerv green)
        ;; # okay so we need to anchor tag href.. in there, there is the travel_2 shit (Jetbrains orange)

    ;; base
    `(default                           ((,class (:background ,onncera-bg :foreground ,onncera-white-1))))

    ;; font-lock
    `(font-lock-negation-char-face      ((,class (:foreground ,onncera-amber-2))))   ;; styles the exact character used to invert a boolean expression (e.g. "not" in python)
    `(font-lock-variable-name-face      ((,class (:foreground ,onncera-white-1))))   ;; the name of the variable when it is being declared
    `(font-lock-builtin-face            ((,class (:foreground ,onncera-yellow-1))))  ;; print() len() sizeof etc
    `(font-lock-keyword-face            ((,class (:foreground ,onncera-yellow-1))))  ;; if else return for def import etc
    `(font-lock-warning-face            ((,class (:foreground ,onncera-red-1))))     ;; for severe syntax errors , compiler warnings , or standard programming placeholders (TODO FIXME etc)
    `(font-lock-comment-face            ((,class (:foreground ,onncera-red-2))))
    `(font-lock-comment-delimiter-face  ((,class (:foreground ,onncera-red-2))))     ;; the specific characters that initiate a comment (e.g. # // etc)
    `(font-lock-doc-face                ((,class (:foreground ,onncera-red-2))))     ;; docstrings
    `(font-lock-doc-markup-face         ((,class (:foreground ,onncera-red-2))))     ;; not too sure - just docstrings I guess..
    `(font-lock-doc-string-face         ((,class (:foreground ,onncera-red-2))))     ;; not too sure - just docstrings I guess..
    `(font-lock-escape-face             ((,class (:foreground ,onncera-red-2))))     ;; \n \t etc
    `(font-lock-string-face             ((,class (:foreground ,onncera-green-1))))
    `(font-lock-number-face             ((,class (:foreground ,onncera-white-1))))   ;; all numeric literals
    `(font-lock-function-name-face      ((,class (:foreground ,onncera-white-1))))   ;; the name of the function when it is being declared
    `(font-lock-function-call-face      ((,class (:foreground ,onncera-white-1))))   ;; the name of the function when you are invoking it
    `(font-lock-property-name-face      ((,class (:foreground ,onncera-white-1))))   ;; Similar to variables but specifically for object/struct properties (e.g. the length in user.length)
    `(font-lock-property-use-face       ((,class (:foreground ,onncera-white-1))))
    `(font-lock-operator-face           ((,class (:foreground ,onncera-white-1))))   ;; mathematical and logical operators (e.g. + - * == etc)
    `(font-lock-type-face               ((,class (:foreground ,onncera-amber-2))))   ;; int String struct User etc
    `(font-lock-reference-face          ((,class (:foreground ,onncera-amber-2))))   ;; no clue.. testing
    `(font-lock-preprocessor-face       ((,class (:foreground ,onncera-yellow-1))))  ;; #include #define @import etc
    `(font-lock-constant-face           ((,class (:foreground ,onncera-amber-2))))   ;; true false nil NULL etc

    ;; tab bar / tab line
    `(tab-bar              ((,class (:background ,onncera-tab-bg      :foreground ,onncera-tab-gray))))
    `(tab-bar-tab          ((,class (:background ,onncera-tab-bg-elev :foreground ,onncera-tab-fg-bright :box (:line-width 1 :color ,onncera-tab-amber)))))
    `(tab-bar-tab-inactive ((,class (:background ,onncera-tab-bg      :foreground ,onncera-tab-gray :box (:line-width 1 :color ,onncera-tab-line)))))
    `(tab-line             ((,class (:background ,onncera-tab-bg      :foreground ,onncera-tab-gray))))

    ;; whitespace settings:
    `(whitespace-space            ((t (:background ,onncera-bg            :foreground ,onncera-bg-whitespace))))
    `(whitespace-tab              ((t (:background ,onncera-bg            :foreground ,onncera-bg-whitespace))))
    `(whitespace-hspace           ((t (:background ,onncera-bg            :foreground ,onncera-bg-whitespace))))
    `(whitespace-newline          ((t (:background ,onncera-bg            :foreground ,onncera-bg-whitespace))))  ;; symbols like ¶ or $ so you see exactly where a line terminates
    `(whitespace-empty            ((t (:background ,onncera-yellow-1      :foreground ,onncera-yellow-1))))       ;; completely blank, empty lines at the absolute beginning or the absolute end of a file buffer
    `(whitespace-space-after-tab  ((t (:background ,onncera-yellow-1      :foreground ,onncera-yellow-1))))       ;; Styles a regular space that occurs immediately after  a tab character (e.g., »·)
    `(whitespace-indentation      ((t (:background ,onncera-yellow-1      :foreground ,onncera-red-1))))          ;; spaces or tabs that violate your language's indentation rules
    `(whitespace-trailing         ((t (:background ,onncera-red-1         :foreground ,onncera-red-1))))
    `(whitespace-space-before-tab ((t (:background ,onncera-red-2         :foreground ,onncera-red-2))))          ;; Styles a regular space that occurs immediately before a tab character (e.g., ·»)
    `(whitespace-line             ((t (:background ,onncera-bg-whitespace :foreground ,onncera-red-2))))          ;; Styles code that exceeds your preferred maximum line length (e.g. 80)

    ;; misc
    `(cursor             ((,class (:background ,onncera-amber-1))))
    `(region             ((,class (:background ,nerv-line :extend t))))
    )

    ;; things to work on:
    ;; compilation (TODO)
    ;; completions (TODO)
    ;; diffs (TODO)
    ;; dired (TODO)
    ;; magit (TODO)
    ;; mode line (TODO)
    ;; line numbers (TODO)
    ;; search (TODO)
    ;; parens (TODO)
    ;; orderless (TODO)

)

(provide-theme 'onncera)

;; onncera-theme.el ends here

