# frozen_string_literal: true

module Dependencies
	class Docker < Dependency
		def met?
			execute("cd #{name} && docker-compose ps | grep -q ' Up '")
		end

		def meet
			execute("cd #{name} && docker-compose up -d")
		end

		def unmeet
			execute("cd #{name} && docker-compose down")
		end
	end
end
