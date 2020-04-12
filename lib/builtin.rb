# frozen_string_literal: true

class Builtin
	def initialize(args, config)
		@args = args
		@config = config
	end

	def run
		raise NotImplementedError
	end
end
