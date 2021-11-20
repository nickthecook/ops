#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'require_all'
require "rubygems"

require 'output'
require 'options'
require 'version'
require 'runner'

require_rel "builtins"

# executes commands based on local `ops.yml`
class Ops
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

	def initialize(argv, config_file: nil)
		@action_name = argv[0]
		@args = argv[1..-1]
		@config_file = config_file || "ops.yml"

		Options.set(config["options"] || {})
	end

	# rubocop:disable Metrics/MethodLength
	# better to have all the rescues in one place
	def run
		# "return" is here to allow specs to stub "exit" without executing everything after it
		return exit(INVALID_SYNTAX_EXIT_CODE) unless syntax_valid?
		return exit(MIN_VERSION_NOT_MET_EXIT_CODE) unless min_version_met?

		runner.run
	rescue Runner::UnknownActionError => e
		Output.error(e.to_s)
		Output.out(RECOMMEND_HELP_TEXT) unless print_did_you_mean
		exit(UNKNOWN_ACTION_EXIT_CODE)
	rescue Runner::ActionConfigError => e
		Output.error("Error(s) running action '#{@action_name}': #{e}")
		exit(ACTION_CONFIG_ERROR_EXIT_CODE)
	rescue Builtin::ArgumentError => e
		Output.error("Error running builtin '#{@action_name}': #{e}")
		exit(BUILTIN_SYNTAX_ERROR_EXIT_CODE)
	rescue AppConfig::ParsingError => e
		Output.error("Error parsing app config: #{e}")
		exit(ERROR_LOADING_APP_CONFIG_EXIT_CODE)
	rescue Runner::NotAllowedInEnvError => e
		Output.error("Error running action #{@action_name}: #{e}")
		exit(ACTION_NOT_ALLOWED_IN_ENV_EXIT_CODE)
	end
	# rubocop:enable Metrics/MethodLength

	private

	def syntax_valid?
		return true unless @action_name.nil?

		Output.error("Usage: ops <action>")
		Output.out(RECOMMEND_HELP_TEXT)
		false
	end

	def print_did_you_mean
		Output.out("Did you mean '#{runner.suggestions.join(", ")}'?") if runner.suggestions.any?

		runner.suggestions.any?
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

	def runner
		@runner ||= Runner.new(@action_name, @args, config, config_file_absolute_path)
	end

	def config
		@config ||= if config_file_exists?
			parsed_config_contents
		else
			Output.warn("File '#{@config_file}' does not exist.") unless @action_name == "init"
			{}
		end
	end

	def parsed_config_contents
		YAML.load_file(@config_file)
	rescue StandardError => e
		Output.warn("Error parsing '#{@config_file}': #{e}")
		{}
	end

	def config_file_exists?
		File.exist?(@config_file)
	end

	def config_file_absolute_path
		File.expand_path(@config_file)
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
