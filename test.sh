#!/bin/bash
[ -x bin/rake ] || exit 1
bin/rake gapi:test
exit_1=$?
bin/rake test
exit_2=$?
if [[ "x$1" == "xcommit" ]] ; then
	if [ $exit_1 -eq 1 ] || [ $exit_2 -eq 1 ]; then
		echo errors happended during testing i wont commit that..
		exit 1
	fi
	git commit -a
	#git push --all
fi
exit 0
