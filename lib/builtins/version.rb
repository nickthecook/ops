# frozen_string_literal: true

require "output"
require "version"

module Builtins
	class Version < Builtin
		class << self
			def description
				"prints the version of ops that is running"
			end
		end

		def run
			Output.out(::Version.version)
		end
	end
end
