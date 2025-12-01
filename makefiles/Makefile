# include rules.mk
# include mkfiles/main.mk
# include translators.mk

## Основные правила
# include mkfiles/main_rules.mk

all: compile

compile:
		@latexmk

clean:
		-@latexmk -c
		-@rm -f *.tac *.loa default.titlelist.* split-paper.tex default.xml default.html default*.png *.4o[mftsy] *Notes.bib *.cut cite.bib cite.*.bib

cleanall:
		-@latexmk -C
		-@rm -rvf _minted
		-@rm -rvf split-paper.d default.htmld out
		-@rm -rf $(biber --cache)


include Makefile.postamble
