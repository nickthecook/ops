# frozen_string_literal: true

RSpec.describe Options do
	let(:options) do
		{
			"environment" => {
				"var" => "val"
			},
			"snap" => {
				"use_sudo" => false,
				"install" => true
			}
		}
	end

	describe "#set" do
		it "takes an argument" do
			expect { described_class.set(options) }.not_to raise_error
		end
	end

	describe "#get" do
		let(:result) { described_class.get("snap.use_sudo") }

		before do
			described_class.set(options)
		end

		it "returns the set options" do
			expect(result).to eq(false)
		end

		context "when env var options are set" do
			let(:use_sudo) { "true" }

			before do
				allow(ENV).to receive(:[]).with("OPS__SNAP__USE_SUDO").and_return(use_sudo)
			end

			it "checks for the env var equivalent of the option" do
				expect(ENV).to receive(:[]).with("OPS__SNAP__USE_SUDO")
				result
			end

			it "returns the env var option first" do
				expect(result).to eq(true)
			end

			context "when variable is set to a string that's not special in YAML" do
				let(:use_sudo) { "some string" }

				it "returns the string" do
					expect(result).to eq("some string")
				end
			end
		end
	end
end
