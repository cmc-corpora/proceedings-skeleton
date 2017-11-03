TARGETS = proceedings.pdf
PAPERS_SRCS = $(wildcard paper*.tex)
PAPERS_TARGETS = $(patsubst %.tex,%.pdf,$(PAPERS_SRCS))
BNDL_TARGETS = $(patsubst %.pdf,%.tar.gz,$(TARGETS))
OUT_TARGETS = $(patsubst %.pdf,%.out,$(TARGETS))
PDF_TARGETS = $(TARGETS)
TEX_SRCS := $(patsubst %pdf,%tex,$(TARGETS)) 
TEX_XTRA_SRCS := 
BIB_SRCS := $(wildcard *.bib)
IMG_SRCS := $(wildcard img/*)
OTH_SRCS := $(wildcard bit-*.tex) $(wildcard proceedings-*.tex) $(wildcard *.cls) $(wildcard *.sty)

LATEXMK_PDFLATEX_OPTS ?= -file-line-error -interaction=nonstopmode
LATEXMK_CE_OPTS = '$$cleanup_includes_cusdep_generated=1;$$clean_ext="dep nav run.xml snm tdo vrb"'

SUBMISSIONS_SOURCES := $(wildcard submissions/paper_*.pdf)
SUBMISSIONS_TARGETS := $(patsubst submissions/%,submissions_sane/%,$(SUBMISSIONS_SOURCES))

SHELL:=/bin/bash

#.DELETE_ON_ERROR:

.PHONY: all init bundle clean cleanall submissions_sane papers

.DEFAULT_GOAL := $(TARGETS)

all: init $(TARGETS) bundle

init: submissions_sane

$(TARGETS): %.pdf:%.tex $(PAPERS_SRCS) $(TEX_XTRA_SRCS) $(BIB_SRCS) $(IMG_SRCS) $(OTH_SRCS)
	for AUX in $(wildcard *.aux); do echo $${AUX}; [ -s $${AUX} ] || rm $${AUX}; done
ifeq ($(ENGINE),pdflatex)
	latexmk -pdf -pdflatex="pdflatex $(LATEXMK_PDFLATEX_OPTS)"            -bibtex -use-make $<
else
	latexmk -pdf -pdflatex="lualatex $(LATEXMK_PDFLATEX_OPTS)" -dvi- -ps- -bibtex $<
endif
	# gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.5 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="$$(basename $@ .pdf)-compressed.pdf" $@

$(OUT_TARGETS):
	if [ ! -e "$(OUT_TARGETS)" ]; then $(MAKE) cleanall; fi
	$(MAKE) $(TARGETS)

$(BNDL_TARGETS): $(OUT_TARGETS) $(TARGETS) Makefile
	bundledoc --texfile=$(basename $<).tex --nokeepdirs --include=Makefile --include="*.bib" --include="*.tex" --exclude="*.maf" --exclude="*.mtc*" --exclude="*.out" --config=bundledoc.cfg $(basename $<).dep

bundle: $(BNDL_TARGETS)

submissions_sane/%.pdf: submissions/%.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dNOPAUSE -dQUIET -dBATCH -sOutputFile="submissions_sane/$$(basename $<)" $<
submissions_sane: $(SUBMISSIONS_TARGETS)

$(PAPERS_TARGETS): %.pdf:%.tex $(TARGETS)
	lualatex -jobname='tmpaper' -pdf <(echo "\input{$(patsubst %.pdf,%.tex,$(patsubst paper%,meta%,$@))}\includeonly{$(subst .pdf,,$@)}\input{proceedings-main}")
	mv tmpaper.pdf $@
papers: $(PAPERS_TARGETS)

clean:
	latexmk -c -bibtex -e $(LATEXMK_CE_OPTS)
	rm $(patsubst %pdf,%maf,$(PDF_TARGETS)) || true
	rm $(patsubst %pdf,%mtc,$(PDF_TARGETS)) || true
	rm $(patsubst %pdf,%mtc,$(PDF_TARGETS))? || true
	rm tmpaper.* || true

cleanall: clean
	latexmk -C -bibtex -e $(LATEXMK_CE_OPTS)
	rm $(patsubst %.pdf,%.tar.gz,$(PDF_TARGETS)) || true
