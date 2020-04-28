# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Brew < Dependency
		def met?
			execute("brew list #{name}")
		end

		def meet
			execute("brew install #{name}")
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Darwin"
		end
	end
end
