(TeX-add-style-hook
 "gost"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("biblatex" "parentracker=true" "backend=biber" "hyperref=auto" "language=auto" "langhook=extras" "citestyle=gost-numeric" "defernumbers=true" "bibstyle=gost-footnote" "style=gost-numeric" "")))
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "biblatex"))
 :latex)

