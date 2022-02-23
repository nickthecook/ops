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
			unless File.exist?(file)
				require 'require_all'
				require_rel "builtins"
			end

			get_const(name: builtin_class_name_for(name: name))
		end

		private

		def get_const(name:)
			Builtins.const_get(name, false)
		rescue NameError
			# no such constant
			nil
		end

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
