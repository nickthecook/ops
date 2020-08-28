# frozen_string_literal: true

require 'json'
require 'open3'

require 'output'
require 'app_config'
require 'options'

class Secrets < AppConfig
	class << self
		private

		def app_config_path
			expand_path(Options.get("secrets.path"))
		end
	end

	def initialize(filename = "")
		@filename = filename.empty? ? default_filename : actual_filename_for(filename)
	end

	private

	def default_filename
		File.exist?(default_ejson_filename) ? default_ejson_filename : default_json_filename
	end

	def default_ejson_filename
		"config/#{environment}/secrets.ejson"
	end

	def default_json_filename
		"config/#{environment}/secrets.json"
	end

	def actual_filename_for(filename)
		File.exist?(filename) ? filename : filename.sub(".ejson", ".json")
	end

	def file_contents
		@file_contents ||= begin
			@filename.match(/\.ejson$/) ? ejson_contents : super
		end
	end

	def ejson_contents
		@ejson_contents ||= begin
			out, err, _status = Open3.capture3("ejson decrypt #{@filename}")

			# TODO: err is only nil in testing, but I can't figure out why the stubbing isn't working
			raise ParsingError, "Error decrypting EJSON file: #{err}" unless err.nil? || err.empty?

			out
		end
	end
end
