# frozen_string_literal: true

require 'secrets'

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	class NotAllowedInEnvError < StandardError; end

	def initialize(config, args)
		@config = config
		@args = args
	end

	def run
		unless allowed_in_current_env?
			raise NotAllowedInEnvError, "Action not allowed in #{Environment.environment} environment."
		end

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

	def config_valid?
		config_errors.empty?
	end

	def config_errors
		@config_errors ||= begin
			errors = []

			errors << "No 'command' specified in 'action'." unless @config['command']

			errors
		end
	end

	def load_secrets?
		@config["load_secrets"].nil? ? false : @config["load_secrets"]
	end

	private

	def not_in_envs
		@config["not_in_envs"] || []
	end

	def in_envs
		@config["in_envs"] || []
	end

	def allowed_in_current_env?
		return false if not_in_envs.include?(Environment.environment)

		return false if in_envs.any? && !in_envs.include?(Environment.environment)

		true
	end
end
