# frozen_string_literal: true

module Builtins
	class Envdiff < Builtin
		class << self
			def description
				"compares keys present in config and secrets between different environments"
			end
		end

		def run
			check_args

			if source_only_keys.empty? && dest_only_keys.empty?
				Output.out("Environments '#{source_env}' and '#{dest_env}' define the same #{source_keys.length} key(s).")
				return
			end

			output_key_summary(source_only_keys, source_env, dest_env) if source_only_keys.any?
			output_key_summary(dest_only_keys, dest_env, source_env) if dest_only_keys.any?

			true
		end

		private

		def output_key_summary(keys, in_env, not_in_env)
			Output.warn("Environment '#{in_env}' defines keys that '#{not_in_env}' does not:\n")
			keys.each do |key|
				Output.warn("   - #{key}")
			end
			Output.out("")
		end

		def source_only_keys
			@source_only_keys ||= source_keys - dest_keys
		end

		def dest_only_keys
			@dest_only_keys ||= dest_keys - source_keys
		end

		def source_keys
			@source_keys ||= keys_for(source_env)
		end

		def dest_keys
			@dest_keys ||= keys_for(dest_env)
		end

		def keys_for(env)
			tagged_config_keys_for(env) + tagged_secrets_keys_for(env)
		end

		def tagged_config_keys_for(env)
			config_keys_for(env).map do |key|
				"[CONFIG] #{key}"
			end
		end

		def tagged_secrets_keys_for(env)
			secrets_keys_for(env).map do |key|
				"[SECRET] #{key}"
			end
		end

		def config_keys_for(env)
			(config_for(env)["environment"]&.keys || []) - ignored_keys
		end

		def secrets_keys_for(env)
			(secrets_for(env)["environment"]&.keys || []) - ignored_keys
		end

		def config_for(env)
			YAML.load_file(config_path_for(env))
		end

		def secrets_for(env)
			YAML.load_file(secrets_path_for(env))
		end

		def check_args
			raise Builtin::ArgumentError, "Usage: ops envdiff <env_one> <env_two>" unless args.length == 2

			check_environment(source_env)
			check_environment(dest_env)
		end

		def source_env
			args[0]
		end

		def dest_env
			args[1]
		end

		def check_environment(name)
			raise_missing_file_error(config_path_for(name)) unless config_file_exists?(name)
			raise_missing_file_error(secrets_path_for(name)) unless secrets_file_exists?(name)
		end

		def raise_missing_file_error(path)
			raise Builtin::ArgumentError, "File '#{path}' does not exist."
		end

		def config_file_exists?(env)
			File.exist?(config_path_for(env))
		end

		def secrets_file_exists?(env)
			File.exist?(secrets_path_for(env))
		end

		def config_path_for(env)
			AppConfig.config_path_for(env)
		end

		def secrets_path_for(env)
			Secrets.config_path_for(env)
		end

		def ignored_keys
			Options.get("envdiff.ignored_keys") || []
		end
	end
end
