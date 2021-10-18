# frozen_string_literal: true

RSpec.describe "up fail_on_error false" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../../bin/ops up")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end
end
