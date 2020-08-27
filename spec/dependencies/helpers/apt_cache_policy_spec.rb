# frozen_string_literal: true

require 'dependencies/helpers/apt_cache_policy'

RSpec.describe Dependencies::Helpers::AptCachePolicy do
	subject { described_class.new(package_name) }

	let(:package_name) { "curl" }
	let(:policy_installed_output) do
		<<~OUTPUT
			curl:
			  Installed: 7.52.1-5+deb9u7
			  Candidate: 7.52.1-5+deb9u11
			  Version table:
			     7.52.1-5+deb9u11 500
			        500 http://raspbian.raspberrypi.org/raspbian stretch/main armhf Packages
			 *** 7.52.1-5+deb9u7 100
			        100 /var/lib/dpkg/status
		OUTPUT
	end
	let(:policy_not_installed_output) do
		<<~OUTPUT
			curl:
			  Installed: (none)
			  Candidate: 7.52.1-5+deb9u11
			  Version table:
			     7.52.1-5+deb9u11 500
			        500 http://raspbian.raspberrypi.org/raspbian stretch/main armhf Packages
			     7.52.1-5+deb9u7 100
			        100 /var/lib/dpkg/status
		OUTPUT
	end
	let(:policy_output) { policy_installed_output }

	before do
		allow(subject).to receive(:`).with("apt-cache policy curl").and_return(policy_output)
	end

	describe "#installed_version" do
		let(:result) { subject.installed_version }

		it "stuffs" do
			expect(result).to eq("7.52.1-5+deb9u7")
		end

		context "when package is not installed" do
			let(:policy_output) { policy_not_installed_output }

			it "returns nil" do
				expect(result).to be_nil
			end
		end
	end

	describe "#installed?" do
		let(:result) { subject.installed? }

		it "returns true" do
			expect(result).to be true
		end

		context "when package is not installed" do
			let(:policy_output) { policy_not_installed_output }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
