# frozen_string_literal: true

RSpec.describe Action do
	subject { described_class.new("jackson", action_config, args) }
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

		context "when not_in_envs does not include the current environment" do
			let(:action_config) { { "command" => "bundle exec rspec", "not_in_envs" => %w[dev production] } }

			include_examples "executes the command"
		end

		context "when shell expansion is option is false" do
			let(:action_config) { { "command" => "bundle exec rspec", "shell_expansion" => false } }

			it "executed the action without shell expansion" do
				expect(Kernel).to receive(:exec).with("bundle", "exec", "rspec", "spec/file1.rb", "spec/file2.rb")
				result
			end
		end

		context "when shell expansion is option is true" do
			let(:action_config) { { "command" => "bundle exec rspec", "shell_expansion" => true } }

			it "executed the action with shell expansion" do
				expect(Kernel).to receive(:exec).with("bundle exec rspec spec/file1.rb spec/file2.rb")
				result
			end
		end

		context "when action config is nil" do
			let(:action_config) { nil }

			it "does not raise" do
				expect { result }.not_to raise_exception
			end
		end
	end

	shared_context "missing command" do
		let(:action_config) { { "alias" => "nope", "description" => "nope" } }
	end

	shared_context "config is string" do
		let(:action_config) { "echo hi there" }
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

		context "when config is just a string" do
			include_context "config is string"

			it "returns true" do
				expect(result).to be true
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

		context "when config is just a string" do
			include_context "config is string"

			it "returns nil" do
				expect(result).to be_empty
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

	describe "#allowed_in_env?" do
		let(:result) { subject.allowed_in_env?(env) }
		let(:env) { "production" }
		let(:action_config) { { "command" => command } }
		let(:command) { "bundle exec rspec" }

		context "with no in_envs or not_in_envs configured" do
			it "returns true" do
				expect(result).to be true
			end
		end

		context "when in_envs does not include the given environment" do
			let(:action_config) { { "command" => command, "in_envs" => %w[dev staging] } }

			it "returns false" do
				expect(result).to be false
			end
		end

		context "when in_envs includes the given environment" do
			let(:action_config) { { "command" => command, "in_envs" => %w[staging production] } }

			it "returns true" do
				expect(result).to be true
			end
		end

		context "when not_in_envs includes the given environment" do
			let(:action_config) { { "command" => command, "not_in_envs" => %w[staging production] } }

			it "returns false" do
				expect(result).to be false
			end
		end

		context "when in_envs and not_in_envs include the given environment" do
			let(:action_config) do
				{
					"command" => command,
					"in_envs" => %w[staging production],
					"not_in_envs" => %w[staging production]
				}
			end

			it "returns false" do
				expect(result).to be false
			end
		end
	end

	describe "#execute_in_env?" do
		let(:result) { subject.execute_in_env?(env) }
		let(:env) { "production" }
		let(:action_config) { { "command" => command } }
		let(:command) { "bundle exec rspec" }

		it "returns true" do
			expect(result).to be true
		end

		context "when skip_in_envs includes the given environment" do
			let(:action_config) { { "command" => command, "skip_in_envs" => %w[staging production] } }

			it "returns false" do
				expect(result).to be false
			end
		end
	end

	describe "#alias" do
		let(:result) { subject.alias }
		let(:action_config) do
			{
				"command" => "bundle exec rspec",
				"alias" => "t"
			}
		end

		it "returns the configured alias" do
			expect(result).to eq("t")
		end

		context "when only aliases is set" do
			let(:action_config) do
				{
					"command" => "bundle exec rspec",
					"aliases" => %w[t rspec]
				}
			end

			it "returns the first alias" do
				expect(result).to eq("t")
			end
		end
	end

	describe "#aliases" do
		let(:result) { subject.aliases }
		let(:action_config) do
			{
				"command" => "bundle exec rspec",
				"aliases" => %w[t rspec]
			}
		end

		it "returns the list of aliases" do
			expect(result).to contain_exactly("t", "rspec")
		end

		context "when alias and aliases are not set" do
			let(:action_config) do
				{ "command" => "bundle exec rspec" }
			end

			it "does not raise an error" do
				expect { result }.not_to raise_error
			end

			it "returns an empty list" do
				expect(result).to be_empty
			end
		end

		context "when alias and aliases are set" do
			let(:action_config) do
				{
					"command" => "bundle exec rspec",
					"alias" => "t",
					"aliases" => %w[test rspec]
				}
			end

			it "returns the combined list" do
				expect(result).to contain_exactly("t", "test", "rspec")
			end
		end

		context "when action config is nil" do
			let(:action_config) { nil }

			it "does not raise" do
				expect { result }.not_to raise_exception
			end

			it "returns an empty list" do
				expect(result).to be_empty
			end
		end
	end
end
