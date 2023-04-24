# frozen_string_literal: true

RSpec.describe Dependencies::Helpers::SshKeyDecryptor do
	subject { described_class.new(source_key_path, passphrase) }

	let(:source_key_path) { "config/test/user@host" }
	let(:passphrase) { "1234" }
	let(:tempfile_double) { instance_double(Tempfile, path: "/var/folders/opsasdf") }

	before do
		allow(Tempfile).to receive(:new).and_return(tempfile_double)
		allow(FileUtils).to receive(:cp)
		allow(File).to receive(:read).with("/var/folders/opsasdf").and_return("unencrypted key")
		allow(File).to receive(:delete)
		allow(subject).to receive(:`).with(/ssh-keygen -f '\/var\/folders\/opsasdf' .*/).and_return(true)
	end

	describe "#plaintext_key" do
		let(:result) { subject.plaintext_key }

		it "creates a tempfile" do
			result

			expect(Tempfile).to have_received(:new).with("ops")
		end

		it "copies the key to a tempfile" do
			result

			expect(FileUtils).to have_received(:cp).with("config/test/user@host", "/var/folders/opsasdf")
		end

		it "uses ssh-keygen to remove the passphrase from the encrypted key" do
			result

			expect(subject).to have_received(:`).with("ssh-keygen -f '/var/folders/opsasdf' -p -P '1234' </dev/null")
		end

		it "returns the value it reads from the decrypted file" do
			expect(result).to eq("unencrypted key")
		end

		it "deletes the tempfile" do
			result

			expect(File).to have_received(:delete).with("/var/folders/opsasdf")
		end
	end
end
