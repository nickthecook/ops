# frozen_string_literal: true

require 'dependency'
require 'options'

module Dependencies
	class Gem < Dependency
		def met?
			execute("gem list -i '^#{name}$'")
		end

		def meet
			if Options.get("gem.use_sudo")
				execute("sudo gem install #{name}")
			elsif Options.get("gem.user_install")
				execute("gem install --user-install #{name}")
			else
				execute("gem install #{name}")
			end
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end
	end
end
