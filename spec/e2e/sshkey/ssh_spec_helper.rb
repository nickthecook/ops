# frozen_string_literal: true

shared_examples "creates an SSH key" do |private_key_file|
	let(:public_key_file) { private_key_file + ".pub" }
	let(:private_key) { File.read(private_key_file) }
	let(:public_key) { File.read(public_key_file) }

	it "creates the SSH private key" do
		expect(private_key.split("\n").first).to eq("-----BEGIN OPENSSH PRIVATE KEY-----")
	end

	it "creates the SSH public key" do
		expect(public_key).to match(/^ssh-rsa /)
	end
end
