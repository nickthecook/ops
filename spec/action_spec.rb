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

		it "executes the command" do
			expect(Kernel).to receive(:exec).with("bundle exec rspec spec/file1.rb spec/file2.rb")
			result
		end

		it "does not load secrets" do
			expect(Secrets).not_to receive(:new)
			result
		end

		context "when command requires secrets" do
			let(:action_config) { { "command" => "bundle exec rspec", "load_secrets" => true } }
			let(:secrets_double) { instance_double(Secrets) }

			before do
				allow(Secrets).to receive(:load).and_return(secrets_double)
			end

			it "loads secrets" do
				expect(Secrets).to receive(:load)
				result
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
				expect(result).to include("No 'command' specified.")
			end
		end
	end

	shared_context "args defined" do
		let(:action_config) do
			{
				"command" => "echo hello",
				"args" => {
					"name" => {
						"desc" => "The name of the person to whom to say 'hello'.",
						"mandatory" => true
					}
				}
			}
		end
	end

	shared_context "no extra args allowed" do
		let(:action_config) do
			{
				"command" => "echo hello",
				"extra_args_allowed" => false
			}
		end
	end

	describe "#args_valid?" do
		let(:result) { subject.args_valid? }
		let(:args) { ["leeroy"] }

		context "when args are defined" do
			include_context "args defined"

			it "returns true" do
				expect(result).to be true
			end

			context "when too many args are given" do
				let(:args) { %w[leeroy jenkins] }

				it "returns true" do
					expect(result).to be true
				end
			end
		end

		context "when no extra args are allowed" do
			let(:args) { ["leeroy"] }

			include_context "no extra args allowed"

			it "returns false" do
				expect(result).to be false
			end
		end

		context "when mandatory arg is missing" do
			let(:args) { [] }

			it "returns an error" do
				# expect(result).to include("")
			end
		end
	end

	describe "#arg_errors" do
		let(:result) { subject.arg_errors }
		let(:args) { ["leeroy"] }

		include_context "args defined"

		it "is empty" do
			expect(result).to be_empty
		end

		context "when too many args are given" do
			let(:args) { %w[leeroy jenkins] }

			it "returns no errors" do
				expect(result).to be_empty
			end
		end
	end
end
