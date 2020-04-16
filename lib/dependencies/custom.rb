# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Custom < Dependency
		def met?
			# we always want to try to meet this dependency
			false
		end

		def meet
			# this dependency is just a custom, idempotent command
			system(name)
		end

		def unmeet
			true
		end
	end
end
