# frozen_string_literal: true

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	def initialize(command, args)
		@command = command
		@args = args
	end

	def run
		Kernel.exec(to_s)
	end

	def to_s
		"#{@command} #{@args.join(' ')}"
	end
end
