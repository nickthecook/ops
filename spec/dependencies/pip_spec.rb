# frozen_string_literal: true

require 'ostruct'

RSpec.describe Dependencies::Pip do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	shared_context "pip command overridden" do |command|
		before do
			allow(Options).to receive(:get).with("pip.command").and_return(command)
		end
	end

	describe '#met?' do
		let(:result) { subject.met? }

		it "calls `pip` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with(/^python3 -m pip show #{name}/)
			result
		end

		context "when pip command is overridden" do
			include_context "pip command overridden", "pip3"

			it "uses the user-configured command for pip" do
				expect(subject).to receive(:execute).with(/^pip3 show #{name}/)
				result
			end
		end
	end

	describe '#meet' do
		let(:result) { subject.meet }

		it "calls apk to install the package" do
			expect(subject).to receive(:execute).with("python3 -m pip install #{name}")
			result
		end

		context "when pip command is overridden" do
			include_context "pip command overridden", "pip3"

			it "uses the user-configured command for pip" do
				expect(subject).to receive(:execute).with(/^pip3 install #{name}/)
				result
			end
		end
	end

	describe '#unmeet' do
		it "returns true" do
			expect(subject.unmeet).to be true
		end
	end

	describe '#should_meet?' do
		let(:result) { subject.should_meet? }
		let(:success?) { true }

		it "returns true" do
			expect(result).to be true
		end
	end
end
