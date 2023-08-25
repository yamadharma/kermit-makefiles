(TeX-add-style-hook
 "lualatex"
 (lambda ()
   (TeX-run-style-hooks
    "preamble/font/fontspec"
    "preamble/font/unicode-math"
    "preamble/fix/xelatex"
    "luatex85"
    "amssymb"
    "lualatex-math"
    "fontspec")
   (TeX-add-symbols
    "multilingualrealization"))
 :latex)

