# frozen_string_literal: true

require 'ostruct'

RSpec.describe Dependencies::Gem do
	subject { described_class.new(name) }
	let(:name) { "some-gem" }
	let(:use_sudo) { false }
	let(:user_install) { false }

	before do
		allow(Open3).to receive(:capture2e).and_return(["this is stdout", OpenStruct.new(exitstatus: 0)])
		Options.set({ "gem" => { "use_sudo" => use_sudo, "user_install" => user_install } })
	end

	describe '#met?' do
		let(:result) { subject.met? }

		it "runs `gem` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with("gem list -i '^some-gem$'")
			result
		end

		context "when version is specified" do
			let(:name) { "some-gem >=1.0.0" }

			it "runs gem to check if an acceptable version is installed" do
				expect(subject).to receive(:execute).with("gem list -i '^some-gem$' -v '>=1.0.0'")
				result
			end
		end
	end

	describe '#meet' do
		let(:result) { subject.meet }

		it "runs `gem` to install the package" do
			expect(subject).to receive(:execute).with("gem install 'some-gem'")
			result
		end

		context "use_sudo is true" do
			let(:use_sudo) { true }

			it "uses sudo to run `gem`" do
				expect(subject).to receive(:execute).with("sudo gem install 'some-gem'")
				result
			end
		end

		context "user_install is true" do
			let(:user_install) { true }

			it "runs gem with --user-install" do
				expect(subject).to receive(:execute).with("gem install --user-install 'some-gem'")
				result
			end
		end

		context "when version is specified" do
			let(:name) { "some-gem >=1.0.0" }

			it "runs gem to install with the version spec" do
				expect(subject).to receive(:execute).with("gem install 'some-gem' -v '>=1.0.0'")
				result
			end
		end
	end

	describe '#unmeet' do
		it "returns true" do
			expect(subject.unmeet).to be true
		end
	end
end
