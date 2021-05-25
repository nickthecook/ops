# frozen_string_literal: true

require 'colorize'

require 'builtin'
require 'forwards'
require 'builtin_list'
require 'action_list'
require 'builtins/helpers/help_formatter'

module Builtins
	class Help < Builtin
		NAME_WIDTH = 40

		class << self
			def description
				"displays available builtins, actions, and forwards"
			end
		end

		def run
			@args.any? ? @args.each { |arg| help(arg) } : help_all
		end

		private

		def help(arg)
			# puts "BL #{builtin_names}"
			# puts "AL #{action_names}"
			# puts "FL #{forward_names}"
			if builtin_names.include?(arg)
				Output.out(formatter.builtin(arg))
			elsif forward_names.include?(arg)
				Output.out("F #{arg}")
			elsif action_names.include?(arg)
				Output.out("A #{arg}")
			else
				Output.error("nope")
			end
		end

		def help_all
			Output.out("Builtins:")
			Output.out("  #{builtins.join("\n  ")}")
			Output.out("")
			Output.out("Forwards:")
			Output.out("  #{forwards.join("\n  ")}")
			Output.out("")
			Output.out("Actions:")
			Output.out("  #{actions.join("\n  ")}")
		end

		def builtins(names = [])
			selected_commands = builtin_list.commands.select { |name, _| names.empty? || names.include?(name) }

			selected_commands.map { |klass, commands| formatter.builtin(klass, commands) }
		end

		def builtin_names
			builtin_list.names.map(&:downcase).map(&:to_s)
		end

		def builtin_list
			@builtin_list ||= BuiltinList.new
		end

		def actions
			return [] unless @config["actions"]

			action_list.names.map do |name|
				action = action_list.get(name)

				format("%<name>-#{NAME_WIDTH}s %<desc>s",
					name: "#{name.yellow} #{action.alias}",
					desc: action.description || action.command
				)
			end.sort
		end

		def alias_string_for(action_config)
			return "[#{action_config["alias"]}]" if action_config["alias"]

			""
		end

		def action_names
			action_list.names + action_list.aliases
		end

		def action_list
			@action_list ||= ActionList.new(@config["actions"], [])
		end

		def forwards
			forwards_list.forwards.map do |name, dir|
				format("%<name>-#{NAME_WIDTH}s %<desc>s", name: name.yellow, desc: dir.to_s)
			end
		end

		def forward_names
			forwards_list.forwards.keys
		end

		def forwards_list
			Forwards.new(@config)
		end

		def formatter
			Helpers::HelpFormatter
		end
	end
end
