# frozen_string_literal: true

class Environment
	def initialize(env_hash)
		@env_hash = env_hash
	end

	def set_variables
		set_ops_variables
		set_environment_aliases
		set_configured_variables
	end

	def environment
		return 'dev' if ENV['environment'].nil? || ENV['environment'].empty?

		ENV['environment']
	end

	private

	def set_ops_variables
		ENV["OPS_YML_DIR"] = Dir.pwd
	end

	def set_environment_aliases
		environment_aliases.each do |alias_name|
			ENV[alias_name] = environment
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
