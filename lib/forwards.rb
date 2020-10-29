# frozen_string_literal: true

require 'forward'

class Forwards
	def initialize(config, args)
		@config = config
		@args = args
	end

	def get(name)
		Forward.new(forwards[name], @args) if forwards[name]
	end

	private

	def forwards
		@forwards ||= @config["forwards"] || {}
	end
end
