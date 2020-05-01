# frozen_string_literal: true

require_relative "../spec_helper.rb"

require_relative "../../lib/dependencies/cask"

RSpec.describe Dependencies::Cask do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#met?" do
		it "calls `brew` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with("brew cask list some-dependency")
			subject.met?
		end
	end

	describe "#meet" do
		it "calls brew to install the package" do
			expect(subject).to receive(:execute).with("brew cask install some-dependency")
			subject.meet
		end
	end
end
