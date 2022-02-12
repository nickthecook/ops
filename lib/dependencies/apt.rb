# frozen_string_literal: true

module Dependencies
	class Apt < VersionedDependency
		def met?
			if versioned?
				apt_cache_policy.installed_version == dep_version
			else
				apt_cache_policy.installed?
			end
		end

		def meet
			if versioned?
				execute("#{sudo_string}apt-get install -y #{dep_name}=#{dep_version}")
			else
				execute("#{sudo_string}apt-get install -y #{name}")
			end
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Linux" && system("which apt-get", out: File::NULL, err: File::NULL)
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
