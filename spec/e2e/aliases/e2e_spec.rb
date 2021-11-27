# frozen_string_literal: true

RSpec.describe "no actions" do
	include_context "ops e2e"

	before(:all) do
		Dir.chdir(__dir__)

		remove_untracked_files
	end

	let(:commands) do
		[
			"../../../bin/ops t",
			"../../../bin/ops tw",
			"../../../bin/ops rw",
			"../../../bin/ops te",
			"../../../bin/ops e2e"
		]
	end
	let(:results) { commands.map { |cmd| run_ops(cmd) } }
	let(:exit_codes) { results.map { |result| result[EXIT_CODE_IDX] } }

	it "succeeds" do
		expect(exit_codes).to all(eq(0))
	end

	context "when alias does not exist" do
		let(:commands) { ["../../../bin/ops zz"] }

		it "fails" do
			expect(exit_codes).to eq([65])
		end

		it "prints an eror" do
			expect(results.first[OUTPUT_IDX]).to match(/Unknown action: zz/)
		end
	end
end
