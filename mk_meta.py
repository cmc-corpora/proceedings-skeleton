#!/usr/bin/env python

import sys
import json
import yaml

with open("proceedings.yaml", 'r') as fh:
    try:
        data_yaml = yaml.load(fh)
    except yaml.YAMLError as e:
        sys.stderr.write(repr(e))
        sys.exit(1)

with open("zenodo/skel-inproceedings.json", 'r') as fh:
    # try:
    data_json = json.load(fh)
    # except error as e:
    #     sys.stderr.write(repr(e))
    #     sys.exit(1)

for datum in data_yaml:
    print(datum)
    fid_incl = fid_zenodo = None

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
        id_zenodo = '0%i' %(datum['id'])
    elif 'types' in datum and 'paper' in datum['types']:
        fid_meta = 'meta_%i.tex' %(datum['id'])
        fid_incl = 'paper_%i.tex' %(datum['id'])
        fn_incl = 'submissions_sane/paper_%i.pdf' %(datum['id'])
        id_zenodo = '%i' %(datum['id'])
    elif 'types' in datum and 'proceedings' in datum['types']:
        fid_meta = 'proceedings-meta.tex'

    print(title, id_zenodo)

    fid_zenodo = 'cmccorpora17-%s.json' %(id_zenodo)
    fid_mk_zenodo = 'zenodo/mk_cmccorpora17-%s.sh' %(id_zenodo)

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

    if fid_zenodo:
        if 'title_utf8' in datum:
            title = datum['title_utf8']
        data_json['metadata']['title'] = title
        data_json['metadata']['keywords'] = [keyword.strip() for keyword in keywords.split(',')]
        data_json['metadata']['creators'] = (
            [{'name': author['name'], 'affiliation': author['affiliation']} for author in datum['authors_utf8']])
        data_json['metadata']['description'] = datum['abstract']

        with open('zenodo/'+fid_zenodo, 'w') as fh:
            fh.write(json.dumps(data_json))

        print(fid_zenodo, id_zenodo, id_zenodo, id_zenodo, fid_incl[0:-4]+'.pdf')
        with open(fid_mk_zenodo, 'w') as fh:
            script = """
            ### [Update metadata](http://developers.zenodo.org/?shell#update27)
            curl -H "Content-Type: application/json" -X POST --data @%s "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}?access_token=${ACCESS_TOKEN}" | tee %s-reply.json

            ### Retrieve the recid.
            RECORD_ID=$(cat %s-reply.json | jq -r '.record_id')
            echo RECORD_ID=${RECORD_ID}

            ### [Upload the file](http://developers.zenodo.org/?shell#create24)
            curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID}/files?access_token=${ACCESS_TOKEN}" -F name=cmccorpora17-%s.pdf -F file=@../%s
            """ %(fid_zenodo, id_zenodo, id_zenodo, id_zenodo, fid_incl[0:-4]+'.pdf')

            fh.write(script)
