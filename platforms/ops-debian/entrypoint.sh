#!/bin/bash
# entrypoint for ops test containers

eval `ssh-agent`
bundle install --quiet
bin/ops up

echo "$*"
"$@"
