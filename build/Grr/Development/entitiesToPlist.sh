#!/bin/sh

# Assumes the presence of entities.html, downloaded from
# http://www.w3.org/TR/html401/sgml/entities.html

echo '{'
grep '^&lt;!ENTITY' entities.html | sed -e 's/^&lt;!ENTITY /     /' -e 's/[[:space:]] *CDATA \"&amp;#/ = <*I/' -e 's/;\".*$/>;/' | sort 
echo '}'

