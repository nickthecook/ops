# frozen_string_literal: true

RSpec.describe Builtins::Up do
	subject { described_class.new(args, config) }

	let(:args) { [] }
	let(:config) { {} }
	let(:dep_double) { instance_double(Dependency, meet: dep_success) }
	let(:dep_success) { true }

	describe "#handle_dependency" do
		let(:result) { subject.handle_dependency(dep_double) }

		it "meets the dependency" do
			expect(dep_double).to receive(:meet).with(no_args)
			result
		end

		it "returns true" do
			expect(result).to be true
		end

		context "when meeting dependency fails" do
			let(:dep_success) { false }

			it "returns false" do
				expect(result).to be false
			end
		end
	end
end
