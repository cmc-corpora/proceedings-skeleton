#!/usr/bin/env bash
#
# Download DOI svg image, 
# Convert svg image to pdf, and
# Generate .tex \href{}{} snippet.

# DOI from env or this one
: ${DOI:=10.5281/zenodo.1040713}

# Download svg image
curl https://zenodo.org/badge/DOI/${DOI}.svg -o img/zenodo_doi.svg

# Convert svg to pdf (in high resolution)
convert -density 300x300 img/zenodo_doi.svg img/zenodo_doi.pdf

# Generate .tex \href{}{} snippet
echo '\href{'https://doi.org/${DOI}'}{\includegraphics{img/zenodo_doi}}' > zenodo_doi_url.tex
