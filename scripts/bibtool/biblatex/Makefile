fixbib:
	cp ../bib/main.bib .
	./fixbib.sh
	-bibtex-tidy --no-escape --duplicates key --merge --enclosing-braces=title,subtitle,journal *.bib
