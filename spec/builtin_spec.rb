# frozen_string_literal: true

require 'builtin'

RSpec.describe Builtin do
	subject { described_class.new([], {}) }

	describe '#run' do
		it "raises NotImplementedError" do
			expect { subject.run }.to raise_error(NotImplementedError)
		end
	end

	describe ".class_names" do
		let(:result) { described_class.class_names }

		it "returns a list of builtin class names" do
			expect(result).to include(:BackgroundLog, :Down, :Help, :Up)
		end
	end
end
