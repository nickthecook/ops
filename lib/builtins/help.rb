# frozen_string_literal: true

require 'colorize'

require 'builtin'
require 'forwards'
require 'builtins/helpers/enumerator'
require 'nomenclator'

module Builtins
	class Help < Builtin
		NAME_WIDTH = 40

		class << self
			def description
				"displays available builtins, actions, and forwards"
			end
		end

		def run
			if @args[0] == "commands"
				print_commands
			else
				print_help
			end
		end

		def print_commands
			Output.out(nomenclator.commands)
		end

		def print_help
			Output.out("Builtins:")
			Output.out("  #{builtins.join("\n  ")}")
			Output.out("")
			Output.out("Forwards:")
			Output.out("  #{forwards.join("\n  ")}")
			Output.out("")
			Output.out("Actions:")
			Output.out("  #{actions.join("\n  ")}")
		end

		private

		def forwards
			Forwards.new(@config).forwards.map do |name, dir|
				format("%<name>-#{NAME_WIDTH}s %<desc>s", name: name.yellow, desc: dir)
			end
		end

		def builtins
			builtin_enumerator.names_by_constant.map do |klass, names|
				names_string = names.map(&:downcase).map(&:to_s).uniq.join(", ").yellow

				format("%<names>-#{NAME_WIDTH}s %<desc>s", names: names_string, desc: klass.description)
			end
		end

		def actions
			return [] unless @config["actions"]

			@config["actions"].map do |name, action_config|
				format("%<name>-#{NAME_WIDTH}s %<desc>s",
					name: "#{name.yellow} #{alias_string_for(action_config)}",
					desc: action_config["description"] || action_config["command"]
				)
			end.sort
		end

		def alias_string_for(action_config)
			return "[#{action_config["alias"]}]" if action_config["alias"]

			""
		end

		def builtin_enumerator
			@builtin_enumerator ||= ::Builtins::Helpers::Enumerator
		end
	end
end
