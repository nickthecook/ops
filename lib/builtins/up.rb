# frozen_string_literal: true

require "require_all"

require_relative "../builtin"

require_rel "../dependencies"

module Builtins
	class Up < Builtin
		def run
			install_dependencies
		end

		private

		def install_dependencies
			# we probably need a DependencyInstaller to do this, and Up calls it
			# but this can wait until Up has more than one thing to do
			dependencies.each do |dependency|
				if dependency.installed?
					puts "Package #{dependency.name} already installed; skipping..."
				else
					puts "Installing package '#{dependency.name}..."
					dependency.install
				end
			end
		end

		def dependencies
			dependency_types.map do |type, names|
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

		def brew_dependencies
			brew_dependency_names.map { |name| Dependencies::Brew.new(name) }
		end

		def brew_dependency_names
			dependency_types["brew"] || []
		end

		def dependency_types
			@config["dependencies"] || []
		end
	end
end
