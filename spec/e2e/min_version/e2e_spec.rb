# frozen_string_literal: true

RSpec.describe "min_version checking" do
	include_context "ops e2e"

	before(:all) do
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops up")
	end

	it "fails with config error exit code" do
		expect(@exit_status).to eq(67)
	end

	it "outputs an error about minimum version" do
		# TODO: update test when we hit version 99.99.99
		expect(@output).to match(/ops.yml specifies minimum version of 99.99.99, but ops version is /)
	end
end
