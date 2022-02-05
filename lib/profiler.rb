# frozen_string_literal: true

class Profiler
	INDENT = "  "

	@measurements = {}

	class << self
		attr_reader :measurements

		def measure(tag)
			start = time_now
			result = yield
			add_measurement(tag, time_now - start)

			result
		end

		def add_measurement(tag, seconds)
			return unless profiling?

			@measurements[tag] ||= []

			@measurements[tag] << seconds
		end

		def summary
			return unless profiling?

			@summary ||= measurements.reverse_each.each_with_object([]) do |(tag, values), output|
				output << "#{tag}:\n"
				values.sort.reverse.each do |value|
					value_str = format("%.3f", value * 1000)
					output << format("%<indent>s%9<value>sms\n", indent: INDENT, value: value_str)
				end
			end.join
		end

		def profiling?
			!ENV["OPS_PROFILE"].nil?
		end

		def time_now
			Process.clock_gettime(Process::CLOCK_MONOTONIC)
		end
	end
end
