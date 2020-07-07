# frozen_string_literal: true

require 'dependency'

module Dependencies
	class Sshkey < Dependency
		DEFAULT_KEY_SIZE = 2048
		DEFAULT_KEY_ALGO = "rsa"

		def met?
			File.exist?(priv_key_name) && File.exist?(pub_key_name)
		end

		def meet
			Secrets.load if Options.get("sshkey.load_secrets")

			FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)

			execute("ssh-keygen -b #{key_size} -t #{key_algo} -f #{priv_key_name} -q -N '#{passphrase}'")
		end

		def unmeet
			true
		end

		def should_meet?
			true
		end

		private

		def dir_name
			`echo #{File.dirname(name)}`.chomp
		end

		def priv_key_name
			`echo #{name}`.chomp
		end

		def pub_key_name
			"#{priv_key_name}.pub"
		end

		def key_size
			Options.get("sshkey.key_size") || DEFAULT_KEY_SIZE
		end

		def key_algo
			Options.get("sshkey.key_algo") || DEFAULT_KEY_ALGO
		end

		def passphrase
			`echo #{configured_passphrase}`.chomp
		end

		def configured_passphrase
			Options.get("sshkey.passphrase")
		end
	end
end
