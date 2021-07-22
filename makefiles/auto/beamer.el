(TeX-add-style-hook
 "beamer"
 (lambda ()
   (add-to-list 'LaTeX-verbatim-environments-local "semiverbatim")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "href")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (TeX-run-style-hooks
    "preamble/class/beamer/fix"
    "preamble/class/beamer/common"
    "preamble/class/beamer/caption"
    "preamble/class/beamer/themes"
    "preamble/class/beamer/pst"
    "preamble/class/beamer/notes"
    "preamble/class/beamer/handoutwithnotes"
    "preamble/class/beamer/beamerposter"
    "ifpdf"
    "ifxetex"
    "ifluatex"
    "xifthen"))
 :latex)

