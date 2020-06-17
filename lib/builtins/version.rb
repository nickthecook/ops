# frozen_string_literal: true

require "rubygems"

require "output"

module Builtins
	class Version < Builtin
		GEMSPEC_FILE = "#{__dir__}/../../ops_team.gemspec"

		class << self
			def description
				"prints the version of ops that is running"
			end
		end

		def run
			unless gemspec
				Output.error("Unable to load gemspec at '#{GEMSPEC_FILE}")
				return false
			end

			Output.out(gemspec.version)
		end

		private

		def gemspec
			@gemspec ||= Gem::Specification.load(GEMSPEC_FILE)
		end
	end
end
