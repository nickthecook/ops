# frozen_string_literal: true

require_relative "../dependency"

module Dependencies
	class Apt < Dependency
		def met?
			`dpkg-query --show --showformat '${db:Status-Status}\n' #{name} | grep -q ^installed`
		end

		def meet
			`apt-get install -y #{name}`
		end

		def unmeet
			# do nothing; we don't want to uninstall packages and reinstall them every time
			true
		end

		def should_meet?
			`uname`.chomp == "Linux"
		end
	end
end
