# frozen_string_literal: true

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

	describe ".load" do
		let(:result) { described_class.load }

		it "loads data from the default file" do
			expect(File).to receive(:open).with("config/test/config.json")
			result
		end

		it "sets environment variables for values in the 'environment' section" do
			expect(ENV).to receive(:[]=).with("KEY1", "This is key 1")
			expect(ENV).to receive(:[]=).with("KEY2", "This is key 2")
			result
		end

		it "does not set environment variables for keys outside 'environment'" do
			expect(ENV).not_to receive(:[]=).with("KEY3", anything)
			result
		end

		context "when json file does not exist" do
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

		context "when file is empty" do
			let(:config) { "" }

			it "outputs a warning" do
				expect(Output).to receive(:warn).with("Config file 'config/test/config.json' exists but is empty.")
				result
			end

			it "returns an empty config hash" do
				expect(ENV).not_to receive(:[]=)
				result
			end
		end

		context "when config path option is set" do
			before do
				allow(Options).to receive(:get).with("config.path").and_return("config-test.json")
			end

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

		context "when config is in YAML" do
			let(:config) do
				{
					"environment" => {
						"key1" => "value 1"
					}
				}.to_yaml
			end

			it "sets environment variables for values in the 'environment' section" do
				expect(ENV).to receive(:[]=).with("key1", "value 1")
				result
			end
		end

		context "when value is an array" do
			let(:config) do
				{
					"environment" => {
						"key1" => %w[val1 val2]
					}
				}.to_yaml
			end

			it "encodes the array as JSON" do
				expect(ENV).to receive(:[]=).with("key1", "[\"val1\",\"val2\"]")
				result
			end
		end

		context "when value is a hash" do
			let(:config) do
				{
					"environment" => {
						"key1" => {
							"key2" => "val1"
						}
					}
				}.to_yaml
			end

			it "encodes the hash as JSON" do
				expect(ENV).to receive(:[]=).with("key1", "{\"key2\":\"val1\"}")
				result
			end
		end
	end

	describe ".app_config_path" do
		let(:result) { AppConfig.app_config_path }

		it "returns default config path" do
			expect(result).to eq("config/test/config.json")
		end

		context "when config path option is set" do
			before do
				allow(Options).to receive(:get).with("config.path").and_return("config-test.json")
			end

			it "returns the path from the option" do
				expect(result).to eq("config-test.json")
			end
		end
	end
end
