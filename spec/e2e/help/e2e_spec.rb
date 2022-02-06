# frozen_string_literal: true

RSpec.describe "help" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops help")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "includes help for builtins other than 'help'" do
		# binding.pry
		expect(@output).to match(/49mup\e/)
		expect(@output).to match(/49mdown\e/)
		expect(@output).to match(/49minit\e/)
		expect(@output).to match(/49mexec\e/)
	end
end
