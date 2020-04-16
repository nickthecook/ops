# frozen_string_literal: true

class Dependency
	attr_reader :name

	def initialize(name)
		@name = name
	end

	def met?
		raise NotImplementedError
	end

	def meet
		raise NotImplementedError
	end

	def type
		self.class.name.split('::').last
	end
end
