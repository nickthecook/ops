# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Brew < Dependency
		def installed?
			`brew list #{name}`
		end

		def install
			`brew install #{name}`
		end
	end
end
