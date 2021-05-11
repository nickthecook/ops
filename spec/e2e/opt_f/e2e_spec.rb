# frozen_string_literal: true

RSpec.describe "forwards" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output1, @output_file1, @exit_status1 = run_ops("../../../bin/ops -f app/ops.yml say-name")
		@output2, @output_file2, @exit_status2 = run_ops("../../../bin/ops -f app/ops.yml ls -l")
		@output3, @output_file3, @exit_status3 = run_ops("../../../bin/ops -f")
		@output4, @output_file4, @exit_status4 = run_ops("../../../bin/ops --file app/ops.yml say-name")
	end

	context "when running action without params" do
		it "succeeds" do
			expect(@exit_status1).to eq(0)
			expect(@exit_status4).to eq(0)
		end

		it "runs action with no args from 'app/ops.yml'" do
			expect(@output1).to match(/Hello, my name is Leeeeeroy/)
			expect(@output4).to match(/Hello, my name is Leeeeeroy/)
		end
	end

	context "when running action with option passed to it" do
		it "succeeds" do
			expect(@exit_status2).to eq(0)
		end

		it "gets the expected output" do
			expect(@output2).to match(/drwxr.xr-x/)
		end
	end

	context "when given -f without another param" do
		it "exits with an error code" do
			expect(@exit_status3).to eq(1)
		end

		it "prints usage" do
			expect(@output3).to match(/Usage: ops/)
		end
	end
end
