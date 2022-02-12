# frozen_string_literal: true

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
			display_file
		end

		private

		def display_file
			if args.any?
				exec("tail #{args.join(' ')} '#{Background.log_filename}'")
			else
				exec("cat '#{Background.log_filename}'")
			end
		end
	end

	# set an alias
	Bglog = BackgroundLog
end
