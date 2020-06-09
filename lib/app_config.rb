# frozen_string_literal: true

class AppConfig
	def initialize(filename = "")
		@filename = filename.empty? ? default_filename : filename
	end

	def load
		config['environment']&.each do |key, value|
			ENV[key] = value
		end
	end

	private

	def default_filename
		"config/#{environment}/config.json"
	end

	def config
		@config ||= file_contents ? JSON.parse(file_contents) : {}
	rescue JSON::ParserError => e
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
