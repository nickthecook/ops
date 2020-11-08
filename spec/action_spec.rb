# frozen_string_literal: true

require 'action'

RSpec.describe Action do
	subject { described_class.new(action_config, args) }
	let(:action_config) { { "command" => "bundle exec rspec" } }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }

	describe '#to_s' do
		let(:result) { subject.to_s }

		it "appends args to command" do
			expect(result).to eq("bundle exec rspec spec/file1.rb spec/file2.rb")
		end

		context "when no args are given" do
			let(:args) { [] }

			it "returns the command" do
				expect(result).to eq("bundle exec rspec")
			end
		end
	end

	describe "#run" do
		let(:result) { subject.run }

		before do
			allow(Kernel).to receive(:exec)
		end

		shared_examples "executes the command" do
			it "executes the command" do
				expect(Kernel).to receive(:exec).with("bundle exec rspec spec/file1.rb spec/file2.rb")
				result
			end
		end

		include_examples "executes the command"

		it "does not load secrets" do
			expect(Secrets).not_to receive(:new)
			result
		end

		context "when in_envs includes the current environment" do
			let(:action_config) { { "command" => "bundle exec rspec", "in_envs" => %w[test dev] } }

			include_examples "executes the command"
		end

		context "when in_envs does not include the current environment" do
			let(:action_config) { { "command" => "bundle exec rspec", "in_envs" => %w[dev staging] } }

			it "raises an error" do
				expect { result }.to raise_error(Action::NotAllowedInEnvError)
			end
		end

		context "when not_in_envs does not include the current environment" do
			let(:action_config) { { "command" => "bundle exec rspec", "not_in_envs" => %w[dev production] } }

			include_examples "executes the command"
		end

		context "when in_envs includes the current environment" do
			let(:action_config) { { "command" => "bundle exec rspec", "not_in_envs" => %w[test dev] } }

			it "raises an error" do
				expect { result }.to raise_error(Action::NotAllowedInEnvError)
			end
		end

		context "when both in_envs and not_in_envs include current environment" do
			let(:action_config) do
				{ "command" => "bundle exec rspec", "in_envs" => %w[test staging], "not_in_envs" => %w[test dev] }
			end

			it "raises an error" do
				expect { result }.to raise_error(Action::NotAllowedInEnvError)
			end
		end
	end

	shared_context "missing command" do
		let(:action_config) { { "alias" => "nope", "description" => "nope" } }
	end

	describe "#config_valid?" do
		let(:result) { subject.config_valid? }

		it "returns true" do
			expect(result).to be true
		end

		context "when 'command' is missing" do
			include_context "missing command"

			it "returns false" do
				expect(result).to be false
			end
		end
	end

	describe "#config_errors" do
		let(:result) { subject.config_errors }

		it "is empty" do
			expect(result).to be_empty
		end

		context "when 'command' is missing" do
			include_context "missing command"

			it "returns an error about 'command' missing" do
				expect(result).to include("No 'command' specified in 'action'.")
			end
		end
	end

	describe "#load_secrets?" do
		let(:result) { subject.load_secrets? }
		let(:action_config) { { "command" => "bundle exec rspec", "load_secrets" => load_secrets } }
		let(:load_secrets) { true }

		it "returns true" do
			expect(result).to be true
		end

		context "when load_secrets is false" do
			let(:load_secrets) { false }

			it "returns false" do
				expect(result).to be false
			end
		end

		context "when load_secrets is not set" do
			let(:load_secrets) { nil }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
