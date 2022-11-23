report.pdf: report.md
	pandoc --from markdown \
	       --to pdf -o $@ $<

.PHONY: all clean

all: report.pdf

clean:
	rm -f report.pdf
