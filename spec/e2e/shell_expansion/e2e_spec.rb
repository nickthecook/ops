# frozen_string_literal: true

RSpec.describe "forwards" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output1, @output_file1, @exit_status1 = run_ops("../../../bin/ops expansion")
		@output2, @output_file2, @exit_status2 = run_ops("../../../bin/ops no-expansion")
	end

	it "succeeds" do
		expect(@exit_status1).to eq(0)
		expect(@exit_status2).to eq(0)
	end

	it "performs shell expansion by default" do
		expect(@output1).to match(/\nhello\n/)
	end

	it "does not perform shell expansion when disabled in config" do
		expect(@output2).to match(/\n"hello"\n/)
	end
end
