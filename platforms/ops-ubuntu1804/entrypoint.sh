#!/bin/bash
# entrypoint for ops test containers

ZERO="---->"

echo "$ZERO loading SSH agent..."
eval `ssh-agent`

echo "$ZERO running 'ops up'..."
ops up

echo "$ZERO Running command: $*"
"$@"
# to get a shell in the test container, comment out the above command and uncomment the below:
# bash