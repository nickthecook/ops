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

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end
	end
end
