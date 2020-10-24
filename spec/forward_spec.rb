# frozen_string_literal: true

require 'forward'

RSpec.describe Forward do
	subject { described_class.new(dir, args) }

	let(:dir) { "some_dir" }
	let(:args) { %w[arg_one arg_two] }

	describe "#run" do
		let(:result) { subject.run }
		let(:ops_double) { instance_double(Ops) }

		before do
			allow(Dir).to receive(:chdir)
			allow(Ops).to receive(:new).and_return(ops_double)
			allow(ops_double).to receive(:run)
		end

		it "outputs a message about forwarding" do
			expect(Output).to receive(:notice).with("Forwarding 'ops arg_one arg_two' to 'some_dir/'...")
			result
		end

		it "changes dir" do
			expect(Dir).to receive(:chdir).with("some_dir")
			result
		end

		it "runs ops" do
			expect(Ops).to receive(:new).with(%w[arg_one arg_two])
			expect(ops_double).to receive(:run).with(no_args)
			result
		end
	end
end
