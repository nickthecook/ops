#!/bin/bash
# tests the given platforms

VOLUME_DIR=`pwd | sed 's:/ops/.*:/ops:'`

function usage {
	echo 1>&2 "Usage: $0 <command> <platform> [<platform> [...] ]"
	echo 1>&2
	echo 1>&2 "  command:  the command to run in the container"
	echo 1>&2 "  platform: the name of a platform to run it in (e.g. 'ops-debian')"
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
echo "$0: Mounting '$VOLUME_DIR' into the container at '/ops'."

for platform in $platforms; do
	cd "$platform" || {
		echo 1>&2 "$0: Unable to cd to '$platform'"
		exit 2
	}

	# get a string based on the command that can be included in the container name
	command_string=`echo "$command" | sed 's/[^a-zA-z0-9]/_/g'`
	container_name="$platform"_"$command_string"
	# create a container with the name of the platform if it doesn't already exist
	if docker ps -a | grep -q " $container_name$"; then
		echo "$0: Starting existing container '$container_name'..."
		docker start -a $container_name
	else
		echo "$0: Running new container '$container_name' from image '$platform'..."
		docker run -it -v "$VOLUME_DIR:/ops" --name $container_name $platform $command
	fi

	cd ..
done
