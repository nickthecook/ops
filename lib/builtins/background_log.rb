# frozen_string_literal: true

require 'builtin'
require 'builtins/background'

module Builtins
	class BackgroundLog < Builtin
		class << self
			def description
				"displays the log from the current or most recent background task from this project"
			end
		end

		def run
			unless File.exist?(Background.log_filename)
				Output.warn("No background log found at '#{Background.log_filename}'.")
				return 0
			end

			Output.notice("Displaying background log '#{Background.log_filename}'...")
			exec("tail #{args.join(' ')} '#{Background.log_filename}'")
		end
	end

	# set an alias
	Bglog = BackgroundLog
end
