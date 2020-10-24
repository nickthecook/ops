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
		let(:expected_action_args) { [{ "command" => "bundle exec rspec", "alias" => "t" }, args] }
		let(:options) { nil }
		let(:action_string) { "bundle exec rspec spec/file1.rb spec/file2.rb" }
		let(:action_double) do
			instance_double(
				Action,
				run: nil,
				alias: action_alias,
				to_s: "test",
				config_valid?: action_config_valid?,
				config_errors: action_config_errors
			)
		end
		let(:action_config_valid?) { true }
		let(:action_config_errors) { [] }

		before do
			allow(YAML).to receive(:load_file).and_return(ops_config)
			allow(Action).to receive(:new).and_return(action_double)
			allow(Kernel).to receive(:exec)
		end

		context "when a builtin exists" do
			let(:builtin_double) { instance_double(Builtin, run: true) }
			let(:builtin_class_double) { class_double(Builtin, new: builtin_double) }

			before do
				allow(Builtins).to receive(:const_get).and_return(builtin_class_double)
			end

			it "uses Builtin to get the builtin class" do
				expect(Builtin).to receive(:class_for).with(name: "test")
				result
			end

			it "runs the builtin" do
				expect(builtin_double).to receive(:run).with(no_args)
				result
			end

			it "doesn't run the action" do
				expect(Action).not_to receive(:new)
				result
			end

			it "initializes Options" do
				expect(Options).to receive(:set).with({})
				result
			end

			context "when options are set" do
				let(:options) { { "fries_with_that" => true } }

				it "initializes Options with options from config" do
					expect(Options).to receive(:set).with({ "fries_with_that" => true })
					result
				end
			end
		end

		context "when no builtin exists" do
			it "uses ActionList to build a list of actions" do
				expect(ActionList).to receive(:new).with(ops_config["actions"], args).and_call_original
				result
			end

			# TODO: Action-related tests are technically integration tests, since Ops uses ActionList in between
			it "creates an Action" do
				expect(Action).to receive(:new).with(*expected_action_args)
				result
			end

			it "executes the action string" do
				expect(action_double).to receive(:run).with(no_args)
				result
			end

			it "loads ops.yml" do
				expect(YAML).to receive(:load_file).with("ops.yml")
				result
			end

			it "checks that the action is valid" do
				expect(action_double).to receive(:config_valid?)
				result
			end

			it "outputs a message saying it's running the action" do
				expect(Output).to receive(:notice).with(/Running 'test' from /)
				result
			end

			context "when action config is not valid" do
				let(:action_config_valid?) { false }
				let(:action_config_errors) { ["Nope", "Still nope"] }

				before do
					allow(subject).to receive(:exit)
				end

				it "outputs an error" do
					expect(Output).to receive(:error).with("Error(s) running action 'test': Nope; Still nope")
					result
				end
			end
		end

		context "when given action is an alias" do
			let(:input) { "t" }

			it "executes the action string for the aliased action" do
				expect(Action).to receive(:new).with(*expected_action_args)
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

			context "when given action name is close to builtin name" do
				let(:input) { "dwn" }

				it "outputs a suggestion" do
					expect(Output).to receive(:out).with("Did you mean 'down'?")
					result
				end
			end
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

		context "when before hooks are configured" do
			let(:hooks) do
				{
					"before" => [
						"echo hello there",
						"echo and now do you like my hat?"
					]
				}
			end
			let(:hook_handler_double) { instance_double(HookHandler) }

			before do
				allow(ENV).to receive(:[]).and_call_original
				allow(ENV).to receive(:[]).with("OPS_RUNNING").and_return(nil)
				allow(action_double).to receive(:skip_hooks?).with("before").and_return(false)
				allow(HookHandler).to receive(:new).and_return(hook_handler_double)
				allow(hook_handler_double).to receive(:do_hooks)
			end

			it "runs the hooks" do
				expect(hook_handler_double).to receive(:do_hooks)
				result
			end

			context "when the action is configured to skip before hooks" do
				before do
					allow(action_double).to receive(:skip_hooks?).with("before").and_return(true)
				end

				it "does not run the hooks" do
					expect(hook_handler_double).not_to receive(:do_hooks)
					result
				end
			end

			context "when the action is being run from another ops command" do
				# i.e. `ops aa` runs `ops apply`; so `ops apply` should skip before hooks, as `ops aa` will have run them
				before do
					allow(ENV).to receive(:[]).with("OPS_RUNNING").and_return("1")
				end

				it "does not run the hooks" do
					expect(hook_handler_double).not_to receive(:do_hooks)
					result
				end
			end
		end

		context "when action is not allowed in env" do
			before do
				allow(action_double).to receive(:run).and_raise(Action::NotAllowedInEnvError)
			end

			it "exits with the appropriate error code" do
				expect(subject).to receive(:exit).with(Ops::ACTION_NOT_ALLOWED_IN_ENV_EXIT_CODE)
				result
			end
		end

		context "when forwards are configured" do
			let(:ops_config) do
				{
					"forwards" => {
						"app" => "app",
						"inf" => "infrastructure"
					},
					"actions" => {
						"app" => {
							"command" => "nope"
						}
					}
				}
			end
			let(:input) { "inf" }
			let(:forwards_double) { instance_double(Forwards) }
			let(:forward_double) { instance_double(Forward) }
			let(:args) { %w[arg_one arg_two]}

			before do
				allow(Forwards).to receive(:new).and_return(forwards_double)
				allow(forwards_double).to receive(:get).and_return(forward_double)
				allow(forward_double).to receive(:run)
			end

			it "gets the list of Forwards" do
				expect(Forwards).to receive(:new).with(ops_config, args)
				result
			end

			it "gets the correct forward" do
				expect(forwards_double).to receive(:get).with("inf")
				result
			end

			it "runs the forward" do
				expect(forward_double).to receive(:run)
				result
			end
		end
	end
end
