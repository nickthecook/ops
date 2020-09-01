# frozen_string_literal: true

require 'colorize'

class Output
	@out = STDOUT
	@err = STDERR

	STATUS_WIDTH = "50"

	OKAY = "OK"
	SKIPPED = "SKIPPED"
	FAILED = "FAILED"

	# used to silence output, e.g. in testing
	class DummyOutput
		def print(*_); end

		def puts(*_); end
	end

	class << self
		def status(name)
			@out.print(format("%-#{STATUS_WIDTH}<name>s ", name: name))
		end

		def okay
			@out.puts(OKAY.green)
		end

		def skipped
			@out.puts(SKIPPED.yellow)
		end

		def failed
			@out.puts(FAILED.red)
		end

		def warn(msg)
			@err.puts(msg.yellow)
		end

		alias notice warn

		def error(msg)
			@err.puts(msg.red)
		end

		def out(msg)
			@out.puts(msg)
		end

		def print(msg)
			@out.print(msg)
		end

		def silence
			@out = @err = dummy_output
		end

		def dummy_output
			@dummy_output ||= DummyOutput.new
		end
	end
end
