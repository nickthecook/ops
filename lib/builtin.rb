# frozen_string_literal: true

class Builtin
	class ArgumentError < StandardError; end

	attr_reader :args, :config

	class << self
		BUILTIN_DIR = "builtins"

		def description
			"no description"
		end

		def class_for(name:)
			file = file_for(name: name)
			return nil unless File.exist?(file)

			require file
			Builtins.const_get(builtin_class_name_for(name: name), false)
		end

		private

		def file_for(name:)
			File.join(File.dirname(__FILE__), BUILTIN_DIR, "#{name}.rb")
		end

		def builtin_class_name_for(name:)
			name.capitalize.to_sym
		end
	end

	def initialize(args, config)
		@args = args
		@config = config
	end

	def run
		raise NotImplementedError
	end
end
