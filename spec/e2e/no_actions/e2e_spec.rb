# frozen_string_literal: true

RSpec.describe "no actions" do
	include_context "ops e2e"

	before(:all) do
		output, output_file, exit_status = run_ops("ops up")
	end

	it "succeeds" do
		expect(exit_status).to eq(0)
	end
end
