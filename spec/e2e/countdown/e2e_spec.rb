# frozen_string_literal: true

RSpec.describe "countdown" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops countdown 1")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "takes 1 seconds" do
		expect(measure { run_ops("../../../bin/ops countdown 1") } >= 1).to be true
	end

	it "outputs a message when complete" do
		expect(@output).to match("Countdown complete after 1s.")
	end

	def measure
		start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
		yield
		Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time
	end
end
