# frozen_string_literal: true

require "builtins/version"

RSpec.describe Builtins::Version do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) { {} }

	describe '#run' do
		let(:result) { subject.run }
		let(:gemspec_double) { instance_double(Gem::Specification, version: "1.2.3") }

		before do
			allow(Gem::Specification).to receive(:load).and_return(gemspec_double)
		end

		it "prints the correct version" do
			expect(Output).to receive(:out).with("1.2.3")
			result
		end
	end
end
