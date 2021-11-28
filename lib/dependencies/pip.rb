# frozen_string_literal: true

require 'English'

require 'dependency'
require 'options'

module Dependencies
	class Pip < Dependency
		DEFAULT_PIP = "python3 -m pip"

		def met?
			execute("#{pip} show #{name}")
		end

		def meet
			execute("#{pip} install #{name}")
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			true
		end

		private

		def pip
			Options.get("pip.command") || DEFAULT_PIP
		end
	end
end
