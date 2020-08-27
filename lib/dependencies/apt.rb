# frozen_string_literal: true

require 'dependency'
require 'dependencies/helpers/apt_cache_policy'

module Dependencies
	class Apt < Dependency
		PACKAGE_NAME_SEPARATOR = "/"

		def met?
			return apt_cache_policy.installed_version == package_version if package_version

			apt_cache_policy.installed?
		end

		def meet
			execute("#{sudo_string}apt-get install -y #{name}")
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Linux" && system("which apt-get &>/dev/null")
		end

		private

		def package_name
			name_components[0]
		end

		def package_version
			name_components[1]
		end

		def name_components
			name.split(PACKAGE_NAME_SEPARATOR, 2)
		end

		def apt_cache_policy
			@apt_cache_policy ||= Dependencies::Helpers::AptCachePolicy.new(package_name)
		end

		def sudo_string
			return "" if ENV['USER'] == "root" || Options.get("apt.use_sudo") == false

			"sudo "
		end
	end
end
