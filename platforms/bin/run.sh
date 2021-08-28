#!/bin/bash
# tests the given platforms

ZERO="-->"

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

if [ $# -eq 0 ]; then
	usage
	exit 1
elif [ $# -eq 1 ]; then
	command="$1"
	platforms="$(ls -d ops-*)"
else
	command="$1"
	shift
	platforms="$*"
fi

echo -e "$ZERO Running '$command' on platforms:"
echo "$platforms" | sed 's/^/  - /'
echo

for platform in $platforms; do
	echo "==> [ $platform ]"

	cd "$platform" || {
		echo 1>&2 "$ZERO Unable to cd to '$platform'"
		exit 2
	}

	# get a string based on the command that can be included in the container name
	command_string=`echo "$command" | sed 's/[^a-zA-Z0-9]/_/g'`
	container_name="$platform"_"$command_string"

	echo "$ZERO Mounting 'entrypoint.sh' at '$PWD/$platform/entrypoint.sh:/entrypoint.sh'..."
	echo "$ZERO Mounting source dir '$VOLUME_DIR' at '/ops'..."

	# create a container with the name of the platform if it doesn't already exist
	if docker ps -a | grep -q " $container_name$"; then
		echo "$ZERO Starting existing container '$container_name'..."
		docker start -a $container_name
	else
		echo "$ZERO Running new container '$container_name' from image '$platform'..."
		docker run -it \
			-v "$PWD/entrypoint.sh:/entrypoint.sh" \
			-v "$VOLUME_DIR:/ops" \
			--name $container_name \
			$platform \
			$command
	fi

	cd ..
done
