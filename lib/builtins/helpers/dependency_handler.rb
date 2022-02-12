# frozen_string_literal: true

module Builtins
	module Helpers
		class DependencyHandler
			def initialize(dependency_set)
				@dependency_set = dependency_set
			end

			def dependencies
				return [] unless @dependency_set

				@dependency_set.map do |type, names|
					dependencies_for(type, names)
				end.flatten.compact
			end

			def dependencies_for(type, names)
				dependency_class = Dependencies.const_get(type.capitalize.to_sym, false)

				names.map { |name| dependency_class.new(name) }
			rescue NameError
				Output.error("No way to handle dependencies of type '#{type}'; ignoring.")
			end
		end
	end
end
