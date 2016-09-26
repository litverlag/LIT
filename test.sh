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
if [[ $1 == "commit" ]] || [[ $1 == "push" ]] ; then
	git commit -a
	if [[ $1 == "push" ]]; then
		git push --all
	fi
fi
exit 0
