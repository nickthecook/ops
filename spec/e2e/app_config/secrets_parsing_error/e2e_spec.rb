# frozen_string_literal: true

RSpec.describe "no actions" do
	include_context "ops e2e"

	before(:all) do
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../../bin/ops ls")
	end

	it "fails" do
		expect(@exit_status).to eq(66)
	end

	it "prints the name of the config file in the error message" do
		expect(@output).to match(/config\/test\/secrets.json/)
	end
end
