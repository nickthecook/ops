# frozen_string_literal: true

class Options
	class << self
		def get(path)
			env_var = ENV[env_var(path)]
			return YAML.safe_load(env_var) unless env_var.nil?

			@options&.dig(*path.split('.'))
		end

		def set(options)
			@options = options
		end

		private

		def env_var(path)
			"OPS__#{path.upcase.gsub(".", "__")}"
		end
	end
end
