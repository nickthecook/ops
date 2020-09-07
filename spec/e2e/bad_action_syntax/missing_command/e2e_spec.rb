# frozen_string_literal: true

RSpec.describe "hooks" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../../bin/ops hello")
	end

	it "succeeds" do
		expect(@exit_status).to eq(68)
	end

	it "outputs an error" do
		expect(@output).to match(/No 'command' specified in 'action'./)
	end
end
