# frozen_string_literal: true

require 'json'
require 'open3'

require 'output'
require 'app_config'
require 'options'

class Secrets < AppConfig
	class << self
		def default_filename
			config_path_for(Environment.environment)
		end

		def config_path_for(env)
			File.exist?(ejson_path_for(env)) ? ejson_path_for(env) : json_path_for(env)
		end

		private

		def ejson_path_for(env)
			"config/#{env}/secrets.ejson"
		end

		def json_path_for(env)
			"config/#{env}/secrets.json"
		end

		def app_config_path
			expand_path(Options.get("secrets.path"))
		end
	end

	def initialize(filename = "")
		@filename = filename.empty? ? Secrets.default_filename : actual_filename_for(filename)
	end

	private

	def actual_filename_for(filename)
		File.exist?(filename) ? filename : filename.sub(".ejson", ".json")
	end

	def file_contents
		@file_contents ||= @filename.match(/\.ejson$/) ? ejson_contents : super
	end

	def ejson_contents
		@ejson_contents ||= begin
			out, err, _status = Open3.capture3("ejson decrypt #{@filename}")

			# TODO: err is only nil in testing, but I can't figure out why the stubbing isn't working
			raise ParsingError, "#{@filename}: #{err}" unless err.nil? || err.empty?

			out
		end
	end
end
