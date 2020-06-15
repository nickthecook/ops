# frozen_string_literal: true

require 'app_config'

RSpec.describe AppConfig do
	let(:config) do
		{
			"environment" => {
				"KEY1" => "This is key 1",
				"KEY2" => "This is key 2"
			},
			"other_stuff" => {
				"KEY3" => "This is key 3"
			}
		}.to_json
	end
	let(:file_double) { instance_double(File, read: config) }

	before do
		allow(File).to receive(:open).and_return(file_double)
	end

	describe "#load" do
		let(:result) { subject.load }

		it "loads data from the default file" do
			expect(File).to receive(:open).with("config/test/config.json")
			result
		end

		it "sets environment variables for values in the 'environment' section" do
			expect(ENV).to receive(:[]=).with("KEY1", "This is key 1")
			expect(ENV).to receive(:[]=).with("KEY2", "This is key 2")
			result
		end

		it "does not set environment variabls for keys outside 'environment'" do
			expect(ENV).not_to receive(:[]=).with("KEY3", anything)
			result
		end

		context "when ejson file does not exist" do
			before do
				allow(File).to receive(:open).and_raise(Errno::ENOENT, "NOPE")
			end

			it "does not raise an error" do
				expect { result }.not_to raise_error
			end

			it "does not set any environment variables" do
				expect(ENV).not_to receive(:[]=).with("KEY1", anything)
				expect(ENV).not_to receive(:[]=).with("KEY2", anything)
				result
			end
		end

		context "when given filename" do
			subject { described_class.new("config-test.json") }

			it "loads the correct file" do
				expect(File).to receive(:open).with("config-test.json")
				result
			end
		end

		context "when numeric value is in config" do
			let(:config) do
				{
					"environment" => {
						"KEY1" => 13
					}
				}.to_json
			end

			it "does not raise an exception" do
				expect { result }.not_to raise_error
			end
		end
	end
end
