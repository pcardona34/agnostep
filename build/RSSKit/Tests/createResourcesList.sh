#!/bin/sh

# Produces a resource list. It's too big to put all that into the
# GNUmakefile.

echo 'RSSKitTests_RESOURCE_FILES = \'
find Resources/ | grep xml$ | sed 's/$/ \\/'
# Extra blank line so that we don't need to remove the \ from the last line
echo
