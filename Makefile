TARGETS = proceedings.pdf
BNDL_TARGETS = $(patsubst %.pdf,%.tar.gz,$(TARGETS))
OUT_TARGETS = $(patsubst %.pdf,%.out,$(TARGETS))
PDF_TARGETS = $(TARGETS)
TEX_SRCS := $(patsubst %pdf,%tex,$(TARGETS)) 
TEX_XTRA_SRCS := 
BIB_SRCS := $(wildcard *.bib)
IMG_SRCS := $(wildcard img/*)
OTH_SRCS := $(wildcard *.tex) $(wildcard *.cls) $(wildcard *.sty)

LATEXMK_PDFLATEX_OPTS ?= -file-line-error -interaction=nonstopmode
LATEXMK_CE_OPTS = '$$cleanup_includes_cusdep_generated=1;$$clean_ext="dep nav run.xml snm tdo vrb"'

PAPER_SOURCES := $(wildcard papers.org/paper_*.pdf)
PAPER_TARGETS := $(patsubst papers.org/%,papers/%,$(PAPER_SOURCES))

#.DELETE_ON_ERROR:

.PHONY: all init extras compressed bundle install clean realclean papers

.DEFAULT_GOAL := $(TARGETS)

all: $(TARGETS) extras bundle

init: papers

$(TARGETS): %.pdf:%.tex init $(TEX_XTRA_SRCS) $(BIB_SRCS) $(IMG_SRCS) $(OTH_SRCS)
	for AUX in $(wildcard *.aux); do echo $${AUX}; [ -s $${AUX} ] || rm $${AUX}; done
ifeq ($(ENGINE),pdflatex)
	latexmk -pdf -pdflatex="pdflatex $(LATEXMK_PDFLATEX_OPTS)"            -bibtex -use-make $<
else
	latexmk -pdf -pdflatex="lualatex $(LATEXMK_PDFLATEX_OPTS)" -dvi- -ps- -bibtex $<
endif
	# gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$$(basename $@ .pdf)-compressed.pdf" $@

$(OUT_TARGETS):
	if [ ! -e "$(OUT_TARGETS)" ]; then $(MAKE) realclean; fi
	$(MAKE) $(TARGETS)

$(BNDL_TARGETS): $(OUT_TARGETS) $(TARGETS) Makefile
	bundledoc --texfile=$(basename $<).tex --nokeepdirs --include=Makefile --include="*.bib" --include="*.tex" --exclude="*.maf" --exclude="*.mtc*" --exclude="*.out" --config=bundledoc.cfg $(basename $<).dep

bundle: $(BNDL_TARGETS)

papers/%.pdf: papers.org/%.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="papers/$$(basename $<)" $<
papers: $(PAPER_TARGETS)

clean:
	latexmk -c -bibtex -e $(LATEXMK_CE_OPTS)
	rm $(patsubst %pdf,%maf,$(PDF_TARGETS)) || true
	rm $(patsubst %pdf,%mtc,$(PDF_TARGETS)) || true
	rm $(patsubst %pdf,%mtc,$(PDF_TARGETS))? || true

cleanall: clean
	latexmk -C -bibtex -e $(LATEXMK_CE_OPTS)
	rm $(patsubst %.pdf,%.tar.gz,$(PDF_TARGETS)) || true
