# frozen_string_literal: true

require 'builtin'
require 'forwards'
require 'builtins/helpers/enumerator'
require 'options'

require 'require_all'
require_rel '.'

module Builtins
	class Completion < Builtin
		BASH = "bash"
		ZSH = "zsh"
		USAGE = "Usage: ops completion 'bash / zsh'"

		class << self
			def description
				"displays completion configuration for the flavor of shell provided"
			end
		end

		def run
			if args.none? || ![BASH, ZSH].include?(args[0])
				Output.error(USAGE)
				false
			elsif args[0] == BASH
				Output.print(bash_completion)
				true
			elsif args[0] == ZSH
				Output.print(zsh_completion)
				true
			end
		end

		def completion
			return false if ENV["OPS_AUTO_COMPLETE"].nil? || ENV["COMP_WORDS"].nil? || ENV["COMP_CWORD"].nil?

			word_list = ENV["COMP_WORDS"].split(" ")
			current_index = ENV["COMP_CWORD"].to_i
			current_word = word_list[current_index]

			Output.out(completion_list(current_word))
			true
		end

		private

		def bash_completion
			"\n\n_ops_completion()\n"\
			"{\n"\
			"    COMPREPLY=( $( COMP_WORDS=\"${COMP_WORDS[*]}\" \\\n"\
			"                   COMP_CWORD=$COMP_CWORD \\\n"\
			"                   OPS_AUTO_COMPLETE=1 $1 2>/dev/null ) )\n"\
			"}\n"\
			"complete -o default -F _ops_completion ops\n"
		end

		def zsh_completion
			"\n\nfunction _ops_completion {\n"\
			"  local words cword\n"\
			"  read -Ac words\n"\
			"  read -cn cword\n"\
			"  reply=( $( COMP_WORDS=\"$words[*]\" \\\n"\
			"             COMP_CWORD=$(( cword-1 )) \\\n"\
			"             OPS_AUTO_COMPLETE=1 $words[1] 2>/dev/null ))\n"\
			"}\n"\
			"compctl -K _ops_completion ops\n"
		end

		def completion_list(filter)
			(actions | builtins | forwards).select { |item| item =~ /^#{filter}/ }.sort.join(" ")
		end

		def forwards
			@forwards ||= Forwards.new(@config).forwards.map do |name, _dir|
				name
			end.uniq
		end

		def builtins
			@builtins ||= builtin_enumerator.names_by_constant.map do |_klass, names|
				names.map(&:downcase).map(&:to_s)
			end.flatten.uniq
		end

		def actions
			return [] unless @config["actions"]

			@actions ||= @config["actions"].map do |name, action_config|
				next unless verify_by_restrictions(action_config)

				include_aliases? ? [name, alias_string_for(action_config)] : name
			end.flatten.uniq
		end

		def alias_string_for(action_config)
			return action_config["alias"].to_s if action_config["alias"]

			""
		end

		def include_aliases?
			@include_aliases ||= Options.get("completion.include_aliases")
		end

		def verify_by_restrictions(action_config)
			env = ENV["environment"] || "dev"
			return false if action_config["skip_in_envs"]&.include?(env)
			return false if action_config["not_in_envs"]&.include?(env)
			return false if action_config["in_envs"] && !action_config["in_envs"].include?(env)

			true
		end

		def builtin_enumerator
			@builtin_enumerator ||= ::Builtins::Helpers::Enumerator
		end
	end
end
