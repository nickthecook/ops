# frozen_string_literal: true

require_relative 'test_dependency'

RSpec.describe Dependency do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	shared_examples "raises error" do |method|
		it "raises an error" do
			expect { subject.send(method) }.to raise_error(NotImplementedError)
		end
	end

	describe '#met?' do
		include_examples "raises error", :met?
	end

	describe '#meet' do
		include_examples "raises error", :meet
	end

	describe '#unmeet' do
		include_examples "raises error", :unmeet
	end

	describe '#should_meet?' do
		it "returns true" do
			expect(subject.should_meet?).to be true
		end
	end

	describe '#type' do
		it "returns the name of the class without modules" do
			expect(subject.type).to eq("Dependency")
		end
	end

	describe '#execute' do
		subject { TestDependency.new(name) }

		let(:result) { subject.meet }
		let(:cmd) { "bin/some_script" }
		let(:status_double) { instance_double(Process::Status, exitstatus: exit_code) }
		let(:exit_code) { 0 }
		let(:output_string) { "this is stdout\nthis is stderr\n" }

		before do
			allow(Open3).to receive(:capture2e).and_return([output_string, status_double])
		end

		it "executes the command" do
			expect(Open3).to receive(:capture2e).with(cmd)
			result
		end

		it "returns true" do
			expect(result).to be true
		end

		it "captures stdout" do
			result
			expect(subject.output).to match(/this is stdout/)
		end

		it "captures stderr" do
			result
			expect(subject.output).to match(/this is stderr/)
		end

		it "captures the exit code" do
			result
			expect(subject.exit_code).to eq(0)
		end

		context "when execution is unsuccessful" do
			let(:exit_code) { 1 }

			before do
				allow(Open3).to receive(:capture2e).and_return(["no such command!\n", status_double])
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
