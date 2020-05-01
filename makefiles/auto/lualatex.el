(TeX-add-style-hook
 "lualatex"
 (lambda ()
   (TeX-run-style-hooks
    "preamble/pkg/polyglossia/default/russian"
    "preamble/pkg/polyglossia/other/english"
    "preamble/font/fontspec"
    "preamble/font/unicode-math"
    "preamble/fix/xelatex"
    "luatex85"
    "polyglossia"
    "lualatex-math"
    "fontspec"))
 :latex)

