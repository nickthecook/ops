# frozen_string_literal: true

class Executor
	attr_reader :output, :exit_code

	def initialize(command)
		@command = command
	end

	def execute
		@output, status = Open3.capture2e(@command)
		@exit_code = status.exitstatus

		success?
	end

	def success?
		@exit_code.nil? ? true : @exit_code.zero?
	end
end
