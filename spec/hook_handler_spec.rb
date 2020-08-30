# frozen_string_literal: true

require 'hook_handler'

RSpec.describe(HookHandler) do
	subject { described_class.new(config) }

	let(:config) do
		{
			"hooks" => {
				"before" => [
					"echo before",
					"echo more before"
				],
				"after" => [
					"echo after",
					"echo more after"
				]
			}
		}
	end
	let(:first_execute_result) { ["before", 0]}
	let(:second_execute_result) { ["more before", 0] }

	before do
		allow(Executor).to receive(:execute).and_return(first_execute_result, second_execute_result)
	end

	describe "#do_hooks" do
		let(:result) { subject.do_hooks("before") }

		it "runs all hooks with the given name" do
			expect(Executor).to receive(:execute).with("echo before")
			expect(Executor).to receive(:execute).with("echo more before")
			result
		end

		context "when first hook fails" do
			let(:first_execute_result) { ["nope", 1] }

			it "raises an exception" do
				expect { result }.to raise_error(
					HookHandler::HookExecError,
					"before hook 'echo before' failed with exit code 1:\nnope"
				)
			end

			it "does not execute the second hook" do
				expect(Executor).not_to receive(:execute).with("echo more before")

				# this is kind of duplicating the above test, but it's needed to have rspec allow the error to be raised
				expect { result }.to raise_error(HookHandler::HookExecError)
			end
		end

		context "when no hooks are configured" do
			let(:config) { {} }

			it "does not raise an error" do
				expect { result }.not_to raise_error
			end

			it "does not execute any hooks" do
				expect(Executor).not_to receive(:execute)
				result
			end
		end

		context "when hook list is not a list" do
			let(:config) do
				{
					"hooks" => {
						"before" => "nope"
					}
				}
			end

			it "raises a HookConfigError" do
				expect { result }.to raise_error(HookHandler::HookConfigError, "'hooks.before' must be a list")
			end
		end
	end
end
