# frozen_string_literal: true

require 'secrets'

# represents one action to be performed in the shell
# can assemble a command line from a command and args
class Action
	def initialize(config, args)
		@config = config
		@args = args
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
		@config["description"] || @config["desc"]
	end

	def skip_hooks?(name)
		@config["skip_#{name}_hooks"]
	end

	def config_valid?
		config_errors.empty?
	end

	def config_errors
		@config['command'] ? [] : "No 'command' specified."
	end

	def args_valid?
		arg_errors.empty?
	end

	def arg_errors
		@arg_errors ||= begin
			errors = []

			errors << extra_arg_error if @args.length > configured_arg_count && !extra_args_allowed?
			# errors << missing_required_args_error

			errors
		end
	end

	private

	def extra_args_allowed?
		@config["extra_args_allowed"].nil? ? true : @config["extra_args_allowed"]
	end

	def extra_arg_error
		"Too many arguments; expected #{configured_arg_count}, got #{@args.length}."
	end

	def configured_arg_count
		@config["args"]&.length || 0
	end

	def missing_required_args_error
		""
	end

	def required_args_present?
		missing_required_args.empty?
	end

	def missing_required_args

	end

	def load_secrets?
		@config["load_secrets"]
	end
end
