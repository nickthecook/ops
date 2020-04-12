# frozen_string_literal: true

require_relative "spec_helper.rb"

require_relative "../lib/ops.rb"

RSpec.describe Ops do
	subject { described_class.new(argv) }
	let(:action) { "test" }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }
	let(:argv) { [action, *args] }
	let(:command) { "bundle exec rspec" }
	let(:ops_config) do
		{
			"actions" => {
				action => {
					"command" => command
				}
			}
		}
	end

	describe "#run" do
		let(:result) { subject.run }
		let(:expected_action_args) { ["bundle exec rspec", args] }
		let(:action_string) { "bundle exec rspec spec/file1.rb spec/file2.rb" }
		let(:action_double) { instance_double(Action, run: nil) }

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

			it "finds the builtin class" do
				expect(Builtins).to receive(:const_get).with(:Test)
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
		end

		context "when no builtin exists" do
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
		end
	end
end

# to suppress the putses from Ops
def puts(*_); end
