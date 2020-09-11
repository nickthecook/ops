#!/bin/bash
# entrypoint for ops test containers

echo "$0: loading SSH agent..."
eval `ssh-agent`
echo "$0: running 'bundler install'..."
bundle install --quiet
echo "$0: running 'ops up'..."
bin/ops up

echo "$0: Running command: $*"
"$@"
