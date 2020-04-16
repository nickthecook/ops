# frozen_string_literal: true

require_relative "spec_helper.rb"

require_relative "../lib/dependency"

RSpec.describe Dependency do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#met?" do
		it "raises an error" do
			expect { subject.met? }.to raise_error(NotImplementedError)
		end
	end

	describe "#meet" do
		it "raises an error" do
			expect { subject.meet }.to raise_error(NotImplementedError)
		end
	end
end
