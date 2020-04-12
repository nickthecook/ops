#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "require_all"

require_relative "action.rb"
require_rel "builtins"

# executes commands defined in local `ops.yml`
class Ops
	CONFIG_FILE = "ops.yml"

	INVALID_SYNTAX_EXIT_CODE = 1

	def initialize(argv)
		@action_name = argv[0]
		@args = argv[1..-1]
	end

	def run
		exit(INVALID_SYNTAX_EXIT_CODE) unless syntax_valid?

		return builtin.run if builtin

		# TODO: output to stderr
		puts "Running '#{action}' from #{CONFIG_FILE}..."
		action.run
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
		@builtin ||= Builtins.const_get(builtin_class_name).new(@args, config)
	rescue NameError
		# this means there isn't a builtin with that name in that module
		nil
	end

	def builtin_class_name
		@action_name.capitalize.to_sym
	end

	def action
		@action ||= Action.new(command, @args)
	end

	def command
		@command ||= actions[@action_name]["command"]
	end

	def actions
		config["actions"]
	end

	def deps
		config["deps"]
	end

	def config
		@config ||= YAML.load_file(CONFIG_FILE)
	rescue StandardError
		{}
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
