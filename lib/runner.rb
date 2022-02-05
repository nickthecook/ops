# frozen_string_literal: true

require 'hook_handler'
require 'action'
require 'action_list'
require 'action_suggester'
require 'forwards'
require 'environment'
require 'builtin'

module Builtins
end

class Runner
	class UnknownActionError < StandardError; end

	class ActionConfigError < StandardError; end

	class NotAllowedInEnvError < StandardError; end

	def initialize(action_name, args, config, config_path)
		@action_name = action_name
		@args = args
		@config = config
		@config_path = config_path
	end

	def run
		return forward.run if forward

		do_before_all

		return builtin.run if builtin

		raise UnknownActionError, "Unknown action: #{@action_name}" unless action
		raise ActionConfigError, action.config_errors.join("; ") unless action.config_valid?

		do_before_action

		run_action
	end

	def suggestions
		@suggestions ||= ActionSuggester.new(action_list.names + action_list.aliases + builtin_names).check(@action_name)
	end

	private

	def do_before_all
		AppConfig.load
		Secrets.load if action&.load_secrets?
		environment.set_variables
	end

	def do_before_action
		return if ENV["OPS_RUNNING"] || action.skip_hooks?("before")

		# this prevents before hooks from running in ops executed by ops
		ENV["OPS_RUNNING"] = "1"
		hook_handler.do_hooks("before")
	end

	def hook_handler
		@hook_handler ||= HookHandler.new(@config)
	end

	def builtin
		Profiler.measure("runner:require_builtin") do
			@builtin ||= Builtin.class_for(name: @action_name)&.new(@args, @config)
		end
	rescue NameError
		# this means there isn't a builtin with that name in that module
		nil
	end

	def builtin_names
		Builtins.constants.select { |c| Builtins.const_get(c).is_a? Class }.map(&:downcase)
	end

	def forward
		@forward ||= Forwards.new(@config, @args).get(@action_name)
	end

	def run_action
		unless action.allowed_in_env?(Environment.environment)
			raise NotAllowedInEnvError, "Action not allowed in #{Environment.environment} environment."
		end

		unless action.execute_in_env?(Environment.environment)
			Output.warn("Skipping action '#{action.name}' in environment #{Environment.environment}.")
			return true
		end

		Output.notice("Running '#{action}' in environment '#{ENV['environment']}'...")
		action.run
	end

	def action
		return action_list.get(@action_name) if action_list.get(@action_name)
		return action_list.get_by_alias(@action_name) if action_list.get_by_alias(@action_name)
	end

	def action_list
		@action_list ||= begin
			Output.warn("'ops.yml' has no 'actions' defined.") if @config.any? && @config["actions"].nil?

			ActionList.new(@config["actions"], @args)
		end
	end

	def env_vars
		@config.dig("options", "environment") || {}
	end

	def environment
		@environment ||= Environment.new(env_vars, @config_path)
	end
end
