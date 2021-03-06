# frozen_string_literal: true

require 'builtins/up'

RSpec.describe Builtins::Up do
	subject { described_class.new(args, config) }
	# Up doesn't use args
	let(:args) { [] }
	let(:config) do
		{
			"dependencies" => {
				"apk" => [
					"ridiculous_package"
				],
				"custom" => [
					"echo hi",
					"echo derp"
				],
				"dir" => [
					"directory_of_life"
				]
			}
		}
	end

	describe '#run' do
		let(:result) { subject.run }
		let(:dependency_class_double) { class_double(Dependency) }
		let(:dependency_double) do
			instance_double(
				Dependency,
				met?: met?,
				meet: true,
				should_meet?: should_meet?,
				always_act?: always_act?,
				success?: true,
				name: "ridiculous_package",
				type: "apk"
			)
		end
		let(:should_meet?) { true }
		let(:always_act?) { false }
		let(:met?) { false }

		before do
			allow(Dependencies).to receive(:const_get).and_return(dependency_class_double)
			allow(dependency_class_double).to receive(:new).and_return(dependency_double)
			allow(dependency_double)
		end

		it "Looks for a class to handle the dependency" do
			expect(Dependencies).to receive(:const_get).with(:Apk, false)
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

		context "always_act? and met? are true" do
			let(:always_act?) { true }
			let(:met?) { true }

			it "meets the dependency" do
				expect(dependency_double).to receive(:meet)
				result
			end
		end

		context "args are given" do
			let(:args) { %w[custom dir] }
			let(:dep_handler_double) { instance_double(Builtins::Helpers::DependencyHandler, dependencies: []) }

			before do
				allow(Builtins::Helpers::DependencyHandler).to receive(:new).and_return(dep_handler_double)
			end

			it "attempts to meet the dir dependency" do
				expect(Builtins::Helpers::DependencyHandler).to receive(:new).with(hash_including("dir" => anything))
				result
			end

			it "attempts to meet the custom dependencies" do
				expect(Builtins::Helpers::DependencyHandler).to receive(:new).with(hash_including("custom" => anything))
				result
			end
			
			it "does not attempt to meet the apt dependencies" do
				expect(Builtins::Helpers::DependencyHandler).to receive(:new).with(hash_not_including("apk" => anything))
				result
			end
		end
	end
end
