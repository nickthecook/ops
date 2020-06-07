# frozen_string_literal: true

require 'secrets'

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	def initialize(config, args, options)
		@config = config
		@args = args
		@options = options
	end

	def run
		load_secrets if load_secrets?

		Kernel.exec(to_s)
	end

	def to_s
		"#{command} #{@args.join(' ')}"
	end

	def alias
		@config["alias"]
	end

	def command
		@config["command"]
	end

	def description
		@config["description"]
	end

	private

	def load_secrets?
		@config["load_secrets"]
	end

	def load_secrets
		Secrets.new(secrets_file).load
	end

	def secrets_file
		`echo -n #{@options&.dig("secrets", "path")}`
	end
end
