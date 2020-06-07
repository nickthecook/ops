# frozen_string_literal: true

require 'colorize'

require 'builtin'

module Builtins
	class Help < Builtin
		class << self
			def description
				"Displays available builtins and actions"
			end
		end

		def run
			Output.out("Builtins:")
			Output.out("  #{builtins.join("\n  ")}")
			Output.out("")
			Output.out("Actions:")
			Output.out("  #{actions.join("\n  ")}")
		end

		private

		def builtins
			builtin_class_names.map do |class_name|
				description = Builtins.const_get(class_name).description
				format("%<name>-35s %<desc>s", name: class_name.downcase.to_s.yellow, desc: description)
			end
		end

		def builtin_class_names
			Builtins.constants.select { |c| Builtins.const_get(c).is_a? Class }
		end

		def actions
			@config["actions"].map do |name, value|
				format("%<name>-35s %<desc>s", name: name.yellow, desc: value["description"] || value["command"])
			end
		end
	end
end
