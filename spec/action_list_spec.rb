# frozen_string_literal: true

require 'action_list'

RSpec.describe ActionList do
	subject { described_class.new(action_list, args) }
	let(:action_list) do
		{
			"action_one" => {
				"command" => "echo one",
				"alias" => "one"
			},
			"action_two" => {
				"command" => "echo two",
				"alias" => "two"
			}
		}
	end
	let(:args) { %w[arg_one arg_two] }

	describe "#get" do
		let(:result) { subject.get(name) }
		let(:name) { "action_two" }

		it "returns an Action" do
			expect(result).to be_an(Action)
		end

		it "returns the correct Action" do
			expect(result.to_s).to eq("echo two arg_one arg_two")
		end
	end

	describe "#get_by_alias" do
		let(:result) { subject.get_by_alias(name) }
		let(:name) { "one" }

		it "returns an Action" do
			expect(result).to be_an(Action)
		end

		it "returns the correct Action" do
			expect(result.to_s).to eq("echo one arg_one arg_two")
		end
	end
end
