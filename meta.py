#!/usr/bin/env python

import sys
import yaml

with open("proceedings.yaml", 'r') as fh:
    try:
        data = yaml.load(fh)
    except yaml.YAMLError as e:
        sys.stderr.write(repr(e))
        sys.exit(1)

for datum in data:
    fid_incl = None
    pdfcreator = 'Egon W.~Stemle, Eurac Research'
    pdfsubject = "Proceedings of the 5th Conference on CMC and Social Media Corpora for the Humanities (cmccorpora17)"
    footershorttitle = '\#cmccorpora17'

    authors = datum['authors'].strip()
    title = datum['title'].strip()
    shorttitle = ""
    if 'shorttitle' in datum:
        shorttitle = datum['shorttitle'].strip()
    shortauthors = ""
    if 'shortauthors' in datum:
        shortauthors = datum['shortauthors'].strip()
    keywords = datum['keywords'].strip()

    if 'types' in datum and 'invitedtalk' in datum['types']:
        fid_meta = 'meta-inv_%i.tex' %(datum['id'])
        fid_incl = 'paper-inv_%i.tex' %(datum['id'])
        fn_incl = 'inv-%i/main.pdf' %(datum['id'])
    elif 'types' in datum and 'paper' in datum['types']:
        fid_meta = 'meta_%i.tex' %(datum['id'])
        fid_incl = 'paper_%i.tex' %(datum['id'])
        fn_incl = 'submissions_sane/paper_%i.pdf' %(datum['id'])
    elif 'types' in datum and 'proceedings' in datum['types']:
        fid_meta = 'proceedings-meta.tex'

    if fid_incl:
        with open(fid_incl, 'w') as fh:
            fh.write("\\insertpdf{%s}{%s}{%s}{%s}{%s}{%s}\n" %(fn_incl,
                                                               authors,
                                                               title,
                                                               shorttitle,
                                                               shortauthors,
                                                               keywords))

    with open(fid_meta, 'w') as fh:
        authors = authors.replace(' and ', ', ')
        shortauthors = shortauthors.replace(' and ', ', ')
        nc = """\\newcommand"""

        fh.write("%s{\\thetitle}{%s}\n" %(nc, title))
        fh.write("%s{\\shorttitle}{%s}\n" %(nc, footershorttitle))

        fh.write("%s{\\%s}{%s}\n" %(nc, "pdftitle", "\\thetitle"))
        fh.write("%s{\\%s}{%s}\n" %(nc, "pdfauthors", authors))
        fh.write("%s{\\%s}{%s}\n" %(nc, "pdfsubject", pdfsubject))
        fh.write("%s{\\%s}{%s}\n" %(nc, "pdfkeywords", keywords))
        fh.write("%s{\\%s}{%s}\n" %(nc, "pdfcreator", pdfcreator))

