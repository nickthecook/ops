# frozen_string_literal: true

require 'open3'

shared_context "ops e2e" do
	output = nil
	exit_status = nil
	output_file = nil

	let(:output) { output }
	let(:exit_status) { exit_status }
	let(:output_file) { output_file }

	def run_ops(cmd, output_file = "#{__dir__}/ops.out")
		output, output_file, exit_status = Dir.chdir(__dir__) do
			output, status = Open3.capture2e(cmd)

			File.open(output_file, "w") { |file| file.write(output) }
			puts(output)

			[output, output_file, status.exitstatus]
		end
	end
end
