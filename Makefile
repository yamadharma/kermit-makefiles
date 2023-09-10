clean:
	-find . -name "*~" -delete
	-find . -name "auto" -type d -exec rm -r "{}" \;

cleanall: clean
