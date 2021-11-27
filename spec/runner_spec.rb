# frozen_string_literal: true

require 'runner'

RSpec.describe Runner do
	subject { described_class.new(action_name, args, config, config_path) }

	let(:action_name) { 'test' }
	let(:args) { %w[one two] }
	let(:config) do
		{
			"hooks" => hooks,
			"actions" => {
				"test" => {
					"command" => command,
					"alias" => action_alias
				}
			}
		}
	end
	let(:config_path) { "some_dir/ops.yml" }
	let(:hooks) { {} }
	let(:action_alias) { "t" }
	let(:command) { "bundle exec rspec" }
	let(:options) { {} }

	describe "#run" do
		let(:result) { subject.run }
		let(:action_double) do
			instance_double(
				Action,
				name: action_name,
				run: nil,
				alias: action_alias,
				aliases: [action_alias],
				to_s: "test",
				load_secrets?: load_secrets,
				config_valid?: true,
				allowed_in_env?: allowed_in_env,
				execute_in_env?: execute_in_env
			)
		end
		let(:load_secrets) { false }
		let(:expected_action_args) { [action_name, { "command" => "bundle exec rspec", "alias" => "t" }, args] }
		let(:allowed_in_env) { true }
		let(:execute_in_env) { true }

		before do
			allow(Action).to receive(:new).and_return(action_double)
			allow(Kernel).to receive(:exec)
			allow(subject).to receive(:exit)
		end

		context "when forwards are configured" do
			let(:config) do
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
			let(:action_name) { "inf" }
			let(:forwards_double) { instance_double(Forwards) }
			let(:forward_double) { instance_double(Forward) }
			let(:args) { %w[arg_one arg_two] }

			before do
				allow(Forwards).to receive(:new).and_return(forwards_double)
				allow(forwards_double).to receive(:get).and_return(forward_double)
				allow(forward_double).to receive(:run)
			end

			it "gets the list of Forwards" do
				expect(Forwards).to receive(:new).with(config, args)
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
				expect(action_double).not_to receive(:run)
				result
			end
		end

		context "when no builtin exists" do
			it "uses ActionList to build a list of actions" do
				expect(ActionList).to receive(:new).with(config["actions"], args).and_call_original
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

			it "checks that the action is valid" do
				expect(action_double).to receive(:config_valid?)
				result
			end

			it "outputs a message saying it's running the action" do
				expect(Output).to receive(:notice).with(/Running 'test' in environment 'test'/)
				result
			end

			it "does not load secrets" do
				expect(Secrets).not_to receive(:load)
				result
			end

			context "when action says to load secrest" do
				let(:load_secrets) { true }

				it "loads secrets" do
					expect(Secrets).to receive(:load)
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

		context "when not allowed in env" do
			let(:allowed_in_env) { false }

			it "raises an error instead of running the action" do
				expect(action_double).not_to receive(:run)
				expect { result }.to raise_error(Runner::NotAllowedInEnvError)
			end
		end

		context "when skipped in env" do
			let(:execute_in_env) { false }

			it "outputs a warning" do
				expect(Output).to receive(:warn).with("Skipping action 'test' in environment test.")
				result
			end

			it "does not run the action" do
				expect(action_double).not_to receive(:run)
				result
			end
		end
	end
end
