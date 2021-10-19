# frozen_string_literal: true

require 'require_all'
require_rel "../../dependencies"

require 'builtin'
require 'builtins/helpers/dependency_handler'
require 'output'

module Builtins
	module Common
		class UpDown < Builtin
			class << self
				def description
					"attempts to meet dependencies listed in ops.yml"
				end
			end

			def run
				meet_dependencies

				return true unless fail_on_error?

				deps_to_meet.all?(&:success?)
			end

			private

			def meet_dependencies
				deps_to_meet.each do |dependency|
					Output.status("[#{dependency.type}] #{dependency.name}")

					meet_dependency(dependency)
				end
			end

			def meet_dependency(dependency)
				handle_dependency(dependency) if !dependency.met? || dependency.always_act?

				if dependency.success?
					Output.okay
				else
					Output.failed
					Output.error("Error meeting #{dependency.type} dependency '#{dependency.name}':")
					Output.out(dependency.output)
				end
			end

			def deps_to_meet
				@deps_to_meet ||= dependency_handler.dependencies.select(&:should_meet?)
			end

			def dependency_handler
				Helpers::DependencyHandler.new(dependencies)
			end

			def dependencies
				return @config["dependencies"] if @args.empty?

				@config["dependencies"].select { |dep, _names| @args.include?(dep) }
			end

			def fail_on_error?
				Options.get("up.fail_on_error") || false
			end
		end
	end
end
