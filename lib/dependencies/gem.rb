# frozen_string_literal: true

require 'dependency'
require 'options'

module Dependencies
	class Gem < VersionedDependency
		def met?
			if versioned?
				execute("gem list -i '^#{dep_name}$' -v '#{dep_version}'") if versioned?
			else
				execute("gem list -i '^#{name}$'")
			end
		end

		def meet
			if versioned?
				execute("#{sudo_string}gem install #{user_install_string}'#{dep_name}' -v '#{dep_version}'")
			else
				execute("#{sudo_string}gem install #{user_install_string}'#{name}'")
			end
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		private

		def sudo_string
			Options.get("gem.use_sudo") ? "sudo " : ""
		end

		def user_install_string
			Options.get("gem.user_install") ? "--user-install " : ""
		end
	end
end
