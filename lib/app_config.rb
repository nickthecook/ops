# frozen_string_literal: true

class AppConfig
	class << self
		def load
			new(app_config_path).load
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
		@filename = filename.empty? ? default_filename : filename
	end

	def load
		config['environment']&.each do |key, value|
			ENV[key] = value.to_s
		end
	end

	private

	def default_filename
		"config/#{environment}/config.json"
	end

	def config
		@config ||= file_contents ? YAML.safe_load(file_contents) : {}
	rescue YAML::SyntaxError => e
		Output.error("Error parsing config data: #{e}")
		{}
	end

	def file_contents
		@file_contents ||= begin
			File.open(@filename).read
		rescue Errno::ENOENT
			nil
		end
	end

	def environment
		ENV['environment']
	end
end
