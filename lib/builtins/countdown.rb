# frozen_string_literal: true

require 'concurrent'

require 'builtin'
require 'output'

module Builtins
	class Countdown < Builtin
		USAGE_STRING = "Usage: ops countdown <seconds>"

		class << self
			def description
				"Like `sleep`, but displays time remaining in terminal."
			end
		end

		def run
			check_args

			timer_task.execute

			while timer_task.running?
				sleep(1)
				timer_task.shutdown if task_complete?
			end
			Output.out("\rCountdown complete after #{sleep_seconds}s.")
		end

		private

		def check_args
			check_arg_count
			check_arg_is_positive_int
		end

		def check_arg_count
			raise Builtin::ArgumentError, USAGE_STRING unless args.length == 1
		end

		def check_arg_is_positive_int
			raise Builtin::ArgumentError, USAGE_STRING unless sleep_seconds.positive?
		# raised when the arg is not an int
		rescue ::ArgumentError
			raise Builtin::ArgumentError, USAGE_STRING
		end

		def timer_task
			@timer_task ||= Concurrent::TimerTask.new(run_now: true, execution_interval: 1) do
				Output.print("\r      \r#{seconds_left}")
			end
		end

		def sleep_seconds
			Integer(args.first)
		end

		def task_start_time
			@task_start_time ||= Time.now
		end

		def task_end_time
			@task_end_time ||= task_start_time + sleep_seconds
		end

		def task_complete?
			Time.now > task_end_time
		end

		def seconds_left
			Integer(task_end_time - Time.now + 1)
		end
	end
end
