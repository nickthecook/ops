# frozen_string_literal: true

RSpec.describe "environment_loading" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../bin/ops print_env")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "sets environment variables based on variables loaded from config" do
		expect(@output).to match(/ENV_CONFIG_VAR=from config/)
	end

	it "sets environment variables based on variables loaded from secrets" do
		expect(@output).to match(/ENV_SECRETS_VAR=from secrets/)
	end
end
