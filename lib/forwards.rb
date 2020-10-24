# frozen_string_literal: true

class Forwards
	def initialize(config)
		@config = config
	end

	def get(name)
		forwards[name]
	end

	private

	def forwards
		@forwards ||= config["forwards"]
	end
end
