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
	end

	it "succeeds" do
		expect(@exit_status1).to eq(0)
	end

	it "runs action_one in 'app/'" do
		expect(@output1).to match(/action one/)
	end

	it "succeeds" do
		expect(@exit_status2).to eq(0)
	end

	it "runs action_two in 'app/'" do
		expect(@output2).to match(/action two/)
	end

	it "sets the config from the app dir" do
		expect(@output3).to match(/app value one/)
	end

	it "sets the secret from the app dir" do
		expect(@output4).to match(/app secret one/)
	end
end
