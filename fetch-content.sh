#!/bin/sh

set -e
set -x

BASEURL="http://festapp-server.heroku.com"
OUTPUTDIR="Resources/Content"

JSONS="artists faq general news program services stages"
ASSETS="arrival.html map.png"

JSONURL="${BASEURL}/api"
HTMLURL="${BASEURL}/public"

for json in $JSONS; do
	curl -o "${OUTPUTDIR}/${json}.json" "${JSONURL}/${json}"
done

for asset in $ASSETS; do
	curl -o "${OUTPUTDIR}/${asset}" "${HTMLURL}/${asset}"
done
