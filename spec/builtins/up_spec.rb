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
		let(:dependency_double) { instance_double(Dependency, installed?: installed?, install: true) }
		let(:installed?) { false }

		before do
			allow(Dependencies).to receive(:const_get).and_return(dependency_class_double)
			allow(dependency_class_double).to receive(:new).and_return(dependency_double)
		end

		it "creates a Dependency for each dependency in config" do
			expect(dependency_class_double).to receive(:new)
			result
		end

		it "checks if the dependency is installed" do
			expect(dependency_double).to receive(:installed?)
			result
		end

		it "installs the dependency" do
			expect(dependency_double).to receive(:install)
			result
		end

		context "dependency already installed" do
			let(:installed?) { true }

			it "does not install the dependency" do
				expect(dependency_double).not_to receive(:install)
				result
			end
		end
	end
end
