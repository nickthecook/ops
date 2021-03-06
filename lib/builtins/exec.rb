# frozen_string_literal: true

require 'builtin'
require 'output'
require 'secrets'
require 'options'

module Builtins
	class Exec < Builtin
		class << self
			def description
				"executes the given command in the `ops` environment, i.e. with environment variables set"
			end
		end

		def run
			Secrets.load if Options.get("exec.load_secrets")

			if args.any?
				Kernel.exec(args.join(" "))
			else
				Output.error("Usage: ops exec '<command>'")
			end
		end
	end
end
