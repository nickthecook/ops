# frozen_string_literal: true

require 'dependencies/custom'

RSpec.describe Dependencies::Custom do
	subject { described_class.new(definition) }

	let(:definition) { "ls -la" }

	shared_context "definition is hash" do
		let(:definition) do
			{
				"init file" => {
					"up" => "touch file",
					"down" => "rm file"
				}
			}
		end
	end

	shared_context "definition has only up" do
		let(:definition) do
			{
				"init file" => {
					"up" => "touch file"
				}
			}
		end
	end

	shared_context "definition has only down" do
		let(:definition) do
			{
				"init file" => {
					"down" => "rm file"
				}
			}
		end
	end

	shared_examples "meet executes" do |command|
		it "executes the command" do
			expect(subject).to receive(:execute).with(command)
			subject.meet
		end
	end

	shared_examples "unmeet executes" do |command|
		it "executes the command" do
			expect(subject).to receive(:execute).with(command)
			subject.unmeet
		end
	end

	describe "#met?" do
		it { is_expected.not_to be_met }
	end

	describe "#always_act?" do
		it { is_expected.to be_always_act }
	end

	describe "#meet" do
		include_examples "meet executes", "ls -la"

		context "when definition is a hash" do
			include_context "definition is hash"
			include_examples "meet executes", "touch file"
		end

		context "when definition has only up defined" do
			include_context "definition has only up"
			include_examples "meet executes", "touch file"
		end

		context "when definition has only down defined" do
			include_context "definition has only down"

			it "does not execute a command" do
				expect(subject).not_to receive(:execute)
				subject.meet
			end
		end
	end

	describe "#unmeet" do
		it "does not execute a command" do
			expect(subject).not_to receive(:execute)
			subject.unmeet
		end

		context "when definition is a hash" do
			include_context "definition is hash"
			include_examples "unmeet executes", "rm file"
		end

		context "when definition has only up defined" do
			include_context "definition has only up"

			it "does not execute a command" do
				expect(subject).not_to receive(:execute)
				subject.unmeet
			end
		end

		context "when definition has only down defined" do
			include_context "definition has only down"
			include_examples "unmeet executes", "rm file"
		end
	end
end
