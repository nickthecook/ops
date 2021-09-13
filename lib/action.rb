# frozen_string_literal: true

require 'secrets'

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	attr_reader :name

	DEFAULT_SHELL = "/bin/bash"

	def initialize(name, config, args)
		@name = name
		@config = config
		@args = args
	end

	def run
		if perform_shell_expansion?
			Kernel.exec(exec_string)
		else
			Kernel.exec(*to_a)
		end
	end

	def to_s
		# fix "Running ..." output
		@to_s ||= begin
			# switch to arg lists
			if append_args?
				"#{shell} -c '#{command} #{@args.join(' ')}'"
			else
				"#{shell} -c '#{command}' '#{@name}' #{@args.join(' ')}"
			end
		end
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

	def execute_in_env?(env)
		!skip_in_envs.include?(env)
	end

	def allowed_in_env?(env)
		return false if not_in_envs.include?(env)

		return false if in_envs.any? && !in_envs.include?(env)

		true
	end

	private

	def shell
		ENV["SHELL"] || DEFAULT_SHELL
	end

	def append_args?
		@append_args ||= !command.match?(/\$[0-9*@]+/)
	end

	def to_a
		command.split(" ").reject(&:nil?) | @args
	end

	def not_in_envs
		@config["not_in_envs"] || []
	end

	def in_envs
		@config["in_envs"] || []
	end

	def skip_in_envs
		@config["skip_in_envs"] || []
	end

	def perform_shell_expansion?
		@config["shell_expansion"].nil? ? true : @config["shell_expansion"]
	end
end
