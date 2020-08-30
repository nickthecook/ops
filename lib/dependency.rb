# frozen_string_literal: true

require 'open3'
require 'English'

require 'output'
require 'executor'

class Dependency
	DESCRIPTION_TYPE_WIDTH = 8

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

	def unmeet
		raise NotImplementedError
	end

	# should_meet? can be used to implement dependencies that should only be met on some platforms,
	# e.g. brew on Macs and apt on Linux
	# it can be used to base a decision on anything else that can be read from the environment at
	# runtime
	def should_meet?
		true
	end

	# if true, this type of resource must always have `meet` and `unmeet` called;
	# useful for resources that can't easily be checked to see if they're met
	def always_act?
		false
	end

	def type
		self.class.name.split('::').last
	end

	def success?
		@executor.nil? ? true : @executor.success?
	end

	def output
		@executor&.output
	end

	def exit_code
		@executor&.exit_code
	end

	private

	def execute(cmd)
		@executor = Executor.new(cmd)
		@executor.execute

		@executor.success?
	end
end
