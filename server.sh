#!/bin/bash

QUERIES_FILE=queries.txt

function get_query_value()
{
	encoded=$(awk -F'[=]' '{ if ( $1 == "'$1'" ) { print $2 } }' $QUERIES_FILE)
	printf '%b' "${encoded//%/\\x}"
	#pass through urldecoder and then print
}


function handle_request()
{
	read GET
	#check if '?' exists in $GET, if not just send base page

	GET_INFO=$(echo -e $GET | awk '{ print $2 }' | cut -d? -f 2-)

	if [ -f $QUERIES_FILE ]; then
		rm -f $QUERIES_FILE
	fi
	echo -e $GET_INFO | grep -o '[A-Za-z][A-Za-z]*=[^\&]*' > $QUERIES_FILE
}

while true;
do
	(nc -l -p 8080 < test.html | handle_request)
	get_query_value mediaURI
	url=$(get_query_value mediaURI)
	youtube-dl -q -o- $url | mplayer -cache 8192 -
	#any other query values you need
done
