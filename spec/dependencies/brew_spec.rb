# frozen_string_literal: true

require_relative "../spec_helper.rb"

require_relative "../../lib/dependencies/brew"

RSpec.describe Dependencies::Brew do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#met?" do
		it "calls `brew` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with("brew list some-dependency")
			subject.met?
		end
	end

	describe "#meet" do
		it "calls brew to install the package" do
			expect(subject).to receive(:execute).with("brew install some-dependency")
			subject.meet
		end
	end

	describe "#unmeet" do
		it "returns true" do
			expect(subject.unmeet).to be true
		end
	end

	describe "#should_meet?" do
		let(:result) { subject.should_meet? }

		before do
			allow(subject).to receive(:`).with("uname").and_return(uname)
		end

		context "Darwin kernel is running" do
			let(:uname) { "Darwin\n" }

			it "returns true" do
				expect(result).to be true
			end
		end

		context "Linux kernel is running" do
			let(:uname) { "Linux\n" }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
