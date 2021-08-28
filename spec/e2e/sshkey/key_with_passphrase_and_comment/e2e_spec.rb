require_relative '../ssh_spec_helper'

# frozen_string_literal: true

RSpec.describe "ssh key with passphrase var" do
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

	it "generates a key with a passphrase" do
		expect(system("grep -q bink@some_host user@host.pub")).to be true
	end

	include_examples "creates an SSH key", "user@host"
end
