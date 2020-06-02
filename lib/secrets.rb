# frozen_string_literal: true

require 'json'

require 'output'

class Secrets
	def initialize(filename = "")
		@filename = filename.empty? ? default_filename : filename
	end

	def load
		secrets['environment']&.each do |key, value|
			ENV[key] = value
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

	def secrets
		@secrets ||= JSON.parse(file_contents)
	rescue JSON::ParserError => e
		Output.error("Error parsing secrets data: #{e}")
		{}
	end

	def file_contents
		@filename.match(/\.ejson$/) ? `ejson decrypt #{@filename}` : File.open(@filename).read
	end

	def environment
		ENV['environment']
	end
end
