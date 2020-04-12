#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "require_all"

require_relative "action.rb"
require_rel "builtins"

# executes commands defined in local `ops.yml`
class Ops
	CONFIG_FILE = "ops.yml"

	def initialize(argv)
		@action_name = argv[0]
		@args = argv[1..-1]
	end

	def run
		return builtin.run if builtin

		puts "Running '#{action}' from #{CONFIG_FILE}..."
		action.run
	end

	private

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
	end
end

Ops.new(ARGV).run if $PROGRAM_NAME == __FILE__
