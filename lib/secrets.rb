# frozen_string_literal: true

require 'json'

require 'output'
require 'app_config'

class Secrets < AppConfig
	class << self
		def from_options(options)
			path = options&.dig("secrets", "path")

			Secrets.new(expanded_path(path))
		end

		private

		def expanded_path(path)
			`echo #{path}`.chomp
		end
	end

	private

	def default_filename
		return default_ejson_filename if File.exist?(default_ejson_filename)

		default_json_filename
	end

	def default_ejson_filename
		"config/#{environment}/secrets.ejson"
	end

	def default_json_filename
		"config/#{environment}/secrets.json"
	end

	def file_contents
		@file_contents ||= @filename.match(/\.ejson$/) ? `ejson decrypt #{@filename}` : super
	end
end
