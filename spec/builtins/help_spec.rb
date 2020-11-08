# frozen_string_literal: true

require 'builtins/help'

RSpec.describe Builtins::Help do
	subject { described_class.new(args, config) }
	let(:args) { [] }
	let(:config) do
		{
			"actions" => {
				"action1" => {
					"command" => "do something",
					"description" => description
				}
			},
			"forwards" => {
				"fwd1" => "forward one"
			}
		}
	end
	let(:description) { "does something" }

	describe '#run' do
		let(:result) { subject.run }

		before do
			allow(Output).to receive(:out)
		end

		it "prints builtins" do
			expect(Output).to receive(:out).with("Builtins:")
			expect(Output).to receive(:out).with(/up/)
			result
		end

		it "prints actions" do
			expect(Output).to receive(:out).with("Actions:")
			expect(Output).to receive(:out).with(/action1/)
			result
		end

		it "prints fowards" do
			expect(Output).to receive(:out).with("Forwards:")
			expect(Output).to receive(:out).with(/fwd1.*forward one/)
			result
		end
	end
end
