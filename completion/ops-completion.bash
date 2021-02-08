#!/usr/bin/env bash

function _ops_completions {
	ACTIONS = $(ops help actions)
	COMPREPLY=($(compgen -W $ACTIONS $COMP_WORDS[1]))
}
