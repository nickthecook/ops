# frozen_string_literal: true

require 'dependencies/brew'

module Dependencies
	class Cask < Brew
		def met?
			execute("brew cask list #{name}")
		end

		def meet
			execute("brew cask install #{name}")
		end
	end
end
