(TeX-add-style-hook
 "xelatex"
 (lambda ()
   (TeX-run-style-hooks
    "preamble/pkg/polyglossia/default/russian"
    "preamble/pkg/polyglossia/other/english"
    "preamble/font/fontspec"
    "preamble/font/unicode-math"
    "preamble/fix/xelatex"
    "amssymb"
    "xltxtra"
    "polyglossia"
    "xecyr"
    "fontspec"))
 :latex)

