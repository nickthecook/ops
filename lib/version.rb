# frozen_string_literal: true

require "rubygems"

class Version
	GEMSPEC_FILE = "#{__dir__}/../ops_team.gemspec"

	class << self
		# these class methods exist because I don't want to have to call `Version.new.version` elsewhere
		def version
			new.send(:version)
		end

		def min_version_met?(min_version)
			new.send(:min_version_met?, min_version)
		end
	end

	private

	# these instance methods exist so that I don't have to clear class variables between tests
	def version
		unless gemspec
			Output.error("Unable to load gemspec at '#{GEMSPEC_FILE}")
			return nil
		end

		gemspec.version
	end

	def min_version_met?(min_version)
		Gem::Version.new(version) >= Gem::Version.new(min_version)
	end

	def gemspec
		@gemspec ||= Gem::Specification.load(GEMSPEC_FILE)
	end
end
