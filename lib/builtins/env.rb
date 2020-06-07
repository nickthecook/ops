# frozen_string_literal: true

require 'builtin'
require 'output'

module Builtins
	class Env < Builtin
		class << self
			def description
				"Prints the current environment, e.g. 'dev', 'production', 'staging', etc."
			end
		end

		def run
			Output.print(environment)
		end

		def environment
			ENV['environment']
		end
	end
end
