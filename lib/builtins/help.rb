# frozen_string_literal: true

require 'colorize'

module Builtins
	class Help < Builtin
		NAME_WIDTH = 40

		class << self
			def description
				"displays available builtins, actions, and forwards"
			end
		end

		def run
			list("Builtins", builtins) if builtins.any?
			list("Forwards", forwards) if forwards.any?
			list("Actions", actions) if actions.any?

			true
		end

		private

		def list(name, items)
			Output.out("#{name}:")
			Output.out("  #{items.join("\n  ")}")
			Output.out("")
		end

		def forwards
			Forwards.new(@config).forwards.map do |name, dir|
				format("%<name>-#{NAME_WIDTH}s %<desc>s", name: name.yellow, desc: dir.to_s)
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
