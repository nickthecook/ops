# frozen_string_literal: true

require_relative "../../builtin.rb"

module Builtins
	module Helpers
		class DependencyHandler
			def initialize(dependency_set)
				@dependency_set = dependency_set
			end

			def dependencies
				@dependency_set.map do |type, names|
					dependencies_for(type, names)
				end.flatten
			end

			def dependencies_for(type, names)
				dependency_class = Dependencies.const_get(type.capitalize.to_sym)

				names.map { |name| dependency_class.new(name) }
			rescue NameError
				# TODO: output to stderr
				puts "No way to handle dependencies of type '#{type}; ignoring."
			end
		end
	end
end
