#!/bin/sh

set -e
set -x

HOST="127.0.0.1:3000"

BASEURL="http://${HOST}/api"
OUTPUTDIR="Resources/Content"

JSONS="festival gigs news info"

for json in $JSONS; do
	curl -o "${OUTPUTDIR}/${json}" "${BASEURL}/${json}"
done
