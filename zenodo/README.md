# Steps for uploading the proceedings to and updating them at [zenodo](https://zenodo.org)

## Init environment: the real thing or the sandbox

### The real thing
```
SANDBOX=""
ACCESS_TOKEN=[Get your personal one](https://zenodo.org/account/settings/applications/tokens/new/)
```

### The sandbox
``` 
: ${SANDBOX:=sandbox.}
ACCESS_TOKEN=[Get your personal one](https://sandbox.zenodo.org/account/settings/applications/tokens/new/)
```


## First Edition
```
URL_BASE="https://${SANDBOX}zenodo.org"
```

### [Create the entry](http://developers.zenodo.org/?shell#create).
```
curl -H "Content-Type: application/json" -X POST --data @<(grep -vE '^ +//' v1-data.json) "${URL_BASE}/api/deposit/depositions/?access_token=${ACCESS_TOKEN}" | tee v1-reply.json
```

### Retrieve the recid.
```
RECORD_ID=$(cat v1-reply.json | jq -r '.record_id')
echo RECORD_ID=${RECORD_ID}
```

### [Upload the file](http://developers.zenodo.org/?shell#create24)
```
curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID}/files?access_token=${ACCESS_TOKEN}" -F name=cmccorpora17-proceedings-v1.pdf -F file=@../cmccorpora17-proceedings-v1.pdf
```

### Publish

(can be done automatically...)


## Second Edition

### [Create new version](http://developers.zenodo.org/?shell#new-version)
```
curl -X POST "${URL_BASE}/api/deposit/depositions/${RECORD_ID}/actions/newversion?access_token=${ACCESS_TOKEN}"
URL_DRAFT=$(curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID}?access_token=${ACCESS_TOKEN}" | jq -r '.links.latest_draft')
echo URL_DRAFT=${URL_DRAFT}
```

### Retrieve (new) recid and DOI
```
RECORD_ID2=$(curl "${URL_DRAFT}?access_token=${ACCESS_TOKEN}" | jq -r '.record_id')
echo RECORD_ID2=${RECORD_ID2}
DOI=$(curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}?access_token=${ACCESS_TOKEN}" | jq -r '.doi')
echo DOI=${DOI}
```

### Delete old file
```
# Retrieve FILE_ID
FILE_ID=$(curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}?access_token=${ACCESS_TOKEN}" | jq -r '.files[0].id')
echo FILE_ID=${FILE_ID}

# DELETE old file (v1) from copied entry
curl -X DELETE "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}/files/${FILE_ID}?access_token=${ACCESS_TOKEN}"
```

### [Update metadata](http://developers.zenodo.org/?shell#update27)
```
curl -H "Content-Type: application/json" -X PUT --data @<(grep -vE '^ +//' v2-data.json | sed -e"s#_DOI_#${DOI}#" -e"s#_RECID_#${RECORD_ID2}#") "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}?access_token=${ACCESS_TOKEN}" | tee v2-reply.json
```

### [Upload the file](http://developers.zenodo.org/?shell#create24)
```
curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}/files?access_token=${ACCESS_TOKEN}" -F name=cmccorpora17-proceedings-v2.pdf -F file=@../cmccorpora17-proceedings-v2.pdf
```

### Retrieve entry
```
curl "${URL_BASE}/api/deposit/depositions/${RECORD_ID2}?access_token=${ACCESS_TOKEN}"
```
