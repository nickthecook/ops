# frozen_string_literal: true

require 'require_all'
require_rel "../dependencies"

require 'builtin'
require 'builtins/helpers/dependency_handler'
require 'output'

module Builtins
	class Up < Builtin
		class << self
			def description
				"attempts to meet dependencies listed in ops.yml"
			end
		end

		def run
			# TODO: return a success/failure status to the caller
			meet_dependencies
		end

		private

		def dependency_handler
			Helpers::DependencyHandler.new(deps_to_meet)
		end

		def meet_dependencies
			dependency_handler.dependencies.each do |dependency|
				# don't even output anything for dependencies that shouldn't be considered on this machine
				next unless dependency&.should_meet?

				Output.status("[#{dependency.type}] #{dependency.name}")

				meet_dependency(dependency)
			end
		end

		def meet_dependency(dependency)
			# TODO: make this simpler, and factor in `should_meet?` above, too
			dependency.meet if !dependency.met? || dependency.always_act?

			if dependency.success?
				Output.okay
			else
				Output.failed
				Output.error("Error meeting #{dependency.type} dependency '#{dependency.name}':")
				Output.out(dependency.output)
			end
		end

		def deps_to_meet
			return @config["dependencies"] if @args.empty?

			return @config["dependencies"].select { |dep, names| @args.include?(dep) }
		end
	end
end
