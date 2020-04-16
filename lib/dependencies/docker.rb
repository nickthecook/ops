# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Docker < Dependency
		def met?
			# this will return true if docker-compose returns any output,
			# which it will if containers are running
			system("cd #{name} && docker-compose ps -q | grep -q .")
		end

		def meet
			system("cd #{name} && docker-compose up -d")
		end
	end
end
