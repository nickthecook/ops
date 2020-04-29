# frozen_string_literal: true

require_relative "../spec_helper.rb"

require_relative "../../lib/dependencies/terraform"

RSpec.describe Dependencies::Terraform do
	subject { described_class.new(name) }
	let(:name) { "some-dependency" }

	describe "#met?" do
		it "returns false" do
			expect(subject.met?).to be false
		end
	end

	describe "always_act?" do
		it "returns true" do
			expect(subject.always_act?).to be true
		end
	end

	describe "#meet" do
		let(:result) { subject.meet }

		it "uses the execute method to run `terraform apply`" do
			expect(subject).to receive(:execute).with(/terraform apply/)
			result
		end

		it "passes the --auto-approve arg to terraform" do
			expect(subject).to receive(:execute).with(/--auto-approve/)
			result
		end

		it "passes the -input=false arg to terraform" do
			expect(subject).to receive(:execute).with(/-input=false/)
			result
		end
	end
end
