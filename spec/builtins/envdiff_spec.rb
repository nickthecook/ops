# frozen_string_literal: true

require 'builtins/envdiff'

RSpec.describe Builtins::EnvDiff do
	subject { described_class.new(args, config) }

	let(:args) { %w[dev staging] }
	let(:config) { {} }
	let(:dev_config_file) { "config/dev/config.json" }
	let(:dev_secrets_file) { "config/dev/secrets.json" }
	let(:staging_config_file) { "config/staging/config.json" }
	let(:staging_secrets_file) { "config/staging/secrets.ejson" }

	describe "#run" do
		let(:result) { subject.run }
		let(:dev_config) do
			{
				"environment" => {
					"SOME_CONFIG_KEY": "some dev value",
					"SOME_DEV_CONFIG_KEY": "some other dev value"
				}
			}
		end
		let(:staging_config) do
			{
				"environment" => {
					"SOME_CONFIG_KEY": "some staging value",
					"SOME_STAGING_KEY": "some other staging value"
				}
			}
		end
		let(:dev_secrets) do
			{
				"environment" => {
					"SOME_SECRET_KEY": "some secret value",
					"SOME_DEV_SECRET_KEY": "some dev secret value"
				}
			}
		end
		let(:staging_secrets) do
			{
				"environment" => {
					"SOME_SECRET_KEY": "some secret value",
					"SOME_STAGING_SECRET_KEY": "some staging secret value"
				}
			}
		end

		before do
			allow(File).to receive(:exist?).with(dev_config_file).and_return(true)
			allow(File).to receive(:exist?).with(dev_secrets_file).and_return(true)
			allow(File).to receive(:exist?).with(staging_config_file).and_return(true)
			allow(File).to receive(:exist?).with(staging_secrets_file).and_return(true)
			allow(File).to receive(:exist?).with("config/dev/secrets.ejson").and_return(false)

			allow(YAML).to receive(:load_file).with(dev_config_file).and_return(dev_config)
			allow(YAML).to receive(:load_file).with(dev_secrets_file).and_return(dev_secrets)
			allow(YAML).to receive(:load_file).with(staging_config_file).and_return(staging_config)
			allow(YAML).to receive(:load_file).with(staging_secrets_file).and_return(staging_secrets)

			allow(Output).to receive(:warn)
			allow(Output).to receive(:out)
		end

		it "outputs the keys that are in dev config and not staging config" do
			expect(Output).to receive(:warn).with("   - [CONFIG] SOME_DEV_CONFIG_KEY")
			result
		end

		it "outputs the keys that are in staging config and not in dev config" do
			expect(Output).to receive(:warn).with("   - [CONFIG] SOME_STAGING_KEY")
			result
		end

		it "does not output the keys that are present in both configs" do
			expect(Output).not_to receive(:warn).with(/SOME_CONFIG_KEY/)
			result
		end

		it "outputs the keys that are in dev secrets and not in staging secrets" do
			expect(Output).to receive(:warn).with("   - [SECRET] SOME_DEV_SECRET_KEY")
			result
		end

		it "outputs the keys that are in staging secrets and not in dev secrets" do
			expect(Output).to receive(:warn).with("   - [SECRET] SOME_STAGING_SECRET_KEY")
			result
		end

		it "does not output the keys that are present in both configs" do
			expect(Output).not_to receive(:warn).with(/SOME_SECRET_KEY/)
			result
		end

		it "outputs a message about dev having keys that staging does not" do
			expect(Output).to receive(:warn).with("Environment 'dev' defines keys that 'staging' does not:\n")
			result
		end

		it "outputs a message about staging having keys that dev does not" do
			expect(Output).to receive(:warn).with("Environment 'staging' defines keys that 'dev' does not:\n")
			result
		end

		context "when all config and secrets match" do
			let(:dev_config) do
				{
					"environment" => {
						"COMMON_KEY": "some value"
					}
				}
			end
			let(:staging_config) do
				{
					"environment" => {
						"COMMON_KEY": "some other value"
					}
				}
			end
			let(:dev_secrets) do
				{
					"environment" => {
						"COMMON_SECRET_KEY": "some secret value"
					}
				}
			end
			let(:staging_secrets) do
				{
					"environment" => {
						"COMMON_SECRET_KEY": "some other secret value"
					}
				}
			end

			it "outputs a message saying all keys match" do
				expect(Output).to receive(:out).with("Environments 'dev' and 'staging' define the same 2 key(s).")
				result
			end

			it "does not output any warnings" do
				expect(Output).not_to receive(:warn)
				result
			end
		end

		context "when a config file does not exist" do
			before do
				allow(File).to receive(:exist?).with(dev_config_file).and_return(false)
			end

			it "raises an error" do
				expect { result }.to raise_error(Builtin::ArgumentError, "File 'config/dev/config.json' does not exist.")
			end
		end

		context "when a secrets file does not exist" do
			before do
				allow(File).to receive(:exist?).with(staging_secrets_file).and_return(false)
				allow(File).to receive(:exist?).with("config/staging/secrets.json").and_return(false)
			end

			it "raises an error" do
				expect { result }.to raise_error(Builtin::ArgumentError, "File 'config/staging/secrets.json' does not exist.")
			end
		end

		context "when given wrong number of args" do
			let(:args) { ["dev"] }

			it "raises a usage error" do
				expect { result }.to raise_error(Builtin::ArgumentError, "Usage: ops envdiff <env_one> <env_two>")
			end
		end
	end
end
