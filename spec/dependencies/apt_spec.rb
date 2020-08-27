# frozen_string_literal: true

require 'dependencies/apt'

RSpec.describe Dependencies::Apt do
	subject { described_class.new(name) }

	let(:name) { "some-dependency" }

	describe '#met?' do
		it "calls `dpkg-query` to check if the dependency is installed" do
			expect(subject).to receive(:execute).with(/^dpkg-query .*/)
			subject.met?
		end
	end

	describe '#meet' do
		let(:result) { subject.meet }

		it "calls apt-get to install the package" do
			expect(subject).to receive(:execute).with("sudo apt-get install -y some-dependency")
			result
		end

		context "when user is root" do
			before do
				allow(ENV).to receive(:[]).with("USER").and_return("root")
			end

			it "calls apt-get without sudo" do
				expect(subject).to receive(:execute).with("apt-get install -y some-dependency")
				result
			end
		end

		context "when options.apt.sudo is false" do
			before do
				Options.set({ "apt" => { "use_sudo" => false } })
			end

			it "calls apt-get without sudo" do
				expect(subject).to receive(:execute).with("apt-get install -y some-dependency")
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
		let(:apt_get_available?) { true }

		before do
			allow(subject).to receive(:`).with("uname").and_return(uname)
			allow(subject).to receive(:system).with(/^which apt-get /).and_return(apt_get_available?)
		end

		context "Darwin kernel is running" do
			let(:uname) { "Darwin\n" }

			it "returns true" do
				expect(result).to be false
			end
		end

		context "Linux kernel is running" do
			let(:uname) { "Linux\n" }

			it "returns true" do
				expect(result).to be true
			end

			context "apt-get is not available" do
				let(:apt_get_available?) { false }

				it "returns false" do
					expect(result).to be false
				end
			end
		end
	end
end
