# frozen_string_literal: true

require 'builtin'

module Builtins
	class Background < Builtin
		DEFAULT_LOG_FILE_PREFIX = "/tmp/ops_bglog_"

		class << self
			def description
				"runs the given command in a background session"
			end

			def log_filename
				Options.get("background.log_filename") || "#{DEFAULT_LOG_FILE_PREFIX}#{Ops.project_name}"
			end
		end

		def run
			subprocess = fork do
				set_bglog_file_permissions
				run_ops(args)
			end

			Process.detach(subprocess)

			true
		end

		private

		def set_bglog_file_permissions
			File.new(Background.log_filename, "w").chmod(0o600)
		end

		def run_ops(args)
			Output.notice("Running '#{args.join(' ')}' with stderr and stdout redirected to '#{Background.log_filename}'")
			$stdout.sync = $stderr.sync = true
			$stdout.reopen(Background.log_filename, "w")
			$stderr.reopen($stdout)

			Ops.new(args).run
		end
	end

	# set an alias
	Bg = Background
end
