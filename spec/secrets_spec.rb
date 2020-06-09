# frozen_string_literal: true

require 'secrets'

RSpec.describe Secrets do
	let(:secrets) do
		{
			"environment" => {
				"SECRET1" => "This is secret 1",
				"SECRET2" => "This is secret 2"
			},
			"other_stuff" => {
				"SECRET3" => "This is secret 3"
			}
		}.to_json
	end
	let(:ejson_file_exists) { true }
	let(:json_file_exists) { false }

	before do
		allow(File).to receive(:exist?).with("config/test/secrets.ejson").and_return(ejson_file_exists)
		allow(File).to receive(:exist?).with("config/test/secrets.json").and_return(json_file_exists)
		allow(subject).to receive(:`).with(/ejson decrypt .*/).and_return(secrets)
	end

	describe "#load" do
		let(:result) { subject.load }

		it "runs ejson to decrypt secrets" do
			expect(subject).to receive(:`).with("ejson decrypt config/test/secrets.ejson")
			result
		end

		it "sets environment variables for secrets in the 'environment' section" do
			expect(ENV).to receive(:[]=).with("SECRET1", "This is secret 1")
			expect(ENV).to receive(:[]=).with("SECRET2", "This is secret 2")
			result
		end

		it "does not set environment variabls for keys outside 'environment'" do
			expect(ENV).not_to receive(:[]=).with("SECRET3", anything)
			result
		end

		context "when ejson file does not exist" do
			let(:ejson_file_exists) { false }
			let(:json_file_exists) { true }
			let(:file_double) { instance_double(File) }

			before do
				allow(File).to receive(:open).with("config/test/secrets.json").and_return(file_double)
				allow(file_double).to receive(:read).and_return(secrets)
			end

			it "loads secrets from the JSON file" do
				expect(File).to receive(:open).with("config/test/secrets.json")
				result
			end

			it "does not call ejson to decrypt the file" do
				expect(subject).not_to receive(:`).with(/ejson decrypt/)
				result
			end

			context "when json file does not exist" do
				before do
					allow(File).to receive(:open).with("config/test/secrets.json").and_raise(Errno::ENOENT, "NOPE")
				end

				it "does not raise an exception" do
					expect { result }.not_to raise_error
				end

				it "does not set any environment variables" do
					expect(ENV).not_to receive(:[]=).with("SECRET1", anything)
					expect(ENV).not_to receive(:[]=).with("SECRET2", anything)
					result
				end
			end
		end

		context "when given filename" do
			subject { described_class.new(secrets_path) }

			let(:secrets_path) { "secrets/secrets.ejson" }

			it "runs ejson to decrypt the given file" do
				expect(subject).to receive(:`).with("ejson decrypt secrets/secrets.ejson")
				result
			end
		end
	end
end
