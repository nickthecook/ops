# frozen_string_literal: true

class Builtin
	attr_reader :args, :config

	class << self
		def description
			"no description"
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
