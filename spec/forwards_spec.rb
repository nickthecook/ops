# frozen_string_literal: true

require 'forwards'

RSpec.describe Forwards do
	subject { described_class.new(config, args) }

	let(:config) do
		{
			"forwards" => {
				"app" => "app",
				"inf" => "infrastructure"
			}
		}
	end

	let(:args) { %w[arg_one arg_two] }

	describe "#get" do
		let(:result) { subject.get(name) }
		let(:name) { "inf" }

		it "returns an instance of Forward" do
			expect(result).to be_a(Forward)
		end

		it "create Forward with the correct args" do
			expect(Forward).to receive(:new).with("infrastructure", %w[arg_one arg_two])
			result
		end

		context "when the forward is not defined" do
			let(:name) { "nosuch" }

			it "returns nil" do
				expect(result).to be_nil
			end
		end

		context "when no forwards are configured" do
			let(:config) { {} }

			it "returns nil" do
				expect(result).to be_nil
			end
		end
	end
end
