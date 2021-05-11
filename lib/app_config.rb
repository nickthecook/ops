# frozen_string_literal: true

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

		private

		def app_config_path
			expand_path(Options.get("config.path"))
		end

		def expand_path(path)
			`echo #{path}`.chomp
		end
	end

	def initialize(filename = "")
		@filename = filename.empty? ? AppConfig.default_filename : filename
	end

	def load
		config['environment']&.each do |key, value|
			ENV[key] = value.is_a?(Hash) || value.is_a?(Array) ? value.to_json : value.to_s
		end
	end

	private

	def config
		@config ||= file_contents ? YAML.safe_load(file_contents) : {}
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
