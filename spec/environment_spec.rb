# frozen_string_literal: true

require 'environment'

RSpec.describe Environment do
	subject { described_class.new(variables) }

	let(:variables) { { "var1" => "val1", "var2" => "val2" } }

	describe "#set_variables" do
		let(:result) { subject.set_variables }

		before do
			# keys and values set in ENV must be Strings
			allow(ENV).to receive(:[]=).with(kind_of(String), kind_of(String))
		end

		it "sets OPS_YML_DIR" do
			expect(ENV).to receive(:[]=).with("OPS_YML_DIR", Dir.pwd)
			result
		end

		it "sets OPS_VERSION" do
			expect(ENV).to receive(:[]=).with("OPS_VERSION", /[0-9]+\.[0-9]+\.[0-9]+/)
			result
		end

		it "sets the given variables" do
			expect(ENV).to receive(:[]=).with("var1", "val1")
			expect(ENV).to receive(:[]=).with("var2", "val2")
			result
		end

		it "sets the 'environment' variable" do
			expect(ENV).to receive(:[]=).with("environment", "test")
			result
		end

		context "when numeric value is in config" do
			let(:variables) { { "var1" => 1 } }

			it "does not raise an exception" do
				expect { result }.not_to raise_error
			end
		end

		context "when environment_aliases are given" do
			let(:aliases) { %w[ENV RAILS_ENV] }

			before do
				allow(Options).to receive(:get).with("environment_aliases").and_return(aliases)
			end

			it "sets all aliases to the environment value" do
				expect(ENV).to receive(:[]=).with('ENV', 'test')
				expect(ENV).to receive(:[]=).with('RAILS_ENV', 'test')
				result
			end

			it "does not set 'environment'" do
				expect(ENV).not_to receive(:[]=).with('environment', anything)
				result
			end
		end

		context "when variable values contain environment variable references" do
			let(:variables) { { "namespace" => "nick-$environment" } }

			it "expands the variables" do
				expect(ENV).to receive(:[]=).with("namespace", "nick-test")
				result
			end
		end
	end

	describe ".environment" do
		let(:result) { described_class.environment }

		it "returns the current value of the 'environment' variable" do
			expect(result).to eq("test")
		end

		context "when the variable is not set" do
			before do
				allow(ENV).to receive(:[]).with("environment").and_return(nil)
			end

			it "returns 'dev'" do
				expect(result).to eq("dev")
			end
		end
	end
end
