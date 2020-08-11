# frozen_string_literal: true

require 'action'

RSpec.describe Action do
	subject { described_class.new(action_config, args) }
	let(:action_config) { { "command" => "bundle exec rspec" } }
	let(:args) { ["spec/file1.rb", "spec/file2.rb"] }

	describe '#to_s' do
		let(:result) { subject.to_s }

		it "appends args to command" do
			expect(result).to eq("bundle exec rspec spec/file1.rb spec/file2.rb")
		end

		context "when no args are given" do
			let(:args) { [] }

			it "returns the command" do
				expect(result).to eq("bundle exec rspec")
			end
		end
	end

	describe "#run" do
		let(:result) { subject.run }

		before do
			allow(Kernel).to receive(:exec)
		end

		it "executes the command" do
			expect(Kernel).to receive(:exec).with("bundle exec rspec spec/file1.rb spec/file2.rb")
			result
		end

		it "does not load secrets" do
			expect(Secrets).not_to receive(:new)
			result
		end

		context "when command requires secrets" do
			let(:action_config) { { "command" => "bundle exec rspec", "load_secrets" => true } }
			let(:secrets_double) { instance_double(Secrets) }

			before do
				allow(Secrets).to receive(:load).and_return(secrets_double)
			end

			it "loads secrets" do
				expect(Secrets).to receive(:load)
				result
			end
		end
	end
end
