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
require_rel "builtins"

# executes commands based on local `ops.yml`
class Ops
	class UnknownActionError < StandardError; end

	CONFIG_FILE = "ops.yml"

	INVALID_SYNTAX_EXIT_CODE = 64
	UNKNOWN_ACTION_EXIT_CODE = 65
	ERROR_LOADING_APP_CONFIG_EXIT_CODE = 66
	MIN_VERSION_NOT_MET_EXIT_CODE = 67

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
		# "return" is here to allow specs to stub "exit"
		return exit(INVALID_SYNTAX_EXIT_CODE) unless syntax_valid?
		return exit(MIN_VERSION_NOT_MET_EXIT_CODE) unless min_version_met?

		run_action
	rescue UnknownActionError => e
		Output.error("Error: #{e}")
		exit(UNKNOWN_ACTION_EXIT_CODE)
	end

	private

	def syntax_valid?
		if @action_name.nil?
			Output.error("Usage: ops <action>")
			false
		else
			true
		end
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
		do_before_run_action

		return builtin.run if builtin

		Output.notice("Running '#{action}' from #{CONFIG_FILE} in environment '#{ENV['environment']}'...")
		action.run
	rescue AppConfig::ParsingError => e
		Output.error("Error parsing app config: #{e}")
		exit(ERROR_LOADING_APP_CONFIG_EXIT_CODE)
	end

	def do_before_run_action
		environment.set_variables
		AppConfig.load
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

	def action
		return actions[@action_name] if actions[@action_name]
		return aliases[@action_name] if aliases[@action_name]

		raise UnknownActionError, "Unknown action: #{@action_name}"
	end

	def actions
		@actions ||= begin
			if config["actions"]
				config["actions"]&.transform_values do |config|
					Action.new(config, @args)
				end
			else
				# only print this error if ops.yml had something in it
				Output.warn("'ops.yml' has no 'actions' defined.") if config.any?
				{}
			end
		end
	end

	def config
		@config ||= begin
			Output.warn("File '#{CONFIG_FILE}' does not exist.") unless File.exist?(CONFIG_FILE)
			YAML.load_file(CONFIG_FILE)
		rescue StandardError => e
			Output.warn("Error parsing '#{CONFIG_FILE}': #{e}")
			{}
		end
	end

	def aliases
		@aliases ||= begin
			actions.each_with_object({}) do |(_name, action), alias_hash|
				alias_hash[action.alias] = action if action.alias
			end
		end
	end

	def env_vars
		@config.dig("options", "environment") || {}
	end

	def environment
		@environment ||= Environment.new(env_vars)
	end

	def app_config
		@app_config ||= AppConfig.new
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
