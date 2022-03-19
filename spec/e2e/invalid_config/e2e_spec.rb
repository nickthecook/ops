# frozen_string_literal: true

RSpec.describe "environment_loading" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops version")
	end

	it "fails with code 66" do
		expect(@exit_status).to eq(66)
	end

	it "outputs an error" do
		expect(@output).to match(/Error parsing app config:/)
	end
end
