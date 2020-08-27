#!/bin/bash
# tests the given platforms

VOLUME_DIR=`pwd | sed 's:/ops/.*:/ops:'`

function usage {
	echo 1>&2 "Usage: $0 <command> <platform> [<platform> [...] ]"
	echo 1>&2
	echo 1>&2 "  command:  the command to run in the container"
	echo 1>&2 "  platform: the name of a directory to test"
}

if [ "$1" == "-h" ]; then
	usage
	exit 0
fi

if [ $# -lt 2 ]; then
	usage
	exit 1
else
	command="$1"
	shift
	platforms="$*"
fi

echo "$0: Running '$command' on platforms: $platforms"

for platform in $platforms; do
	cd "$platform" || {
		echo 1>&2 "$0: Unable to cd to '$platform'"
		exit 2
	}

	echo "$0: Mounting '$VOLUME_DIR' into the container at '/ops'."
	docker run --rm -it -v "$VOLUME_DIR:/ops" --name $platform $platform $command
done
