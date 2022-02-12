# frozen_string_literal: true

module Dependencies
	class Cask < Brew
		def met?
			execute("brew list --cask #{name}")
		end

		def meet
			execute("brew install --cask #{name}")
		end
	end
end
