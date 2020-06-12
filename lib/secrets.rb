# frozen_string_literal: true

require 'json'

require 'output'
require 'app_config'
require 'options'

class Secrets < AppConfig
	class << self
		def load
			Secrets.new(expand_path(Options.get("secrets.path"))).load
		end

		private

		def expand_path(path)
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
