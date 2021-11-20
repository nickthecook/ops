# frozen_string_literal: true

require 'English'

require 'dependency'

module Dependencies
	class Apk < Dependency
		def met?
			execute("apk info | grep -q '^#{name}'$")
		end

		def meet
			execute("apk add #{name}")
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Linux" && system("which apk", out: File::NULL, err: File::NULL)
		end
	end
end
