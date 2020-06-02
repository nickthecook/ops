#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'require_all'

require 'action'
require 'output'
require 'options'
require 'environment'
require_rel "builtins"

# executes commands based on local `ops.yml`
class Ops
	class UnknownActionError < StandardError; end

	CONFIG_FILE = "ops.yml"

	INVALID_SYNTAX_EXIT_CODE = 1

	def initialize(argv)
		@action_name = argv[0]
		@args = argv[1..-1]

		Options.set(config["options"] || {})
	end

	def run
		exit(INVALID_SYNTAX_EXIT_CODE) unless syntax_valid?

		environment.set_variables

		return builtin.run if builtin

		Output.warn("Running '#{action}' from #{CONFIG_FILE}...")
		action.run
	rescue UnknownActionError => e
		Output.error("Error: #{e}")
	end

	private

	def syntax_valid?
		if @action_name.nil?
			# TODO: output to stderr
			puts "Usage: ops <action>"
			false
		else
			true
		end
	end

	def builtin
		@builtin ||= Builtins.const_get(builtin_class_name, false).new(@args, config)
	rescue NameError
		# this means there isn't a builtin with that name in that module
		nil
	end

	def builtin_class_name
		@action_name.capitalize.to_sym
	end

	def action
		return actions[@action_name] if actions[@action_name]
		return aliases[@action_name] if aliases[@action_name]

		raise UnknownActionError, "Unknown action: #{@action_name}"
	end

	def actions
		config["actions"].transform_values do |config|
			Action.new(config, @args, action_options)
		end
	end

	def config
		@config ||= begin
			Output.warn("File '#{CONFIG_FILE}' does not exist.") unless File.exist?(CONFIG_FILE)
			YAML.load_file(CONFIG_FILE)
		rescue StandardError
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

	def action_options
		@action_options ||= @config.dig("options", "actions")
	end

	def env_vars
		@config.dig("options", "environment") || {}
	end

	def environment
		@environment ||= Environment.new(env_vars)
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
