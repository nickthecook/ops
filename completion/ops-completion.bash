
function _ops_completions {
		if [ "${#COMP_WORDS[@]}" != "2" ]; then
		return
	fi

	COMMANDS=$(ops help commands)
	COMPREPLY=($(compgen -W "$COMMANDS" ${COMP_WORDS[1]}))
}

complete -F _ops_completions ops
