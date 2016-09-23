#!/bin/bash
failure () {
	if [ $1 -ne 0 ] ; then
		echo errors happended during testing i wont commit that..
		exit 1
	fi
}
[ -x bin/rake ] || exit 1
bin/rake gapi:test
failure $?
bin/rake test
failure $?
if [[ "x$1" == "xcommit" ]] ; then
	git commit -a
	#git push --all
fi
exit 0
