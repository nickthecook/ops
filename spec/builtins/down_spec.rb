# frozen_string_literal: true

require 'builtins/down'

RSpec.describe Builtins::Down do
	subject { described_class.new(args, config) }

	let(:args) { [] }
	let(:config) { {} }
	let(:dep_double) { instance_double(Dependency, unmeet: dep_success) }
	let(:dep_success) { true }

	describe "#handle_dependency" do
		let(:result) { subject.handle_dependency(dep_double) }

		it "unmeets the dependency" do
			expect(dep_double).to receive(:unmeet).with(no_args)
			result
		end

		it "returns true" do
			expect(result).to be true
		end

		context "when unmeeting dependency fails" do
			let(:dep_success) { false }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
