# frozen_string_literal: true

RSpec.describe "forwards" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output1, @output_file1, @exit_status1 = run_ops("../../../bin/ops app action_one")
		@output2, @output_file2, @exit_status2 = run_ops("../../../bin/ops app action_two")
		@output3, @output_file3, @exit_status3 = run_ops("../../../bin/ops app config_val")
		@output4, @output_file4, @exit_status4 = run_ops("../../../bin/ops app secret_val")
		@output5, @output_file5, @exit_status5 = run_ops("../../../bin/ops app echo_var")
		@output6, @output_file6, @exit_status6 = run_ops("../../../bin/ops app echo_top_var")
	end

	it "succeeds" do
		expect(@exit_status1).to eq(0)
	end

	it "runs action_one in 'app/'" do
		expect(@output1).to match(/action one/)
	end

	it "runs action_two in 'app/'" do
		expect(@output2).to match(/action two/)
	end

	it "sets the config from the app dir" do
		expect(@output3).to match(/app value one/)
	end

	it "does not set the config from the top-level dir" do
		expect(@output3).not_to match(/top value one/)
	end

	it "sets the secret from the app dir" do
		expect(@output4).to match(/app secret one/)
	end

	it "does not set the secret from the top-level dir" do
		expect(@output4).not_to match(/top secret one/)
	end

	it "sets env vars from app options" do
		expect(@output5).to match(/app-level value/)
	end

	it "does not set env vars from top-level options" do
		expect(@output6).not_to match(/top-level option/)
	end
end
