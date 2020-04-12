# frozen_string_literal: true

require "fileutils"

require_relative "../builtin"

module Builtins
	class Init < Builtin
		OPS_YML = "ops.yml"
		OPS_YML_TEMPLATE = File.join(
			File.dirname(__FILE__),
			"..",
			"..",
			"etc",
			"ops.template.yml"
		)

		def run
			if File.exist?(OPS_YML)
				# TODO: output to stderr
				puts "File '#{OPS_YML} exists; not initializing."
			else
				FileUtils.cp(OPS_YML_TEMPLATE, OPS_YML)
			end
		end
	end
end
