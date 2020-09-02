# frozen_string_literal: true

require 'dependencies/versioned_dependency'
require 'dependencies/helpers/apt_cache_policy'

module Dependencies
	class Apt < VersionedDependency
		def met?
			return apt_cache_policy.installed_version == dep_version if dep_version

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
			`uname`.chomp == "Linux" && system("which apt-get")
		end

		private

		def apt_cache_policy
			@apt_cache_policy ||= Dependencies::Helpers::AptCachePolicy.new(dep_name)
		end

		def sudo_string
			return "" if ENV['USER'] == "root" || `whoami` == "root" || Options.get("apt.use_sudo") == false

			"sudo "
		end
	end
end
