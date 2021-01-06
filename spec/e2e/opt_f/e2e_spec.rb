# frozen_string_literal: true

RSpec.describe "forwards" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops -f app/ops.yml say-name")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "runs action from 'app/ops.yml'" do
		expect(@output).to match(/Hello, my name is Leeeeeroy/)
	end
end
