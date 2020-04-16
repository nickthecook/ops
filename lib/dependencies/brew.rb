# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Brew < Dependency
		def met?
			`brew list #{name}`
		end

		def meet
			`brew install #{name}`
		end
	end
end
