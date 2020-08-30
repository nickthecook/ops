# frozen_string_literal: true

require 'output'

class HookHandler
	class HookConfigError < StandardError; end
	class HookExecError < StandardError; end

	def initialize(config)
		@config = config
	end

	def do_hooks(name)
		raise HookConfigError, "'hooks.#{name}' must be a list" unless hooks(name).is_a?(Array)

		execute_hooks(name)
	end

	private

	def hooks(name)
		@config.dig("hooks", name) || []
	end

	def execute_hooks(name)
		hooks(name).each do |hook|
			Output.notice("Running #{name} hook: #{hook}")
			output, exit_code = Executor.execute(hook)

			next if exit_code.zero?

			raise HookExecError, "#{name} hook '#{hook}' failed with exit code #{exit_code}:\n#{output}"
		end
	end
end
