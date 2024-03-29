# frozen_string_literal: true

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
	let(:first_execute_result) { 0 }
	let(:second_execute_result) { 0 }
	let(:executor_double) { instance_double(Executor) }

	before do
		allow(Executor).to receive(:new).and_return(executor_double)
		allow(executor_double).to receive(:execute).and_return(true, true)
		allow(executor_double).to receive(:exit_code).and_return(first_execute_result, second_execute_result)
		allow(executor_double).to receive(:output).and_return("before", "more before")
	end

	describe "#do_hooks" do
		let(:result) { subject.do_hooks("before") }

		it "runs all hooks with the given name" do
			expect(executor_double).to receive(:execute).twice
			result
		end

		context "when first hook fails" do
			let(:first_execute_result) { 1 }

			it "raises an exception" do
				expect { result }.to raise_error(
					HookHandler::HookExecError,
					"before hook 'echo before' failed with exit code 1:\nbefore"
				)
			end

			it "does not execute the second hook" do
				expect(Executor).not_to receive(:new).with("more before")

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
				expect(executor_double).not_to receive(:execute)
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
