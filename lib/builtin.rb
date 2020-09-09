# frozen_string_literal: true

class Builtin
	class ArgumentError < StandardError; end

	attr_reader :args, :config

	class << self
		def description
			"no description"
		end

		def class_for(name:)
			Builtins.const_get(builtin_class_name_for(name: name), false)
		end

		private

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
