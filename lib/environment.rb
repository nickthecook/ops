# frozen_string_literal: true

require 'version'
require 'secrets'
require 'app_config'

class Environment
	class << self
		def environment
			return 'dev' if ENV['environment'].nil? || ENV['environment'].empty?

			ENV['environment']
		end
	end

	def initialize(env_hash, config_path)
		@env_hash = env_hash
		@config_path = config_path
	end

	def set_variables
		set_ops_variables
		set_environment_aliases
		set_configured_variables
	end

	private

	def set_ops_variables
		ENV["OPS_YML_DIR"] = File.dirname(@config_path)
		ENV["OPS_VERSION"] = Version.version.to_s
		ENV["OPS_SECRETS_FILE"] = Secrets.config_path_for(Environment.environment)
		ENV["OPS_CONFIG_FILE"] = AppConfig.config_path_for(Environment.environment)
	end

	def set_environment_aliases
		environment_aliases.each do |alias_name|
			ENV[alias_name] = Environment.environment
		end
	end

	def environment_aliases
		Options.get("environment_aliases") || ['environment']
	end

	def set_configured_variables
		@env_hash.each do |key, value|
			ENV[key] = `echo #{value}`.chomp
		end
	end
end
