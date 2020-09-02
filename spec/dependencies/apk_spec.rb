# frozen_string_literal: true

require 'ostruct'

require 'dependencies/apt'

RSpec.describe Dependencies::Apk do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe '#met?' do
		it "calls `apk` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with(/^apk info | grep -q #{name}/)
			subject.met?
		end
	end

	describe '#meet' do
		it "calls apk to install the package" do
			expect(subject).to receive(:execute).with("apk add #{name}")
			subject.meet
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

		before do
			allow(subject).to receive(:`).with("uname").and_return(uname)
			allow(subject).to receive(:system).with(
				"which apk",
				out: File::NULL,
				err: File::NULL
			).and_return(success?)
		end

		context "kernel is Linux" do
			let(:uname) { "Linux" }

			it "returns true" do
				expect(result).to be true
			end

			context "apk command is not available" do
				let(:success?) { false }

				it "returns false" do
					expect(result).to be false
				end
			end
		end

		context "kernel name is Darwin" do
			let(:uname) { "Darwin" }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
