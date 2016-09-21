#!/bin/bash
[ -x bin/rake ] || exit 1
bin/rake gapi:test
bin/rake test
if [[ "x$1" == "xcommit" ]] ; then
	git commit -a
	#git push --all
fi
exit 0
