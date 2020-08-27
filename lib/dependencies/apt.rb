# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Apt < Dependency
		def met?
			execute("dpkg-query --show --showformat '${db:Status-Status}\n' #{name} | grep -q ^installed")
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

		def sudo_string
			return "" if ENV['USER'] == "root" || Options.get("apt.use_sudo") == false

			"sudo "
		end
	end
end
