# frozen_string_literal: true

require 'builtin'
require 'output'

module Builtins
	class Env < Builtin
		def run
			Output.print(environment)
		end

		private

		def environment
			ENV['environment']
		end
	end
end
