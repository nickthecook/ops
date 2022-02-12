# frozen_string_literal: true

module Builtins
	class Version < Builtin
		class << self
			def description
				"prints the version of ops that is running"
			end
		end

		def run
			Output.out(::Version.version)

			true
		end
	end
end
