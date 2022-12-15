# frozen_string_literal: true

require 'json'

class AppConfig
	class ParsingError < StandardError; end

	class << self
		def load
			new(app_config_path).load
		end

		def default_filename
			config_path_for(Environment.environment)
		end

		def config_path_for(env)
			"config/#{env}/config.json"
		end

		def app_config_path
			expand_path(Options.get("config.path") || default_filename)
		end

		private

		def expand_path(path)
			`echo #{path}`.chomp
		end
	end

	def load
		config['environment']&.each do |key, value|
			if Options.get("config.preserve_existing_env_vars") && ENV[key]
				Output.debug("Environment variable '$#{key}' already set; skipping...")
				next
			end

			ENV[key] = value.is_a?(Hash) || value.is_a?(Array) ? value.to_json : value.to_s
		end
	end

	private

	def initialize(filename = "")
		@filename = filename
	end

	def config
		@config ||= if file_contents == ""
			Output.warn("Config file '#{@filename}' exists but is empty.")
			{}
		elsif file_contents
			YAML.safe_load(file_contents)
		else
			{}
		end
	rescue YAML::SyntaxError => e
		raise ParsingError, "#{@filename}: #{e}"
	end

	def file_contents
		@file_contents ||= begin
			File.open(@filename).read
		rescue Errno::ENOENT
			nil
		end
	end
end
