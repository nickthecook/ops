# frozen_string_literal: true

RSpec.describe "ops.yaml precedence" do
	include_context "ops e2e"

	before(:all) do
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops test")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "outputs the string from ops.yaml" do
		expect(@output).to match(/this is ops.yaml/)
	end
end
