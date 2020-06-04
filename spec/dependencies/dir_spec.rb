# frozen_string_literal: true

require 'dependencies/dir'

RSpec.describe Dependencies::Dir do
	subject { described_class.new(name) }
	let(:name) { "some-directory" }

	describe '#met?' do
		it "calls `test` to check if the directory exists" do
			expect(subject).to receive(:execute).with("test -d some-directory")
			subject.met?
		end
	end

	describe '#meet' do
		it "calls mkdir to create the directory" do
			expect(subject).to receive(:execute).with("mkdir some-directory")
			subject.meet
		end
	end

	describe '#unmeet' do
		it "returns true" do
			expect(subject.unmeet).to be true
		end
	end

	describe '#should_meet?' do
		it "returns true" do
			expect(subject.should_meet?).to be true
		end
	end
end
