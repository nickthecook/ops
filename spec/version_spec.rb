# frozen_string_literal: true

require 'version'

RSpec.describe Version do
	let(:gemspec_double) { instance_double(Gem::Specification, version: "1.2.3") }

	before do
		allow(Gem::Specification).to receive(:load).and_return(gemspec_double)
	end

	describe "#version" do
		let(:result) { subject.version }

		it "returns the version from the gemspec" do
			expect(result).to eq("1.2.3")
		end

		context "when gemspec does not exist" do
			before do
				allow(Gem::Specification).to receive(:load).and_return(nil)
			end

			it "prints an error" do
				expect(Output).to receive(:error)
				result
			end

			it "returns nil" do
				expect(result).to be nil
			end
		end
	end
end
