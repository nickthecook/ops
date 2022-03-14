# frozen_string_literal: true

require 'fileutils'
require 'net/ssh'

module Dependencies
	class Sshkey < Dependency
		DEFAULT_KEY_SIZE = 4096
		DEFAULT_KEY_ALGO = "rsa"
		DEFAULT_KEY_LIFETIME_S = 3600
		DEFAULT_KEY_FILE_COMMENT_COMMAND = "$USER@`hostname -s`"

		def met?
			# we always need to at least update the key lifetime in the agent
			false
		end

		def meet
			Secrets.load

			Output.warn("\nNo passphrase set for SSH key '#{priv_key_name}'") if passphrase.nil? || passphrase.empty?

			FileUtils.mkdir_p(dir_name) unless File.directory?(dir_name)
			generate_key unless File.exist?(priv_key_name) && File.exist?(pub_key_name)
			add_key if success? && should_add_key?
		end

		def unmeet
			true
		end

		def should_meet?
			true
		end

		private

		def generate_key
			execute(
				"ssh-keygen -b #{opt_key_size} -t #{opt_key_algo} -f #{priv_key_name} -q -N '#{passphrase}' -C '#{key_file_comment}'"
			)
		end

		def add_key
			Net::SSH::Authentication::Agent.connect.add_identity(
				unencrypted_key,
				key_comment,
				lifetime: opt_key_lifetime
			)
		end

		def should_add_key?
			ENV["SSH_AUTH_SOCK"] && opt_add_keys?
		end

		def unencrypted_key
			Net::SSH::KeyFactory.load_private_key(priv_key_name, passphrase.empty? ? nil : passphrase)
		end

		def key_comment
			Ops.project_name
		end

		def key_file_comment
			`echo #{opt_key_file_comment_command}`.chomp
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

		def opt_key_size
			Options.get("sshkey.key_size") || DEFAULT_KEY_SIZE
		end

		def opt_key_algo
			Options.get("sshkey.key_algo") || DEFAULT_KEY_ALGO
		end

		def passphrase
			`echo #{opt_passphrase}`.chomp
		end

		def opt_passphrase
			@opt_passphrase ||= begin
				return "$#{Options.get('sshkey.passphrase_var')}" if Options.get("sshkey.passphrase_var")

				output_passphrase_warning if Options.get("sshkey.passphrase")

				Options.get("sshkey.passphrase")
			end
		end

		def output_passphrase_warning
			Output.warn(
				"\n'options.sshkey.passphrase' is deprecated and will be removed in a future release. " \
				"Use 'options.sshkey.passphrase_var' instead."
			)
		end

		def opt_add_keys?
			Options.get("sshkey.add_keys").nil? ? true : Options.get("sshkey.add_keys")
		end

		def opt_key_lifetime
			Options.get("sshkey.key_lifetime") || DEFAULT_KEY_LIFETIME_S
		end

		def opt_key_file_comment_command
			Options.get("sshkey.key_file_comment") || DEFAULT_KEY_FILE_COMMENT_COMMAND
		end
	end
end
