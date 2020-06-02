# frozen_string_literal: true

require 'environment'

RSpec.describe Environment do
	subject { described_class.new({ "var1" => "val1", "var2" => "val2" }) }

	describe "#set_variables" do
		let(:result) { subject.set_variables }

		before do
			allow(ENV).to receive(:[]=)
		end

		it "sets the given variables" do
			expect(ENV).to receive(:[]=).with("var1", "val1")
			expect(ENV).to receive(:[]=).with("var2", "val2")
			result
		end

		it "sets the 'environment' variable" do
			expect(ENV).to receive(:[]=).with("environment", "test")
			result
		end
	end

	describe "#environment" do
		let(:result) { subject.environment }

		it "returns the current value of the 'environment' variable" do
			expect(result).to eq("test")
		end

		context "when the variable is not set" do
			before do
				allow(ENV).to receive(:[]).with("environment").and_return(nil)
			end

			it "returns 'dev'" do
				expect(result).to eq("dev")
			end
		end
	end
end
