# frozen_string_literal: true

RSpec.describe "hooks" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops hello")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "executes the first before hook" do
		expect(File).to exist("before_hook_1")
	end

	it "executes the second before hook" do
		expect(File).to exist("before_hook_2")
	end

	it "does not execute after hooks" do
		# after hooks are not implemented yet
		expect(File).not_to exist("after_hook_1")
		expect(File).not_to exist("after_hook_2")
	end
end
