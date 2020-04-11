#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

require_relative "action.rb"

# executes commands defined in local `ops.yml`
class Ops
	CONFIG_FILE = "ops.yml"

	def initialize(argv)
		@action_name = argv[0]
		@args = argv[1..-1]
	end

	def run
		puts "Running '#{action}' from #{CONFIG_FILE}..."
		Kernel.exec(action.to_s)
	end

	private

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
