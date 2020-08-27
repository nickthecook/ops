#!/bin/bash
# builds the given platforms, or all platforms if none are given

OPS_FILES="bin config etc lib loader.rb ops.yml spec"
OPS_DIR=".."

function usage {
	echo 1>&2 "Usage: $0 [<platform> [<platform> [...] ] ]"
	echo 1>&2
	echo 1>&2 "  platform: the name of a directory to build"
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

echo "$0: Building platforms: $platforms"

for platform in $platforms; do
	cd "$platform" || {
		echo 1>&2 "$0: Unable to cd to '$platform'"
		exit 2
	}

	# build container
	docker-compose build || {
		echo 1>&2 "$0: Error building container with docker-compose for platform '$platform'."
		exit 5
	}

	# remove existing containers, since image has changed
	docker rm "$platform"
done
