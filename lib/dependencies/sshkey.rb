# frozen_string_literal: true

require 'net/ssh'

require 'dependency'

module Dependencies
	class Sshkey < Dependency
		DEFAULT_KEY_SIZE = 2048
		DEFAULT_KEY_ALGO = "rsa"
		DEFAULT_KEY_LIFETIME_S = 600

		def met?
			# we always need to at least update the key lifetime in the agent
			false
		end

		def meet
			Secrets.load

			FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)

			generate_key unless File.exist?(priv_key_name) && File.exist?(pub_key_name)
			add_key if success? && ENV["SSH_AUTH_SOCK"]
		end

		def unmeet
			true
		end

		def should_meet?
			true
		end

		private

		def generate_key
			execute("ssh-keygen -b #{key_size} -t #{key_algo} -f #{priv_key_name} -q -N '#{passphrase}'")
		end

		def add_key
			Net::SSH::Authentication::Agent.connect.add_identity(
				unencrypted_key,
				key_comment,
				lifetime: key_lifetime
			)
		end

		def unencrypted_key
			Net::SSH::KeyFactory.load_private_key(priv_key_name, passphrase)
		end

		def key_comment
			# the current directory is usually named for the project
			File.basename(::Dir.pwd)
		end

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
			DEFAULT_KEY_ALGO
		end

		def passphrase
			`echo #{configured_passphrase}`.chomp
		end

		def configured_passphrase
			Options.get("sshkey.passphrase")
		end

		def key_lifetime
			Options.get("sshkey.key_lifetime") || DEFAULT_KEY_LIFETIME_S
		end
	end
end
