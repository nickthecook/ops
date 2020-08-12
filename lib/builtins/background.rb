# frozen_string_literal: true

require 'builtin'

module Builtins
	class Background < Builtin
		DEFAULT_SHELL = "bash"
		DEFAULT_LOG_FILE_PREFIX = "/tmp/ops_bglog_"

		class << self
			def description
				"runs the given command in a background session"
			end

			def log_filename
				"#{log_filename_prefix}#{Ops.project_name}"
			end

			private

			def log_filename_prefix
				Options.get("background.log_filename_prefix") || DEFAULT_LOG_FILE_PREFIX
			end
		end

		def run
			subprocess = fork do
				run_ops(args)
			end

			Process.detach(subprocess)
		end

		private

		def run_ops(args)
			Output.warn("Running '#{args.join(' ')}' with stderr and stdout redirected to '#{Background.log_filename}'")
			$stdout.sync = $stderr.sync = true
			$stdout.reopen(Background.log_filename, "w")
			$stderr.reopen($stdout)

			Ops.new(args).run
		end

		def shell
			Options.get("background.shell") || DEFAULT_SHELL
		end
	end

	# set an alias
	Bg = Background
end
