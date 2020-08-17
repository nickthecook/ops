# frozen_string_literal: true

RSpec.describe "ssh key with passphrase var" do
	include_context "ops e2e"

	it "succeeds" do
		expect(exit_status).to eq(0)
	end
end
