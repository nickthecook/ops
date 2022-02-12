# frozen_string_literal: true

module Builtins
	class Env < Builtin
		class << self
			def description
				"prints the current environment, e.g. 'dev', 'production', 'staging', etc."
			end
		end

		def run
			Output.print(environment)

			true
		end

		def environment
			ENV['environment']
		end
	end
end
