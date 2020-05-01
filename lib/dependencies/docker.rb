# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Docker < Dependency
		def met?
			# this will return true if docker-compose returns any output,
			# which it will if containers are running
			execute("cd #{name} && docker-compose ps -q | grep -q .")
		end

		def meet
			execute("cd #{name} && docker-compose up -d")
		end

		def unmeet
			execute("cd #{name} && docker-compose down")
		end
	end
end
