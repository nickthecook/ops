# frozen_string_literal: true

class Builtin
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
