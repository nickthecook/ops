# frozen_string_literal: true

class Dependency
	attr_reader :name

	def initialize(name)
		@name = name
	end

	def installed?
		raise NotImplementedError
	end

	def install
		raise NotImplementedError
	end
end
