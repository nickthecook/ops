# frozen_string_literal: true

require 'fileutils'

require 'builtin'
require 'output'

module Builtins
	class Init < Builtin
		OPS_YML = "ops.yml"
		TEMPLATE_DIR = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "etc"))
		OPS_YML_TEMPLATE = File.join(TEMPLATE_DIR, "%<template_name>s.template.yml")
		DEFAULT_TEMPLATE_NAME = "ops"

		class << self
			def description
				"creates an ops.yml file from a template"
			end
		end

		def run
			if File.exist?(OPS_YML)
				Output.error("File '#{OPS_YML} exists; not initializing.")
			else
				Output.out("Creating '#{OPS_YML} from template...")
				FileUtils.cp(template_path, OPS_YML)
			end
		rescue SystemCallError
			Output.error(template_not_found_message)
			exit 1
		end

		private

		def template_name
			@args[0]
		end

		def template_path
			return template_name if template_name && File.exist?(template_name)

			builtin_template_path
		end

		def builtin_template_path
			format(OPS_YML_TEMPLATE, template_name: template_name || DEFAULT_TEMPLATE_NAME)
		end

		def template_name_list
			@template_name_list ||= Dir.entries(TEMPLATE_DIR).map do |name|
				name.match(/^([^.]*).template.yml/)&.captures&.first
			end.compact
		end

		def template_not_found_message
			<<~MESSAGE
				Template '#{template_path} does not exist.
				\nValid template names are:
				   - #{template_name_list.join("\n   - ")}\n
			MESSAGE
		end
	end
end
