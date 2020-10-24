# frozen_string_literal: true

require 'output'

class Forward
	def initialize(dir, args)
		@dir = dir
		@args = args
	end

	def run
		Output.notice("Forwarding 'ops #{@args.join(" ")}' to '#{@dir}/'...")

		Dir.chdir(@dir)
		Ops.new(@args).run
	end
end
