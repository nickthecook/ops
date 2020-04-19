# frozen_string_literal: true

require_relative "spec_helper.rb"

require_relative "../lib/dependency"

require_relative "test_dependency.rb"

RSpec.describe Dependency do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#met?" do
		it "raises an error" do
			expect { subject.met? }.to raise_error(NotImplementedError)
		end
	end

	describe "#meet" do
		it "raises an error" do
			expect { subject.meet }.to raise_error(NotImplementedError)
		end
	end

	describe "#unmeet" do
		it "raises an error" do
			expect { subject.unmeet }.to raise_error(NotImplementedError)
		end
	end

	describe "#type" do
		it "returns the name of the class without modules" do
			expect(subject.type).to eq("Dependency")
		end
	end

	describe "#execute" do
		subject { TestDependency.new(name) }

		let(:result) { subject.meet }
		let(:cmd) { "bin/some_script" }
		let(:status_double) { instance_double(Process::Status, exitstatus: exit_code) }
		let(:exit_code) { 0 }

		before do
			allow(Open3).to receive(:capture3).and_return(["this is stdout\n", "this is stderr\n", status_double])
		end


		it "executes the command" do
			expect(Open3).to receive(:capture3).with(cmd)
			result
		end

		it "returns true" do
			expect(result).to be true
		end

		it "captures stdout" do
			result
			expect(subject.stdout).to eq("this is stdout\n")
		end

		it "captures stderr" do
			result
			expect(subject.stderr).to eq("this is stderr\n")
		end

		it "captures the exit code" do
			result
			expect(subject.exit_code).to eq(0)
		end

		context "when execution is unsuccessful" do
			let(:exit_code) { 1 }

			before do
				allow(Open3).to receive(:capture3).and_return(["", "no such command!\n", status_double])
			end

			it "returns false" do
				expect(result).to be false
			end

			it "captures the exit code" do
				result
				expect(subject.exit_code).to eq(1)
			end
		end
	end
end
