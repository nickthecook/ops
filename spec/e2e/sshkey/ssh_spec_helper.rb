# frozen_string_literal: true

require 'English'

shared_examples "creates an SSH key" do |private_key_file|
	let(:public_key_file) { private_key_file + ".pub" }
	let(:private_key) { File.read(private_key_file) }
	let(:public_key) { File.read(public_key_file) }

	it "creates the SSH private key" do
		expect(private_key.split("\n").first).to match(/-----BEGIN (OPENSSH|RSA) PRIVATE KEY-----/)
	end

	it "creates the SSH public key" do
		expect(public_key).to match(/^ssh-[a-zA-Z0-9]* /)
	end
end

def has_passphrase?(private_key_file)
	# attempt to change the passphrase and provide an empty passphrase
	# this will exit with 255 if the key has a passphrase, and 0 if it does not
	# this will also not prompt for input, but redirect input from /dev/null just in case
	system("ssh-keygen -p -P '' -N '' -f \"#{private_key_file}\"", out: File::NULL, err: File::NULL)

	$CHILD_STATUS.exitstatus == 255
end
