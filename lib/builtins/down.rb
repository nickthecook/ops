# frozen_string_literal: true

require "require_all"
require_rel "../dependencies"

require_relative "../builtin"
require_relative "helpers/dependency_handler"

module Builtins
	class Down < Builtin
		def run
			# TODO: return a success/failure status to the caller
			unmeet_dependencies
		end

		private

		def dependency_handler
			Helpers::DependencyHandler.new(@config["dependencies"])
		end

		def unmeet_dependencies
			dependency_handler.dependencies.each do |dependency|
				# don't even output anything for dependencies that shouldn't be considered on this machine
				next unless dependency.should_meet?

				Output.status("[#{dependency.type}] #{dependency.name}")

				unmeet_dependency(dependency)
			end
		end

		def unmeet_dependency(dependency)
			# TODO: make this simpler, and factor in `should_meet?` above, too
			dependency.unmeet if dependency.met? || dependency.always_act?

			if dependency.success?
				Output.okay
			else
				Output.failed
				Output.error("Error unmeeting #{dependency.type} dependency '#{dependency.name}':")
				puts(dependency.output)
			end
		end
	end
end
