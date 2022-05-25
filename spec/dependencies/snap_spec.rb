# frozen_string_literal: true

RSpec.describe Dependencies::Snap do
	subject { described_class.new(name) }

	let(:name) { "some-dependency" }

	describe '#met?' do
		let(:result) { subject.met? }
		let(:snap_installed) { true }

		before do
			allow(subject).to receive(:system).with(/^snap list/).and_return(snap_installed)
			allow(subject).to receive(:execute)
			ENV["OPS__APT__USE_SUDO"] = "false"
		end

		it "returns true" do
			expect(result).to be true
		end

		context "when snap is not installed" do
			let(:snap_installed) { false }

			it "returns false" do
				expect(result).to be false
			end
		end
	end

	describe '#meet' do
		let(:result) { subject.meet }

		it "calls snap to install the package" do
			expect(subject).to receive(:execute).with("sudo snap install some-dependency")
			result
		end

		context "when options.snap.use_sudo is false" do
			before do
				allow(Options).to receive(:get).with("snap.use_sudo").and_return(false)
			end

			it "calls snap without sudo" do
				expect(subject).to receive(:execute).with("snap install some-dependency")
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
		let(:snap_available?) { false }
		let(:snap_install_enabled?) { false }

		before do
			allow(subject).to receive(:`).with("uname").and_return(uname)
			allow(subject).to receive(:system).with(
				"which snap",
				out: File::NULL,
				err: File::NULL
			).and_return(snap_available?)
			allow(Options).to receive(:get).with("snap.install").and_return(snap_install_enabled?)
		end

		context "Darwin kernel is running" do
			let(:uname) { "Darwin\n" }

			it "returns false" do
				expect(result).to be false
			end
		end

		context "Linux kernel is running" do
			let(:uname) { "Linux\n" }

			it "returns false" do
				expect(result).to be false
			end

			context "snap.install option is true" do
				let(:snap_install_enabled?) { true }

				it "returns false" do
					expect(result).to be false
				end

				context "snap is available" do
					let(:snap_available?) { true }

					it "returns true" do
						expect(result).to be true
					end
				end
			end
		end
	end
end
