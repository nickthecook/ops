# frozen_string_literal: true

require "open3"

class Dependency
	DESCRIPTION_TYPE_WIDTH = 8

	attr_reader :name, :stdout, :stderr, :exit_code

	def initialize(name)
		@name = name
	end

	def met?
		raise NotImplementedError
	end

	def meet
		raise NotImplementedError
	end

	def unmeet
		raise NotImplementedError
	end

	def should_meet?
		true
	end

	def type
		self.class.name.split('::').last
	end

	def success?
		@exit_code.nil? ? true : @exit_code.zero?
	end

	private

	def execute(cmd)
		@stdout, @stderr, status = Open3.capture3(cmd)
		@exit_code = status.exitstatus
		success?
	end
end
