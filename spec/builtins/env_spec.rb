# frozen_string_literal: true

require 'builtins/env'

RSpec.describe Builtins::Env do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) { {} }

	describe '#run' do
		let(:result) { subject.run }

		it "prints 'dev'" do
			expect(Output).to receive(:print).with("test")
			result
		end

		context "when 'environment' variable is set" do
			before do
				allow(ENV).to receive(:[]).with('environment').and_return('production')
			end

			it "returns the value from the 'environment' variable" do
				expect(Output).to receive(:print).with('production')
				result
			end
		end
	end
end
