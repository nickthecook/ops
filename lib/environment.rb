# frozen_string_literal: true

class Environment
	def initialize(env_hash)
		@env_hash = env_hash
	end

	def set_variables
		@env_hash.each do |key, value|
			ENV[key] = value
		end

		ENV['environment'] = environment
	end

	def environment
		return 'dev' if ENV['environment'].nil? || ENV['environment'].empty?

		ENV['environment']
	end
end
