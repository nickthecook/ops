# frozen_string_literal: true

require 'builtin'

RSpec.describe Builtin do
	subject { described_class.new([], {}) }

	describe '#run' do
		it "raises NotImplementedError" do
			expect { subject.run }.to raise_error(NotImplementedError)
		end
	end
end
