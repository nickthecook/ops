# frozen_string_literal: true

RSpec.describe Builtins::Exec do
	subject { described_class.new(args, config) }

	let(:args) { %w[echo hello world] }
	let(:config) { {} }
	let(:load_secrets_option) { nil }

	before do
		allow(Options).to receive(:get).with("exec.load_secrets").and_return(load_secrets_option)
		allow(Kernel).to receive(:exec).and_return(nil)
	end

	describe "#run" do
		let(:result) { subject.run }

		it "does not load Secrets" do
			expect(Secrets).not_to receive(:load)
			result
		end

		it "executes the given command" do
			expect(Kernel).to receive(:exec).with("echo hello world")
			result
		end

		context "when load_secrets option is true" do
			let(:load_secrets_option) { true }

			it "loads Secrets" do
				expect(Secrets).to receive(:load)
				result
			end
		end
	end
end
