# frozen_string_literal: true

require 'colorize'

require 'builtin'
require 'forwards'

module Builtins
	class Help < Builtin
		NAME_WIDTH = 35

		class << self
			def description
				"displays available builtins, actions, and forwards"
			end
		end

		def run
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
				format("%<name>-#{NAME_WIDTH}s %<desc>s" , name: name.yellow, desc: "#{dir}")
			end
		end

		def builtins
			builtin_class_map.map do |klass, name|
				format("%<name>-#{NAME_WIDTH}s %<desc>s", name: name.downcase.to_s.yellow, desc: klass.description)
			end
		end

		def builtin_class_map
			builtin_class_names.each_with_object({}) do |name, hash|
				# get the class reference for this name
				constant = const_for(name)
				# check hash for an existing entry for the same class
				existing_name = hash[constant]

				# if there is an existing key for the same class, and it's longer than the one we just found,
				# skip adding this one one to avoid duplicates, leaving the shortest name for each class
				next if existing_name && existing_name.length <= name.length

				hash[constant] = name
			end
		end

		def builtin_class_names
			@builtin_class_names ||= Builtins.constants.select { |c| const_for(c).is_a?(Class) }.sort
		end

		def const_for(name)
			Builtins.const_get(name, false)
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
	end
end
