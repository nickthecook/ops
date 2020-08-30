# frozen_string_literal: true

class Version
	GEMSPEC_FILE = "#{__dir__}/../ops_team.gemspec"

	class << self
		def version
			new.version
		end
	end

	def version
		unless gemspec
			Output.error("Unable to load gemspec at '#{GEMSPEC_FILE}")
			return nil
		end

		gemspec&.version
	end

	private

	def gemspec
		@gemspec ||= Gem::Specification.load(GEMSPEC_FILE)
	end
end
