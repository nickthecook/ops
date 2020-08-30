# frozen_string_literal: true

require 'secrets'

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	def initialize(config, args)
		@config = config
		@args = args
	end

	def config_ok?
		config_errors.empty?
	end

	def config_errors
		@config_errors ||= begin
			errors = []

			errors << "Missing 'command' field." unless @config["command"]

			errors
		end
	end

	def run
		Secrets.load if load_secrets?

		Kernel.exec(to_s)
	end

	def to_s
		"#{command} #{@args.join(' ')}".strip
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

	def skip_hooks?(name)
		@config["skip_#{name}_hooks"]
	end

	private

	def load_secrets?
		@config["load_secrets"]
	end
end
