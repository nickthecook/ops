require_relative '../ssh_spec_helper'

# frozen_string_literal: true

RSpec.describe "ssh key with configured algorithm" do
	include_context "ops e2e"

	before(:all) do
		# change to the directory containing this file
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../../bin/ops up")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "generates a key with the configured algorithm" do
		expect(`ssh-keygen -l -f user@host`).to match(/(ED25519)/)
	end

	include_examples "creates an SSH key", "user@host"
end
