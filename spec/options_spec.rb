# frozen_string_literal: true

require 'options'

RSpec.describe Options do
	describe "#set" do
		it "takes an argument" do
			expect { described_class.set({ a: 'b' }) }.not_to raise_error
		end
	end
end
