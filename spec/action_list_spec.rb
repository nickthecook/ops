# frozen_string_literal: true

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

		context "when duplicate alias exists" do
			before do
				action_list.merge!({
					"action_three" => {
						"command" => "echo three",
						"alias" => "two"
					}
				})
			end

			it "warns of duplicate alias" do
				expect(Output).to receive(:warn).with("Duplicate alias 'two' detected in action 'action_three'.")
				result
			end
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

		context "when actions have aliases set" do
			let(:action_list) do
				{
					"action_one" => {
						"command" => "echo one",
						"alias" => "one",
						"aliases" => ["1"]
					},
					"action_two" => {
						"command" => "echo two",
						"alias" => "two",
						"aliases" => ["2"]
					}
				}
			end

			it "returns an action by its alias" do
				expect(subject.get_by_alias("one").to_s).to eq("echo one arg_one arg_two")
			end

			it "returns an action by one of its aliases" do
				expect(subject.get_by_alias("1").to_s).to eq("echo one arg_one arg_two")
			end
		end
	end
end
