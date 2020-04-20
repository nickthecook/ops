# frozen_string_literal: true

require_relative "../../lib/builtins/up.rb"

require_relative "../spec_helper.rb"

RSpec.describe Builtins::Up do
	subject { described_class.new(args, config) }
	# Up doesn't use args
	let(:args) { [] }
	let(:config) do
		{
			"dependencies" => {
				"apk" => [
					"ridiculous_package"
				]
			}
		}
	end

	describe "#run" do
		let(:result) { subject.run }
		let(:dependency_class_double) { class_double(Dependency) }
		let(:dependency_double) do
			instance_double(
				Dependency,
				met?: met?,
				meet: true,
				should_meet?: should_meet?,
				success?: true,
				name: "ridiculous_package",
				type: "apk"
			)
		end
		let(:should_meet?) { true }
		let(:met?) { false }

		before do
			allow(Dependencies).to receive(:const_get).and_return(dependency_class_double)
			allow(dependency_class_double).to receive(:new).and_return(dependency_double)
			allow(dependency_double)
		end

		it "Looks for a class to handle the dependency" do
			expect(Dependencies).to receive(:const_get).with(:Apk)
			result
		end

		it "creates a Dependency for each dependency in config" do
			expect(dependency_class_double).to receive(:new)
			result
		end

		it "checks if the dependency is met" do
			expect(dependency_double).to receive(:met?)
			result
		end

		it "checks if it should meet the dependency" do
			expect(dependency_double).to receive(:should_meet?)
			result
		end

		it "meets the dependency" do
			expect(dependency_double).to receive(:meet)
			result
		end

		context "dependency already met" do
			let(:met?) { true }

			it "does not meet the dependency" do
				expect(dependency_double).not_to receive(:meet)
				result
			end
		end

		context "should not meet dependency" do
			let(:should_meet?) { false }

			it "does not check if dependency is met" do
				expect(dependency_double).not_to receive(:met?)
				result
			end
		end
	end
end
