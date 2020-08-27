#!/bin/bash
# tests the given platforms

function usage {
	echo 1>&2 "Usage: $0 [<platform> [<platform> [...] ] ]"
	echo 1>&2
	echo 1>&2 "  platform: the name of a directory to test"
}

if [ "$1" == "-h" ]; then
	usage
	exit 0
fi

if [ $# -eq -0 ]; then
	usage
	exit 1
else
	platforms="$*"
fi

echo "$0: Testing platforms: $platforms"

for platform in $platforms; do
	cd "$platform" || {
		echo 1>&2 "$0: Unable to cd to '$platform'"
		exit 2
	}

	docker-compose up
done
