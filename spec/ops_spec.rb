# frozen_string_literal: true

require 'ops'

RSpec.describe Ops do
	subject { described_class.new(argv) }
	let(:input) { "test" }
	let(:action) { "test" }
	let(:action_alias) { "t" }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }
	let(:argv) { [input, *args] }
	let(:command) { "bundle exec rspec" }
	let(:ops_config) do
		{
			"min_version" => min_version,
			"hooks" => hooks,
			"actions" => {
				action => {
					"command" => command,
					"alias" => action_alias
				}
			},
			"options" => options
		}
	end
	let(:options) { {} }
	let(:hooks) { {} }
	let(:min_version) { "0.0.1" }

	describe '.project_name' do
		let(:result) { described_class.project_name }

		it "returns the current directory basename" do
			expect(result).to eq("ops")
		end

		context "when directory is not 'ops'" do
			before do
				expect(Dir).to receive(:pwd).and_return("/some/other/dir")
			end

			it "returns the current directory basename" do
				expect(result).to eq("dir")
			end
		end
	end

	describe '#run' do
		let(:result) { subject.run }
		let(:options) { nil }
		let(:action_string) { "bundle exec rspec spec/file1.rb spec/file2.rb" }

		before do
			allow(YAML).to receive(:load_file).and_return(ops_config)
			allow(Kernel).to receive(:exec)
			allow(subject).to receive(:exit)
		end

		context "when no arguments are given" do
			let(:argv) { [] }

			before do
				allow(subject).to receive(:exit)
			end

			it "prints an error" do
				expect(Output).to receive(:error).with(/^Usage: /)
				result
			end

			it "recommends running 'help'" do
				expect(Output).to receive(:out).with("Run 'ops help' for a list of builtins and actions.")
				result
			end

			it "exits with the appropriate error code" do
				expect(subject).to receive(:exit).with(Ops::INVALID_SYNTAX_EXIT_CODE)
				result
			end
		end

		context "when min version not met" do
			let(:min_version) { "99.99.99" }

			before do
				allow(subject).to receive(:exit)
			end

			it "exits with the appropriate error code" do
				expect(subject).to receive(:exit).with(Ops::MIN_VERSION_NOT_MET_EXIT_CODE)
				result
			end

			it "prints an error" do
				expect(Output).to receive(:error).with(/ops.yml specifies minimum version of /)
				result
			end
		end

		context "when action is not allowed in env" do
			let(:runner_double) { instance_double(Runner) }

			before do
				allow(Runner).to receive(:new).and_return(runner_double)
				allow(runner_double).to receive(:run).and_raise(Runner::NotAllowedInEnvError)
			end

			it "exits with the appropriate error code" do
				expect(subject).to receive(:exit).with(Ops::ACTION_NOT_ALLOWED_IN_ENV_EXIT_CODE)
				result
			end

			it "outputs an error" do
				expect(Output).to receive(:error).with("Error running action test: Runner::NotAllowedInEnvError")
				result
			end
		end

		context "when given action name is close to existing action name" do
			let(:input) { "tst" }

			it "outputs a suggestion" do
				expect(Output).to receive(:out).with("Did you mean 'test'?")
				result
			end

			it "does not recommend running 'help'" do
				expect(Output).not_to receive(:out).with("Run 'ops help' for a list of builtins and actions.")
				result
			end
		end

		context "when no builtin or action exists" do
			let(:input) { "nosuch" }

			before do
				allow(subject).to receive(:exit)
			end

			it "outputs an error" do
				expect(Output).to receive(:error).with("Unknown action: nosuch")
				result
			end

			it "recommends running 'help'" do
				expect(Output).to receive(:out).with("Run 'ops help' for a list of builtins and actions.")
				result
			end
		end
	end
end
