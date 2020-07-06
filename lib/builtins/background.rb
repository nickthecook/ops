# frozen_string_literal: true

require 'open3'

require 'builtin'

module Builtins
	class Background < Builtin
		SHELL = "bash"

		class << self
			def description
				"runs the given command in a background session"
			end
		end

		def run
			exec("screen", "-L", "-Logfile", log_file, "-dm", "bash", "-c", "ops #{args.join(' ')}")
		end

		private

		def log_file
			"/tmp/ops-screenlog"
		end
	end

	# set an alias
	Bg = Background
end
