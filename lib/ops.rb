#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'require_all'
require "rubygems"

require 'hook_handler'
require 'action'
require 'output'
require 'options'
require 'environment'
require 'version'
require 'action_list'
require 'action_suggester'
require 'forwards'

require_rel "builtins"

# executes commands based on local `ops.yml`
class Ops
	class UnknownActionError < StandardError; end
	class ActionConfigError < StandardError; end

	CONFIG_FILE = "ops.yml"

	INVALID_SYNTAX_EXIT_CODE = 64
	UNKNOWN_ACTION_EXIT_CODE = 65
	ERROR_LOADING_APP_CONFIG_EXIT_CODE = 66
	MIN_VERSION_NOT_MET_EXIT_CODE = 67
	ACTION_CONFIG_ERROR_EXIT_CODE = 68
	BUILTIN_SYNTAX_ERROR_EXIT_CODE = 69
	ACTION_NOT_ALLOWED_IN_ENV_EXIT_CODE = 70

	RECOMMEND_HELP_TEXT = "Run 'ops help' for a list of builtins and actions."

	class << self
		def project_name
			File.basename(::Dir.pwd)
		end
	end

	def initialize(argv)
		@action_name = argv[0]
		@args = argv[1..-1]

		Options.set(config["options"] || {})
	end

	def run
		# "return" is here to allow specs to stub "exit" without executing everything after it
		return exit(INVALID_SYNTAX_EXIT_CODE) unless syntax_valid?
		return exit(MIN_VERSION_NOT_MET_EXIT_CODE) unless min_version_met?

		run_action
	rescue UnknownActionError => e
		Output.error(e.to_s)
		Output.out(RECOMMEND_HELP_TEXT) unless print_did_you_mean
		exit(UNKNOWN_ACTION_EXIT_CODE)
	rescue ActionConfigError => e
		Output.error("Error(s) running action '#{@action_name}': #{e}")
		exit(ACTION_CONFIG_ERROR_EXIT_CODE)
	end

	private

	def syntax_valid?
		if @action_name.nil?
			Output.error("Usage: ops <action>")
			Output.out(RECOMMEND_HELP_TEXT)
			false
		else
			true
		end
	end

	def print_did_you_mean
		suggestions = did_you_mean.check(@action_name)

		Output.out("Did you mean '#{suggestions.join(", ")}'?") if suggestions.any?

		suggestions.any?
	end

	def did_you_mean
		ActionSuggester.new(action_list.names + action_list.aliases + builtin_names)
	end

	def min_version_met?
		return true unless min_version

		if Version.min_version_met?(min_version)
			true
		else
			Output.error("ops.yml specifies minimum version of #{min_version}, but ops version is #{Version.version}")
			false
		end
	end

	def min_version
		config["min_version"]
	end

	def run_action
		return forward.run if forward

		do_before_all

		return builtin.run if builtin

		raise ActionConfigError, action.config_errors.join("; ") unless action.config_valid?

		do_before_action
		Output.notice("Running '#{action}' from #{CONFIG_FILE} in environment '#{ENV['environment']}'...")
		action.run
	rescue Builtin::ArgumentError => e
		Output.error("Error running builtin '#{@action_name}': #{e}")
		exit(BUILTIN_SYNTAX_ERROR_EXIT_CODE)
	rescue AppConfig::ParsingError => e
		Output.error("Error parsing app config: #{e}")
		exit(ERROR_LOADING_APP_CONFIG_EXIT_CODE)
	rescue Action::NotAllowedInEnvError => e
		Output.error("Error running action #{@action_name}: #{e}")
		exit(ACTION_NOT_ALLOWED_IN_ENV_EXIT_CODE)
	end

	def do_before_all
		environment.set_variables
		AppConfig.load
	end

	def do_before_action
		return if ENV["OPS_RUNNING"] || action.skip_hooks?("before")

		# this prevents before hooks from running in ops executed by ops
		ENV["OPS_RUNNING"] = "1"
		hook_handler.do_hooks("before")
	end

	def hook_handler
		@hook_handler ||= HookHandler.new(config)
	end

	def builtin
		@builtin ||= Builtin.class_for(name: @action_name).new(@args, config)
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

	def action
		return action_list.get(@action_name) if action_list.get(@action_name)
		return action_list.get_by_alias(@action_name) if action_list.get_by_alias(@action_name)

		raise UnknownActionError, "Unknown action: #{@action_name}"
	end

	def action_list
		@action_list ||= begin
			Output.warn("'ops.yml' has no 'actions' defined.") if config.any? && config["actions"].nil?

			ActionList.new(config["actions"], @args)
		end
	end

	def config
		@config ||= begin
			if File.exist?(CONFIG_FILE)
				YAML.load_file(CONFIG_FILE)
			else
				Output.warn("File '#{CONFIG_FILE}' does not exist.") unless @action_name == "init"
				{}
			end
		rescue StandardError => e
			Output.warn("Error parsing '#{CONFIG_FILE}': #{e}")
			{}
		end
	end

	def env_vars
		config.dig("options", "environment") || {}
	end

	def environment
		@environment ||= Environment.new(env_vars)
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
