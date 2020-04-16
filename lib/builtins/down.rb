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
				if dependency.met?
					puts "Unmeeting #{dependency.type} dependency '#{dependency.name}'..."
					puts "Failed to unmeet dependency '#{dependency.name}'!" unless dependency.unmeet
				else
					puts "#{dependency.type} dependency '#{dependency.name}' not met; skipping..."
				end
			end
		end
	end
end
