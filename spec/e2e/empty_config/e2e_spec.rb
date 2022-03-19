# frozen_string_literal: true

RSpec.describe "environment_loading" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops version")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "outputs a warning" do
		expect(@output).to match(/Config file 'config\/test\/config.json' exists but is empty./)
	end
end
