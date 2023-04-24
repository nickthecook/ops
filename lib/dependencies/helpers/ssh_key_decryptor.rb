# frozen_string_literal: true

require "tempfile"

module Dependencies
	module Helpers
		class SshKeyDecryptor
			def initialize(source_key_path, passphrase)
				@source_key_path = source_key_path
				@passphrase = passphrase
			end

			def plaintext_key
				@plaintext_key ||= begin
					plaintext = decrypt_key

					File.delete(temp_key_file.path)

					plaintext
				end
			end

			private

			def temp_key_file
				@temp_key_file ||= Tempfile.new("ops")
			end

			def decrypt_key
				FileUtils.cp(@source_key_path, temp_key_file.path)
				`ssh-keygen -f '#{temp_key_file.path}' -p -P '#{@passphrase}' </dev/null`

				File.read(temp_key_file.path)
			end
		end
	end
end
