# frozen_string_literal: true

require "require_all"

require_relative "../builtin"

require_rel "../dependencies"

module Builtins
	class Up < Builtin
		def run
			# TODO: return a success/failure status to the caller
			install_dependencies
		end

		private

		def install_dependencies
			dependencies.each do |dependency|
				if dependency.met?
					puts "#{dependency.type} dependency '#{dependency.name}' already met; skipping..."
				else
					puts "Meeting #{dependency.type} dependency '#{dependency.name}'..."
					puts "Failed to meet dependency '#{dependency.name}'!" unless dependency.meet
				end
			end
		end

		def dependencies
			dependency_names_by_type.map do |type, names|
				dependencies_for(type, names)
			end.flatten
		end

		def dependencies_for(type, names)
			dependency_class = Dependencies.const_get(type.capitalize.to_sym)

			names.map { |name| dependency_class.new(name) }
		rescue NameError
			# TODO: output to stderr
			puts "No way to install dependencies of type '#{type}; ignoring."
		end

		def dependency_names_by_type
			@config["dependencies"] || []
		end
	end
end
