# frozen_string_literal: true

require_relative '../ssh_spec_helper'

RSpec.describe "ssh key without passphrase" do
	include_context "ops e2e"

	before(:all) do
		Dir.chdir(__dir__)

		remove_untracked_files

		@output, @output_file, @exit_status = run_ops("../../../../bin/ops up")
	end

	it "succeeds" do
		expect(@exit_status).to eq(0)
	end

	it "generates a key without a passphrase" do
		expect(has_passphrase?("user@host")).to be false
	end

	include_examples "creates an SSH key", "user@host"
end
