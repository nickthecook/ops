# frozen_string_literal: true

require_relative "../../../lib/builtins/helpers/dependency_handler"

RSpec.describe Builtins::Helpers::DependencyHandler do
	subject { described_class.new(dependency_set) }

	let(:dependency_set) do
		{
			"brew" => [
				"some_package"
			]
		}
	end

	describe "#dependencies" do
		let(:result) { subject.dependencies }

		it "returns a list of instances of Dependency" do
			expect(result).to all(be_a(Dependency))
		end

		context "when there are no dependencies defined" do
			let(:dependency_set) { nil }

			it "returns an empty list" do
				expect(result).to be_empty
			end
		end
	end
end
