# frozen_string_literal: true

require_relative "spec_helper.rb"

require_relative "../lib/dependency"

RSpec.describe Dependency do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#installed?" do
		it "raises an error" do
			expect { subject.installed? }.to raise_error(NotImplementedError)
		end
	end

	describe "#install" do
		it "raises an error" do
			expect { subject.install }.to raise_error(NotImplementedError)
		end
	end
end
