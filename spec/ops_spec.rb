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
		let(:action_double) { instance_double(Action, to_s: action_string) }

		before do
			allow(YAML).to receive(:load_file).and_return(ops_config)
			allow(Action).to receive(:new).and_return(action_double)
			allow(Kernel).to receive(:exec)
		end

		it "creates an Action" do
			expect(Action).to receive(:new).with(*expected_action_args)
			result
		end

		it "executes the action string" do
			expect(Kernel).to receive(:exec).with(action_string)
			result
		end
	end
end

# to suppress the putses from Ops
def puts(*_); end
